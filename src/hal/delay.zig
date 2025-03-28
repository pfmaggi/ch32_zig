const std = @import("std");
const config = @import("config");
const svd = @import("svd");

const hal = @import("hal.zig");

var p_us: u32 = 0;
var p_ms: u32 = 0;

pub fn init(c: hal.clock.Clocks) void {
    const clock = c.hb;

    p_us = clock / 1_000_000;
    p_ms = clock / 1_000;

    // Enable SysTick timer.
    svd.peripherals.PFIC.STK_CTLR.modify(.{
        .STE = 1,
        .STCLK = 1, // HCLK/1 for time base.
    });
}

pub fn sysTick(n: u32) void {
    const PFIC = svd.peripherals.PFIC;

    const end: i32 = @intCast(PFIC.STK_CNTL.raw + n);

    while (@as(i32, @intCast(PFIC.STK_CNTL.raw)) - end < 0) {
        asm volatile ("" ::: "memory");
    }
}

pub fn us(n: u32) void {
    sysTick(n * p_us);
}

pub fn ms(n: u32) void {
    sysTick(n * p_ms);
}
