const handler = @import("handler.zig");
const Handler = handler.Handler;
const unhandledFn = handler.unhandled;

pub const Interrups = extern struct {
    _reserved1: [1]u32 = undefined,
    NMI: Handler = unhandledFn,
    EXC: Handler = unhandledFn,
    _reserved4: [8]u32 = undefined,
    SysTick: Handler = unhandledFn,
    _reserved13: [1]u32 = undefined,
    SW: Handler = unhandledFn,
    _reserved15: [1]u32 = undefined,
    WWDG: Handler = unhandledFn,
    PVD: Handler = unhandledFn,
    FLASH: Handler = unhandledFn,
    RCC: Handler = unhandledFn,
    EXTI7_0: Handler = unhandledFn,
    AWU: Handler = unhandledFn,
    DMA1_CH1: Handler = unhandledFn,
    DMA1_CH2: Handler = unhandledFn,
    DMA1_CH3: Handler = unhandledFn,
    DMA1_CH4: Handler = unhandledFn,
    DMA1_CH5: Handler = unhandledFn,
    DMA1_CH6: Handler = unhandledFn,
    DMA1_CH7: Handler = unhandledFn,
    ADC: Handler = unhandledFn,
    I2C1_EV: Handler = unhandledFn,
    I2C1_ER: Handler = unhandledFn,
    USART1: Handler = unhandledFn,
    SPI1: Handler = unhandledFn,
    TIM1BRK: Handler = unhandledFn,
    TIM1UP: Handler = unhandledFn,
    TIM1TRG: Handler = unhandledFn,
    TIM1CC: Handler = unhandledFn,
    TIM2: Handler = unhandledFn,
    // FIXME: add more handlers
};
