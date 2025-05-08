const std = @import("std");

pub fn RegisterRW(comptime Register: type, comptime Nullable: type) type {
    const size = @bitSizeOf(Register);
    const IntSize = std.meta.Int(.unsigned, size);

    return extern struct {
        raw: IntSize,

        const Self = @This();

        pub inline fn read(self: *volatile Self) Register {
            return @bitCast(self.raw);
        }

        pub inline fn write(self: *volatile Self, value: Register) void {
            self.writeRaw(@bitCast(value));
        }

        pub inline fn modify(self: *volatile Self, new_value: Nullable) void {
            var old_value = self.read();
            inline for (@typeInfo(@TypeOf(new_value)).@"struct".fields) |field| {
                if (@field(new_value, field.name)) |v| {
                    @field(old_value, field.name) = v;
                }
            }
            self.write(old_value);
        }

        /// Write any type to the register. Any unassigned fields will be set to default.
        pub inline fn writeAny(self: *volatile Self, value: anytype) void {
            var reg = self.default();

            const reg_fields = @typeInfo(@TypeOf(value)).@"struct".fields;
            inline for (reg_fields) |field| {
                @field(reg, field.name) = @field(value, field.name);
            }

            self.write(reg);
        }

        /// Modify register with any type.
        /// Fields can have types different from the register fields, such as optional or bool.
        pub inline fn modifyAny(self: *volatile Self, new_value: anytype) void {
            var old_value = self.read();

            inline for (@typeInfo(@TypeOf(new_value)).@"struct".fields) |field| {
                const old_field_value = @field(old_value, field.name);
                const old_field_value_type_info = @typeInfo(@TypeOf(old_field_value));

                const new_field_value = @field(new_value, field.name);
                const new_field_value_type_info = @typeInfo(@TypeOf(new_field_value));
                const is_new_value_optional = new_field_value_type_info == .optional;

                // Unwrap optional type.
                const new_field_value_unwrapped_type_info = if (is_new_value_optional)
                    @typeInfo(new_field_value_type_info.optional.child)
                else
                    new_field_value_type_info;

                // Null fields don't modify the value.
                if (new_field_value_unwrapped_type_info == .null) {
                    continue;
                }

                // Unwrap optional value.
                const new_field_value_unwrapped: @Type(new_field_value_unwrapped_type_info) = if (is_new_value_optional)
                    // Null values don't modify the field.
                    if (new_field_value) |v| v else continue
                else
                    new_field_value;

                // Allow set boolean values.
                const is_u1_type = old_field_value_type_info.int.signedness == .unsigned and old_field_value_type_info.int.bits == 1;
                if (is_u1_type and new_field_value_unwrapped_type_info == .bool) {
                    @field(old_value, field.name) = if (new_field_value_unwrapped) 1 else 0;
                    continue;
                }

                @field(old_value, field.name) = new_field_value_unwrapped;
            }

            self.write(old_value);
        }

        pub inline fn writeRaw(self: *volatile Self, value: IntSize) void {
            self.raw = value;
        }

        pub inline fn setBits(self: *volatile Self, pos: u5, width: u6, value: IntSize) void {
            if (pos + width > size) {
                return;
            }

            const IntSizePlus1 = std.meta.Int(.unsigned, size + 1);
            const mask: IntSize = @as(IntSize, (@as(IntSizePlus1, 1) << width) - 1) << pos;
            self.raw = (self.raw & ~mask) | ((value << pos) & mask);
        }

        pub inline fn setBit(self: *volatile Self, pos: u5, value: u1) void {
            if (pos >= size) {
                return;
            }

            if (value == 1) {
                self.raw |= @as(IntSize, 1) << pos;
            } else {
                self.raw &= ~(@as(IntSize, 1) << pos);
            }
        }

        pub inline fn getBit(self: *volatile Self, pos: u5) u1 {
            if (pos >= size) {
                return 0;
            }

            return @truncate(self.raw >> pos);
        }

        pub inline fn default(_: *volatile Self) Register {
            return Register{};
        }
    };
}

