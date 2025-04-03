# Size benchmark

This document contains the size in bytes of the firmware for each optimize mode.

## [examples/blink_delay](examples/blink_delay)

### blink_delay_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 406 | 0 | 0 | 4 | 562 |
| ReleaseFast | 156 | 404 | 0 | 0 | 4 | 560 |
| ReleaseSafe | 156 | 696 | 0 | 0 | 4 | 852 |
| Debug | 156 | 2704 | 232 | 0 | 12 | 3096 |

### blink_delay_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 434 | 0 | 0 | 4 | 826 |
| ReleaseFast | 392 | 412 | 0 | 0 | 4 | 804 |
| ReleaseSafe | 392 | 450 | 0 | 0 | 4 | 842 |
| Debug | 392 | 2728 | 240 | 0 | 12 | 3360 |

### blink_delay_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 452 | 0 | 0 | 4 | 868 |
| ReleaseFast | 416 | 430 | 0 | 0 | 4 | 846 |
| ReleaseSafe | 416 | 460 | 0 | 0 | 4 | 876 |
| Debug | 416 | 2812 | 240 | 0 | 12 | 3472 |


## [examples/blink_minimal](examples/blink_minimal)

### blink_minimal_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 272 | 0 | 0 | 0 | 428 |
| ReleaseFast | 156 | 306 | 0 | 0 | 0 | 462 |
| ReleaseSafe | 156 | 308 | 0 | 0 | 0 | 464 |
| Debug | 156 | 1982 | 224 | 0 | 0 | 2368 |

### blink_minimal_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 322 | 0 | 0 | 0 | 714 |
| ReleaseFast | 392 | 358 | 0 | 0 | 0 | 750 |
| ReleaseSafe | 392 | 360 | 0 | 0 | 0 | 752 |
| Debug | 392 | 2316 | 224 | 0 | 0 | 2936 |

### blink_minimal_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 332 | 0 | 0 | 0 | 748 |
| ReleaseFast | 416 | 368 | 0 | 0 | 0 | 784 |
| ReleaseSafe | 416 | 370 | 0 | 0 | 0 | 786 |
| Debug | 416 | 2400 | 224 | 0 | 0 | 3040 |


## [examples/blink_systick_interrupt](examples/blink_systick_interrupt)

### blink_systick_interrupt_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 380 | 8 | 0 | 0 | 544 |
| ReleaseFast | 156 | 430 | 8 | 0 | 0 | 596 |
| ReleaseSafe | 156 | 432 | 8 | 0 | 0 | 596 |
| Debug | 156 | 2194 | 232 | 0 | 0 | 2584 |

### blink_systick_interrupt_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 408 | 8 | 0 | 0 | 808 |
| ReleaseFast | 392 | 458 | 8 | 0 | 0 | 860 |
| ReleaseSafe | 392 | 460 | 8 | 0 | 0 | 860 |
| Debug | 392 | 2546 | 232 | 0 | 0 | 3176 |

### blink_systick_interrupt_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 430 | 8 | 0 | 0 | 856 |
| ReleaseFast | 416 | 480 | 8 | 0 | 0 | 904 |
| ReleaseSafe | 416 | 482 | 8 | 0 | 0 | 908 |
| Debug | 416 | 2784 | 232 | 0 | 0 | 3432 |


## [examples/blink_time_delay](examples/blink_time_delay)

### blink_time_delay_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 478 | 0 | 0 | 8 | 634 |
| ReleaseFast | 156 | 458 | 0 | 0 | 8 | 614 |
| ReleaseSafe | 156 | 470 | 0 | 0 | 8 | 626 |
| Debug | 156 | 2660 | 232 | 0 | 8 | 3048 |

### blink_time_delay_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 528 | 0 | 0 | 8 | 920 |
| ReleaseFast | 392 | 510 | 0 | 0 | 8 | 902 |
| ReleaseSafe | 392 | 522 | 0 | 0 | 8 | 914 |
| Debug | 392 | 2986 | 240 | 0 | 8 | 3624 |

### blink_time_delay_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 538 | 0 | 0 | 8 | 954 |
| ReleaseFast | 416 | 520 | 0 | 0 | 8 | 936 |
| ReleaseSafe | 416 | 532 | 0 | 0 | 8 | 948 |
| Debug | 416 | 3070 | 240 | 0 | 8 | 3728 |


## [examples/i2c_bmi160](examples/i2c_bmi160)

### i2c_bmi160_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 6710 | 1224 | 4 | 16 | 8096 |
| ReleaseFast | 156 | 10602 | 1416 | 4 | 16 | 12180 |


## [examples/mco](examples/mco)

### mco_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 410 | 2 | 0 | 0 | 568 |
| ReleaseFast | 156 | 458 | 2 | 0 | 0 | 616 |
| ReleaseSafe | 156 | 524 | 168 | 0 | 0 | 848 |
| Debug | 156 | 5162 | 412 | 0 | 0 | 5732 |

### mco_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 448 | 2 | 0 | 0 | 842 |
| ReleaseFast | 392 | 496 | 2 | 0 | 0 | 890 |
| ReleaseSafe | 392 | 730 | 300 | 0 | 0 | 1424 |
| Debug | 392 | 7268 | 610 | 0 | 0 | 8274 |

### mco_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 464 | 2 | 0 | 0 | 882 |
| ReleaseFast | 416 | 510 | 2 | 0 | 0 | 928 |
| ReleaseSafe | 416 | 744 | 300 | 0 | 0 | 1460 |
| Debug | 416 | 7330 | 610 | 0 | 0 | 8362 |


## [examples/spi](examples/spi)

