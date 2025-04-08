const std = @import("std");
const ch32 = @import("ch32");

const I2cModeOption = enum {
    master,
    slave,
};

pub fn build(b: *std.Build) void {
    const ch32_dep = b.dependency("ch32", .{});

    const name = "i2c_blocking";
    const targets: []const ch32.Target = &.{
        // You can specify a series of the chip.
        .{ .chip = .{ .series = .ch32v003 } },
        // .{ .chip = .{ .series = .ch32v103 } },
        // .{ .chip = .{ .series = .ch32v20x } },
        // .{ .chip = .{ .series = .ch32v30x } },
        // Or a specific model.
        // .{ .chip = .{ .model = .ch32v003f4p6 } },
    };
    const i2c_modes: []const I2cModeOption = &.{ .master, .slave };

    //      ┌──────────────────────────────────────────────────────────┐
    //      │                          Build                           │
    //      └──────────────────────────────────────────────────────────┘
    const optimize = b.option(
        std.builtin.OptimizeMode,
        "optimize",
        "Prioritize performance, safety, or binary size",
    ) orelse .ReleaseSmall;

    for (targets) |target| {
        for (i2c_modes) |i2c_mode| {
            const config_options = ch32.createConfigOptions(b, name, target.chip);
            config_options.addOption(I2cModeOption, "i2c_mode", i2c_mode);

            const fw = ch32.addFirmware(b, ch32_dep, .{
                .name = b.fmt("{s}_{s}_{s}", .{ name, target.chip.string(), @tagName(i2c_mode) }),
                .root_source_file = b.path("src/main.zig"),
                .target = target,
                .optimize = optimize,
                .config_options = config_options,
            });

            // Emit the bin file for flashing.
            const fw_bin = ch32.installFirmware(b, fw, .{});
            ch32.printFirmwareSize(b, fw_bin);

            // Emit the elf file for debugging.
            _ = ch32.installFirmware(b, fw, .{ .format = .elf });
        }
    }

    //      ┌──────────────────────────────────────────────────────────┐
    //      │                           Test                           │
    //      └──────────────────────────────────────────────────────────┘
    const native_target = b.standardTargetOptions(.{});
    const test_step = b.step("test", "Run platform-independent tests");
    for (targets) |target| {
        for (i2c_modes) |i2c_mode| {
            const config_options = ch32.createConfigOptions(b, name, target.chip);
            config_options.addOption(I2cModeOption, "i2c_mode", i2c_mode);

            const fw_test = ch32.addFirmwareTest(b, ch32_dep, native_target, .{
                .name = b.fmt("{s}_{s}_{s}", .{ name, target.chip.string(), @tagName(i2c_mode) }),
                .root_source_file = b.path("src/main.zig"),
                .target = target,
                .optimize = .Debug,
                .config_options = config_options,
            });
            const unit_tests_run = b.addRunArtifact(fw_test);
            test_step.dependOn(&unit_tests_run.step);
        }
    }

    //      ┌──────────────────────────────────────────────────────────┐
    //      │                          Clean                           │
    //      └──────────────────────────────────────────────────────────┘
    const clean_step = b.step("clean", "Clean up");
    clean_step.dependOn(&b.addRemoveDirTree(.{ .cwd_relative = b.install_path }).step);
    clean_step.dependOn(&b.addRemoveDirTree(.{ .cwd_relative = b.pathFromRoot(".zig-cache") }).step);
}
