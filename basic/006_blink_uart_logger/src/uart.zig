const std = @import("std");

const RCC_APB2PCENR: *volatile u32 = @ptrFromInt(0x40021018);
const GPIOD_CFGLR: *volatile u32 = @ptrFromInt(0x40011400);

pub const USART1: UART = @bitCast(@as(u32, 0x40013800));

pub const Config = struct {
    cpu_frequency: u32,
    baud_rate: u32,
    word_bits: WordBits = .eight,
    stop_bits: StopBits = .one,
    parity: Parity = .none,
    flow_control: FlowControl = .none,
};

pub const WordBits = enum {
    eight,
    nine,
};

pub const StopBits = enum {
    one,
    half,
    two,
    one_and_a_half,
};

pub const Parity = enum {
    none,
    even,
    odd,
};

pub const FlowControl = enum {
    none,
    cts,
    rts,
    cts_rts,
};

pub const UART = packed struct(u32) {
    addr: u32,

    // Table 12-2 USART-related registers list (CH32V003 Reference Manual).
    const STATR_OFFSET: u32 = 0x00;
    const DATAR_OFFSET: u32 = 0x04;
    const BRR_OFFSET: u32 = 0x08;
    const CTLR1_OFFSET: u32 = 0x0C;
    const CTLR2_OFFSET: u32 = 0x10;
    const CTLR3_OFFSET: u32 = 0x14;

    pub const Writer = std.io.GenericWriter(UART, error{}, genericWriterFn);

    pub fn writer(self: UART) Writer {
        return .{ .context = self };
    }

    pub fn genericWriterFn(self: UART, buffer: []const u8) error{}!usize {
        return self.writeBlocking(buffer);
    }

    fn ptr(self: UART, offset: u32) *volatile u32 {
        return @ptrFromInt(self.addr + offset);
    }

    pub fn setup(comptime self: UART, comptime cfg: Config) void {
        self.setupPins();
        self.setupBrr(cfg);
        self.setupCtrl(cfg);
    }

    fn setupPins(comptime self: UART) void {
        if (self != USART1) {
            @compileError("UART not supported");
        }

        // Enable Port D clock.
        RCC_APB2PCENR.* |= @as(u32, 1 << 5);
        // Enable USART1 clock.
        RCC_APB2PCENR.* |= @as(u32, 1 << 14);

        // GPIOD
        // TX - GPIO D5
        // Clear all bits
        GPIOD_CFGLR.* &= ~@as(u32, 0b1111 << 4 * 5);
        // Set
        // Mode 01: Output max 10MHz
        // CNF 10: Multiplexed Push-Pull
        GPIOD_CFGLR.* |= @as(u32, 0b10_01 << 4 * 5);

        // RX - GPIO D6
        // Clear all bits
        GPIOD_CFGLR.* &= ~@as(u32, 0b1111 << 4 * 6);
        // Mode 00: Input
        // CNF 01: Floating
        GPIOD_CFGLR.* |= @as(u32, 0b01_00 << 4 * 6);
    }

    fn setupBrr(self: UART, comptime cfg: Config) void {
        const USART_BRR: *volatile u32 = self.ptr(BRR_OFFSET);

        const brr = (cfg.cpu_frequency + cfg.baud_rate / 2) / cfg.baud_rate;
        USART_BRR.* = brr;
    }

    fn setupCtrl(self: UART, comptime cfg: Config) void {
        const parity_bit = switch (cfg.parity) {
            .none => @as(u1, 0),
            .even, .odd => @as(u1, 1),
        };
        const parity_selection_bit = switch (cfg.parity) {
            .even => @as(u1, 1),
            .odd, .none => @as(u1, 0),
        };
        const word_long_bit = switch (cfg.word_bits) {
            .eight => @as(u1, 0),
            .nine => @as(u1, 1),
        };
        const stop_bits = switch (cfg.stop_bits) {
            .one => @as(u2, 0b00),
            .half => @as(u2, 0b01),
            .two => @as(u2, 0b10),
            .one_and_a_half => @as(u2, 0b11),
        };
        var rts_bit: u1 = 0;
        var cts_bit: u1 = 0;
        switch (cfg.flow_control) {
            .none => {},
            .cts => cts_bit = 1,
            .rts => rts_bit = 1,
            .cts_rts => {
                cts_bit = 1;
                rts_bit = 1;
            },
        }

        const USART_CTLR1: *volatile u32 = self.ptr(CTLR1_OFFSET);
        const USART_CTLR2: *volatile u32 = self.ptr(CTLR2_OFFSET);
        const USART_CTLR3: *volatile u32 = self.ptr(CTLR3_OFFSET);

        // Reset.
        USART_CTLR1.* = 0;
        // RE: Receiver enable.
        USART_CTLR1.* |= @as(u32, 1) << 2;
        // TE: Transmitter enable.
        USART_CTLR1.* |= @as(u32, 1) << 3;
        // PEIE: Parity check interrupt enable bit.
        USART_CTLR1.* |= @as(u32, parity_bit) << 8;
        // PS: Parity selection bit.
        USART_CTLR1.* |= @as(u32, parity_selection_bit) << 9;
        // M: Word long bit.
        USART_CTLR1.* |= @as(u32, word_long_bit) << 12;

        // Reset.
        USART_CTLR2.* = 0;
        // STOP: Stop bits.
        USART_CTLR2.* |= @as(u32, stop_bits) << 12;

        // Reset.
        USART_CTLR3.* = 0;
        // RTSE: RTS enable.
        USART_CTLR3.* |= @as(u32, rts_bit) << 8;
        // CTSE: CTS enable.
        USART_CTLR3.* |= @as(u32, cts_bit) << 9;

        // UE: UART enable bit.
        USART_CTLR1.* |= @as(u32, 1) << 13;
    }

    pub inline fn isReadable(self: UART) bool {
        const USART_STATR: *volatile u32 = self.ptr(STATR_OFFSET);
        const RXNE = @as(u32, 1) << 5;
        return (USART_STATR.* & RXNE) != 0;
    }

    pub inline fn isWriteable(self: UART) bool {
        const USART_STATR: *volatile u32 = self.ptr(STATR_OFFSET);
        const TXE = @as(u32, 1) << 7;
        return (USART_STATR.* & TXE) != 0;
    }

    pub inline fn isWriteComplete(self: UART) bool {
        const USART_STATR: *volatile u32 = self.ptr(STATR_OFFSET);
        const TC = @as(u32, 1) << 6;
        return (USART_STATR.* & TC) != 0;
    }

    pub noinline fn writeBlocking(self: UART, payload: []const u8) usize {
        const USART_DATAR: *volatile u32 = self.ptr(DATAR_OFFSET);

        var offset: usize = 0;
        while (offset < payload.len) {
            while (!self.isWriteable()) {
                asm volatile ("" ::: "memory");
            }

            USART_DATAR.* = payload[offset];
            offset += 1;

            while (!self.isWriteComplete()) {
                asm volatile ("" ::: "memory");
            }
        }

        return offset;
    }

    pub fn readBlocking(self: UART, buffer: []u8) usize {
        const USART_DATAR: *volatile u32 = self.ptr(DATAR_OFFSET);

        var count: u32 = 0;
        for (buffer) |*byte| {
            while (!self.isReadable()) {
                asm volatile ("" ::: "memory");
            }

            byte.* = @truncate(USART_DATAR.* & 0xFF);
            count += 1;
        }

        return count;
    }
};
