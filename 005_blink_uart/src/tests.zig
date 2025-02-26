const std = @import("std");
const testing = std.testing;

pub fn setBitsAuto(value: *u32, comptime pos: u8, comptime width: u8, bits: u32) void {
    const mask: u32 = ((1 << width) - 1) << pos;
    value.* = (value.* & ~mask) | ((bits << pos) & mask);
}

test "setBitsAuto" {
    var v: u32 = 0x00000FFF;
    try testing.expectFmt("0b0000111111111111", "0b{b:0>16}", .{v});

    setBitsAuto(&v, 16, 1, 1);
    setBitsAuto(&v, 4, 4, 0);

    try testing.expectFmt("0b10000111100001111", "0b{b:0>16}", .{v});
}
