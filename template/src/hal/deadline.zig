const std = @import("std");
const config = @import("config");
const svd = @import("svd");

pub const DeadlineFn = fn () bool;

// FIXME: refactoring is needed because the type remembers the number and
//  the counter does not reset on subsequent calls.
pub fn simple(count: u32) ?DeadlineFn {
    return struct {
        var counter = count;
        pub fn reset() void {
            counter = count;
        }
        pub fn check() bool {
            if (counter == 0) {
                reset();
                return true;
            }

            counter -= 1;
            return false;
        }
    }.check;
}
