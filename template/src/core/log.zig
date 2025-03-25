const std = @import("std");

var writer: ?std.io.AnyWriter = null;

pub fn setWriter(w: ?std.io.AnyWriter) void {
    writer = w;
}

pub fn nopFn(
    comptime _: std.log.Level,
    comptime _: @Type(.enum_literal),
    comptime _: []const u8,
    _: anytype,
) void {}

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

    if (writer) |w| {
        w.print(prefix ++ format ++ "\r\n", args) catch {};
    }
}
