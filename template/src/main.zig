const config = @import("config");
const std = @import("std");
const svd = @import("svd");
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
    hal.gpio.Port.enable(.GPIOC);
    // hal.gpio.Port.disable(.GPIOC);

    const USART1 = hal.UART.from(.USART1);
    USART1.setup(.{
        .cpu_frequency = 8_000_000,
        .baud_rate = 115_200,
    });

    const led = hal.gpio.Pin.init(.GPIOC, 0);
    led.as_output(.{ .speed = .max_50mhz, .mode = .push_pull });

    _ = try USART1.writeBlocking("Hello, World!\r\n", hal.uart.simpleDeadline(100_000));

    var count: u32 = 0;
    var buffer: [10]u8 = undefined;
    while (true) {
        _ = try USART1.writeBlocking(intToStr(&buffer, count), null);
        _ = try USART1.writeBlocking("\r\n", null);
        count += 1;

        // led.toggle();
        const on = led.read();
        led.write(!on);

        var i: u32 = 0;
        while (i < 1_000_000) : (i += 1) {
            // ZIG please don't optimize this loop away.
            asm volatile ("" ::: "memory");
        }
    }
}

fn intToStr(buf: []u8, value: u32) []u8 {
    var i: u32 = buf.len;
    var v: u32 = value;
    if (v == 0) {
        buf[0] = '0';
        return buf[0..1];
    }

    while (v > 0) : (v /= 10) {
        i -= 1;
        buf[i] = @as(u8, @truncate(v % 10)) + '0';
    }

    return buf[i..];
}

test {
    _ = hal;
}
