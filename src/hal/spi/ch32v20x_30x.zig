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
            return isSet(self.afio_pcfr1.SPI1_RM) or isSet(self.afio_pcfr1.SPI3_RM);
        }

        inline fn isSet(value: anytype) bool {
            return value != null and value.? != 0;
        }
    };

    pub const spi1 = struct {
        // 0: Default map (NSS/PA4, SCK/PA5, MISO/PA6, MOSI/PA7).
        pub const default = sck_pa5_miso_pa6_mosi_pa7_nss_pa4;
        pub const sck_pa5_miso_pa6_mosi_pa7_nss_pa4: Pins = .{
            .nss = .{ .pin = Pin.init(.GPIOA, 4), .is_hardware = true },
            .sck = Pin.init(.GPIOA, 5),
            .miso = Pin.init(.GPIOA, 6),
            .mosi = Pin.init(.GPIOA, 7),
            .remap = .{ .afio_pcfr1 = .{ .SPI1_RM = 0 } },
        };
        // 1: Remap (NSS/PA15, SCK/PB3, MISO/PB4, MOSI/PB5).
        pub const sck_pb3_miso_pb4_mosi_pb5_nss_pa15: Pins = .{
            .nss = .{ .pin = Pin.init(.GPIOA, 15), .is_hardware = true },
            .sck = Pin.init(.GPIOB, 3),
            .miso = Pin.init(.GPIOB, 4),
            .mosi = Pin.init(.GPIOB, 5),
            .remap = .{ .afio_pcfr1 = .{ .SPI1_RM = 1 } },
        };
    };

    pub const spi2 = struct {
        pub const default = sck_pb13_miso_pb14_mosi_pb15_nss_pb12;
        // Default map (NSS/PB12, SCK/PB13, MISO/PB14, MOSI/PB15).
        pub const sck_pb13_miso_pb14_mosi_pb15_nss_pb12: Pins = .{
            .nss = .{ .pin = Pin.init(.GPIOB, 12), .is_hardware = true },
            .sck = Pin.init(.GPIOB, 13),
            .miso = Pin.init(.GPIOB, 14),
            .mosi = Pin.init(.GPIOB, 15),
            .remap = .{ .afio_pcfr1 = .{} },
        };
    };

    pub const spi3 = struct {
        pub const default = sck_pb3_miso_pb4_mosi_pb5_nss_pa15;
        // 0: Default map (NSS/PA15, SCK/PB3, MSIO/PB4, MOSI/PB5);
        pub const sck_pb3_miso_pb4_mosi_pb5_nss_pa15: Pins = .{
            .nss = .{ .pin = Pin.init(.GPIOA, 15), .is_hardware = true },
            .sck = Pin.init(.GPIOB, 3),
            .miso = Pin.init(.GPIOB, 4),
            .mosi = Pin.init(.GPIOB, 5),
            .remap = .{ .afio_pcfr1 = .{ .SPI3_RM = 0 } },
        };
        // 1: Remap (NSS/PA4, SCK/PC10, MSIO/PC11, MOSI/PC12).
        pub const sck_pc10_miso_pc11_mosi_pc12_nss_pa4: Pins = .{
            .nss = .{ .pin = Pin.init(.GPIOA, 4), .is_hardware = true },
            .sck = Pin.init(.GPIOC, 10),
            .miso = Pin.init(.GPIOC, 11),
            .mosi = Pin.init(.GPIOC, 12),
            .remap = .{ .afio_pcfr1 = .{ .SPI3_RM = 1 } },
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

    pub inline fn namespaceFor(comptime reg: *volatile svd.registers.SPI) type {
        switch (reg.addr()) {
            svd.registers.SPI.SPI1.addr() => return Pins.spi1,
            svd.registers.SPI_2.SPI2.addr() => return Pins.spi2,
            svd.registers.SPI_2.SPI3.addr() => return Pins.spi3,
            else => unreachable,
        }
    }

    pub inline fn defaultFor(comptime reg: *volatile svd.registers.SPI) Pins {
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
    pub inline fn enable(reg: *volatile svd.registers.SPI) void {
        set(reg, true);
    }

    pub inline fn disable(reg: *volatile svd.registers.SPI) void {
        set(reg, false);
    }

    pub inline fn reset(reg: *volatile svd.registers.SPI) void {
        switch (reg.addr()) {
            svd.registers.SPI.SPI1.addr() => {
                svd.peripherals.RCC.APB2PRSTR.modify(.{ .SPI1RST = 1 });
                svd.peripherals.RCC.APB2PRSTR.modify(.{ .SPI1RST = 0 });
            },
            svd.registers.SPI_2.SPI2.addr() => {
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .SPI2RST = 1 });
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .SPI2RST = 0 });
            },
            svd.registers.SPI_2.SPI3.addr() => {
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .SPI3RST = 1 });
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .SPI3RST = 0 });
            },
            else => unreachable,
        }
    }

    inline fn set(reg: *volatile svd.registers.SPI, en: bool) void {
        const en_value = if (en) 1 else 0;
        switch (reg.addr()) {
            svd.registers.SPI.SPI1.addr() => {
                svd.peripherals.RCC.APB2PCENR.modify(.{ .SPI1EN = en_value });
            },
            svd.registers.SPI_2.SPI2.addr() => {
                svd.peripherals.RCC.APB1PCENR.modify(.{ .SPI2EN = en_value });
            },
            svd.registers.SPI_2.SPI3.addr() => {
                svd.peripherals.RCC.APB1PCENR.modify(.{ .SPI3EN = en_value });
            },
            else => unreachable,
        }
    }
};
