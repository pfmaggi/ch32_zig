const std = @import("std");
const config = @import("config");
const svd = @import("svd");

const port = @import("port.zig");
const Pin = @import("Pin.zig");

pub const DeadlineFn = fn () bool;

pub const Config = struct {
    /// SPI mode. Master or slave.
    mode: Mode = .master,
    /// Unidirectional or bidirectional data mode.
    direction: Direction = .two_lines_full_duplex,
    /// Clock polarity.
    cpol: CPOL = .low,
    /// Clock active edge for the bit capture.
    cpha: CPHA = .first_edge,
    /// Baud Rate prescaler value which will be
    /// used to configure the transmit and receive SCK clock.
    baud_rate: BaudRate = .default,
    /// Whether data transfers start from MSB bit.
    /// NOTE: LSB is only supported by SPI as host.
    first_bit: FirstBit = .msb,
    /// SPI pins. If not provided, default pins will be used.
    pins: ?Pins = null,

    fn isHardwareNss(self: Config) bool {
        if (self.pins) |pins| {
            if (pins.nss) |nss| {
                return nss.is_hardware;
            }
        }

        return false;
    }
};

pub const Mode = enum(u1) {
    slave = 0,
    master = 1,
};

pub const DataSize = enum(u1) {
    eight_bits = 0, // 8
    sixteen_bits = 1, // 16
};

pub const Direction = enum {
    two_lines_full_duplex,
    two_lines_rx_only,
    one_line_rx,
    one_line_tx,
};

pub const CPOL = enum(u1) {
    low = 0,
    high = 1,
};

pub const CPHA = enum(u1) {
    first_edge = 0,
    second_edge = 1,
};

pub const BaudRate = struct {
    peripheral_clock: u32,
    baud_rate: u32,

    pub const default = BaudRate{ .peripheral_clock = 0, .baud_rate = 0 };

    fn calculate(self: BaudRate) BaudRatePrescaler {
        if (self.peripheral_clock == 0 or self.baud_rate == 0) {
            return .div64;
        }

        const div = self.peripheral_clock / self.baud_rate;
        if (div <= 2) return .div2;
        if (div <= 4) return .div4;
        if (div <= 8) return .div8;
        if (div <= 16) return .div16;
        if (div <= 32) return .div32;
        if (div <= 64) return .div64;
        if (div <= 128) return .div128;
        if (div <= 256) return .div256;

        return .div256;
    }
};

pub const BaudRatePrescaler = enum(u3) {
    div2 = 0b000,
    div4 = 0b001,
    div8 = 0b010,
    div16 = 0b011,
    div32 = 0b100,
    div64 = 0b101,
    div128 = 0b110,
    div256 = 0b111,
};

pub const BiDirectionalMode = enum(u1) {
    rx = 0,
    tx = 1,
};

pub const FirstBit = enum(u1) {
    msb = 0,
    /// LSB is only supported by SPI as host.
    lsb = 1,
};

pub const Pins = switch (config.chip_series) {
    .ch32v003 => @import("spi/ch32v003.zig").Pins,
    // TODO: implement other chips
    else => @compileError("Unsupported chip series"),
};

const RccBits = switch (config.chip_series) {
    .ch32v003 => @import("spi/ch32v003.zig").RccBits,
    // TODO: implement other chips
    else => @compileError("Unsupported chip series"),
};

pub const Timeout = error{
    Timeout,
};

pub const ConfigureError = error{
    ModeFault,
};

const SPI = @This();

spi: *volatile svd.types.SPI,
sw_nss: ?Pin,

pub fn init(uart: svd.peripherals.SPI, comptime cfg: Config) ConfigureError!SPI {
    const sw_nss: ?Pin = if (cfg.mode == .master and !cfg.isHardwareNss()) blk: {
        if (cfg.pins) |pins| if (pins.nss) |nss| if (!nss.is_hardware) break :blk nss.pin;
        break :blk null;
    } else null;

    const self = SPI{ .spi = uart.get(), .sw_nss = sw_nss };

    self.reset();
    self.enable();
    self.configurePins(cfg);
    self.configureCtrl(cfg);
    self.configureBaudRate(cfg.baud_rate);
    try self.configureCheck();

    return self;
}

