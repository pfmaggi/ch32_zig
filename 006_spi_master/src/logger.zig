const std = @import("std");
const uart = @import("uart.zig");

var logger: ?uart.UART.Writer = null;

pub fn set(writer: ?uart.UART) void {
    if (writer) |w| {
        logger = w.writer();
        return;
    }

    logger = null;
}

pub fn logFn(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    const level_prefix = comptime "[{}.{:0>3}] " ++ level.asText();
    const prefix = comptime level_prefix ++ switch (scope) {
        .default => ": ",
        else => " (" ++ @tagName(scope) ++ "): ",
    };

    if (logger) |w| {
        // const millis = systick.millis(); // FIXME
        const millis = 12345;
        const seconds = millis / std.time.ms_per_s;
        const milliseconds = millis % std.time.ms_per_s;

        w.print(prefix ++ format ++ "\r\n", .{ seconds, milliseconds } ++ args) catch {        };
    }
}
