const config = @import("config");
const std = @import("std");
const svd = @import("svd");
const core = @import("core/core.zig");
const hal = @import("hal/hal.zig");

comptime {
    _ = core;
}

pub const std_options: std.Options = .{
    .log_level = .debug,
    .logFn = core.log.logFn,
};

pub const panic = core.panic.log;

pub const interrups: core.Interrups = .{};

var USART1: hal.Uart = undefined;

pub fn main() !void {
    hal.debug.sdi_print.enable();
    // core.log.setWriter(hal.debug.sdi_print.writer().any());

    // Set clock to 48MHz.
    const clock = hal.clock.setOrGet(.hsi_48mhz);

    USART1 = hal.Uart.init(.USART1, .{});
    USART1.configureBaudRate(.{
        .peripheral_clock = switch (config.chip_series) {
            .ch32v003 => clock.hb,
            else => clock.pb2,
        },
        .baud_rate = 115_200,
    });
    // USART1.deinit();

    core.log.setWriter(USART1.writer().any());

    // SPI работает, но есть проблема с чувствительностью к шумам.
    // Если одновременно идёт передача по MISO и MOSI то данные бъются и получается каша (привет cross-talk).
    // Так же есть проблема с NSS, при включении Hardware на Slave он может не работать корректно.
    // Одно из решений сделать NSS как software, что отключит его распознование и МК будет думать что NSS всегда low.
    // Но лучше всего использовать короткие провода с экраном, а на плате между пинами сделать землю.
    // const SPI1 = try hal.Spi.init(.SPI1, .{
    //     .mode = if (config.chip_series == .ch32v003) .slave else .master,
    //     // .pins = hal.Spi.Pins.softwareNss(hal.Spi.Pins.spi1.default, hal.Spi.Pins.spi1.default.nss.?.pin),
    //     .cpol = .high,
    //     .cpha = .second_edge,
    // });
    // SPI1.configureBaudRate(.{
    //     .peripheral_clock = switch (config.chip_series) {
    //         .ch32v003 => clock.hb,
    //         else => clock.pb2,
    //     },
    //     .baud_rate = 750_000,
    // });
    // SPI1.deinit();

    const I2C1 = hal.I2c.init(.I2C1, .{});
    try I2C1.configureBaudRate(.{
        .peripheral_clock = switch (config.chip_series) {
            .ch32v003 => clock.hb,
            else => clock.pb2,
        },
        .speed = 400_000,
        .duty_cycle = .@"16/9",
    });
    // I2C1.deinit();

    const led = switch (config.chip_series) {
        .ch32v003 => hal.Pin.init(.GPIOC, 0),
        .ch32v30x => hal.Pin.init(.GPIOA, 3),
        else => @compileError("Unsupported chip series"),
    };
    hal.port.enable(led.port);
    // hal.port.disable(led.port);
    led.asOutput(.{ .speed = .max_50mhz, .mode = .push_pull });

    _ = try USART1.writeBlocking("Hello, World!\r\n", hal.deadline.simple(100_000));

    var buffer: [256]u8 = undefined;
    _ = try USART1.writeVecBlocking(&.{ "HB clock: ", intToStr(&buffer, clock.hb), "\r\n" }, null);

    try setupBMI160(I2C1);

    var count: u32 = 0;
    while (true) {
        try updateBMI160(I2C1);

        count += 1;

        // var spiBuf: [18 * 2]u8 = undefined;
        // const spiSend = if (config.chip_series == .ch32v003) "World___" else "Hello___";
        // _ = SPI1.transferBlocking(u8, spiSend, &spiBuf, null) catch 0;
        // _ = try USART1.writeVecBlocking(&.{ "SPI recv: ", &spiBuf, "\r\n" }, null);
        //
        // _ = hal.debug.sdi_print.transfer("SPI recv: ", null);
        // _ = hal.debug.sdi_print.transfer(try std.fmt.bufPrint(&buffer, "{x} {s}", .{ spiBuf, spiBuf }), null);
        // _ = hal.debug.sdi_print.transfer("\r\n", null);
        //
        // if (config.chip_series != .ch32v003) {
        //     var i: u32 = 0;
        //     while (i < 1_000_000) : (i += 1) {
        //         // ZIG please don't optimize this loop away.
        //         asm volatile ("" ::: "memory");
        //     }
        // }

        // led.toggle();
        const on = led.read();
        led.write(!on);

        // Print counter to UART.
        // _ = try USART1.writeVecBlocking(&.{ "Counter: ", intToStr(&buffer, count), "\r\n" }, null);

        // // Print and read from debug print.
        // // Use `minichlink -T` for open terminal.
        // var recvBuf: [32]u8 = undefined;
        // var len = hal.debug.sdi_print.transfer("Hello Debug Print: ", &recvBuf);
        // len += hal.debug.sdi_print.transfer(intToStr(&buffer, count), recvBuf[len..]);
        // len += hal.debug.sdi_print.transfer("\r\n", recvBuf[len..]);
        // if (len > 0) {
        //     // Print received data to UART.
        //     _ = try USART1.writeVecBlocking(&.{ "Debug recv: ", recvBuf[0..len], "\r\n" }, null);
        // }

        // Read from uart.
        // const recvLen = USART1.readBlocking(&buffer, hal.deadline.simple(1_000_000)) catch 0;
        // _ = try USART1.writeVecBlocking(&.{ "UART recv: ", buffer[0..recvLen], "\r\n" }, null);

        var i: u32 = 0;
        while (i < 1_000_000) : (i += 1) {
            // ZIG please don't optimize this loop away.
            asm volatile ("" ::: "memory");
        }
    }
}

