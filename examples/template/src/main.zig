const std = @import("std");
const config = @import("config");
const hal = @import("hal");

// pub const panic = hal.panic.silent;
pub const panic = hal.panic.log;

pub const std_options: std.Options = .{
    .log_level = .debug,
    .logFn = hal.log.logFn,
};

pub fn main() !void {
    hal.debug.sdi_print.enable();
    // hal.log.setWriter(hal.debug.sdi_print.writer().any());

    // Set clock to 48MHz.
    const clock = hal.clock.setOrGet(.hsi_48mhz);

    const USART1 = hal.Uart.init(.USART1, .{});
    USART1.configureBaudRate(.{
        .peripheral_clock = switch (config.chip.series) {
            .ch32v003 => clock.hb,
            else => clock.pb2,
        },
        .baud_rate = 115_200,
    });
    // USART1.deinit();

    hal.log.setWriter(USART1.writer().any());

    // Select LED pin based on chip series.
    const led = switch (config.chip.series) {
        .ch32v003 => hal.Pin.init(.GPIOC, 0),
        // .ch32v103 => hal.Pin.init(.GPIOC, 0),
        .ch32v20x => hal.Pin.init(.GPIOA, 15), // nanoCH32V203 board
        .ch32v30x => hal.Pin.init(.GPIOA, 3), // nanoCH32V305 board
        else => @compileError("Unsupported chip series"),
    };
    hal.port.enable(led.port);
    // hal.port.disable(led.port);

    led.asOutput(.{ .speed = .max_50mhz, .mode = .push_pull });

    _ = try USART1.writeBlocking("Hello, World!\r\n", hal.deadline.simple(100_000));

    std.log.info("Clock: {}", .{clock});

    var buffer: [64]u8 = undefined;
    var count: u32 = 0;
    while (true) {
        count += 1;

        // Print counter to UART.
        _ = try USART1.writeVecBlocking(&.{ "Counter: ", intToStr(&buffer, count), "\r\n" }, null);

        // led.toggle();
        // or
        const on = led.read();
        led.write(!on);

        dummyLoop(8_000_000);
    }
}

inline fn dummyLoop(count: u32) void {
    var i: u32 = 0;
    while (i < count) : (i += 1) {
        // ZIG please don't optimize this loop away.
        asm volatile ("" ::: "memory");
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
