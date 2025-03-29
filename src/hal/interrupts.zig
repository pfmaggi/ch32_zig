const std = @import("std");
const config = @import("config");

pub const Interrupts = switch (config.chip.series) {
    .ch32v003 => @import("interrupts/ch32v003.zig").Interrupts,
    .ch32v20x, .ch32v30x => @import("interrupts/ch32v20x_30x.zig").Interrupts,
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
