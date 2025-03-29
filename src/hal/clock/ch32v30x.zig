const std = @import("std");
const config = @import("config");
const svd = @import("svd");

pub const Clocks = struct {
    sys: u32,
    hb: u32,
    pb1: u32,
    pb2: u32,

    // Default clock configuration after systemInit() routine.
    pub const default: Clocks = .{
        .sys = hsi_frequency,
        .hb = hsi_frequency,
        .pb1 = hsi_frequency,
        .pb2 = hsi_frequency,
    };
};

pub const hsi_frequency: u32 = 8_000_000;
pub const default_hse_frequency: u32 = 8_000_000;

const HseSource = struct {
    frequency: u32 = default_hse_frequency,
    bypass: bool = false,
    clock_security_system: bool = false,
};

const Source = union(enum) {
    hsi: void,
    hse: HseSource,
};

const PllMul = enum(u32) {
    mul2 = 2, // Only for non-D8C.
    mul3 = 3,
    mul4 = 4,
    mul5 = 5,
    mul6 = 6,
    mul7 = 7,
    mul8 = 8,
    mul9 = 9,
    mul10 = 10,
    mul11 = 11,
    mul12 = 12,
    mul13 = 13,
    mul14 = 14,
    mul15 = 15,
    mul16 = 16,
    mul18 = 18,

    fn num(self: PllMul) u32 {
        return @intFromEnum(self);
    }

    fn bits(comptime self: PllMul) u4 {
        // PLL multiplication factor (These bits can be written only when PLL is disabled).

        // For CH32F20x_D8C, CH32V30x_D8C, CH32V31x_D8C:
        // 0000: PLL input clock x 18; 0001: PLL input clock x 3;
        // 0010: PLL input clock x 4; 0011: PLL input clock x 5;
        // 0100: PLL input clock x 6; 0101: PLL input clock x 7;
        // 0110: PLL input clock x 8; 0111: PLL input clock x 9;
        // 1000: PLL input clock x 10; 1001: PLL input clock x 11;
        // 1010: PLL input clock x 12; 1011: PLL input clock x 13;
        // 1100: PLL input clock x 14; 1101: PLL input clock x 6.5;
        // 1110: PLL input clock x 15; 1111: PLL input clock x 16.

        if (config.chip.class == .d8c) {
            return switch (self) {
                .mul18 => 0b0000,
                .mul3 => 0b0001,
                .mul4 => 0b0010,
                .mul5 => 0b0011,
                .mul6 => 0b0100,
                .mul7 => 0b0101,
                .mul8 => 0b0110,
                .mul9 => 0b0111,
                .mul10 => 0b1000,
                .mul11 => 0b1001,
                .mul12 => 0b1010,
                .mul13 => 0b1011,
                .mul14 => 0b1100,
                .mul15 => 0b1110,
                .mul16 => 0b1111,
                .mul2 => @compileError("mul2 is not supported for D8C"),
            };
        }

        // For CH32F20x_D6, CH32F20x_D8, CH32F20x_D8W, CH32V20x_D6, CH32V20x_D8, CH32V20x_D8W, CH32V30x_D8:
        // 0000: PLL input clock x 2; 0001: PLL input clock x 3;
        // 0010: PLL input clock x 4; 0011: PLL input clock x 5;
        // 0100: PLL input clock x 6; 0101: PLL input clock x 7;
        // 0110: PLL input clock x 8; 0111: PLL input clock x 9;
        // 1000: PLL input clock x 10; 1001: PLL input clock x 11;
        // 1010: PLL input clock x 12; 1011: PLL input clock x 13;
        // 1100: PLL input clock x 14; 1101: PLL input clock x 15;
        // 1110: PLL input clock x 16; 1111: PLL input clock x 18;

        return switch (self) {
            .mul2 => 0b0000,
            .mul3 => 0b0001,
            .mul4 => 0b0010,
            .mul5 => 0b0011,
            .mul6 => 0b0100,
            .mul7 => 0b0101,
            .mul8 => 0b0110,
            .mul9 => 0b0111,
            .mul10 => 0b1000,
            .mul11 => 0b1001,
            .mul12 => 0b1010,
            .mul13 => 0b1011,
            .mul14 => 0b1100,
            .mul15 => 0b1101,
            .mul16 => 0b1110,
            .mul18 => 0b1111,
        };
    }

    fn fromBits(b: u4) ?PllMul {
        if (config.chip.class == .d8c) {
            return switch (b) {
                0b0000 => .mul18,
                0b0001 => .mul3,
                0b0010 => .mul4,
                0b0011 => .mul5,
                0b0100 => .mul6,
                0b0101 => .mul7,
                0b0110 => .mul8,
                0b0111 => .mul9,
                0b1000 => .mul10,
                0b1001 => .mul11,
                0b1010 => .mul12,
                0b1011 => .mul13,
                0b1100 => .mul14,
                0b1110 => .mul15,
                0b1111 => .mul16,
                else => .mul18,
            };
        }

        return switch (b) {
            0b0000 => .mul2,
            0b0001 => .mul3,
            0b0010 => .mul4,
            0b0011 => .mul5,
            0b0100 => .mul6,
            0b0101 => .mul7,
            0b0110 => .mul8,
            0b0111 => .mul9,
            0b1000 => .mul10,
            0b1001 => .mul11,
            0b1010 => .mul12,
            0b1011 => .mul13,
            0b1100 => .mul14,
            0b1101 => .mul15,
            0b1110 => .mul16,
            0b1111 => .mul18,
            else => null,
        };
    }
};

