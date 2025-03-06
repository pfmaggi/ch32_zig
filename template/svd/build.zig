const std = @import("std");

pub fn build(b: *std.Build) !void {
    const svd4zig_dep = b.dependency("svd4zig", .{});
    const svd4zig_artifact = svd4zig_dep.artifact("svd4zig");

    const dir = try std.fs.cwd().openDir(".", .{ .iterate = true });
    var dir_it = dir.iterate();
    while (try dir_it.next()) |entry| {
        if (entry.kind != .file) {
            continue;
        }

        if (!std.mem.endsWith(u8, entry.name, ".svd")) {
            continue;
        }

        const svd_file = entry.name;
        const out_file = b.fmt("{s}.zig", .{entry.name[0 .. entry.name.len - ".svd".len]});

        const run_cmd = b.addRunArtifact(svd4zig_artifact);
        run_cmd.addFileArg(.{ .cwd_relative = svd_file });
        b.getInstallStep().dependOn(&run_cmd.step);

        const out_file_path = run_cmd.addOutputFileArg(out_file);
        const install_file = b.addInstallFileWithDir(out_file_path, .{ .custom = ".." }, out_file);
        install_file.step.dependOn(&run_cmd.step);
        b.getInstallStep().dependOn(&install_file.step);
    }
}
