const config = @import("config");
const std = @import("std");
const core = @import("core/core.zig");

comptime {
    _ = core;
}

pub const std_options: std.Options = .{
    .logFn = core.log.nopFn,
};

pub const panic = core.panic.silent;

pub const interrups: core.Interrups = .{};

pub fn main() !void {
    unreachable;
}
