# Size benchmark

This document contains the size in bytes of the firmware for each optimize mode.

## [examples/blink_delay](examples/blink_delay)

### blink_delay_ch32v003.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 562 | 0 | 4 | 566 | 
| ReleaseFast | 558 | 0 | 4 | 562 | 
| ReleaseSafe | 864 | 0 | 4 | 868 | 
| Debug | 4388 | 0 | 4 | 4392 | 

### blink_delay_ch32v20x.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 590 | 0 | 4 | 594 | 
| ReleaseFast | 566 | 0 | 4 | 570 | 
| ReleaseSafe | 612 | 0 | 4 | 616 | 
| Debug | 4412 | 0 | 4 | 4416 | 

### blink_delay_ch32v30x.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 608 | 0 | 4 | 612 | 
| ReleaseFast | 584 | 0 | 4 | 588 | 
| ReleaseSafe | 622 | 0 | 4 | 626 | 
| Debug | 4968 | 0 | 4 | 4972 | 


## [examples/blink_minimal](examples/blink_minimal)

### blink_minimal_ch32v003.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 428 | 0 | 0 | 428 | 
| ReleaseFast | 460 | 0 | 0 | 460 | 
| ReleaseSafe | 464 | 0 | 0 | 464 | 
| Debug | 3360 | 0 | 0 | 3360 | 

### blink_minimal_ch32v20x.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 478 | 0 | 0 | 478 | 
| ReleaseFast | 512 | 0 | 0 | 512 | 
| ReleaseSafe | 516 | 0 | 0 | 516 | 
| Debug | 3682 | 0 | 0 | 3682 | 

### blink_minimal_ch32v30x.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 488 | 0 | 0 | 488 | 
| ReleaseFast | 522 | 0 | 0 | 522 | 
| ReleaseSafe | 526 | 0 | 0 | 526 | 
| Debug | 4238 | 0 | 0 | 4238 | 


## [examples/i2c_bmi160](examples/i2c_bmi160)

### i2c_bmi160_ch32v003.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 8066 | 4 | 16 | 8086 | 
| ReleaseFast | 12124 | 4 | 16 | 12144 | 


## [examples/spi](examples/spi)

### spi_ch32v003_master.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2582 | 0 | 4 | 2586 | 
| ReleaseFast | 3458 | 0 | 4 | 3462 | 
| ReleaseSafe | 10720 | 0 | 4 | 10724 | 

### spi_ch32v003_slave.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2578 | 0 | 4 | 2582 | 
| ReleaseFast | 3368 | 0 | 4 | 3372 | 
| ReleaseSafe | 10632 | 0 | 4 | 10636 | 

### spi_ch32v20x_master.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2664 | 0 | 4 | 2668 | 
| ReleaseFast | 3454 | 0 | 4 | 3458 | 
| ReleaseSafe | 9470 | 0 | 4 | 9474 | 

### spi_ch32v20x_slave.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2656 | 0 | 4 | 2660 | 
| ReleaseFast | 3384 | 0 | 4 | 3388 | 
| ReleaseSafe | 9394 | 0 | 4 | 9398 | 

### spi_ch32v30x_master.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2678 | 0 | 4 | 2682 | 
| ReleaseFast | 3468 | 0 | 4 | 3472 | 
| ReleaseSafe | 9484 | 0 | 4 | 9488 | 
| Debug | 51262 | 0 | 4 | 51266 | 

### spi_ch32v30x_slave.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2670 | 0 | 4 | 2674 | 
| ReleaseFast | 3398 | 0 | 4 | 3402 | 
| ReleaseSafe | 9408 | 0 | 4 | 9412 | 
| Debug | 51128 | 0 | 4 | 51132 | 


## [examples/uart](examples/uart)

### uart_ch32v003.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2044 | 4 | 4 | 2052 | 
| ReleaseFast | 2656 | 4 | 4 | 2664 | 
| ReleaseSafe | 3516 | 4 | 4 | 3524 | 

### uart_ch32v20x.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2084 | 4 | 4 | 2092 | 
| ReleaseFast | 2594 | 4 | 4 | 2602 | 
| ReleaseSafe | 2974 | 4 | 4 | 2982 | 

### uart_ch32v30x.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2098 | 4 | 4 | 2106 | 
| ReleaseFast | 2608 | 4 | 4 | 2616 | 
| ReleaseSafe | 2988 | 4 | 4 | 2996 | 
| Debug | 59778 | 4 | 4 | 59786 | 


## [examples/uart_echo](examples/uart_echo)

### uart_echo_ch32v003.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 1952 | 0 | 4 | 1956 | 
| ReleaseFast | 2130 | 0 | 4 | 2134 | 
| ReleaseSafe | 1844 | 0 | 4 | 1848 | 

### uart_echo_ch32v20x.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2062 | 0 | 4 | 2066 | 
| ReleaseFast | 2172 | 0 | 4 | 2176 | 
| ReleaseSafe | 1900 | 0 | 4 | 1904 | 

### uart_echo_ch32v30x.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2076 | 0 | 4 | 2080 | 
| ReleaseFast | 2186 | 0 | 4 | 2190 | 
| ReleaseSafe | 1914 | 0 | 4 | 1918 | 
| Debug | 64050 | 0 | 4 | 64054 | 



This document was generated by `size-benchmark.sh` script.
