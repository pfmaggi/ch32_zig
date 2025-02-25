const std = @import("std");

const RCC_APB2PCENR: *volatile u32 = @ptrFromInt(0x40021018);
const GPIOD_CFGLR: *volatile u32 = @ptrFromInt(0x40011400);

pub const USART1: UART = @enumFromInt(0x40013800);

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
    CTS,
    RTS,
    CTS_RTS,
};

pub const TransmitError = error{
    Timeout,
};

pub const ReceiveError = error{
    OverrunError,
    BreakError,
    ParityError,
    FramingError,
    NoiseError,
    Timeout,
};

pub const ErrorStates = packed struct(u4) {
    overrun_error: bool = false,
    break_error: bool = false,
    parity_error: bool = false,
    framing_error: bool = false,
    noise_error: bool = false,
};

pub const UART = enum(u32) {
    _,

    // Table 12-2 USART-related registers list (CH32V003 Reference Manual).
    const STATR_offset: u32 = 0x00;
    const DATAR_offset: u32 = 0x04;
    const BRR_offset: u32 = 0x08;
    const CTLR1_offset: u32 = 0x0C;
    const CTLR2_offset: u32 = 0x10;
    const CTLR3_offset: u32 = 0x14;

    pub const DeadlineFn = fn () bool;

    pub const Writer = std.io.GenericWriter(UART, TransmitError, genericWriterFn);
    pub const Reader = std.io.GenericReader(UART, ReceiveError, genericReaderFn);

    pub fn writer(self: UART) Writer {
        return .{ .context = self };
    }

    pub fn reader(self: UART) Reader {
        return .{ .context = self };
    }

    fn simpleDeadline(count :u32) ?DeadlineFn {
        return struct {
            var counter = count;
            pub fn deadline() bool {
                counter -= 1;
                return counter == 0;
            }
        }.deadline;
    }

    fn genericWriterFn(self: UART, buffer: []const u8) TransmitError!usize {
        return self.writeBlocking(buffer, simpleDeadline(10000));
    }

    fn genericReaderFn(self: UART, buffer: []u8) ReceiveError!usize {
        return self.readBlocking(buffer, simpleDeadline(10000));
    }

    fn ptr(self: UART, offset: u32) *volatile u32 {
        return @ptrFromInt(@intFromEnum(self) + offset);
    }

    pub fn setup(comptime self: UART, cfg: Config) void {
        self.setupPins();
        self.setupBrr(cfg);
        self.setupCtrl(cfg);
    }

    fn setupPins(comptime self: UART) void {
        if (self != USART1) {
            @compileLog(@intFromEnum(self));
            @compileLog(USART1);
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

    fn setupBrr(self: UART, cfg: Config) void {
        const USART_BRR: *volatile u32 = self.ptr(BRR_offset);

        const brr = (cfg.cpu_frequency + cfg.baud_rate / 2) / cfg.baud_rate;
        USART_BRR.* = brr;
    }

    fn setupCtrl(self: UART, cfg: Config) void {
        const parityBit = switch (cfg.parity) {
            .none => @as(u1, 0),
            .even, .odd => @as(u1, 1),
        };
        const paritySelectionBit = switch (cfg.parity) {
            .even => @as(u1, 1),
            .odd, .none => @as(u1, 0),
        };
        const wordLongBit = switch (cfg.word_bits) {
            .eight => @as(u1, 0),
            .nine => @as(u1, 1),
        };
        const stopBits = switch (cfg.stop_bits) {
            .one => @as(u2, 0b00),
            .half => @as(u2, 0b01),
            .two => @as(u2, 0b10),
            .one_and_a_half => @as(u2, 0b11),
        };
        var rts_bit: u1 = 0;
        var cts_bit: u1 = 0;
        switch (cfg.flow_control) {
            .none => {},
            .CTS => cts_bit = 1,
            .RTS => rts_bit = 1,
            .CTS_RTS => {
                cts_bit = 1;
                rts_bit = 1;
            },
        }

        const USART_CTLR1: *volatile u32 = self.ptr(CTLR1_offset);
        const USART_CTLR2: *volatile u32 = self.ptr(CTLR2_offset);
        const USART_CTLR3: *volatile u32 = self.ptr(CTLR3_offset);

        // Reset.
        USART_CTLR1.* = 0;
        // RE: Receiver enable.
        USART_CTLR1.* |= @as(u32, 1) << 2;
        // TE: Transmitter enable.
        USART_CTLR1.* |= @as(u32, 1) << 3;
        // PEIE: Parity check interrupt enable bit.
        USART_CTLR1.* |= @as(u32, parityBit) << 8;
        // PS: Parity selection bit.
        USART_CTLR1.* |= @as(u32, paritySelectionBit) << 9;
        // M: Word long bit.
        USART_CTLR1.* |= @as(u32, wordLongBit) << 12;

        // Reset.
        USART_CTLR2.* = 0;
        // STOP: Stop bits.
        USART_CTLR2.* |= @as(u32, stopBits) << 12;

        // Reset.
        USART_CTLR3.* = 0;
        // RTSE: RTS enable.
        USART_CTLR3.* |= @as(u32, rts_bit) << 8;
        // CTSE: CTS enable.
        USART_CTLR3.* |= @as(u32, cts_bit) << 9;

        // Enable the interrupt for RX
        // const PFIC_IENR2: *volatile u32 = @ptrFromInt(0xE000E104);
        // // RXNEIE: RXNE interrupt enable.
        // USART_CTLR1.* |= @as(u32, 1) << 5;
        // // 32 - interrupt enable control.
        // PFIC_IENR2.* = 1;

        // UE: UART enable bit.
        USART_CTLR1.* |= @as(u32, 1) << 13;
    }

    pub inline fn isReadable(self: UART) bool {
        const USART_STATR: *volatile u32 = self.ptr(STATR_offset);
        const RXNE = @as(u32, 1) << 5;
        return (USART_STATR.* & RXNE) != 0;
    }

    pub inline fn isWriteable(self: UART) bool {
        const USART_STATR: *volatile u32 = self.ptr(STATR_offset);
        const TXE = @as(u32, 1) << 7;
        return (USART_STATR.* & TXE) != 0;
    }

    pub inline fn isWriteComplete(self: UART) bool {
        const USART_STATR: *volatile u32 = self.ptr(STATR_offset);
        const TC = @as(u32, 1) << 6;
        return (USART_STATR.* & TC) != 0;
    }

    pub noinline fn writeBlocking(self: UART, payload: []const u8, deadlineFn: ?DeadlineFn) TransmitError!usize {
        const USART_DATAR: *volatile u32 = self.ptr(DATAR_offset);

        var offset: usize = 0;
        while (offset < payload.len) {
            while (!self.isWriteable()) {
                if (deadlineFn) |deadline| {
                    if (deadline()) {
                        if (offset > 0) {
                            return offset;
                        }

                        return error.Timeout;
                    }
                }
                asm volatile ("" ::: "memory");
            }
            USART_DATAR.* = payload[offset];
            offset += 1;

            while (!self.isWriteComplete()) {
                if (deadlineFn) |deadline| {
                    if (deadline()) {
                        if (offset > 0) {
                            return offset;
                        }

                        return error.Timeout;
                    }
                }
                asm volatile ("" ::: "memory");
            }
        }

        return offset;
    }

    pub fn readBlocking(self: UART, buffer: []u8, deadlineFn: ?DeadlineFn) ReceiveError!usize {
        const USART_DATAR: *volatile u32 = self.ptr(DATAR_offset);

        var count: u32 = 0;
        for (buffer) |*byte| {
            while (!self.isReadable()) {
                if (deadlineFn) |deadline| {
                    if (deadline()) {
                        if (count > 0) {
                            return count;
                        }

                        return error.Timeout;
                    }
                }
                asm volatile ("" ::: "memory");
            }

            byte.* = @truncate(USART_DATAR.* & 0xFF);
            count += 1;
        }

        return count;
    }

    pub fn getErrors(uart: UART) ErrorStates {
        const read_val = uart.get_regs().STATR.read();
        return .{
            .overrun_error = read_val.ORE == 1,
            .break_error = read_val.LBD == 1,
            .parity_error = read_val.PE == 1,
            .framing_error = read_val.FE == 1,
            .noise_error = read_val.NE == 1,
        };
    }

    pub fn clearErrors(uart: UART) void {
        const uart_regs = uart.get_regs();
        uart_regs.STATR.modify(.{
            .ORE = 0,
            .LBD = 0,
            .PE = 0,
            .FE = 0,
            .NE = 0,
        });
    }
};
