const config = @import("config");
const svd = @import("svd");

pub const DeadlineFn = fn () bool;

// TODO: extract
pub fn simpleDeadline(count: u32) ?DeadlineFn {
    return struct {
        var counter = count;
        pub fn check() bool {
            counter -= 1;
            return counter == 0;
        }
    }.check;
}

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

pub const Timeout = error{
    Timeout,
};

pub const ErrorStates = packed struct(u4) {
    overrun_error: bool = false,
    break_error: bool = false,
    parity_error: bool = false,
    framing_error: bool = false,
    noise_error: bool = false,
};

pub const UART = struct {
    uart: *volatile svd.types.USARTx,

    pub fn from(uart: svd.peripherals.USARTx) UART {
        return .{ .uart = uart.get() };
    }

    pub fn setup(self: UART, cfg: Config) void {
        self.setupPins();
        self.setupBrr(cfg);
        self.setupCtrl(cfg);
    }

    fn setupPins(self: UART) void {
        _ = self;

        const RCC = svd.peripherals.RCC;
        RCC.APB2PCENR.modify(.{
            // Enable Port D clock.
            .IOPDEN = 1,
            // Enable USART1 clock.
            .USART1EN = 1,
        });

        // GPIOD
        // TX - GPIO D5
        svd.peripherals.GPIOD.CFGLR.modify(.{
            // Mode 01: Output max 10MHz
            .MODE5 = 0b01,
            // CNF 10: Multiplexed Push-Pull
            .CNF5 = 0b10,
        });

        // RX - GPIO D6
        svd.peripherals.GPIOD.CFGLR.modify(.{
            // Mode 00: Input
            .MODE6 = 0b00,
            // CNF 01: Floating
            .CNF6 = 0b01,
        });
    }

    fn setupBrr(self: UART, cfg: Config) void {
        const brr = (cfg.cpu_frequency + cfg.baud_rate / 2) / cfg.baud_rate;
        self.uart.BRR.raw = brr;
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

        self.uart.CTLR1.write(.{
            // Receiver enable
            .RE = 1,
            // Transmitter enable
            .TE = 1,
            // Parity check interrupt enable bit
            .PEIE = parityBit,
            // Parity selection bit
            .PS = paritySelectionBit,
            // Word long bit
            .M = wordLongBit,
        });

        self.uart.CTLR2.write(.{
            // Stop bits.
            .STOP = stopBits,
        });

        self.uart.CTLR3.write(.{
            // RTS enable.
            .RTSE = rts_bit,
            // CTS enable.
            .CTSE = cts_bit,
        });

        // // Enable the interrupt for RX
        // self.uart.CTLR1.modify(.{
        //     // RXNE interrupt enable.
        //     .RXNEIE = 1,
        // });
        // // bit 32 - interrupt enable control.
        // svd.peripherals.PFIC.IENR2.raw = 1;

        // UART enable bit.
        self.uart.CTLR1.modify(.{
            .UE = 1,
        });
    }

    pub fn isReadable(self: UART) bool {
        return self.uart.STATR.read().RXNE == 1;
    }

    pub fn isWriteable(self: UART) bool {
        return self.uart.STATR.read().TXE == 1;
    }

    pub fn isWriteComplete(self: UART) bool {
        return self.uart.STATR.read().TC == 1;
    }

    pub noinline fn writeBlocking(self: UART, payload: []const u8, deadlineFn: ?DeadlineFn) Timeout!usize {
        var offset: usize = 0;
        while (offset < payload.len) {
            self.wait(isWriteable, deadlineFn) catch |err| {
                if (offset > 0) {
                    return offset;
                }
                return err;
            };

            self.uart.DATAR.raw = payload[offset];
            offset += 1;

            self.wait(isWriteComplete, deadlineFn) catch {
                return offset;
            };
        }

        return offset;
    }

    pub fn readBlocking(self: UART, buffer: []u8, deadlineFn: ?DeadlineFn) Timeout!usize {
        var count: u32 = 0;
        for (buffer) |*byte| {
            self.wait(isReadable, deadlineFn) catch |err| {
                if (count > 0) {
                    return count;
                }
                return err;
            };

            byte.* = @truncate(self.uart.DATAR.raw & 0xFF);
            count += 1;
        }

        return count;
    }

    pub fn getErrors(self: UART) ErrorStates {
        const statr = self.uart.STATR.read();
        return .{
            .overrun_error = statr.ORE,
            .break_error = statr.LBD,
            .parity_error = statr.PE,
            .framing_error = statr.FE,
            .noise_error = statr.NE,
        };
    }

    pub fn clearErrors(self: UART) void {
        self.uart.STATR.modify(.{
            .ORE = 0,
            .LBD = 0,
            .PE = 0,
            .FE = 0,
            .NE = 0,
        });
    }

    // Wait for a condition to be true.
    fn wait(self: UART, conditionFn: fn (self: UART) bool, deadlineFn: ?DeadlineFn) Timeout!void {
        while (!conditionFn(self)) {
            if (deadlineFn) |check| {
                if (check()) {
                    return error.Timeout;
                }
            }
            asm volatile ("" ::: "memory");
        }
    }
};
