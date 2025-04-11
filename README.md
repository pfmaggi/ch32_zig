# WCH CH32 HAL in Zig

HAL(Hardware Abstraction Layer) for the WCH CH32 series of microcontrollers written in Zig.

## Project Goals

- The size of the firmware output file. After each change, the size of all examples is checked, and if it increases, the
  cause is investigated and resolved.
- IDE autocompletion support is a top priority. Whatever you interact with, autocompletion should work seamlessly.

## Flashing

The [minichlink](tools/minichlink) flasher is also included and can be
compiled using `zig build` as well.

## Getting Started

> \[!NOTE\]
> If you are using `nix`, you can simply run `nix develop` in the root of the project, and it will automatically install
> `zig`, `zigscient`, `minichlink` and `wch-openocd` in your environment.
> And you can skip to the [Build and upload the example](#build-and-upload-the-example) section.

### Install Zig

Currently, the examples are tested with `0.14.0`.\
You can download the latest version from:
https://ziglang.org/download/

### Build the flasher

```shell
cd tools/minichlink
zig build

# Add the `minichlink` to your `PATH`:
export PATH=$PATH:$(pwd)/zig-out/bin
```

### Build and upload the example

```shell
cd examples/blink_minimal
zig build
minichlink -w zig-out/firmware/blink_minimal_ch32v003.bin flash -b
```

## Basic Examples

If you want to learn more about how everything works, I recommend checking out the repository with basic examples that
are based on the use of registers without
abstractions: [ch32v003_basic_zig](https://github.com/ghostiam/ch32v003_basic_zig)

## Size benchmark

See [SIZE_BENCHMARK.md](SIZE_BENCHMARK.md)

## Useful Notes

See [USEFUL_NOTES.md](USEFUL_NOTES.md)