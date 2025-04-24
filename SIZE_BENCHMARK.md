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
| Debug | 156 | 2714 | 236 | 0 | 12 | 3108 |

### blink_delay_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 430 | 0 | 0 | 4 | 822 |
| ReleaseFast | 392 | 408 | 0 | 0 | 4 | 800 |
| ReleaseSafe | 392 | 454 | 0 | 0 | 4 | 846 |
| Debug | 392 | 2736 | 244 | 0 | 12 | 3372 |

### blink_delay_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 448 | 0 | 0 | 4 | 864 |
| ReleaseFast | 416 | 426 | 0 | 0 | 4 | 842 |
| ReleaseSafe | 416 | 464 | 0 | 0 | 4 | 880 |
| Debug | 416 | 2814 | 244 | 0 | 12 | 3476 |


## [examples/blink_minimal](examples/blink_minimal)

### blink_minimal_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 268 | 0 | 0 | 0 | 424 |
| ReleaseFast | 156 | 302 | 0 | 0 | 0 | 458 |
| ReleaseSafe | 156 | 304 | 0 | 0 | 0 | 460 |
| Debug | 156 | 1992 | 224 | 0 | 0 | 2376 |

### blink_minimal_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 318 | 0 | 0 | 0 | 710 |
| ReleaseFast | 392 | 354 | 0 | 0 | 0 | 746 |
| ReleaseSafe | 392 | 356 | 0 | 0 | 0 | 748 |
| Debug | 392 | 2324 | 224 | 0 | 0 | 2944 |

### blink_minimal_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 328 | 0 | 0 | 0 | 744 |
| ReleaseFast | 416 | 364 | 0 | 0 | 0 | 780 |
| ReleaseSafe | 416 | 366 | 0 | 0 | 0 | 782 |
| Debug | 416 | 2402 | 224 | 0 | 0 | 3048 |


## [examples/blink_systick_interrupt](examples/blink_systick_interrupt)

### blink_systick_interrupt_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 366 | 8 | 0 | 0 | 532 |
| ReleaseFast | 156 | 416 | 8 | 0 | 0 | 580 |
| ReleaseSafe | 156 | 418 | 8 | 0 | 0 | 584 |
| Debug | 156 | 2096 | 232 | 0 | 0 | 2488 |

### blink_systick_interrupt_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 390 | 8 | 0 | 0 | 792 |
| ReleaseFast | 392 | 440 | 8 | 0 | 0 | 840 |
| ReleaseSafe | 392 | 442 | 8 | 0 | 0 | 844 |
| Debug | 392 | 2448 | 232 | 0 | 0 | 3072 |

### blink_systick_interrupt_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 412 | 8 | 0 | 0 | 836 |
| ReleaseFast | 416 | 462 | 8 | 0 | 0 | 888 |
| ReleaseSafe | 416 | 464 | 8 | 0 | 0 | 888 |
| Debug | 416 | 2686 | 232 | 0 | 0 | 3336 |


## [examples/blink_time_deadline](examples/blink_time_deadline)

### blink_time_deadline_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 832 | 0 | 0 | 8 | 988 |
| ReleaseFast | 156 | 834 | 0 | 0 | 8 | 990 |
| ReleaseSafe | 156 | 886 | 0 | 0 | 8 | 1042 |
| Debug | 156 | 3678 | 264 | 0 | 8 | 4104 |

### blink_time_deadline_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 572 | 0 | 0 | 8 | 964 |
| ReleaseFast | 392 | 564 | 0 | 0 | 8 | 956 |
| ReleaseSafe | 392 | 606 | 0 | 0 | 8 | 998 |
| Debug | 392 | 3668 | 272 | 0 | 8 | 4336 |

### blink_time_deadline_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 582 | 0 | 0 | 8 | 998 |
| ReleaseFast | 416 | 574 | 0 | 0 | 8 | 990 |
| ReleaseSafe | 416 | 616 | 0 | 0 | 8 | 1032 |
| Debug | 416 | 3746 | 272 | 0 | 8 | 4440 |


## [examples/blink_time_delay](examples/blink_time_delay)

