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

.{ .name = .{ .items = { 67, 72, 51, 50, 86, 51, 48, 120 }, .capacity = 128, .allocator = .{ .ptr = anyopaque@7ffc2474f000, .vtable = .{ ... } } }, .version = .{ .items = { 49, 46, 50 }, .capacity = 128, .allocator = .{ .ptr = anyopaque@7ffc2474f000, .vtable = .{ ... } } }, .description = .{ .items = { 67, 72, 51, 50, 86, 51, 48, 120, 32, 86, 105, 101, 119, 32, 70, 105, 108, 101 }, .capacity = 128, .allocator = .{ .ptr = anyopaque@7ffc2474f000, .vtable = .{ ... } } }, .cpu = null, .address_unit_bits = 8, .max_bit_width = 32, .reg_default_size = null, .reg_default_reset_value = null, .reg_default_reset_mask = null, .peripherals = .{ .items = { .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }, .{ ... }