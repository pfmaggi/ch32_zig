# Size benchmark

This document contains the size in bytes of the firmware for each optimize mode.

## [examples/adc_polling](examples/adc_polling)

### adc_polling_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1506 | 208 | 0 | 4 | 1872 |
| ReleaseFast | 156 | 2028 | 204 | 0 | 4 | 2388 |
| ReleaseSafe | 156 | 9266 | 948 | 0 | 4 | 10372 |


## [examples/adc_scan_dma](examples/adc_scan_dma)

### adc_scan_dma_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1902 | 216 | 0 | 20 | 2276 |
| ReleaseFast | 156 | 2716 | 208 | 0 | 20 | 3080 |
| ReleaseSafe | 156 | 9988 | 952 | 0 | 20 | 11096 |


## [examples/blink_delay](examples/blink_delay)

### blink_delay_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 428 | 0 | 0 | 4 | 584 |
| ReleaseFast | 156 | 426 | 0 | 0 | 4 | 582 |
| ReleaseSafe | 156 | 726 | 0 | 0 | 4 | 882 |
| Debug | 156 | 3174 | 236 | 0 | 12 | 3572 |

### blink_delay_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 436 | 0 | 0 | 4 | 828 |
| ReleaseFast | 392 | 414 | 0 | 0 | 4 | 806 |
| ReleaseSafe | 392 | 460 | 0 | 0 | 4 | 852 |
| Debug | 392 | 3094 | 244 | 0 | 12 | 3732 |

### blink_delay_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 452 | 0 | 0 | 4 | 868 |
| ReleaseFast | 416 | 430 | 0 | 0 | 4 | 846 |
| ReleaseSafe | 416 | 468 | 0 | 0 | 4 | 884 |
| Debug | 416 | 3294 | 244 | 0 | 12 | 3956 |


## [examples/blink_minimal](examples/blink_minimal)

### blink_minimal_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 294 | 0 | 0 | 0 | 450 |
| ReleaseFast | 156 | 328 | 0 | 0 | 0 | 484 |
| ReleaseSafe | 156 | 330 | 0 | 0 | 0 | 486 |
| Debug | 156 | 2452 | 224 | 0 | 0 | 2832 |

### blink_minimal_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 324 | 0 | 0 | 0 | 716 |
| ReleaseFast | 392 | 360 | 0 | 0 | 0 | 752 |
| ReleaseSafe | 392 | 362 | 0 | 0 | 0 | 754 |
| Debug | 392 | 2682 | 224 | 0 | 0 | 3304 |

### blink_minimal_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 332 | 0 | 0 | 0 | 748 |
| ReleaseFast | 416 | 368 | 0 | 0 | 0 | 784 |
| ReleaseSafe | 416 | 370 | 0 | 0 | 0 | 786 |
| Debug | 416 | 2882 | 224 | 0 | 0 | 3528 |


## [examples/blink_systick_interrupt](examples/blink_systick_interrupt)

### blink_systick_interrupt_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 392 | 8 | 0 | 0 | 556 |
| ReleaseFast | 156 | 442 | 8 | 0 | 0 | 608 |
| ReleaseSafe | 156 | 444 | 8 | 0 | 0 | 608 |
| Debug | 156 | 2556 | 232 | 0 | 0 | 2944 |

### blink_systick_interrupt_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 396 | 8 | 0 | 0 | 796 |
| ReleaseFast | 392 | 446 | 8 | 0 | 0 | 848 |
| ReleaseSafe | 392 | 448 | 8 | 0 | 0 | 848 |
| Debug | 392 | 2806 | 232 | 0 | 0 | 3432 |

### blink_systick_interrupt_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 416 | 8 | 0 | 0 | 840 |
| ReleaseFast | 416 | 466 | 8 | 0 | 0 | 892 |
| ReleaseSafe | 416 | 468 | 8 | 0 | 0 | 892 |
| Debug | 416 | 3166 | 232 | 0 | 0 | 3816 |


## [examples/blink_time_deadline](examples/blink_time_deadline)

### blink_time_deadline_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 858 | 0 | 0 | 8 | 1014 |
| ReleaseFast | 156 | 860 | 0 | 0 | 8 | 1016 |
| ReleaseSafe | 156 | 912 | 0 | 0 | 8 | 1068 |
| Debug | 156 | 4138 | 264 | 0 | 8 | 4560 |

