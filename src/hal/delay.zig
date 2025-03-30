const std = @import("std");
const config = @import("config");
const svd = @import("svd");

const hal = @import("hal.zig");

const Data = packed struct(u32) {
    us: u8 = 0, // 1 - 144
    ms: u24 = 0, // 1_000 - 144_000
};

var data = Data{};

/// Initialize delay dividers for the given clock and enable SysTick timer.
pub fn init(clock: hal.clock.Clocks) void {
    data.us = @truncate(div_optimized(clock.hb, 1_000_000));
    data.ms = @truncate(div_optimized(clock.hb, 1_000));

    // Enable SysTick timer.
    svd.peripherals.PFIC.STK_CTLR.modify(.{
        .STE = 1, // Enable SysTick.
        .STCLK = 1, // HCLK/1 for time base.
    });
}

/// Delay in SysTick clock cycles.
pub fn sysTick(n: u32) void {
    const PFIC = svd.peripherals.PFIC;

    const end: i32 = @intCast(PFIC.STK_CNTL.raw +% n);

    while (@as(i32, @intCast(PFIC.STK_CNTL.raw)) -% end < 0) {
        asm volatile ("" ::: "memory");
    }
}

/// Delay in microseconds.
pub inline fn us(n: u32) void {
    // n * data.us optimization.
    for (0..n) |_| {
        sysTick(data.us);
    }
}

/// Delay in milliseconds.
pub inline fn ms(n: u32) void {
    // n * data.ms optimization.
    for (0..n) |_| {
        sysTick(data.ms);
    }
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

test "div_optimized" {
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
