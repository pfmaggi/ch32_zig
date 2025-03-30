const std = @import("std");
const config = @import("config");
const hal = @import("hal");

pub fn main() !void {
    // Select LED pin based on chip series.
    const led = switch (config.chip.series) {
        .ch32v003 => hal.Pin.init(.GPIOC, 0),
        .ch32v103 => hal.Pin.init(.GPIOC, 0),
        .ch32v20x => hal.Pin.init(.GPIOA, 15), // nanoCH32V203 board
        .ch32v30x => hal.Pin.init(.GPIOA, 3), // nanoCH32V305 board
        // else => @compileError("Unsupported chip series"),
    };
    hal.port.enable(led.port);
    // hal.port.disable(led.port);

    led.asOutput(.{ .speed = .max_50mhz, .mode = .push_pull });

    while (true) {
        // const on = led.read();
        // led.write(!on);
        // or
        led.toggle();

        dummyLoop(1_000_000);
    }
}

fn dummyLoop(cnt: u32) void {
    var i: u32 = 0;
    while (i < cnt) : (i += 1) {
        // ZIG please don't optimize this loop away.
        asm volatile ("" ::: "memory");
    }
}
