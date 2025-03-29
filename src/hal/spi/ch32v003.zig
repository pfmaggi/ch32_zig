const port = @import("../port.zig");
const Pin = @import("../Pin.zig");
const svd = @import("svd");

pub const NssPin = struct {
    pin: Pin,
    is_hardware: bool,
};

pub const Pins = struct {
    nss: ?NssPin,
    sck: Pin,
    miso: Pin,
    mosi: Pin,
    remap: Remap,

    const Remap = struct {
        afio_pcfr1: svd.nullable_types.AFIO.PCFR1,

        pub fn has(self: Remap) bool {
            return isSet(self.afio_pcfr1.SPI1_RM);
        }

        inline fn isSet(value: anytype) bool {
            return value != null and value.? != 0;
        }
    };

    pub const spi1 = struct {
        // 0: Default mapping (NSS/PC1, CK/PC5, MISO/PC7, MOSI/PC6).
        pub const default = sck_pc5_miso_pc7_mosi_pc6_nss_pc1;
        pub const sck_pc5_miso_pc7_mosi_pc6_nss_pc1: Pins = .{
            .nss = .{ .pin = Pin.init(.GPIOC, 1), .is_hardware = true },
            .sck = Pin.init(.GPIOC, 5),
            .miso = Pin.init(.GPIOC, 7),
            .mosi = Pin.init(.GPIOC, 6),
            .remap = .{ .afio_pcfr1 = .{ .SPI1_RM = 0 } },
        };
        // 1: Remapping (NSS/PC0, CK/PC5, MISO/PC7, MOSI/PC6).
        pub const sck_pc5_miso_pc7_mosi_pc6_nss_pc0: Pins = .{
            .nss = .{ .pin = Pin.init(.GPIOC, 0), .is_hardware = true },
            .sck = Pin.init(.GPIOC, 5),
            .miso = Pin.init(.GPIOC, 7),
            .mosi = Pin.init(.GPIOC, 6),
            .remap = .{ .afio_pcfr1 = .{ .SPI1_RM = 1 } },
        };
    };

    // Software NSS mode.
    pub fn softwareNss(base: Pins, nss: ?Pin) Pins {
        return .{
            .nss = if (nss) |p| NssPin{ .pin = p, .is_hardware = false } else null,
            .sck = base.sck,
            .miso = base.miso,
            .mosi = base.mosi,
            .remap = base.remap,
        };
    }

    pub inline fn namespaceFor(comptime reg: *volatile svd.types.SPI) type {
        return switch (reg.addr()) {
            svd.types.SPI.SPI1.addr() => Pins.spi1,
            else => @compileError("Unsupported SPI peripheral"),
        };
    }

    pub inline fn defaultFor(comptime reg: *volatile svd.types.SPI) Pins {
        return namespaceFor(reg).default;
    }

    pub fn isHardwareNss(self: Pins) bool {
        if (self.nss) |nss| {
            return nss.is_hardware;
        }

        return false;
    }

    pub fn eqWithoutNss(self: Pins, other: Pins) bool {
        return self.sck.eq(other.sck) and self.miso.eq(other.miso) and self.mosi.eq(other.mosi);
    }
};

pub const rcc = struct {
    pub inline fn enable(reg: *volatile svd.types.SPI) void {
        set(reg, true);
    }

    pub inline fn disable(reg: *volatile svd.types.SPI) void {
        set(reg, false);
    }

    pub inline fn reset(reg: *volatile svd.types.SPI) void {
        switch (reg.addr()) {
            svd.types.SPI.SPI1.addr() => {
                svd.peripherals.RCC.APB2PRSTR.modify(.{ .SPI1RST = 1 });
                svd.peripherals.RCC.APB2PRSTR.modify(.{ .SPI1RST = 0 });
            },
            else => unreachable,
        }
    }

    inline fn set(reg: *volatile svd.types.SPI, en: bool) void {
        const en_value = if (en) 1 else 0;
        switch (reg.addr()) {
            svd.types.SPI.SPI1.addr() => {
                svd.peripherals.RCC.APB2PCENR.modify(.{ .SPI1EN = en_value });
            },
            else => unreachable,
        }
    }
};