const Pll = struct {
    mul: PllMul,
};

const SysClk = union(enum) {
    hsi: void,
    hse: void,
    pll: Pll,
};

const HbPrescaler = enum(u32) {
    div1 = 1,
    div2 = 2,
    div4 = 4,
    div8 = 8,
    div16 = 16,
    div64 = 64,
    div128 = 128,
    div256 = 256,
    div512 = 512,

    fn num(self: HbPrescaler) u32 {
        return @intFromEnum(self);
    }

    fn bits(self: HbPrescaler) u4 {
        return switch (self) {
            .div1 => 0b0000,
            .div2 => 0b1000,
            .div4 => 0b1001,
            .div8 => 0b1010,
            .div16 => 0b1011,
            .div64 => 0b1100,
            .div128 => 0b1101,
            .div256 => 0b1110,
            .div512 => 0b1111,
        };
    }

    fn fromBits(b: u4) ?HbPrescaler {
        return switch (b) {
            0b0000 => .div1,
            0b1000 => .div2,
            0b1001 => .div4,
            0b1010 => .div8,
            0b1011 => .div16,
            0b1100 => .div64,
            0b1101 => .div128,
            0b1110 => .div256,
            0b1111 => .div512,
            else => null,
        };
    }
};

const PbPrescaler = enum(u32) {
    div1 = 1,
    div2 = 2,
    div4 = 4,
    div8 = 8,
    div16 = 16,

    fn num(self: PbPrescaler) u32 {
        return @intFromEnum(self);
    }

    fn bits(self: PbPrescaler) u3 {
        return switch (self) {
            .div1 => 0b000,
            .div2 => 0b100,
            .div4 => 0b101,
            .div8 => 0b110,
            .div16 => 0b111,
        };
    }

    fn fromBits(b: u3) ?PbPrescaler {
        return switch (b) {
            0b000 => .div1,
            0b100 => .div2,
            0b101 => .div4,
            0b110 => .div8,
            0b111 => .div16,
            else => null,
        };
    }
};

