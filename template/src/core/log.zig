const std = @import("std");

pub fn nopFn(
    comptime _: std.log.Level,
    comptime _: @Type(.enum_literal),
    comptime _: []const u8,
    _: anytype,
) void {}
