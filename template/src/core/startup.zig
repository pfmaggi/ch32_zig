const std = @import("std");
const builtin = @import("builtin");
const root = @import("root");
const panic = @import("panic.zig");

comptime {
    if (!builtin.is_test) {
        asm (
            \\.section .init
            \\j _start
        );

        @export(&_start, .{ .name = "_start" });
    }
}

fn _start() callconv(.C) noreturn {
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
    // MPIE and MIE.
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
    if (return_type != .void and return_type != .noreturn and return_type != .error_union) {
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

    panic.hang();
}