### blink_time_deadline_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 578 | 0 | 0 | 8 | 970 |
| ReleaseFast | 392 | 570 | 0 | 0 | 8 | 962 |
| ReleaseSafe | 392 | 612 | 0 | 0 | 8 | 1004 |
| Debug | 392 | 4026 | 272 | 0 | 8 | 4696 |

### blink_time_deadline_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 586 | 0 | 0 | 8 | 1002 |
| ReleaseFast | 416 | 578 | 0 | 0 | 8 | 994 |
| ReleaseSafe | 416 | 620 | 0 | 0 | 8 | 1036 |
| Debug | 416 | 4226 | 272 | 0 | 8 | 4920 |


## [examples/blink_time_delay](examples/blink_time_delay)

### blink_time_delay_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 488 | 0 | 0 | 8 | 644 |
| ReleaseFast | 156 | 470 | 0 | 0 | 8 | 626 |
| ReleaseSafe | 156 | 490 | 0 | 0 | 8 | 646 |
| Debug | 156 | 3012 | 236 | 0 | 8 | 3404 |

### blink_time_delay_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 518 | 0 | 0 | 8 | 910 |
| ReleaseFast | 392 | 502 | 0 | 0 | 8 | 894 |
| ReleaseSafe | 392 | 522 | 0 | 0 | 8 | 914 |
| Debug | 392 | 3234 | 244 | 0 | 8 | 3876 |

### blink_time_delay_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 526 | 0 | 0 | 8 | 942 |
| ReleaseFast | 416 | 510 | 0 | 0 | 8 | 926 |
| ReleaseSafe | 416 | 530 | 0 | 0 | 8 | 946 |
| Debug | 416 | 3434 | 244 | 0 | 8 | 4100 |


## [examples/debug_sdi_print](examples/debug_sdi_print)

### debug_sdi_print_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1044 | 26 | 0 | 4 | 1226 |
| ReleaseFast | 156 | 1466 | 26 | 0 | 4 | 1648 |
| ReleaseSafe | 156 | 9570 | 700 | 0 | 4 | 10428 |

### debug_sdi_print_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 686 | 26 | 0 | 4 | 1104 |
| ReleaseFast | 392 | 1054 | 26 | 0 | 4 | 1472 |
| ReleaseSafe | 392 | 7656 | 700 | 0 | 4 | 8748 |
| Debug | 392 | 19382 | 1184 | 0 | 12 | 20960 |

### debug_sdi_print_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 706 | 26 | 0 | 4 | 1148 |
| ReleaseFast | 416 | 1074 | 26 | 0 | 4 | 1516 |
| ReleaseSafe | 416 | 7676 | 700 | 0 | 4 | 8792 |
| Debug | 416 | 19582 | 1184 | 0 | 12 | 21184 |


## [examples/debug_sdi_print_logger](examples/debug_sdi_print_logger)

### debug_sdi_print_logger_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 3726 | 319 | 0 | 17 | 4207 |
| ReleaseFast | 156 | 5244 | 519 | 0 | 17 | 5919 |
| ReleaseSafe | 156 | 10404 | 1132 | 0 | 16 | 11692 |

### debug_sdi_print_logger_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 3328 | 319 | 0 | 17 | 4039 |
| ReleaseFast | 392 | 4374 | 519 | 0 | 17 | 5287 |
| ReleaseSafe | 392 | 8554 | 1132 | 0 | 16 | 10084 |
| Debug | 392 | 28954 | 1536 | 0 | 24 | 30888 |

### debug_sdi_print_logger_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 3388 | 319 | 0 | 17 | 4127 |
| ReleaseFast | 416 | 4434 | 519 | 0 | 17 | 5375 |
| ReleaseSafe | 416 | 8614 | 1132 | 0 | 16 | 10164 |
| Debug | 416 | 29154 | 1536 | 0 | 24 | 31112 |


## [examples/i2c_blocking](examples/i2c_blocking)

### i2c_blocking_ch32v003_master.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 4082 | 832 | 0 | 8 | 5072 |
| ReleaseFast | 156 | 5914 | 812 | 0 | 8 | 6884 |
| ReleaseSafe | 156 | 11380 | 1168 | 0 | 8 | 12704 |

