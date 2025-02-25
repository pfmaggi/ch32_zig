const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const optimize003 = switch (optimize) {
        // ch32v003 don't have enough flash memory for debug builds.
        .Debug => .ReleaseSmall,
        else => optimize,
    };

    const firmware = addFirmware(b, .{
        .name = "ch32v003_blink",
        .mcu = ch32v003,
        .optimize = optimize003,
        .strip = false,
    });
    installFirmware(b, firmware, FirmwareFormat.elf);
    installFirmware(b, firmware, FirmwareFormat.bin);

    const firmwareStrip = addFirmware(b, .{
        .name = "ch32v003_blink",
        .mcu = ch32v003,
        .optimize = optimize003,
        .strip = true,
    });
    installFirmware(b, firmwareStrip, FirmwareFormat.@"asm");

    // Tests

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/tests.zig"),
    });

    const unit_tests_run = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run platform-independent tests");
    test_step.dependOn(&unit_tests_run.step);
}

const ch32v003 = MCU{
    .linkerScript = .{ .cwd_relative = "ld/ch32v003.ld" },
    .target = std.Target.Query{
        .cpu_arch = .riscv32,
        .cpu_model = .{
            .explicit = &std.Target.riscv.cpu.generic,
        },
        .cpu_features_add = std.Target.riscv.featureSet(&.{
            std.Target.riscv.Feature.@"32bit",
            std.Target.riscv.Feature.e,
            std.Target.riscv.Feature.c,
        }),
        .os_tag = .freestanding,
        .abi = .eabi,
    },
};

const MCU = struct {
    linkerScript: std.Build.LazyPath,
    target: std.Target.Query,
};

const FirmwareOptions = struct {
    name: []const u8,
    mcu: MCU,
    optimize: std.builtin.OptimizeMode,
    strip: ?bool,
};

fn addFirmware(b: *std.Build, config: FirmwareOptions) *std.Build.Step.Compile {
    const firmware = b.addExecutable(.{
        .name = config.name,
        .root_source_file = b.path("src/main.zig"),
        .target = b.resolveTargetQuery(config.mcu.target),
        .optimize = config.optimize,
        .strip = config.strip,
        .single_threaded = true,
        .linkage = .static,
    });
    firmware.bundle_compiler_rt = true;
    firmware.link_gc_sections = true;
    firmware.link_function_sections = true;
    firmware.link_data_sections = true;
    firmware.linker_script = config.mcu.linkerScript;

    return firmware;
}

fn installFirmware(b: *std.Build, compile: *std.Build.Step.Compile, format: FirmwareFormat) void {
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
