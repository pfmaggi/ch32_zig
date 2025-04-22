# Size benchmark

This document contains the size in bytes of the firmware for each optimize mode.

## [examples/adc_polling](examples/adc_polling)

### adc_polling_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1480 | 208 | 0 | 4 | 1844 |
| ReleaseFast | 156 | 2002 | 204 | 0 | 4 | 2364 |
| ReleaseSafe | 156 | 9240 | 948 | 0 | 4 | 10344 |


## [examples/adc_scan_dma](examples/adc_scan_dma)

### adc_scan_dma_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1876 | 216 | 0 | 20 | 2248 |
| ReleaseFast | 156 | 2690 | 208 | 0 | 20 | 3056 |
| ReleaseSafe | 156 | 9962 | 952 | 0 | 20 | 11072 |


## [examples/blink_delay](examples/blink_delay)

### blink_delay_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 402 | 0 | 0 | 4 | 558 |
| ReleaseFast | 156 | 400 | 0 | 0 | 4 | 556 |
| ReleaseSafe | 156 | 700 | 0 | 0 | 4 | 856 |
| Debug | 156 | 2724 | 236 | 0 | 12 | 3116 |

### blink_delay_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 430 | 0 | 0 | 4 | 822 |
| ReleaseFast | 392 | 408 | 0 | 0 | 4 | 800 |
| ReleaseSafe | 392 | 454 | 0 | 0 | 4 | 846 |
| Debug | 392 | 2748 | 244 | 0 | 12 | 3388 |

### blink_delay_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 448 | 0 | 0 | 4 | 864 |
| ReleaseFast | 416 | 426 | 0 | 0 | 4 | 842 |
| ReleaseSafe | 416 | 464 | 0 | 0 | 4 | 880 |
| Debug | 416 | 2832 | 244 | 0 | 12 | 3492 |


## [examples/blink_minimal](examples/blink_minimal)

### blink_minimal_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 268 | 0 | 0 | 0 | 424 |
| ReleaseFast | 156 | 302 | 0 | 0 | 0 | 458 |
| ReleaseSafe | 156 | 304 | 0 | 0 | 0 | 460 |
| Debug | 156 | 2002 | 224 | 0 | 0 | 2384 |

### blink_minimal_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 318 | 0 | 0 | 0 | 710 |
| ReleaseFast | 392 | 354 | 0 | 0 | 0 | 746 |
| ReleaseSafe | 392 | 356 | 0 | 0 | 0 | 748 |
| Debug | 392 | 2336 | 224 | 0 | 0 | 2952 |

### blink_minimal_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 328 | 0 | 0 | 0 | 744 |
| ReleaseFast | 416 | 364 | 0 | 0 | 0 | 780 |
| ReleaseSafe | 416 | 366 | 0 | 0 | 0 | 782 |
| Debug | 416 | 2420 | 224 | 0 | 0 | 3064 |


## [examples/blink_systick_interrupt](examples/blink_systick_interrupt)

### blink_systick_interrupt_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 366 | 8 | 0 | 0 | 532 |
| ReleaseFast | 156 | 416 | 8 | 0 | 0 | 580 |
| ReleaseSafe | 156 | 418 | 8 | 0 | 0 | 584 |
| Debug | 156 | 2124 | 232 | 0 | 0 | 2512 |

### blink_systick_interrupt_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 390 | 8 | 0 | 0 | 792 |
| ReleaseFast | 392 | 440 | 8 | 0 | 0 | 840 |
| ReleaseSafe | 392 | 442 | 8 | 0 | 0 | 844 |
| Debug | 392 | 2472 | 232 | 0 | 0 | 3096 |

### blink_systick_interrupt_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 412 | 8 | 0 | 0 | 836 |
| ReleaseFast | 416 | 462 | 8 | 0 | 0 | 888 |
| ReleaseSafe | 416 | 464 | 8 | 0 | 0 | 888 |
| Debug | 416 | 2710 | 232 | 0 | 0 | 3360 |


## [examples/blink_time_deadline](examples/blink_time_deadline)

### blink_time_deadline_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 832 | 0 | 0 | 8 | 988 |
| ReleaseFast | 156 | 834 | 0 | 0 | 8 | 990 |
| ReleaseSafe | 156 | 886 | 0 | 0 | 8 | 1042 |
| Debug | 156 | 3690 | 264 | 0 | 8 | 4112 |

