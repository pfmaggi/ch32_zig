# Basic examples

Basic examples are based on the use of registers, without abstractions. \
All examples have been tested for functionality on `ch32v003`, but since the pin to which the LED is connected may
differ for you, you will need to change the port and pin in the code.

## [001_blink_minimal](001_blink_minimal)

Blinking LED with minimal code in `ZIG`. \
No linker script, no startup code, no standard library, only read/write registers!

## [002_blink_ld_zig](002_blink_ld_zig)

This example uses a global variable that needs to be placed in memory. \
For this, a linker script and a function that initializes the registers and copies data from `FLASH` to `RAM` are
required. \
The data copying function will be implemented in pure `ZIG`.

## [003_blink_ld_asm](003_blink_ld_asm)

The difference from the previous example is that the data copying function will be implemented in assembly, which will
greatly reduce the firmware size when compiled in a mode other than `ReleaseSmall`. \
This function will be used in all subsequent examples.

## [004_blink_systick_interrupt](004_blink_systick_interrupt)

Now we get to interrupts. \
In this example, we will blink the LED using a system timer interrupt.

## [005_blink_uart](005_blink_uart)

We will do a small code refactoring by moving the startup code to a separate file. \
We will add `UART` initialization and output a counter that increments with each LED blink.

## [006_blink_uart_logger](006_blink_uart_logger)

We raise the stakes and connect `std.log` to `UART`! \
Now we can use string formatting and output panic messages to `UART`! \
To demonstrate this, the code will panic when the counter reaches `10`.

## [007_spi_master](007_spi_master)

As an additional example, we will add an `SPI` master that will send `Test`.