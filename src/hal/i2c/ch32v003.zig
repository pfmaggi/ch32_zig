const port = @import("../port.zig");
const Pin = @import("../Pin.zig");
const svd = @import("svd");

pub const Pins = struct {
    scl: Pin,
    sda: Pin,
    remap: Remap,

    const Remap = struct {
        afio_pcfr1: svd.nullable_types.AFIO.PCFR1,

        pub fn has(self: Remap) bool {
            return isSet(self.afio_pcfr1.I2C1_RM) or isSet(self.afio_pcfr1.I2C1REMAP1);
        }

        inline fn isSet(value: anytype) bool {
            return value != null and value.? != 0;
        }
    };

    pub const i2c1 = struct {
        pub const default = scl_pc2_sda_pc1;
        // 00: default mapping (SCL/PC2, SDA/PC1).
        pub const scl_pc2_sda_pc1: Pins = .{
            .scl = Pin.init(.GPIOC, 2),
            .sda = Pin.init(.GPIOC, 1),
            .remap = .{ .afio_pcfr1 = .{ .I2C1_RM = 0, .I2C1REMAP1 = 0 } },
        };
        // 01: Remapping (SCL/PD1, SDA/PD0).
        pub const scl_pd1_sda_pd0: Pins = .{
            .scl = Pin.init(.GPIOD, 1),
            .sda = Pin.init(.GPIOD, 0),
            .remap = .{ .afio_pcfr1 = .{ .I2C1_RM = 1, .I2C1REMAP1 = 0 } },
        };
        // 1X: Remapping (SCL/PC5, SDA/PC6).
        pub const scl_pc5_sda_pc6: Pins = .{
            .scl = Pin.init(.GPIOC, 5),
            .sda = Pin.init(.GPIOC, 6),
            .remap = .{ .afio_pcfr1 = .{ .I2C1_RM = 0, .I2C1REMAP1 = 1 } },
        };
    };

    pub inline fn namespaceFor(comptime reg: *volatile svd.types.I2C) type {
        return switch (reg.addr()) {
            svd.types.I2C.I2C1.addr() => Pins.i2c1,
            else => @compileError("Unsupported I2C peripheral"),
        };
    }

    pub inline fn defaultFor(comptime reg: *volatile svd.types.I2C) Pins {
        return namespaceFor(reg).default;
    }
};

pub const rcc = struct {
    pub inline fn enable(reg: *volatile svd.types.I2C) void {
        set(reg, true);
    }

    pub inline fn disable(reg: *volatile svd.types.I2C) void {
        set(reg, false);
    }

    pub inline fn reset(reg: *volatile svd.types.I2C) void {
        switch (reg.addr()) {
            svd.types.I2C.I2C1.addr() => {
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .I2C1RST = 1 });
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .I2C1RST = 0 });
            },
            else => unreachable,
        }
    }

    inline fn set(reg: *volatile svd.types.I2C, en: bool) void {
        const en_value = if (en) 1 else 0;
        switch (reg.addr()) {
            svd.types.I2C.I2C1.addr() => {
                svd.peripherals.RCC.APB1PCENR.modify(.{ .I2C1EN = en_value });
            },
            else => unreachable,
        }
    }
};