pub const Config = struct {
    source: Source,
    sys_clk: SysClk,
    hb_pre: HbPrescaler,
    pb1_pre: PbPrescaler,
    pb2_pre: PbPrescaler,

    pub const default = hsi_8mhz;
    pub const hsi_max = hsi_144mhz;
    pub const hse_max = hse_144mhz;

    pub const hsi_8mhz = Config{
        .source = .hsi,
        .sys_clk = .hsi,
        .hb_pre = .div1,
        .pb1_pre = .div1,
        .pb2_pre = .div1,
    };
    pub const hsi_48mhz = Config{
        .source = .hsi,
        .sys_clk = .{ .pll = .{ .mul = .mul6 } },
        .hb_pre = .div1,
        .pb1_pre = .div1,
        .pb2_pre = .div1,
    };
    pub const hsi_96mhz = Config{
        .source = .hsi,
        .sys_clk = .{
            .pll = .{ .mul = .mul12 },
        },
        .hb_pre = .div1,
        .pb1_pre = .div1,
        .pb2_pre = .div1,
    };
    pub const hsi_144mhz = Config{
        .source = .hsi,
        .sys_clk = .{
            .pll = .{ .mul = .mul18 },
        },
        .hb_pre = .div1,
        .pb1_pre = .div1,
        .pb2_pre = .div1,
    };
    pub const hse_8mhz = Config{
        .source = .{ .hse = .{} },
        .sys_clk = .hse,
        .hb_pre = .div1,
        .pb1_pre = .div1,
        .pb2_pre = .div1,
    };
    pub const hse_48mhz = Config{
        .source = .{ .hse = .{} },
        .sys_clk = .{ .pll = .{ .mul = .mul6 } },
        .hb_pre = .div1,
        .pb1_pre = .div1,
        .pb2_pre = .div1,
    };
    pub const hse_96mhz = Config{
        .source = .{ .hse = .{} },
        .sys_clk = .{
            .pll = .{ .mul = .mul12 },
        },
        .hb_pre = .div1,
        .pb1_pre = .div1,
        .pb2_pre = .div1,
    };
    pub const hse_144mhz = Config{
        .source = .{ .hse = .{} },
        .sys_clk = .{
            .pll = .{ .mul = .mul18 },
        },
        .hb_pre = .div1,
        .pb1_pre = .div1,
        .pb2_pre = .div1,
    };
};

pub const Error = error{
    WaitHseTimeout,
    WaitPllTimeout,
    WaitSysClkTimeout,
};

pub fn setOrGet(comptime cfg: Config) Clocks {
    const hse_frequency = switch (cfg.source) {
        .hse => |hse| hse.frequency,
        else => default_hse_frequency,
    };
    return set(cfg) catch get(hse_frequency) orelse .default;
}

