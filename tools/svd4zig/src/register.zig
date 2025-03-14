const std = @import("std");

pub fn RegisterRW(comptime Register: type) type {
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

        pub inline fn modify(self: *volatile Self, new_value: anytype) void {
            var old_value = self.read();
            const info = @typeInfo(@TypeOf(new_value));
            inline for (info.@"struct".fields) |field| {
                const new_field_value = @field(new_value, field.name);

                // Allow set boolean values.
                const old_field_value_type_info = @typeInfo(@TypeOf(@field(old_value, field.name)));
                const new_field_value_type_info = @typeInfo(@TypeOf(new_field_value));
                if (old_field_value_type_info.int.signedness == .unsigned and old_field_value_type_info.int.bits == 1 and new_field_value_type_info == .bool) {
                    @field(old_value, field.name) = if (new_field_value) 1 else 0;
                    continue;
                }

                @field(old_value, field.name) = new_field_value;
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
    const TestPeriferalRegister = RegisterRW(TestPeriferal);

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

    value.setBit(11, 1);
    try std.testing.expectEqual(TestPeriferal{
        .field0 = 0b1,
        .field1 = 0b1,
        .field2 = 0b1,
        .field3 = 0b1,
        .field4 = 0b11010,
    }, value.read());

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

    // Modify with boolean.
    value.modify(.{
        .field0 = false,
    });
    try std.testing.expectEqual(TestPeriferal{
        .field0 = 0b0,
        .field1 = 0b1,
        .field2 = 0b1,
        .field3 = 0b1,
        .field4 = 0b11010,
    }, value.read());

    value.modify(.{
        .field0 = true,
    });
    try std.testing.expectEqual(TestPeriferal{
        .field0 = 0b1,
        .field1 = 0b1,
        .field2 = 0b1,
        .field3 = 0b1,
        .field4 = 0b11010,
    }, value.read());
}
