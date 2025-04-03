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
        afio_pcfr1: svd.nullable_types.AFIO.PCFR1,

        pub fn has(self: Remap) bool {
            return isSet(self.afio_pcfr1.USART1_RM) or isSet(self.afio_pcfr1.USART1REMAP1);
        }

        inline fn isSet(value: anytype) bool {
            return value != null and value.? != 0;
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

    pub inline fn namespaceFor(comptime reg: *volatile svd.registers.USART) type {
        return switch (reg.addr()) {
            svd.registers.USART.USART1.addr() => Pins.usart1,
            else => @compileError("Unsupported USART peripheral"),
        };
    }

    pub inline fn defaultFor(comptime reg: *volatile svd.registers.USART) Pins {
        return namespaceFor(reg).default;
    }
};

pub const rcc = struct {
    pub inline fn enable(reg: *volatile svd.registers.USART) void {
        set(reg, true);
    }

    pub inline fn disable(reg: *volatile svd.registers.USART) void {
        set(reg, false);
    }

    pub inline fn reset(reg: *volatile svd.registers.USART) void {
        switch (reg.addr()) {
            svd.registers.USART.USART1.addr() => {
                svd.peripherals.RCC.APB2PRSTR.modify(.{ .USART1RST = 1 });
                svd.peripherals.RCC.APB2PRSTR.modify(.{ .USART1RST = 0 });
            },
            else => unreachable,
        }
    }

    inline fn set(reg: *volatile svd.registers.USART, en: bool) void {
        const en_value = if (en) 1 else 0;
        switch (reg.addr()) {
            svd.registers.USART.USART1.addr() => {
                svd.peripherals.RCC.APB2PCENR.modify(.{ .USART1EN = en_value });
            },
            else => unreachable,
        }
    }
};
