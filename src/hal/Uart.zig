const std = @import("std");
const config = @import("config");
const svd = @import("svd");

const port = @import("port.zig");
const deadline = @import("deadline.zig");

pub const DeadlineFn = fn () bool;

pub const Config = struct {
    mode: Mode = .tx_rx,
    baud_rate: ?BaudRate = null,
    word_bits: WordBits = .eight,
    stop_bits: StopBits = .one,
    parity: Parity = .none,
    flow_control: FlowControl = .none,
    pins: ?Pins = null,
};

pub const Mode = enum {
    tx,
    rx,
    tx_rx,
};

pub const BaudRate = struct {
    peripheral_clock: u32,
    baud_rate: u32,

    fn calculate(self: BaudRate) u32 {
        if (!self.isValid()) {
            return 0;
        }

        return (self.peripheral_clock + self.baud_rate / 2) / self.baud_rate;
    }

    pub fn isValid(self: BaudRate) bool {
        return self.peripheral_clock > 0 and self.baud_rate > 0;
    }
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

const chip = switch (config.chip.series) {
    .ch32v003 => @import("uart/ch32v003.zig"),
    .ch32v20x, .ch32v30x => @import("uart/ch32v20x_30x.zig"),
    // TODO: implement other chips
    else => @compileError("Unsupported chip series"),
};

pub const Pins = chip.Pins;

const rcc = chip.rcc;

pub const Timeout = error{
    Timeout,
};

pub const Error = error{
    /// Parity error (PE)
    Parity,
    /// Framing error (FE)
    Framing,
    /// Noise error (NE)
    Noise,
    /// Overrun error (ORE)
    Overrun,
};

const UART = @This();

reg: *volatile svd.types.USART,

pub fn init(comptime uart: svd.peripherals.USART, comptime cfg: Config) UART {
    const self = UART{ .reg = uart.get() };

    self.reset();
    self.enable();
    self.configurePins(cfg);
    if (cfg.baud_rate) |baud_rate| {
        comptime if (!baud_rate.isValid()) {
            @compileError("Invalid baud rate configuration");
        };
        self.configureBaudRate(baud_rate);
    }
    self.configureCtrl(cfg);

    return self;
}

/// Deinitializes the UART peripheral.
/// Disables and resets registers.
/// Note: GPIO pins will not be deinitialized when this function is called.
pub fn deinit(self: UART) void {
    self.disable();
    self.reset();
}

fn configurePins(comptime self: UART, comptime cfg: Config) void {
    if (cfg.pins) |pins| {
        comptime checkPins(self.reg, pins);
    }

    const pins = cfg.pins orelse Pins.defaultFor(self.reg);

    if (pins.remap.has()) {
        // Alternate function I/O clock enable
        svd.peripherals.RCC.APB2PCENR.modify(.{ .AFIOEN = 1 });
        // Remap the pins.
        svd.peripherals.AFIO.PCFR1.modify(pins.remap.afio_pcfr1);
        if (config.chip.series != .ch32v003) {
            svd.peripherals.AFIO.PCFR2.modify(pins.remap.afio_pcfr2);
        }
    }

    if (cfg.mode == .tx or cfg.mode == .tx_rx) {
        port.enable(pins.tx.port);
        pins.tx.asOutput(.{ .speed = .max_10mhz, .mode = .alt_push_pull });
    }

    if (cfg.mode == .rx or cfg.mode == .tx_rx) {
        port.enable(pins.rx.port);
        pins.rx.asInput(.floating);
    }
}

/// Runtime baud rate configuration.
pub fn configureBaudRate(self: UART, cfg: BaudRate) void {
    self.reg.BRR.raw = cfg.calculate();
}

fn configureCtrl(self: UART, comptime cfg: Config) void {
    var rx_enable: u1 = 0;
    var tx_enable: u1 = 0;
    switch (cfg.mode) {
        .tx => tx_enable = 1,
        .rx => rx_enable = 1,
        .tx_rx => {
            tx_enable = 1;
            rx_enable = 1;
        },
    }
    const parity_bit: u1 = switch (cfg.parity) {
        .none => 0,
        .even, .odd => 1,
    };
    const parity_selection_bit: u1 = switch (cfg.parity) {
        .even => 1,
        .odd, .none => 0,
    };
    const word_long_bit: u1 = switch (cfg.word_bits) {
        .eight => 0,
        .nine => 1,
    };
    const stop_bits: u2 = switch (cfg.stop_bits) {
        .one => 0b00,
        .half => 0b01,
        .two => 0b10,
        .one_and_a_half => 0b11,
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

    self.reg.CTLR1.write(.{
        // Receiver enable
        .RE = rx_enable,
        // Transmitter enable
        .TE = tx_enable,
        // Parity check interrupt enable bit
        .PEIE = parity_bit,
        // Parity selection bit
        .PS = parity_selection_bit,
        // Word long bit
        .M = word_long_bit,
    });

    self.reg.CTLR2.write(.{
        // Stop bits.
        .STOP = stop_bits,
    });

    self.reg.CTLR3.write(.{
        // RTS enable.
        .RTSE = rts_bit,
        // CTS enable.
        .CTSE = cts_bit,
    });

    // // Enable the interrupt for RX
    // self.reg.CTLR1.modify(.{
    //     // RXNE interrupt enable.
    //     .RXNEIE = 1,
    // });
    // // bit 32 - interrupt enable control.
    // svd.peripherals.PFIC.IENR2.raw = 1;

    // UART enable bit.
    self.reg.CTLR1.modify(.{
        .UE = 1,
    });
}

pub fn enable(self: UART) void {
    rcc.enable(self.reg);
}

pub fn disable(self: UART) void {
    rcc.disable(self.reg);
}

fn reset(self: UART) void {
    rcc.reset(self.reg);
}

pub fn isReadable(self: UART) bool {
    return self.reg.STATR.read().RXNE == 1;
}

pub fn isWriteable(self: UART) bool {
    return self.reg.STATR.read().TXE == 1;
}

pub fn isWriteComplete(self: UART) bool {
    return self.reg.STATR.read().TC == 1;
}

pub fn writeBlocking(self: UART, payload: []const u8, deadlineFn: ?DeadlineFn) Timeout!usize {
    return self.writeVecBlocking(&.{payload}, deadlineFn);
}

pub fn writeVecBlocking(self: UART, payloads: []const []const u8, deadlineFn: ?DeadlineFn) Timeout!usize {
    var total: usize = 0;

    for (payloads) |payload| {
        for (payload) |b| {
            self.wait(isWriteable, deadlineFn) catch |err| {
                if (total > 0) {
                    return total;
                }
                return err;
            };

            self.reg.DATAR.raw = b;
            total += 1;

            self.wait(isWriteComplete, deadlineFn) catch {
                return total;
            };
        }
    }

    return total;
}

pub fn writeByteBlocking(self: UART, byte: u8, deadlineFn: ?DeadlineFn) Timeout!void {
    try self.wait(isWriteable, deadlineFn);
    self.reg.DATAR.raw = byte;
    try self.wait(isWriteComplete, deadlineFn);
}

pub fn readBlocking(self: UART, buffer: []u8, deadlineFn: ?DeadlineFn) Timeout!usize {
    return self.readVecBlocking(&.{buffer}, deadlineFn);
}

pub fn readVecBlocking(self: UART, buffers: []const []u8, deadlineFn: ?DeadlineFn) Timeout!usize {
    var total: usize = 0;

    for (buffers) |buffer| {
        for (buffer) |*byte| {
            byte.* = self.readByteBlocking(deadlineFn) catch |err| {
                if (total > 0) {
                    return total;
                }
                return err;
            };

            total += 1;
        }
    }

    return total;
}

pub fn readByteBlocking(self: UART, deadlineFn: ?DeadlineFn) Timeout!u8 {
    try self.wait(isReadable, deadlineFn);
    return @truncate(self.reg.DATAR.raw & 0xFF);
}

fn checkErrors(self: UART) Error!void {
    const statr = self.reg.STATR.read();

    if (statr.PE == 1) {
        self.reg.STATR.modify(.{ .PE = 0 });
        return error.Parity;
    }
    if (statr.FE == 1) {
        self.reg.STATR.modify(.{ .FE = 0 });
        return error.Framing;
    }
    if (statr.NE == 1) {
        self.reg.STATR.modify(.{ .NE = 0 });
        return error.Noise;
    }
    if (statr.ORE == 1) {
        self.reg.STATR.modify(.{ .ORE = 0 });
        return error.Overrun;
    }
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

// Comptime pins checks.
pub fn checkPins(comptime reg: *volatile svd.types.I2C, comptime pins: Pins) void {
    const pins_namespace = Pins.namespaceFor(reg);

    // Find pins from namespace.
    var periph_pins_maybe: ?Pins = null;
    for (@typeInfo(pins_namespace).@"struct".decls) |decl| {
        const p_pins: Pins = @field(pins_namespace, decl.name);
        if (p_pins.eqWithoutNss(pins)) {
            periph_pins_maybe = p_pins;
            break;
        }
    }
    _ = periph_pins_maybe orelse @compileError(
        \\Pins not found in namespace for selected UART.
        \\This may be due to an incorrect pin configuration.
        \\For example, if you are using USART1, the pins should be from Pins.usart1 namespace.
    );
}

pub const Writer = std.io.GenericWriter(UART, Timeout, genericWriterFn);

pub fn writer(self: UART) Writer {
    return .{ .context = self };
}

fn genericWriterFn(self: UART, buffer: []const u8) Timeout!usize {
    return self.writeBlocking(buffer, deadline.simple(100_000));
}
