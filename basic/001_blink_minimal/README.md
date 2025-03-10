```shell
zig build
# upload
minichlink -w zig-out/firmware/ch32v003_blink.bin flash -b
```

or manually:

```shell
# build ELF
zig build-exe -fstrip -fsingle-threaded \
-OReleaseSafe \
-target riscv32-freestanding-eabi \
-mcpu=generic+32bit+e+c \
-femit-asm --name ch32v003_blink.elf \
src/main.zig
# convert to BIN
zig objcopy -O binary ch32v003_blink.elf ch32v003_blink.bin
rm ch32v003_blink.elf.o # remove intermediate object file
# upload
minichlink -w ch32v003_blink.bin flash -b
```
