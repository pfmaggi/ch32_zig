const config = @import("config");
const std = @import("std");
const core = @import("core/core.zig");
const hal = @import("hal/hal.zig");

comptime {
    _ = core;
}

pub const std_options: std.Options = .{
    .logFn = core.log.nopFn,
};

pub const panic = core.panic.silent;

pub const interrups: core.Interrups = .{};

pub fn main() !void {
    hal.gpio.Port.C.enable();

    const led = hal.gpio.Pin.init(.C, 0);
    led.as_output(.{ .speed = .max_50mhz, .mode = .push_pull });

    while (true) {
        // led.toggle();
        const on = led.read();
        led.write(!on);

        var i: u32 = 0;
        while (i < 1_000_000) : (i += 1) {
            // ZIG please don't optimize this loop away.
            asm volatile ("" ::: "memory");
        }
    }

    unreachable;
}

test {
    _ = hal;
}
