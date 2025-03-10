const RCC_BASE: u32 = 0x40021000;
const GPIOC_BASE: u32 = 0x40011000;

const RCC_APB2PCENR: *volatile u32 = @ptrFromInt(RCC_BASE + 0x18);
const GPIOC_CFGLR: *volatile u32 = @ptrFromInt(GPIOC_BASE + 0x00);
const GPIOC_OUTDR: *volatile u32 = @ptrFromInt(GPIOC_BASE + 0x0C);

// Global variable in memory.
// Code with such a variable will not work without a linker script
// and without copying the .data section to RAM.
var step: u32 = 1;

pub fn main() void {
    RCC_APB2PCENR.* |= @as(u32, 1 << 4); // Enable Port C clock.
    GPIOC_CFGLR.* &= ~@as(u32, 0b1111 << 0); // Clear all bits for PC0
    GPIOC_CFGLR.* |= @as(u32, 0b0011 << 0); // Set push-pull output for PC0

    while (true) {
        GPIOC_OUTDR.* ^= @as(u16, 1 << 0); // Toggle PC0

        var i: u32 = 0;
        while (i < 1_000_000) : (i += step) {
            // ZIG please don't optimize this loop away.
            asm volatile ("" ::: "memory");
        }

        step += 1;
        if (step > 100) {
            step = 1;
        }
    }
}

// This is the entry point of the program.
export fn _start() linksection(".init") callconv(.naked) noreturn {
    // We need to make a jump because right below this code
    // is the interrupt vector table, which we will deal with later.
    asm volatile ("j resetHandler");
}

// Get the address of the .bss and .data sections from the linker script.
extern var __bss_start: u32;
extern const __bss_end: u32;
extern var __data_start: u32;
extern const __data_end: u32;
extern const __data_load_start: u32;

export fn resetHandler() callconv(.c) noreturn {
    // Set global pointer.
    asm volatile (
        \\.option push
        \\.option norelax
        \\la gp, __global_pointer$
        \\.option pop
    );

    // Set stack pointer.
    asm volatile (
        \\la sp, __end_of_stack
    );

    // Using a simple loop instead of @memset and @memcpy
    // allows the program size to be closer to the assembly version.

    // Clear .bss section.
    const bss_start: [*]align(4) u32 = @ptrCast(&__bss_start);
    const bss_end: [*]align(4) const u32 = @ptrCast(&__bss_end);
    const bss_len = @intFromPtr(bss_end) - @intFromPtr(bss_start);
    // Divide by 4 because we are working with u32(4 bytes).
    for (0..bss_len / 4) |i| bss_start[i] = 0;

    // Copy .data from Flash to RAM.
    const data_start: [*]align(4) u32 = @ptrCast(&__data_start);
    const data_end: [*]align(4) const u32 = @ptrCast(&__data_end);
    const data_len = @intFromPtr(data_end) - @intFromPtr(data_start);
    const data_src: [*]align(4) const u32 = @ptrCast(&__data_load_start);
    // Divide by 4 because we are working with u32(4 bytes).
    for (0..data_len / 4) |i| data_start[i] = data_src[i];

    main();

    // If main() returns, enter to sleep mode.
    while (true) {
        // wfi - Wait For Interrupt, but we not enable any interrupt.
        asm volatile ("wfi");
    }
}
