const std = @import("std");
const builtin = @import("builtin");
const root = @import("root");

comptime {
    @export(&interrups, .{
        .name = "interrups",
        .section = ".init",
    });
}

const interrups: Interrups = if (@hasDecl(root, "interrups")) root.interrups else .{};

pub const Interrups = extern struct {
    // const Handler = *const fn () callconv(.{ .riscv32_interrupt = .{.mode = .machine}}) void;
    const Handler = *const fn () callconv(.C) noreturn;
    _reserved1: [1]u32 = undefined,
    NMI: Handler = unhandledInterrupt,
    EXC: Handler = unhandledInterrupt,
    _reserved4: [8]u32 = undefined,
    SysTick: Handler = unhandledInterrupt,
    _reserved13: [1]u32 = undefined,
    SW: Handler = unhandledInterrupt,
    _reserved15: [1]u32 = undefined,
    WWDG: Handler = unhandledInterrupt,
    PVD: Handler = unhandledInterrupt,
    FLASH: Handler = unhandledInterrupt,
    RCC: Handler = unhandledInterrupt,
    EXTI7_0: Handler = unhandledInterrupt,
    AWU: Handler = unhandledInterrupt,
    DMA1_CH1: Handler = unhandledInterrupt,
    DMA1_CH2: Handler = unhandledInterrupt,
    DMA1_CH3: Handler = unhandledInterrupt,
    DMA1_CH4: Handler = unhandledInterrupt,
    DMA1_CH5: Handler = unhandledInterrupt,
    DMA1_CH6: Handler = unhandledInterrupt,
    DMA1_CH7: Handler = unhandledInterrupt,
    ADC: Handler = unhandledInterrupt,
    I2C1_EV: Handler = unhandledInterrupt,
    I2C1_ER: Handler = unhandledInterrupt,
    USART1: Handler = unhandledInterrupt,
    SPI1: Handler = unhandledInterrupt,
    TIM1BRK: Handler = unhandledInterrupt,
    TIM1UP: Handler = unhandledInterrupt,
    TIM1TRG: Handler = unhandledInterrupt,
    TIM1CC: Handler = unhandledInterrupt,
    TIM2: Handler = unhandledInterrupt,
};

pub fn unhandledInterrupt() callconv(.C) noreturn {
    switch (builtin.mode) {
        .Debug, .ReleaseSafe => {
            @panic("unhandled interrupt: see mcause.");
        },
        .ReleaseSmall => @panic("UH IRQ"),
        .ReleaseFast => unreachable,
    }
}
