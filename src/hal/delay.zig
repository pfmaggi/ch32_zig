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
    data.us = @truncate(clock.hb / 1_000_000);
    data.ms = @truncate(clock.hb / 1_000);

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
    sysTick(n * data.us);
}

/// Delay in milliseconds.
pub inline fn ms(n: u32) void {
    const max_systicks = std.math.maxInt(u32);
    const max_ms_per_systick = max_systicks / @as(u32, data.ms);

    var _n = n;
    while (_n > max_ms_per_systick) {
        sysTick(max_systicks);
        _n -= max_ms_per_systick;
    }

    sysTick(_n * data.ms);
}
