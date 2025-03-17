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
    const clock = hal.clock.setOrGet(.hse_max);

    const USART1 = hal.Uart.init(.USART1, .{});
    USART1.configureBaudRate(.{
        .peripheral_clock = switch (config.chip_series) {
            .ch32v003 => clock.hb,
            else => clock.pb2,
        },
        .baud_rate = 115_200,
    });
    // USART1.deinit();

    const SPI1 = try hal.Spi.init(.SPI1, .{});
    SPI1.configureBaudRate(.{
        .peripheral_clock = switch (config.chip_series) {
            .ch32v003 => clock.hb,
            else => clock.pb2,
        },
        .baud_rate = 1_000_000,
    });
    // SPI1.deinit();

    const led = switch (config.chip_series) {
        .ch32v003 => hal.Pin.init(.GPIOC, 0),
        .ch32v30x => hal.Pin.init(.GPIOA, 3),
        else => @compileError("Unsupported chip series"),
    };
    hal.port.enable(led.port);
    // hal.port.disable(led.port);
    led.asOutput(.{ .speed = .max_50mhz, .mode = .push_pull });

    _ = try USART1.writeBlocking("Hello, World!\r\n", hal.deadline.simple(100_000));

    var buffer: [32]u8 = undefined;
    _ = try USART1.writeVecBlocking(&.{ "HB clock: ", intToStr(&buffer, clock.hb), "\r\n" }, null);

    hal.debug.sdi_print.enable();

    var count: u32 = 0;
    while (true) {
        count += 1;

        var spiBuf: [8]u8 = undefined;
        _ = try SPI1.transferBlocking(u8, "Hello", &spiBuf, null);

        // led.toggle();
        const on = led.read();
        led.write(!on);

        // Print counter to UART.
        _ = try USART1.writeVecBlocking(&.{ "Counter: ", intToStr(&buffer, count), "\r\n" }, null);

        // Print and read from debug print.
        // Use `minichlink -T` for open terminal.
        var recvBuf: [32]u8 = undefined;
        var len = hal.debug.sdi_print.transfer("Hello Debug Print: ", &recvBuf);
        len += hal.debug.sdi_print.transfer(intToStr(&buffer, count), recvBuf[len..]);
        len += hal.debug.sdi_print.transfer("\r\n", recvBuf[len..]);
        if (len > 0) {
            // Print received data to UART.
            _ = try USART1.writeVecBlocking(&.{ "Debug recv: ", recvBuf[0..len], "\r\n" }, null);
        }

        // Read from uart.
        const recvLen = USART1.readBlocking(&buffer, hal.deadline.simple(1_000_000)) catch 0;
        _ = try USART1.writeVecBlocking(&.{ "UART recv: ", buffer[0..recvLen], "\r\n" }, null);

        // var i: u32 = 0;
        // while (i < 1_000_000) : (i += 1) {
        //     // ZIG please don't optimize this loop away.
        //     asm volatile ("" ::: "memory");
        // }
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
