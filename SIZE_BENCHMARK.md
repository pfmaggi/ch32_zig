# Size benchmark

This document contains the size in bytes of the firmware for each optimize mode.

## [examples/adc_polling](examples/adc_polling)

### adc_polling_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1472 | 208 | 0 | 4 | 1836 |
| ReleaseFast | 156 | 1994 | 204 | 0 | 4 | 2356 |
| ReleaseSafe | 156 | 8860 | 948 | 0 | 4 | 9964 |


## [examples/adc_scan_dma](examples/adc_scan_dma)

### adc_scan_dma_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1868 | 216 | 0 | 20 | 2240 |
| ReleaseFast | 156 | 2682 | 208 | 0 | 20 | 3048 |
| ReleaseSafe | 156 | 9564 | 952 | 0 | 20 | 10672 |


## [examples/blink_delay](examples/blink_delay)

### blink_delay_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 394 | 0 | 0 | 4 | 550 |
| ReleaseFast | 156 | 392 | 0 | 0 | 4 | 548 |
| ReleaseSafe | 156 | 684 | 0 | 0 | 4 | 840 |
| Debug | 156 | 2692 | 236 | 0 | 12 | 3084 |

### blink_delay_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 422 | 0 | 0 | 4 | 814 |
| ReleaseFast | 392 | 400 | 0 | 0 | 4 | 792 |
| ReleaseSafe | 392 | 438 | 0 | 0 | 4 | 830 |
| Debug | 392 | 2716 | 244 | 0 | 12 | 3356 |

### blink_delay_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 440 | 0 | 0 | 4 | 856 |
| ReleaseFast | 416 | 418 | 0 | 0 | 4 | 834 |
| ReleaseSafe | 416 | 448 | 0 | 0 | 4 | 864 |
| Debug | 416 | 2800 | 244 | 0 | 12 | 3460 |


## [examples/blink_minimal](examples/blink_minimal)

### blink_minimal_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 260 | 0 | 0 | 0 | 416 |
| ReleaseFast | 156 | 294 | 0 | 0 | 0 | 450 |
| ReleaseSafe | 156 | 296 | 0 | 0 | 0 | 452 |
| Debug | 156 | 1970 | 224 | 0 | 0 | 2352 |

### blink_minimal_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 310 | 0 | 0 | 0 | 702 |
| ReleaseFast | 392 | 346 | 0 | 0 | 0 | 738 |
| ReleaseSafe | 392 | 348 | 0 | 0 | 0 | 740 |
| Debug | 392 | 2304 | 224 | 0 | 0 | 2920 |

### blink_minimal_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 320 | 0 | 0 | 0 | 736 |
| ReleaseFast | 416 | 356 | 0 | 0 | 0 | 772 |
| ReleaseSafe | 416 | 358 | 0 | 0 | 0 | 774 |
| Debug | 416 | 2388 | 224 | 0 | 0 | 3032 |


## [examples/blink_systick_interrupt](examples/blink_systick_interrupt)

### blink_systick_interrupt_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 368 | 8 | 0 | 0 | 532 |
| ReleaseFast | 156 | 418 | 8 | 0 | 0 | 584 |
| ReleaseSafe | 156 | 420 | 8 | 0 | 0 | 584 |
| Debug | 156 | 2182 | 232 | 0 | 0 | 2576 |

### blink_systick_interrupt_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 396 | 8 | 0 | 0 | 796 |
| ReleaseFast | 392 | 446 | 8 | 0 | 0 | 848 |
| ReleaseSafe | 392 | 448 | 8 | 0 | 0 | 848 |
| Debug | 392 | 2534 | 232 | 0 | 0 | 3160 |

### blink_systick_interrupt_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 418 | 8 | 0 | 0 | 844 |
| ReleaseFast | 416 | 468 | 8 | 0 | 0 | 892 |
| ReleaseSafe | 416 | 470 | 8 | 0 | 0 | 896 |
| Debug | 416 | 2772 | 232 | 0 | 0 | 3424 |


## [examples/blink_time_delay](examples/blink_time_delay)

### blink_time_delay_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 466 | 0 | 0 | 8 | 622 |
| ReleaseFast | 156 | 446 | 0 | 0 | 8 | 602 |
| ReleaseSafe | 156 | 458 | 0 | 0 | 8 | 614 |
| Debug | 156 | 2648 | 236 | 0 | 8 | 3044 |

### blink_time_delay_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 516 | 0 | 0 | 8 | 908 |
| ReleaseFast | 392 | 498 | 0 | 0 | 8 | 890 |
| ReleaseSafe | 392 | 510 | 0 | 0 | 8 | 902 |
| Debug | 392 | 2974 | 244 | 0 | 8 | 3612 |

### blink_time_delay_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 526 | 0 | 0 | 8 | 942 |
| ReleaseFast | 416 | 508 | 0 | 0 | 8 | 924 |
| ReleaseSafe | 416 | 520 | 0 | 0 | 8 | 936 |
| Debug | 416 | 3058 | 244 | 0 | 8 | 3724 |


