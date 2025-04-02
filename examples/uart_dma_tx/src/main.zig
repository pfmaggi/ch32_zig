const std = @import("std");
const config = @import("config");
const hal = @import("hal");
const svd = @import("svd");

fn dmaSetup() void {
    const DMA1 = svd.peripherals.DMA1;

    // Enable clock for DMA and SRAM.
    svd.peripherals.RCC.AHBPCENR.modify(.{
        .DMA1EN = 1,
        .SRAMEN = 1,
    });

    // Disable DMA before setup.
    DMA1.CFGR4.write(.{ .EN = 0 });
    // Configure DMA.
    DMA1.CFGR4.write(.{
        .DIR = 1, // From Memory to Peripheral.
        .CIRC = 0, // Circular mode disabled.
        .PINC = 0, // Peripheral increment mode.
        .MINC = 1, // Memory increment mode.
        .PSIZE = 0, // Peripheral size 8 bits.
        .MSIZE = 0, // Memory size 8 bits.
        .PL = 0, // Low priority.
        .MEM2MEM = 0, // Memory to Peripheral mode.
    });
    // Set USART1 TX peripheral address.
    DMA1.PADDR4.raw = @intFromPtr(&svd.peripherals.USART1.DATAR);
}

fn dmaWrite(msg: []const u8) void {
    const DMA1 = svd.peripherals.DMA1;

    // Disbale DMA before set new message.
    DMA1.CFGR4.modify(.{ .EN = 0 });
    // Set transfer length.
    DMA1.CNTR4.raw = msg.len;
    // Set source address.
    DMA1.MADDR4.raw = @intFromPtr(msg.ptr);
    // Enable DMA.
    DMA1.CFGR4.modify(.{ .EN = 1 });
}

pub fn main() !void {
    const clock = hal.clock.setOrGet(.hsi_max);
    hal.delay.init(clock);

    // Configure UART.
    // The default pins are:
    // For CH32V003: TX: PD5, RX: PD6.
    // For CH32V103, CH32V20x and CH32V30x: TX: PA9, RX: PA10.
    const USART1 = hal.Uart.init(.USART1, .{
        .mode = .tx,
        .dma = .tx,
    });
    // Runtime baud rate configuration.
    USART1.configureBaudRate(.{
        .peripheral_clock = switch (config.chip.series) {
            .ch32v003 => clock.hb,
            else => clock.pb2,
        },
        .baud_rate = 115_200,
    });

    // Setup DMA for USART1 TX.
    dmaSetup();

    // Counter is 32 bits, so we need 10 bytes to store it,
    // because max value is 4294967295.
    var buf: [10]u8 = undefined;
    var msg_buf: [32]u8 = undefined;
    var w = std.io.fixedBufferStream(&msg_buf);
    const prefix = "Counter: ";
    const suffix = "\r\n";

    var counter: u32 = 0;
    while (true) {
        counter += 1;

        w.reset();

        // Convert counter to string.
        const counter_str = intToStr(&buf, counter);
        // Build message.
        _ = try w.write(prefix);
        _ = try w.write(counter_str);
        _ = try w.write(suffix);

        // Print counter to UART using DMA.
        dmaWrite(w.getWritten());

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
