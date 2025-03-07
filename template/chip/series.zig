const std = @import("std");
const Model = @import("model.zig").Model;

pub const Series = enum {
    CH32V003,
    CH32V103,
    CH32V20x,
    CH32V30x,

    /// Minimal model for the series by Flash, RAM size and GPIO count.
    pub fn minimalModel(self: Series) Model {
        return switch (self) {
            .CH32V003 => .CH32V003J4M6,
            .CH32V103 => .CH32V103C6T6,
            .CH32V20x => .CH32V203F6P6,
            .CH32V30x => .CH32V305FBP6,
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
            .CH32V003 => qingkev2a,
            .CH32V103 => qingkev3,
            .CH32V20x => qingkev4b,
            .CH32V30x => qingkev4f,
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
            .CH32V003 => "CH32V003",
            .CH32V103 => "CH32V103",
            .CH32V20x => "CH32V20x",
            .CH32V30x => "CH32V30x",
        };
    }
};
