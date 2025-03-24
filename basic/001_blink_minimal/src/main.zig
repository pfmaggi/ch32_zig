// Registers adresses are taken from CH32V003 reference manual.
const RCC_BASE: u32 = 0x40021000;
// const GPIOA_BASE: u32 = 0x40010800;
const GPIOC_BASE: u32 = 0x40011000;
// cosnt GPIOD_BASE: u32 = 0x40011400;
const GPIO_BASE = GPIOC_BASE;

const RCC_APB2PCENR: *volatile u32 = @ptrFromInt(RCC_BASE + 0x18);
const GPIO_CFGLR: *volatile u32 = @ptrFromInt(GPIO_BASE + 0x00);
const GPIO_OUTDR: *volatile u32 = @ptrFromInt(GPIO_BASE + 0x0C);

// Port bit offset: A - 2, B - 3, C - 4, D - 5.
// NOTE: If you use another port, you also need to change the value of GPIO_BASE.
const io_port_bit = 4;
// Led pin number 0-7.
const led_pin_num = 0;

// This is the entry point of the program.
export fn _start() callconv(.c) noreturn {
    RCC_APB2PCENR.* |= @as(u32, 1) << io_port_bit; // Enable Port clock.
    GPIO_CFGLR.* &= ~(@as(u32, 0b1111) << led_pin_num * 4); // Clear all bits for pin.
    GPIO_CFGLR.* |= @as(u32, 0b0011) << led_pin_num * 4; // Set push-pull output for pin.

    while (true) {
        GPIO_OUTDR.* ^= @as(u16, 1 << led_pin_num); // Toggle pin.

        // Simple delay.
        var i: u32 = 0;
        while (i < 1_000_000) : (i += 1) {
            // ZIG please don't optimize this loop away.
            asm volatile ("" ::: "memory");
        }
    }
}
