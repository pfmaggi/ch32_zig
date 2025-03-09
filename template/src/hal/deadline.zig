const std = @import("std");
const config = @import("config");
const svd = @import("svd");

pub const DeadlineFn = fn () bool;

pub fn simple(count: u32) ?DeadlineFn {
    return struct {
        var counter = count;
        pub fn check() bool {
            counter -= 1;
            return counter == 0;
        }
    }.check;
}