test RegisterRW {
    const TestPeriferal = packed struct(u32) {
        field0: u1 = 0,
        field1: u2 = 0,
        field2: u3 = 0,
        field3: u4 = 0,
        field4: u5 = 0,
        padding: u17 = 0,
    };
    const TestPeriferalNullables = struct {
        field0: ?u1 = null,
        field1: ?u2 = null,
        field2: ?u3 = null,
        field3: ?u4 = null,
        field4: ?u5 = null,
    };

    const TestPeriferalRegister = RegisterRW(TestPeriferal, TestPeriferalNullables);

    var value: TestPeriferalRegister = @bitCast(@as(u32, 0b0_10101_0101_010_10_1));

    try std.testing.expectEqual(@as(u32, 0b0_10101_0101_010_10_1), value.raw);

    // Read the value.
    try std.testing.expectEqual(TestPeriferal{
        .field0 = 0b1,
        .field1 = 0b10,
        .field2 = 0b010,
        .field3 = 0b0101,
        .field4 = 0b10101,
    }, value.read());

    // Write zeroes.
    value.write(.{});
    try std.testing.expectEqual(TestPeriferal{
        .field0 = 0b0,
        .field1 = 0b0,
        .field2 = 0b0,
        .field3 = 0b0,
        .field4 = 0b0,
    }, value.read());

    // Write ones.
    value.write(TestPeriferal{
        .field0 = 0b1,
        .field1 = 0b1,
        .field2 = 0b1,
        .field3 = 0b1,
        .field4 = 0b1,
    });
    try std.testing.expectEqual(TestPeriferal{
        .field0 = 0b1,
        .field1 = 0b1,
        .field2 = 0b1,
        .field3 = 0b1,
        .field4 = 0b1,
    }, value.read());

    // Modify only field4.
    value.modify(.{
        .field4 = 0b10101,
    });
    try std.testing.expectEqual(TestPeriferal{
        .field0 = 0b1,
        .field1 = 0b1,
        .field2 = 0b1,
        .field3 = 0b1,
        .field4 = 0b10101,
    }, value.read());

    // Set bits in field4.
    value.setBits(10, 5, 0b11001);
    try std.testing.expectEqual(TestPeriferal{
        .field0 = 0b1,
        .field1 = 0b1,
        .field2 = 0b1,
        .field3 = 0b1,
        .field4 = 0b11001,
    }, value.read());

    // Set bit in field4.
    value.setBit(10, 0);
    try std.testing.expectEqual(TestPeriferal{
        .field0 = 0b1,
        .field1 = 0b1,
        .field2 = 0b1,
        .field3 = 0b1,
        .field4 = 0b11000,
    }, value.read());

    var bit = value.getBit(11);
    try std.testing.expectEqual(0b0, bit);

    value.setBit(11, 1);
    try std.testing.expectEqual(TestPeriferal{
        .field0 = 0b1,
        .field1 = 0b1,
        .field2 = 0b1,
        .field3 = 0b1,
        .field4 = 0b11010,
    }, value.read());

    bit = value.getBit(11);
    try std.testing.expectEqual(0b1, bit);

    // Modify with int.
    value.modify(.{
        .field0 = 0,
    });
    try std.testing.expectEqual(TestPeriferal{
        .field0 = 0b0,
        .field1 = 0b1,
        .field2 = 0b1,
        .field3 = 0b1,
        .field4 = 0b11010,
    }, value.read());

    value.modify(.{
        .field0 = 1,
    });
    try std.testing.expectEqual(TestPeriferal{
        .field0 = 0b1,
        .field1 = 0b1,
        .field2 = 0b1,
        .field3 = 0b1,
        .field4 = 0b11010,
    }, value.read());

    // Null fields don't modify the value.
    value.modify(.{
        .field0 = null,
        .field1 = null,
        .field2 = null,
        .field3 = null,
        .field4 = null,
    });
    try std.testing.expectEqual(TestPeriferal{
        .field0 = 0b1,
        .field1 = 0b1,
        .field2 = 0b1,
        .field3 = 0b1,
        .field4 = 0b11010,
    }, value.read());

    value.modify(.{
        .field0 = null,
        .field1 = 0,
        .field2 = null,
        .field3 = 0b1010,
        .field4 = 1,
    });
    try std.testing.expectEqual(TestPeriferal{
        .field0 = 0b1,
        .field1 = 0b0,
        .field2 = 0b1,
        .field3 = 0b1010,
        .field4 = 0b00001,
    }, value.read());

    // And with nullables struct.
    value.modify(TestPeriferalNullables{
        .field0 = null,
        .field1 = 0,
        .field2 = null,
        .field3 = 0b0101,
        // .field4 = null, // Use default value.
    });
    try std.testing.expectEqual(TestPeriferal{
        .field0 = 0b1,
        .field1 = 0b0,
        .field2 = 0b1,
        .field3 = 0b0101,
        .field4 = 0b00001,
    }, value.read());

    // Write any type struct.
    value.writeAny(.{
        .field0 = 0b1,
        .field2 = 0b1,
        .field4 = 4,
    });
    try std.testing.expectEqual(TestPeriferal{
        .field0 = 0b1,
        .field1 = 0b0,
        .field2 = 0b1,
        .field3 = 0b0,
        .field4 = 4,
    }, value.read());

    // Modify with any type struct.
    value.modifyAny(.{
        .field0 = false,
        .field1 = 1,
        .field2 = 2,
        .field3 = 3,
        .field4 = null, // Should be not modified.
    });
    try std.testing.expectEqual(TestPeriferal{
        .field0 = 0,
        .field1 = 1,
        .field2 = 2,
        .field3 = 3,
        .field4 = 4,
    }, value.read());
}
