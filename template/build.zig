const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.option(
        std.builtin.OptimizeMode,
        "optimize",
        "Prioritize performance, safety, or binary size",
    ) orelse .ReleaseSmall;

    const name = "template";
    const targets: []const Target = &.{
        .{ .chip = .{ .model = .CH32V003F4P6 } },
        .{ .chip = .{ .series = .CH32V30x } },
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

const ChipSeries = enum {
    CH32V003,
    CH32V30x,

    fn minimalModel(self: ChipSeries) ChipModel {
        return switch (self) {
            .CH32V003 => .CH32V003J4M6,
            .CH32V30x => .CH32V305FBP6,
        };
    }

    fn target(self: ChipSeries) std.Target.Query {
        const qingkev2a = std.Target.riscv.featureSet(&.{
            std.Target.riscv.Feature.@"32bit",
            std.Target.riscv.Feature.e,
            std.Target.riscv.Feature.c,
        });

        const qingkev4f = std.Target.riscv.featureSet(&.{
            std.Target.riscv.Feature.@"32bit",
            std.Target.riscv.Feature.i,
            std.Target.riscv.Feature.m,
            std.Target.riscv.Feature.a,
            std.Target.riscv.Feature.f,
            std.Target.riscv.Feature.c,
        });

        const cpu_features = switch (self) {
            .CH32V003 => qingkev2a,
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

    fn string(self: ChipSeries) []const u8 {
        return @tagName(self);
    }
};

const ChipModel = enum {
    // CH32V003 series
    CH32V003F4P6, // 16K / 2K / TSSOP20 (18 GPIO)
    CH32V003F4U6, // 16K / 2K / QFN20 (18 GPIO)
    CH32V003A4M6, // 16K / 2K / SOP16 (14 GPIO)
    CH32V003J4M6, // 16K / 2K / SOP8 (6 GPIO)
    // CH32V30x series
    CH32V305FBP6, // 128K / 32K / TSSOP20 (17 GPIO)
    CH32V305RBT6, // 128K / 32K / LQFP64M (51 GPIO)

    fn series(self: ChipModel) ChipSeries {
        return switch (self) {
            .CH32V003F4P6, .CH32V003F4U6, .CH32V003A4M6, .CH32V003J4M6 => .CH32V003,
            .CH32V305FBP6, .CH32V305RBT6 => .CH32V30x,
        };
    }

    fn linkScript(self: ChipModel, b: *std.Build) std.Build.LazyPath {
        const name = switch (self) {
            .CH32V003F4P6, .CH32V003F4U6, .CH32V003A4M6, .CH32V003J4M6 => "ch32v003_16k_2k.ld",
            .CH32V305FBP6, .CH32V305RBT6 => "ch32v30x_128k_32k.ld",
        };

        return b.path(b.pathJoin(&.{ "ld", name }));
    }

    fn target(self: ChipModel) std.Target.Query {
        return self.series().target();
    }

    fn string(self: ChipModel) []const u8 {
        return @tagName(self);
    }
};

const Chip = union(enum) {
    series: ChipSeries,
    model: ChipModel,

    fn linkScript(chip: Chip, b: *std.Build) std.Build.LazyPath {
        return switch (chip) {
            .model => |v| v.linkScript(b),
            .series => |v| v.minimalModel().linkScript(b),
        };
    }

    fn target(chip: Chip) std.Target.Query {
        return switch (chip) {
            .model => |v| v.target(),
            .series => |v| v.target(),
        };
    }

    fn string(chip: Chip) []const u8 {
        return switch (chip) {
            .model => |v| v.string(),
            .series => |v| v.string(),
        };
    }

    fn as_series(chip: Chip) ChipSeries {
        return switch (chip) {
            .model => |v| v.series(),
            .series => |v| v,
        };
    }

    fn as_model(chip: Chip) ChipModel {
        return switch (chip) {
            .model => |v| v,
            .series => |v| v.minimalModel(),
        };
    }
};

const Target = struct {
    chip: Chip,
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

fn buildConfigOptions(b: *std.Build, name: []const u8, chip: Chip) *std.Build.Step.Options {
    const config_options = b.addOptions();
    config_options.addOption([]const u8, "name", name);
    config_options.addOption(ChipModel, "chip_model", chip.as_model());
    config_options.addOption(ChipSeries, "chip_series", chip.as_series());
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
    firmware.linker_script = options.target.chip.linkScript(b);

    return firmware;
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