### blink_time_delay_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 462 | 0 | 0 | 8 | 618 |
| ReleaseFast | 156 | 444 | 0 | 0 | 8 | 600 |
| ReleaseSafe | 156 | 464 | 0 | 0 | 8 | 620 |
| Debug | 156 | 2552 | 236 | 0 | 8 | 2948 |

### blink_time_delay_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 512 | 0 | 0 | 8 | 904 |
| ReleaseFast | 392 | 496 | 0 | 0 | 8 | 888 |
| ReleaseSafe | 392 | 516 | 0 | 0 | 8 | 908 |
| Debug | 392 | 2876 | 244 | 0 | 8 | 3516 |

### blink_time_delay_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 522 | 0 | 0 | 8 | 938 |
| ReleaseFast | 416 | 506 | 0 | 0 | 8 | 922 |
| ReleaseSafe | 416 | 526 | 0 | 0 | 8 | 942 |
| Debug | 416 | 2954 | 244 | 0 | 8 | 3620 |


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
| Debug | 392 | 28596 | 1536 | 0 | 24 | 30528 |

### debug_sdi_print_logger_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 3386 | 319 | 0 | 17 | 4127 |
| ReleaseFast | 416 | 4428 | 519 | 0 | 17 | 5367 |
| ReleaseSafe | 416 | 8610 | 1132 | 0 | 16 | 10164 |
| Debug | 416 | 28674 | 1536 | 0 | 24 | 30632 |


## [examples/i2c_blocking](examples/i2c_blocking)

### i2c_blocking_ch32v003_master.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 4056 | 856 | 0 | 8 | 5072 |
| ReleaseFast | 156 | 5886 | 836 | 0 | 8 | 6884 |
| ReleaseSafe | 156 | 11354 | 1168 | 0 | 8 | 12680 |

### i2c_blocking_ch32v003_slave.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 4492 | 1008 | 0 | 8 | 5656 |
| ReleaseFast | 156 | 6190 | 1196 | 0 | 8 | 7548 |
| ReleaseSafe | 156 | 11736 | 1328 | 0 | 8 | 13224 |


## [examples/i2c_bmi160](examples/i2c_bmi160)

### i2c_bmi160_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 6954 | 1188 | 0 | 17 | 8300 |
| ReleaseFast | 156 | 10754 | 1376 | 0 | 17 | 12288 |


## [examples/mco](examples/mco)

### mco_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 406 | 2 | 0 | 0 | 564 |
| ReleaseFast | 156 | 454 | 2 | 0 | 0 | 612 |
| ReleaseSafe | 156 | 528 | 168 | 0 | 0 | 852 |
| Debug | 156 | 5304 | 416 | 0 | 0 | 5880 |

### mco_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 444 | 2 | 0 | 0 | 838 |
| ReleaseFast | 392 | 492 | 2 | 0 | 0 | 886 |
| ReleaseSafe | 392 | 758 | 300 | 0 | 0 | 1452 |
| Debug | 392 | 7334 | 614 | 0 | 0 | 8342 |

### mco_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 460 | 2 | 0 | 0 | 878 |
| ReleaseFast | 416 | 506 | 2 | 0 | 0 | 924 |
| ReleaseSafe | 416 | 772 | 300 | 0 | 0 | 1488 |
| Debug | 416 | 7396 | 614 | 0 | 0 | 8430 |


## [examples/spi](examples/spi)

### spi_ch32v003_master.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 2128 | 544 | 0 | 8 | 2832 |
| ReleaseFast | 156 | 2872 | 504 | 0 | 8 | 3536 |
| ReleaseSafe | 156 | 10038 | 1112 | 0 | 8 | 11312 |

### spi_ch32v003_slave.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 2112 | 548 | 0 | 8 | 2816 |
| ReleaseFast | 156 | 2788 | 496 | 0 | 8 | 3440 |
| ReleaseSafe | 156 | 9922 | 1096 | 0 | 8 | 11176 |

### spi_ch32v20x_master.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 2042 | 732 | 0 | 8 | 3172 |
| ReleaseFast | 392 | 2716 | 692 | 0 | 8 | 3804 |
| ReleaseSafe | 392 | 8594 | 1300 | 0 | 8 | 10292 |

### spi_ch32v20x_slave.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 2038 | 732 | 0 | 8 | 3164 |
| ReleaseFast | 392 | 2654 | 676 | 0 | 8 | 3724 |
| ReleaseSafe | 392 | 8540 | 1284 | 0 | 8 | 10220 |