### spi_ch32v003_master.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1940 | 500 | 0 | 4 | 2596 |
| ReleaseFast | 156 | 2866 | 460 | 0 | 4 | 3484 |
| ReleaseSafe | 156 | 9474 | 1100 | 0 | 4 | 10732 |

### spi_ch32v003_slave.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1932 | 508 | 0 | 4 | 2596 |
| ReleaseFast | 156 | 2788 | 448 | 0 | 4 | 3392 |
| ReleaseSafe | 156 | 9396 | 1092 | 0 | 4 | 10644 |

### spi_ch32v20x_master.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1814 | 692 | 0 | 4 | 2900 |
| ReleaseFast | 392 | 2666 | 636 | 0 | 4 | 3700 |
| ReleaseSafe | 392 | 8058 | 1276 | 0 | 4 | 9732 |

### spi_ch32v20x_slave.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1810 | 692 | 0 | 4 | 2896 |
| ReleaseFast | 392 | 2610 | 620 | 0 | 4 | 3628 |
| ReleaseSafe | 392 | 8000 | 1260 | 0 | 4 | 9652 |

### spi_ch32v30x_master.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1828 | 692 | 0 | 4 | 2940 |
| ReleaseFast | 416 | 2680 | 636 | 0 | 4 | 3732 |
| ReleaseSafe | 416 | 8072 | 1276 | 0 | 4 | 9764 |
| Debug | 416 | 34662 | 2052 | 0 | 12 | 37132 |

### spi_ch32v30x_slave.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1824 | 692 | 0 | 4 | 2932 |
| ReleaseFast | 416 | 2624 | 620 | 0 | 4 | 3660 |
| ReleaseSafe | 416 | 8014 | 1260 | 0 | 4 | 9692 |
| Debug | 416 | 34552 | 2028 | 0 | 12 | 36996 |


## [examples/uart](examples/uart)

### uart_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1540 | 352 | 4 | 4 | 2052 |
| ReleaseFast | 156 | 2172 | 332 | 4 | 4 | 2664 |
| ReleaseSafe | 156 | 3092 | 224 | 4 | 4 | 3476 |

### uart_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1390 | 532 | 4 | 4 | 2320 |
| ReleaseFast | 392 | 1938 | 496 | 4 | 4 | 2832 |
| ReleaseSafe | 392 | 2404 | 388 | 4 | 4 | 3188 |
| Debug | 392 | 29662 | 1768 | 4 | 12 | 31828 |

### uart_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1404 | 532 | 4 | 4 | 2356 |
| ReleaseFast | 416 | 1952 | 496 | 4 | 4 | 2868 |
| ReleaseSafe | 416 | 2418 | 388 | 4 | 4 | 3228 |
| Debug | 416 | 29724 | 1768 | 4 | 12 | 31916 |


## [examples/uart_dma_tx](examples/uart_dma_tx)

### uart_dma_tx_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1338 | 208 | 0 | 4 | 1704 |
| ReleaseFast | 156 | 1810 | 208 | 0 | 4 | 2176 |
| ReleaseSafe | 156 | 3054 | 224 | 0 | 4 | 3436 |

### uart_dma_tx_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1208 | 388 | 0 | 4 | 1988 |
| ReleaseFast | 392 | 1578 | 372 | 0 | 4 | 2344 |
| ReleaseSafe | 392 | 2372 | 388 | 0 | 4 | 3152 |
| Debug | 392 | 29062 | 1736 | 0 | 12 | 31192 |

### uart_dma_tx_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1222 | 388 | 0 | 4 | 2028 |
| ReleaseFast | 416 | 1592 | 372 | 0 | 4 | 2380 |
| ReleaseSafe | 416 | 2386 | 388 | 0 | 4 | 3192 |
| Debug | 416 | 29124 | 1736 | 0 | 12 | 31280 |


## [examples/uart_dma_tx_irq](examples/uart_dma_tx_irq)

### uart_dma_tx_irq_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1476 | 216 | 0 | 4 | 1848 |
| ReleaseFast | 156 | 1962 | 216 | 0 | 4 | 2336 |
| ReleaseSafe | 156 | 3204 | 232 | 0 | 4 | 3592 |

### uart_dma_tx_irq_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1306 | 396 | 0 | 4 | 2096 |
| ReleaseFast | 392 | 1760 | 380 | 0 | 4 | 2532 |
| ReleaseSafe | 392 | 2554 | 396 | 0 | 4 | 3344 |

### uart_dma_tx_irq_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1320 | 396 | 0 | 4 | 2132 |
| ReleaseFast | 416 | 1774 | 380 | 0 | 4 | 2572 |
| ReleaseSafe | 416 | 2568 | 396 | 0 | 4 | 3380 |
| Debug | 416 | 32236 | 1768 | 0 | 12 | 34424 |


## [examples/uart_echo](examples/uart_echo)

### uart_echo_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1382 | 416 | 0 | 4 | 1956 |
| ReleaseFast | 156 | 1570 | 408 | 0 | 4 | 2136 |
| ReleaseSafe | 156 | 1434 | 236 | 0 | 4 | 1828 |

### uart_echo_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1304 | 596 | 0 | 4 | 2292 |
| ReleaseFast | 392 | 1436 | 572 | 0 | 4 | 2400 |
| ReleaseSafe | 392 | 1314 | 400 | 0 | 4 | 2108 |

### uart_echo_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1318 | 596 | 0 | 4 | 2332 |
| ReleaseFast | 416 | 1450 | 572 | 0 | 4 | 2440 |
| ReleaseSafe | 416 | 1328 | 400 | 0 | 4 | 2144 |
| Debug | 416 | 32156 | 1944 | 0 | 12 | 34520 |



This document was generated by `size-benchmark.sh` script.
