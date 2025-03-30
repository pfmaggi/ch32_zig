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
        // .mode = .tx_rx, // Default mode.
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

    _ = try USART1.writeBlocking("Echo UART example\r\n", null);

    while (true) {
        // Wait for a byte to be received.
        const v = try USART1.readByteBlocking(null);
        // Echo the received byte.
        try USART1.writeByteBlocking(v, null);
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
