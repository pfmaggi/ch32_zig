const std = @import("std");
const app = @import("app");
const builtin = @import("builtin");

pub const svd = @import("svd");
pub const hal = @import("hal");
const startup = @import("startup.zig");

comptime {
    if (!builtin.is_test) {
        asm (
            \\.section .init
            \\j _start
        );

        @export(&startup.start, .{
            .name = "_start",
        });

        @export(&exported_vector_table, .{
            .name = "vector_table",
            .section = ".init",
        });

        // Execute comptime code.
        _ = app;

        if (@hasDecl(app, "std_options")) {
            @compileError("std_options is not supported, use ch32_options instead");
        }
    }
}

pub const Options = struct {
    /// The current log level.
    log_level: std.log.Level = std.log.default_level,
    log_scope_levels: []const std.log.ScopeLevel = &.{},
    logFn: fn (
        comptime message_level: std.log.Level,
        comptime scope: @TypeOf(.enum_literal),
        comptime format: []const u8,
        args: anytype,
    ) void = hal.log.nopFn,
    fmt_max_depth: usize = std.fmt.default_max_depth,
    unhandledInterruptFn: fn () callconv(hal.interrupts.call_conv) void = hal.interrupts.unhandled,
};

pub const ch32_options: Options = if (@hasDecl(app, "ch32_options")) app.ch32_options else .{};

pub const std_options: std.Options = .{
    .log_level = ch32_options.log_level,
    .log_scope_levels = ch32_options.log_scope_levels,
    .logFn = ch32_options.logFn,
    .fmt_max_depth = ch32_options.fmt_max_depth,
};

pub const panic = if (@hasDecl(app, "panic")) app.panic else hal.panic.nop;

pub const interrupts: hal.interrupts.VectorTable = if (@hasDecl(app, "interrupts")) app.interrupts else .{};

const exported_vector_table = hal.interrupts.generateExportedVectorTable(interrupts, ch32_options.unhandledInterruptFn);
