const std = @import("std");
const builtin = @import("builtin");

// zig build --release=fast
// MacOS: install XCode
// Linux: apt install libudev-dev
pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});

    // Minichlink only works with ReleaseFast optimization mode.
    const optimize = std.builtin.OptimizeMode.ReleaseFast;
    // const optimize = b.standardOptimizeOption(.{});

    const minichlink = try buildMinichlink(b, .exe, target, optimize);
    b.installArtifact(minichlink);

    const minichlink_lib = try buildMinichlink(b, .lib, target, optimize);
    const install_minichlink_lib = b.addInstallArtifact(minichlink_lib, .{});
    const build_lib = b.step("lib", "Build the minichlink as library");
    build_lib.dependOn(&install_minichlink_lib.step);
}

fn buildMinichlink(
    b: *std.Build,
    kind: std.Build.Step.Compile.Kind,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) !*std.Build.Step.Compile {
    const libusb_dep = b.dependency("libusb", .{});
    const libusb = createLibusb(b, libusb_dep, target, optimize);

    const minichlink_dep = b.dependency("ch32v003fun", .{});
    const minichlink = try createMinichlink(b, minichlink_dep, kind, target, optimize);
    minichlink.linkLibrary(libusb);

    return minichlink;
}

fn createMinichlink(
    b: *std.Build,
    dep: *std.Build.Dependency,
    kind: std.Build.Step.Compile.Kind,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) !*std.Build.Step.Compile {
    const root_path = dep.path("minichlink");
    const exe = std.Build.Step.Compile.create(b, .{
        .name = "minichlink",
        .version = .{ .major = 1, .minor = 0, .patch = 0, .pre = "rc.2" },
        .kind = kind,
        .linkage = .dynamic,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });

    if (kind == .lib) {
        // exe.root_module.addCMacro("MINICHLINK_AS_LIBRARY", "1");
        exe.installHeader(root_path.path(b, "minichlink.h"), "minichlink.h");
    }

    exe.linkLibC();
    exe.addIncludePath(root_path);
    exe.addCSourceFiles(.{
        .root = root_path,
        .files = &.{
            "minichlink.c",
            "pgm-wch-linke.c",
            "pgm-esp32s2-ch32xx.c",
            "nhc-link042.c",
            "ardulink.c",
            "serial_dev.c",
            "pgm-b003fun.c",
            "minichgdb.c",
        },
    });
    exe.root_module.addCMacro("MINICHLINK", "1");
    exe.root_module.addCMacro("CH32V003", "1");
    // Without this, the build fails with "error: unknown register name 'a5' in asm"
    exe.root_module.addCMacro("__DELAY_TINY_DEFINED__", "1");

    switch (target.result.os.tag) {
        .macos => {
            exe.root_module.addCMacro("__MACOSX__", "1");
            exe.linkFramework("CoreFoundation");
            exe.linkFramework("IOKit");
        },
        .linux, .netbsd, .openbsd => {
            const rules = b.addInstallBinFile(try root_path.join(b.allocator, "99-minichlink.rules"), "99-minichlink.rules");
            exe.step.dependOn(&rules.step);
        },
        .windows => {
            exe.root_module.addCMacro("_WIN32_WINNT", "0x0600");
            exe.addLibraryPath(dep.path("minichlink"));
            exe.linkSystemLibrary("setupapi");
            exe.linkSystemLibrary("ws2_32");
        },
        else => {},
    }

    return exe;
}

fn defineBool(b: bool) ?u1 {
    return if (b) 1 else null;
}

fn createLibusb(
    b: *std.Build,
    dep: *std.Build.Dependency,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) *std.Build.Step.Compile {
    const is_posix = target.result.os.tag != .windows;
    const config_header = b.addConfigHeader(.{ .style = .blank }, .{
        ._GNU_SOURCE = 1,
        .DEFAULT_VISIBILITY = .@"__attribute__ ((visibility (\"default\")))",
        .@"PRINTF_FORMAT(a, b)" = .@"/* */",
        .PLATFORM_POSIX = defineBool(is_posix),
        .PLATFORM_WINDOWS = defineBool(target.result.os.tag == .windows),
        .ENABLE_DEBUG_LOGGING = defineBool(optimize == .Debug),
        .ENABLE_LOGGING = 1,
        .HAVE_CLOCK_GETTIME = defineBool(target.result.os.tag != .windows),
        .HAVE_EVENTFD = null,
        .HAVE_TIMERFD = null,
        .USE_SYSTEM_LOGGING_FACILITY = null,
        .HAVE_PTHREAD_CONDATTR_SETCLOCK = null,
        .HAVE_PTHREAD_SETNAME_NP = null,
        .HAVE_PTHREAD_THREADID_NP = null,
    });

    const lib = std.Build.Step.Compile.create(b, .{
        .name = "usb",
        .version = .{ .major = 1, .minor = 0, .patch = 27 },

        .kind = .lib,
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });
    lib.installHeader(dep.path("libusb/libusb.h"), "libusb.h");
    lib.linkLibC();
    lib.addIncludePath(dep.path("libusb"));
    lib.addConfigHeader(config_header);
    lib.addCSourceFiles(.{
        .root = dep.path("libusb"),
        .files = &.{
            "core.c",
            "descriptor.c",
            "hotplug.c",
            "io.c",
            "strerror.c",
            "sync.c",
        },
    });

    switch (target.result.os.tag) {
        .macos => {
            lib.addIncludePath(dep.path("Xcode"));
        },
        .windows => {
            lib.addIncludePath(dep.path("msvc"));
        },
        else => {},
    }

    if (is_posix) {
        lib.addCSourceFiles(.{
            .root = dep.path("libusb/os"),
            .files = &.{
                "events_posix.c",
                "threads_posix.c",
            },
        });
    } else {
        lib.addCSourceFiles(.{
            .root = dep.path("libusb/os"),
            .files = &.{
                "events_windows.c",
                "threads_windows.c",
            },
        });
    }
    if (target.result.abi.isAndroid()) {
        lib.addIncludePath(dep.path("android"));
    }

    switch (target.result.os.tag) {
        .macos => {
            lib.addCSourceFiles(.{
                .root = dep.path("libusb/os"),
                .files = &.{"darwin_usb.c"},
            });
            lib.linkFramework("IOKit");
            lib.linkFramework("CoreFoundation");
            lib.linkFramework("Security");
        },
        .linux => {
            lib.addCSourceFiles(.{
                .root = dep.path("libusb/os"),
                .files = &.{
                    "linux_usbfs.c",
                    "linux_netlink.c",
                    "linux_udev.c",
                },
            });
            lib.linkSystemLibrary("udev");
        },
        .windows => {
            lib.addCSourceFiles(.{
                .root = dep.path("libusb/os"),
                .files = &.{
                    "windows_common.c",
                    "windows_usbdk.c",
                    "windows_winusb.c",
                },
            });
            lib.addWin32ResourceFile(.{ .file = dep.path("libusb/libusb-1.0.rc") });
        },
        .netbsd => {
            lib.addCSourceFiles(.{
                .root = dep.path("libusb/os"),
                .files = &.{"netbsd_usb.c"},
            });
        },
        .openbsd => {
            lib.addCSourceFiles(.{
                .root = dep.path("libusb/os"),
                .files = &.{"openbsd_usb.c"},
            });
        },
        else => {},
    }

    return lib;
}
