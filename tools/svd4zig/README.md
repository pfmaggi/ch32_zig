# svd4zig

Generate [Zig](https://ziglang.org/) header files from
[CMSIS-SVD](http://www.keil.com/pack/doc/CMSIS/SVD/html/index.html) files for accessing MMIO
registers.

## Based on svd4zig (which is based on svd2zig)

This is a fork of [svd4zig](https://github.com/rbino/svd4zig/) with fixes and improvements.\
Made for use with CH32V (RISC-V) MCU.

## New features

+ Supports Zig 0.14.0-dev.
+ Fixed bugs when generating from SVD files for CH32V.
+ New format for the generated file (code has become more interchangeable between different MCUs).

## License

The license remains the same as before: [UNLICENSE](LICENSE).