const std = @import("std");
const config = @import("config");
const svd = @import("svd");

const port = @import("port.zig");

pub const DeadlineFn = fn () bool;

pub const Config = struct {
    cpu_frequency: u32,
    baud_rate: u32,
    mode: Mode = .TX_RX,
    word_bits: WordBits = .eight,
    stop_bits: StopBits = .one,
    parity: Parity = .none,
    flow_control: FlowControl = .none,
    pins: ?Pins = null,
};

pub const Mode = enum {
    TX,
    RX,
    TX_RX,
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

pub const Pins = switch (config.chip_series) {
    .ch32v003 => @import("uart/ch32v003.zig").Pins,
    // TODO: implement other chips
    else => @compileError("Unsupported chip series"),
};

const RccBits = switch (config.chip_series) {
    .ch32v003 => @import("uart/ch32v003.zig").RccBits,
    // TODO: implement other chips
    else => @compileError("Unsupported chip series"),
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

const UART = @This();

uart: *volatile svd.types.USART,

pub fn from(uart: svd.peripherals.USART) UART {
    return .{ .uart = uart.get() };
}

pub fn configure(self: UART, comptime cfg: Config) void {
    self.enable();
    self.configurePins(cfg);
    self.configureBrr(cfg);
    self.configureCtrl(cfg);
}

fn configurePins(self: UART, comptime cfg: Config) void {
    const pins = cfg.pins orelse Pins.get_default(self.uart);

    if (pins.remap.has()) {
        // Alternate function I/O clock enable
        svd.peripherals.RCC.APB2PCENR.modify(.{ .AFIOEN = 1 });
        // Remap the pins.
        svd.peripherals.AFIO.PCFR1.modify(pins.remap.afio_pcfr1);
    }

    if (cfg.mode == .TX or cfg.mode == .TX_RX) {
        port.enable(pins.tx.port);
        pins.tx.asOutput(.{ .speed = .max_10mhz, .mode = .alt_push_pull });
    }

    if (cfg.mode == .RX or cfg.mode == .TX_RX) {
        port.enable(pins.rx.port);
        pins.rx.asInput(.floating);
    }
}

fn configureBrr(self: UART, comptime cfg: Config) void {
    const brr = (cfg.cpu_frequency + cfg.baud_rate / 2) / cfg.baud_rate;
    self.uart.BRR.raw = brr;
}

fn configureCtrl(self: UART, comptime cfg: Config) void {
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

pub fn enable(self: UART) void {
    const RCC = svd.peripherals.RCC;
    const bits = RccBits.get(self.uart);
    if (bits.apb2) |pos| {
        RCC.APB2PCENR.setBit(pos, 1);
    }
    if (bits.apb1) |pos| {
        RCC.APB1PCENR.setBit(pos, 1);
    }
}

pub fn disable(self: UART) void {
    const RCC = svd.peripherals.RCC;
    const bits = RccBits.get(self.uart);
    if (bits.apb2) |pos| {
        RCC.APB2PCENR.setBit(pos, 0);
    }
    if (bits.apb1) |pos| {
        RCC.APB1PCENR.setBit(pos, 0);
    }
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
