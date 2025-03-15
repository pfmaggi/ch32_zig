const port = @import("../port.zig");
const Pin = @import("../Pin.zig");
const svd = @import("svd");

pub const Pins = struct {
    ck: ?Pin,
    tx: Pin,
    rx: Pin,
    cts: ?Pin,
    rts: ?Pin,
    remap: Remap,

    const Remap = struct {
        afio_pcfr1: struct {
            /// USART1_RM [2:2]
            /// USART1 remapping
            USART1_RM: u1 = 0,
            /// USART1REMAP1 [21:21]
            /// USART1 remapping
            USART1REMAP1: u1 = 0,
        },

        pub fn has(self: Remap) bool {
            return self.afio_pcfr1.USART1_RM != 0 or self.afio_pcfr1.USART1REMAP1 != 0;
        }
    };

    pub const usart1 = struct {
        // 00: default mapping (CK/PD4, TX/PD5, RX/PD6, CTS/PD3, RTS/PC2).
        pub const default = tx_pd5_rx_pd6;
        pub const tx_pd5_rx_pd6: Pins = .{
            .ck = Pin.init(.GPIOD, 4),
            .tx = Pin.init(.GPIOD, 5),
            .rx = Pin.init(.GPIOD, 6),
            .cts = Pin.init(.GPIOD, 3),
            .rts = Pin.init(.GPIOC, 2),
            .remap = .{ .afio_pcfr1 = .{ .USART1_RM = 0, .USART1REMAP1 = 0 } },
        };
        // 01: Remapping (CK/PD7, TX/PD0, RX/PD1, CTS/PC3, RTS/PC2, SW_RX/PD0).
        pub const tx_pd0_rx_pd1: Pins = .{
            .ck = Pin.init(.GPIOD, 7),
            .tx = Pin.init(.GPIOD, 0),
            .rx = Pin.init(.GPIOD, 1),
            .cts = Pin.init(.GPIOC, 3),
            .rts = Pin.init(.GPIOC, 2),
            .remap = .{ .afio_pcfr1 = .{ .USART1_RM = 1, .USART1REMAP1 = 0 } },
        };
        // 10: Remapping (CK/PD7, TX/PD6, RX/PD5, CTS/PC6, RTS/PC7, SW_RX/PD6).
        pub const tx_pd6_rx_pd5: Pins = .{
            .ck = Pin.init(.GPIOD, 7),
            .tx = Pin.init(.GPIOD, 6),
            .rx = Pin.init(.GPIOD, 5),
            .cts = Pin.init(.GPIOC, 6),
            .rts = Pin.init(.GPIOC, 7),
            .remap = .{ .afio_pcfr1 = .{ .USART1_RM = 0, .USART1REMAP1 = 1 } },
        };
        // 11: Remapping (CK/PC5, TX/PC0, RX/PC1, CTS/PC6, RTS/PC7, SW_RX/PC0).
        pub const tx_pc0_rx_pc1: Pins = .{
            .ck = Pin.init(.GPIOC, 5),
            .tx = Pin.init(.GPIOC, 0),
            .rx = Pin.init(.GPIOC, 1),
            .cts = Pin.init(.GPIOC, 6),
            .rts = Pin.init(.GPIOC, 7),
            .remap = .{ .afio_pcfr1 = .{ .USART1_RM = 1, .USART1REMAP1 = 1 } },
        };
    };

    pub inline fn get_default(uart: *volatile svd.types.USART) Pins {
        switch (uart.addr()) {
            svd.types.USART.USART1.addr() => return Pins.usart1.default,
            else => unreachable,
        }
    }
};

pub const RccBits = struct {
    apb2: ?u5,
    apb1: ?u5,

    const usart1_offset = @bitOffsetOf(@TypeOf(svd.peripherals.RCC.APB2PCENR.default()), "USART1EN");
    pub const usart1 = RccBits{ .apb2 = usart1_offset, .apb1 = null };

    pub inline fn get(uart: *volatile svd.types.USART) RccBits {
        switch (uart.addr()) {
            svd.types.USART.USART1.addr() => return RccBits.usart1,
            else => unreachable,
        }
    }
};
