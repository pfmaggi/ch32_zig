const config = @import("config");

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

pub const Port = switch (config.chip_series) {
    .CH32V003 => enum(u3) {
        A = 0,
        C = 2,
        D = 3,

        // FIXME: need to eliminate duplicates in different configurations.
        pub const enable = port_enable;
        pub const disable = port_disable;
    },
    .CH32V30x => enum(u5) {
        A,
        B,
        C,
        D,
        E,

        pub const enable = port_enable;
        pub const disable = port_disable;
    },
};

pub const Pin = packed struct {
    port: Port,
    num: u4, // 0-15

    pub fn init(port: Port, num: u4) Pin {
        return .{ .port = port, .num = num };
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

    pub fn toggle(pin: Pin) void {
        const gpio_base = port_reg(pin.port);
        // ODR: Port output data register.
        const GPIOx_OUTDR: *volatile u32 = @ptrFromInt(gpio_base + GPIOx_OUTDR_offset);
        GPIOx_OUTDR.* ^= mask(pin);
    }

    pub fn write(pin: Pin, value: bool) void {
        const gpio_base = port_reg(pin.port);
        // BSHR - Port set(low 16 bits) and reset(high 16 bits) register.
        const GPIOx_BSHR: *volatile u32 = @ptrFromInt(gpio_base + GPIOx_BSHR_offset);
        if (value) {
            // Set.
            GPIOx_BSHR.* = mask(pin);
        } else {
            // Reset.
            GPIOx_BSHR.* = @as(u32, mask(pin)) << 16;
        }
    }

    pub fn read(pin: Pin) bool {
        const gpio_base = port_reg(pin.port);
        const GPIOx_INDR: *volatile u32 = @ptrFromInt(gpio_base + GPIOx_INDR_offset);
        return (GPIOx_INDR.* & mask(pin)) != 0;
    }

    inline fn mask(pin: Pin) u16 {
        return @as(u16, 1) << pin.num;
    }

    fn write_cfgr(self: Pin, data: u4) void {
        const gpio_base = port_reg(self.port);
        const GPIOx_CFGLR: *volatile u32 = @ptrFromInt(gpio_base + GPIOx_CFGLR_offset);
        const offset_bits = self.num * 4; // or use `<< 2`?
        // Clear the bits first, then set the new value.
        GPIOx_CFGLR.* &= ~(@as(u32, 0b1111) << offset_bits);
        GPIOx_CFGLR.* |= @as(u32, data) << offset_bits;
    }
};

inline fn port_reg(p: Port) u32 {
    return GPIOA_BASE + GPIOx_offset * @intFromEnum(p);
}

fn port_enable(p: Port) void {
    // PA port module clock enable bit for I/O.
    const IOPAEN = 2;
    RCC_APB2PCENR.* |= @as(u32, 1) << (@intFromEnum(p) + IOPAEN);
}

fn port_disable(p: Port) void {
    // PA port module clock enable bit for I/O.
    const IOPAEN = 2;
    RCC_APB2PCENR.* &= ~(@as(u32, 1) << (@intFromEnum(p) + IOPAEN));
}

// TODO: extract RCC staff to a separate module.
const RCC_BASE: u32 = 0x40021000;
const RCC_APB2PCENR: *volatile u32 = @ptrFromInt(RCC_BASE + 0x18);

const GPIOA_BASE: u32 = 0x40010800;
const GPIOx_offset: u32 = 0x400;

const GPIOx_CFGLR_offset: u32 = 0x00;
const GPIOx_INDR_offset: u32 = 0x08;
const GPIOx_OUTDR_offset: u32 = 0x0C;
const GPIOx_BSHR_offset: u32 = 0x10;

const testing = @import("std").testing;

test "port_reg" {
    const actual = port_reg(.C);
    const expected = 0x40011000;
    try testing.expectEqual(expected, actual);
}
