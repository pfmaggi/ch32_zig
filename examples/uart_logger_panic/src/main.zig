const std = @import("std");
const config = @import("config");
const hal = @import("hal");
const ch32 = @import("ch32");

// Add panic handler to the logger.
pub const panic = hal.panic.log;

pub const ch32_options: ch32.Options = .{
    .log_level = .debug,
    .logFn = hal.log.logFn,
};

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
    hal.log.setWriter(USART1.writer().any());

    std.log.info("Hello, World!", .{});

    var counter: u32 = 0;
    while (true) {
        counter += 1;

        if (counter == 10) {
            // Trigger a panic.
            @panic("Counter reached 10");
        }

        // Print counter to UART.
        std.log.info("Counter: {}", .{counter});

        hal.delay.ms(1000);
    }
}
