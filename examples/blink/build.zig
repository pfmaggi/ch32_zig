const std = @import("std");
const ch32_zig = @import("ch32_zig");

pub fn build(b: *std.Build) void {
    const ch32_dep = b.dependency("ch32_zig", .{});

    const name = "blink";
    const targets: []const ch32_zig.Target = &.{
        // You can specify a specific model or series of the chip.
        .{ .chip = .{ .model = .ch32v003f4p6 } },
        // .{ .chip = .{ .series = .ch32v103 } },
        // .{ .chip = .{ .series = .ch32v20x } },
        // .{ .chip = .{ .series = .ch32v30x } },
    };

    const optimize = b.option(
        std.builtin.OptimizeMode,
        "optimize",
        "Prioritize performance, safety, or binary size",
    ) orelse .ReleaseSmall;

    for (targets) |target| {
        // TODO
        // const fw = ch32_zig.createFirmware(b, .{
        //     .name = name,
        //     .target = target,
        //     .optimize = null,
        // });
        // fw.install();
        // fw.printSize();

        const options = ch32_zig.FirmwareOptions{
            .name = b.fmt("{s}_{s}", .{ name, target.chip.string() }),
            .target = target,
            .optimize = optimize,
            .root_source_file = b.path("src/main.zig"),
        };
        ch32_zig.buildAndInstallFirmware(b, ch32_dep, options);
    }
}
