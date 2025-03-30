const std = @import("std");
const config = @import("config");
const hal = @import("hal");

const bmi160 = @import("bmi160.zig");

pub const panic = hal.panic.log;
pub const std_options: std.Options = .{
    .log_level = .debug,
    .logFn = hal.log.logFn,
};

pub fn main() !void {
    const clock = hal.clock.setOrGet(.hsi_max);
    hal.delay.init(clock);

    // Configure UART for logging.

    const USART1 = hal.Uart.init(.USART1, .{});
    USART1.configureBaudRate(.{
        .peripheral_clock = switch (config.chip.series) {
            .ch32v003 => clock.hb,
            else => clock.pb2,
        },
        .baud_rate = 115_200,
    });
    hal.log.setWriter(USART1.writer().any());

    // Configure I2C.
    // The default pins are:
    // For CH32V003: SCL: PC2, SDA: PC1.
    // For CH32V103, CH32V20x and CH32V30x: SCL: PB6, SDA: PB7.
    const I2C1 = hal.I2c.init(.I2C1, .{
        // You can use the default pins for the selected I2C by leaving the field null or remap it to other pins.
        // For example, to use the remapped pins for I2C1 on CH32V003:
        // .pins = hal.I2c.Pins.i2c1.scl_pd1_sda_pd0,
    });
    // You can deinitialize the I2C peripheral if you don't need it anymore.
    defer I2C1.deinit();

    // Runtime baud rate configuration.
    try I2C1.configureBaudRate(.{
        .peripheral_clock = switch (config.chip.series) {
            .ch32v003 => clock.hb,
            else => clock.pb2,
        },
        .speed = 400_000,
        .duty_cycle = .@"16/9",
    });

    // Can be 0x68 or 0x69.
    const BMI160_I2C_ADDR = 0x69;

    bmi160.setup(I2C1, BMI160_I2C_ADDR, null) catch |err| switch (err) {
        error.I2CDeviceNotFound => {
            std.log.err("Device on address 0x{X:0>2} not found", .{BMI160_I2C_ADDR});
            return err;
        },
        error.I2CDeviceNotBMI160 => {
            std.log.err("Device on address 0x{X:0>2} is not BMI160", .{BMI160_I2C_ADDR});
            return err;
        },
        else => return err,
    };

    var imu_data: bmi160.ImuData = undefined;
    while (true) {
        try bmi160.readImuData(I2C1, BMI160_I2C_ADDR, &imu_data, null);

        std.log.info("{any}", .{imu_data});

        hal.delay.ms(50);
    }
}