const BMI160_I2C_ADDR = 0x68;
// https://github.com/LiquidCGS/FastIMU/blob/main/src/F_BMI160.cpp
fn setupBMI160(I2C1: hal.I2c) !void {
    const BMI160_CHIP_ID = 0x00;
    const BMI160_CHIP_ID_DEFAULT_VALUE = 0xD1;

    const BMI160_RA_CMD = 0x7E;

    const BMI160_GYR_RANGE = 0x43;
    const BMI160_GYR_CONF = 0x42;
    const BMI160_ACC_RANGE = 0x41;
    const BMI160_ACC_CONF = 0x40;

    var i2c_buf = [_]u8{0x00};
    var uart_buf: [64]u8 = undefined;

    // Request CHIP_ID
    _ = try I2C1.masterTransferBlocking(.from7(BMI160_I2C_ADDR), &.{BMI160_CHIP_ID}, &i2c_buf, null);
    _ = try USART1.writeVecBlocking(&.{ "I2C recv: ", intToStr(&uart_buf, i2c_buf[0]), "\r\n" }, null);

    if (i2c_buf[0] != BMI160_CHIP_ID_DEFAULT_VALUE) {
        _ = try USART1.writeBlocking("BMI160 not found!\r\n", null);
        return error.BMI160NotFound;
    }

    _ = try USART1.writeBlocking("BMI160 found!\r\n", null);

    // Soft-reset device.
    _ = try I2C1.masterTransferBlocking(.from7(BMI160_I2C_ADDR), &.{ BMI160_RA_CMD, 0xB6 }, null, null);
    dummyLoop(50000);

    // Power up the accelerometer
    _ = try I2C1.masterTransferBlocking(.from7(BMI160_I2C_ADDR), &.{ BMI160_RA_CMD, 0x11 }, null, null);
    dummyLoop(50000);

    // Power up the gyroscope
    _ = try I2C1.masterTransferBlocking(.from7(BMI160_I2C_ADDR), &.{ BMI160_RA_CMD, 0x15 }, null, null);
    dummyLoop(50000);

    // Set up full-scale range for the accelerometer. 0x0C = 16g
    _ = try I2C1.masterTransferBlocking(.from7(BMI160_I2C_ADDR), &.{ BMI160_ACC_RANGE, 0x0C }, null, null);
    // Set up full-scale range for the gyroscope. 0x00 = 2000dps
    _ = try I2C1.masterTransferBlocking(.from7(BMI160_I2C_ADDR), &.{ BMI160_GYR_RANGE, 0x00 }, null, null);

    // Set Accel ODR to 400hz, BWP mode to Oversample 4, LPF of ~40.5hz
    _ = try I2C1.masterTransferBlocking(.from7(BMI160_I2C_ADDR), &.{ BMI160_ACC_CONF, 0x0A }, null, null);
    // Set Gyro ODR to 400hz, BWP mode to Oversample 4, LPF of ~34.15hz
    _ = try I2C1.masterTransferBlocking(.from7(BMI160_I2C_ADDR), &.{ BMI160_GYR_CONF, 0x0A }, null, null);
}

const ImuData = packed struct {
    acc_x: i16,
    acc_y: i16,
    acc_z: i16,
    gyr_x: i16,
    gyr_y: i16,
    gyr_z: i16,
};

fn updateBMI160(I2C1: hal.I2c) !void {
    // const a_res = 16.0 / 32768.0; //ares value for full range (16g) readings
    // const g_res = 2000.0 / 32768.0; //gres value for full range (2000dps) readings

    var imu_data: ImuData = undefined;

    // Read the 12 raw data registers into data array
    const BMI160_GYR_X_L = 0x0C;
    // Read directly to the structure, thanks `std.mem.asBytes`.
    _ = try I2C1.masterTransferBlocking(.from7(BMI160_I2C_ADDR), &.{BMI160_GYR_X_L}, std.mem.asBytes(&imu_data), null);

    var uart_buf: [256]u8 = undefined;
    _ = try USART1.writeBlocking(try std.fmt.bufPrint(&uart_buf, "{any}\r\n", .{imu_data}), null);
}

fn dummyLoop(cnt: u32) void {
    var i: u32 = 0;
    while (i < cnt) : (i += 1) {
        // ZIG please don't optimize this loop away.
        asm volatile ("" ::: "memory");
    }
}

fn intToStr(buf: []u8, value: u32) []u8 {
    var i: u32 = buf.len;
    var v: u32 = value;
    if (v == 0) {
        buf[0] = '0';
        return buf[0..1];
    }

    while (v > 0) : (v /= 10) {
        i -= 1;
        buf[i] = @as(u8, @truncate(v % 10)) + '0';
    }

    return buf[i..];
}

test {
    _ = hal;
}
