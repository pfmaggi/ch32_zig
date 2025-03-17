const config = @import("config");

pub const Pin = @import("Pin.zig");
pub const port = @import("port.zig");
pub const Uart = @import("Uart.zig");
pub const Spi = @import("Spi.zig");
pub const deadline = @import("deadline.zig");
pub const debug = @import("debug.zig");

pub const clock = switch (config.chip_series) {
    .ch32v003 => @import("clock/ch32v003.zig"),
    .ch32v30x => @import("clock/ch32v30x.zig"),
    // TODO: implement other chips
    else => @compileError("Unsupported chip series"),
};

test {
    @import("std").testing.refAllDecls(@This());
}
