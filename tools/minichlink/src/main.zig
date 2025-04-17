const std = @import("std");
const builtin = @import("builtin");

const c = @cImport({
    @cInclude("minichlink.h");
    @cInclude("minichlink-patched.c");
});

pub fn main() !u8 {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    const gpa, const is_debug = switch (builtin.mode) {
        .Debug, .ReleaseSafe => .{ debug_allocator.allocator(), true },
        .ReleaseFast, .ReleaseSmall => .{ std.heap.smp_allocator, false },
    };
    defer if (is_debug) {
        _ = debug_allocator.deinit();
    };
    const allocator = gpa;
    // var arena = std.heap.ArenaAllocator.init(gpa);
    // defer arena.deinit();
    // const allocator = arena.allocator();

    const args = std.process.argsAlloc(allocator) catch |err| {
        std.debug.print("Failed to allocate arguments\n", .{});
        return err;
    };
    defer std.process.argsFree(allocator, args);

    const ocd_args = try OcdArgs.parse(allocator, args);
    defer allocator.destroy(ocd_args);

    if (ocd_args.show_version) {
        const version = try versionFromZon(allocator);
        defer versionFromZonFree(allocator, version);

        const stderr = std.io.getStdErr().writer();
        try stderr.print("Minichlink As Open On-Chip Debugger {s}\n", .{version.version});
        return 0;
    }

    // int orig_main( int argc, char ** argv )
    // var info_arg: [:0]const u8 = "-i";
    // const info_arg_ptr: [*:0]u8 = @ptrCast(&info_arg);
    // const argv_pre = [_][*:0]u8{
    //     std.os.argv[0],
    //     info_arg_ptr,
    // };
    // const argv: [][*:0]u8 = @constCast(&argv_pre);

    const argv_pre = [_][*:0]u8{
        args[0],
        @constCast("-i"),
        // @constCast("-T"),
    };
    const argv: [][*:0]u8 = @constCast(&argv_pre);
    const argv_c_ptr: [*c][*c]u8 = @ptrCast(argv.ptr);
    const code = c.orig_main(@intCast(argv.len), argv_c_ptr);
    if (code != 0) {
        std.log.err("Error code: {}", .{code});
    }
    return @truncate(@as(c_uint, @bitCast(code)));
}

const OcdArgs = struct {
    show_version: bool = false,

    fn parse(allocator: std.mem.Allocator, args: [][:0]u8) !*OcdArgs {
        const ocd_args = try allocator.create(OcdArgs);

        for (args) |arg| {
            if (std.mem.eql(u8, arg, "--version")) {
                ocd_args.show_version = true;
            }
        }

        return ocd_args;
    }

    test parse {}
};

const Version = struct { version: []const u8 };

fn versionFromZon(allocator: std.mem.Allocator) !Version {
    const build_zig_zon = @embedFile("build_zig_zon");
    const version = try std.zon.parse.fromSlice(
        Version,
        allocator,
        build_zig_zon,
        null,
        .{ .ignore_unknown_fields = true },
    );

    return version;
}

fn versionFromZonFree(allocator: std.mem.Allocator, version: Version) void {
    std.zon.parse.free(allocator, version);
}