### i2c_blocking_ch32v003_slave.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 4518 | 984 | 0 | 8 | 5664 |
| ReleaseFast | 156 | 6218 | 1172 | 0 | 8 | 7548 |
| ReleaseSafe | 156 | 11762 | 1328 | 0 | 8 | 13248 |


## [examples/i2c_bmi160](examples/i2c_bmi160)

### i2c_bmi160_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 6978 | 1172 | 0 | 17 | 8308 |
| ReleaseFast | 156 | 10774 | 1360 | 0 | 17 | 12296 |


## [examples/mco](examples/mco)

### mco_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 432 | 2 | 0 | 0 | 590 |
| ReleaseFast | 156 | 480 | 2 | 0 | 0 | 638 |
| ReleaseSafe | 156 | 554 | 168 | 0 | 0 | 880 |
| Debug | 156 | 5764 | 416 | 0 | 0 | 6336 |

### mco_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 450 | 2 | 0 | 0 | 844 |
| ReleaseFast | 392 | 498 | 2 | 0 | 0 | 892 |
| ReleaseSafe | 392 | 764 | 300 | 0 | 0 | 1456 |
| Debug | 392 | 7692 | 614 | 0 | 0 | 8702 |

### mco_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 464 | 2 | 0 | 0 | 882 |
| ReleaseFast | 416 | 510 | 2 | 0 | 0 | 928 |
| ReleaseSafe | 416 | 776 | 300 | 0 | 0 | 1492 |
| Debug | 416 | 7876 | 614 | 0 | 0 | 8910 |


## [examples/spi](examples/spi)

### spi_ch32v003_master.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 2156 | 488 | 0 | 8 | 2800 |
| ReleaseFast | 156 | 2900 | 448 | 0 | 8 | 3504 |
| ReleaseSafe | 156 | 10064 | 1112 | 0 | 8 | 11336 |

### spi_ch32v003_slave.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 2140 | 492 | 0 | 8 | 2788 |
| ReleaseFast | 156 | 2816 | 432 | 0 | 8 | 3408 |
| ReleaseSafe | 156 | 9948 | 1096 | 0 | 8 | 11200 |

### spi_ch32v20x_master.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 2050 | 676 | 0 | 8 | 3124 |
| ReleaseFast | 392 | 2732 | 636 | 0 | 8 | 3764 |
| ReleaseSafe | 392 | 8600 | 1300 | 0 | 8 | 10292 |

### spi_ch32v20x_slave.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 2046 | 676 | 0 | 8 | 3116 |
| ReleaseFast | 392 | 2670 | 620 | 0 | 8 | 3684 |
| ReleaseSafe | 392 | 8546 | 1284 | 0 | 8 | 10228 |

### spi_ch32v30x_master.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 2062 | 676 | 0 | 8 | 3156 |
| ReleaseFast | 416 | 2744 | 636 | 0 | 8 | 3796 |
| ReleaseSafe | 416 | 8612 | 1300 | 0 | 8 | 10332 |
| Debug | 416 | 36414 | 2068 | 0 | 8 | 38900 |

### spi_ch32v30x_slave.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 2058 | 676 | 0 | 8 | 3152 |
| ReleaseFast | 416 | 2682 | 620 | 0 | 8 | 3724 |
| ReleaseSafe | 416 | 8558 | 1284 | 0 | 8 | 10260 |
| Debug | 416 | 36310 | 2044 | 0 | 8 | 38772 |


## [examples/uart](examples/uart)

### uart_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1984 | 360 | 0 | 8 | 2500 |
| ReleaseFast | 156 | 2458 | 316 | 0 | 8 | 2932 |
| ReleaseSafe | 156 | 3148 | 240 | 0 | 8 | 3544 |

### uart_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1804 | 540 | 0 | 8 | 2736 |
| ReleaseFast | 392 | 2156 | 496 | 0 | 8 | 3044 |
| ReleaseSafe | 392 | 2600 | 420 | 0 | 8 | 3412 |
| Debug | 392 | 30370 | 1796 | 0 | 8 | 32564 |

### uart_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1816 | 540 | 0 | 8 | 2772 |
| ReleaseFast | 416 | 2168 | 496 | 0 | 8 | 3080 |
| ReleaseSafe | 416 | 2612 | 420 | 0 | 8 | 3448 |
| Debug | 416 | 30554 | 1796 | 0 | 8 | 32772 |


