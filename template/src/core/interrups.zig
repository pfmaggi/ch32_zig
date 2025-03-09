const std = @import("std");
const builtin = @import("builtin");
const root = @import("root");
const config = @import("config");

comptime {
    if (!builtin.is_test) {
        @export(&interrups, .{
            .name = "interrups",
            .section = ".init",
        });
    }
}

const interrups: Interrups = if (@hasDecl(root, "interrups")) root.interrups else .{};

pub const Interrups = switch (config.chip_series) {
    .ch32v003 => @import("interrups/ch32v003.zig").Interrups,
    // TODO: implement other chips
    else => @compileError("Unsupported chip series"),
};

pub inline fn enable() void {
    asm volatile ("csrsi mstatus, 0b1000");
}

pub inline fn disable() void {
    asm volatile ("csrci mstatus, 0b1000");
}

pub inline fn isEnabled() bool {
    const mstatus = asm ("csrr %[out], mstatus"
        : [out] "=r" (-> u32),
    );
    return (mstatus & 0b1000) != 0;
}