pub fn set(comptime cfg: Config) Error!Clocks {
    const EXTEN = svd.peripherals.EXTEND;
    const RCC = svd.peripherals.RCC;
    const AFIO = svd.peripherals.AFIO;

    if (cfg.sys_clk == .hse and cfg.source != .hse) {
        @compileError("Source must be HSE when system clock is HSE");
    }

    // Configure HSE.
    if (cfg.source == .hse) {
        // PD0-PD1 are used for HSE.
        RCC.APB2PCENR.modify(.{ .AFIOEN = 1 });
        AFIO.PCFR1.modify(.{ .PD01_RM = 1 });
        RCC.CTLR.modify(.{
            // Enable HSE.
            .HSEON = 1,
            // HSE bypass.
            .HSEBYP = if (cfg.source.hse.bypass) 1 else 0,
            .CSSON = if (cfg.source.hse.clock_security_system) 1 else 0,
        });

        // Wait for HSE to be ready or timeout.
        var timeout: u32 = 10_000;
        while (timeout > 0) : (timeout -= 1) {
            if (RCC.CTLR.read().HSERDY != 0) {
                break;
            }
        }
        if (RCC.CTLR.read().HSERDY == 0) {
            return error.WaitHseTimeout;
        }
    }

    const sys_clk_freq: u32 = switch (cfg.sys_clk) {
        .hsi => hsi_frequency,
        .hse => cfg.source.hse.frequency,
        .pll => |pll| blk: {
            const freq = switch (cfg.source) {
                .hsi => hsi_frequency,
                .hse => |v| v.frequency,
            };

            break :blk freq * pll.mul.num();
        },
    };

    const hbclk_freq: u32 = sys_clk_freq / cfg.hb_pre.num();
    const pb1clk_freq: u32 = hbclk_freq / cfg.pb1_pre.num();
    const pb2clk_freq: u32 = hbclk_freq / cfg.pb2_pre.num();

    if (cfg.source == .hsi) {
        EXTEN.EXTEND_CTR.modify(.{ .HSIPRE = 1 });
    }

    // Set prescalers.
    RCC.CFGR0.modify(.{
        .HPRE = cfg.hb_pre.bits(),
        .PPRE1 = cfg.pb1_pre.bits(),
        .PPRE2 = cfg.pb2_pre.bits(),
    });

    if (cfg.sys_clk == .pll) {
        // Configure PLL source.
        RCC.CFGR0.modify(.{
            .PLLSRC = if (cfg.source == .hse) 1 else 0,
            .PLLXTPRE = 0,
            .PLLMUL = cfg.sys_clk.pll.mul.bits(),
        });
        // Enable PLL.
        RCC.CTLR.modify(.{ .PLLON = 1 });
        // Wait for PLL to be ready or timeout.
        var timeout: u32 = 10_000;
        while (timeout > 0) : (timeout -= 1) {
            if (RCC.CTLR.read().PLLRDY != 0) {
                break;
            }
        }
        if (RCC.CTLR.read().PLLRDY == 0) {
            return error.WaitPllTimeout;
        }
    }

    // Set system clock source.
    const sw: u2 = switch (cfg.sys_clk) {
        .hsi => 0b00,
        .hse => 0b01,
        .pll => 0b10,
    };
    RCC.CFGR0.modify(.{ .SW = sw });
    // Wait for system clock to be ready or timeout.
    var timeout: u32 = 10_000;
    while (timeout > 0) : (timeout -= 1) {
        if (RCC.CFGR0.read().SWS == sw) {
            break;
        }
    }
    if (RCC.CFGR0.read().SWS != sw) {
        return error.WaitSysClkTimeout;
    }

    return .{
        .sys = sys_clk_freq,
        .hb = hbclk_freq,
        .pb1 = pb1clk_freq,
        .pb2 = pb2clk_freq,
    };
}

pub fn get(hse_frequency: u32) ?Clocks {
    const RCC = svd.peripherals.RCC;
    const CFGR0 = RCC.CFGR0.read();

    const sys_clk_freq: u32 = switch (CFGR0.SWS) {
        0b00 => hsi_frequency,
        0b01 => default_hse_frequency,
        0b10 => blk: {
            const freq = switch (CFGR0.PLLSRC) {
                0 => hsi_frequency,
                1 => hse_frequency,
            };

            const pll_mul = PllMul.fromBits(CFGR0.PLLMUL) orelse return null;
            break :blk freq * pll_mul.num();
        },
        else => return null,
    };

    const hpre = HbPrescaler.fromBits(CFGR0.HPRE) orelse return null;
    const hbclk_freq: u32 = sys_clk_freq / hpre.num();

    const pb1pre = PbPrescaler.fromBits(CFGR0.PPRE1) orelse return null;
    const pb1clk_freq: u32 = hbclk_freq / pb1pre.num();

    const pb2pre = PbPrescaler.fromBits(CFGR0.PPRE2) orelse return null;
    const pb2clk_freq: u32 = hbclk_freq / pb2pre.num();

    return .{
        .sys = sys_clk_freq,
        .hb = hbclk_freq,
        .pb1 = pb1clk_freq,
        .pb2 = pb2clk_freq,
    };
}

// Adjusts the Internal High Speed oscillator (HSI) calibration value.
// value must be a number between 0 and 31(0x1F).
pub fn adjustHsiCalibrationValue(value: u5) void {
    const RCC = svd.peripherals.RCC;
    RCC.CTLR.modify(.{ .HSITRIM = value });
}