## [examples/debug_sdi_print](examples/debug_sdi_print)

### debug_sdi_print_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1010 | 26 | 0 | 4 | 1192 |
| ReleaseFast | 156 | 1432 | 26 | 0 | 4 | 1614 |
| ReleaseSafe | 156 | 9148 | 700 | 0 | 4 | 10004 |

### debug_sdi_print_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 672 | 26 | 0 | 4 | 1090 |
| ReleaseFast | 392 | 1040 | 26 | 0 | 4 | 1458 |
| ReleaseSafe | 392 | 7254 | 700 | 0 | 4 | 8348 |
| Debug | 392 | 19022 | 1184 | 0 | 12 | 20600 |

### debug_sdi_print_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 694 | 26 | 0 | 4 | 1136 |
| ReleaseFast | 416 | 1062 | 26 | 0 | 4 | 1504 |
| ReleaseSafe | 416 | 7276 | 700 | 0 | 4 | 8392 |
| Debug | 416 | 19100 | 1184 | 0 | 12 | 20704 |


## [examples/i2c_bmi160](examples/i2c_bmi160)

### i2c_bmi160_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 6680 | 1208 | 4 | 16 | 8048 |
| ReleaseFast | 156 | 10552 | 1400 | 4 | 16 | 12112 |


## [examples/mco](examples/mco)

### mco_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 398 | 2 | 0 | 0 | 556 |
| ReleaseFast | 156 | 446 | 2 | 0 | 0 | 604 |
| ReleaseSafe | 156 | 512 | 168 | 0 | 0 | 836 |
| Debug | 156 | 5284 | 416 | 0 | 0 | 5856 |

### mco_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 436 | 2 | 0 | 0 | 830 |
| ReleaseFast | 392 | 484 | 2 | 0 | 0 | 878 |
| ReleaseSafe | 392 | 718 | 300 | 0 | 0 | 1412 |
| Debug | 392 | 7314 | 614 | 0 | 0 | 8326 |

### mco_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 452 | 2 | 0 | 0 | 870 |
| ReleaseFast | 416 | 498 | 2 | 0 | 0 | 916 |
| ReleaseSafe | 416 | 732 | 300 | 0 | 0 | 1448 |
| Debug | 416 | 7376 | 614 | 0 | 0 | 8406 |


## [examples/spi](examples/spi)

### spi_ch32v003_master.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1920 | 544 | 0 | 4 | 2624 |
| ReleaseFast | 156 | 2850 | 504 | 0 | 4 | 3512 |
| ReleaseSafe | 156 | 9456 | 1112 | 0 | 4 | 10728 |

### spi_ch32v003_slave.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1912 | 548 | 0 | 4 | 2616 |
| ReleaseFast | 156 | 2770 | 496 | 0 | 4 | 3424 |
| ReleaseSafe | 156 | 9384 | 1096 | 0 | 4 | 10640 |

### spi_ch32v20x_master.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1802 | 732 | 0 | 4 | 2932 |
| ReleaseFast | 392 | 2642 | 692 | 0 | 4 | 3732 |
| ReleaseSafe | 392 | 8042 | 1300 | 0 | 4 | 9740 |

### spi_ch32v20x_slave.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1798 | 732 | 0 | 4 | 2924 |
| ReleaseFast | 392 | 2586 | 676 | 0 | 4 | 3660 |
| ReleaseSafe | 392 | 7984 | 1284 | 0 | 4 | 9660 |

### spi_ch32v30x_master.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1816 | 732 | 0 | 4 | 2964 |
| ReleaseFast | 416 | 2656 | 692 | 0 | 4 | 3764 |
| ReleaseSafe | 416 | 8056 | 1300 | 0 | 4 | 9772 |
| Debug | 416 | 34708 | 2056 | 0 | 12 | 37184 |

### spi_ch32v30x_slave.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1812 | 732 | 0 | 4 | 2960 |
| ReleaseFast | 416 | 2600 | 676 | 0 | 4 | 3692 |
| ReleaseSafe | 416 | 7998 | 1284 | 0 | 4 | 9700 |
| Debug | 416 | 34598 | 2032 | 0 | 12 | 37048 |


## [examples/uart](examples/uart)

### uart_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1520 | 392 | 4 | 4 | 2072 |
| ReleaseFast | 156 | 2156 | 376 | 4 | 4 | 2692 |
| ReleaseSafe | 156 | 3076 | 228 | 4 | 4 | 3464 |

### uart_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1378 | 572 | 4 | 4 | 2348 |
| ReleaseFast | 392 | 1954 | 556 | 4 | 4 | 2908 |
| ReleaseSafe | 392 | 2428 | 408 | 4 | 4 | 3232 |
| Debug | 392 | 29708 | 1772 | 4 | 12 | 31880 |

### uart_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1392 | 572 | 4 | 4 | 2384 |
| ReleaseFast | 416 | 1968 | 556 | 4 | 4 | 2944 |
| ReleaseSafe | 416 | 2442 | 408 | 4 | 4 | 3272 |
| Debug | 416 | 29770 | 1772 | 4 | 12 | 31968 |


