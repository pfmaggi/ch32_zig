const RCC_BASE: u32 = 0x40021000;
const GPIOC_BASE: u32 = 0x40011000;

const RCC_APB2PCENR: *volatile u32 = @ptrFromInt(RCC_BASE + 0x18);
const GPIOC_CFGLR: *volatile u32 = @ptrFromInt(GPIOC_BASE + 0x00);
const GPIOC_OUTDR: *volatile u32 = @ptrFromInt(GPIOC_BASE + 0x0C);

const PFIC_IENR1: *volatile u32 = @ptrFromInt(0xE000E100);
const STK_CTLR: *volatile u32 = @ptrFromInt(0xE000F000);
const STK_SR: *volatile u32 = @ptrFromInt(0xE000F004);
const STK_CNTL: *volatile u32 = @ptrFromInt(0xE000F008);
const STK_CMPLR: *volatile u32 = @ptrFromInt(0xE000F010);

var cpu_freq: u32 = 8_000_000; // 8MHz

const std = @import("std");
const builtin = @import("builtin");
const start = @import("start.zig");
const irq = @import("interrups.zig");
const uart = @import("uart.zig");
const logger = @import("logger.zig");
const spi = @import("spi.zig");

pub const interrups: irq.Interrups = .{
    .SysTick = sysTickHandler,
};

comptime {
    _ = start;
    _ = irq;
}

pub const std_options = std.Options{
    .log_level = .debug,
    // .logFn = start.nopLogFn,
    .logFn = logger.logFn,
};

pub const panic = start.panic;

// Configure the RCC to use the HSI clock and PLL to get 48MHz.
fn rcc_init_hsi_pll() void {
    const RCC_CTLR: *volatile u32 = @ptrFromInt(RCC_BASE + 0x00);

    // const CFG0_PLL_TRIM: *u8 = @ptrFromInt(0x1FFFF7D4); // Factory HSI clock trim value
    // const HSITRIM = @as(u5, @truncate(CFG0_PLL_TRIM.*));
    // if (CFG0_PLL_TRIM.* != 0xFF) {
    //     // HSITRIM
    //     RCC_CTLR.* = (RCC_CTLR.* & ~@as(u32, 0b11111) << 3) | @as(u32, HSITRIM) << 3;
    // }

    const FLASH_ACTLR: *volatile u32 = @ptrFromInt(0x40022000);
    // LATENCY: Flash wait state 1 for 48MHz clock
    FLASH_ACTLR.* = (FLASH_ACTLR.* & ~@as(u32, 0b11)) | 0b01;

    const RCC_CFGR0: *volatile u32 = @ptrFromInt(RCC_BASE + 0x04);
    var v = RCC_CFGR0.*;
    // PLLSRC: HSI
    v = (v & ~@as(u32, 0b1) << 16) | 0b0 << 16;
    // HPRE: Prescaler off
    v = (v & ~@as(u32, 0b1111 << 4)) | 0b0000 << 4;
    RCC_CFGR0.* = v;

    RCC_CTLR.* |= 1 << 24; // PLLON

    // Spin until PLL ready
    while (RCC_CTLR.* >> 25 & 1 != 1) {
        asm volatile ("nop" ::: "memory");
    }

    // Select PLL clock source
    // RCC_CFGR0.* |= 0b10 << 0; // SW: PLL
    RCC_CFGR0.* = (RCC_CFGR0.* & ~@as(u32, 0b11)) | 0b10;

    // Spin until PLL selected
    while (RCC_CFGR0.* >> 2 & 0b11 != 0b10) {
        asm volatile ("nop" ::: "memory");
    }

    cpu_freq = 48_000_000; // 48MHz
}

// To save space in a flash, you can use `noreturn` or `void`.
pub fn main() void {
    // rcc_init_hsi_pll();

    const systick_one_second = cpu_freq;

    RCC_APB2PCENR.* |= @as(u32, 1 << 4); // Enable Port C clock.
    GPIOC_CFGLR.* &= ~@as(u32, 0b1111 << 0); // Clear all bits for PC0
    GPIOC_CFGLR.* |= @as(u32, 0b0011 << 0); // Set push-pull output for PC0

    GPIOC_OUTDR.* |= @as(u16, 1 << 0); // Set PC0 (disable led)

    // Setup SysTick

    // Reset configuration.
    STK_CTLR.* = 0;
    // Reset the Count Register.
    STK_CNTL.* = 0;
    // Set the compare register to trigger once per second.
    STK_CMPLR.* = systick_one_second - 1;
    // Set the SysTick Configuration.
    // Bits:
    //   0 - Turn on the system counter STK
    //   1 - Enable counter interrupt.
    //   2 - HCLK for time base.
    //   3 - Re-counting from 0 after counting up to the comparison value.
    STK_CTLR.* = 0b1111;

    // Enable SysTick interrupt.
    // Bit 12 - SysTick interrupt.
    PFIC_IENR1.* |= @as(u32, 1 << 12);

    uart.USART1.setup(.{
        .cpu_frequency = cpu_freq,
        .baud_rate = 115200,
    });

    _ = uart.USART1.writeBlocking("UART initialized\n", null) catch {};
    logger.set(uart.USART1);
    std.log.info("Logger initialized", .{});

    spi.SPI1.setup(.{ .mode = .master });
    const SPI_STATR: *volatile u32 = @ptrFromInt(0x40013008);
    std.log.info("SPI1 initialized: 0b{b:0>8}", .{SPI_STATR.*});

    var timestamp: u32 = 0;
    while (true) {
        if (STK_CNTL.* - timestamp > 10000) {
            timestamp = STK_CNTL.*;
        }

        _ = spi.SPI1.writeBlocking("Test", null) catch {};
    }
}

pub fn sysTickHandler() callconv(.C) noreturn {
    GPIOC_OUTDR.* ^= @as(u16, 1 << 0); // Toggle PC0

    // Clear the trigger state for the next interrupt.
    STK_SR.* = 0;

    // All interrupts must end with mret instruction.
    asm volatile ("mret");
    unreachable;
}
