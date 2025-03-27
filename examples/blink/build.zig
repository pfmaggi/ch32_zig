const std = @import("std");
const ch32_zig = @import("ch32_zig");

pub fn build(b: *std.Build) void {
    const ch32_dep = b.dependency("ch32_zig", .{});

    const name = "blink";
    const targets: []const ch32_zig.Target = &.{
        // You can specify a series of the chip.
        .{ .chip = .{ .series = .ch32v003 } },
        .{ .chip = .{ .series = .ch32v30x } },
        // Or a specific model.
        // .{ .chip = .{ .model = .ch32v003f4p6 } },
    };

    const optimize = b.option(
        std.builtin.OptimizeMode,
        "optimize",
        "Prioritize performance, safety, or binary size",
    ) orelse .ReleaseSmall;

    for (targets) |target| {
        const fw = ch32_zig.addFirmware(b, ch32_dep, .{
            .name = b.fmt("{s}_{s}", .{ name, target.chip.string() }),
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        });

        // Emit the bin file for flashing.
        const fw_bin = ch32_zig.installFirmware(b, fw, .{});
        ch32_zig.printFirmwareSize(b, fw_bin);

        // Emit the elf file for debugging.
        _ = ch32_zig.installFirmware(b, fw, .{ .format = .elf });
    }
}
