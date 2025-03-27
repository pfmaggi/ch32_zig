const std = @import("std");
const config = @import("config");
const svd = @import("svd");

pub const InputConfig = union(enum) {
    analog: void,
    floating: void,
    pull: InputPull,
};

pub const InputPull = enum {
    up,
    down,
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

port: svd.peripherals.GPIO,
num: u4, // 0-15

const Pin = @This();

pub fn init(port: svd.peripherals.GPIO, num: u4) Pin {
    return .{ .port = port, .num = num };
}

pub fn asInput(self: Pin, cfg: InputConfig) void {
    const data: u4 = switch (cfg) {
        .analog => 0b00_00,
        .floating => 0b01_00,
        .pull => 0b10_00,
    };
    self.writeCfgr(data);

    if (cfg == .pull) {
        self.write(cfg.pull == .up);
    }
}

pub fn asOutput(self: Pin, cfg: OutputConfig) void {
    // const speed_bits = @as(u2, @intFromEnum(cfg.speed));
    // const mode_bits = @as(u4, @intFromEnum(cfg.mode));
    // const data = (mode_bits << 2) | speed_bits;
    // equivalent to:
    const data: u4 = @bitCast(cfg);
    self.writeCfgr(data);
}

pub fn toggle(self: Pin) void {
    self.port.get().OUTDR.raw ^= mask(self);
}

pub fn write(self: Pin, value: bool) void {
    // BSHR - Port set(low 16 bits) and reset(high 16 bits) register.
    if (value) {
        // Set.
        self.port.get().BSHR.raw = mask(self);
    } else {
        // Reset.
        self.port.get().BSHR.raw = @as(u32, mask(self)) << 16;
    }
}

pub fn read(self: Pin) bool {
    return (self.port.get().INDR.raw & mask(self)) != 0;
}

inline fn mask(pin: Pin) u16 {
    return @as(u16, 1) << pin.num;
}

inline fn writeCfgr(self: Pin, data: u4) void {
    switch (self.num) {
        0...7 => {
            const bit_offset = @as(u5, self.num) * 4; // or use `<< 2`?
            self.port.get().CFGLR.setBits(bit_offset, 4, data);
        },
        8...15 => {
            if (config.chip.series == .ch32v003) {
                return;
            }

            const bit_offset = @as(u5, self.num - 8) * 4;
            self.port.get().CFGHR.setBits(bit_offset, 4, data);
        },
    }
}
