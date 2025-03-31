const std = @import("std");
const builtin = @import("builtin");
const config = @import("config");
const svd = @import("svd");

pub const call_conv: std.builtin.CallingConvention = if (builtin.cpu.arch != .riscv32) .c else .{ .riscv32_interrupt = .{ .mode = .machine } };
pub const Handler = *const fn () callconv(call_conv) void;

pub fn unhandled() callconv(call_conv) void {
    switch (builtin.mode) {
        .Debug, .ReleaseSafe => {
            @panic("unhandled interrupt: see mcause.");
        },
        .ReleaseFast, .ReleaseSmall => @panic("UH IRQ"),
    }
}

pub const interrupts = svd.interrupts;

pub const VectorTable = interrupts.VectorTable;

pub inline fn enable() void {
    asm volatile ("csrsi mstatus, 0b1000");
}

pub inline fn disable() void {
    asm volatile ("csrci mstatus, 0b1000");
}

pub inline fn isEnabled() bool {
    const mstatus = asm ("csrr %[out], mstatus"
        : [out] "=r" (-> u32),
    );
    return (mstatus & 0b1000) != 0;
}

pub fn generateExportedVectorTable(list: VectorTable, unhandledFn: Handler) ExportedVectorTableType {
    var vector_table: ExportedVectorTableType = undefined;
    for (@typeInfo(ExportedVectorTableType).@"struct".fields) |field| {
        if (std.mem.startsWith(u8, field.name, "_")) {
            @field(vector_table, field.name) = 0;
            continue;
        }
        const handler: Handler = @field(list, field.name) orelse unhandledFn;
        @field(vector_table, field.name) = handler;
    }

    return vector_table;
}

const ExportedVectorTableType = createExportedVectorTableType();

fn createExportedVectorTableType() type {
    @setEvalBranchQuota(100_000);

    const offset = 1;
    const interrupts_list = @typeInfo(svd.interrupts).@"enum".fields;
    const last_interrupt = interrupts_list[interrupts_list.len - 1];
    const last_interrupt_idx = last_interrupt.value;

    var fields: [last_interrupt_idx + 1 - offset]std.builtin.Type.StructField = undefined;
    for (&fields, offset..) |*field, idx| {
        // Find name of the interrupt by its number.
        var name: ?[:0]const u8 = null;
        for (interrupts_list, 0..) |decl, decl_idx| {
            if (decl_idx == interrupts_list.len - 1) break;

            if (decl.value == idx) {
                name = decl.name;
                break;
            }
        }

        var buf: [10]u8 = undefined;
        const l = std.fmt.formatIntBuf(&buf, idx, 10, .lower, .{});
        const idx_str = buf[0..l];

        const field_type = if (name != null) Handler else std.meta.Int(.unsigned, @alignOf(Handler) * 8);
        field.* = .{
            .name = name orelse "_reserved" ++ idx_str,
            .type = field_type,
            .default_value_ptr = null,
            .is_comptime = false,
            .alignment = @alignOf(field_type),
        };
    }

    return @Type(.{
        .@"struct" = .{
            .layout = .@"extern",
            .fields = &fields,
            .decls = &.{},
            .is_tuple = false,
        },
    });
}

test generateExportedVectorTable {
    const v = comptime generateExportedVectorTable(.{
        .SysTick = testSysTickHandler,
    }, unhandled);
    try std.testing.expectEqual(0, v._reserved4);
    try std.testing.expectEqual(unhandled, v.NMI);
    try std.testing.expectEqual(testSysTickHandler, v.SysTick);
}

fn testSysTickHandler() callconv(call_conv) void {}
