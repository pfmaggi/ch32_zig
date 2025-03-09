const std = @import("std");
const config = @import("config");
const svd = @import("svd");

pub const InputConfig = enum(u4) {
    analog = 0b00_00,
    floating = 0b01_00,
    pull_up_down = 0b10_00,
};

pub const OutputConfig = packed struct(u4) {
    speed: OutputSpeed,
    mode: OutputMode,
};

pub const OutputSpeed = enum(u2) {
    max_10mhz = 0b01,
    max_2mhz = 0b10,
    max_50mhz = 0b11,
};

pub const OutputMode = enum(u2) {
    push_pull = 0b00,
    open_drain = 0b01,
    alt_push_pull = 0b10,
    alt_open_drain = 0b11,
};

port: *volatile svd.types.GPIO,
num: u4, // 0-15

const Pin = @This();

pub fn init(port: svd.peripherals.GPIO, num: u4) Pin {
    return .{ .port = port.get(), .num = num };
}

pub fn as_input(self: Pin, cfg: InputConfig) void {
    const data: u4 = @intFromEnum(cfg);
    self.write_cfgr(data);
}

pub fn as_output(self: Pin, cfg: OutputConfig) void {
    // const speed_bits = @as(u2, @intFromEnum(cfg.speed));
    // const mode_bits = @as(u4, @intFromEnum(cfg.mode));
    // const data = (mode_bits << 2) | speed_bits;
    // equivalent to:
    const data: u4 = @bitCast(cfg);
    self.write_cfgr(data);
}

pub fn toggle(self: Pin) void {
    self.port.OUTDR.raw ^= mask(self);
}

pub fn write(self: Pin, value: bool) void {
    // BSHR - Port set(low 16 bits) and reset(high 16 bits) register.
    if (value) {
        // Set.
        self.port.BSHR.raw = mask(self);
    } else {
        // Reset.
        self.port.BSHR.raw = @as(u32, mask(self)) << 16;
    }
}

pub fn read(self: Pin) bool {
    return (self.port.INDR.raw & mask(self)) != 0;
}

inline fn mask(pin: Pin) u16 {
    return @as(u16, 1) << pin.num;
}

inline fn write_cfgr(self: Pin, data: u4) void {
    const bit_offset = self.num * 4; // or use `<< 2`?
    // Clear the bits first, then set the new value.
    self.port.CFGLR.raw &= ~(@as(u32, 0b1111) << bit_offset);
    self.port.CFGLR.raw |= @as(u32, data) << bit_offset;
}
