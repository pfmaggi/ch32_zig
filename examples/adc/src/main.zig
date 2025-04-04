const std = @import("std");
const config = @import("config");
const hal = @import("hal");
const svd = @import("svd");

pub fn main() !void {
    const clock = hal.clock.setOrGet(.hsi_max);
    hal.delay.init(clock);

    // Select LED pin based on chip series.
    const led = switch (config.chip.series) {
        .ch32v003 => hal.Pin.init(.GPIOC, 0),
        .ch32v103 => hal.Pin.init(.GPIOC, 0),
        .ch32v20x => hal.Pin.init(.GPIOA, 15), // nanoCH32V203 board
        .ch32v30x => hal.Pin.init(.GPIOA, 3), // nanoCH32V305 board
        // else => @compileError("Unsupported chip series"),
    };
    hal.port.enable(led.port);
    led.asOutput(.{ .speed = .max_50mhz, .mode = .push_pull });

    // Configure UART.
    // The default pins are:
    // For CH32V003: TX: PD5, RX: PD6.
    // For CH32V103, CH32V20x and CH32V30x: TX: PA9, RX: PA10.
    const USART1 = hal.Uart.init(.USART1, .{
        .mode = .tx,
    });
    // Runtime baud rate configuration.
    USART1.configureBaudRate(.{
        .peripheral_clock = switch (config.chip.series) {
            .ch32v003 => clock.hb,
            else => clock.pb2,
        },
        .baud_rate = 115_200,
    });

    // ADC.
    const RCC = svd.peripherals.RCC;
    const ADC1 = svd.peripherals.ADC1;

    RCC.CFGR0.modify(.{ .ADCPRE = 0 });
    RCC.APB2PCENR.modify(.{ .ADC1EN = 1 });

    // ADC pin.
    const adc_pin = hal.Pin.init(.GPIOD, 4);
    hal.port.enable(adc_pin.port);
    adc_pin.asInput(.analog);

    ADC1.RSQR1.raw = 0;
    ADC1.RSQR2.raw = 0;
    ADC1.RSQR3.raw = 7;

    // 3/9/15/30/43/57/73/241 cycles
    ADC1.SAMPTR2.write(.{ .SMP7 = 7 });

    ADC1.CTLR2.modify(.{
        .ADON = 1,
        .EXTSEL = 0b111, // SWSTART software trigger.
    });

    // Reset calibration
    ADC1.CTLR2.modify(.{ .RSTCAL = 1 });
    while (ADC1.CTLR2.read().RSTCAL == 1) {
        asm volatile ("" ::: "memory");
    }

    // Start calibration
    ADC1.CTLR2.modify(.{ .CAL = 1 });
    while (ADC1.CTLR2.read().CAL == 1) {
        asm volatile ("" ::: "memory");
    }

    _ = try USART1.writeBlocking("ADC example\r\n", null);

    var buf: [10]u8 = undefined;
    while (true) {
        led.toggle();
        hal.delay.ms(200);

        // Start.
        ADC1.CTLR2.modify(.{ .SWSTART = 1 });

        // Wait.
        while (ADC1.STATR.read().EOC == 0) {
            asm volatile ("" ::: "memory");
        }

        // Result.
        const v: u16 = @truncate(ADC1.RDATAR.raw);
        _ = try USART1.writeVecBlocking(&.{ "ADC: ", intToStr(&buf, v), "\r\n" }, null);
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
