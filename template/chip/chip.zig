const std = @import("std");
pub const Series = @import("series.zig").Series;
pub const Model = @import("model.zig").Model;

pub const Chip = union(enum) {
    series: Series,
    model: Model,

    pub fn linkScript(chip: Chip, b: *std.Build) std.Build.LazyPath {
        return switch (chip) {
            .model => |v| v.linkScript(b),
            .series => |v| v.minimalModel().linkScript(b),
        };
    }

    pub fn target(chip: Chip) std.Target.Query {
        return switch (chip) {
            .model => |v| v.target(),
            .series => |v| v.target(),
        };
    }

    pub fn string(chip: Chip) []const u8 {
        return switch (chip) {
            .model => |v| v.string(),
            .series => |v| v.string(),
        };
    }

    pub fn as_series(chip: Chip) Series {
        return switch (chip) {
            .model => |v| v.series(),
            .series => |v| v,
        };
    }

    pub fn as_model(chip: Chip) Model {
        return switch (chip) {
            .model => |v| v,
            .series => |v| v.minimalModel(),
        };
    }
};
