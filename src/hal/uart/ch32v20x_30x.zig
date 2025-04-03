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
        afio_pcfr2: svd.nullable_types.AFIO.PCFR2,

        pub fn has(self: Remap) bool {
            return isSet(self.afio_pcfr1.USART1_RM) or isSet(self.afio_pcfr2.UART1_RM1);
        }

        inline fn isSet(value: anytype) bool {
            return value != null and value.? != 0;
        }
    };

    pub const usart1 = struct {
        // 00: Default map (CK/PA8, TX/PA9, RX/PA10, CTS/PA11, RTS/PA12).
        pub const default = tx_pa9_rx_pa10;
        pub const tx_pa9_rx_pa10: Pins = .{
            .ck = Pin.init(.GPIOA, 8),
            .tx = Pin.init(.GPIOA, 9),
            .rx = Pin.init(.GPIOA, 10),
            .cts = Pin.init(.GPIOA, 11),
            .rts = Pin.init(.GPIOA, 12),
            .remap = .{
                .afio_pcfr1 = .{ .USART1_RM = 0 },
                .afio_pcfr2 = .{ .UART1_RM1 = 0 },
            },
        };
        // 01: Remap (CK/PA8, TX/PB6, RX/PB7, CTS/PA11, RTS/PA12).
        pub const tx_pd0_rx_pd1: Pins = .{
            .ck = Pin.init(.GPIOA, 8),
            .tx = Pin.init(.GPIOB, 6),
            .rx = Pin.init(.GPIOB, 7),
            .cts = Pin.init(.GPIOA, 11),
            .rts = Pin.init(.GPIOA, 12),
            .remap = .{
                .afio_pcfr1 = .{ .USART1_RM = 1 },
                .afio_pcfr2 = .{ .UART1_RM1 = 0 },
            },
        };
        // 10: Remap (CK/PA10, TX/PB15, RX/PA8, CTS/PA5, RTS/PA9).
        pub const tx_pd6_rx_pd5: Pins = .{
            .ck = Pin.init(.GPIOA, 10),
            .tx = Pin.init(.GPIOB, 15),
            .rx = Pin.init(.GPIOA, 8),
            .cts = Pin.init(.GPIOA, 5),
            .rts = Pin.init(.GPIOA, 9),
            .remap = .{
                .afio_pcfr1 = .{ .USART1_RM = 0 },
                .afio_pcfr2 = .{ .UART1_RM1 = 1 },
            },
        };
        // 11: Remap (CK/PA5, TX/PA6, RX/PA7, CTS/PC4, RTS/PC5).
        pub const tx_pc0_rx_pc1: Pins = .{
            .ck = Pin.init(.GPIOA, 5),
            .tx = Pin.init(.GPIOA, 6),
            .rx = Pin.init(.GPIOA, 7),
            .cts = Pin.init(.GPIOC, 4),
            .rts = Pin.init(.GPIOC, 5),
            .remap = .{
                .afio_pcfr1 = .{ .USART1_RM = 1 },
                .afio_pcfr2 = .{ .UART1_RM1 = 1 },
            },
        };
    };

    // TODO: add other USARTs

    pub inline fn namespaceFor(comptime reg: *volatile svd.registers.USART) type {
        return switch (reg.addr()) {
            svd.registers.USART.USART1.addr() => return Pins.usart1,
            // svd.registers.USART.USART2.addr() => return Pins.usart2,
            // svd.registers.USART.USART3.addr() => return Pins.usart3,
            // svd.registers.USART.UART4.addr() => return Pins.uart4,
            // svd.registers.USART.UART5.addr() => return Pins.uart5,
            // svd.registers.USART.UART6.addr() => return Pins.uart6,
            // svd.registers.USART.UART7.addr() => return Pins.uart7,
            // svd.registers.USART.UART8.addr() => return Pins.uart8,
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
            svd.registers.USART.USART2.addr() => {
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .USART2RST = 1 });
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .USART2RST = 0 });
            },
            svd.registers.USART.USART3.addr() => {
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .USART3RST = 1 });
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .USART3RST = 0 });
            },
            svd.registers.USART.UART4.addr() => {
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .USART4RST = 1 });
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .USART4RST = 0 });
            },
            svd.registers.USART.UART5.addr() => {
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .USART5RST = 1 });
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .USART5RST = 0 });
            },
            svd.registers.USART.UART6.addr() => {
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .UART6RST = 1 });
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .UART6RST = 0 });
            },
            svd.registers.USART.UART7.addr() => {
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .UART7RST = 1 });
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .UART7RST = 0 });
            },
            svd.registers.USART.UART8.addr() => {
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .UART8RST = 1 });
                svd.peripherals.RCC.APB1PRSTR.modify(.{ .UART8RST = 0 });
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
            svd.registers.USART.USART2.addr() => {
                svd.peripherals.RCC.APB1PCENR.modify(.{ .USART2EN = en_value });
            },
            svd.registers.USART.USART3.addr() => {
                svd.peripherals.RCC.APB1PCENR.modify(.{ .USART3EN = en_value });
            },
            svd.registers.USART.UART4.addr() => {
                svd.peripherals.RCC.APB1PCENR.modify(.{ .UART4EN = en_value });
            },
            svd.registers.USART.UART5.addr() => {
                svd.peripherals.RCC.APB1PCENR.modify(.{ .UART5EN = en_value });
            },
            svd.registers.USART.UART6.addr() => {
                svd.peripherals.RCC.APB1PCENR.modify(.{ .USART6_EN = en_value });
            },
            svd.registers.USART.UART7.addr() => {
                svd.peripherals.RCC.APB1PCENR.modify(.{ .USART7_EN = en_value });
            },
            svd.registers.USART.UART8.addr() => {
                svd.peripherals.RCC.APB1PCENR.modify(.{ .USART8_EN = en_value });
            },
            else => unreachable,
        }
    }
};