## [examples/uart_dma_tx](examples/uart_dma_tx)

### uart_dma_tx_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1316 | 212 | 0 | 4 | 1684 |
| ReleaseFast | 156 | 1794 | 212 | 0 | 4 | 2164 |
| ReleaseSafe | 156 | 3038 | 228 | 0 | 4 | 3424 |

### uart_dma_tx_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1196 | 392 | 0 | 4 | 1980 |
| ReleaseFast | 392 | 1586 | 392 | 0 | 4 | 2372 |
| ReleaseSafe | 392 | 2394 | 408 | 0 | 4 | 3196 |
| Debug | 392 | 29068 | 1740 | 0 | 12 | 31204 |

### uart_dma_tx_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1210 | 392 | 0 | 4 | 2020 |
| ReleaseFast | 416 | 1600 | 392 | 0 | 4 | 2408 |
| ReleaseSafe | 416 | 2408 | 408 | 0 | 4 | 3232 |
| Debug | 416 | 29130 | 1740 | 0 | 12 | 31292 |


## [examples/uart_dma_tx_irq](examples/uart_dma_tx_irq)

### uart_dma_tx_irq_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1454 | 220 | 0 | 4 | 1832 |
| ReleaseFast | 156 | 1946 | 220 | 0 | 4 | 2324 |
| ReleaseSafe | 156 | 3188 | 236 | 0 | 4 | 3580 |

### uart_dma_tx_irq_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1294 | 400 | 0 | 4 | 2088 |
| ReleaseFast | 392 | 1768 | 400 | 0 | 4 | 2560 |
| ReleaseSafe | 392 | 2576 | 416 | 0 | 4 | 3384 |

### uart_dma_tx_irq_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1308 | 400 | 0 | 4 | 2124 |
| ReleaseFast | 416 | 1782 | 400 | 0 | 4 | 2600 |
| ReleaseSafe | 416 | 2590 | 416 | 0 | 4 | 3424 |
| Debug | 416 | 32242 | 1772 | 0 | 12 | 34436 |


## [examples/uart_echo](examples/uart_echo)

### uart_echo_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1364 | 456 | 0 | 4 | 1976 |
| ReleaseFast | 156 | 1554 | 448 | 0 | 4 | 2160 |
| ReleaseSafe | 156 | 1418 | 240 | 0 | 4 | 1816 |

### uart_echo_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1292 | 636 | 0 | 4 | 2320 |
| ReleaseFast | 392 | 1452 | 628 | 0 | 4 | 2472 |
| ReleaseSafe | 392 | 1332 | 420 | 0 | 4 | 2144 |

### uart_echo_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1306 | 636 | 0 | 4 | 2360 |
| ReleaseFast | 416 | 1466 | 628 | 0 | 4 | 2512 |
| ReleaseSafe | 416 | 1346 | 420 | 0 | 4 | 2184 |
| Debug | 416 | 32202 | 1948 | 0 | 12 | 34572 |


## [examples/uart_logger](examples/uart_logger)

### uart_logger_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1682 | 248 | 4 | 16 | 2092 |
| ReleaseFast | 156 | 1976 | 452 | 4 | 16 | 2588 |
| ReleaseSafe | 156 | 8860 | 1004 | 4 | 16 | 10024 |

### uart_logger_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1472 | 428 | 4 | 16 | 2296 |
| ReleaseFast | 392 | 1698 | 632 | 4 | 16 | 2728 |
| ReleaseSafe | 392 | 7224 | 1184 | 4 | 16 | 8804 |
| Debug | 392 | 30246 | 1804 | 4 | 24 | 32448 |

### uart_logger_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1486 | 428 | 4 | 16 | 2336 |
| ReleaseFast | 416 | 1712 | 632 | 4 | 16 | 2764 |
| ReleaseSafe | 416 | 7238 | 1184 | 4 | 16 | 8844 |
| Debug | 416 | 30308 | 1804 | 4 | 24 | 32536 |


## [examples/uart_logger_panic](examples/uart_logger_panic)

### uart_logger_panic_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 4070 | 512 | 4 | 16 | 4744 |
| ReleaseFast | 156 | 5720 | 712 | 4 | 16 | 6592 |
| ReleaseSafe | 156 | 10700 | 1424 | 4 | 16 | 12284 |

### uart_logger_panic_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 3848 | 692 | 4 | 16 | 4936 |
| ReleaseFast | 392 | 5122 | 892 | 4 | 16 | 6412 |
| ReleaseSafe | 392 | 9148 | 1604 | 4 | 16 | 11148 |

### uart_logger_panic_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 3902 | 692 | 4 | 16 | 5016 |
| ReleaseFast | 416 | 5176 | 892 | 4 | 16 | 6488 |
| ReleaseSafe | 416 | 9202 | 1604 | 4 | 16 | 11228 |
| Debug | 416 | 36528 | 2064 | 4 | 24 | 39012 |



This document was generated by `size-benchmark.sh` script.
