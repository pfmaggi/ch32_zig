const RCC_BASE: u32 = 0x40021000;
const GPIOC_BASE: u32 = 0x40011000;

const RCC_APB2PCENR: *volatile u32 = @ptrFromInt(RCC_BASE + 0x18);
const GPIOC_CFGLR: *volatile u32 = @ptrFromInt(GPIOC_BASE + 0x00);
const GPIOC_OUTDR: *volatile u32 = @ptrFromInt(GPIOC_BASE + 0x0C);

// This is the entry point of the program.
export fn _start() callconv(.C) noreturn {
    RCC_APB2PCENR.* |= @as(u32, 1 << 4); // Enable Port C clock.
    GPIOC_CFGLR.* &= ~@as(u32, 0b1111 << 0); // Clear all bits for PC0
    GPIOC_CFGLR.* |= @as(u32, 0b0011 << 0); // Set push-pull output for PC0

    while (true) {
        GPIOC_OUTDR.* ^= @as(u16, 1 << 0); // Toggle PC0

        var i: u32 = 0;
        while (i < 1_000_000) : (i += 1) {
            // ZIG please don't optimize this loop away.
            asm volatile ("" ::: "memory");
        }
    }
}
