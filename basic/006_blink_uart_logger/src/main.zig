// Registers adresses are taken from CH32V003 reference manual.
const RCC_BASE: u32 = 0x40021000;
const GPIOC_BASE: u32 = 0x40011000;
const RCC_APB2PCENR: *volatile u32 = @ptrFromInt(RCC_BASE + 0x18);
const GPIOC_CFGLR: *volatile u32 = @ptrFromInt(GPIOC_BASE + 0x00);
const GPIOC_OUTDR: *volatile u32 = @ptrFromInt(GPIOC_BASE + 0x0C);

// Port bit offset for Port C.
const io_port_bit = 4;
const led_pin_num = 0;

// By default, the CPU frequency is 8MHz.
const cpu_freq: u32 = 8_000_000;
const uart_baud_rate: u32 = 115_200;

const std = @import("std");
const start = @import("start.zig");
const uart = @import("uart.zig");

comptime {
    // Import comptime definitions from start.zig.
    _ = start;
}

pub const std_options = std.Options{
    .log_level = .debug,
    .logFn = logFn,
};

// Use panic function from start.zig as panic function.
pub const panic = start.panic_log;

pub fn main() !void {
    RCC_APB2PCENR.* |= @as(u32, 1) << io_port_bit; // Enable Port clock.
    GPIOC_CFGLR.* &= ~(@as(u32, 0b1111) << led_pin_num * 4); // Clear all bits for pin.
    GPIOC_CFGLR.* |= @as(u32, 0b0011) << led_pin_num * 4; // Set push-pull output for pin.

    uart.USART1.setup(.{
        .cpu_frequency = cpu_freq,
        .baud_rate = uart_baud_rate,
    });

    _ = uart.USART1.writeBlocking("UART initialized\r\n");
    std.log.info("Logger initialized", .{});

    var count: u32 = 0;
    while (true) {
        // Toggle pin.
        GPIOC_OUTDR.* ^= @as(u16, 1 << led_pin_num);

        // Print counter value.
        std.log.info("Counter: {}", .{count});
        count += 1;

        // Test panic for demonstration.
        if (count > 10) {
            @panic("test panic message");
        }

        // Simple delay.
        var i: u32 = 0;
        while (i < 1_000_000) : (i += 1) {
            // ZIG please don't optimize this loop away.
            asm volatile ("" ::: "memory");
        }
    }
}

pub fn logFn(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    const prefix = comptime level.asText() ++ switch (scope) {
        .default => ": ",
        else => " (" ++ @tagName(scope) ++ "): ",
    };

    const w = uart.USART1.writer();
    w.print(prefix ++ format ++ "\r\n", args) catch {};
}
