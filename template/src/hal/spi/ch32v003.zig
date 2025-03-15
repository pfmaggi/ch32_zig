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
        afio_pcfr1: struct {
            /// SPI1_RM [0:0]
            /// SPI1 remapping
            SPI1_RM: u1 = 0,
        },

        pub fn has(self: Remap) bool {
            return self.afio_pcfr1.SPI1_RM != 0;
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
        // Software NSS mode.
        pub fn softwareNss(nss: ?Pin) Pins {
            return .{
                .nss = if (nss) |p| NssPin{ .pin = p, .is_hardware = false } else null,
                .sck = Pin.init(.GPIOC, 5),
                .miso = Pin.init(.GPIOC, 7),
                .mosi = Pin.init(.GPIOC, 6),
                .remap = .{ .afio_pcfr1 = .{ .SPI1_RM = 0 } },
            };
        }
    };

    pub inline fn get_default(spi: *volatile svd.types.SPI) Pins {
        switch (spi.addr()) {
            svd.types.SPI.SPI1.addr() => return Pins.spi1.default,
            else => unreachable,
        }
    }
};

pub const RccBits = struct {
    apb2: ?u5,
    apb1: ?u5,

    const spi1_offset = @bitOffsetOf(@TypeOf(svd.peripherals.RCC.APB2PCENR.default()), "SPI1EN");
    pub const spi1 = RccBits{ .apb2 = spi1_offset, .apb1 = null };

    pub inline fn get(spi: *volatile svd.types.SPI) RccBits {
        switch (spi.addr()) {
            svd.types.SPI.SPI1.addr() => return RccBits.spi1,
            else => unreachable,
        }
    }
};
