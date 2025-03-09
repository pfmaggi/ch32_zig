const std = @import("std");
const config = @import("config");
const svd = @import("svd");

const IOPAEN_bit_offset: u5 = 2;

pub fn enable(p: svd.peripherals.GPIO) void {
    svd.peripherals.RCC.APB2PCENR.raw |= @as(u32, 1) << (bit_offset(p.addr()) + IOPAEN_bit_offset);
}

pub fn disable(p: svd.peripherals.GPIO) void {
    svd.peripherals.RCC.APB2PCENR.raw &= ~(@as(u32, 1) << (bit_offset(p.addr()) + IOPAEN_bit_offset));
}

pub fn bit_offset(port_addr: u32) u5 {
    const port_A_addr = svd.peripherals.GPIO.GPIOA.addr();
    return @truncate((port_addr - port_A_addr) / GPIO_distance);
}

// Distance between GPIOx registers.
const GPIO_distance: u32 = 0x400;

// Comptime GPIOx_distance check.
comptime {
    const GPIO_info = @typeInfo(svd.peripherals.GPIO);

    var last_field_name_suffix = '-';
    var last_field_value = 0;
    for (GPIO_info.@"enum".fields) |field| {
        const field_suffix = field.name[field.name.len - 1];
        const field_value = field.value;

        // Fill with the first value, as we need something to compare with.
        if (last_field_name_suffix == '-') {
            last_field_name_suffix = field_suffix;
            last_field_value = field_value;
            continue;
        }

        // When the field name differs by the next character, it means it's the next port.
        // We can compare the distance between addresses.
        if (field.name[field.name.len - 1] - last_field_name_suffix == 1) {
            const distance = field_value - last_field_value;
            if (distance != GPIO_distance) {
                @compileError("GPIOx distance is not correct");
            }
            break;
        }

        // Move on to the next field, as the previous condition was not met.
        last_field_name_suffix = field_suffix;
        last_field_value = field_value;
    }
}
