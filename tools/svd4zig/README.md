# svd4zig

Generate [Zig](https://ziglang.org/) header files from SVD files for accessing MMIO registers.

## Based on svd4zig (which is based on svd2zig)

This is a fork of [svd4zig](https://github.com/rbino/svd4zig/) with fixes and improvements.\
Made for use with CH32V (RISC-V) MCU.

## New features

- Supports Zig 0.14.0-dev.
- Fixed bugs when generating from SVD files for CH32V.
- New format for the generated file (code has become more interchangeable between different MCUs).

## Usage

Standalone:

```shell
zig build

# Print to stdout
./zig-cache/bin/svd4zig path/to/svd/file.svd

# Write to file
./zig-cache/bin/svd4zig path/to/svd/file.svd path/to/output/file.zig
```

In `build.zig`:

```zig
pub fn build(b: *std.Build) !void {
    const svd4zig_dep = b.dependency("svd4zig", .{});
    const svd4zig_artifact = svd4zig_dep.artifact("svd4zig");

    const svd_file = "file.svd";
    const out_file = b.fmt("{s}.zig", .{entry.name[0 .. entry.name.len - ".svd".len]});

    const run_cmd = b.addRunArtifact(svd4zig_artifact);
    run_cmd.addFileArg(.{ .cwd_relative = svd_file });
    b.getInstallStep().dependOn(&run_cmd.step);

    const out_file_path = run_cmd.addOutputFileArg(out_file);
    const install_file = b.addInstallFileWithDir(out_file_path, .{ .custom = ".." }, out_file);
    install_file.step.dependOn(&run_cmd.step);
    b.getInstallStep().dependOn(&install_file.step);
}
```

Don't forget to add the dependency in your `build.zig.zon`:

```
.{
  .dependencies = .{
    .svd4zig = .{ .path = "../../tools/svd4zig" },
  },
}
```

## License

The license remains the same as before: [UNLICENSE](LICENSE).
