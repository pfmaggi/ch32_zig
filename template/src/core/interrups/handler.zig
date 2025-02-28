const builtin = @import("builtin");

// pub const Handler = *const fn () callconv(.{ .riscv32_interrupt = .{.mode = .machine}}) void;
pub const Handler = *const fn () callconv(.C) noreturn;

pub fn unhandled() callconv(.C) noreturn {
    switch (builtin.mode) {
        .Debug, .ReleaseSafe => {
            @panic("unhandled interrupt: see mcause.");
        },
        .ReleaseSmall => @panic("UH IRQ"),
        .ReleaseFast => unreachable,
    }
}
