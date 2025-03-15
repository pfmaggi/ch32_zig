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
    const clock = hal.clock.setOrGet(.hse_48mhz);

    hal.port.enable(.GPIOC);
    // hal.port.disable(.GPIOC);

    const USART1 = hal.Uart.from(.USART1);
    USART1.configure(.{});
    USART1.configureBaudRate(.{
        .peripheral_clock = clock.peripheral,
        .baud_rate = 115_200,
    });

    const SPI1 = try hal.Spi.init(.SPI1, .{
        // .pins = hal.Spi.Pins.spi1.softwareNss(.init(.GPIOC, 1)),
    });
    SPI1.configureBaudRate(.{
        .calc = .{
            .peripheral_clock = clock.peripheral,
            .baud_rate = 1_000_000,
        },
    });

    const led = hal.Pin.init(.GPIOC, 0);
    led.asOutput(.{ .speed = .max_50mhz, .mode = .push_pull });

    _ = try USART1.writeBlocking("Hello, World!\r\n", hal.deadline.simple(100_000));

    hal.debug.sdi_print.enable();

    var count: u32 = 0;
    var buffer: [32]u8 = undefined;
    while (true) {
        count += 1;

        var b: [8]u8 = undefined;
        _ = try SPI1.transferBlocking(u8, "Hello", &b, null);

        // led.toggle();
        const on = led.read();
        led.write(!on);

        // Print counter to UART.
        _ = try USART1.writeBlocking("Counter: ", null);
        _ = try USART1.writeBlocking(intToStr(&buffer, count), null);
        _ = try USART1.writeBlocking("\r\n", null);

        // Print and read from debug print.
        // Use `minichlink -T` for open terminal.
        var recvBuf: [32]u8 = undefined;
        var len = hal.debug.sdi_print.transfer("Hello Debug Print: ", &recvBuf);
        len += hal.debug.sdi_print.transfer(intToStr(&buffer, count), recvBuf[len..]);
        len += hal.debug.sdi_print.transfer("\r\n", recvBuf[len..]);
        if (len > 0) {
            // Print received data to UART.
            _ = try USART1.writeBlocking("Debug recv: ", null);
            _ = try USART1.writeBlocking(recvBuf[0..len], null);
            _ = try USART1.writeBlocking("\r\n", null);
        }

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