/// Deinitializes the SPI peripheral.
/// Disables and resets registers.
/// Note: GPIO pins will not be deinitialized when this function is called.
pub fn deinit(self: SPI) void {
    self.disable();
    self.reset();
}

fn configurePins(self: SPI, comptime cfg: Config) void {
    const pins = cfg.pins orelse Pins.get_default(self.spi);

    if (pins.remap.has()) {
        // Alternate function I/O clock enable
        svd.peripherals.RCC.APB2PCENR.modify(.{ .AFIOEN = 1 });
        // Remap the pins.
        svd.peripherals.AFIO.PCFR1.modify(pins.remap.afio_pcfr1);
    }

    // TODO: add support bi-dir mode
    switch (cfg.mode) {
        .master => {
            if (pins.nss) |nss| {
                port.enable(nss.pin.port);
                nss.pin.asOutput(.{ .speed = .max_50mhz, .mode = if (nss.is_hardware) .alt_push_pull else .push_pull });
            }

            port.enable(pins.sck.port);
            pins.sck.asOutput(.{ .speed = .max_50mhz, .mode = .alt_push_pull });

            port.enable(pins.miso.port);
            pins.miso.asInput(.floating);

            port.enable(pins.mosi.port);
            pins.mosi.asOutput(.{ .speed = .max_50mhz, .mode = .alt_push_pull });
        },
        .slave => {
            if (pins.nss) |nss| {
                port.enable(nss.pin.port);
                nss.pin.asInput(.{ .pull = .down });
            }
            port.enable(pins.sck.port);
            pins.sck.asInput(.floating);

            port.enable(pins.miso.port);
            pins.miso.asOutput(.{ .speed = .max_50mhz, .mode = .alt_push_pull });

            port.enable(pins.mosi.port);
            pins.mosi.asInput(.floating);
        },
    }
}

fn configureCtrl(self: SPI, comptime cfg: Config) void {
    self.spi.CTLR1.write(.{
        // Clock phase.
        .CPHA = @intFromEnum(cfg.cpha),
        // Clock polarity.
        .CPOL = @intFromEnum(cfg.cpol),
        // Master selection.
        .MSTR = @intFromEnum(cfg.mode),
        // BR: Baud rate control.
        .BR = 0,
        // SPI enable.
        .SPE = 0,
        // Frame format.
        .LSBFIRST = if (cfg.mode == .master) @intFromEnum(cfg.first_bit) else 0,
        // Internal slave select. Required for master mode.
        .SSI = boolToU1(cfg.mode == .master),
        // SSM: Software slave management.
        .SSM = boolToU1(!cfg.isHardwareNss()),
        // Receive only.
        .RXONLY = boolToU1(cfg.direction == .two_lines_rx_only),
        // Data frame format.
        .DFF = 0,
        // CRC transfer next.
        .CRCNEXT = 0,
        // CRC enable.
        .CRCEN = 0,
        // Output enable in bidirectional mode.
        .BIDIOE = boolToU1(cfg.direction == .one_line_tx),
        // Bidirectional data mode enable
        .BIDIMODE = boolToU1(cfg.direction == .one_line_rx or cfg.direction == .one_line_tx),
    });
    self.spi.CTLR2.write(.{
        .SSOE = boolToU1(cfg.mode == .master and cfg.isHardwareNss()),
    });

    // SPI enable.
    self.spi.CTLR1.modify(.{ .SPE = 1 });
}

/// Runtime baud rate configuration.
pub fn configureBaudRate(self: SPI, baud_rate: BaudRate) void {
    self.spi.CTLR1.modify(.{ .BR = @intFromEnum(baud_rate.calculate()) });
}

fn configureCheck(self: SPI) ConfigureError!void {
    if (self.spi.STATR.read().MODF == 1) {
        return ConfigureError.ModeFault;
    }
}

/// Selects the data transfer direction in bi-directional mode.
pub fn setBiDirectionalMode(self: SPI, dir: BiDirectionalMode) void {
    self.spi.CTLR1.modify(.{ .BIDIOE = @intFromEnum(dir) });
}

