const startup = @import("core/startup.zig");

pub const zasm = @import("core/asm.zig");
pub const interrups = @import("core/interrups.zig");
pub const log = @import("core/log.zig");
// pub const panic = @import("core/panic.zig");

// Comptime exports.
comptime {
    _ = startup;
    _ = interrups;
}

pub const Interrups = interrups.Interrups;

test {
    _ = startup;
    _ = interrups;
    // _ = panic;
}
