const hal = @import("hal");
const startup = @import("startup.zig");

// Added to execute test code.
comptime {
    _ = hal;
    _ = startup;
}

pub fn main() !void {}