pub fn enable(self: SPI) void {
    const RCC = svd.peripherals.RCC;
    const bits = RccBits.get(self.spi);
    if (bits.apb2) |pos| {
        RCC.APB2PCENR.setBit(pos, 1);
    }
    if (bits.apb1) |pos| {
        RCC.APB1PCENR.setBit(pos, 1);
    }
}

pub fn disable(self: SPI) void {
    const RCC = svd.peripherals.RCC;
    const bits = RccBits.get(self.spi);
    if (bits.apb2) |pos| {
        RCC.APB2PCENR.setBit(pos, 0);
    }
    if (bits.apb1) |pos| {
        RCC.APB1PCENR.setBit(pos, 0);
    }
}

fn reset(self: SPI) void {
    const RCC = svd.peripherals.RCC;
    const bits = RccBits.get(self.spi);
    if (bits.apb2) |pos| {
        RCC.APB2PRSTR.setBit(pos, 1);
        RCC.APB2PRSTR.setBit(pos, 0);
    }
    if (bits.apb1) |pos| {
        RCC.APB2PRSTR.setBit(pos, 1);
        RCC.APB2PRSTR.setBit(pos, 0);
    }
}

/// Blocking bidirectional data transfer.
///
/// Transfers data of size `max(send.len, recv.len)` bytes.
/// If send.len > recv.len, the remaining bytes during reading will be ignored.
/// If recv.len > send.len, zeros will be sent for the remaining bytes.
///
/// This function blocks execution until all data is transferred or a timeout occurs.
/// The deadlineFn parameter allows specifying a timeout check function to avoid infinite waiting.
pub noinline fn transferBlocking(self: SPI, comptime u8_or_u16: type, send: ?[]const u8_or_u16, recv: ?[]u8_or_u16, deadlineFn: ?DeadlineFn) Timeout!usize {
    const type_info = @typeInfo(u8_or_u16).int;
    if (type_info.bits != 8 and type_info.bits != 16 or @typeInfo(u8_or_u16).int.signedness != .unsigned) {
        @compileError("Unsupported type, only u8 and u16 are supported");
    }

    self.setDataSize(if (type_info.bits == 8) .eight_bits else .sixteen_bits);

    self.swNssWrite(false);
    defer self.swNssWrite(true);

    const send_len = if (send) |s| s.len else 0;
    const recv_len = if (recv) |r| r.len else 0;
    const len = @max(send_len, recv_len);

    for (0..len) |offset| {
        const word: u16 = if (send) |s| blk: {
            break :blk if (s.len > offset) s[offset] else 0;
        } else 0;

        const v = self.transferWordBlocking(word, deadlineFn) catch |err| {
            if (offset > 0) {
                return offset;
            }
            return err;
        };

        if (recv) |r| {
            if (r.len > offset) {
                r[offset] = @truncate(v);
            }
        }
    }

    return len;
}

inline fn swNssWrite(self: SPI, v: bool) void {
    if (self.sw_nss) |nss| {
        nss.write(v);
    }
}

fn isReadable(self: SPI) bool {
    return self.spi.STATR.read().RXNE == 1;
}

fn isWriteable(self: SPI) bool {
    return self.spi.STATR.read().TXE == 1;
}

fn setDataSize(self: SPI, size: DataSize) void {
    self.spi.CTLR1.modify(.{ .DFF = @intFromEnum(size) });
}

fn transferWordBlocking(self: SPI, word: u16, deadlineFn: ?DeadlineFn) Timeout!u16 {
    try self.wait(isWriteable, deadlineFn);

    self.spi.DATAR.write(.{ .DATAR = word });

    try self.wait(isReadable, deadlineFn);

    return self.spi.DATAR.read().DATAR;
}

// Wait for a condition to be true.
fn wait(self: SPI, conditionFn: fn (self: SPI) bool, deadlineFn: ?DeadlineFn) Timeout!void {
    while (!conditionFn(self)) {
        if (deadlineFn) |check| {
            if (check()) {
                return error.Timeout;
            }
        }
        asm volatile ("" ::: "memory");
    }
}

inline fn boolToU1(b: bool) u1 {
    return if (b) 1 else 0;
}
