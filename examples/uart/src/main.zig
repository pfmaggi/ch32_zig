const std = @import("std");
const config = @import("config");
const hal = @import("hal");

pub fn main() !void {
    const clock = hal.clock.setOrGet(.hsi_max);
    hal.delay.init(clock);

    // Configure UART.
    // The default pins are:
    // For CH32V003: TX: PD5, RX: PD6.
    // For CH32V103, CH32V20x and CH32V30x: TX: PA9, RX: PA10.
    const USART1 = hal.Uart.init(.USART1, .{
        // For this example we will use only transmit mode.
        // Default is .tx_rx.
        .mode = .tx,
        // You can use the default pins for the selected USART by leaving the field null or remap it to other pins.
        // For example, to use the remapped pins for USART1 on CH32V003:
        // .pins = hal.Uart.Pins.usart1.tx_pd0_rx_pd1,
    });
    // Runtime baud rate configuration.
    USART1.configureBaudRate(.{
        .peripheral_clock = switch (config.chip.series) {
            .ch32v003 => clock.hb,
            else => clock.pb2,
        },
        .baud_rate = 115_200,
    });

    _ = try USART1.writeBlocking("Hello, World!\r\n", hal.deadline.simple(100_000));

    // Counter is 32 bits, so we need 10 bytes to store it,
    // because max value is 4294967295.
    var buf: [10]u8 = undefined;
    var counter: u32 = 0;
    while (true) {
        counter += 1;

        // Print counter to UART.
        _ = try USART1.writeVecBlocking(&.{ "Counter: ", intToStr(&buf, counter), "\r\n" }, null);

        hal.delay.ms(1000);
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