### blink_time_deadline_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 572 | 0 | 0 | 8 | 964 |
| ReleaseFast | 392 | 564 | 0 | 0 | 8 | 956 |
| ReleaseSafe | 392 | 606 | 0 | 0 | 8 | 998 |
| Debug | 392 | 3680 | 272 | 0 | 8 | 4344 |

### blink_time_deadline_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 582 | 0 | 0 | 8 | 998 |
| ReleaseFast | 416 | 574 | 0 | 0 | 8 | 990 |
| ReleaseSafe | 416 | 616 | 0 | 0 | 8 | 1032 |
| Debug | 416 | 3764 | 272 | 0 | 8 | 4456 |


## [examples/blink_time_delay](examples/blink_time_delay)

### blink_time_delay_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 462 | 0 | 0 | 8 | 618 |
| ReleaseFast | 156 | 444 | 0 | 0 | 8 | 600 |
| ReleaseSafe | 156 | 464 | 0 | 0 | 8 | 620 |
| Debug | 156 | 2562 | 236 | 0 | 8 | 2956 |

### blink_time_delay_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 512 | 0 | 0 | 8 | 904 |
| ReleaseFast | 392 | 496 | 0 | 0 | 8 | 888 |
| ReleaseSafe | 392 | 516 | 0 | 0 | 8 | 908 |
| Debug | 392 | 2888 | 244 | 0 | 8 | 3524 |

### blink_time_delay_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 522 | 0 | 0 | 8 | 938 |
| ReleaseFast | 416 | 506 | 0 | 0 | 8 | 922 |
| ReleaseSafe | 416 | 526 | 0 | 0 | 8 | 942 |
| Debug | 416 | 2972 | 244 | 0 | 8 | 3636 |


## [examples/debug_sdi_print](examples/debug_sdi_print)

### debug_sdi_print_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1018 | 26 | 0 | 4 | 1200 |
| ReleaseFast | 156 | 1440 | 26 | 0 | 4 | 1622 |
| ReleaseSafe | 156 | 9544 | 700 | 0 | 4 | 10400 |

### debug_sdi_print_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 680 | 26 | 0 | 4 | 1098 |
| ReleaseFast | 392 | 1048 | 26 | 0 | 4 | 1466 |
| ReleaseSafe | 392 | 7650 | 700 | 0 | 4 | 8744 |
| Debug | 392 | 19024 | 1184 | 0 | 12 | 20600 |

### debug_sdi_print_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 702 | 26 | 0 | 4 | 1144 |
| ReleaseFast | 416 | 1070 | 26 | 0 | 4 | 1512 |
| ReleaseSafe | 416 | 7672 | 700 | 0 | 4 | 8788 |
| Debug | 416 | 19102 | 1184 | 0 | 12 | 20704 |


## [examples/debug_sdi_print_logger](examples/debug_sdi_print_logger)

### debug_sdi_print_logger_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 3724 | 319 | 0 | 17 | 4199 |
| ReleaseFast | 156 | 5236 | 519 | 0 | 17 | 5911 |
| ReleaseSafe | 156 | 10378 | 1132 | 0 | 16 | 11668 |

### debug_sdi_print_logger_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 3324 | 319 | 0 | 17 | 4039 |
| ReleaseFast | 392 | 4366 | 519 | 0 | 17 | 5279 |
| ReleaseSafe | 392 | 8548 | 1132 | 0 | 16 | 10076 |
| Debug | 392 | 28614 | 1536 | 0 | 24 | 30544 |

### debug_sdi_print_logger_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 3386 | 319 | 0 | 17 | 4127 |
| ReleaseFast | 416 | 4428 | 519 | 0 | 17 | 5367 |
| ReleaseSafe | 416 | 8610 | 1132 | 0 | 16 | 10164 |
| Debug | 416 | 28692 | 1536 | 0 | 24 | 30648 |


## [examples/i2c_blocking](examples/i2c_blocking)

