# Size benchmark

This document contains the size in bytes of the firmware for each optimize mode.

## [examples/blink_delay](examples/blink_delay)

### blink_delay_ch32v003.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 562 | 0 | 4 | 566 | 
| ReleaseFast | 560 | 0 | 4 | 564 | 
| ReleaseSafe | 864 | 0 | 4 | 868 | 
| Debug | 4406 | 0 | 4 | 4410 | 

### blink_delay_ch32v20x.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 826 | 0 | 4 | 830 | 
| ReleaseFast | 804 | 0 | 4 | 808 | 
| ReleaseSafe | 848 | 0 | 4 | 852 | 
| Debug | 4678 | 0 | 4 | 4682 | 

### blink_delay_ch32v30x.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 868 | 0 | 4 | 872 | 
| ReleaseFast | 846 | 0 | 4 | 850 | 
| ReleaseSafe | 882 | 0 | 4 | 886 | 
| Debug | 5314 | 0 | 4 | 5318 | 


## [examples/blink_minimal](examples/blink_minimal)

### blink_minimal_ch32v003.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 428 | 0 | 0 | 428 | 
| ReleaseFast | 462 | 0 | 0 | 462 | 
| ReleaseSafe | 464 | 0 | 0 | 464 | 
| Debug | 3378 | 0 | 0 | 3378 | 

### blink_minimal_ch32v20x.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 714 | 0 | 0 | 714 | 
| ReleaseFast | 750 | 0 | 0 | 750 | 
| ReleaseSafe | 752 | 0 | 0 | 752 | 
| Debug | 3948 | 0 | 0 | 3948 | 

### blink_minimal_ch32v30x.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 748 | 0 | 0 | 748 | 
| ReleaseFast | 784 | 0 | 0 | 784 | 
| ReleaseSafe | 786 | 0 | 0 | 786 | 
| Debug | 4584 | 0 | 0 | 4584 | 


## [examples/blink_systick_interrupt](examples/blink_systick_interrupt)

### blink_systick_interrupt_ch32v003.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 544 | 0 | 0 | 544 | 
| ReleaseFast | 594 | 0 | 0 | 594 | 
| ReleaseSafe | 596 | 0 | 0 | 596 | 
| Debug | 3796 | 0 | 0 | 3796 | 

### blink_systick_interrupt_ch32v20x.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 808 | 0 | 0 | 808 | 
| ReleaseFast | 858 | 0 | 0 | 858 | 
| ReleaseSafe | 860 | 0 | 0 | 860 | 
| Debug | 4386 | 0 | 0 | 4386 | 

### blink_systick_interrupt_ch32v30x.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 854 | 0 | 0 | 854 | 
| ReleaseFast | 904 | 0 | 0 | 904 | 
| ReleaseSafe | 906 | 0 | 0 | 906 | 
| Debug | 5176 | 0 | 0 | 5176 | 


## [examples/i2c_bmi160](examples/i2c_bmi160)

### i2c_bmi160_ch32v003.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 8110 | 4 | 16 | 8130 | 
| ReleaseFast | 12192 | 4 | 16 | 12212 | 


## [examples/spi](examples/spi)

### spi_ch32v003_master.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2596 | 0 | 4 | 2600 | 
| ReleaseFast | 3482 | 0 | 4 | 3486 | 
| ReleaseSafe | 10720 | 0 | 4 | 10724 | 

### spi_ch32v003_slave.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2596 | 0 | 4 | 2600 | 
| ReleaseFast | 3392 | 0 | 4 | 3396 | 
| ReleaseSafe | 10632 | 0 | 4 | 10636 | 

### spi_ch32v20x_master.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2914 | 0 | 4 | 2918 | 
| ReleaseFast | 3710 | 0 | 4 | 3714 | 
| ReleaseSafe | 9706 | 0 | 4 | 9710 | 

### spi_ch32v20x_slave.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2910 | 0 | 4 | 2914 | 
| ReleaseFast | 3638 | 0 | 4 | 3642 | 
| ReleaseSafe | 9630 | 0 | 4 | 9634 | 

### spi_ch32v30x_master.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2952 | 0 | 4 | 2956 | 
| ReleaseFast | 3748 | 0 | 4 | 3752 | 
| ReleaseSafe | 9744 | 0 | 4 | 9748 | 
| Debug | 51608 | 0 | 4 | 51612 | 

### spi_ch32v30x_slave.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2948 | 0 | 4 | 2952 | 
| ReleaseFast | 3676 | 0 | 4 | 3680 | 
| ReleaseSafe | 9668 | 0 | 4 | 9672 | 
| Debug | 51474 | 0 | 4 | 51478 | 


## [examples/uart](examples/uart)

### uart_ch32v003.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2064 | 4 | 4 | 2072 | 
| ReleaseFast | 2678 | 4 | 4 | 2686 | 
| ReleaseSafe | 3516 | 4 | 4 | 3524 | 

### uart_ch32v20x.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2340 | 4 | 4 | 2348 | 
| ReleaseFast | 2852 | 4 | 4 | 2860 | 
| ReleaseSafe | 3210 | 4 | 4 | 3218 | 

### uart_ch32v30x.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2378 | 4 | 4 | 2386 | 
| ReleaseFast | 2890 | 4 | 4 | 2898 | 
| ReleaseSafe | 3248 | 4 | 4 | 3256 | 
| Debug | 60124 | 4 | 4 | 60132 | 


## [examples/uart_echo](examples/uart_echo)

### uart_echo_ch32v003.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 1972 | 0 | 4 | 1976 | 
| ReleaseFast | 2152 | 0 | 4 | 2156 | 
| ReleaseSafe | 1844 | 0 | 4 | 1848 | 

### uart_echo_ch32v20x.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2318 | 0 | 4 | 2322 | 
| ReleaseFast | 2430 | 0 | 4 | 2434 | 
| ReleaseSafe | 2136 | 0 | 4 | 2140 | 

### uart_echo_ch32v30x.elf 

| Mode | Text | Data | Bss | Total |
|--------|--------|--------|--------|--------|
| ReleaseSmall | 2356 | 0 | 4 | 2360 | 
| ReleaseFast | 2468 | 0 | 4 | 2472 | 
| ReleaseSafe | 2174 | 0 | 4 | 2178 | 
| Debug | 64396 | 0 | 4 | 64400 | 



This document was generated by `size-benchmark.sh` script.
