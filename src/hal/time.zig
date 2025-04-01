const std = @import("std");
const config = @import("config");
const svd = @import("svd");

const hal = @import("hal.zig");
const PFIC = svd.peripherals.PFIC;

const SysTicksPer = packed struct(u32) {
    us: u8 = 0, // 1 - 144
    ms: u24 = 0, // 1_000 - 144_000
};
var systicks_per = SysTicksPer{};
var systick_millis: u32 = 0;

/// Enable SysTick timer and initialize dividers for the given clock.
pub fn init(clock: hal.clock.Clocks) void {
    comptime {
        if (!isEnabledInterrupt()) {
            @compileError("SysTick interrupt handler should be defined to `hal.time.sysTickHandler`");
        }
    }

    systicks_per.us = @truncate(div_optimized(clock.hb, 1_000_000));
    systicks_per.ms = @truncate(div_optimized(clock.hb, 1_000));

    PFIC.STK_CTLR.write(.{});
    // Reset the Count Register.
    PFIC.STK_CNTL.raw = 0;
    // Set the compare register to trigger once per millisecond.
    PFIC.STK_CMPLR.raw = systicks_per.ms - 1;
    // Enable SysTick timer.
    PFIC.STK_CTLR.write(.{
        // Enable SysTick.
        .STE = 1,
        // Enable counter interrupt.
        .STIE = 1,
        // HCLK/1 for time base.
        .STCLK = 1,
    });

    // Enable SysTick interrupt.
    hal.interrupts.enable(.SysTick);
}

pub fn isEnabledInterrupt() bool {
    return @import("root").interrupts.SysTick == sysTickHandler;
}

pub fn sysTickHandler() callconv(hal.interrupts.call_conv) void {
    PFIC.STK_CMPLR.raw +%= systicks_per.ms;

    // Clear the trigger state for the next interrupt.
    PFIC.STK_SR.modify(.{ .CNTIF = 0 });

    // Increment the milliseconds count
    systick_millis +%= 1;
}

pub inline fn millis() u32 {
    return systick_millis;
}

// micros rolls over every ~89.5 seconds if cpu frequency is 48MHz.
pub inline fn micros() u32 {
    return div_optimized(ticks() / systicks_per.us);
}

pub inline fn ticks() u32 {
    return PFIC.STK_CNTL.raw;
}

pub const delay = struct {
    pub inline fn init(_: hal.clock.Clocks) void {}

    /// Delay in SysTick clock cycles.
    pub inline fn ticks(n: u32) void {
        const end = PFIC.STK_CNTL.raw +% n;

        while (diffTime(PFIC.STK_CNTL.raw, end) < 0) {
            asm volatile ("" ::: "memory");
        }
    }

    /// Delay in microseconds.
    pub inline fn us(n: u32) void {
        const start = PFIC.STK_CNTL.raw;
        const ticks_count = n * @as(u32, @intCast(systicks_per.us));
        const end = start +% ticks_count;

        while (diffTime(PFIC.STK_CNTL.raw, end) < 0) {
            asm volatile ("" ::: "memory");
        }
    }

    /// Delay in milliseconds.
    pub inline fn ms(n: u32) void {
        const end = millis() +% n;

        while (diffTime(millis(), end) < 0) {
            hal.interrupts.wait();
        }
    }
};

inline fn diffTime(a: u32, b: u32) i32 {
    return @bitCast(a -% b);
}

fn div_optimized(n: u32, d: u32) u32 {
    var q: u32 = 0;
    var r: u32 = n;

    while (r >= d) {
        r -= d;
        q += 1;
    }

    return q;
}

test div_optimized {
    const Test = struct {
        n: u32,
        d: u32,
        expected: u32,
    };
    const tests = [_]Test{
        // Hz to MHz
        .{ .n = 1_000_000, .d = 1_000_000, .expected = 1 },
        .{ .n = 8_000_000, .d = 1_000_000, .expected = 8 },
        .{ .n = 16_000_000, .d = 1_000_000, .expected = 16 },
        .{ .n = 24_000_000, .d = 1_000_000, .expected = 24 },
        .{ .n = 48_000_000, .d = 1_000_000, .expected = 48 },
        .{ .n = 96_000_000, .d = 1_000_000, .expected = 96 },
        .{ .n = 144_000_000, .d = 1_000_000, .expected = 144 },
        // Hz to kHz
        .{ .n = 1_000_000, .d = 1_000, .expected = 1_000 },
        .{ .n = 8_000_000, .d = 1_000, .expected = 8_000 },
        .{ .n = 16_000_000, .d = 1_000, .expected = 16_000 },
        .{ .n = 24_000_000, .d = 1_000, .expected = 24_000 },
        .{ .n = 48_000_000, .d = 1_000, .expected = 48_000 },
        .{ .n = 96_000_000, .d = 1_000, .expected = 96_000 },
        .{ .n = 144_000_000, .d = 1_000, .expected = 144_000 },
    };

    for (tests) |t| {
        const actual = div_optimized(t.n, t.d);
        try std.testing.expectEqual(t.expected, actual);
    }
}
