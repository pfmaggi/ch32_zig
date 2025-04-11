# WCH CH32 HAL in Zig

HAL(Hardware Abstraction Layer) for the WCH CH32 series of microcontrollers written in Zig.

## Project Goals

- Minimizing the size of the firmware output file. After each change, the size of all examples is checked, and if it
  increases, the cause is investigated and resolved.
- Providing seamless IDE autocompletion support is a top priority. Whatever you interact with, autocompletion should
  work seamlessly.

## Getting Started

See [GETTING_STARTED.md](GETTING_STARTED.md) for more details.

## Basic Examples

If you want to learn more about how everything works, I recommend checking out the repository with basic examples that
are based on the use of registers without
abstractions: [ch32v003_basic_zig](https://github.com/ghostiam/ch32v003_basic_zig)

## Size benchmark

See [SIZE_BENCHMARK.md](SIZE_BENCHMARK.md)

## Useful Notes

See [USEFUL_NOTES.md](USEFUL_NOTES.md)

### Build and flash the examples

```shell
cd examples/blink_minimal
zig build
zig build minichlink -- -w zig-out/firmware/blink_minimal_ch32v003.bin flash -b
```

### Build the `minichlink`

[Minichlink](https://github.com/cnlohr/ch32v003fun/tree/master/minichlink) is a open-source flasher for WCH chips.
It is built with Zig and can be compiled using the following command:

```shell
zig build minichlink
```

Output will be in `zig-out/bin/minichlink`.
