const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    const name = "ch32v003_blink";
    const ch32v003_target = b.resolveTargetQuery(.{
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
    });

    const firmware = b.addExecutable(.{
        .name = name,
        .root_source_file = b.path("src/main.zig"),
        .target = ch32v003_target,
        .optimize = switch (optimize) {
            .Debug => .ReleaseSafe, // ch32v003 don't have enough flash memory for debug builds.
            else => optimize,
        },
        .strip = true,
        .single_threaded = true,
    });

    installFirmware(b, firmware, FirmwareFormat.elf);
    installFirmware(b, firmware, FirmwareFormat.bin);
    installFirmware(b, firmware, FirmwareFormat.@"asm");
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