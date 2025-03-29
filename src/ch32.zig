const std = @import("std");
const root = @import("app");
const builtin = @import("builtin");

pub const hal = @import("hal");
const startup = @import("startup.zig");

comptime {
    if (!builtin.is_test) {
        asm (
            \\.section .init
            \\j _start
        );

        @export(&startup.start, .{
            .name = "_start",
        });

        @export(&interrupts, .{
            .name = "interrupts",
            .section = ".init",
        });

        _ = root;
    }

    // Execute comptime code.
    _ = hal;
    _ = startup;
}

pub const std_options: std.Options = if (@hasDecl(root, "std_options")) root.std_options else .{};

pub const panic = if (@hasDecl(root, "panic")) root.panic else hal.panic.nop;

const interrupts: hal.Interrupts = if (@hasDecl(root, "interrupts")) root.interrupts else .{};
