const std = @import("std");
const config = @import("config");
const hal = @import("hal");

pub const interrupts: hal.interrupts.VectorTable = .{
    .SysTick = hal.time.sysTickHandler,
};

pub fn main() !void {
    const clock = hal.clock.setOrGet(.hsi_max);
    hal.time.init(clock);

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

    _ = try USART1.writeBlocking("Echo UART example\r\n", hal.time.Deadline.init(null));

    while (true) {
        // Wait for a byte to be received.
        const v = try USART1.readByteBlocking(hal.time.Deadline.init(null));
        // Echo the received byte.
        try USART1.writeByteBlocking(v, hal.time.Deadline.init(null));
    }
}
