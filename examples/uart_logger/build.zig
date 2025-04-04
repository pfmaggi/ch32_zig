const std = @import("std");
const ch32 = @import("ch32");

pub fn build(b: *std.Build) void {
    const ch32_dep = b.dependency("ch32", .{});

    const name = "uart_logger";
    const targets: []const ch32.Target = &.{
        // You can specify a series of the chip.
        .{ .chip = .{ .series = .ch32v003 } },
        // .{ .chip = .{ .series = .ch32v103 } },
        .{ .chip = .{ .series = .ch32v20x } },
        .{ .chip = .{ .series = .ch32v30x } },
        // Or a specific model.
        // .{ .chip = .{ .model = .ch32v003f4p6 } },
    };

    //      ┌──────────────────────────────────────────────────────────┐
    //      │                          Build                           │
    //      └──────────────────────────────────────────────────────────┘
    const optimize = b.option(
        std.builtin.OptimizeMode,
        "optimize",
        "Prioritize performance, safety, or binary size",
    ) orelse .ReleaseSmall;

    for (targets) |target| {
        const fw = ch32.addFirmware(b, ch32_dep, .{
            .name = b.fmt("{s}_{s}", .{ name, target.chip.string() }),
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        });

        // Emit the bin file for flashing.
        const fw_bin = ch32.installFirmware(b, fw, .{});
        ch32.printFirmwareSize(b, fw_bin);

        // Emit the elf file for debugging.
        _ = ch32.installFirmware(b, fw, .{ .format = .elf });
    }

    //      ┌──────────────────────────────────────────────────────────┐
    //      │                           Test                           │
    //      └──────────────────────────────────────────────────────────┘
    const native_target = b.standardTargetOptions(.{});
    const test_step = b.step("test", "Run platform-independent tests");
    for (targets) |target| {
        const fw_test = ch32.addFirmwareTest(b, ch32_dep, native_target, .{
            .name = b.fmt("{s}_{s}", .{ name, target.chip.string() }),
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = .Debug,
        });
        const unit_tests_run = b.addRunArtifact(fw_test);
        test_step.dependOn(&unit_tests_run.step);
    }

    //      ┌──────────────────────────────────────────────────────────┐
    //      │                          Clean                           │
    //      └──────────────────────────────────────────────────────────┘
    const clean_step = b.step("clean", "Clean up");
    clean_step.dependOn(&b.addRemoveDirTree(.{ .cwd_relative = b.install_path }).step);
    clean_step.dependOn(&b.addRemoveDirTree(.{ .cwd_relative = b.pathFromRoot(".zig-cache") }).step);
}
