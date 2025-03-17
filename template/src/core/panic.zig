const std = @import("std");
const zasm = @import("asm.zig");
const interrups = @import("interrups.zig");
const config = @import("config");

// Prints the message and registers dump to the logger if configured.
pub fn log(message: []const u8, _: ?*std.builtin.StackTrace, _: ?usize) noreturn {
    interrups.disable();

    std.log.err(
        \\PANIC: {s}
        \\Registers dump:
        \\    MSTATUS: 0x{X:0>8}
        \\    MEPC: 0x{X:0>8}
        \\    MCAUSE: 0x{X:0>8}
        \\    MTVAL: 0x{X:0>8}
        \\    MSCRATCH: 0x{X:0>8}
    , .{ message, zasm.getMstatus(), zasm.getMepc(), zasm.getMcause(), zasm.getMtval(), zasm.getMscratch() });

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

    hang();
}

// Silent panic handler.
pub fn silent(_: []const u8, _: ?*std.builtin.StackTrace, _: ?usize) noreturn {
    hang();
}

pub fn hang() noreturn {
    interrups.disable();

    const hasLed = true;
    if (!hasLed) {
        while (true) {
            zasm.wfi();
        }
    }

    // Fast blink for debugging.
    // FIXME: use LED GPIO instead raw.
    const led_pin_num: u5 = if (config.chip_series == .ch32v003) 0 else 3;
    const GPIO_BASE: u32 = if (config.chip_series == .ch32v003) 0x40011000 else 0x40010800; // C else A
    const GPIO_CFGLR: *volatile u32 = @ptrFromInt(GPIO_BASE + 0x00);
    const GPIO_OUTDR: *volatile u32 = @ptrFromInt(GPIO_BASE + 0x0C);
    GPIO_CFGLR.* &= ~@as(u32, 0b1111 << 0); // Clear all bits for PC0
    GPIO_CFGLR.* |= @as(u32, 0b0011 << 0); // Set push-pull output for PC0

    while (true) {
        GPIO_OUTDR.* ^= @as(u16, 1 << led_pin_num); // Toggle pin.

        var i: u32 = 0;
        while (i < 100_000) : (i += 1) {
            asm volatile ("" ::: "memory");
        }
    }
}