### i2c_blocking_ch32v003_master.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 4078 | 856 | 0 | 8 | 5096 |
| ReleaseFast | 156 | 6358 | 836 | 0 | 8 | 7356 |
| ReleaseSafe | 156 | 11566 | 1168 | 0 | 8 | 12896 |

### i2c_blocking_ch32v003_slave.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 4488 | 1008 | 0 | 8 | 5656 |
| ReleaseFast | 156 | 6260 | 1196 | 0 | 8 | 7612 |
| ReleaseSafe | 156 | 11814 | 1328 | 0 | 8 | 13304 |


## [examples/i2c_bmi160](examples/i2c_bmi160)

### i2c_bmi160_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 6970 | 1188 | 0 | 17 | 8316 |
| ReleaseFast | 156 | 10986 | 1376 | 0 | 17 | 12520 |


## [examples/mco](examples/mco)

### mco_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 406 | 2 | 0 | 0 | 564 |
| ReleaseFast | 156 | 454 | 2 | 0 | 0 | 612 |
| ReleaseSafe | 156 | 528 | 168 | 0 | 0 | 852 |
| Debug | 156 | 5286 | 416 | 0 | 0 | 5864 |

### mco_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 444 | 2 | 0 | 0 | 838 |
| ReleaseFast | 392 | 492 | 2 | 0 | 0 | 886 |
| ReleaseSafe | 392 | 758 | 300 | 0 | 0 | 1452 |
| Debug | 392 | 7316 | 614 | 0 | 0 | 8326 |

### mco_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 460 | 2 | 0 | 0 | 878 |
| ReleaseFast | 416 | 506 | 2 | 0 | 0 | 924 |
| ReleaseSafe | 416 | 772 | 300 | 0 | 0 | 1488 |
| Debug | 416 | 7378 | 614 | 0 | 0 | 8414 |


## [examples/spi](examples/spi)

### spi_ch32v003_master.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1936 | 544 | 0 | 4 | 2640 |
| ReleaseFast | 156 | 2866 | 504 | 0 | 4 | 3528 |
| ReleaseSafe | 156 | 9934 | 1112 | 0 | 4 | 11208 |

### spi_ch32v003_slave.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1928 | 548 | 0 | 4 | 2632 |
| ReleaseFast | 156 | 2786 | 496 | 0 | 4 | 3440 |
| ReleaseSafe | 156 | 9838 | 1096 | 0 | 4 | 11096 |

### spi_ch32v20x_master.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1818 | 732 | 0 | 4 | 2948 |
| ReleaseFast | 392 | 2658 | 692 | 0 | 4 | 3748 |
| ReleaseSafe | 392 | 8528 | 1300 | 0 | 4 | 10220 |

### spi_ch32v20x_slave.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1814 | 732 | 0 | 4 | 2940 |
| ReleaseFast | 392 | 2602 | 676 | 0 | 4 | 3676 |
| ReleaseSafe | 392 | 8470 | 1284 | 0 | 4 | 10148 |

### spi_ch32v30x_master.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1832 | 732 | 0 | 4 | 2980 |
| ReleaseFast | 416 | 2672 | 692 | 0 | 4 | 3780 |
| ReleaseSafe | 416 | 8542 | 1300 | 0 | 4 | 10260 |
| Debug | 416 | 34710 | 2056 | 0 | 12 | 37184 |

### spi_ch32v30x_slave.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1828 | 732 | 0 | 4 | 2976 |
| ReleaseFast | 416 | 2616 | 676 | 0 | 4 | 3708 |
| ReleaseSafe | 416 | 8484 | 1284 | 0 | 4 | 10188 |
| Debug | 416 | 34600 | 2032 | 0 | 12 | 37048 |


## [examples/uart](examples/uart)

### uart_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1536 | 392 | 4 | 4 | 2088 |
| ReleaseFast | 156 | 2172 | 376 | 4 | 4 | 2708 |
| ReleaseSafe | 156 | 3126 | 228 | 4 | 4 | 3516 |

### uart_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1394 | 572 | 4 | 4 | 2364 |
| ReleaseFast | 392 | 1970 | 556 | 4 | 4 | 2924 |
| ReleaseSafe | 392 | 2502 | 408 | 4 | 4 | 3308 |
| Debug | 392 | 29710 | 1772 | 4 | 12 | 31880 |