## [examples/uart_dma_tx](examples/uart_dma_tx)

### uart_dma_tx_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1350 | 212 | 0 | 4 | 1720 |
| ReleaseFast | 156 | 1828 | 212 | 0 | 4 | 2196 |
| ReleaseSafe | 156 | 3130 | 228 | 0 | 4 | 3516 |

### uart_dma_tx_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1210 | 392 | 0 | 4 | 1996 |
| ReleaseFast | 392 | 1600 | 392 | 0 | 4 | 2384 |
| ReleaseSafe | 392 | 2490 | 408 | 0 | 4 | 3292 |
| Debug | 392 | 29412 | 1740 | 0 | 12 | 31548 |

### uart_dma_tx_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1222 | 392 | 0 | 4 | 2032 |
| ReleaseFast | 416 | 1612 | 392 | 0 | 4 | 2420 |
| ReleaseSafe | 416 | 2502 | 408 | 0 | 4 | 3328 |
| Debug | 416 | 29596 | 1740 | 0 | 12 | 31756 |


## [examples/uart_dma_tx_irq](examples/uart_dma_tx_irq)

### uart_dma_tx_irq_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1488 | 220 | 0 | 4 | 1864 |
| ReleaseFast | 156 | 1980 | 220 | 0 | 4 | 2356 |
| ReleaseSafe | 156 | 3280 | 236 | 0 | 4 | 3672 |

### uart_dma_tx_irq_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1308 | 400 | 0 | 4 | 2100 |
| ReleaseFast | 392 | 1782 | 400 | 0 | 4 | 2576 |
| ReleaseSafe | 392 | 2672 | 416 | 0 | 4 | 3480 |

### uart_dma_tx_irq_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1320 | 400 | 0 | 4 | 2136 |
| ReleaseFast | 416 | 1794 | 400 | 0 | 4 | 2612 |
| ReleaseSafe | 416 | 2684 | 416 | 0 | 4 | 3516 |
| Debug | 416 | 32708 | 1772 | 0 | 12 | 34900 |


## [examples/uart_echo](examples/uart_echo)

### uart_echo_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 1770 | 400 | 0 | 8 | 2328 |
| ReleaseFast | 156 | 1700 | 392 | 0 | 8 | 2248 |
| ReleaseSafe | 156 | 1600 | 240 | 0 | 8 | 1996 |

### uart_echo_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 1690 | 580 | 0 | 8 | 2664 |
| ReleaseFast | 392 | 1578 | 572 | 0 | 8 | 2544 |
| ReleaseSafe | 392 | 1516 | 420 | 0 | 8 | 2328 |

### uart_echo_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 1702 | 580 | 0 | 8 | 2700 |
| ReleaseFast | 416 | 1590 | 572 | 0 | 8 | 2580 |
| ReleaseSafe | 416 | 1528 | 420 | 0 | 8 | 2364 |
| Debug | 416 | 34020 | 1960 | 0 | 8 | 36400 |


## [examples/uart_logger](examples/uart_logger)

### uart_logger_ch32v003.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 156 | 4168 | 520 | 0 | 16 | 4848 |
| ReleaseFast | 156 | 5634 | 720 | 0 | 16 | 6512 |
| ReleaseSafe | 156 | 10288 | 1432 | 0 | 16 | 11880 |

### uart_logger_ch32v20x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 392 | 3912 | 704 | 0 | 16 | 5008 |
| ReleaseFast | 392 | 5002 | 904 | 0 | 16 | 6304 |
| ReleaseSafe | 392 | 8936 | 1612 | 0 | 16 | 10940 |

### uart_logger_ch32v30x.elf 

| Mode | .init | .text | .rodata | .data | .bss | Total |
|--------|--------|--------|--------|--------|--------|--------|
| ReleaseSmall | 416 | 3964 | 704 | 0 | 16 | 5088 |
| ReleaseFast | 416 | 5054 | 904 | 0 | 16 | 6376 |
| ReleaseSafe | 416 | 8988 | 1612 | 0 | 16 | 11020 |
| Debug | 416 | 37692 | 2084 | 0 | 20 | 40196 |



This document was generated by `size-benchmark.sh` script.
