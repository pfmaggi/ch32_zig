const std = @import("std");
const config = @import("config");
const hal = @import("hal");
const svd = @import("svd");

// Programmable Fast Interrupt Controller
const PFIC = svd.peripherals.PFIC;

pub const interrupts: hal.interrupts.VectorTable = .{
    .SysTick = sysTickHandler,
};

fn sysTickHandler() callconv(hal.interrupts.call_conv) void {
    // Toggle the LED pin.
    led.toggle();

    // Clear the trigger state for the next interrupt.
    PFIC.STK_SR.modify(.{ .CNTIF = 0 });
}

// Select LED pin based on chip series.
const led: hal.Pin = switch (config.chip.series) {
    .ch32v003 => hal.Pin.init(.GPIOC, 0),
    .ch32v103 => hal.Pin.init(.GPIOC, 0),
    .ch32v20x => hal.Pin.init(.GPIOA, 15), // nanoCH32V203 board
    .ch32v30x => hal.Pin.init(.GPIOA, 3), // nanoCH32V305 board
    // else => @compileError("Unsupported chip series"),
};

pub fn main() !void {
    const clock = hal.clock.Clocks.default;

    hal.port.enable(led.port);

    led.asOutput(.{ .speed = .max_50mhz, .mode = .push_pull });

    // Configure SysTick

    // Reset configuration.
    PFIC.STK_CTLR.write(.{});
    // Reset the Count Register.
    PFIC.STK_CNTL.raw = 0;
    // Set the compare register to trigger once per second.
    PFIC.STK_CMPLR.raw = clock.hb - 1;
    // Set the SysTick Configuration.
    PFIC.STK_CTLR.write(.{
        // Turn on the system counter STK
        .STE = 1,
        // Enable counter interrupt.
        .STIE = 1,
        // HCLK for time base.
        .STCLK = 1,
        // Re-counting from 0 after counting up to the comparison value.
        .STRE = 1,
    });

    // Enable SysTick interrupt.
    hal.interrupts.enable(.SysTick);

    while (true) {
        hal.interrupts.wait();
    }
}
