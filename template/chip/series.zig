const std = @import("std");
const Model = @import("model.zig").Model;

pub const Series = enum {
    ch32v003,
    ch32v103,
    ch32v20x,
    ch32v30x,

    /// Minimal model for the series by Flash, RAM size and GPIO count.
    pub fn minimalModel(self: Series) Model {
        return switch (self) {
            .ch32v003 => .ch32v003j4m6,
            .ch32v103 => .ch32v103c6t6,
            .ch32v20x => .ch32v203f6p6,
            .ch32v30x => .ch32v305fbp6,
        };
    }

    pub fn target(self: Series) std.Target.Query {
        const qingkev2a = std.Target.riscv.featureSet(&.{
            std.Target.riscv.Feature.@"32bit",
            std.Target.riscv.Feature.e,
            std.Target.riscv.Feature.c,
            // WCH/QingKe additional compressed opcodes
            std.Target.riscv.Feature.xwchc,
        });

        const qingkev3 = std.Target.riscv.featureSet(&.{
            std.Target.riscv.Feature.@"32bit",
            std.Target.riscv.Feature.i,
            std.Target.riscv.Feature.m,
            std.Target.riscv.Feature.a,
            std.Target.riscv.Feature.c,
            // WCH/QingKe additional compressed opcodes
            std.Target.riscv.Feature.xwchc,
        });

        const qingkev4b = std.Target.riscv.featureSet(&.{
            std.Target.riscv.Feature.@"32bit",
            std.Target.riscv.Feature.i,
            std.Target.riscv.Feature.m,
            std.Target.riscv.Feature.a,
            std.Target.riscv.Feature.c,
            // WCH/QingKe additional compressed opcodes
            std.Target.riscv.Feature.xwchc,
        });

        const qingkev4f = std.Target.riscv.featureSet(&.{
            std.Target.riscv.Feature.@"32bit",
            std.Target.riscv.Feature.i,
            std.Target.riscv.Feature.m,
            std.Target.riscv.Feature.a,
            std.Target.riscv.Feature.f,
            std.Target.riscv.Feature.c,
            // WCH/QingKe additional compressed opcodes
            std.Target.riscv.Feature.xwchc,
        });

        const cpu_features = switch (self) {
            .ch32v003 => qingkev2a,
            .ch32v103 => qingkev3,
            .ch32v20x => qingkev4b,
            .ch32v30x => qingkev4f,
        };

        return .{
            .cpu_arch = .riscv32,
            .cpu_model = .{ .explicit = &std.Target.riscv.cpu.generic },
            .cpu_features_add = cpu_features,
            .os_tag = .freestanding,
            .abi = .eabi,
        };
    }

    pub fn string(self: Series) []const u8 {
        return @tagName(self);
    }

    pub fn svd_name(self: Series) []const u8 {
        return switch (self) {
            .ch32v003 => "CH32V003",
            .ch32v103 => "CH32V103",
            .ch32v20x => "CH32V20X",
            .ch32v30x => "CH32V30X",
        };
    }
};