### uart_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1408 | 572 | 4 | 4 | 2400 |
| ReleaseFast | 416 | 1984 | 556 | 4 | 4 | 2960 |
| ReleaseSafe | 416 | 2516 | 408 | 4 | 4 | 3344 |
| Debug | 416 | 29772 | 1772 | 4 | 12 | 31968 |


## [examples/uart_dma_tx](examples/uart_dma_tx)

### uart_dma_tx_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1324 | 212 | 0 | 4 | 1692 |
| ReleaseFast | 156 | 1802 | 212 | 0 | 4 | 2172 |
| ReleaseSafe | 156 | 3104 | 228 | 0 | 4 | 3488 |

### uart_dma_tx_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1204 | 392 | 0 | 4 | 1988 |
| ReleaseFast | 392 | 1594 | 392 | 0 | 4 | 2380 |
| ReleaseSafe | 392 | 2484 | 408 | 0 | 4 | 3284 |
| Debug | 392 | 29052 | 1740 | 0 | 12 | 31188 |

### uart_dma_tx_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1218 | 392 | 0 | 4 | 2028 |
| ReleaseFast | 416 | 1608 | 392 | 0 | 4 | 2416 |
| ReleaseSafe | 416 | 2498 | 408 | 0 | 4 | 3324 |
| Debug | 416 | 29114 | 1740 | 0 | 12 | 31276 |


## [examples/uart_dma_tx_irq](examples/uart_dma_tx_irq)

### uart_dma_tx_irq_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1462 | 220 | 0 | 4 | 1840 |
| ReleaseFast | 156 | 1954 | 220 | 0 | 4 | 2332 |
| ReleaseSafe | 156 | 3254 | 236 | 0 | 4 | 3648 |

### uart_dma_tx_irq_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1302 | 400 | 0 | 4 | 2096 |
| ReleaseFast | 392 | 1776 | 400 | 0 | 4 | 2568 |
| ReleaseSafe | 392 | 2666 | 416 | 0 | 4 | 3476 |

### uart_dma_tx_irq_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1316 | 400 | 0 | 4 | 2132 |
| ReleaseFast | 416 | 1790 | 400 | 0 | 4 | 2608 |
| ReleaseSafe | 416 | 2680 | 416 | 0 | 4 | 3512 |
| Debug | 416 | 32226 | 1772 | 0 | 12 | 34420 |


## [examples/uart_echo](examples/uart_echo)

### uart_echo_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1380 | 456 | 0 | 4 | 1992 |
| ReleaseFast | 156 | 1570 | 448 | 0 | 4 | 2176 |
| ReleaseSafe | 156 | 1452 | 240 | 0 | 4 | 1848 |

### uart_echo_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1308 | 636 | 0 | 4 | 2336 |
| ReleaseFast | 392 | 1468 | 628 | 0 | 4 | 2488 |
| ReleaseSafe | 392 | 1390 | 420 | 0 | 4 | 2204 |

### uart_echo_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1322 | 636 | 0 | 4 | 2376 |
| ReleaseFast | 416 | 1482 | 628 | 0 | 4 | 2528 |
| ReleaseSafe | 416 | 1404 | 420 | 0 | 4 | 2240 |
| Debug | 416 | 32204 | 1948 | 0 | 12 | 34572 |


## [examples/uart_logger](examples/uart_logger)

### uart_logger_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 4124 | 520 | 4 | 16 | 4804 |
| ReleaseFast | 156 | 5748 | 720 | 4 | 16 | 6628 |
| ReleaseSafe | 156 | 10770 | 1432 | 4 | 16 | 12364 |

### uart_logger_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 3870 | 704 | 4 | 16 | 4972 |
| ReleaseFast | 392 | 5112 | 904 | 4 | 16 | 6412 |
| ReleaseSafe | 392 | 9188 | 1612 | 4 | 16 | 11200 |

### uart_logger_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 3924 | 704 | 4 | 16 | 5052 |
| ReleaseFast | 416 | 5166 | 904 | 4 | 16 | 6492 |
| ReleaseSafe | 416 | 9242 | 1612 | 4 | 16 | 11280 |
| Debug | 416 | 36758 | 2072 | 4 | 24 | 39252 |



This document was generated by `size-benchmark.sh` script.
