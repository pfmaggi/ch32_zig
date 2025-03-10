const std = @import("std");
const builtin = @import("builtin");
const root = @import("root");

comptime {
    asm (
        \\.section .init
        \\j _start
    );

    @export(&_start, .{ .name = "_start" });
}

pub fn nopLogFn(
    comptime _: std.log.Level,
    comptime _: @Type(.enum_literal),
    comptime _: []const u8,
    _: anytype,
) void {}

fn _start() callconv(.c) noreturn {
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
    );

    callMain();
}

inline fn callMain() noreturn {
    const main_invalid_msg = "main must be either \"pub fn main() void\" or \"pub fn main() !void\".";

    const main_type = @typeInfo(@TypeOf(root.main));
    if (main_type != .@"fn" or main_type.@"fn".params.len > 0) {
        @compileError(main_invalid_msg);
    }

    const return_type = @typeInfo(main_type.@"fn".return_type.?);
    if (return_type != .void and return_type != .error_union) {
        @compileError(main_invalid_msg);
    }

    if (return_type == .error_union) {
        root.main() catch |err| {
            const prefix = "main() returned error";

            var buf: [64]u8 = undefined;
            const msg = std.fmt.bufPrint(&buf, prefix ++ " {s}", .{@errorName(err)}) catch prefix;
            @panic(msg);
        };
    } else {
        root.main();
    }

    hang();
}

// Panic handler prints the message and registers dump to the UART if configured.
pub fn panic(message: []const u8, _: ?*std.builtin.StackTrace, _: ?usize) noreturn {
    disableInterrupts();

    std.log.err(
        \\PANIC: {s}
        \\Registers dump:
        \\    MSTATUS: 0x{X:0>8}
        \\    MEPC: 0x{X:0>8}
        \\    MCAUSE: 0x{X:0>8}
        \\    MTVAL: 0x{X:0>8}
        \\    MSCRATCH: 0x{X:0>8}
    , .{ message, getMstatus(), getMepc(), getMcause(), getMtval(), getMscratch() });

    // Stack trace
    // Use `riscv-none-elf-addr2line -e zig-out/firmware/ch32v003_blink.elf 0x08000950` ---> main.zig:xxx
    var index: usize = 0;
    var iter = std.debug.StackIterator.init(@returnAddress(), null);
    while (iter.next()) |address| : (index += 1) {
        if (index == 0) {
            std.log.err("Stack trace:", .{});
        }
        std.log.err("{d: >3}: 0x{X:0>8}", .{ index, address });

        // Avoid infinite loop.
        if (index >= 10) break;
    }

    // TODO: check debugger attached
    if (false) {
        @breakpoint();
    }

    hang();
}

// Disable interrupts and enter to sleep mode.
pub fn hang() noreturn {
    disableInterrupts();

    // Fast blink.
    const GPIOC_OUTDR: *volatile u32 = @ptrFromInt(0x40011000 + 0x0C);
    while (true) {
        GPIOC_OUTDR.* ^= @as(u16, 1 << 0); // Toggle PC0

        var i: u32 = 0;
        while (i < 100_000) : (i += 1) {
            asm volatile ("" ::: "memory");
        }
    }

    // while (true) {
    //     wfi();
    // }
}

// Wait for interrupt.
// This will put the processor into a low power state until an interrupt occurs.
pub inline fn wfi() void {
    asm volatile ("wfi");
}

pub inline fn wfe() void {
    // 6.5.2.22 PFIC System Control Register (PFIC_SCTLR)
    const PFIC_SCTLR: *volatile u32 = @ptrFromInt(0xE000ED10);
    // WFITOWFE. Execute the WFI command as if it were a WFE.
    PFIC_SCTLR.* |= @as(u32, 1 << 3);
    asm volatile ("wfi");
}

inline fn enableInterrupts() void {
    asm volatile ("csrsi mstatus, 0b1000");
}

inline fn disableInterrupts() void {
    asm volatile ("csrci mstatus, 0b1000");
}

inline fn isInterruptsEnabled() bool {
    return (getMstatus() & 0b1000) != 0;
}

// Return the Machine Scratch Register (MSCRATCH)
inline fn getMscratch() u32 {
    return asm ("csrr %[out], mscratch"
        : [out] "=r" (-> u32),
    );
}

// Return the Machine Status Register (MSTATUS)
inline fn getMstatus() u32 {
    return asm ("csrr %[out], mstatus"
        : [out] "=r" (-> u32),
    );
}

// Return the Machine Exception Program Register (MEPC)
inline fn getMepc() u32 {
    return asm ("csrr %[out], mepc"
        : [out] "=r" (-> u32),
    );
}

// Return the Machine Cause Register (MCAUSE)
pub inline fn getMcause() u32 {
    return asm ("csrr %[out], mcause"
        : [out] "=r" (-> u32),
    );
}

// Return the Machine Trap Value Register (MTVAL)
inline fn getMtval() u32 {
    return asm ("csrr %[out], mtval"
        : [out] "=r" (-> u32),
    );
}
