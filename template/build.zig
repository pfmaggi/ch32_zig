const std = @import("std");
const chip = @import("chip/chip.zig");

pub fn build(b: *std.Build) void {
    const optimize = b.option(
        std.builtin.OptimizeMode,
        "optimize",
        "Prioritize performance, safety, or binary size",
    ) orelse .ReleaseSmall;

    const name = "template";
    const targets: []const Target = &.{
        .{ .chip = .{ .model = .ch32v003f4p6 } },
        // .{ .chip = .{ .series = .ch32v30x } },
    };

    //      ┌──────────────────────────────────────────────────────────┐
    //      │                          Build                           │
    //      └──────────────────────────────────────────────────────────┘
    for (targets) |target| {
        const options = FirmwareOptions{
            .name = b.fmt("{s}_{s}", .{ name, target.chip.string() }),
            .target = target,
            .optimize = optimize,
        };
        buildAndInstallFirmware(b, options);
    }

    //      ┌──────────────────────────────────────────────────────────┐
    //      │                           Test                           │
    //      └──────────────────────────────────────────────────────────┘
    const test_step = b.step("test", "Run platform-independent tests");
    for (targets) |target| {
        const unit_tests = b.addTest(.{
            .name = b.fmt("{s}_{s}_test", .{ name, target.chip.string() }),
            .root_source_file = b.path("src/main.zig"),
            .test_runner = .{ .path = b.path("test_runner.zig"), .mode = .simple },
        });
        const config_options = buildConfigOptions(b, unit_tests.name, target.chip);
        unit_tests.root_module.addImport("config", config_options.createModule());
        unit_tests.root_module.addImport("svd", svd_module(b, target));

        const unit_tests_run = b.addRunArtifact(unit_tests);
        test_step.dependOn(&unit_tests_run.step);
    }

    //      ┌──────────────────────────────────────────────────────────┐
    //      │                          Check                           │
    //      └──────────────────────────────────────────────────────────┘
    // ZLS magic: https://zigtools.org/zls/guides/build-on-save/
    const check_step = b.step("check", "Check if compiles");
    for (targets) |target| {
        const options = FirmwareOptions{
            .name = b.fmt("{s}_{s}_check", .{ name, target.chip.string() }),
            .target = target,
            .optimize = optimize,
        };
        const fw = addFirmware(b, options);
        check_step.dependOn(&fw.step);
    }
}

const Target = struct {
    chip: chip.Chip,
    // Override the default linker script for the chip.
    linker_script: ?std.Build.LazyPath = null,
};

const FirmwareOptions = struct {
    name: []const u8 = "",
    target: Target,
    optimize: std.builtin.OptimizeMode = .ReleaseSmall,
    // If not provided, the default is "src/main.zig"
    root_source_file: ?std.Build.LazyPath = null,
};

fn buildAndInstallFirmware(
    b: *std.Build,
    options: FirmwareOptions,
) void {
    const firmware = addFirmware(b, options);
    firmware.root_module.strip = true;
    _ = installFirmware(b, firmware, FirmwareFormat.elf);
    _ = installFirmware(b, firmware, FirmwareFormat.@"asm");
    const firmware_bin = installFirmware(b, firmware, FirmwareFormat.bin);
    printFirmwareSize(b, firmware_bin);

    // Save debug info for GDB.
    const firmware_no_strip = addFirmware(b, .{
        .name = b.fmt("{s}_no_strip", .{firmware.name}),
        .target = options.target,
        .optimize = options.optimize,
        .root_source_file = options.root_source_file,
    });
    firmware_no_strip.root_module.strip = false;
    _ = installFirmware(b, firmware_no_strip, FirmwareFormat.elf);
}

fn buildConfigOptions(b: *std.Build, name: []const u8, c: chip.Chip) *std.Build.Step.Options {
    const config_options = b.addOptions();
    config_options.addOption([]const u8, "name", name);
    config_options.addOption(chip.Model, "chip_model", c.as_model());
    config_options.addOption(chip.Series, "chip_series", c.as_series());
    config_options.addOption(chip.Class, "chip_class", c.as_class());
    return config_options;
}

