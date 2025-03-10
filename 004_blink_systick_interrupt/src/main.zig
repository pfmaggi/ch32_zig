const RCC_BASE: u32 = 0x40021000;
const GPIOC_BASE: u32 = 0x40011000;

const RCC_APB2PCENR: *volatile u32 = @ptrFromInt(RCC_BASE + 0x18);
const GPIOC_CFGLR: *volatile u32 = @ptrFromInt(GPIOC_BASE + 0x00);
const GPIOC_OUTDR: *volatile u32 = @ptrFromInt(GPIOC_BASE + 0x0C);

const PFIC_IENR1: *volatile u32 = @ptrFromInt(0xE000E100);
// 6.5.4 STK Register Description
const STK_CTLR: *volatile u32 = @ptrFromInt(0xE000F000);
const STK_SR: *volatile u32 = @ptrFromInt(0xE000F004);
const STK_CNTL: *volatile u32 = @ptrFromInt(0xE000F008);
const STK_CMPLR: *volatile u32 = @ptrFromInt(0xE000F010);

const cpu_freq: u32 = 8_000_000; // 8MHz
const systick_one_second = cpu_freq;

pub fn main() void {
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
    PFIC_IENR1.* = @as(u32, 1 << 12);

    while (true) {
        // Wait for interrupt instead of busy loop.
        asm volatile ("wfi");
    }
}

export fn sysTickHandler() callconv(.c) noreturn {
    GPIOC_OUTDR.* ^= @as(u16, 1 << 0); // Toggle PC0

    // Clear the trigger state for the next interrupt.
    STK_SR.* = 0;

    // All interrupts must end with mret instruction.
    asm volatile ("mret");
    unreachable;
}

// This is the entry point of the program.
export fn _start() linksection(".init") callconv(.naked) noreturn {
    // We need to make a jump because right below this code
    // is the interrupt vector table.
    asm volatile ("j resetHandler");

    // Add interrupt vector table here.
    // We need only the SysTick.
    asm volatile (
        \\.set SysTicK_IRQn, 12
        \\.skip    4*(SysTicK_IRQn - 1)
        \\.word sysTickHandler
    );
}

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

    // Clear .bss section.
    asm volatile (
        \\    li a0, 0
        \\    la a1, __bss_start
        \\    la a2, __bss_end
        \\    beq a1, a2, clear_bss_done
        \\clear_bss_loop:
        \\    sw a0, 0(a1)
        \\    addi a1, a1, 4
        \\    blt a1, a2, clear_bss_loop
        \\clear_bss_done:
    );

    // Copy .data from flash to RAM.
    asm volatile (
        \\    la a0, __data_load_start
        \\    la a1, __data_start
        \\    la a2, __data_end
        \\copy_data_loop:
        \\    beq a1, a2, copy_done
        \\    lw a3, 0(a0)
        \\    sw a3, 0(a1)
        \\    addi a0, a0, 4
        \\    addi a1, a1, 4
        \\    bne a1, a2, copy_data_loop
        \\copy_done:
    );

    // 3.2 Interrupt-related CSR Registers
    // INTSYSCR: enable EABI, nesting and HPE.
    asm volatile ("csrsi 0x804, 0b111");
    // Enable interrupts.
    asm volatile (
        \\li a0, 0b10001000
        \\csrw mstatus, a0
    );
    // mtvec: set the base address of the interrupt vector table
    // and set the mode0 and mode1.
    asm volatile (
        \\la a0, _start
        \\ori a0, a0, 0b11
        \\csrw mtvec, a0
        ::: "a0", "memory");

    main();

    // If main() returns, disable interrupts and enter to sleep mode.
    asm volatile ("csrci mstatus, 0b1000");
    while (true) {
        // wfi - Wait For Interrupt, but we disable interrupts above.
        asm volatile ("wfi");
    }
}
