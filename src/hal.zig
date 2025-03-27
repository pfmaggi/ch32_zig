const config = @import("config");

pub const Pin = @import("hal/Pin.zig");
pub const port = @import("hal/port.zig");
pub const Uart = @import("hal/Uart.zig");
pub const Spi = @import("hal/Spi.zig");
pub const I2c = @import("hal/I2c.zig");
pub const deadline = @import("hal/deadline.zig");
pub const debug = @import("hal/debug.zig");

pub const clock = switch (config.chip_series) {
    .ch32v003 => @import("hal/clock/ch32v003.zig"),
    .ch32v30x => @import("hal/clock/ch32v30x.zig"),
    // TODO: implement other chips
    else => @compileError("Unsupported chip series"),
};

test {
    @import("std").testing.refAllDecls(@This());
}