### spi_ch32v30x_master.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 2056 | 732 | 0 | 8 | 3204 |
| ReleaseFast | 416 | 2730 | 692 | 0 | 8 | 3844 |
| ReleaseSafe | 416 | 8608 | 1300 | 0 | 8 | 10324 |
| Debug | 416 | 35934 | 2068 | 0 | 8 | 38420 |

### spi_ch32v30x_slave.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 2052 | 732 | 0 | 8 | 3200 |
| ReleaseFast | 416 | 2668 | 676 | 0 | 8 | 3764 |
| ReleaseSafe | 416 | 8554 | 1284 | 0 | 8 | 10260 |
| Debug | 416 | 35830 | 2044 | 0 | 8 | 38292 |


## [examples/uart](examples/uart)

### uart_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1958 | 416 | 0 | 8 | 2532 |
| ReleaseFast | 156 | 2432 | 376 | 0 | 8 | 2964 |
| ReleaseSafe | 156 | 3122 | 240 | 0 | 8 | 3520 |

### uart_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1798 | 596 | 0 | 8 | 2788 |
| ReleaseFast | 392 | 2150 | 556 | 0 | 8 | 3100 |
| ReleaseSafe | 392 | 2594 | 420 | 0 | 8 | 3408 |
| Debug | 392 | 30012 | 1796 | 0 | 8 | 32204 |

### uart_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1812 | 596 | 0 | 8 | 2824 |
| ReleaseFast | 416 | 2164 | 556 | 0 | 8 | 3136 |
| ReleaseSafe | 416 | 2608 | 420 | 0 | 8 | 3444 |
| Debug | 416 | 30074 | 1796 | 0 | 8 | 32292 |


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
| Debug | 392 | 29054 | 1740 | 0 | 12 | 31188 |

### uart_dma_tx_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1218 | 392 | 0 | 4 | 2028 |
| ReleaseFast | 416 | 1608 | 392 | 0 | 4 | 2416 |
| ReleaseSafe | 416 | 2498 | 408 | 0 | 4 | 3324 |
| Debug | 416 | 29116 | 1740 | 0 | 12 | 31276 |


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
| Debug | 416 | 32228 | 1772 | 0 | 12 | 34420 |


## [examples/uart_echo](examples/uart_echo)

### uart_echo_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1752 | 456 | 0 | 8 | 2364 |
| ReleaseFast | 156 | 1674 | 448 | 0 | 8 | 2280 |
| ReleaseSafe | 156 | 1574 | 240 | 0 | 8 | 1972 |

### uart_echo_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1692 | 636 | 0 | 8 | 2720 |
| ReleaseFast | 392 | 1572 | 628 | 0 | 8 | 2592 |
| ReleaseSafe | 392 | 1510 | 420 | 0 | 8 | 2324 |

### uart_echo_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1706 | 636 | 0 | 8 | 2760 |
| ReleaseFast | 416 | 1586 | 628 | 0 | 8 | 2632 |
| ReleaseSafe | 416 | 1524 | 420 | 0 | 8 | 2360 |
| Debug | 416 | 33540 | 1960 | 0 | 8 | 35920 |


## [examples/uart_logger](examples/uart_logger)

### uart_logger_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 4144 | 520 | 0 | 16 | 4824 |
| ReleaseFast | 156 | 5610 | 720 | 0 | 16 | 6488 |
| ReleaseSafe | 156 | 10262 | 1432 | 0 | 16 | 11856 |

### uart_logger_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 3908 | 704 | 0 | 16 | 5008 |
| ReleaseFast | 392 | 4998 | 904 | 0 | 16 | 6296 |
| ReleaseSafe | 392 | 8930 | 1612 | 0 | 16 | 10940 |

### uart_logger_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 3962 | 704 | 0 | 16 | 5088 |
| ReleaseFast | 416 | 5052 | 904 | 0 | 16 | 6376 |
| ReleaseSafe | 416 | 8984 | 1612 | 0 | 16 | 11012 |
| Debug | 416 | 37212 | 2084 | 0 | 20 | 39716 |



This document was generated by `size-benchmark.sh` script.