fn addFirmware(b: *std.Build, options: FirmwareOptions) *std.Build.Step.Compile {
    const config_options = buildConfigOptions(b, options.name, options.target.chip);

    const fw = b.createModule(.{
        .root_source_file = options.root_source_file orelse b.path("src/main.zig"),
        .target = b.resolveTargetQuery(options.target.chip.target()),
        .optimize = options.optimize,
        .single_threaded = true,
        .imports = &.{
            .{
                .name = "config",
                .module = config_options.createModule(),
            },
            .{
                .name = "svd",
                .module = svd_module(b, options.target),
            },
        },
    });

    const firmware = b.addExecutable(.{
        .name = options.name,
        .linkage = .static,
        .root_module = fw,
    });
    firmware.bundle_compiler_rt = true;
    firmware.link_gc_sections = true;
    firmware.link_function_sections = true;
    firmware.link_data_sections = true;
    firmware.linker_script = options.target.linker_script orelse options.target.chip.linkScript(b);

    return firmware;
}

fn svd_module(b: *std.Build, target: Target) *std.Build.Module {
    const svd_path = b.path("svd").join(b.allocator, b.fmt("{s}.zig", .{target.chip.as_series().svd_name()})) catch @panic("OOM");
    const module = b.createModule(.{
        .root_source_file = svd_path,
        .target = b.resolveTargetQuery(target.chip.target()),
        .single_threaded = true,
    });

    return module;
}

const FirmwareFormat = union(enum) {
    elf,
    bin,
    @"asm",

    fn ext(format: FirmwareFormat) []const u8 {
        return switch (format) {
            .elf => "elf",
            .bin => "bin",
            .@"asm" => "s",
        };
    }
};

fn installFirmware(b: *std.Build, compile: *std.Build.Step.Compile, format: FirmwareFormat) std.Build.LazyPath {
    const basename = b.fmt("{s}.{s}", .{ compile.name, format.ext() });

    const path = switch (format) {
        .elf => compile.getEmittedBin(),
        .bin => b.addObjCopy(compile.getEmittedBin(), .{
            .basename = basename,
            .format = .bin,
        }).getOutput(),
        .@"asm" => compile.getEmittedAsm(),
    };

    const install = b.addInstallFileWithDir(path, .{ .custom = "firmware" }, basename);
    b.getInstallStep().dependOn(&install.step);

    return path;
}

const FirmwareSize = struct {
    step: std.Build.Step,
    source: std.Build.LazyPath,
};

fn printFirmwareSize(b: *std.Build, file: std.Build.LazyPath) void {
    const size = b.allocator.create(FirmwareSize) catch @panic("OOM");
    size.* = .{
        .step = std.Build.Step.init(.{
            .id = .install_file,
            .name = b.fmt("print {s} size", .{file.getDisplayName()}),
            .owner = b,
            .makeFn = makeFirmwareSize,
        }),
        .source = file,
    };

    file.addStepDependencies(&size.step);
    b.getInstallStep().dependOn(&size.step);
}

fn makeFirmwareSize(step: *std.Build.Step, options: std.Build.Step.MakeOptions) !void {
    _ = options;
    const b = step.owner;

    const self: *FirmwareSize = @fieldParentPtr("step", step);

    const full_src_path = self.source.getPath2(b, step);
    const name = std.fs.path.basename(full_src_path);

    const file = std.fs.openFileAbsolute(full_src_path, .{ .mode = .read_only }) catch |err| {
        return step.fail("unable to open file from '{s}': {s}", .{
            full_src_path, @errorName(err),
        });
    };
    const stat = file.stat() catch |err| {
        return step.fail("unable to stat file from '{s}': {s}", .{
            full_src_path, @errorName(err),
        });
    };
    const size = stat.size;

    std.log.info("{s} size: {d} bytes", .{ name, size });
}
