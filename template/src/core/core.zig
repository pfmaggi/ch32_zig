const startup = @import("startup.zig");

pub const zasm = @import("asm.zig");
pub const interrups = @import("interrups.zig");
pub const log = @import("log.zig");
pub const panic = @import("panic.zig");

// Comptime exports.
comptime {
    _ = startup;
    _ = interrups;
}

pub const Interrups = interrups.Interrups;

test {
    _ = startup;
    _ = interrups;
    _ = panic;
}
