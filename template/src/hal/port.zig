const std = @import("std");
const config = @import("config");
const svd = @import("svd");

pub fn enable(p: svd.peripherals.GPIO) void {
    const pos = bitOffset(p.addr()) + IOPAEN_bit_offset;
    svd.peripherals.RCC.APB2PCENR.setBit(pos, 1);
}

pub fn disable(p: svd.peripherals.GPIO) void {
    const pos = bitOffset(p.addr()) + IOPAEN_bit_offset;
    svd.peripherals.RCC.APB2PCENR.setBit(pos, 0);
}

pub fn bitOffset(port_addr: u32) u5 {
    const port_A_addr = svd.peripherals.GPIO.GPIOA.addr();
    return @truncate((port_addr - port_A_addr) / GPIO_distance);
}

const IOPAEN_bit_offset: u5 = @bitOffsetOf(@TypeOf(svd.peripherals.RCC.APB2PCENR.default()), "IOPAEN");

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
