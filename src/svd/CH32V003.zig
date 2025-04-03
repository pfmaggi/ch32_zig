const std = @import("std");

pub fn RegisterRW(comptime Register: type, comptime Nullable: type) type {
    const size = @bitSizeOf(Register);
    const IntSize = std.meta.Int(.unsigned, size);

    return extern struct {
        raw: IntSize,

        const Self = @This();

        pub inline fn read(self: *volatile Self) Register {
            return @bitCast(self.raw);
        }

        pub inline fn write(self: *volatile Self, value: Register) void {
            self.writeRaw(@bitCast(value));
        }

        pub inline fn modify(self: *volatile Self, new_value: Nullable) void {
            var old_value = self.read();
            inline for (@typeInfo(@TypeOf(new_value)).@"struct".fields) |field| {
                if (@field(new_value, field.name)) |v| {
                    @field(old_value, field.name) = v;
                }
            }
            self.write(old_value);
        }

        /// Write any type to the register. Any unassigned fields will be set to default.
        pub inline fn writeAny(self: *volatile Self, value: anytype) void {
            var reg = self.default();

            const reg_fields = @typeInfo(@TypeOf(value)).@"struct".fields;
            inline for (reg_fields) |field| {
                @field(reg, field.name) = @field(value, field.name);
            }

            self.write(reg);
        }

        /// Modify register with any type.
        /// Fields can have types different from the register fields, such as optional or bool.
        pub inline fn modifyAny(self: *volatile Self, new_value: anytype) void {
            var old_value = self.read();

            inline for (@typeInfo(@TypeOf(new_value)).@"struct".fields) |field| {
                const old_field_value = @field(old_value, field.name);
                const old_field_value_type_info = @typeInfo(@TypeOf(old_field_value));

                const new_field_value = @field(new_value, field.name);
                const new_field_value_type_info = @typeInfo(@TypeOf(new_field_value));
                const is_new_value_optional = new_field_value_type_info == .optional;

                // Unwrap optional type.
                const new_field_value_unwrapped_type_info = if (is_new_value_optional)
                    @typeInfo(new_field_value_type_info.optional.child)
                else
                    new_field_value_type_info;

                // Null fields don't modify the value.
                if (new_field_value_unwrapped_type_info == .null) {
                    continue;
                }

                // Unwrap optional value.
                const new_field_value_unwrapped: @Type(new_field_value_unwrapped_type_info) = if (is_new_value_optional)
                    // Null values don't modify the field.
                    if (new_field_value) |v| v else continue
                else
                    new_field_value;

                // Allow set boolean values.
                const is_u1_type = old_field_value_type_info.int.signedness == .unsigned and old_field_value_type_info.int.bits == 1;
                if (is_u1_type and new_field_value_unwrapped_type_info == .bool) {
                    @field(old_value, field.name) = if (new_field_value_unwrapped) 1 else 0;
                    continue;
                }

                @field(old_value, field.name) = new_field_value_unwrapped;
            }

            self.write(old_value);
        }

        pub inline fn writeRaw(self: *volatile Self, value: IntSize) void {
            self.raw = value;
        }

        pub inline fn setBits(self: *volatile Self, pos: u5, width: u6, value: IntSize) void {
            if (pos + width > size) {
                return;
            }

            const IntSizePlus1 = std.meta.Int(.unsigned, size + 1);
            const mask: IntSize = @as(IntSize, (@as(IntSizePlus1, 1) << width) - 1) << pos;
            self.raw = (self.raw & ~mask) | ((value << pos) & mask);
        }

        pub inline fn setBit(self: *volatile Self, pos: u5, value: u1) void {
            if (pos >= size) {
                return;
            }

            if (value == 1) {
                self.raw |= @as(IntSize, 1) << pos;
            } else {
                self.raw &= ~(@as(IntSize, 1) << pos);
            }
        }

        pub inline fn getBit(self: *volatile Self, pos: u5) u1 {
            if (pos >= size) {
                return 0;
            }

            return @truncate(self.raw >> pos);
        }

        pub inline fn default(_: *volatile Self) Register {
            return Register{};
        }
    };
}

pub const device_name = "CH32V003";
pub const device_revision = "1.2";
pub const device_description = "CH32V003 View File";

pub const peripherals = struct {
    /// Power control
    pub const PWR = types.PWR.from(0x40007000);

    /// Reset and clock control
    pub const RCC = types.RCC.from(0x40021000);

    /// Extend configuration
    pub const EXTEN = types.EXTEN.from(0x40023800);

    /// General purpose I/O
    pub const GPIO = enum(u32) {
        GPIOA = 0x40010800,
        GPIOC = 0x40011000,
        GPIOD = 0x40011400,

        pub inline fn addr(self: GPIO) u32 {
            return @intFromEnum(self);
        }

        pub inline fn get(self: GPIO) *volatile types.GPIO {
            return types.GPIO.from(self.addr());
        }

        pub inline fn from(address: u32) GPIO {
            return types.GPIO.from(address);
        }
    };
    /// General purpose I/O
    pub const GPIOA = GPIO.GPIOA.get();
    /// General purpose I/O
    pub const GPIOC = GPIO.GPIOC.get();
    /// General purpose I/O
    pub const GPIOD = GPIO.GPIOD.get();

    /// Alternate function I/O
    pub const AFIO = types.AFIO.from(0x40010000);

    /// EXTI
    pub const EXTI = types.EXTI.from(0x40010400);

    /// DMA1 controller
    pub const DMA1 = types.DMA1.from(0x40020000);

    /// Independent watchdog
    pub const IWDG = types.IWDG.from(0x40003000);

    /// Window watchdog
    pub const WWDG = types.WWDG.from(0x40002c00);

    /// Advanced timer
    pub const AdvancedTimer = enum(u32) {
        TIM1 = 0x40012c00,

        pub inline fn addr(self: AdvancedTimer) u32 {
            return @intFromEnum(self);
        }

        pub inline fn get(self: AdvancedTimer) *volatile types.AdvancedTimer {
            return types.AdvancedTimer.from(self.addr());
        }

        pub inline fn from(address: u32) AdvancedTimer {
            return types.AdvancedTimer.from(address);
        }
    };
    /// Advanced timer
    pub const TIM1 = AdvancedTimer.TIM1.get();

    /// General purpose timer
    pub const GeneralPurposeTimer = enum(u32) {
        TIM2 = 0x40000000,

        pub inline fn addr(self: GeneralPurposeTimer) u32 {
            return @intFromEnum(self);
        }

        pub inline fn get(self: GeneralPurposeTimer) *volatile types.GeneralPurposeTimer {
            return types.GeneralPurposeTimer.from(self.addr());
        }

        pub inline fn from(address: u32) GeneralPurposeTimer {
            return types.GeneralPurposeTimer.from(address);
        }
    };
    /// General purpose timer
    pub const TIM2 = GeneralPurposeTimer.TIM2.get();

    /// Inter integrated circuit
    pub const I2C = enum(u32) {
        I2C1 = 0x40005400,

        pub inline fn addr(self: I2C) u32 {
            return @intFromEnum(self);
        }

        pub inline fn get(self: I2C) *volatile types.I2C {
            return types.I2C.from(self.addr());
        }

        pub inline fn from(address: u32) I2C {
            return types.I2C.from(address);
        }
    };
    /// Inter integrated circuit
    pub const I2C1 = I2C.I2C1.get();

    /// Serial peripheral interface
    pub const SPI = enum(u32) {
        SPI1 = 0x40013000,

        pub inline fn addr(self: SPI) u32 {
            return @intFromEnum(self);
        }

        pub inline fn get(self: SPI) *volatile types.SPI {
            return types.SPI.from(self.addr());
        }

        pub inline fn from(address: u32) SPI {
            return types.SPI.from(address);
        }
    };
    /// Serial peripheral interface
    pub const SPI1 = SPI.SPI1.get();

    /// Universal synchronous asynchronous receiver transmitter
    pub const USART = enum(u32) {
        USART1 = 0x40013800,

        pub inline fn addr(self: USART) u32 {
            return @intFromEnum(self);
        }

        pub inline fn get(self: USART) *volatile types.USART {
            return types.USART.from(self.addr());
        }

        pub inline fn from(address: u32) USART {
            return types.USART.from(address);
        }
    };
    /// Universal synchronous asynchronous receiver transmitter
    pub const USART1 = USART.USART1.get();

    /// Analog to digital converter
    pub const ADC1 = types.ADC1.from(0x40012400);

    /// Debug support
    pub const DBG = types.DBG.from(0xe000d000);

    /// Device electronic signature
    pub const ESIG = types.ESIG.from(0x1ffff7e0);

    /// FLASH
    pub const FLASH = types.FLASH.from(0x40022000);

    /// Programmable Fast Interrupt Controller
    pub const PFIC = types.PFIC.from(0xe000e000);
};

pub const types = struct {
    /// Power control
    pub const PWR = extern struct {
        pub inline fn from(base: u32) *volatile types.PWR {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.PWR) u32 {
            return @intFromPtr(self);
        }

        /// Power control register (PWR_CTRL)
        CTLR: RegisterRW(packed struct(u32) {
            /// unused [0:0]
            _unused0: u1 = 0,
            /// PDDS [1:1]
            /// Power Down Deep Sleep
            PDDS: u1 = 0,
            /// unused [2:3]
            _unused2: u2 = 0,
            /// PVDE [4:4]
            /// Power Voltage Detector Enable
            PVDE: u1 = 0,
            /// PLS [5:7]
            /// PVD Level Selection
            PLS: u3 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }, nullable_types.PWR.CTLR),

        /// Power control state register (PWR_CSR)
        CSR: RegisterRW(packed struct(u32) {
            /// unused [0:1]
            _unused0: u2 = 0,
            /// PVDO [2:2]
            /// PVD Output
            PVDO: u1 = 0,
            /// padding [3:31]
            _padding: u29 = 0,
        }, nullable_types.PWR.CSR),

        /// Automatic wake-up control state register (PWR_AWUCSR)
        AWUCSR: RegisterRW(packed struct(u32) {
            /// unused [0:0]
            _unused0: u1 = 0,
            /// AWUEN [1:1]
            /// Automatic wake-up enable
            AWUEN: u1 = 0,
            /// padding [2:31]
            _padding: u30 = 0,
        }, nullable_types.PWR.AWUCSR),

        /// Automatic wake window comparison value register (PWR_AWUWR)
        AWUWR: RegisterRW(packed struct(u32) {
            /// AWUWR [0:5]
            /// AWU window value
            AWUWR: u6 = 63,
            /// padding [6:31]
            _padding: u26 = 0,
        }, nullable_types.PWR.AWUWR),

        /// Automatic wake-up prescaler register (PWR_AWUPSC)
        AWUPSC: RegisterRW(packed struct(u32) {
            /// AWUPSC [0:3]
            /// Wake-up prescaler
            AWUPSC: u4 = 0,
            /// padding [4:31]
            _padding: u28 = 0,
        }, nullable_types.PWR.AWUPSC),
    };

    /// Reset and clock control
    pub const RCC = extern struct {
        pub inline fn from(base: u32) *volatile types.RCC {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.RCC) u32 {
            return @intFromPtr(self);
        }

        /// Clock control register
        CTLR: RegisterRW(packed struct(u32) {
            /// HSION [0:0]
            /// Internal High Speed clock enable
            HSION: u1 = 1,
            /// HSIRDY [1:1]
            /// Internal High Speed clock ready flag
            HSIRDY: u1 = 1,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// HSITRIM [3:7]
            /// Internal High Speed clock trimming
            HSITRIM: u5 = 16,
            /// HSICAL [8:15]
            /// Internal High Speed clock Calibration
            HSICAL: u8 = 0,
            /// HSEON [16:16]
            /// External High Speed clock enable
            HSEON: u1 = 0,
            /// HSERDY [17:17]
            /// External High Speed clock ready flag
            HSERDY: u1 = 0,
            /// HSEBYP [18:18]
            /// External High Speed clock Bypass
            HSEBYP: u1 = 0,
            /// CSSON [19:19]
            /// Clock Security System enable
            CSSON: u1 = 0,
            /// unused [20:23]
            _unused20: u4 = 0,
            /// PLLON [24:24]
            /// PLL enable
            PLLON: u1 = 0,
            /// PLLRDY [25:25]
            /// PLL clock ready flag
            PLLRDY: u1 = 0,
            /// padding [26:31]
            _padding: u6 = 0,
        }, nullable_types.RCC.CTLR),

        /// Clock configuration register (RCC_CFGR0)
        CFGR0: RegisterRW(packed struct(u32) {
            /// SW [0:1]
            /// System clock Switch
            SW: u2 = 0,
            /// SWS [2:3]
            /// System Clock Switch Status
            SWS: u2 = 0,
            /// HPRE [4:7]
            /// HB prescaler
            HPRE: u4 = 2,
            /// unused [8:10]
            _unused8: u3 = 0,
            /// ADCPRE [11:15]
            /// ADC prescaler
            ADCPRE: u5 = 0,
            /// PLLSRC [16:16]
            /// PLL entry clock source
            PLLSRC: u1 = 0,
            /// unused [17:23]
            _unused17: u7 = 0,
            /// MCO [24:26]
            /// Microcontroller clock output
            MCO: u3 = 0,
            /// padding [27:31]
            _padding: u5 = 0,
        }, nullable_types.RCC.CFGR0),

        /// Clock interrupt register (RCC_INTR)
        INTR: RegisterRW(packed struct(u32) {
            /// LSIRDYF [0:0]
            /// LSI Ready Interrupt flag
            LSIRDYF: u1 = 0,
            /// unused [1:1]
            _unused1: u1 = 0,
            /// HSIRDYF [2:2]
            /// HSI Ready Interrupt flag
            HSIRDYF: u1 = 0,
            /// HSERDYF [3:3]
            /// HSE Ready Interrupt flag
            HSERDYF: u1 = 0,
            /// PLLRDYF [4:4]
            /// PLL Ready Interrupt flag
            PLLRDYF: u1 = 0,
            /// unused [5:6]
            _unused5: u2 = 0,
            /// CSSF [7:7]
            /// Clock Security System Interrupt flag
            CSSF: u1 = 0,
            /// LSIRDYIE [8:8]
            /// LSI Ready Interrupt Enable
            LSIRDYIE: u1 = 0,
            /// unused [9:9]
            _unused9: u1 = 0,
            /// HSIRDYIE [10:10]
            /// HSI Ready Interrupt Enable
            HSIRDYIE: u1 = 0,
            /// HSERDYIE [11:11]
            /// HSE Ready Interrupt Enable
            HSERDYIE: u1 = 0,
            /// PLLRDYIE [12:12]
            /// PLL Ready Interrupt Enable
            PLLRDYIE: u1 = 0,
            /// unused [13:15]
            _unused13: u3 = 0,
            /// LSIRDYC [16:16]
            /// LSI Ready Interrupt Clear
            LSIRDYC: u1 = 0,
            /// unused [17:17]
            _unused17: u1 = 0,
            /// HSIRDYC [18:18]
            /// HSI Ready Interrupt Clear
            HSIRDYC: u1 = 0,
            /// HSERDYC [19:19]
            /// HSE Ready Interrupt Clear
            HSERDYC: u1 = 0,
            /// PLLRDYC [20:20]
            /// PLL Ready Interrupt Clear
            PLLRDYC: u1 = 0,
            /// unused [21:22]
            _unused21: u2 = 0,
            /// CSSC [23:23]
            /// Clock security system interrupt clear
            CSSC: u1 = 0,
            /// padding [24:31]
            _padding: u8 = 0,
        }, nullable_types.RCC.INTR),

        /// PB2 peripheral reset register (RCC_APB2PRSTR)
        APB2PRSTR: RegisterRW(packed struct(u32) {
            /// AFIORST [0:0]
            /// Alternate function I/O reset
            AFIORST: u1 = 0,
            /// unused [1:1]
            _unused1: u1 = 0,
            /// IOPARST [2:2]
            /// IO port A reset
            IOPARST: u1 = 0,
            /// unused [3:3]
            _unused3: u1 = 0,
            /// IOPCRST [4:4]
            /// IO port C reset
            IOPCRST: u1 = 0,
            /// IOPDRST [5:5]
            /// IO port D reset
            IOPDRST: u1 = 0,
            /// unused [6:8]
            _unused6: u2 = 0,
            _unused8: u1 = 0,
            /// ADC1RST [9:9]
            /// ADC 1 interface reset
            ADC1RST: u1 = 0,
            /// unused [10:10]
            _unused10: u1 = 0,
            /// TIM1RST [11:11]
            /// TIM1 timer reset
            TIM1RST: u1 = 0,
            /// SPI1RST [12:12]
            /// SPI 1 reset
            SPI1RST: u1 = 0,
            /// unused [13:13]
            _unused13: u1 = 0,
            /// USART1RST [14:14]
            /// USART1 reset
            USART1RST: u1 = 0,
            /// padding [15:31]
            _padding: u17 = 0,
        }, nullable_types.RCC.APB2PRSTR),

        /// PB1 peripheral reset register (RCC_APB1PRSTR)
        APB1PRSTR: RegisterRW(packed struct(u32) {
            /// TIM2RST [0:0]
            /// TIM2 reset
            TIM2RST: u1 = 0,
            /// unused [1:10]
            _unused1: u7 = 0,
            _unused8: u3 = 0,
            /// WWDGRST [11:11]
            /// Window watchdog reset
            WWDGRST: u1 = 0,
            /// unused [12:20]
            _unused12: u4 = 0,
            _unused16: u5 = 0,
            /// I2C1RST [21:21]
            /// I2C1 reset
            I2C1RST: u1 = 0,
            /// unused [22:27]
            _unused22: u2 = 0,
            _unused24: u4 = 0,
            /// PWRRST [28:28]
            /// Power interface reset
            PWRRST: u1 = 0,
            /// padding [29:31]
            _padding: u3 = 0,
        }, nullable_types.RCC.APB1PRSTR),

        /// HB Peripheral Clock enable register (RCC_AHBPCENR)
        AHBPCENR: RegisterRW(packed struct(u32) {
            /// DMA1EN [0:0]
            /// DMA clock enable
            DMA1EN: u1 = 0,
            /// unused [1:1]
            _unused1: u1 = 0,
            /// SRAMEN [2:2]
            /// SRAM interface clock enable
            SRAMEN: u1 = 1,
            /// padding [3:31]
            _padding: u29 = 0,
        }, nullable_types.RCC.AHBPCENR),

        /// PB2 peripheral clock enable register (RCC_APB2PCENR)
        APB2PCENR: RegisterRW(packed struct(u32) {
            /// AFIOEN [0:0]
            /// Alternate function I/O clock enable
            AFIOEN: u1 = 0,
            /// unused [1:1]
            _unused1: u1 = 0,
            /// IOPAEN [2:2]
            /// I/O port A clock enable
            IOPAEN: u1 = 0,
            /// unused [3:3]
            _unused3: u1 = 0,
            /// IOPCEN [4:4]
            /// I/O port C clock enable
            IOPCEN: u1 = 0,
            /// IOPDEN [5:5]
            /// I/O port D clock enable
            IOPDEN: u1 = 0,
            /// unused [6:8]
            _unused6: u2 = 0,
            _unused8: u1 = 0,
            /// ADC1EN [9:9]
            /// ADC1 interface clock enable
            ADC1EN: u1 = 0,
            /// unused [10:10]
            _unused10: u1 = 0,
            /// TIM1EN [11:11]
            /// TIM1 Timer clock enable
            TIM1EN: u1 = 0,
            /// SPI1EN [12:12]
            /// SPI 1 clock enable
            SPI1EN: u1 = 0,
            /// unused [13:13]
            _unused13: u1 = 0,
            /// USART1EN [14:14]
            /// USART1 clock enable
            USART1EN: u1 = 0,
            /// padding [15:31]
            _padding: u17 = 0,
        }, nullable_types.RCC.APB2PCENR),

        /// PB1 peripheral clock enable register (RCC_APB1PCENR)
        APB1PCENR: RegisterRW(packed struct(u32) {
            /// TIM2EN [0:0]
            /// Timer 2 clock enable
            TIM2EN: u1 = 0,
            /// unused [1:10]
            _unused1: u7 = 0,
            _unused8: u3 = 0,
            /// WWDGEN [11:11]
            /// Window watchdog clock enable
            WWDGEN: u1 = 0,
            /// unused [12:20]
            _unused12: u4 = 0,
            _unused16: u5 = 0,
            /// I2C1EN [21:21]
            /// I2C 1 clock enable
            I2C1EN: u1 = 0,
            /// unused [22:27]
            _unused22: u2 = 0,
            _unused24: u4 = 0,
            /// PWREN [28:28]
            /// Power interface clock enable
            PWREN: u1 = 0,
            /// padding [29:31]
            _padding: u3 = 0,
        }, nullable_types.RCC.APB1PCENR),

        /// offset 0x4
        _offset8: [4]u8,

        /// Control/status register (RCC_RSTSCKR)
        RSTSCKR: RegisterRW(packed struct(u32) {
            /// LSION [0:0]
            /// Internal low speed oscillator enable
            LSION: u1 = 0,
            /// LSIRDY [1:1]
            /// Internal low speed oscillator ready
            LSIRDY: u1 = 0,
            /// unused [2:23]
            _unused2: u6 = 0,
            _unused8: u8 = 0,
            _unused16: u8 = 0,
            /// RMVF [24:24]
            /// Remove reset flag
            RMVF: u1 = 0,
            /// unused [25:25]
            _unused25: u1 = 0,
            /// PINRSTF [26:26]
            /// PIN reset flag
            PINRSTF: u1 = 1,
            /// PORRSTF [27:27]
            /// POR/PDR reset flag
            PORRSTF: u1 = 1,
            /// SFTRSTF [28:28]
            /// Software reset flag
            SFTRSTF: u1 = 0,
            /// IWDGRSTF [29:29]
            /// Independent watchdog reset flag
            IWDGRSTF: u1 = 0,
            /// WWDGRSTF [30:30]
            /// Window watchdog reset flag
            WWDGRSTF: u1 = 0,
            /// LPWRRSTF [31:31]
            /// Low-power reset flag
            LPWRRSTF: u1 = 0,
        }, nullable_types.RCC.RSTSCKR),
    };

    /// Extend configuration
    pub const EXTEN = extern struct {
        pub inline fn from(base: u32) *volatile types.EXTEN {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.EXTEN) u32 {
            return @intFromPtr(self);
        }

        /// Configure the extended control register
        EXTEN_CTR: RegisterRW(packed struct(u32) {
            /// unused [0:5]
            _unused0: u6 = 0,
            /// LKUPEN [6:6]
            /// LOCKUP_Enable
            LKUPEN: u1 = 0,
            /// LKUPRST [7:7]
            /// LOCKUP RESET
            LKUPRST: u1 = 0,
            /// unused [8:9]
            _unused8: u2 = 0,
            /// LDO_TRIM [10:10]
            /// LDO_TRIM
            LDO_TRIM: u1 = 1,
            /// unused [11:15]
            _unused11: u5 = 0,
            /// OPAEN [16:16]
            /// OPA Enalbe
            OPAEN: u1 = 0,
            /// OPANSEL [17:17]
            /// OPA negative end channel selection
            OPANSEL: u1 = 0,
            /// OPAPSEL [18:18]
            /// OPA positive end channel selection
            OPAPSEL: u1 = 0,
            /// padding [19:31]
            _padding: u13 = 0,
        }, nullable_types.EXTEN.EXTEN_CTR),
    };

    /// General purpose I/O
    /// Type for: GPIOA GPIOC GPIOD
    pub const GPIO = extern struct {
        pub const GPIOA = types.GPIO.from(0x40010800);
        pub const GPIOC = types.GPIO.from(0x40011000);
        pub const GPIOD = types.GPIO.from(0x40011400);

        pub inline fn from(base: u32) *volatile types.GPIO {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.GPIO) u32 {
            return @intFromPtr(self);
        }

        /// Port configuration register low (GPIOn_CFGLR)
        CFGLR: RegisterRW(packed struct(u32) {
            /// MODE0 [0:1]
            /// Port n.0 mode bits
            MODE0: u2 = 0,
            /// CNF0 [2:3]
            /// Port n.0 configuration bits
            CNF0: u2 = 1,
            /// MODE1 [4:5]
            /// Port n.1 mode bits
            MODE1: u2 = 0,
            /// CNF1 [6:7]
            /// Port n.1 configuration bits
            CNF1: u2 = 1,
            /// MODE2 [8:9]
            /// Port n.2 mode bits
            MODE2: u2 = 0,
            /// CNF2 [10:11]
            /// Port n.2 configuration bits
            CNF2: u2 = 1,
            /// MODE3 [12:13]
            /// Port n.3 mode bits
            MODE3: u2 = 0,
            /// CNF3 [14:15]
            /// Port n.3 configuration bits
            CNF3: u2 = 1,
            /// MODE4 [16:17]
            /// Port n.4 mode bits
            MODE4: u2 = 0,
            /// CNF4 [18:19]
            /// Port n.4 configuration bits
            CNF4: u2 = 1,
            /// MODE5 [20:21]
            /// Port n.5 mode bits
            MODE5: u2 = 0,
            /// CNF5 [22:23]
            /// Port n.5 configuration bits
            CNF5: u2 = 1,
            /// MODE6 [24:25]
            /// Port n.6 mode bits
            MODE6: u2 = 0,
            /// CNF6 [26:27]
            /// Port n.6 configuration bits
            CNF6: u2 = 1,
            /// MODE7 [28:29]
            /// Port n.7 mode bits
            MODE7: u2 = 0,
            /// CNF7 [30:31]
            /// Port n.7 configuration bits
            CNF7: u2 = 1,
        }, nullable_types.GPIO.CFGLR),

        /// offset 0x4
        _offset1: [4]u8,

        /// Port input data register (GPIOn_INDR)
        INDR: RegisterRW(packed struct(u32) {
            /// IDR0 [0:0]
            /// Port input data
            IDR0: u1 = 0,
            /// IDR1 [1:1]
            /// Port input data
            IDR1: u1 = 0,
            /// IDR2 [2:2]
            /// Port input data
            IDR2: u1 = 0,
            /// IDR3 [3:3]
            /// Port input data
            IDR3: u1 = 0,
            /// IDR4 [4:4]
            /// Port input data
            IDR4: u1 = 0,
            /// IDR5 [5:5]
            /// Port input data
            IDR5: u1 = 0,
            /// IDR6 [6:6]
            /// Port input data
            IDR6: u1 = 0,
            /// IDR7 [7:7]
            /// Port input data
            IDR7: u1 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }, nullable_types.GPIO.INDR),

        /// Port output data register (GPIOn_OUTDR)
        OUTDR: RegisterRW(packed struct(u32) {
            /// ODR0 [0:0]
            /// Port output data
            ODR0: u1 = 0,
            /// ODR1 [1:1]
            /// Port output data
            ODR1: u1 = 0,
            /// ODR2 [2:2]
            /// Port output data
            ODR2: u1 = 0,
            /// ODR3 [3:3]
            /// Port output data
            ODR3: u1 = 0,
            /// ODR4 [4:4]
            /// Port output data
            ODR4: u1 = 0,
            /// ODR5 [5:5]
            /// Port output data
            ODR5: u1 = 0,
            /// ODR6 [6:6]
            /// Port output data
            ODR6: u1 = 0,
            /// ODR7 [7:7]
            /// Port output data
            ODR7: u1 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }, nullable_types.GPIO.OUTDR),

        /// Port bit set/reset register (GPIOn_BSHR)
        BSHR: RegisterRW(packed struct(u32) {
            /// BS0 [0:0]
            /// Set bit 0
            BS0: u1 = 0,
            /// BS1 [1:1]
            /// Set bit 1
            BS1: u1 = 0,
            /// BS2 [2:2]
            /// Set bit 1
            BS2: u1 = 0,
            /// BS3 [3:3]
            /// Set bit 3
            BS3: u1 = 0,
            /// BS4 [4:4]
            /// Set bit 4
            BS4: u1 = 0,
            /// BS5 [5:5]
            /// Set bit 5
            BS5: u1 = 0,
            /// BS6 [6:6]
            /// Set bit 6
            BS6: u1 = 0,
            /// BS7 [7:7]
            /// Set bit 7
            BS7: u1 = 0,
            /// unused [8:15]
            _unused8: u8 = 0,
            /// BR0 [16:16]
            /// Reset bit 0
            BR0: u1 = 0,
            /// BR1 [17:17]
            /// Reset bit 1
            BR1: u1 = 0,
            /// BR2 [18:18]
            /// Reset bit 2
            BR2: u1 = 0,
            /// BR3 [19:19]
            /// Reset bit 3
            BR3: u1 = 0,
            /// BR4 [20:20]
            /// Reset bit 4
            BR4: u1 = 0,
            /// BR5 [21:21]
            /// Reset bit 5
            BR5: u1 = 0,
            /// BR6 [22:22]
            /// Reset bit 6
            BR6: u1 = 0,
            /// BR7 [23:23]
            /// Reset bit 7
            BR7: u1 = 0,
            /// padding [24:31]
            _padding: u8 = 0,
        }, nullable_types.GPIO.BSHR),

        /// Port bit reset register (GPIOn_BCR)
        BCR: RegisterRW(packed struct(u32) {
            /// BR0 [0:0]
            /// Reset bit 0
            BR0: u1 = 0,
            /// BR1 [1:1]
            /// Reset bit 1
            BR1: u1 = 0,
            /// BR2 [2:2]
            /// Reset bit 1
            BR2: u1 = 0,
            /// BR3 [3:3]
            /// Reset bit 3
            BR3: u1 = 0,
            /// BR4 [4:4]
            /// Reset bit 4
            BR4: u1 = 0,
            /// BR5 [5:5]
            /// Reset bit 5
            BR5: u1 = 0,
            /// BR6 [6:6]
            /// Reset bit 6
            BR6: u1 = 0,
            /// BR7 [7:7]
            /// Reset bit 7
            BR7: u1 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }, nullable_types.GPIO.BCR),

        /// Port configuration lock register
        LCKR: RegisterRW(packed struct(u32) {
            /// LCK0 [0:0]
            /// Port A Lock bit 0
            LCK0: u1 = 0,
            /// LCK1 [1:1]
            /// Port A Lock bit 1
            LCK1: u1 = 0,
            /// LCK2 [2:2]
            /// Port A Lock bit 2
            LCK2: u1 = 0,
            /// LCK3 [3:3]
            /// Port A Lock bit 3
            LCK3: u1 = 0,
            /// LCK4 [4:4]
            /// Port A Lock bit 4
            LCK4: u1 = 0,
            /// LCK5 [5:5]
            /// Port A Lock bit 5
            LCK5: u1 = 0,
            /// LCK6 [6:6]
            /// Port A Lock bit 6
            LCK6: u1 = 0,
            /// LCK7 [7:7]
            /// Port A Lock bit 7
            LCK7: u1 = 0,
            /// LCKK [8:8]
            /// Lock key
            LCKK: u1 = 0,
            /// padding [9:31]
            _padding: u23 = 0,
        }, nullable_types.GPIO.LCKR),
    };

    /// Alternate function I/O
    pub const AFIO = extern struct {
        pub inline fn from(base: u32) *volatile types.AFIO {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.AFIO) u32 {
            return @intFromPtr(self);
        }

        /// offset 0x4
        _offset0: [4]u8,

        /// AF remap and debug I/O configuration register (AFIO_PCFR1)
        PCFR1: RegisterRW(packed struct(u32) {
            /// SPI1_RM [0:0]
            /// SPI1 remapping
            SPI1_RM: u1 = 0,
            /// I2C1_RM [1:1]
            /// I2C1 remapping
            I2C1_RM: u1 = 0,
            /// USART1_RM [2:2]
            /// USART1 remapping
            USART1_RM: u1 = 0,
            /// unused [3:5]
            _unused3: u3 = 0,
            /// TIM1_RM [6:7]
            /// TIM1 remapping
            TIM1_RM: u2 = 0,
            /// TIM2_RM [8:9]
            /// TIM2 remapping
            TIM2_RM: u2 = 0,
            /// unused [10:14]
            _unused10: u5 = 0,
            /// PA12_RM [15:15]
            /// Port A1/Port A2 mapping on OSCIN/OSCOUT
            PA12_RM: u1 = 0,
            /// unused [16:16]
            _unused16: u1 = 0,
            /// ADC1_ETRGINJ_RM [17:17]
            /// ADC 1 External trigger injected conversion remapping
            ADC1_ETRGINJ_RM: u1 = 0,
            /// ADC1_ETRGREG_RM [18:18]
            /// ADC 1 external trigger regular conversion remapping
            ADC1_ETRGREG_RM: u1 = 0,
            /// unused [19:20]
            _unused19: u2 = 0,
            /// USART1REMAP1 [21:21]
            /// USART1 remapping
            USART1REMAP1: u1 = 0,
            /// I2C1REMAP1 [22:22]
            /// I2C1 remapping
            I2C1REMAP1: u1 = 0,
            /// TIM1_1_RM [23:23]
            /// TIM1_CH1 channel selection
            TIM1_1_RM: u1 = 0,
            /// SWCFG [24:26]
            /// Serial wire JTAG configuration
            SWCFG: u3 = 0,
            /// padding [27:31]
            _padding: u5 = 0,
        }, nullable_types.AFIO.PCFR1),

        /// External interrupt configuration register (AFIO_EXTICR)
        EXTICR: RegisterRW(packed struct(u32) {
            /// EXTI0 [0:1]
            /// EXTI0 configuration
            EXTI0: u2 = 0,
            /// EXTI1 [2:3]
            /// EXTI1 configuration
            EXTI1: u2 = 0,
            /// EXTI2 [4:5]
            /// EXTI2 configuration
            EXTI2: u2 = 0,
            /// EXTI3 [6:7]
            /// EXTI3 configuration
            EXTI3: u2 = 0,
            /// EXTI4 [8:9]
            /// EXTI4 configuration
            EXTI4: u2 = 0,
            /// EXTI5 [10:11]
            /// EXTI5 configuration
            EXTI5: u2 = 0,
            /// EXTI6 [12:13]
            /// EXTI6 configuration
            EXTI6: u2 = 0,
            /// EXTI7 [14:15]
            /// EXTI7 configuration
            EXTI7: u2 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AFIO.EXTICR),
    };

    /// EXTI
    pub const EXTI = extern struct {
        pub inline fn from(base: u32) *volatile types.EXTI {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.EXTI) u32 {
            return @intFromPtr(self);
        }

        /// Interrupt mask register (EXTI_INTENR)
        INTENR: RegisterRW(packed struct(u32) {
            /// MR0 [0:0]
            /// Interrupt Mask on line 0
            MR0: u1 = 0,
            /// MR1 [1:1]
            /// Interrupt Mask on line 1
            MR1: u1 = 0,
            /// MR2 [2:2]
            /// Interrupt Mask on line 2
            MR2: u1 = 0,
            /// MR3 [3:3]
            /// Interrupt Mask on line 3
            MR3: u1 = 0,
            /// MR4 [4:4]
            /// Interrupt Mask on line 4
            MR4: u1 = 0,
            /// MR5 [5:5]
            /// Interrupt Mask on line 5
            MR5: u1 = 0,
            /// MR6 [6:6]
            /// Interrupt Mask on line 6
            MR6: u1 = 0,
            /// MR7 [7:7]
            /// Interrupt Mask on line 7
            MR7: u1 = 0,
            /// MR8 [8:8]
            /// Interrupt Mask on line 8
            MR8: u1 = 0,
            /// MR9 [9:9]
            /// Interrupt Mask on line 9
            MR9: u1 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }, nullable_types.EXTI.INTENR),

        /// Event mask register (EXTI_EVENR)
        EVENR: RegisterRW(packed struct(u32) {
            /// MR0 [0:0]
            /// Event Mask on line 0
            MR0: u1 = 0,
            /// MR1 [1:1]
            /// Event Mask on line 1
            MR1: u1 = 0,
            /// MR2 [2:2]
            /// Event Mask on line 2
            MR2: u1 = 0,
            /// MR3 [3:3]
            /// Event Mask on line 3
            MR3: u1 = 0,
            /// MR4 [4:4]
            /// Event Mask on line 4
            MR4: u1 = 0,
            /// MR5 [5:5]
            /// Event Mask on line 5
            MR5: u1 = 0,
            /// MR6 [6:6]
            /// Event Mask on line 6
            MR6: u1 = 0,
            /// MR7 [7:7]
            /// Event Mask on line 7
            MR7: u1 = 0,
            /// MR8 [8:8]
            /// Event Mask on line 8
            MR8: u1 = 0,
            /// MR9 [9:9]
            /// Event Mask on line 9
            MR9: u1 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }, nullable_types.EXTI.EVENR),

        /// Rising Trigger selection register (EXTI_RTENR)
        RTENR: RegisterRW(packed struct(u32) {
            /// TR0 [0:0]
            /// Rising trigger event configuration of line 0
            TR0: u1 = 0,
            /// TR1 [1:1]
            /// Rising trigger event configuration of line 1
            TR1: u1 = 0,
            /// TR2 [2:2]
            /// Rising trigger event configuration of line 2
            TR2: u1 = 0,
            /// TR3 [3:3]
            /// Rising trigger event configuration of line 3
            TR3: u1 = 0,
            /// TR4 [4:4]
            /// Rising trigger event configuration of line 4
            TR4: u1 = 0,
            /// TR5 [5:5]
            /// Rising trigger event configuration of line 5
            TR5: u1 = 0,
            /// TR6 [6:6]
            /// Rising trigger event configuration of line 6
            TR6: u1 = 0,
            /// TR7 [7:7]
            /// Rising trigger event configuration of line 7
            TR7: u1 = 0,
            /// TR8 [8:8]
            /// Rising trigger event configuration of line 8
            TR8: u1 = 0,
            /// TR9 [9:9]
            /// Rising trigger event configuration of line 9
            TR9: u1 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }, nullable_types.EXTI.RTENR),

        /// Falling Trigger selection register (EXTI_FTENR)
        FTENR: RegisterRW(packed struct(u32) {
            /// TR0 [0:0]
            /// Falling trigger event configuration of line 0
            TR0: u1 = 0,
            /// TR1 [1:1]
            /// Falling trigger event configuration of line 1
            TR1: u1 = 0,
            /// TR2 [2:2]
            /// Falling trigger event configuration of line 2
            TR2: u1 = 0,
            /// TR3 [3:3]
            /// Falling trigger event configuration of line 3
            TR3: u1 = 0,
            /// TR4 [4:4]
            /// Falling trigger event configuration of line 4
            TR4: u1 = 0,
            /// TR5 [5:5]
            /// Falling trigger event configuration of line 5
            TR5: u1 = 0,
            /// TR6 [6:6]
            /// Falling trigger event configuration of line 6
            TR6: u1 = 0,
            /// TR7 [7:7]
            /// Falling trigger event configuration of line 7
            TR7: u1 = 0,
            /// TR8 [8:8]
            /// Falling trigger event configuration of line 8
            TR8: u1 = 0,
            /// TR9 [9:9]
            /// Falling trigger event configuration of line 9
            TR9: u1 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }, nullable_types.EXTI.FTENR),

        /// Software interrupt event register (EXTI_SWIEVR)
        SWIEVR: RegisterRW(packed struct(u32) {
            /// SWIER0 [0:0]
            /// Software Interrupt on line 0
            SWIER0: u1 = 0,
            /// SWIER1 [1:1]
            /// Software Interrupt on line 1
            SWIER1: u1 = 0,
            /// SWIER2 [2:2]
            /// Software Interrupt on line 2
            SWIER2: u1 = 0,
            /// SWIER3 [3:3]
            /// Software Interrupt on line 3
            SWIER3: u1 = 0,
            /// SWIER4 [4:4]
            /// Software Interrupt on line 4
            SWIER4: u1 = 0,
            /// SWIER5 [5:5]
            /// Software Interrupt on line 5
            SWIER5: u1 = 0,
            /// SWIER6 [6:6]
            /// Software Interrupt on line 6
            SWIER6: u1 = 0,
            /// SWIER7 [7:7]
            /// Software Interrupt on line 7
            SWIER7: u1 = 0,
            /// SWIER8 [8:8]
            /// Software Interrupt on line 8
            SWIER8: u1 = 0,
            /// SWIER9 [9:9]
            /// Software Interrupt on line 9
            SWIER9: u1 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }, nullable_types.EXTI.SWIEVR),

        /// Pending register (EXTI_INTFR)
        INTFR: RegisterRW(packed struct(u32) {
            /// IF0 [0:0]
            /// Pending bit 0
            IF0: u1 = 0,
            /// IF1 [1:1]
            /// Pending bit 1
            IF1: u1 = 0,
            /// IF2 [2:2]
            /// Pending bit 2
            IF2: u1 = 0,
            /// IF3 [3:3]
            /// Pending bit 3
            IF3: u1 = 0,
            /// IF4 [4:4]
            /// Pending bit 4
            IF4: u1 = 0,
            /// IF5 [5:5]
            /// Pending bit 5
            IF5: u1 = 0,
            /// IF6 [6:6]
            /// Pending bit 6
            IF6: u1 = 0,
            /// IF7 [7:7]
            /// Pending bit 7
            IF7: u1 = 0,
            /// IF8 [8:8]
            /// Pending bit 8
            IF8: u1 = 0,
            /// IF9 [9:9]
            /// Pending bit 9
            IF9: u1 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }, nullable_types.EXTI.INTFR),
    };

    /// DMA1 controller
    pub const DMA1 = extern struct {
        pub inline fn from(base: u32) *volatile types.DMA1 {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.DMA1) u32 {
            return @intFromPtr(self);
        }

        /// DMA interrupt status register (DMA_INTFR)
        INTFR: RegisterRW(packed struct(u32) {
            /// GIF1 [0:0]
            /// Channel 1 Global interrupt flag
            GIF1: u1 = 0,
            /// TCIF1 [1:1]
            /// Channel 1 Transfer Complete flag
            TCIF1: u1 = 0,
            /// HTIF1 [2:2]
            /// Channel 1 Half Transfer Complete flag
            HTIF1: u1 = 0,
            /// TEIF1 [3:3]
            /// Channel 1 Transfer Error flag
            TEIF1: u1 = 0,
            /// GIF2 [4:4]
            /// Channel 2 Global interrupt flag
            GIF2: u1 = 0,
            /// TCIF2 [5:5]
            /// Channel 2 Transfer Complete flag
            TCIF2: u1 = 0,
            /// HTIF2 [6:6]
            /// Channel 2 Half Transfer Complete flag
            HTIF2: u1 = 0,
            /// TEIF2 [7:7]
            /// Channel 2 Transfer Error flag
            TEIF2: u1 = 0,
            /// GIF3 [8:8]
            /// Channel 3 Global interrupt flag
            GIF3: u1 = 0,
            /// TCIF3 [9:9]
            /// Channel 3 Transfer Complete flag
            TCIF3: u1 = 0,
            /// HTIF3 [10:10]
            /// Channel 3 Half Transfer Complete flag
            HTIF3: u1 = 0,
            /// TEIF3 [11:11]
            /// Channel 3 Transfer Error flag
            TEIF3: u1 = 0,
            /// GIF4 [12:12]
            /// Channel 4 Global interrupt flag
            GIF4: u1 = 0,
            /// TCIF4 [13:13]
            /// Channel 4 Transfer Complete flag
            TCIF4: u1 = 0,
            /// HTIF4 [14:14]
            /// Channel 4 Half Transfer Complete flag
            HTIF4: u1 = 0,
            /// TEIF4 [15:15]
            /// Channel 4 Transfer Error flag
            TEIF4: u1 = 0,
            /// GIF5 [16:16]
            /// Channel 5 Global interrupt flag
            GIF5: u1 = 0,
            /// TCIF5 [17:17]
            /// Channel 5 Transfer Complete flag
            TCIF5: u1 = 0,
            /// HTIF5 [18:18]
            /// Channel 5 Half Transfer Complete flag
            HTIF5: u1 = 0,
            /// TEIF5 [19:19]
            /// Channel 5 Transfer Error flag
            TEIF5: u1 = 0,
            /// GIF6 [20:20]
            /// Channel 6 Global interrupt flag
            GIF6: u1 = 0,
            /// TCIF6 [21:21]
            /// Channel 6 Transfer Complete flag
            TCIF6: u1 = 0,
            /// HTIF6 [22:22]
            /// Channel 6 Half Transfer Complete flag
            HTIF6: u1 = 0,
            /// TEIF6 [23:23]
            /// Channel 6 Transfer Error flag
            TEIF6: u1 = 0,
            /// GIF7 [24:24]
            /// Channel 7 Global interrupt flag
            GIF7: u1 = 0,
            /// TCIF7 [25:25]
            /// Channel 7 Transfer Complete flag
            TCIF7: u1 = 0,
            /// HTIF7 [26:26]
            /// Channel 7 Half Transfer Complete flag
            HTIF7: u1 = 0,
            /// TEIF7 [27:27]
            /// Channel 7 Transfer Error flag
            TEIF7: u1 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
        }, nullable_types.DMA1.INTFR),

        /// DMA interrupt flag clear register (DMA_INTFCR)
        INTFCR: RegisterRW(packed struct(u32) {
            /// CGIF1 [0:0]
            /// Channel 1 Global interrupt clear
            CGIF1: u1 = 0,
            /// CTCIF1 [1:1]
            /// Channel 1 Transfer Complete clear
            CTCIF1: u1 = 0,
            /// CHTIF1 [2:2]
            /// Channel 1 Half Transfer clear
            CHTIF1: u1 = 0,
            /// CTEIF1 [3:3]
            /// Channel 1 Transfer Error clear
            CTEIF1: u1 = 0,
            /// CGIF2 [4:4]
            /// Channel 2 Global interrupt clear
            CGIF2: u1 = 0,
            /// CTCIF2 [5:5]
            /// Channel 2 Transfer Complete clear
            CTCIF2: u1 = 0,
            /// CHTIF2 [6:6]
            /// Channel 2 Half Transfer clear
            CHTIF2: u1 = 0,
            /// CTEIF2 [7:7]
            /// Channel 2 Transfer Error clear
            CTEIF2: u1 = 0,
            /// CGIF3 [8:8]
            /// Channel 3 Global interrupt clear
            CGIF3: u1 = 0,
            /// CTCIF3 [9:9]
            /// Channel 3 Transfer Complete clear
            CTCIF3: u1 = 0,
            /// CHTIF3 [10:10]
            /// Channel 3 Half Transfer clear
            CHTIF3: u1 = 0,
            /// CTEIF3 [11:11]
            /// Channel 3 Transfer Error clear
            CTEIF3: u1 = 0,
            /// CGIF4 [12:12]
            /// Channel 4 Global interrupt clear
            CGIF4: u1 = 0,
            /// CTCIF4 [13:13]
            /// Channel 4 Transfer Complete clear
            CTCIF4: u1 = 0,
            /// CHTIF4 [14:14]
            /// Channel 4 Half Transfer clear
            CHTIF4: u1 = 0,
            /// CTEIF4 [15:15]
            /// Channel 4 Transfer Error clear
            CTEIF4: u1 = 0,
            /// CGIF5 [16:16]
            /// Channel 5 Global interrupt clear
            CGIF5: u1 = 0,
            /// CTCIF5 [17:17]
            /// Channel 5 Transfer Complete clear
            CTCIF5: u1 = 0,
            /// CHTIF5 [18:18]
            /// Channel 5 Half Transfer clear
            CHTIF5: u1 = 0,
            /// CTEIF5 [19:19]
            /// Channel 5 Transfer Error clear
            CTEIF5: u1 = 0,
            /// CGIF6 [20:20]
            /// Channel 6 Global interrupt clear
            CGIF6: u1 = 0,
            /// CTCIF6 [21:21]
            /// Channel 6 Transfer Complete clear
            CTCIF6: u1 = 0,
            /// CHTIF6 [22:22]
            /// Channel 6 Half Transfer clear
            CHTIF6: u1 = 0,
            /// CTEIF6 [23:23]
            /// Channel 6 Transfer Error clear
            CTEIF6: u1 = 0,
            /// CGIF7 [24:24]
            /// Channel 7 Global interrupt clear
            CGIF7: u1 = 0,
            /// CTCIF7 [25:25]
            /// Channel 7 Transfer Complete clear
            CTCIF7: u1 = 0,
            /// CHTIF7 [26:26]
            /// Channel 7 Half Transfer clear
            CHTIF7: u1 = 0,
            /// CTEIF7 [27:27]
            /// Channel 7 Transfer Error clear
            CTEIF7: u1 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
        }, nullable_types.DMA1.INTFCR),

        /// DMA channel configuration register (DMA_CFGR)
        CFGR1: RegisterRW(packed struct(u32) {
            /// EN [0:0]
            /// Channel enable
            EN: u1 = 0,
            /// TCIE [1:1]
            /// Transfer complete interrupt enable
            TCIE: u1 = 0,
            /// HTIE [2:2]
            /// Half Transfer interrupt enable
            HTIE: u1 = 0,
            /// TEIE [3:3]
            /// Transfer error interrupt enable
            TEIE: u1 = 0,
            /// DIR [4:4]
            /// Data transfer direction
            DIR: u1 = 0,
            /// CIRC [5:5]
            /// Circular mode
            CIRC: u1 = 0,
            /// PINC [6:6]
            /// Peripheral increment mode
            PINC: u1 = 0,
            /// MINC [7:7]
            /// Memory increment mode
            MINC: u1 = 0,
            /// PSIZE [8:9]
            /// Peripheral size
            PSIZE: u2 = 0,
            /// MSIZE [10:11]
            /// Memory size
            MSIZE: u2 = 0,
            /// PL [12:13]
            /// Channel Priority level
            PL: u2 = 0,
            /// MEM2MEM [14:14]
            /// Memory to memory mode
            MEM2MEM: u1 = 0,
            /// padding [15:31]
            _padding: u17 = 0,
        }, nullable_types.DMA1.CFGR1),

        /// DMA channel 1 number of data register
        CNTR1: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.DMA1.CNTR1),

        /// DMA channel 1 peripheral address register
        PADDR1: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }, nullable_types.DMA1.PADDR1),

        /// DMA channel 1 memory address register
        MADDR1: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }, nullable_types.DMA1.MADDR1),

        /// offset 0x4
        _offset6: [4]u8,

        /// DMA channel configuration register (DMA_CFGR)
        CFGR2: RegisterRW(packed struct(u32) {
            /// EN [0:0]
            /// Channel enable
            EN: u1 = 0,
            /// TCIE [1:1]
            /// Transfer complete interrupt enable
            TCIE: u1 = 0,
            /// HTIE [2:2]
            /// Half Transfer interrupt enable
            HTIE: u1 = 0,
            /// TEIE [3:3]
            /// Transfer error interrupt enable
            TEIE: u1 = 0,
            /// DIR [4:4]
            /// Data transfer direction
            DIR: u1 = 0,
            /// CIRC [5:5]
            /// Circular mode
            CIRC: u1 = 0,
            /// PINC [6:6]
            /// Peripheral increment mode
            PINC: u1 = 0,
            /// MINC [7:7]
            /// Memory increment mode
            MINC: u1 = 0,
            /// PSIZE [8:9]
            /// Peripheral size
            PSIZE: u2 = 0,
            /// MSIZE [10:11]
            /// Memory size
            MSIZE: u2 = 0,
            /// PL [12:13]
            /// Channel Priority level
            PL: u2 = 0,
            /// MEM2MEM [14:14]
            /// Memory to memory mode
            MEM2MEM: u1 = 0,
            /// padding [15:31]
            _padding: u17 = 0,
        }, nullable_types.DMA1.CFGR2),

        /// DMA channel 2 number of data register
        CNTR2: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.DMA1.CNTR2),

        /// DMA channel 2 peripheral address register
        PADDR2: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }, nullable_types.DMA1.PADDR2),

        /// DMA channel 2 memory address register
        MADDR2: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }, nullable_types.DMA1.MADDR2),

        /// offset 0x4
        _offset10: [4]u8,

        /// DMA channel configuration register (DMA_CFGR)
        CFGR3: RegisterRW(packed struct(u32) {
            /// EN [0:0]
            /// Channel enable
            EN: u1 = 0,
            /// TCIE [1:1]
            /// Transfer complete interrupt enable
            TCIE: u1 = 0,
            /// HTIE [2:2]
            /// Half Transfer interrupt enable
            HTIE: u1 = 0,
            /// TEIE [3:3]
            /// Transfer error interrupt enable
            TEIE: u1 = 0,
            /// DIR [4:4]
            /// Data transfer direction
            DIR: u1 = 0,
            /// CIRC [5:5]
            /// Circular mode
            CIRC: u1 = 0,
            /// PINC [6:6]
            /// Peripheral increment mode
            PINC: u1 = 0,
            /// MINC [7:7]
            /// Memory increment mode
            MINC: u1 = 0,
            /// PSIZE [8:9]
            /// Peripheral size
            PSIZE: u2 = 0,
            /// MSIZE [10:11]
            /// Memory size
            MSIZE: u2 = 0,
            /// PL [12:13]
            /// Channel Priority level
            PL: u2 = 0,
            /// MEM2MEM [14:14]
            /// Memory to memory mode
            MEM2MEM: u1 = 0,
            /// padding [15:31]
            _padding: u17 = 0,
        }, nullable_types.DMA1.CFGR3),

        /// DMA channel 3 number of data register
        CNTR3: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.DMA1.CNTR3),

        /// DMA channel 3 peripheral address register
        PADDR3: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }, nullable_types.DMA1.PADDR3),

        /// DMA channel 3 memory address register
        MADDR3: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }, nullable_types.DMA1.MADDR3),

        /// offset 0x4
        _offset14: [4]u8,

        /// DMA channel configuration register (DMA_CFGR)
        CFGR4: RegisterRW(packed struct(u32) {
            /// EN [0:0]
            /// Channel enable
            EN: u1 = 0,
            /// TCIE [1:1]
            /// Transfer complete interrupt enable
            TCIE: u1 = 0,
            /// HTIE [2:2]
            /// Half Transfer interrupt enable
            HTIE: u1 = 0,
            /// TEIE [3:3]
            /// Transfer error interrupt enable
            TEIE: u1 = 0,
            /// DIR [4:4]
            /// Data transfer direction
            DIR: u1 = 0,
            /// CIRC [5:5]
            /// Circular mode
            CIRC: u1 = 0,
            /// PINC [6:6]
            /// Peripheral increment mode
            PINC: u1 = 0,
            /// MINC [7:7]
            /// Memory increment mode
            MINC: u1 = 0,
            /// PSIZE [8:9]
            /// Peripheral size
            PSIZE: u2 = 0,
            /// MSIZE [10:11]
            /// Memory size
            MSIZE: u2 = 0,
            /// PL [12:13]
            /// Channel Priority level
            PL: u2 = 0,
            /// MEM2MEM [14:14]
            /// Memory to memory mode
            MEM2MEM: u1 = 0,
            /// padding [15:31]
            _padding: u17 = 0,
        }, nullable_types.DMA1.CFGR4),

        /// DMA channel 4 number of data register
        CNTR4: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.DMA1.CNTR4),

        /// DMA channel 4 peripheral address register
        PADDR4: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }, nullable_types.DMA1.PADDR4),

        /// DMA channel 4 memory address register
        MADDR4: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }, nullable_types.DMA1.MADDR4),

        /// offset 0x4
        _offset18: [4]u8,

        /// DMA channel configuration register (DMA_CFGR)
        CFGR5: RegisterRW(packed struct(u32) {
            /// EN [0:0]
            /// Channel enable
            EN: u1 = 0,
            /// TCIE [1:1]
            /// Transfer complete interrupt enable
            TCIE: u1 = 0,
            /// HTIE [2:2]
            /// Half Transfer interrupt enable
            HTIE: u1 = 0,
            /// TEIE [3:3]
            /// Transfer error interrupt enable
            TEIE: u1 = 0,
            /// DIR [4:4]
            /// Data transfer direction
            DIR: u1 = 0,
            /// CIRC [5:5]
            /// Circular mode
            CIRC: u1 = 0,
            /// PINC [6:6]
            /// Peripheral increment mode
            PINC: u1 = 0,
            /// MINC [7:7]
            /// Memory increment mode
            MINC: u1 = 0,
            /// PSIZE [8:9]
            /// Peripheral size
            PSIZE: u2 = 0,
            /// MSIZE [10:11]
            /// Memory size
            MSIZE: u2 = 0,
            /// PL [12:13]
            /// Channel Priority level
            PL: u2 = 0,
            /// MEM2MEM [14:14]
            /// Memory to memory mode
            MEM2MEM: u1 = 0,
            /// padding [15:31]
            _padding: u17 = 0,
        }, nullable_types.DMA1.CFGR5),

        /// DMA channel 5 number of data register
        CNTR5: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.DMA1.CNTR5),

        /// DMA channel 5 peripheral address register
        PADDR5: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }, nullable_types.DMA1.PADDR5),

        /// DMA channel 5 memory address register
        MADDR5: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }, nullable_types.DMA1.MADDR5),

        /// offset 0x4
        _offset22: [4]u8,

        /// DMA channel configuration register (DMA_CFGR)
        CFGR6: RegisterRW(packed struct(u32) {
            /// EN [0:0]
            /// Channel enable
            EN: u1 = 0,
            /// TCIE [1:1]
            /// Transfer complete interrupt enable
            TCIE: u1 = 0,
            /// HTIE [2:2]
            /// Half Transfer interrupt enable
            HTIE: u1 = 0,
            /// TEIE [3:3]
            /// Transfer error interrupt enable
            TEIE: u1 = 0,
            /// DIR [4:4]
            /// Data transfer direction
            DIR: u1 = 0,
            /// CIRC [5:5]
            /// Circular mode
            CIRC: u1 = 0,
            /// PINC [6:6]
            /// Peripheral increment mode
            PINC: u1 = 0,
            /// MINC [7:7]
            /// Memory increment mode
            MINC: u1 = 0,
            /// PSIZE [8:9]
            /// Peripheral size
            PSIZE: u2 = 0,
            /// MSIZE [10:11]
            /// Memory size
            MSIZE: u2 = 0,
            /// PL [12:13]
            /// Channel Priority level
            PL: u2 = 0,
            /// MEM2MEM [14:14]
            /// Memory to memory mode
            MEM2MEM: u1 = 0,
            /// padding [15:31]
            _padding: u17 = 0,
        }, nullable_types.DMA1.CFGR6),

        /// DMA channel 6 number of data register
        CNTR6: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.DMA1.CNTR6),

        /// DMA channel 6 peripheral address register
        PADDR6: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }, nullable_types.DMA1.PADDR6),

        /// DMA channel 6 memory address register
        MADDR6: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }, nullable_types.DMA1.MADDR6),

        /// offset 0x4
        _offset26: [4]u8,

        /// DMA channel configuration register (DMA_CFGR)
        CFGR7: RegisterRW(packed struct(u32) {
            /// EN [0:0]
            /// Channel enable
            EN: u1 = 0,
            /// TCIE [1:1]
            /// Transfer complete interrupt enable
            TCIE: u1 = 0,
            /// HTIE [2:2]
            /// Half Transfer interrupt enable
            HTIE: u1 = 0,
            /// TEIE [3:3]
            /// Transfer error interrupt enable
            TEIE: u1 = 0,
            /// DIR [4:4]
            /// Data transfer direction
            DIR: u1 = 0,
            /// CIRC [5:5]
            /// Circular mode
            CIRC: u1 = 0,
            /// PINC [6:6]
            /// Peripheral increment mode
            PINC: u1 = 0,
            /// MINC [7:7]
            /// Memory increment mode
            MINC: u1 = 0,
            /// PSIZE [8:9]
            /// Peripheral size
            PSIZE: u2 = 0,
            /// MSIZE [10:11]
            /// Memory size
            MSIZE: u2 = 0,
            /// PL [12:13]
            /// Channel Priority level
            PL: u2 = 0,
            /// MEM2MEM [14:14]
            /// Memory to memory mode
            MEM2MEM: u1 = 0,
            /// padding [15:31]
            _padding: u17 = 0,
        }, nullable_types.DMA1.CFGR7),

        /// DMA channel 7 number of data register
        CNTR7: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.DMA1.CNTR7),

        /// DMA channel 7 peripheral address register
        PADDR7: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }, nullable_types.DMA1.PADDR7),

        /// DMA channel 7 memory address register
        MADDR7: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }, nullable_types.DMA1.MADDR7),
    };

    /// Independent watchdog
    pub const IWDG = extern struct {
        pub inline fn from(base: u32) *volatile types.IWDG {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.IWDG) u32 {
            return @intFromPtr(self);
        }

        /// Key register (IWDG_CTLR)
        CTLR: RegisterRW(packed struct(u32) {
            /// KEY [0:15]
            /// Key value
            KEY: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.IWDG.CTLR),

        /// Prescaler register (IWDG_PSCR)
        PSCR: RegisterRW(packed struct(u32) {
            /// PR [0:2]
            /// Prescaler divider
            PR: u3 = 0,
            /// padding [3:31]
            _padding: u29 = 0,
        }, nullable_types.IWDG.PSCR),

        /// Reload register (IWDG_RLDR)
        RLDR: RegisterRW(packed struct(u32) {
            /// RL [0:11]
            /// Watchdog counter reload value
            RL: u12 = 4095,
            /// padding [12:31]
            _padding: u20 = 0,
        }, nullable_types.IWDG.RLDR),

        /// Status register (IWDG_SR)
        STATR: RegisterRW(packed struct(u32) {
            /// PVU [0:0]
            /// Watchdog prescaler value update
            PVU: u1 = 0,
            /// RVU [1:1]
            /// Watchdog counter reload value update
            RVU: u1 = 0,
            /// padding [2:31]
            _padding: u30 = 0,
        }, nullable_types.IWDG.STATR),
    };

    /// Window watchdog
    pub const WWDG = extern struct {
        pub inline fn from(base: u32) *volatile types.WWDG {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.WWDG) u32 {
            return @intFromPtr(self);
        }

        /// Control register (WWDG_CR)
        CTLR: RegisterRW(packed struct(u32) {
            /// T [0:6]
            /// 7-bit counter (MSB to LSB)
            T: u7 = 127,
            /// WDGA [7:7]
            /// Activation bit
            WDGA: u1 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }, nullable_types.WWDG.CTLR),

        /// Configuration register (WWDG_CFR)
        CFGR: RegisterRW(packed struct(u32) {
            /// W [0:6]
            /// 7-bit window value
            W: u7 = 127,
            /// WDGTB [7:8]
            /// Timer Base
            WDGTB: u2 = 0,
            /// EWI [9:9]
            /// Early Wakeup Interrupt
            EWI: u1 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }, nullable_types.WWDG.CFGR),

        /// Status register (WWDG_SR)
        STATR: RegisterRW(packed struct(u32) {
            /// EWIF [0:0]
            /// Early Wakeup Interrupt Flag
            EWIF: u1 = 0,
            /// padding [1:31]
            _padding: u31 = 0,
        }, nullable_types.WWDG.STATR),
    };

    /// Advanced timer
    /// Type for: TIM1
    pub const AdvancedTimer = extern struct {
        pub const TIM1 = types.AdvancedTimer.from(0x40012c00);

        pub inline fn from(base: u32) *volatile types.AdvancedTimer {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.AdvancedTimer) u32 {
            return @intFromPtr(self);
        }

        /// control register 1
        CTLR1: RegisterRW(packed struct(u32) {
            /// CEN [0:0]
            /// Counter enable
            CEN: u1 = 0,
            /// UDIS [1:1]
            /// Update disable
            UDIS: u1 = 0,
            /// URS [2:2]
            /// Update request source
            URS: u1 = 0,
            /// OPM [3:3]
            /// One-pulse mode
            OPM: u1 = 0,
            /// DIR [4:4]
            /// Direction
            DIR: u1 = 0,
            /// CMS [5:6]
            /// Center-aligned mode selection
            CMS: u2 = 0,
            /// ARPE [7:7]
            /// Auto-reload preload enable
            ARPE: u1 = 0,
            /// CKD [8:9]
            /// Clock division
            CKD: u2 = 0,
            /// unused [10:13]
            _unused10: u4 = 0,
            /// CAPOV [14:14]
            /// Timer capture value configuration enable
            CAPOV: u1 = 0,
            /// CAPLVL [15:15]
            /// Timer capture level indication enable
            CAPLVL: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AdvancedTimer.CTLR1),

        /// control register 2
        CTLR2: RegisterRW(packed struct(u32) {
            /// CCPC [0:0]
            /// Capture/compare preloaded control
            CCPC: u1 = 0,
            /// unused [1:1]
            _unused1: u1 = 0,
            /// CCUS [2:2]
            /// Capture/compare control update selection
            CCUS: u1 = 0,
            /// CCDS [3:3]
            /// Capture/compare DMA selection
            CCDS: u1 = 0,
            /// MMS [4:6]
            /// Master mode selection
            MMS: u3 = 0,
            /// TI1S [7:7]
            /// TI1 selection
            TI1S: u1 = 0,
            /// OIS1 [8:8]
            /// Output Idle state 1
            OIS1: u1 = 0,
            /// OIS1N [9:9]
            /// Output Idle state 1
            OIS1N: u1 = 0,
            /// OIS2 [10:10]
            /// Output Idle state 2
            OIS2: u1 = 0,
            /// OIS2N [11:11]
            /// Output Idle state 2
            OIS2N: u1 = 0,
            /// OIS3 [12:12]
            /// Output Idle state 3
            OIS3: u1 = 0,
            /// OIS3N [13:13]
            /// Output Idle state 3
            OIS3N: u1 = 0,
            /// OIS4 [14:14]
            /// Output Idle state 4
            OIS4: u1 = 0,
            /// padding [15:31]
            _padding: u17 = 0,
        }, nullable_types.AdvancedTimer.CTLR2),

        /// slave mode control register
        SMCFGR: RegisterRW(packed struct(u32) {
            /// SMS [0:2]
            /// Slave mode selection
            SMS: u3 = 0,
            /// unused [3:3]
            _unused3: u1 = 0,
            /// TS [4:6]
            /// Trigger selection
            TS: u3 = 0,
            /// MSM [7:7]
            /// Master/Slave mode
            MSM: u1 = 0,
            /// ETF [8:11]
            /// External trigger filter
            ETF: u4 = 0,
            /// ETPS [12:13]
            /// External trigger prescaler
            ETPS: u2 = 0,
            /// ECE [14:14]
            /// External clock enable
            ECE: u1 = 0,
            /// ETP [15:15]
            /// External trigger polarity
            ETP: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AdvancedTimer.SMCFGR),

        /// DMA/Interrupt enable register
        DMAINTENR: RegisterRW(packed struct(u32) {
            /// UIE [0:0]
            /// Update interrupt enable
            UIE: u1 = 0,
            /// CC1IE [1:1]
            /// Capture/Compare 1 interrupt enable
            CC1IE: u1 = 0,
            /// CC2IE [2:2]
            /// Capture/Compare 2 interrupt enable
            CC2IE: u1 = 0,
            /// CC3IE [3:3]
            /// Capture/Compare 3 interrupt enable
            CC3IE: u1 = 0,
            /// CC4IE [4:4]
            /// Capture/Compare 4 interrupt enable
            CC4IE: u1 = 0,
            /// COMIE [5:5]
            /// COM interrupt enable
            COMIE: u1 = 0,
            /// TIE [6:6]
            /// Trigger interrupt enable
            TIE: u1 = 0,
            /// BIE [7:7]
            /// Break interrupt enable
            BIE: u1 = 0,
            /// UDE [8:8]
            /// Update DMA request enable
            UDE: u1 = 0,
            /// CC1DE [9:9]
            /// Capture/Compare 1 DMA request enable
            CC1DE: u1 = 0,
            /// CC2DE [10:10]
            /// Capture/Compare 2 DMA request enable
            CC2DE: u1 = 0,
            /// CC3DE [11:11]
            /// Capture/Compare 3 DMA request enable
            CC3DE: u1 = 0,
            /// CC4DE [12:12]
            /// Capture/Compare 4 DMA request enable
            CC4DE: u1 = 0,
            /// COMDE [13:13]
            /// COM DMA request enable
            COMDE: u1 = 0,
            /// TDE [14:14]
            /// Trigger DMA request enable
            TDE: u1 = 0,
            /// padding [15:31]
            _padding: u17 = 0,
        }, nullable_types.AdvancedTimer.DMAINTENR),

        /// status register
        INTFR: RegisterRW(packed struct(u32) {
            /// UIF [0:0]
            /// Update interrupt flag
            UIF: u1 = 0,
            /// CC1IF [1:1]
            /// Capture/compare 1 interrupt flag
            CC1IF: u1 = 0,
            /// CC2IF [2:2]
            /// Capture/Compare 2 interrupt flag
            CC2IF: u1 = 0,
            /// CC3IF [3:3]
            /// Capture/Compare 3 interrupt flag
            CC3IF: u1 = 0,
            /// CC4IF [4:4]
            /// Capture/Compare 4 interrupt flag
            CC4IF: u1 = 0,
            /// COMIF [5:5]
            /// COM interrupt flag
            COMIF: u1 = 0,
            /// TIF [6:6]
            /// Trigger interrupt flag
            TIF: u1 = 0,
            /// BIF [7:7]
            /// Break interrupt flag
            BIF: u1 = 0,
            /// unused [8:8]
            _unused8: u1 = 0,
            /// CC1OF [9:9]
            /// Capture/Compare 1 overcapture flag
            CC1OF: u1 = 0,
            /// CC2OF [10:10]
            /// Capture/compare 2 overcapture flag
            CC2OF: u1 = 0,
            /// CC3OF [11:11]
            /// Capture/Compare 3 overcapture flag
            CC3OF: u1 = 0,
            /// CC4OF [12:12]
            /// Capture/Compare 4 overcapture flag
            CC4OF: u1 = 0,
            /// padding [13:31]
            _padding: u19 = 0,
        }, nullable_types.AdvancedTimer.INTFR),

        /// event generation register
        SWEVGR: RegisterRW(packed struct(u32) {
            /// UG [0:0]
            /// Update generation
            UG: u1 = 0,
            /// CC1G [1:1]
            /// Capture/compare 1 generation
            CC1G: u1 = 0,
            /// CC2G [2:2]
            /// Capture/compare 2 generation
            CC2G: u1 = 0,
            /// CC3G [3:3]
            /// Capture/compare 3 generation
            CC3G: u1 = 0,
            /// CC4G [4:4]
            /// Capture/compare 4 generation
            CC4G: u1 = 0,
            /// COMG [5:5]
            /// Capture/Compare control update generation
            COMG: u1 = 0,
            /// TG [6:6]
            /// Trigger generation
            TG: u1 = 0,
            /// BG [7:7]
            /// Break generation
            BG: u1 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }, nullable_types.AdvancedTimer.SWEVGR),

        /// capture/compare mode register (output mode)
        CHCTLR1_Output: RegisterRW(packed struct(u32) {
            /// CC1S [0:1]
            /// Capture/Compare 1 selection
            CC1S: u2 = 0,
            /// OC1FE [2:2]
            /// Output Compare 1 fast enable
            OC1FE: u1 = 0,
            /// OC1PE [3:3]
            /// Output Compare 1 preload enable
            OC1PE: u1 = 0,
            /// OC1M [4:6]
            /// Output Compare 1 mode
            OC1M: u3 = 0,
            /// OC1CE [7:7]
            /// Output Compare 1 clear enable
            OC1CE: u1 = 0,
            /// CC2S [8:9]
            /// Capture/Compare 2 selection
            CC2S: u2 = 0,
            /// OC2FE [10:10]
            /// Output Compare 2 fast enable
            OC2FE: u1 = 0,
            /// OC2PE [11:11]
            /// Output Compare 2 preload enable
            OC2PE: u1 = 0,
            /// OC2M [12:14]
            /// Output Compare 2 mode
            OC2M: u3 = 0,
            /// OC2CE [15:15]
            /// Output Compare 2 clear enable
            OC2CE: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AdvancedTimer.CHCTLR1_Output),

        /// capture/compare mode register (output mode)
        CHCTLR2_Output: RegisterRW(packed struct(u32) {
            /// CC3S [0:1]
            /// Capture/Compare 3 selection
            CC3S: u2 = 0,
            /// OC3FE [2:2]
            /// Output compare 3 fast enable
            OC3FE: u1 = 0,
            /// OC3PE [3:3]
            /// Output compare 3 preload enable
            OC3PE: u1 = 0,
            /// OC3M [4:6]
            /// Output compare 3 mode
            OC3M: u3 = 0,
            /// OC3CE [7:7]
            /// Output compare 3 clear enable
            OC3CE: u1 = 0,
            /// CC4S [8:9]
            /// Capture/Compare 4 selection
            CC4S: u2 = 0,
            /// OC4FE [10:10]
            /// Output compare 4 fast enable
            OC4FE: u1 = 0,
            /// OC4PE [11:11]
            /// Output compare 4 preload enable
            OC4PE: u1 = 0,
            /// OC4M [12:14]
            /// Output compare 4 mode
            OC4M: u3 = 0,
            /// OC4CE [15:15]
            /// Output compare 4 clear enable
            OC4CE: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AdvancedTimer.CHCTLR2_Output),

        /// capture/compare enable register
        CCER: RegisterRW(packed struct(u32) {
            /// CC1E [0:0]
            /// Capture/Compare 1 output enable
            CC1E: u1 = 0,
            /// CC1P [1:1]
            /// Capture/Compare 1 output Polarity
            CC1P: u1 = 0,
            /// CC1NE [2:2]
            /// Capture/Compare 1 complementary output enable
            CC1NE: u1 = 0,
            /// CC1NP [3:3]
            /// Capture/Compare 1 output Polarity
            CC1NP: u1 = 0,
            /// CC2E [4:4]
            /// Capture/Compare 2 output enable
            CC2E: u1 = 0,
            /// CC2P [5:5]
            /// Capture/Compare 2 output Polarity
            CC2P: u1 = 0,
            /// CC2NE [6:6]
            /// Capture/Compare 2 complementary output enable
            CC2NE: u1 = 0,
            /// CC2NP [7:7]
            /// Capture/Compare 2 output Polarity
            CC2NP: u1 = 0,
            /// CC3E [8:8]
            /// Capture/Compare 3 output enable
            CC3E: u1 = 0,
            /// CC3P [9:9]
            /// Capture/Compare 3 output Polarity
            CC3P: u1 = 0,
            /// CC3NE [10:10]
            /// Capture/Compare 3 complementary output enable
            CC3NE: u1 = 0,
            /// CC3NP [11:11]
            /// Capture/Compare 3 output Polarity
            CC3NP: u1 = 0,
            /// CC4E [12:12]
            /// Capture/Compare 4 output enable
            CC4E: u1 = 0,
            /// CC4P [13:13]
            /// Capture/Compare 3 output Polarity
            CC4P: u1 = 0,
            /// padding [14:31]
            _padding: u18 = 0,
        }, nullable_types.AdvancedTimer.CCER),

        /// counter
        CNT: RegisterRW(packed struct(u32) {
            /// CNT [0:15]
            /// counter value
            CNT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AdvancedTimer.CNT),

        /// prescaler
        PSC: RegisterRW(packed struct(u32) {
            /// PSC [0:15]
            /// Prescaler value
            PSC: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AdvancedTimer.PSC),

        /// auto-reload register
        ATRLR: RegisterRW(packed struct(u32) {
            /// ATRLR [0:15]
            /// Auto-reload value
            ATRLR: u16 = 65535,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AdvancedTimer.ATRLR),

        /// repetition counter register
        RPTCR: RegisterRW(packed struct(u32) {
            /// RPTCR [0:7]
            /// Repetition counter value
            RPTCR: u8 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }, nullable_types.AdvancedTimer.RPTCR),

        /// capture/compare register 1
        CH1CVR: RegisterRW(packed struct(u32) {
            /// CH1CVR [0:15]
            /// Capture/Compare 1 value
            CH1CVR: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AdvancedTimer.CH1CVR),

        /// capture/compare register 2
        CH2CVR: RegisterRW(packed struct(u32) {
            /// CH2CVR [0:15]
            /// Capture/Compare 2 value
            CH2CVR: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AdvancedTimer.CH2CVR),

        /// capture/compare register 3
        CH3CVR: RegisterRW(packed struct(u32) {
            /// CH3CVR [0:15]
            /// Capture/Compare value
            CH3CVR: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AdvancedTimer.CH3CVR),

        /// capture/compare register 4
        CH4CVR: RegisterRW(packed struct(u32) {
            /// CH4CVR [0:15]
            /// Capture/Compare value
            CH4CVR: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AdvancedTimer.CH4CVR),

        /// break and dead-time register
        BDTR: RegisterRW(packed struct(u32) {
            /// DTG [0:7]
            /// Dead-time generator setup
            DTG: u8 = 0,
            /// LOCK [8:9]
            /// Lock configuration
            LOCK: u2 = 0,
            /// OSSI [10:10]
            /// Off-state selection for Idle mode
            OSSI: u1 = 0,
            /// OSSR [11:11]
            /// Off-state selection for Run mode
            OSSR: u1 = 0,
            /// BKE [12:12]
            /// Break enable
            BKE: u1 = 0,
            /// BKP [13:13]
            /// Break polarity
            BKP: u1 = 0,
            /// AOE [14:14]
            /// Automatic output enable
            AOE: u1 = 0,
            /// MOE [15:15]
            /// Main output enable
            MOE: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AdvancedTimer.BDTR),

        /// DMA control register
        DMACFGR: RegisterRW(packed struct(u32) {
            /// DBA [0:4]
            /// DMA base address
            DBA: u5 = 0,
            /// unused [5:7]
            _unused5: u3 = 0,
            /// DBL [8:12]
            /// DMA burst length
            DBL: u5 = 0,
            /// padding [13:31]
            _padding: u19 = 0,
        }, nullable_types.AdvancedTimer.DMACFGR),

        /// DMA address for full transfer
        DMAADR: RegisterRW(packed struct(u32) {
            /// DMAB [0:15]
            /// DMA register for burst accesses
            DMAB: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AdvancedTimer.DMAADR),
    };

    /// General purpose timer
    /// Type for: TIM2
    pub const GeneralPurposeTimer = extern struct {
        pub const TIM2 = types.GeneralPurposeTimer.from(0x40000000);

        pub inline fn from(base: u32) *volatile types.GeneralPurposeTimer {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.GeneralPurposeTimer) u32 {
            return @intFromPtr(self);
        }

        /// control register 1
        CTLR1: RegisterRW(packed struct(u32) {
            /// CEN [0:0]
            /// Counter enable
            CEN: u1 = 0,
            /// UDIS [1:1]
            /// Update disable
            UDIS: u1 = 0,
            /// URS [2:2]
            /// Update request source
            URS: u1 = 0,
            /// OPM [3:3]
            /// One-pulse mode
            OPM: u1 = 0,
            /// DIR [4:4]
            /// Direction
            DIR: u1 = 0,
            /// CMS [5:6]
            /// Center-aligned mode selection
            CMS: u2 = 0,
            /// ARPE [7:7]
            /// Auto-reload preload enable
            ARPE: u1 = 0,
            /// CKD [8:9]
            /// Clock division
            CKD: u2 = 0,
            /// unused [10:13]
            _unused10: u4 = 0,
            /// CAPOV [14:14]
            /// Timer capture value configuration enable
            CAPOV: u1 = 0,
            /// CAPLVL [15:15]
            /// Timer capture level indication enable
            CAPLVL: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.CTLR1),

        /// control register 2
        CTLR2: RegisterRW(packed struct(u32) {
            /// unused [0:2]
            _unused0: u3 = 0,
            /// CCDS [3:3]
            /// Capture/compare DMA selection
            CCDS: u1 = 0,
            /// MMS [4:6]
            /// Master mode selection
            MMS: u3 = 0,
            /// TI1S [7:7]
            /// TI1 selection
            TI1S: u1 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }, nullable_types.GeneralPurposeTimer.CTLR2),

        /// slave mode control register
        SMCFGR: RegisterRW(packed struct(u32) {
            /// SMS [0:2]
            /// Slave mode selection
            SMS: u3 = 0,
            /// unused [3:3]
            _unused3: u1 = 0,
            /// TS [4:6]
            /// Trigger selection
            TS: u3 = 0,
            /// MSM [7:7]
            /// Master/Slave mode
            MSM: u1 = 0,
            /// ETF [8:11]
            /// External trigger filter
            ETF: u4 = 0,
            /// ETPS [12:13]
            /// External trigger prescaler
            ETPS: u2 = 0,
            /// ECE [14:14]
            /// External clock enable
            ECE: u1 = 0,
            /// ETP [15:15]
            /// External trigger polarity
            ETP: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.SMCFGR),

        /// DMA/Interrupt enable register
        DMAINTENR: RegisterRW(packed struct(u32) {
            /// UIE [0:0]
            /// Update interrupt enable
            UIE: u1 = 0,
            /// CC1IE [1:1]
            /// Capture/Compare 1 interrupt enable
            CC1IE: u1 = 0,
            /// CC2IE [2:2]
            /// Capture/Compare 2 interrupt enable
            CC2IE: u1 = 0,
            /// CC3IE [3:3]
            /// Capture/Compare 3 interrupt enable
            CC3IE: u1 = 0,
            /// CC4IE [4:4]
            /// Capture/Compare 4 interrupt enable
            CC4IE: u1 = 0,
            /// unused [5:5]
            _unused5: u1 = 0,
            /// TIE [6:6]
            /// Trigger interrupt enable
            TIE: u1 = 0,
            /// unused [7:7]
            _unused7: u1 = 0,
            /// UDE [8:8]
            /// Update DMA request enable
            UDE: u1 = 0,
            /// CC1DE [9:9]
            /// Capture/Compare 1 DMA request enable
            CC1DE: u1 = 0,
            /// CC2DE [10:10]
            /// Capture/Compare 2 DMA request enable
            CC2DE: u1 = 0,
            /// CC3DE [11:11]
            /// Capture/Compare 3 DMA request enable
            CC3DE: u1 = 0,
            /// CC4DE [12:12]
            /// Capture/Compare 4 DMA request enable
            CC4DE: u1 = 0,
            /// unused [13:13]
            _unused13: u1 = 0,
            /// TDE [14:14]
            /// Trigger DMA request enable
            TDE: u1 = 0,
            /// padding [15:31]
            _padding: u17 = 0,
        }, nullable_types.GeneralPurposeTimer.DMAINTENR),

        /// status register
        INTFR: RegisterRW(packed struct(u32) {
            /// UIF [0:0]
            /// Update interrupt flag
            UIF: u1 = 0,
            /// CC1IF [1:1]
            /// Capture/compare 1 interrupt flag
            CC1IF: u1 = 0,
            /// CC2IF [2:2]
            /// Capture/Compare 2 interrupt flag
            CC2IF: u1 = 0,
            /// CC3IF [3:3]
            /// Capture/Compare 3 interrupt flag
            CC3IF: u1 = 0,
            /// CC4IF [4:4]
            /// Capture/Compare 4 interrupt flag
            CC4IF: u1 = 0,
            /// unused [5:5]
            _unused5: u1 = 0,
            /// TIF [6:6]
            /// Trigger interrupt flag
            TIF: u1 = 0,
            /// unused [7:8]
            _unused7: u1 = 0,
            _unused8: u1 = 0,
            /// CC1OF [9:9]
            /// Capture/Compare 1 overcapture flag
            CC1OF: u1 = 0,
            /// CC2OF [10:10]
            /// Capture/compare 2 overcapture flag
            CC2OF: u1 = 0,
            /// CC3OF [11:11]
            /// Capture/Compare 3 overcapture flag
            CC3OF: u1 = 0,
            /// CC4OF [12:12]
            /// Capture/Compare 4 overcapture flag
            CC4OF: u1 = 0,
            /// padding [13:31]
            _padding: u19 = 0,
        }, nullable_types.GeneralPurposeTimer.INTFR),

        /// event generation register
        SWEVGR: RegisterRW(packed struct(u32) {
            /// UG [0:0]
            /// Update generation
            UG: u1 = 0,
            /// CC1G [1:1]
            /// Capture/compare 1 generation
            CC1G: u1 = 0,
            /// CC2G [2:2]
            /// Capture/compare 2 generation
            CC2G: u1 = 0,
            /// CC3G [3:3]
            /// Capture/compare 3 generation
            CC3G: u1 = 0,
            /// CC4G [4:4]
            /// Capture/compare 4 generation
            CC4G: u1 = 0,
            /// unused [5:5]
            _unused5: u1 = 0,
            /// TG [6:6]
            /// Trigger generation
            TG: u1 = 0,
            /// padding [7:31]
            _padding: u25 = 0,
        }, nullable_types.GeneralPurposeTimer.SWEVGR),

        /// capture/compare mode register 1 (output mode)
        CHCTLR1_Output: RegisterRW(packed struct(u32) {
            /// CC1S [0:1]
            /// Capture/Compare 1 selection
            CC1S: u2 = 0,
            /// OC1FE [2:2]
            /// Output compare 1 fast enable
            OC1FE: u1 = 0,
            /// OC1PE [3:3]
            /// Output compare 1 preload enable
            OC1PE: u1 = 0,
            /// OC1M [4:6]
            /// Output compare 1 mode
            OC1M: u3 = 0,
            /// OC1CE [7:7]
            /// Output compare 1 clear enable
            OC1CE: u1 = 0,
            /// CC2S [8:9]
            /// Capture/Compare channel 2 input selection
            CC2S: u2 = 0,
            /// OC2FE [10:10]
            /// Output compare channel 2 fast enable
            OC2FE: u1 = 0,
            /// OC2PE [11:11]
            /// Compare capture register 1 preload enable
            OC2PE: u1 = 0,
            /// OC2M [12:14]
            /// Output compare channel 2 mode
            OC2M: u3 = 0,
            /// OC2CE [15:15]
            /// Output compare channel 2 clear enable
            OC2CE: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.CHCTLR1_Output),

        /// capture/compare mode register 2 (output mode)
        CHCTLR2_Output: RegisterRW(packed struct(u32) {
            /// CC3S [0:1]
            /// Capture/Compare 3 selection
            CC3S: u2 = 0,
            /// OC3FE [2:2]
            /// Output compare 3 fast enable
            OC3FE: u1 = 0,
            /// OC3PE [3:3]
            /// Output compare 3 preload enable
            OC3PE: u1 = 0,
            /// OC3M [4:6]
            /// Output compare 3 mode
            OC3M: u3 = 0,
            /// OC3CE [7:7]
            /// Output compare 3 clear enable
            OC3CE: u1 = 0,
            /// CC4S [8:9]
            /// Capture/Compare 4 selection
            CC4S: u2 = 0,
            /// OC4FE [10:10]
            /// Output compare 4 fast enable
            OC4FE: u1 = 0,
            /// OC4PE [11:11]
            /// Output compare 4 preload enable
            OC4PE: u1 = 0,
            /// OC4M [12:14]
            /// Output compare 4 mode
            OC4M: u3 = 0,
            /// OC4CE [15:15]
            /// Output compare 4 clear enable
            OC4CE: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.CHCTLR2_Output),

        /// capture/compare enable register
        CCER: RegisterRW(packed struct(u32) {
            /// CC1E [0:0]
            /// Capture/Compare channel 1 output enable
            CC1E: u1 = 0,
            /// CC1P [1:1]
            /// Capture/Compare channel 1 output Polarity
            CC1P: u1 = 0,
            /// unused [2:3]
            _unused2: u2 = 0,
            /// CC2E [4:4]
            /// Capture/Compare channel 2 output enable
            CC2E: u1 = 0,
            /// CC2P [5:5]
            /// Capture/Compare channel 2 output Polarity
            CC2P: u1 = 0,
            /// unused [6:7]
            _unused6: u2 = 0,
            /// CC3E [8:8]
            /// Capture/Compare channel 3 output enable
            CC3E: u1 = 0,
            /// CC3P [9:9]
            /// Capture/Compare channel 3 output Polarity
            CC3P: u1 = 0,
            /// unused [10:11]
            _unused10: u2 = 0,
            /// CC4E [12:12]
            /// Capture/Compare channel 4 output enable
            CC4E: u1 = 0,
            /// CC4P [13:13]
            /// Capture/Compare channel 4 output Polarity
            CC4P: u1 = 0,
            /// padding [14:31]
            _padding: u18 = 0,
        }, nullable_types.GeneralPurposeTimer.CCER),

        /// counter
        CNT: RegisterRW(packed struct(u32) {
            /// CNT [0:15]
            /// counter value
            CNT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.CNT),

        /// prescaler
        PSC: RegisterRW(packed struct(u32) {
            /// PSC [0:15]
            /// Prescaler value
            PSC: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.PSC),

        /// auto-reload register
        ATRLR: RegisterRW(packed struct(u32) {
            /// ATRLR [0:15]
            /// Auto-reload value
            ATRLR: u16 = 65535,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.ATRLR),

        /// offset 0x4
        _offset14: [4]u8,

        /// capture/compare register 1
        CH1CVR: RegisterRW(packed struct(u32) {
            /// CH1CVR [0:15]
            /// Capture/Compare 1 value
            CH1CVR: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.CH1CVR),

        /// capture/compare register 2
        CH2CVR: RegisterRW(packed struct(u32) {
            /// CH2CVR [0:15]
            /// Capture/Compare 2 value
            CH2CVR: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.CH2CVR),

        /// capture/compare register 3
        CH3CVR: RegisterRW(packed struct(u32) {
            /// CH3CVR [0:15]
            /// Capture/Compare 3 value
            CH3CVR: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.CH3CVR),

        /// capture/compare register 4
        CH4CVR: RegisterRW(packed struct(u32) {
            /// CH4CVR [0:15]
            /// Capture/Compare 4 value
            CH4CVR: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.CH4CVR),

        /// offset 0x4
        _offset18: [4]u8,

        /// DMA control register
        DMACFGR: RegisterRW(packed struct(u32) {
            /// DBA [0:4]
            /// DMA base address
            DBA: u5 = 0,
            /// unused [5:7]
            _unused5: u3 = 0,
            /// DBL [8:12]
            /// DMA burst length
            DBL: u5 = 0,
            /// padding [13:31]
            _padding: u19 = 0,
        }, nullable_types.GeneralPurposeTimer.DMACFGR),

        /// DMA address for full transfer
        DMAADR: RegisterRW(packed struct(u32) {
            /// DMAADR [0:15]
            /// DMA register for burst accesses
            DMAADR: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.DMAADR),
    };

    /// Inter integrated circuit
    /// Type for: I2C1
    pub const I2C = extern struct {
        pub const I2C1 = types.I2C.from(0x40005400);

        pub inline fn from(base: u32) *volatile types.I2C {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.I2C) u32 {
            return @intFromPtr(self);
        }

        /// Control register 1
        CTLR1: RegisterRW(packed struct(u32) {
            /// PE [0:0]
            /// Peripheral enable
            PE: u1 = 0,
            /// unused [1:4]
            _unused1: u4 = 0,
            /// ENPEC [5:5]
            /// PEC enable
            ENPEC: u1 = 0,
            /// ENGC [6:6]
            /// General call enable
            ENGC: u1 = 0,
            /// NOSTRETCH [7:7]
            /// Clock stretching disable (Slave mode)
            NOSTRETCH: u1 = 0,
            /// START [8:8]
            /// Start generation
            START: u1 = 0,
            /// STOP [9:9]
            /// Stop generation
            STOP: u1 = 0,
            /// ACK [10:10]
            /// Acknowledge enable
            ACK: u1 = 0,
            /// POS [11:11]
            /// Acknowledge/PEC Position (for data reception)
            POS: u1 = 0,
            /// PEC [12:12]
            /// Packet error checking
            PEC: u1 = 0,
            /// unused [13:14]
            _unused13: u2 = 0,
            /// SWRST [15:15]
            /// Software reset
            SWRST: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.I2C.CTLR1),

        /// Control register 2
        CTLR2: RegisterRW(packed struct(u32) {
            /// FREQ [0:5]
            /// Peripheral clock frequency
            FREQ: u6 = 0,
            /// unused [6:7]
            _unused6: u2 = 0,
            /// ITERREN [8:8]
            /// Error interrupt enable
            ITERREN: u1 = 0,
            /// ITEVTEN [9:9]
            /// Event interrupt enable
            ITEVTEN: u1 = 0,
            /// ITBUFEN [10:10]
            /// Buffer interrupt enable
            ITBUFEN: u1 = 0,
            /// DMAEN [11:11]
            /// DMA requests enable
            DMAEN: u1 = 0,
            /// LAST [12:12]
            /// DMA last transfer
            LAST: u1 = 0,
            /// padding [13:31]
            _padding: u19 = 0,
        }, nullable_types.I2C.CTLR2),

        /// Own address register 1
        OADDR1: RegisterRW(packed struct(u32) {
            /// ADD0 [0:0]
            /// Interface address
            ADD0: u1 = 0,
            /// ADD7_1 [1:7]
            /// Interface address
            ADD7_1: u7 = 0,
            /// ADD9_8 [8:9]
            /// Interface address
            ADD9_8: u2 = 0,
            /// unused [10:14]
            _unused10: u5 = 0,
            /// ADDMODE [15:15]
            /// Addressing mode (slave mode)
            ADDMODE: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.I2C.OADDR1),

        /// Own address register 2
        OADDR2: RegisterRW(packed struct(u32) {
            /// ENDUAL [0:0]
            /// Dual addressing mode enable
            ENDUAL: u1 = 0,
            /// ADD2 [1:7]
            /// Interface address
            ADD2: u7 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }, nullable_types.I2C.OADDR2),

        /// Data register
        DATAR: RegisterRW(packed struct(u32) {
            /// DATAR [0:7]
            /// 8-bit data register
            DATAR: u8 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }, nullable_types.I2C.DATAR),

        /// Status register 1
        STAR1: RegisterRW(packed struct(u32) {
            /// SB [0:0]
            /// Start bit (Master mode)
            SB: u1 = 0,
            /// ADDR [1:1]
            /// Address sent (master mode)/matched (slave mode)
            ADDR: u1 = 0,
            /// BTF [2:2]
            /// Byte transfer finished
            BTF: u1 = 0,
            /// ADD10 [3:3]
            /// 10-bit header sent (Master mode)
            ADD10: u1 = 0,
            /// STOPF [4:4]
            /// Stop detection (slave mode)
            STOPF: u1 = 0,
            /// unused [5:5]
            _unused5: u1 = 0,
            /// RxNE [6:6]
            /// Data register not empty (receivers)
            RxNE: u1 = 0,
            /// TxE [7:7]
            /// Data register empty (transmitters)
            TxE: u1 = 0,
            /// BERR [8:8]
            /// Bus error
            BERR: u1 = 0,
            /// ARLO [9:9]
            /// Arbitration lost (master mode)
            ARLO: u1 = 0,
            /// AF [10:10]
            /// Acknowledge failure
            AF: u1 = 0,
            /// OVR [11:11]
            /// Overrun/Underrun
            OVR: u1 = 0,
            /// PECERR [12:12]
            /// PEC Error in reception
            PECERR: u1 = 0,
            /// padding [13:31]
            _padding: u19 = 0,
        }, nullable_types.I2C.STAR1),

        /// Status register 2
        STAR2: RegisterRW(packed struct(u32) {
            /// MSL [0:0]
            /// Master/slave
            MSL: u1 = 0,
            /// BUSY [1:1]
            /// Bus busy
            BUSY: u1 = 0,
            /// TRA [2:2]
            /// Transmitter/receiver
            TRA: u1 = 0,
            /// unused [3:3]
            _unused3: u1 = 0,
            /// GENCALL [4:4]
            /// General call address (Slave mode)
            GENCALL: u1 = 0,
            /// unused [5:6]
            _unused5: u2 = 0,
            /// DUALF [7:7]
            /// Dual flag (Slave mode)
            DUALF: u1 = 0,
            /// PEC [8:15]
            /// acket error checking register
            PEC: u8 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.I2C.STAR2),

        /// Clock control register
        CKCFGR: RegisterRW(packed struct(u32) {
            /// CCR [0:11]
            /// Clock control register in Fast/Standard mode (Master mode)
            CCR: u12 = 0,
            /// unused [12:13]
            _unused12: u2 = 0,
            /// DUTY [14:14]
            /// Fast mode duty cycle
            DUTY: u1 = 0,
            /// F_S [15:15]
            /// I2C master mode selection
            F_S: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.I2C.CKCFGR),
    };

    /// Serial peripheral interface
    /// Type for: SPI1
    pub const SPI = extern struct {
        pub const SPI1 = types.SPI.from(0x40013000);

        pub inline fn from(base: u32) *volatile types.SPI {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.SPI) u32 {
            return @intFromPtr(self);
        }

        /// control register 1
        CTLR1: RegisterRW(packed struct(u32) {
            /// CPHA [0:0]
            /// Clock phase
            CPHA: u1 = 0,
            /// CPOL [1:1]
            /// Clock polarity
            CPOL: u1 = 0,
            /// MSTR [2:2]
            /// Master selection
            MSTR: u1 = 0,
            /// BR [3:5]
            /// Baud rate control
            BR: u3 = 0,
            /// SPE [6:6]
            /// SPI enable
            SPE: u1 = 0,
            /// LSBFIRST [7:7]
            /// Frame format
            LSBFIRST: u1 = 0,
            /// SSI [8:8]
            /// Internal slave select
            SSI: u1 = 0,
            /// SSM [9:9]
            /// Software slave management
            SSM: u1 = 0,
            /// RXONLY [10:10]
            /// Receive only
            RXONLY: u1 = 0,
            /// DFF [11:11]
            /// Data frame format
            DFF: u1 = 0,
            /// CRCNEXT [12:12]
            /// CRC transfer next
            CRCNEXT: u1 = 0,
            /// CRCEN [13:13]
            /// Hardware CRC calculation enable
            CRCEN: u1 = 0,
            /// BIDIOE [14:14]
            /// Output enable in bidirectional mode
            BIDIOE: u1 = 0,
            /// BIDIMODE [15:15]
            /// Bidirectional data mode enable
            BIDIMODE: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.SPI.CTLR1),

        /// control register 2
        CTLR2: RegisterRW(packed struct(u32) {
            /// RXDMAEN [0:0]
            /// Rx buffer DMA enable
            RXDMAEN: u1 = 0,
            /// TXDMAEN [1:1]
            /// Tx buffer DMA enable
            TXDMAEN: u1 = 0,
            /// SSOE [2:2]
            /// SS output enable
            SSOE: u1 = 0,
            /// unused [3:4]
            _unused3: u2 = 0,
            /// ERRIE [5:5]
            /// Error interrupt enable
            ERRIE: u1 = 0,
            /// RXNEIE [6:6]
            /// RX buffer not empty interrupt enable
            RXNEIE: u1 = 0,
            /// TXEIE [7:7]
            /// Tx buffer empty interrupt enable
            TXEIE: u1 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }, nullable_types.SPI.CTLR2),

        /// status register
        STATR: RegisterRW(packed struct(u32) {
            /// RXNE [0:0]
            /// Receive buffer not empty
            RXNE: u1 = 0,
            /// TXE [1:1]
            /// Transmit buffer empty
            TXE: u1 = 1,
            /// CHSID [2:2]
            /// Channel side
            CHSID: u1 = 0,
            /// UDR [3:3]
            /// Underrun flag
            UDR: u1 = 0,
            /// CRCERR [4:4]
            /// CRC error flag
            CRCERR: u1 = 0,
            /// MODF [5:5]
            /// Mode fault
            MODF: u1 = 0,
            /// OVR [6:6]
            /// Overrun flag
            OVR: u1 = 0,
            /// BSY [7:7]
            /// Busy flag
            BSY: u1 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }, nullable_types.SPI.STATR),

        /// data register
        DATAR: RegisterRW(packed struct(u32) {
            /// DATAR [0:15]
            /// Data register
            DATAR: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.SPI.DATAR),

        /// CRCR polynomial register
        CRCR: RegisterRW(packed struct(u32) {
            /// CRCPOLY [0:15]
            /// CRC polynomial register
            CRCPOLY: u16 = 7,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.SPI.CRCR),

        /// RX CRC register
        RCRCR: RegisterRW(packed struct(u32) {
            /// RXCRC [0:15]
            /// Rx CRC register
            RXCRC: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.SPI.RCRCR),

        /// send CRC register
        TCRCR: RegisterRW(packed struct(u32) {
            /// TXCRC [0:15]
            /// Tx CRC register
            TXCRC: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.SPI.TCRCR),

        /// offset 0x8
        _offset7: [8]u8,

        /// high speed control register
        HSCR: RegisterRW(packed struct(u32) {
            /// HSRXEN [0:0]
            /// High speed mode read enable
            HSRXEN: u1 = 0,
            /// padding [1:31]
            _padding: u31 = 0,
        }, nullable_types.SPI.HSCR),
    };

    /// Universal synchronous asynchronous receiver transmitter
    /// Type for: USART1
    pub const USART = extern struct {
        pub const USART1 = types.USART.from(0x40013800);

        pub inline fn from(base: u32) *volatile types.USART {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.USART) u32 {
            return @intFromPtr(self);
        }

        /// Status register
        STATR: RegisterRW(packed struct(u32) {
            /// PE [0:0]
            /// Parity error
            PE: u1 = 0,
            /// FE [1:1]
            /// Framing error
            FE: u1 = 0,
            /// NE [2:2]
            /// Noise error flag
            NE: u1 = 0,
            /// ORE [3:3]
            /// Overrun error
            ORE: u1 = 0,
            /// IDLE [4:4]
            /// IDLE line detected
            IDLE: u1 = 0,
            /// RXNE [5:5]
            /// Read data register not empty
            RXNE: u1 = 0,
            /// TC [6:6]
            /// Transmission complete
            TC: u1 = 1,
            /// TXE [7:7]
            /// Transmit data register empty
            TXE: u1 = 1,
            /// LBD [8:8]
            /// LIN break detection flag
            LBD: u1 = 0,
            /// CTS [9:9]
            /// CTS flag
            CTS: u1 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }, nullable_types.USART.STATR),

        /// Data register
        DATAR: RegisterRW(packed struct(u32) {
            /// DR [0:8]
            /// Data value
            DR: u9 = 0,
            /// padding [9:31]
            _padding: u23 = 0,
        }, nullable_types.USART.DATAR),

        /// Baud rate register
        BRR: RegisterRW(packed struct(u32) {
            /// DIV_Fraction [0:3]
            /// fraction of USARTDIV
            DIV_Fraction: u4 = 0,
            /// DIV_Mantissa [4:15]
            /// mantissa of USARTDIV
            DIV_Mantissa: u12 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.USART.BRR),

        /// Control register 1
        CTLR1: RegisterRW(packed struct(u32) {
            /// SBK [0:0]
            /// Send break
            SBK: u1 = 0,
            /// RWU [1:1]
            /// Receiver wakeup
            RWU: u1 = 0,
            /// RE [2:2]
            /// Receiver enable
            RE: u1 = 0,
            /// TE [3:3]
            /// Transmitter enable
            TE: u1 = 0,
            /// IDLEIE [4:4]
            /// IDLE interrupt enable
            IDLEIE: u1 = 0,
            /// RXNEIE [5:5]
            /// RXNE interrupt enable
            RXNEIE: u1 = 0,
            /// TCIE [6:6]
            /// Transmission complete interrupt enable
            TCIE: u1 = 0,
            /// TXEIE [7:7]
            /// TXE interrupt enable
            TXEIE: u1 = 0,
            /// PEIE [8:8]
            /// PE interrupt enable
            PEIE: u1 = 0,
            /// PS [9:9]
            /// Parity selection
            PS: u1 = 0,
            /// PCE [10:10]
            /// Parity control enable
            PCE: u1 = 0,
            /// WAKE [11:11]
            /// Wakeup method
            WAKE: u1 = 0,
            /// M [12:12]
            /// Word length
            M: u1 = 0,
            /// UE [13:13]
            /// USART enable
            UE: u1 = 0,
            /// padding [14:31]
            _padding: u18 = 0,
        }, nullable_types.USART.CTLR1),

        /// Control register 2
        CTLR2: RegisterRW(packed struct(u32) {
            /// ADD [0:3]
            /// Address of the USART node
            ADD: u4 = 0,
            /// unused [4:4]
            _unused4: u1 = 0,
            /// LBDL [5:5]
            /// lin break detection length
            LBDL: u1 = 0,
            /// LBDIE [6:6]
            /// LIN break detection interrupt enable
            LBDIE: u1 = 0,
            /// unused [7:7]
            _unused7: u1 = 0,
            /// LBCL [8:8]
            /// Last bit clock pulse
            LBCL: u1 = 0,
            /// CPHA [9:9]
            /// Clock phase
            CPHA: u1 = 0,
            /// CPOL [10:10]
            /// Clock polarity
            CPOL: u1 = 0,
            /// CLKEN [11:11]
            /// Clock enable
            CLKEN: u1 = 0,
            /// STOP [12:13]
            /// STOP bits
            STOP: u2 = 0,
            /// LINEN [14:14]
            /// LIN mode enable
            LINEN: u1 = 0,
            /// padding [15:31]
            _padding: u17 = 0,
        }, nullable_types.USART.CTLR2),

        /// Control register 3
        CTLR3: RegisterRW(packed struct(u32) {
            /// EIE [0:0]
            /// Error interrupt enable
            EIE: u1 = 0,
            /// IREN [1:1]
            /// IrDA mode enable
            IREN: u1 = 0,
            /// IRLP [2:2]
            /// IrDA low-power
            IRLP: u1 = 0,
            /// HDSEL [3:3]
            /// Half-duplex selection
            HDSEL: u1 = 0,
            /// NACK [4:4]
            /// Smartcard NACK enable
            NACK: u1 = 0,
            /// SCEN [5:5]
            /// Smartcard mode enable
            SCEN: u1 = 0,
            /// DMAR [6:6]
            /// DMA enable receiver
            DMAR: u1 = 0,
            /// DMAT [7:7]
            /// DMA enable transmitter
            DMAT: u1 = 0,
            /// RTSE [8:8]
            /// RTS enable
            RTSE: u1 = 0,
            /// CTSE [9:9]
            /// CTS enable
            CTSE: u1 = 0,
            /// CTSIE [10:10]
            /// CTS interrupt enable
            CTSIE: u1 = 0,
            /// padding [11:31]
            _padding: u21 = 0,
        }, nullable_types.USART.CTLR3),

        /// Guard time and prescaler register
        GPR: RegisterRW(packed struct(u32) {
            /// PSC [0:7]
            /// Prescaler value
            PSC: u8 = 0,
            /// GT [8:15]
            /// Guard time value
            GT: u8 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.USART.GPR),
    };

    /// Analog to digital converter
    pub const ADC1 = extern struct {
        pub inline fn from(base: u32) *volatile types.ADC1 {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.ADC1) u32 {
            return @intFromPtr(self);
        }

        /// status register
        STATR: RegisterRW(packed struct(u32) {
            /// AWD [0:0]
            /// Analog watchdog flag
            AWD: u1 = 0,
            /// EOC [1:1]
            /// Regular channel end of conversion
            EOC: u1 = 0,
            /// JEOC [2:2]
            /// Injected channel end of conversion
            JEOC: u1 = 0,
            /// JSTRT [3:3]
            /// Injected channel start flag
            JSTRT: u1 = 0,
            /// STRT [4:4]
            /// Regular channel start flag
            STRT: u1 = 0,
            /// padding [5:31]
            _padding: u27 = 0,
        }, nullable_types.ADC1.STATR),

        /// control register 1/TKEY_V_CTLR
        CTLR1: RegisterRW(packed struct(u32) {
            /// AWDCH [0:4]
            /// Analog watchdog channel select bits
            AWDCH: u5 = 0,
            /// EOCIE [5:5]
            /// Interrupt enable for EOC
            EOCIE: u1 = 0,
            /// AWDIE [6:6]
            /// Analog watchdog interrupt enable
            AWDIE: u1 = 0,
            /// JEOCIE [7:7]
            /// Interrupt enable for injected channels
            JEOCIE: u1 = 0,
            /// SCAN [8:8]
            /// Scan mode enable
            SCAN: u1 = 0,
            /// AWDSGL [9:9]
            /// Enable the watchdog on a single channel in scan mode
            AWDSGL: u1 = 0,
            /// JAUTO [10:10]
            /// Automatic injected group conversion
            JAUTO: u1 = 0,
            /// DISCEN [11:11]
            /// Discontinuous mode on regular channels
            DISCEN: u1 = 0,
            /// JDISCEN [12:12]
            /// Discontinuous mode on injected channels
            JDISCEN: u1 = 0,
            /// DISCNUM [13:15]
            /// Discontinuous mode channel count
            DISCNUM: u3 = 0,
            /// unused [16:21]
            _unused16: u6 = 0,
            /// JAWDEN [22:22]
            /// Analog watchdog enable on injected channels
            JAWDEN: u1 = 0,
            /// AWDEN [23:23]
            /// Analog watchdog enable on regular channels
            AWDEN: u1 = 0,
            /// unused [24:24]
            _unused24: u1 = 0,
            /// CALVOL [25:26]
            /// ADC Calibration voltage selection
            CALVOL: u2 = 0,
            /// padding [27:31]
            _padding: u5 = 0,
        }, nullable_types.ADC1.CTLR1),

        /// control register 2
        CTLR2: RegisterRW(packed struct(u32) {
            /// ADON [0:0]
            /// A/D converter ON / OFF
            ADON: u1 = 0,
            /// CONT [1:1]
            /// Continuous conversion
            CONT: u1 = 0,
            /// CAL [2:2]
            /// A/D calibration
            CAL: u1 = 0,
            /// RSTCAL [3:3]
            /// Reset calibration
            RSTCAL: u1 = 0,
            /// unused [4:7]
            _unused4: u4 = 0,
            /// DMA [8:8]
            /// Direct memory access mode
            DMA: u1 = 0,
            /// unused [9:10]
            _unused9: u2 = 0,
            /// ALIGN [11:11]
            /// Data alignment
            ALIGN: u1 = 0,
            /// JEXTSEL [12:14]
            /// External event select for injected group
            JEXTSEL: u3 = 0,
            /// JEXTTRIG [15:15]
            /// External trigger conversion mode for injected channels
            JEXTTRIG: u1 = 0,
            /// unused [16:16]
            _unused16: u1 = 0,
            /// EXTSEL [17:19]
            /// External event select for regular group
            EXTSEL: u3 = 0,
            /// EXTTRIG [20:20]
            /// External trigger conversion mode for regular channels
            EXTTRIG: u1 = 0,
            /// JSWSTART [21:21]
            /// Start conversion of injected channels
            JSWSTART: u1 = 0,
            /// SWSTART [22:22]
            /// Start conversion of regular channels
            SWSTART: u1 = 0,
            /// padding [23:31]
            _padding: u9 = 0,
        }, nullable_types.ADC1.CTLR2),

        /// sample time register 1
        SAMPTR1: RegisterRW(packed struct(u32) {
            /// SMP10 [0:2]
            /// Channel 10 sample time selection
            SMP10: u3 = 0,
            /// SMP11 [3:5]
            /// Channel 11 sample time selection
            SMP11: u3 = 0,
            /// SMP12_TKCG12 [6:8]
            /// Channel 12 sample time selection
            SMP12_TKCG12: u3 = 0,
            /// SMP13 [9:11]
            /// Channel 13 sample time selection
            SMP13: u3 = 0,
            /// SMP14 [12:14]
            /// Channel 14 sample time selection
            SMP14: u3 = 0,
            /// SMP15 [15:17]
            /// Channel 15 sample time selection
            SMP15: u3 = 0,
            /// padding [18:31]
            _padding: u14 = 0,
        }, nullable_types.ADC1.SAMPTR1),

        /// sample time register 2
        SAMPTR2: RegisterRW(packed struct(u32) {
            /// SMP0 [0:2]
            /// Channel 0 sample time selection
            SMP0: u3 = 0,
            /// SMP1 [3:5]
            /// Channel 1 sample time selection
            SMP1: u3 = 0,
            /// SMP2 [6:8]
            /// Channel 2 sample time selection
            SMP2: u3 = 0,
            /// SMP3 [9:11]
            /// Channel 3 sample time selection
            SMP3: u3 = 0,
            /// SMP4 [12:14]
            /// Channel 4 sample time selection
            SMP4: u3 = 0,
            /// SMP5 [15:17]
            /// Channel 5 sample time selection
            SMP5: u3 = 0,
            /// SMP6_TKCG6 [18:20]
            /// Channel 6 sample time selection
            SMP6_TKCG6: u3 = 0,
            /// SMP7 [21:23]
            /// Channel 7 sample time selection
            SMP7: u3 = 0,
            /// SMP8 [24:26]
            /// Channel 8 sample time selection
            SMP8: u3 = 0,
            /// SMP9 [27:29]
            /// Channel 9 sample time selection
            SMP9: u3 = 0,
            /// padding [30:31]
            _padding: u2 = 0,
        }, nullable_types.ADC1.SAMPTR2),

        /// injected channel data offset register x
        IOFR1: RegisterRW(packed struct(u32) {
            /// JOFFSET1 [0:9]
            /// Data offset for injected channel x
            JOFFSET1: u10 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }, nullable_types.ADC1.IOFR1),

        /// injected channel data offset register x
        IOFR2: RegisterRW(packed struct(u32) {
            /// JOFFSET2 [0:9]
            /// Data offset for injected channel x
            JOFFSET2: u10 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }, nullable_types.ADC1.IOFR2),

        /// injected channel data offset register x
        IOFR3: RegisterRW(packed struct(u32) {
            /// JOFFSET3 [0:9]
            /// Data offset for injected channel x
            JOFFSET3: u10 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }, nullable_types.ADC1.IOFR3),

        /// injected channel data offset register x
        IOFR4: RegisterRW(packed struct(u32) {
            /// JOFFSET4 [0:9]
            /// Data offset for injected channel x
            JOFFSET4: u10 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }, nullable_types.ADC1.IOFR4),

        /// watchdog higher threshold register
        WDHTR: RegisterRW(packed struct(u32) {
            /// HT [0:9]
            /// Analog watchdog higher threshold
            HT: u10 = 1023,
            /// padding [10:31]
            _padding: u22 = 0,
        }, nullable_types.ADC1.WDHTR),

        /// watchdog lower threshold register
        WDLTR: RegisterRW(packed struct(u32) {
            /// LT [0:9]
            /// Analog watchdog lower threshold
            LT: u10 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }, nullable_types.ADC1.WDLTR),

        /// regular sequence register 1
        RSQR1: RegisterRW(packed struct(u32) {
            /// SQ13 [0:4]
            /// 13th conversion in regular sequence
            SQ13: u5 = 0,
            /// SQ14 [5:9]
            /// 14th conversion in regular sequence
            SQ14: u5 = 0,
            /// SQ15 [10:14]
            /// 15th conversion in regular sequence
            SQ15: u5 = 0,
            /// SQ16 [15:19]
            /// 16th conversion in regular sequence
            SQ16: u5 = 0,
            /// L [20:23]
            /// Regular channel sequence length
            L: u4 = 0,
            /// padding [24:31]
            _padding: u8 = 0,
        }, nullable_types.ADC1.RSQR1),

        /// regular sequence register 2
        RSQR2: RegisterRW(packed struct(u32) {
            /// SQ7 [0:4]
            /// 7th conversion in regular sequence
            SQ7: u5 = 0,
            /// SQ8 [5:9]
            /// 8th conversion in regular sequence
            SQ8: u5 = 0,
            /// SQ9 [10:14]
            /// 9th conversion in regular sequence
            SQ9: u5 = 0,
            /// SQ10 [15:19]
            /// 10th conversion in regular sequence
            SQ10: u5 = 0,
            /// SQ11 [20:24]
            /// 11th conversion in regular sequence
            SQ11: u5 = 0,
            /// SQ12 [25:29]
            /// 12th conversion in regular sequence
            SQ12: u5 = 0,
            /// padding [30:31]
            _padding: u2 = 0,
        }, nullable_types.ADC1.RSQR2),

        /// regular sequence register 3
        RSQR3: RegisterRW(packed struct(u32) {
            /// SQ1 [0:4]
            /// 1st conversion in regular sequence
            SQ1: u5 = 0,
            /// SQ2 [5:9]
            /// 2nd conversion in regular sequence
            SQ2: u5 = 0,
            /// SQ3 [10:14]
            /// 3rd conversion in regular sequence
            SQ3: u5 = 0,
            /// SQ4 [15:19]
            /// 4th conversion in regular sequence
            SQ4: u5 = 0,
            /// SQ5 [20:24]
            /// 5th conversion in regular sequence
            SQ5: u5 = 0,
            /// SQ6 [25:29]
            /// 6th conversion in regular sequence
            SQ6: u5 = 0,
            /// padding [30:31]
            _padding: u2 = 0,
        }, nullable_types.ADC1.RSQR3),

        /// injected sequence register
        ISQR: RegisterRW(packed struct(u32) {
            /// JSQ1 [0:4]
            /// 1st conversion in injected sequence
            JSQ1: u5 = 0,
            /// JSQ2 [5:9]
            /// 2nd conversion in injected sequence
            JSQ2: u5 = 0,
            /// JSQ3 [10:14]
            /// 3rd conversion in injected sequence
            JSQ3: u5 = 0,
            /// JSQ4 [15:19]
            /// 4th conversion in injected sequence
            JSQ4: u5 = 0,
            /// JL [20:21]
            /// Injected sequence length
            JL: u2 = 0,
            /// padding [22:31]
            _padding: u10 = 0,
        }, nullable_types.ADC1.ISQR),

        /// injected data register 1
        IDATAR1: RegisterRW(packed struct(u32) {
            /// IDATA [0:15]
            /// Injected data
            IDATA: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.ADC1.IDATAR1),

        /// injected data register 2
        IDATAR2: RegisterRW(packed struct(u32) {
            /// IDATA [0:15]
            /// Injected data
            IDATA: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.ADC1.IDATAR2),

        /// injected data register 3
        IDATAR3: RegisterRW(packed struct(u32) {
            /// IDATA [0:15]
            /// Injected data
            IDATA: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.ADC1.IDATAR3),

        /// injected data register 4
        IDATAR4: RegisterRW(packed struct(u32) {
            /// IDATA [0:15]
            /// Injected data
            IDATA: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.ADC1.IDATAR4),

        /// regular data register
        RDATAR: RegisterRW(packed struct(u32) {
            /// DATA [0:31]
            /// Regular data
            DATA: u32 = 0,
        }, nullable_types.ADC1.RDATAR),

        /// delay data register
        DLYR: RegisterRW(packed struct(u32) {
            /// DLYVLU [0:8]
            /// External trigger data delay time configuration
            DLYVLU: u9 = 0,
            /// DLYSRC [9:9]
            /// External trigger source delay selection
            DLYSRC: u1 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }, nullable_types.ADC1.DLYR),
    };

    /// Debug support
    pub const DBG = extern struct {
        pub inline fn from(base: u32) *volatile types.DBG {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.DBG) u32 {
            return @intFromPtr(self);
        }

        /// DBGMCU_CFGR1
        CR: RegisterRW(packed struct(u32) {
            /// SLEEP [0:0]
            /// Debug Sleep mode
            SLEEP: u1 = 0,
            /// STOP [1:1]
            /// Debug stop mode
            STOP: u1 = 0,
            /// STANDBY [2:2]
            /// Debug standby mode
            STANDBY: u1 = 0,
            /// unused [3:7]
            _unused3: u5 = 0,
            /// IWDG_STOP [8:8]
            /// IWDG_STOP
            IWDG_STOP: u1 = 0,
            /// WWDG_STOP [9:9]
            /// WWDG_STOP
            WWDG_STOP: u1 = 0,
            /// unused [10:11]
            _unused10: u2 = 0,
            /// TIM1_STOP [12:12]
            /// TIM1_STOP
            TIM1_STOP: u1 = 0,
            /// TIM2_STOP [13:13]
            /// TIM2_STOP
            TIM2_STOP: u1 = 0,
            /// padding [14:31]
            _padding: u18 = 0,
        }, nullable_types.DBG.CR),
    };

    /// Device electronic signature
    pub const ESIG = extern struct {
        pub inline fn from(base: u32) *volatile types.ESIG {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.ESIG) u32 {
            return @intFromPtr(self);
        }

        /// Flash capacity register
        FLACAP: RegisterRW(packed struct(u16) {
            /// F_SIZE_15_0 [0:15]
            /// Flash size
            F_SIZE_15_0: u16 = 0,
        }, nullable_types.ESIG.FLACAP),

        /// offset 0x6
        _offset1: [6]u8,

        /// Unique identity 1
        UNIID1: RegisterRW(packed struct(u32) {
            /// U_ID [0:31]
            /// Unique identity[31:0]
            U_ID: u32 = 0,
        }, nullable_types.ESIG.UNIID1),

        /// Unique identity 2
        UNIID2: RegisterRW(packed struct(u32) {
            /// U_ID [0:31]
            /// Unique identity[63:32]
            U_ID: u32 = 0,
        }, nullable_types.ESIG.UNIID2),

        /// Unique identity 3
        UNIID3: RegisterRW(packed struct(u32) {
            /// U_ID [0:31]
            /// Unique identity[95:64]
            U_ID: u32 = 0,
        }, nullable_types.ESIG.UNIID3),
    };

    /// FLASH
    pub const FLASH = extern struct {
        pub inline fn from(base: u32) *volatile types.FLASH {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.FLASH) u32 {
            return @intFromPtr(self);
        }

        /// Flash key register
        ACTLR: RegisterRW(packed struct(u32) {
            /// LATENCY [0:1]
            /// Number of FLASH wait states
            LATENCY: u2 = 0,
            /// padding [2:31]
            _padding: u30 = 0,
        }, nullable_types.FLASH.ACTLR),

        /// Flash key register
        KEYR: RegisterRW(packed struct(u32) {
            /// KEYR [0:31]
            /// FPEC key
            KEYR: u32 = 0,
        }, nullable_types.FLASH.KEYR),

        /// Flash option key register
        OBKEYR: RegisterRW(packed struct(u32) {
            /// OPTKEY [0:31]
            /// Option byte key
            OPTKEY: u32 = 0,
        }, nullable_types.FLASH.OBKEYR),

        /// Status register
        STATR: RegisterRW(packed struct(u32) {
            /// BSY [0:0]
            /// Busy
            BSY: u1 = 0,
            /// unused [1:3]
            _unused1: u3 = 0,
            /// WRPRTERR [4:4]
            /// Write protection error
            WRPRTERR: u1 = 0,
            /// EOP [5:5]
            /// End of operation
            EOP: u1 = 0,
            /// unused [6:13]
            _unused6: u2 = 0,
            _unused8: u6 = 0,
            /// BOOT_MODE [14:14]
            /// BOOT mode
            BOOT_MODE: u1 = 0,
            /// BOOT_LOCK [15:15]
            /// BOOT lock
            BOOT_LOCK: u1 = 1,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.FLASH.STATR),

        /// Control register
        CTLR: RegisterRW(packed struct(u32) {
            /// PG [0:0]
            /// Programming
            PG: u1 = 0,
            /// PER [1:1]
            /// Page Erase
            PER: u1 = 0,
            /// MER [2:2]
            /// Mass Erase
            MER: u1 = 0,
            /// unused [3:3]
            _unused3: u1 = 0,
            /// OBPG [4:4]
            /// Option byte programming
            OBPG: u1 = 0,
            /// OBER [5:5]
            /// Option byte erase
            OBER: u1 = 0,
            /// STRT [6:6]
            /// Start
            STRT: u1 = 0,
            /// LOCK [7:7]
            /// Lock
            LOCK: u1 = 1,
            /// unused [8:8]
            _unused8: u1 = 0,
            /// OBWRE [9:9]
            /// Option bytes write enable
            OBWRE: u1 = 0,
            /// ERRIE [10:10]
            /// Error interrupt enable
            ERRIE: u1 = 0,
            /// unused [11:11]
            _unused11: u1 = 0,
            /// EOPIE [12:12]
            /// End of operation interrupt enable
            EOPIE: u1 = 0,
            /// unused [13:14]
            _unused13: u2 = 0,
            /// FLOCK [15:15]
            /// Fast programmable lock
            FLOCK: u1 = 1,
            /// FTPG [16:16]
            /// Fast programming
            FTPG: u1 = 0,
            /// FTER [17:17]
            /// Fast erase
            FTER: u1 = 0,
            /// BUFLOAD [18:18]
            /// Buffer load
            BUFLOAD: u1 = 0,
            /// BUFRST [19:19]
            /// Buffer reset
            BUFRST: u1 = 0,
            /// padding [20:31]
            _padding: u12 = 0,
        }, nullable_types.FLASH.CTLR),

        /// Flash address register
        ADDR: RegisterRW(packed struct(u32) {
            /// FAR [0:31]
            /// Flash Address
            FAR: u32 = 0,
        }, nullable_types.FLASH.ADDR),

        /// offset 0x4
        _offset6: [4]u8,

        /// Option byte register
        OBR: RegisterRW(packed struct(u32) {
            /// OBERR [0:0]
            /// Option byte error
            OBERR: u1 = 0,
            /// RDPRT [1:1]
            /// Read protection
            RDPRT: u1 = 0,
            /// IWDG_SW [2:2]
            /// IWDG_SW
            IWDG_SW: u1 = 0,
            /// unused [3:3]
            _unused3: u1 = 0,
            /// STANDY_RST [4:4]
            /// STANDY_RST
            STANDY_RST: u1 = 0,
            /// RST_MODE [5:6]
            /// CFG_RST_MODE
            RST_MODE: u2 = 0,
            /// STATR_MODE [7:7]
            /// STATR MODE
            STATR_MODE: u1 = 0,
            /// unused [8:9]
            _unused8: u2 = 0,
            /// DATA0 [10:17]
            /// DATA0
            DATA0: u8 = 0,
            /// DATA1 [18:25]
            /// DATA1
            DATA1: u8 = 0,
            /// padding [26:31]
            _padding: u6 = 0,
        }, nullable_types.FLASH.OBR),

        /// Write protection register
        WPR: RegisterRW(packed struct(u32) {
            /// WRP [0:15]
            /// Write protect
            WRP: u16 = 65535,
            /// padding [16:31]
            _padding: u16 = 65535,
        }, nullable_types.FLASH.WPR),

        /// Mode select register
        MODEKEYR: RegisterRW(packed struct(u32) {
            /// MODEKEYR [0:31]
            /// Mode select
            MODEKEYR: u32 = 0,
        }, nullable_types.FLASH.MODEKEYR),

        /// Boot mode key register
        BOOT_MODEKEYP: RegisterRW(packed struct(u32) {
            /// MODEKEYR [0:31]
            /// Boot mode key
            MODEKEYR: u32 = 0,
        }, nullable_types.FLASH.BOOT_MODEKEYP),
    };

    /// Programmable Fast Interrupt Controller
    pub const PFIC = extern struct {
        pub inline fn from(base: u32) *volatile types.PFIC {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.PFIC) u32 {
            return @intFromPtr(self);
        }

        /// Interrupt Status Register
        ISR1: RegisterRW(packed struct(u32) {
            /// unused [0:1]
            _unused0: u2 = 0,
            /// INTENSTA2_3 [2:3]
            /// Interrupt ID Status
            INTENSTA2_3: u2 = 3,
            /// unused [4:11]
            _unused4: u4 = 0,
            _unused8: u4 = 0,
            /// INTENSTA12 [12:12]
            /// Interrupt ID Status
            INTENSTA12: u1 = 0,
            /// unused [13:13]
            _unused13: u1 = 0,
            /// INTENSTA14 [14:14]
            /// Interrupt ID Status
            INTENSTA14: u1 = 0,
            /// unused [15:15]
            _unused15: u1 = 0,
            /// INTENSTA16_31 [16:31]
            /// Interrupt ID Status
            INTENSTA16_31: u16 = 0,
        }, nullable_types.PFIC.ISR1),

        /// Interrupt Status Register
        ISR2: RegisterRW(packed struct(u32) {
            /// INTENSTA [0:6]
            /// Interrupt ID Status
            INTENSTA: u7 = 0,
            /// padding [7:31]
            _padding: u25 = 0,
        }, nullable_types.PFIC.ISR2),

        /// offset 0x18
        _offset2: [24]u8,

        /// Interrupt Pending Register
        IPR1: RegisterRW(packed struct(u32) {
            /// unused [0:1]
            _unused0: u2 = 0,
            /// PENDSTA2_3 [2:3]
            /// PENDSTA
            PENDSTA2_3: u2 = 0,
            /// unused [4:11]
            _unused4: u4 = 0,
            _unused8: u4 = 0,
            /// PENDSTA12 [12:12]
            /// PENDSTA
            PENDSTA12: u1 = 0,
            /// unused [13:13]
            _unused13: u1 = 0,
            /// INTENSTA14 [14:14]
            /// PENDSTA
            INTENSTA14: u1 = 0,
            /// unused [15:15]
            _unused15: u1 = 0,
            /// INTENSTA16_31 [16:31]
            /// PENDSTA
            INTENSTA16_31: u16 = 0,
        }, nullable_types.PFIC.IPR1),

        /// Interrupt Pending Register
        IPR2: RegisterRW(packed struct(u32) {
            /// PENDSTA32_38 [0:6]
            /// PENDSTA
            PENDSTA32_38: u7 = 0,
            /// padding [7:31]
            _padding: u25 = 0,
        }, nullable_types.PFIC.IPR2),

        /// offset 0x18
        _offset4: [24]u8,

        /// Interrupt Priority Register
        ITHRESDR: RegisterRW(packed struct(u32) {
            /// THRESHOLD [0:7]
            /// THRESHOLD
            THRESHOLD: u8 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }, nullable_types.PFIC.ITHRESDR),

        /// offset 0x4
        _offset5: [4]u8,

        /// Interrupt Config Register
        CFGR: RegisterRW(packed struct(u32) {
            /// unused [0:6]
            _unused0: u7 = 0,
            /// RSTSYS [7:7]
            /// RESET System
            RSTSYS: u1 = 0,
            /// unused [8:15]
            _unused8: u8 = 0,
            /// KEYCODE [16:31]
            /// KEYCODE
            KEYCODE: u16 = 0,
        }, nullable_types.PFIC.CFGR),

        /// Interrupt Global Register
        GISR: RegisterRW(packed struct(u32) {
            /// NESTSTA [0:7]
            /// NESTSTA
            NESTSTA: u8 = 0,
            /// GACTSTA [8:8]
            /// GACTSTA
            GACTSTA: u1 = 0,
            /// GPENDSTA [9:9]
            /// GPENDSTA
            GPENDSTA: u1 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }, nullable_types.PFIC.GISR),

        /// ID Config Register
        VTFIDR: RegisterRW(packed struct(u32) {
            /// VTFID0 [0:7]
            /// VTFID0
            VTFID0: u8 = 0,
            /// VTFID1 [8:15]
            /// VTFID1
            VTFID1: u8 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.PFIC.VTFIDR),

        /// offset 0xc
        _offset8: [12]u8,

        /// Interrupt 0 address Register
        VTFADDRR0: RegisterRW(packed struct(u32) {
            /// VTF0EN [0:0]
            /// VTF0EN
            VTF0EN: u1 = 0,
            /// ADDR0 [1:31]
            /// ADDR0
            ADDR0: u31 = 0,
        }, nullable_types.PFIC.VTFADDRR0),

        /// Interrupt 1 address Register
        VTFADDRR1: RegisterRW(packed struct(u32) {
            /// VTF1EN [0:0]
            /// VTF1EN
            VTF1EN: u1 = 0,
            /// ADDR1 [1:31]
            /// ADDR1
            ADDR1: u31 = 0,
        }, nullable_types.PFIC.VTFADDRR1),

        /// offset 0x98
        _offset10: [152]u8,

        /// Interrupt Setting Register
        IENR1: RegisterRW(packed struct(u32) {
            /// unused [0:11]
            _unused0: u8 = 0,
            _unused8: u4 = 0,
            /// INTEN12 [12:12]
            /// INTEN12
            INTEN12: u1 = 0,
            /// unused [13:13]
            _unused13: u1 = 0,
            /// INTEN14 [14:14]
            /// INTEN14
            INTEN14: u1 = 0,
            /// unused [15:15]
            _unused15: u1 = 0,
            /// INTEN16_31 [16:31]
            /// INTEN16_31
            INTEN16_31: u16 = 0,
        }, nullable_types.PFIC.IENR1),

        /// Interrupt Setting Register
        IENR2: RegisterRW(packed struct(u32) {
            /// INTEN [0:6]
            /// INTEN32_38
            INTEN: u7 = 0,
            /// padding [7:31]
            _padding: u25 = 0,
        }, nullable_types.PFIC.IENR2),

        /// offset 0x78
        _offset12: [120]u8,

        /// Interrupt Clear Register
        IRER1: RegisterRW(packed struct(u32) {
            /// unused [0:11]
            _unused0: u8 = 0,
            _unused8: u4 = 0,
            /// INTRSET12 [12:12]
            /// INTRSET12
            INTRSET12: u1 = 0,
            /// unused [13:13]
            _unused13: u1 = 0,
            /// INTRSET14 [14:14]
            /// INTRSET14
            INTRSET14: u1 = 0,
            /// unused [15:15]
            _unused15: u1 = 0,
            /// INTRSET16_31 [16:31]
            /// INTRSET16_31
            INTRSET16_31: u16 = 0,
        }, nullable_types.PFIC.IRER1),

        /// Interrupt Clear Register
        IRER2: RegisterRW(packed struct(u32) {
            /// INTRSET38_32 [0:6]
            /// INTRSET38_32
            INTRSET38_32: u7 = 0,
            /// padding [7:31]
            _padding: u25 = 0,
        }, nullable_types.PFIC.IRER2),

        /// offset 0x78
        _offset14: [120]u8,

        /// Interrupt Pending Register
        IPSR1: RegisterRW(packed struct(u32) {
            /// unused [0:1]
            _unused0: u2 = 0,
            /// PENDSET2_3 [2:3]
            /// PENDSET
            PENDSET2_3: u2 = 0,
            /// unused [4:11]
            _unused4: u4 = 0,
            _unused8: u4 = 0,
            /// PENDSET12 [12:12]
            /// PENDSET
            PENDSET12: u1 = 0,
            /// unused [13:13]
            _unused13: u1 = 0,
            /// PENDSET14 [14:14]
            /// PENDSET
            PENDSET14: u1 = 0,
            /// unused [15:15]
            _unused15: u1 = 0,
            /// PENDSET16_31 [16:31]
            /// PENDSET
            PENDSET16_31: u16 = 0,
        }, nullable_types.PFIC.IPSR1),

        /// Interrupt Pending Register
        IPSR2: RegisterRW(packed struct(u32) {
            /// PENDSET32_38 [0:6]
            /// PENDSET32_38
            PENDSET32_38: u7 = 0,
            /// padding [7:31]
            _padding: u25 = 0,
        }, nullable_types.PFIC.IPSR2),

        /// offset 0x78
        _offset16: [120]u8,

        /// Interrupt Pending Clear Register
        IPRR1: RegisterRW(packed struct(u32) {
            /// unused [0:1]
            _unused0: u2 = 0,
            /// PENDRST2_3 [2:3]
            /// PENDRESET
            PENDRST2_3: u2 = 0,
            /// unused [4:11]
            _unused4: u4 = 0,
            _unused8: u4 = 0,
            /// PENDRST12 [12:12]
            /// PENDRESET
            PENDRST12: u1 = 0,
            /// unused [13:13]
            _unused13: u1 = 0,
            /// PENDRST14 [14:14]
            /// PENDRESET
            PENDRST14: u1 = 0,
            /// unused [15:15]
            _unused15: u1 = 0,
            /// PENDRST16_31 [16:31]
            /// PENDRESET
            PENDRST16_31: u16 = 0,
        }, nullable_types.PFIC.IPRR1),

        /// Interrupt Pending Clear Register
        IPRR2: RegisterRW(packed struct(u32) {
            /// PENDRST32_38 [0:6]
            /// PENDRESET32_38
            PENDRST32_38: u7 = 0,
            /// padding [7:31]
            _padding: u25 = 0,
        }, nullable_types.PFIC.IPRR2),

        /// offset 0x78
        _offset18: [120]u8,

        /// Interrupt ACTIVE Register
        IACTR1: RegisterRW(packed struct(u32) {
            /// unused [0:1]
            _unused0: u2 = 0,
            /// IACTS2_3 [2:3]
            /// IACTS
            IACTS2_3: u2 = 0,
            /// unused [4:11]
            _unused4: u4 = 0,
            _unused8: u4 = 0,
            /// IACTS12 [12:12]
            /// IACTS
            IACTS12: u1 = 0,
            /// unused [13:13]
            _unused13: u1 = 0,
            /// IACTS14 [14:14]
            /// IACTS
            IACTS14: u1 = 0,
            /// unused [15:15]
            _unused15: u1 = 0,
            /// IACTS16_31 [16:31]
            /// IACTS
            IACTS16_31: u16 = 0,
        }, nullable_types.PFIC.IACTR1),

        /// Interrupt ACTIVE Register
        IACTR2: RegisterRW(packed struct(u32) {
            /// IACTS [0:6]
            /// IACTS
            IACTS: u7 = 0,
            /// padding [7:31]
            _padding: u25 = 0,
        }, nullable_types.PFIC.IACTR2),

        /// offset 0xf8
        _offset20: [248]u8,

        /// Interrupt Priority Register
        IPRIOR0: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR0),

        /// Interrupt Priority Register
        IPRIOR1: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR1),

        /// Interrupt Priority Register
        IPRIOR2: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR2),

        /// Interrupt Priority Register
        IPRIOR3: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR3),

        /// Interrupt Priority Register
        IPRIOR4: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR4),

        /// Interrupt Priority Register
        IPRIOR5: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR5),

        /// Interrupt Priority Register
        IPRIOR6: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR6),

        /// Interrupt Priority Register
        IPRIOR7: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR7),

        /// Interrupt Priority Register
        IPRIOR8: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR8),

        /// Interrupt Priority Register
        IPRIOR9: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR9),

        /// Interrupt Priority Register
        IPRIOR10: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR10),

        /// Interrupt Priority Register
        IPRIOR11: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR11),

        /// Interrupt Priority Register
        IPRIOR12: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR12),

        /// Interrupt Priority Register
        IPRIOR13: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR13),

        /// Interrupt Priority Register
        IPRIOR14: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR14),

        /// Interrupt Priority Register
        IPRIOR15: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR15),

        /// Interrupt Priority Register
        IPRIOR16: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR16),

        /// Interrupt Priority Register
        IPRIOR17: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR17),

        /// Interrupt Priority Register
        IPRIOR18: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR18),

        /// Interrupt Priority Register
        IPRIOR19: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR19),

        /// Interrupt Priority Register
        IPRIOR20: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR20),

        /// Interrupt Priority Register
        IPRIOR21: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR21),

        /// Interrupt Priority Register
        IPRIOR22: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR22),

        /// Interrupt Priority Register
        IPRIOR23: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR23),

        /// Interrupt Priority Register
        IPRIOR24: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR24),

        /// Interrupt Priority Register
        IPRIOR25: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR25),

        /// Interrupt Priority Register
        IPRIOR26: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR26),

        /// Interrupt Priority Register
        IPRIOR27: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR27),

        /// Interrupt Priority Register
        IPRIOR28: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR28),

        /// Interrupt Priority Register
        IPRIOR29: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR29),

        /// Interrupt Priority Register
        IPRIOR30: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR30),

        /// Interrupt Priority Register
        IPRIOR31: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR31),

        /// Interrupt Priority Register
        IPRIOR32: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR32),

        /// Interrupt Priority Register
        IPRIOR33: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR33),

        /// Interrupt Priority Register
        IPRIOR34: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR34),

        /// Interrupt Priority Register
        IPRIOR35: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR35),

        /// Interrupt Priority Register
        IPRIOR36: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR36),

        /// Interrupt Priority Register
        IPRIOR37: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR37),

        /// Interrupt Priority Register
        IPRIOR38: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR38),

        /// Interrupt Priority Register
        IPRIOR39: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR39),

        /// Interrupt Priority Register
        IPRIOR40: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR40),

        /// Interrupt Priority Register
        IPRIOR41: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR41),

        /// Interrupt Priority Register
        IPRIOR42: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR42),

        /// Interrupt Priority Register
        IPRIOR43: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR43),

        /// Interrupt Priority Register
        IPRIOR44: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR44),

        /// Interrupt Priority Register
        IPRIOR45: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR45),

        /// Interrupt Priority Register
        IPRIOR46: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR46),

        /// Interrupt Priority Register
        IPRIOR47: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR47),

        /// Interrupt Priority Register
        IPRIOR48: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR48),

        /// Interrupt Priority Register
        IPRIOR49: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR49),

        /// Interrupt Priority Register
        IPRIOR50: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR50),

        /// Interrupt Priority Register
        IPRIOR51: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR51),

        /// Interrupt Priority Register
        IPRIOR52: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR52),

        /// Interrupt Priority Register
        IPRIOR53: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR53),

        /// Interrupt Priority Register
        IPRIOR54: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR54),

        /// Interrupt Priority Register
        IPRIOR55: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR55),

        /// Interrupt Priority Register
        IPRIOR56: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR56),

        /// Interrupt Priority Register
        IPRIOR57: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR57),

        /// Interrupt Priority Register
        IPRIOR58: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR58),

        /// Interrupt Priority Register
        IPRIOR59: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR59),

        /// Interrupt Priority Register
        IPRIOR60: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR60),

        /// Interrupt Priority Register
        IPRIOR61: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR61),

        /// Interrupt Priority Register
        IPRIOR62: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR62),

        /// Interrupt Priority Register
        IPRIOR63: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.PFIC.IPRIOR63),

        /// offset 0x8d0
        _offset84: [2256]u8,

        /// System Control Register
        SCTLR: RegisterRW(packed struct(u32) {
            /// unused [0:0]
            _unused0: u1 = 0,
            /// SLEEPONEXIT [1:1]
            /// SLEEPONEXIT
            SLEEPONEXIT: u1 = 0,
            /// SLEEPDEEP [2:2]
            /// SLEEPDEEP
            SLEEPDEEP: u1 = 0,
            /// WFITOWFE [3:3]
            /// WFITOWFE
            WFITOWFE: u1 = 0,
            /// SEVONPEND [4:4]
            /// SEVONPEND
            SEVONPEND: u1 = 0,
            /// SETEVENT [5:5]
            /// SETEVENT
            SETEVENT: u1 = 0,
            /// unused [6:30]
            _unused6: u2 = 0,
            _unused8: u8 = 0,
            _unused16: u8 = 0,
            _unused24: u7 = 0,
            /// SYSRST [31:31]
            /// SYSRESET
            SYSRST: u1 = 0,
        }, nullable_types.PFIC.SCTLR),

        /// offset 0x2ec
        _offset85: [748]u8,

        /// System counter control register
        STK_CTLR: RegisterRW(packed struct(u32) {
            /// STE [0:0]
            /// System counter enable
            STE: u1 = 0,
            /// STIE [1:1]
            /// System counter interrupt enable
            STIE: u1 = 0,
            /// STCLK [2:2]
            /// System selects the clock source
            STCLK: u1 = 0,
            /// STRE [3:3]
            /// System reload register
            STRE: u1 = 0,
            /// MODE [4:4]
            /// System Mode
            MODE: u1 = 0,
            /// INIT [5:5]
            /// System Initialization update
            INIT: u1 = 0,
            /// unused [6:30]
            _unused6: u2 = 0,
            _unused8: u8 = 0,
            _unused16: u8 = 0,
            _unused24: u7 = 0,
            /// SWIE [31:31]
            /// System software triggered interrupts enable
            SWIE: u1 = 0,
        }, nullable_types.PFIC.STK_CTLR),

        /// System START
        STK_SR: RegisterRW(packed struct(u32) {
            /// CNTIF [0:0]
            /// CNTIF
            CNTIF: u1 = 0,
            /// padding [1:31]
            _padding: u31 = 0,
        }, nullable_types.PFIC.STK_SR),

        /// System counter low register
        STK_CNTL: RegisterRW(packed struct(u32) {
            /// CNT [0:31]
            /// CNT
            CNT: u32 = 0,
        }, nullable_types.PFIC.STK_CNTL),

        /// offset 0x4
        _offset88: [4]u8,

        /// System compare low register
        STK_CMPLR: RegisterRW(packed struct(u32) {
            /// CMP [0:31]
            /// CMP
            CMP: u32 = 0,
        }, nullable_types.PFIC.STK_CMPLR),
    };
};

pub const nullable_types = struct {
    /// Power control
    pub const PWR = struct {
        /// Power control register (PWR_CTRL)
        pub const CTLR = struct {
            /// PDDS [1:1]
            /// Power Down Deep Sleep
            PDDS: ?u1 = null,
            /// PVDE [4:4]
            /// Power Voltage Detector Enable
            PVDE: ?u1 = null,
            /// PLS [5:7]
            /// PVD Level Selection
            PLS: ?u3 = null,
        };

        /// Power control state register (PWR_CSR)
        pub const CSR = struct {
            /// PVDO [2:2]
            /// PVD Output
            PVDO: ?u1 = null,
        };

        /// Automatic wake-up control state register (PWR_AWUCSR)
        pub const AWUCSR = struct {
            /// AWUEN [1:1]
            /// Automatic wake-up enable
            AWUEN: ?u1 = null,
        };

        /// Automatic wake window comparison value register (PWR_AWUWR)
        pub const AWUWR = struct {
            /// AWUWR [0:5]
            /// AWU window value
            AWUWR: ?u6 = null,
        };

        /// Automatic wake-up prescaler register (PWR_AWUPSC)
        pub const AWUPSC = struct {
            /// AWUPSC [0:3]
            /// Wake-up prescaler
            AWUPSC: ?u4 = null,
        };
    };

    /// Reset and clock control
    pub const RCC = struct {
        /// Clock control register
        pub const CTLR = struct {
            /// HSION [0:0]
            /// Internal High Speed clock enable
            HSION: ?u1 = null,
            /// HSIRDY [1:1]
            /// Internal High Speed clock ready flag
            HSIRDY: ?u1 = null,
            /// HSITRIM [3:7]
            /// Internal High Speed clock trimming
            HSITRIM: ?u5 = null,
            /// HSICAL [8:15]
            /// Internal High Speed clock Calibration
            HSICAL: ?u8 = null,
            /// HSEON [16:16]
            /// External High Speed clock enable
            HSEON: ?u1 = null,
            /// HSERDY [17:17]
            /// External High Speed clock ready flag
            HSERDY: ?u1 = null,
            /// HSEBYP [18:18]
            /// External High Speed clock Bypass
            HSEBYP: ?u1 = null,
            /// CSSON [19:19]
            /// Clock Security System enable
            CSSON: ?u1 = null,
            /// PLLON [24:24]
            /// PLL enable
            PLLON: ?u1 = null,
            /// PLLRDY [25:25]
            /// PLL clock ready flag
            PLLRDY: ?u1 = null,
        };

        /// Clock configuration register (RCC_CFGR0)
        pub const CFGR0 = struct {
            /// SW [0:1]
            /// System clock Switch
            SW: ?u2 = null,
            /// SWS [2:3]
            /// System Clock Switch Status
            SWS: ?u2 = null,
            /// HPRE [4:7]
            /// HB prescaler
            HPRE: ?u4 = null,
            /// ADCPRE [11:15]
            /// ADC prescaler
            ADCPRE: ?u5 = null,
            /// PLLSRC [16:16]
            /// PLL entry clock source
            PLLSRC: ?u1 = null,
            /// MCO [24:26]
            /// Microcontroller clock output
            MCO: ?u3 = null,
        };

        /// Clock interrupt register (RCC_INTR)
        pub const INTR = struct {
            /// LSIRDYF [0:0]
            /// LSI Ready Interrupt flag
            LSIRDYF: ?u1 = null,
            /// HSIRDYF [2:2]
            /// HSI Ready Interrupt flag
            HSIRDYF: ?u1 = null,
            /// HSERDYF [3:3]
            /// HSE Ready Interrupt flag
            HSERDYF: ?u1 = null,
            /// PLLRDYF [4:4]
            /// PLL Ready Interrupt flag
            PLLRDYF: ?u1 = null,
            /// CSSF [7:7]
            /// Clock Security System Interrupt flag
            CSSF: ?u1 = null,
            /// LSIRDYIE [8:8]
            /// LSI Ready Interrupt Enable
            LSIRDYIE: ?u1 = null,
            /// HSIRDYIE [10:10]
            /// HSI Ready Interrupt Enable
            HSIRDYIE: ?u1 = null,
            /// HSERDYIE [11:11]
            /// HSE Ready Interrupt Enable
            HSERDYIE: ?u1 = null,
            /// PLLRDYIE [12:12]
            /// PLL Ready Interrupt Enable
            PLLRDYIE: ?u1 = null,
            /// LSIRDYC [16:16]
            /// LSI Ready Interrupt Clear
            LSIRDYC: ?u1 = null,
            /// HSIRDYC [18:18]
            /// HSI Ready Interrupt Clear
            HSIRDYC: ?u1 = null,
            /// HSERDYC [19:19]
            /// HSE Ready Interrupt Clear
            HSERDYC: ?u1 = null,
            /// PLLRDYC [20:20]
            /// PLL Ready Interrupt Clear
            PLLRDYC: ?u1 = null,
            /// CSSC [23:23]
            /// Clock security system interrupt clear
            CSSC: ?u1 = null,
        };

        /// PB2 peripheral reset register (RCC_APB2PRSTR)
        pub const APB2PRSTR = struct {
            /// AFIORST [0:0]
            /// Alternate function I/O reset
            AFIORST: ?u1 = null,
            /// IOPARST [2:2]
            /// IO port A reset
            IOPARST: ?u1 = null,
            /// IOPCRST [4:4]
            /// IO port C reset
            IOPCRST: ?u1 = null,
            /// IOPDRST [5:5]
            /// IO port D reset
            IOPDRST: ?u1 = null,
            /// ADC1RST [9:9]
            /// ADC 1 interface reset
            ADC1RST: ?u1 = null,
            /// TIM1RST [11:11]
            /// TIM1 timer reset
            TIM1RST: ?u1 = null,
            /// SPI1RST [12:12]
            /// SPI 1 reset
            SPI1RST: ?u1 = null,
            /// USART1RST [14:14]
            /// USART1 reset
            USART1RST: ?u1 = null,
        };

        /// PB1 peripheral reset register (RCC_APB1PRSTR)
        pub const APB1PRSTR = struct {
            /// TIM2RST [0:0]
            /// TIM2 reset
            TIM2RST: ?u1 = null,
            /// WWDGRST [11:11]
            /// Window watchdog reset
            WWDGRST: ?u1 = null,
            /// I2C1RST [21:21]
            /// I2C1 reset
            I2C1RST: ?u1 = null,
            /// PWRRST [28:28]
            /// Power interface reset
            PWRRST: ?u1 = null,
        };

        /// HB Peripheral Clock enable register (RCC_AHBPCENR)
        pub const AHBPCENR = struct {
            /// DMA1EN [0:0]
            /// DMA clock enable
            DMA1EN: ?u1 = null,
            /// SRAMEN [2:2]
            /// SRAM interface clock enable
            SRAMEN: ?u1 = null,
        };

        /// PB2 peripheral clock enable register (RCC_APB2PCENR)
        pub const APB2PCENR = struct {
            /// AFIOEN [0:0]
            /// Alternate function I/O clock enable
            AFIOEN: ?u1 = null,
            /// IOPAEN [2:2]
            /// I/O port A clock enable
            IOPAEN: ?u1 = null,
            /// IOPCEN [4:4]
            /// I/O port C clock enable
            IOPCEN: ?u1 = null,
            /// IOPDEN [5:5]
            /// I/O port D clock enable
            IOPDEN: ?u1 = null,
            /// ADC1EN [9:9]
            /// ADC1 interface clock enable
            ADC1EN: ?u1 = null,
            /// TIM1EN [11:11]
            /// TIM1 Timer clock enable
            TIM1EN: ?u1 = null,
            /// SPI1EN [12:12]
            /// SPI 1 clock enable
            SPI1EN: ?u1 = null,
            /// USART1EN [14:14]
            /// USART1 clock enable
            USART1EN: ?u1 = null,
        };

        /// PB1 peripheral clock enable register (RCC_APB1PCENR)
        pub const APB1PCENR = struct {
            /// TIM2EN [0:0]
            /// Timer 2 clock enable
            TIM2EN: ?u1 = null,
            /// WWDGEN [11:11]
            /// Window watchdog clock enable
            WWDGEN: ?u1 = null,
            /// I2C1EN [21:21]
            /// I2C 1 clock enable
            I2C1EN: ?u1 = null,
            /// PWREN [28:28]
            /// Power interface clock enable
            PWREN: ?u1 = null,
        };

        /// Control/status register (RCC_RSTSCKR)
        pub const RSTSCKR = struct {
            /// LSION [0:0]
            /// Internal low speed oscillator enable
            LSION: ?u1 = null,
            /// LSIRDY [1:1]
            /// Internal low speed oscillator ready
            LSIRDY: ?u1 = null,
            /// RMVF [24:24]
            /// Remove reset flag
            RMVF: ?u1 = null,
            /// PINRSTF [26:26]
            /// PIN reset flag
            PINRSTF: ?u1 = null,
            /// PORRSTF [27:27]
            /// POR/PDR reset flag
            PORRSTF: ?u1 = null,
            /// SFTRSTF [28:28]
            /// Software reset flag
            SFTRSTF: ?u1 = null,
            /// IWDGRSTF [29:29]
            /// Independent watchdog reset flag
            IWDGRSTF: ?u1 = null,
            /// WWDGRSTF [30:30]
            /// Window watchdog reset flag
            WWDGRSTF: ?u1 = null,
            /// LPWRRSTF [31:31]
            /// Low-power reset flag
            LPWRRSTF: ?u1 = null,
        };
    };

    /// Extend configuration
    pub const EXTEN = struct {
        /// Configure the extended control register
        pub const EXTEN_CTR = struct {
            /// LKUPEN [6:6]
            /// LOCKUP_Enable
            LKUPEN: ?u1 = null,
            /// LKUPRST [7:7]
            /// LOCKUP RESET
            LKUPRST: ?u1 = null,
            /// LDO_TRIM [10:10]
            /// LDO_TRIM
            LDO_TRIM: ?u1 = null,
            /// OPAEN [16:16]
            /// OPA Enalbe
            OPAEN: ?u1 = null,
            /// OPANSEL [17:17]
            /// OPA negative end channel selection
            OPANSEL: ?u1 = null,
            /// OPAPSEL [18:18]
            /// OPA positive end channel selection
            OPAPSEL: ?u1 = null,
        };
    };

    /// General purpose I/O
    /// Type for: GPIOA GPIOC GPIOD
    pub const GPIO = struct {
        /// Port configuration register low (GPIOn_CFGLR)
        pub const CFGLR = struct {
            /// MODE0 [0:1]
            /// Port n.0 mode bits
            MODE0: ?u2 = null,
            /// CNF0 [2:3]
            /// Port n.0 configuration bits
            CNF0: ?u2 = null,
            /// MODE1 [4:5]
            /// Port n.1 mode bits
            MODE1: ?u2 = null,
            /// CNF1 [6:7]
            /// Port n.1 configuration bits
            CNF1: ?u2 = null,
            /// MODE2 [8:9]
            /// Port n.2 mode bits
            MODE2: ?u2 = null,
            /// CNF2 [10:11]
            /// Port n.2 configuration bits
            CNF2: ?u2 = null,
            /// MODE3 [12:13]
            /// Port n.3 mode bits
            MODE3: ?u2 = null,
            /// CNF3 [14:15]
            /// Port n.3 configuration bits
            CNF3: ?u2 = null,
            /// MODE4 [16:17]
            /// Port n.4 mode bits
            MODE4: ?u2 = null,
            /// CNF4 [18:19]
            /// Port n.4 configuration bits
            CNF4: ?u2 = null,
            /// MODE5 [20:21]
            /// Port n.5 mode bits
            MODE5: ?u2 = null,
            /// CNF5 [22:23]
            /// Port n.5 configuration bits
            CNF5: ?u2 = null,
            /// MODE6 [24:25]
            /// Port n.6 mode bits
            MODE6: ?u2 = null,
            /// CNF6 [26:27]
            /// Port n.6 configuration bits
            CNF6: ?u2 = null,
            /// MODE7 [28:29]
            /// Port n.7 mode bits
            MODE7: ?u2 = null,
            /// CNF7 [30:31]
            /// Port n.7 configuration bits
            CNF7: ?u2 = null,
        };

        /// Port input data register (GPIOn_INDR)
        pub const INDR = struct {
            /// IDR0 [0:0]
            /// Port input data
            IDR0: ?u1 = null,
            /// IDR1 [1:1]
            /// Port input data
            IDR1: ?u1 = null,
            /// IDR2 [2:2]
            /// Port input data
            IDR2: ?u1 = null,
            /// IDR3 [3:3]
            /// Port input data
            IDR3: ?u1 = null,
            /// IDR4 [4:4]
            /// Port input data
            IDR4: ?u1 = null,
            /// IDR5 [5:5]
            /// Port input data
            IDR5: ?u1 = null,
            /// IDR6 [6:6]
            /// Port input data
            IDR6: ?u1 = null,
            /// IDR7 [7:7]
            /// Port input data
            IDR7: ?u1 = null,
        };

        /// Port output data register (GPIOn_OUTDR)
        pub const OUTDR = struct {
            /// ODR0 [0:0]
            /// Port output data
            ODR0: ?u1 = null,
            /// ODR1 [1:1]
            /// Port output data
            ODR1: ?u1 = null,
            /// ODR2 [2:2]
            /// Port output data
            ODR2: ?u1 = null,
            /// ODR3 [3:3]
            /// Port output data
            ODR3: ?u1 = null,
            /// ODR4 [4:4]
            /// Port output data
            ODR4: ?u1 = null,
            /// ODR5 [5:5]
            /// Port output data
            ODR5: ?u1 = null,
            /// ODR6 [6:6]
            /// Port output data
            ODR6: ?u1 = null,
            /// ODR7 [7:7]
            /// Port output data
            ODR7: ?u1 = null,
        };

        /// Port bit set/reset register (GPIOn_BSHR)
        pub const BSHR = struct {
            /// BS0 [0:0]
            /// Set bit 0
            BS0: ?u1 = null,
            /// BS1 [1:1]
            /// Set bit 1
            BS1: ?u1 = null,
            /// BS2 [2:2]
            /// Set bit 1
            BS2: ?u1 = null,
            /// BS3 [3:3]
            /// Set bit 3
            BS3: ?u1 = null,
            /// BS4 [4:4]
            /// Set bit 4
            BS4: ?u1 = null,
            /// BS5 [5:5]
            /// Set bit 5
            BS5: ?u1 = null,
            /// BS6 [6:6]
            /// Set bit 6
            BS6: ?u1 = null,
            /// BS7 [7:7]
            /// Set bit 7
            BS7: ?u1 = null,
            /// BR0 [16:16]
            /// Reset bit 0
            BR0: ?u1 = null,
            /// BR1 [17:17]
            /// Reset bit 1
            BR1: ?u1 = null,
            /// BR2 [18:18]
            /// Reset bit 2
            BR2: ?u1 = null,
            /// BR3 [19:19]
            /// Reset bit 3
            BR3: ?u1 = null,
            /// BR4 [20:20]
            /// Reset bit 4
            BR4: ?u1 = null,
            /// BR5 [21:21]
            /// Reset bit 5
            BR5: ?u1 = null,
            /// BR6 [22:22]
            /// Reset bit 6
            BR6: ?u1 = null,
            /// BR7 [23:23]
            /// Reset bit 7
            BR7: ?u1 = null,
        };

        /// Port bit reset register (GPIOn_BCR)
        pub const BCR = struct {
            /// BR0 [0:0]
            /// Reset bit 0
            BR0: ?u1 = null,
            /// BR1 [1:1]
            /// Reset bit 1
            BR1: ?u1 = null,
            /// BR2 [2:2]
            /// Reset bit 1
            BR2: ?u1 = null,
            /// BR3 [3:3]
            /// Reset bit 3
            BR3: ?u1 = null,
            /// BR4 [4:4]
            /// Reset bit 4
            BR4: ?u1 = null,
            /// BR5 [5:5]
            /// Reset bit 5
            BR5: ?u1 = null,
            /// BR6 [6:6]
            /// Reset bit 6
            BR6: ?u1 = null,
            /// BR7 [7:7]
            /// Reset bit 7
            BR7: ?u1 = null,
        };

        /// Port configuration lock register
        pub const LCKR = struct {
            /// LCK0 [0:0]
            /// Port A Lock bit 0
            LCK0: ?u1 = null,
            /// LCK1 [1:1]
            /// Port A Lock bit 1
            LCK1: ?u1 = null,
            /// LCK2 [2:2]
            /// Port A Lock bit 2
            LCK2: ?u1 = null,
            /// LCK3 [3:3]
            /// Port A Lock bit 3
            LCK3: ?u1 = null,
            /// LCK4 [4:4]
            /// Port A Lock bit 4
            LCK4: ?u1 = null,
            /// LCK5 [5:5]
            /// Port A Lock bit 5
            LCK5: ?u1 = null,
            /// LCK6 [6:6]
            /// Port A Lock bit 6
            LCK6: ?u1 = null,
            /// LCK7 [7:7]
            /// Port A Lock bit 7
            LCK7: ?u1 = null,
            /// LCKK [8:8]
            /// Lock key
            LCKK: ?u1 = null,
        };
    };

    /// Alternate function I/O
    pub const AFIO = struct {
        /// AF remap and debug I/O configuration register (AFIO_PCFR1)
        pub const PCFR1 = struct {
            /// SPI1_RM [0:0]
            /// SPI1 remapping
            SPI1_RM: ?u1 = null,
            /// I2C1_RM [1:1]
            /// I2C1 remapping
            I2C1_RM: ?u1 = null,
            /// USART1_RM [2:2]
            /// USART1 remapping
            USART1_RM: ?u1 = null,
            /// TIM1_RM [6:7]
            /// TIM1 remapping
            TIM1_RM: ?u2 = null,
            /// TIM2_RM [8:9]
            /// TIM2 remapping
            TIM2_RM: ?u2 = null,
            /// PA12_RM [15:15]
            /// Port A1/Port A2 mapping on OSCIN/OSCOUT
            PA12_RM: ?u1 = null,
            /// ADC1_ETRGINJ_RM [17:17]
            /// ADC 1 External trigger injected conversion remapping
            ADC1_ETRGINJ_RM: ?u1 = null,
            /// ADC1_ETRGREG_RM [18:18]
            /// ADC 1 external trigger regular conversion remapping
            ADC1_ETRGREG_RM: ?u1 = null,
            /// USART1REMAP1 [21:21]
            /// USART1 remapping
            USART1REMAP1: ?u1 = null,
            /// I2C1REMAP1 [22:22]
            /// I2C1 remapping
            I2C1REMAP1: ?u1 = null,
            /// TIM1_1_RM [23:23]
            /// TIM1_CH1 channel selection
            TIM1_1_RM: ?u1 = null,
            /// SWCFG [24:26]
            /// Serial wire JTAG configuration
            SWCFG: ?u3 = null,
        };

        /// External interrupt configuration register (AFIO_EXTICR)
        pub const EXTICR = struct {
            /// EXTI0 [0:1]
            /// EXTI0 configuration
            EXTI0: ?u2 = null,
            /// EXTI1 [2:3]
            /// EXTI1 configuration
            EXTI1: ?u2 = null,
            /// EXTI2 [4:5]
            /// EXTI2 configuration
            EXTI2: ?u2 = null,
            /// EXTI3 [6:7]
            /// EXTI3 configuration
            EXTI3: ?u2 = null,
            /// EXTI4 [8:9]
            /// EXTI4 configuration
            EXTI4: ?u2 = null,
            /// EXTI5 [10:11]
            /// EXTI5 configuration
            EXTI5: ?u2 = null,
            /// EXTI6 [12:13]
            /// EXTI6 configuration
            EXTI6: ?u2 = null,
            /// EXTI7 [14:15]
            /// EXTI7 configuration
            EXTI7: ?u2 = null,
        };
    };

    /// EXTI
    pub const EXTI = struct {
        /// Interrupt mask register (EXTI_INTENR)
        pub const INTENR = struct {
            /// MR0 [0:0]
            /// Interrupt Mask on line 0
            MR0: ?u1 = null,
            /// MR1 [1:1]
            /// Interrupt Mask on line 1
            MR1: ?u1 = null,
            /// MR2 [2:2]
            /// Interrupt Mask on line 2
            MR2: ?u1 = null,
            /// MR3 [3:3]
            /// Interrupt Mask on line 3
            MR3: ?u1 = null,
            /// MR4 [4:4]
            /// Interrupt Mask on line 4
            MR4: ?u1 = null,
            /// MR5 [5:5]
            /// Interrupt Mask on line 5
            MR5: ?u1 = null,
            /// MR6 [6:6]
            /// Interrupt Mask on line 6
            MR6: ?u1 = null,
            /// MR7 [7:7]
            /// Interrupt Mask on line 7
            MR7: ?u1 = null,
            /// MR8 [8:8]
            /// Interrupt Mask on line 8
            MR8: ?u1 = null,
            /// MR9 [9:9]
            /// Interrupt Mask on line 9
            MR9: ?u1 = null,
        };

        /// Event mask register (EXTI_EVENR)
        pub const EVENR = struct {
            /// MR0 [0:0]
            /// Event Mask on line 0
            MR0: ?u1 = null,
            /// MR1 [1:1]
            /// Event Mask on line 1
            MR1: ?u1 = null,
            /// MR2 [2:2]
            /// Event Mask on line 2
            MR2: ?u1 = null,
            /// MR3 [3:3]
            /// Event Mask on line 3
            MR3: ?u1 = null,
            /// MR4 [4:4]
            /// Event Mask on line 4
            MR4: ?u1 = null,
            /// MR5 [5:5]
            /// Event Mask on line 5
            MR5: ?u1 = null,
            /// MR6 [6:6]
            /// Event Mask on line 6
            MR6: ?u1 = null,
            /// MR7 [7:7]
            /// Event Mask on line 7
            MR7: ?u1 = null,
            /// MR8 [8:8]
            /// Event Mask on line 8
            MR8: ?u1 = null,
            /// MR9 [9:9]
            /// Event Mask on line 9
            MR9: ?u1 = null,
        };

        /// Rising Trigger selection register (EXTI_RTENR)
        pub const RTENR = struct {
            /// TR0 [0:0]
            /// Rising trigger event configuration of line 0
            TR0: ?u1 = null,
            /// TR1 [1:1]
            /// Rising trigger event configuration of line 1
            TR1: ?u1 = null,
            /// TR2 [2:2]
            /// Rising trigger event configuration of line 2
            TR2: ?u1 = null,
            /// TR3 [3:3]
            /// Rising trigger event configuration of line 3
            TR3: ?u1 = null,
            /// TR4 [4:4]
            /// Rising trigger event configuration of line 4
            TR4: ?u1 = null,
            /// TR5 [5:5]
            /// Rising trigger event configuration of line 5
            TR5: ?u1 = null,
            /// TR6 [6:6]
            /// Rising trigger event configuration of line 6
            TR6: ?u1 = null,
            /// TR7 [7:7]
            /// Rising trigger event configuration of line 7
            TR7: ?u1 = null,
            /// TR8 [8:8]
            /// Rising trigger event configuration of line 8
            TR8: ?u1 = null,
            /// TR9 [9:9]
            /// Rising trigger event configuration of line 9
            TR9: ?u1 = null,
        };

        /// Falling Trigger selection register (EXTI_FTENR)
        pub const FTENR = struct {
            /// TR0 [0:0]
            /// Falling trigger event configuration of line 0
            TR0: ?u1 = null,
            /// TR1 [1:1]
            /// Falling trigger event configuration of line 1
            TR1: ?u1 = null,
            /// TR2 [2:2]
            /// Falling trigger event configuration of line 2
            TR2: ?u1 = null,
            /// TR3 [3:3]
            /// Falling trigger event configuration of line 3
            TR3: ?u1 = null,
            /// TR4 [4:4]
            /// Falling trigger event configuration of line 4
            TR4: ?u1 = null,
            /// TR5 [5:5]
            /// Falling trigger event configuration of line 5
            TR5: ?u1 = null,
            /// TR6 [6:6]
            /// Falling trigger event configuration of line 6
            TR6: ?u1 = null,
            /// TR7 [7:7]
            /// Falling trigger event configuration of line 7
            TR7: ?u1 = null,
            /// TR8 [8:8]
            /// Falling trigger event configuration of line 8
            TR8: ?u1 = null,
            /// TR9 [9:9]
            /// Falling trigger event configuration of line 9
            TR9: ?u1 = null,
        };

        /// Software interrupt event register (EXTI_SWIEVR)
        pub const SWIEVR = struct {
            /// SWIER0 [0:0]
            /// Software Interrupt on line 0
            SWIER0: ?u1 = null,
            /// SWIER1 [1:1]
            /// Software Interrupt on line 1
            SWIER1: ?u1 = null,
            /// SWIER2 [2:2]
            /// Software Interrupt on line 2
            SWIER2: ?u1 = null,
            /// SWIER3 [3:3]
            /// Software Interrupt on line 3
            SWIER3: ?u1 = null,
            /// SWIER4 [4:4]
            /// Software Interrupt on line 4
            SWIER4: ?u1 = null,
            /// SWIER5 [5:5]
            /// Software Interrupt on line 5
            SWIER5: ?u1 = null,
            /// SWIER6 [6:6]
            /// Software Interrupt on line 6
            SWIER6: ?u1 = null,
            /// SWIER7 [7:7]
            /// Software Interrupt on line 7
            SWIER7: ?u1 = null,
            /// SWIER8 [8:8]
            /// Software Interrupt on line 8
            SWIER8: ?u1 = null,
            /// SWIER9 [9:9]
            /// Software Interrupt on line 9
            SWIER9: ?u1 = null,
        };

        /// Pending register (EXTI_INTFR)
        pub const INTFR = struct {
            /// IF0 [0:0]
            /// Pending bit 0
            IF0: ?u1 = null,
            /// IF1 [1:1]
            /// Pending bit 1
            IF1: ?u1 = null,
            /// IF2 [2:2]
            /// Pending bit 2
            IF2: ?u1 = null,
            /// IF3 [3:3]
            /// Pending bit 3
            IF3: ?u1 = null,
            /// IF4 [4:4]
            /// Pending bit 4
            IF4: ?u1 = null,
            /// IF5 [5:5]
            /// Pending bit 5
            IF5: ?u1 = null,
            /// IF6 [6:6]
            /// Pending bit 6
            IF6: ?u1 = null,
            /// IF7 [7:7]
            /// Pending bit 7
            IF7: ?u1 = null,
            /// IF8 [8:8]
            /// Pending bit 8
            IF8: ?u1 = null,
            /// IF9 [9:9]
            /// Pending bit 9
            IF9: ?u1 = null,
        };
    };

    /// DMA1 controller
    pub const DMA1 = struct {
        /// DMA interrupt status register (DMA_INTFR)
        pub const INTFR = struct {
            /// GIF1 [0:0]
            /// Channel 1 Global interrupt flag
            GIF1: ?u1 = null,
            /// TCIF1 [1:1]
            /// Channel 1 Transfer Complete flag
            TCIF1: ?u1 = null,
            /// HTIF1 [2:2]
            /// Channel 1 Half Transfer Complete flag
            HTIF1: ?u1 = null,
            /// TEIF1 [3:3]
            /// Channel 1 Transfer Error flag
            TEIF1: ?u1 = null,
            /// GIF2 [4:4]
            /// Channel 2 Global interrupt flag
            GIF2: ?u1 = null,
            /// TCIF2 [5:5]
            /// Channel 2 Transfer Complete flag
            TCIF2: ?u1 = null,
            /// HTIF2 [6:6]
            /// Channel 2 Half Transfer Complete flag
            HTIF2: ?u1 = null,
            /// TEIF2 [7:7]
            /// Channel 2 Transfer Error flag
            TEIF2: ?u1 = null,
            /// GIF3 [8:8]
            /// Channel 3 Global interrupt flag
            GIF3: ?u1 = null,
            /// TCIF3 [9:9]
            /// Channel 3 Transfer Complete flag
            TCIF3: ?u1 = null,
            /// HTIF3 [10:10]
            /// Channel 3 Half Transfer Complete flag
            HTIF3: ?u1 = null,
            /// TEIF3 [11:11]
            /// Channel 3 Transfer Error flag
            TEIF3: ?u1 = null,
            /// GIF4 [12:12]
            /// Channel 4 Global interrupt flag
            GIF4: ?u1 = null,
            /// TCIF4 [13:13]
            /// Channel 4 Transfer Complete flag
            TCIF4: ?u1 = null,
            /// HTIF4 [14:14]
            /// Channel 4 Half Transfer Complete flag
            HTIF4: ?u1 = null,
            /// TEIF4 [15:15]
            /// Channel 4 Transfer Error flag
            TEIF4: ?u1 = null,
            /// GIF5 [16:16]
            /// Channel 5 Global interrupt flag
            GIF5: ?u1 = null,
            /// TCIF5 [17:17]
            /// Channel 5 Transfer Complete flag
            TCIF5: ?u1 = null,
            /// HTIF5 [18:18]
            /// Channel 5 Half Transfer Complete flag
            HTIF5: ?u1 = null,
            /// TEIF5 [19:19]
            /// Channel 5 Transfer Error flag
            TEIF5: ?u1 = null,
            /// GIF6 [20:20]
            /// Channel 6 Global interrupt flag
            GIF6: ?u1 = null,
            /// TCIF6 [21:21]
            /// Channel 6 Transfer Complete flag
            TCIF6: ?u1 = null,
            /// HTIF6 [22:22]
            /// Channel 6 Half Transfer Complete flag
            HTIF6: ?u1 = null,
            /// TEIF6 [23:23]
            /// Channel 6 Transfer Error flag
            TEIF6: ?u1 = null,
            /// GIF7 [24:24]
            /// Channel 7 Global interrupt flag
            GIF7: ?u1 = null,
            /// TCIF7 [25:25]
            /// Channel 7 Transfer Complete flag
            TCIF7: ?u1 = null,
            /// HTIF7 [26:26]
            /// Channel 7 Half Transfer Complete flag
            HTIF7: ?u1 = null,
            /// TEIF7 [27:27]
            /// Channel 7 Transfer Error flag
            TEIF7: ?u1 = null,
        };

        /// DMA interrupt flag clear register (DMA_INTFCR)
        pub const INTFCR = struct {
            /// CGIF1 [0:0]
            /// Channel 1 Global interrupt clear
            CGIF1: ?u1 = null,
            /// CTCIF1 [1:1]
            /// Channel 1 Transfer Complete clear
            CTCIF1: ?u1 = null,
            /// CHTIF1 [2:2]
            /// Channel 1 Half Transfer clear
            CHTIF1: ?u1 = null,
            /// CTEIF1 [3:3]
            /// Channel 1 Transfer Error clear
            CTEIF1: ?u1 = null,
            /// CGIF2 [4:4]
            /// Channel 2 Global interrupt clear
            CGIF2: ?u1 = null,
            /// CTCIF2 [5:5]
            /// Channel 2 Transfer Complete clear
            CTCIF2: ?u1 = null,
            /// CHTIF2 [6:6]
            /// Channel 2 Half Transfer clear
            CHTIF2: ?u1 = null,
            /// CTEIF2 [7:7]
            /// Channel 2 Transfer Error clear
            CTEIF2: ?u1 = null,
            /// CGIF3 [8:8]
            /// Channel 3 Global interrupt clear
            CGIF3: ?u1 = null,
            /// CTCIF3 [9:9]
            /// Channel 3 Transfer Complete clear
            CTCIF3: ?u1 = null,
            /// CHTIF3 [10:10]
            /// Channel 3 Half Transfer clear
            CHTIF3: ?u1 = null,
            /// CTEIF3 [11:11]
            /// Channel 3 Transfer Error clear
            CTEIF3: ?u1 = null,
            /// CGIF4 [12:12]
            /// Channel 4 Global interrupt clear
            CGIF4: ?u1 = null,
            /// CTCIF4 [13:13]
            /// Channel 4 Transfer Complete clear
            CTCIF4: ?u1 = null,
            /// CHTIF4 [14:14]
            /// Channel 4 Half Transfer clear
            CHTIF4: ?u1 = null,
            /// CTEIF4 [15:15]
            /// Channel 4 Transfer Error clear
            CTEIF4: ?u1 = null,
            /// CGIF5 [16:16]
            /// Channel 5 Global interrupt clear
            CGIF5: ?u1 = null,
            /// CTCIF5 [17:17]
            /// Channel 5 Transfer Complete clear
            CTCIF5: ?u1 = null,
            /// CHTIF5 [18:18]
            /// Channel 5 Half Transfer clear
            CHTIF5: ?u1 = null,
            /// CTEIF5 [19:19]
            /// Channel 5 Transfer Error clear
            CTEIF5: ?u1 = null,
            /// CGIF6 [20:20]
            /// Channel 6 Global interrupt clear
            CGIF6: ?u1 = null,
            /// CTCIF6 [21:21]
            /// Channel 6 Transfer Complete clear
            CTCIF6: ?u1 = null,
            /// CHTIF6 [22:22]
            /// Channel 6 Half Transfer clear
            CHTIF6: ?u1 = null,
            /// CTEIF6 [23:23]
            /// Channel 6 Transfer Error clear
            CTEIF6: ?u1 = null,
            /// CGIF7 [24:24]
            /// Channel 7 Global interrupt clear
            CGIF7: ?u1 = null,
            /// CTCIF7 [25:25]
            /// Channel 7 Transfer Complete clear
            CTCIF7: ?u1 = null,
            /// CHTIF7 [26:26]
            /// Channel 7 Half Transfer clear
            CHTIF7: ?u1 = null,
            /// CTEIF7 [27:27]
            /// Channel 7 Transfer Error clear
            CTEIF7: ?u1 = null,
        };

        /// DMA channel configuration register (DMA_CFGR)
        pub const CFGR1 = struct {
            /// EN [0:0]
            /// Channel enable
            EN: ?u1 = null,
            /// TCIE [1:1]
            /// Transfer complete interrupt enable
            TCIE: ?u1 = null,
            /// HTIE [2:2]
            /// Half Transfer interrupt enable
            HTIE: ?u1 = null,
            /// TEIE [3:3]
            /// Transfer error interrupt enable
            TEIE: ?u1 = null,
            /// DIR [4:4]
            /// Data transfer direction
            DIR: ?u1 = null,
            /// CIRC [5:5]
            /// Circular mode
            CIRC: ?u1 = null,
            /// PINC [6:6]
            /// Peripheral increment mode
            PINC: ?u1 = null,
            /// MINC [7:7]
            /// Memory increment mode
            MINC: ?u1 = null,
            /// PSIZE [8:9]
            /// Peripheral size
            PSIZE: ?u2 = null,
            /// MSIZE [10:11]
            /// Memory size
            MSIZE: ?u2 = null,
            /// PL [12:13]
            /// Channel Priority level
            PL: ?u2 = null,
            /// MEM2MEM [14:14]
            /// Memory to memory mode
            MEM2MEM: ?u1 = null,
        };

        /// DMA channel 1 number of data register
        pub const CNTR1 = struct {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: ?u16 = null,
        };

        /// DMA channel 1 peripheral address register
        pub const PADDR1 = struct {
            /// PA [0:31]
            /// Peripheral address
            PA: ?u32 = null,
        };

        /// DMA channel 1 memory address register
        pub const MADDR1 = struct {
            /// MA [0:31]
            /// Memory address
            MA: ?u32 = null,
        };

        /// DMA channel configuration register (DMA_CFGR)
        pub const CFGR2 = struct {
            /// EN [0:0]
            /// Channel enable
            EN: ?u1 = null,
            /// TCIE [1:1]
            /// Transfer complete interrupt enable
            TCIE: ?u1 = null,
            /// HTIE [2:2]
            /// Half Transfer interrupt enable
            HTIE: ?u1 = null,
            /// TEIE [3:3]
            /// Transfer error interrupt enable
            TEIE: ?u1 = null,
            /// DIR [4:4]
            /// Data transfer direction
            DIR: ?u1 = null,
            /// CIRC [5:5]
            /// Circular mode
            CIRC: ?u1 = null,
            /// PINC [6:6]
            /// Peripheral increment mode
            PINC: ?u1 = null,
            /// MINC [7:7]
            /// Memory increment mode
            MINC: ?u1 = null,
            /// PSIZE [8:9]
            /// Peripheral size
            PSIZE: ?u2 = null,
            /// MSIZE [10:11]
            /// Memory size
            MSIZE: ?u2 = null,
            /// PL [12:13]
            /// Channel Priority level
            PL: ?u2 = null,
            /// MEM2MEM [14:14]
            /// Memory to memory mode
            MEM2MEM: ?u1 = null,
        };

        /// DMA channel 2 number of data register
        pub const CNTR2 = struct {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: ?u16 = null,
        };

        /// DMA channel 2 peripheral address register
        pub const PADDR2 = struct {
            /// PA [0:31]
            /// Peripheral address
            PA: ?u32 = null,
        };

        /// DMA channel 2 memory address register
        pub const MADDR2 = struct {
            /// MA [0:31]
            /// Memory address
            MA: ?u32 = null,
        };

        /// DMA channel configuration register (DMA_CFGR)
        pub const CFGR3 = struct {
            /// EN [0:0]
            /// Channel enable
            EN: ?u1 = null,
            /// TCIE [1:1]
            /// Transfer complete interrupt enable
            TCIE: ?u1 = null,
            /// HTIE [2:2]
            /// Half Transfer interrupt enable
            HTIE: ?u1 = null,
            /// TEIE [3:3]
            /// Transfer error interrupt enable
            TEIE: ?u1 = null,
            /// DIR [4:4]
            /// Data transfer direction
            DIR: ?u1 = null,
            /// CIRC [5:5]
            /// Circular mode
            CIRC: ?u1 = null,
            /// PINC [6:6]
            /// Peripheral increment mode
            PINC: ?u1 = null,
            /// MINC [7:7]
            /// Memory increment mode
            MINC: ?u1 = null,
            /// PSIZE [8:9]
            /// Peripheral size
            PSIZE: ?u2 = null,
            /// MSIZE [10:11]
            /// Memory size
            MSIZE: ?u2 = null,
            /// PL [12:13]
            /// Channel Priority level
            PL: ?u2 = null,
            /// MEM2MEM [14:14]
            /// Memory to memory mode
            MEM2MEM: ?u1 = null,
        };

        /// DMA channel 3 number of data register
        pub const CNTR3 = struct {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: ?u16 = null,
        };

        /// DMA channel 3 peripheral address register
        pub const PADDR3 = struct {
            /// PA [0:31]
            /// Peripheral address
            PA: ?u32 = null,
        };

        /// DMA channel 3 memory address register
        pub const MADDR3 = struct {
            /// MA [0:31]
            /// Memory address
            MA: ?u32 = null,
        };

        /// DMA channel configuration register (DMA_CFGR)
        pub const CFGR4 = struct {
            /// EN [0:0]
            /// Channel enable
            EN: ?u1 = null,
            /// TCIE [1:1]
            /// Transfer complete interrupt enable
            TCIE: ?u1 = null,
            /// HTIE [2:2]
            /// Half Transfer interrupt enable
            HTIE: ?u1 = null,
            /// TEIE [3:3]
            /// Transfer error interrupt enable
            TEIE: ?u1 = null,
            /// DIR [4:4]
            /// Data transfer direction
            DIR: ?u1 = null,
            /// CIRC [5:5]
            /// Circular mode
            CIRC: ?u1 = null,
            /// PINC [6:6]
            /// Peripheral increment mode
            PINC: ?u1 = null,
            /// MINC [7:7]
            /// Memory increment mode
            MINC: ?u1 = null,
            /// PSIZE [8:9]
            /// Peripheral size
            PSIZE: ?u2 = null,
            /// MSIZE [10:11]
            /// Memory size
            MSIZE: ?u2 = null,
            /// PL [12:13]
            /// Channel Priority level
            PL: ?u2 = null,
            /// MEM2MEM [14:14]
            /// Memory to memory mode
            MEM2MEM: ?u1 = null,
        };

        /// DMA channel 4 number of data register
        pub const CNTR4 = struct {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: ?u16 = null,
        };

        /// DMA channel 4 peripheral address register
        pub const PADDR4 = struct {
            /// PA [0:31]
            /// Peripheral address
            PA: ?u32 = null,
        };

        /// DMA channel 4 memory address register
        pub const MADDR4 = struct {
            /// MA [0:31]
            /// Memory address
            MA: ?u32 = null,
        };

        /// DMA channel configuration register (DMA_CFGR)
        pub const CFGR5 = struct {
            /// EN [0:0]
            /// Channel enable
            EN: ?u1 = null,
            /// TCIE [1:1]
            /// Transfer complete interrupt enable
            TCIE: ?u1 = null,
            /// HTIE [2:2]
            /// Half Transfer interrupt enable
            HTIE: ?u1 = null,
            /// TEIE [3:3]
            /// Transfer error interrupt enable
            TEIE: ?u1 = null,
            /// DIR [4:4]
            /// Data transfer direction
            DIR: ?u1 = null,
            /// CIRC [5:5]
            /// Circular mode
            CIRC: ?u1 = null,
            /// PINC [6:6]
            /// Peripheral increment mode
            PINC: ?u1 = null,
            /// MINC [7:7]
            /// Memory increment mode
            MINC: ?u1 = null,
            /// PSIZE [8:9]
            /// Peripheral size
            PSIZE: ?u2 = null,
            /// MSIZE [10:11]
            /// Memory size
            MSIZE: ?u2 = null,
            /// PL [12:13]
            /// Channel Priority level
            PL: ?u2 = null,
            /// MEM2MEM [14:14]
            /// Memory to memory mode
            MEM2MEM: ?u1 = null,
        };

        /// DMA channel 5 number of data register
        pub const CNTR5 = struct {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: ?u16 = null,
        };

        /// DMA channel 5 peripheral address register
        pub const PADDR5 = struct {
            /// PA [0:31]
            /// Peripheral address
            PA: ?u32 = null,
        };

        /// DMA channel 5 memory address register
        pub const MADDR5 = struct {
            /// MA [0:31]
            /// Memory address
            MA: ?u32 = null,
        };

        /// DMA channel configuration register (DMA_CFGR)
        pub const CFGR6 = struct {
            /// EN [0:0]
            /// Channel enable
            EN: ?u1 = null,
            /// TCIE [1:1]
            /// Transfer complete interrupt enable
            TCIE: ?u1 = null,
            /// HTIE [2:2]
            /// Half Transfer interrupt enable
            HTIE: ?u1 = null,
            /// TEIE [3:3]
            /// Transfer error interrupt enable
            TEIE: ?u1 = null,
            /// DIR [4:4]
            /// Data transfer direction
            DIR: ?u1 = null,
            /// CIRC [5:5]
            /// Circular mode
            CIRC: ?u1 = null,
            /// PINC [6:6]
            /// Peripheral increment mode
            PINC: ?u1 = null,
            /// MINC [7:7]
            /// Memory increment mode
            MINC: ?u1 = null,
            /// PSIZE [8:9]
            /// Peripheral size
            PSIZE: ?u2 = null,
            /// MSIZE [10:11]
            /// Memory size
            MSIZE: ?u2 = null,
            /// PL [12:13]
            /// Channel Priority level
            PL: ?u2 = null,
            /// MEM2MEM [14:14]
            /// Memory to memory mode
            MEM2MEM: ?u1 = null,
        };

        /// DMA channel 6 number of data register
        pub const CNTR6 = struct {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: ?u16 = null,
        };

        /// DMA channel 6 peripheral address register
        pub const PADDR6 = struct {
            /// PA [0:31]
            /// Peripheral address
            PA: ?u32 = null,
        };

        /// DMA channel 6 memory address register
        pub const MADDR6 = struct {
            /// MA [0:31]
            /// Memory address
            MA: ?u32 = null,
        };

        /// DMA channel configuration register (DMA_CFGR)
        pub const CFGR7 = struct {
            /// EN [0:0]
            /// Channel enable
            EN: ?u1 = null,
            /// TCIE [1:1]
            /// Transfer complete interrupt enable
            TCIE: ?u1 = null,
            /// HTIE [2:2]
            /// Half Transfer interrupt enable
            HTIE: ?u1 = null,
            /// TEIE [3:3]
            /// Transfer error interrupt enable
            TEIE: ?u1 = null,
            /// DIR [4:4]
            /// Data transfer direction
            DIR: ?u1 = null,
            /// CIRC [5:5]
            /// Circular mode
            CIRC: ?u1 = null,
            /// PINC [6:6]
            /// Peripheral increment mode
            PINC: ?u1 = null,
            /// MINC [7:7]
            /// Memory increment mode
            MINC: ?u1 = null,
            /// PSIZE [8:9]
            /// Peripheral size
            PSIZE: ?u2 = null,
            /// MSIZE [10:11]
            /// Memory size
            MSIZE: ?u2 = null,
            /// PL [12:13]
            /// Channel Priority level
            PL: ?u2 = null,
            /// MEM2MEM [14:14]
            /// Memory to memory mode
            MEM2MEM: ?u1 = null,
        };

        /// DMA channel 7 number of data register
        pub const CNTR7 = struct {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: ?u16 = null,
        };

        /// DMA channel 7 peripheral address register
        pub const PADDR7 = struct {
            /// PA [0:31]
            /// Peripheral address
            PA: ?u32 = null,
        };

        /// DMA channel 7 memory address register
        pub const MADDR7 = struct {
            /// MA [0:31]
            /// Memory address
            MA: ?u32 = null,
        };
    };

    /// Independent watchdog
    pub const IWDG = struct {
        /// Key register (IWDG_CTLR)
        pub const CTLR = struct {
            /// KEY [0:15]
            /// Key value
            KEY: ?u16 = null,
        };

        /// Prescaler register (IWDG_PSCR)
        pub const PSCR = struct {
            /// PR [0:2]
            /// Prescaler divider
            PR: ?u3 = null,
        };

        /// Reload register (IWDG_RLDR)
        pub const RLDR = struct {
            /// RL [0:11]
            /// Watchdog counter reload value
            RL: ?u12 = null,
        };

        /// Status register (IWDG_SR)
        pub const STATR = struct {
            /// PVU [0:0]
            /// Watchdog prescaler value update
            PVU: ?u1 = null,
            /// RVU [1:1]
            /// Watchdog counter reload value update
            RVU: ?u1 = null,
        };
    };

    /// Window watchdog
    pub const WWDG = struct {
        /// Control register (WWDG_CR)
        pub const CTLR = struct {
            /// T [0:6]
            /// 7-bit counter (MSB to LSB)
            T: ?u7 = null,
            /// WDGA [7:7]
            /// Activation bit
            WDGA: ?u1 = null,
        };

        /// Configuration register (WWDG_CFR)
        pub const CFGR = struct {
            /// W [0:6]
            /// 7-bit window value
            W: ?u7 = null,
            /// WDGTB [7:8]
            /// Timer Base
            WDGTB: ?u2 = null,
            /// EWI [9:9]
            /// Early Wakeup Interrupt
            EWI: ?u1 = null,
        };

        /// Status register (WWDG_SR)
        pub const STATR = struct {
            /// EWIF [0:0]
            /// Early Wakeup Interrupt Flag
            EWIF: ?u1 = null,
        };
    };

    /// Advanced timer
    /// Type for: TIM1
    pub const AdvancedTimer = struct {
        /// control register 1
        pub const CTLR1 = struct {
            /// CEN [0:0]
            /// Counter enable
            CEN: ?u1 = null,
            /// UDIS [1:1]
            /// Update disable
            UDIS: ?u1 = null,
            /// URS [2:2]
            /// Update request source
            URS: ?u1 = null,
            /// OPM [3:3]
            /// One-pulse mode
            OPM: ?u1 = null,
            /// DIR [4:4]
            /// Direction
            DIR: ?u1 = null,
            /// CMS [5:6]
            /// Center-aligned mode selection
            CMS: ?u2 = null,
            /// ARPE [7:7]
            /// Auto-reload preload enable
            ARPE: ?u1 = null,
            /// CKD [8:9]
            /// Clock division
            CKD: ?u2 = null,
            /// CAPOV [14:14]
            /// Timer capture value configuration enable
            CAPOV: ?u1 = null,
            /// CAPLVL [15:15]
            /// Timer capture level indication enable
            CAPLVL: ?u1 = null,
        };

        /// control register 2
        pub const CTLR2 = struct {
            /// CCPC [0:0]
            /// Capture/compare preloaded control
            CCPC: ?u1 = null,
            /// CCUS [2:2]
            /// Capture/compare control update selection
            CCUS: ?u1 = null,
            /// CCDS [3:3]
            /// Capture/compare DMA selection
            CCDS: ?u1 = null,
            /// MMS [4:6]
            /// Master mode selection
            MMS: ?u3 = null,
            /// TI1S [7:7]
            /// TI1 selection
            TI1S: ?u1 = null,
            /// OIS1 [8:8]
            /// Output Idle state 1
            OIS1: ?u1 = null,
            /// OIS1N [9:9]
            /// Output Idle state 1
            OIS1N: ?u1 = null,
            /// OIS2 [10:10]
            /// Output Idle state 2
            OIS2: ?u1 = null,
            /// OIS2N [11:11]
            /// Output Idle state 2
            OIS2N: ?u1 = null,
            /// OIS3 [12:12]
            /// Output Idle state 3
            OIS3: ?u1 = null,
            /// OIS3N [13:13]
            /// Output Idle state 3
            OIS3N: ?u1 = null,
            /// OIS4 [14:14]
            /// Output Idle state 4
            OIS4: ?u1 = null,
        };

        /// slave mode control register
        pub const SMCFGR = struct {
            /// SMS [0:2]
            /// Slave mode selection
            SMS: ?u3 = null,
            /// TS [4:6]
            /// Trigger selection
            TS: ?u3 = null,
            /// MSM [7:7]
            /// Master/Slave mode
            MSM: ?u1 = null,
            /// ETF [8:11]
            /// External trigger filter
            ETF: ?u4 = null,
            /// ETPS [12:13]
            /// External trigger prescaler
            ETPS: ?u2 = null,
            /// ECE [14:14]
            /// External clock enable
            ECE: ?u1 = null,
            /// ETP [15:15]
            /// External trigger polarity
            ETP: ?u1 = null,
        };

        /// DMA/Interrupt enable register
        pub const DMAINTENR = struct {
            /// UIE [0:0]
            /// Update interrupt enable
            UIE: ?u1 = null,
            /// CC1IE [1:1]
            /// Capture/Compare 1 interrupt enable
            CC1IE: ?u1 = null,
            /// CC2IE [2:2]
            /// Capture/Compare 2 interrupt enable
            CC2IE: ?u1 = null,
            /// CC3IE [3:3]
            /// Capture/Compare 3 interrupt enable
            CC3IE: ?u1 = null,
            /// CC4IE [4:4]
            /// Capture/Compare 4 interrupt enable
            CC4IE: ?u1 = null,
            /// COMIE [5:5]
            /// COM interrupt enable
            COMIE: ?u1 = null,
            /// TIE [6:6]
            /// Trigger interrupt enable
            TIE: ?u1 = null,
            /// BIE [7:7]
            /// Break interrupt enable
            BIE: ?u1 = null,
            /// UDE [8:8]
            /// Update DMA request enable
            UDE: ?u1 = null,
            /// CC1DE [9:9]
            /// Capture/Compare 1 DMA request enable
            CC1DE: ?u1 = null,
            /// CC2DE [10:10]
            /// Capture/Compare 2 DMA request enable
            CC2DE: ?u1 = null,
            /// CC3DE [11:11]
            /// Capture/Compare 3 DMA request enable
            CC3DE: ?u1 = null,
            /// CC4DE [12:12]
            /// Capture/Compare 4 DMA request enable
            CC4DE: ?u1 = null,
            /// COMDE [13:13]
            /// COM DMA request enable
            COMDE: ?u1 = null,
            /// TDE [14:14]
            /// Trigger DMA request enable
            TDE: ?u1 = null,
        };

        /// status register
        pub const INTFR = struct {
            /// UIF [0:0]
            /// Update interrupt flag
            UIF: ?u1 = null,
            /// CC1IF [1:1]
            /// Capture/compare 1 interrupt flag
            CC1IF: ?u1 = null,
            /// CC2IF [2:2]
            /// Capture/Compare 2 interrupt flag
            CC2IF: ?u1 = null,
            /// CC3IF [3:3]
            /// Capture/Compare 3 interrupt flag
            CC3IF: ?u1 = null,
            /// CC4IF [4:4]
            /// Capture/Compare 4 interrupt flag
            CC4IF: ?u1 = null,
            /// COMIF [5:5]
            /// COM interrupt flag
            COMIF: ?u1 = null,
            /// TIF [6:6]
            /// Trigger interrupt flag
            TIF: ?u1 = null,
            /// BIF [7:7]
            /// Break interrupt flag
            BIF: ?u1 = null,
            /// CC1OF [9:9]
            /// Capture/Compare 1 overcapture flag
            CC1OF: ?u1 = null,
            /// CC2OF [10:10]
            /// Capture/compare 2 overcapture flag
            CC2OF: ?u1 = null,
            /// CC3OF [11:11]
            /// Capture/Compare 3 overcapture flag
            CC3OF: ?u1 = null,
            /// CC4OF [12:12]
            /// Capture/Compare 4 overcapture flag
            CC4OF: ?u1 = null,
        };

        /// event generation register
        pub const SWEVGR = struct {
            /// UG [0:0]
            /// Update generation
            UG: ?u1 = null,
            /// CC1G [1:1]
            /// Capture/compare 1 generation
            CC1G: ?u1 = null,
            /// CC2G [2:2]
            /// Capture/compare 2 generation
            CC2G: ?u1 = null,
            /// CC3G [3:3]
            /// Capture/compare 3 generation
            CC3G: ?u1 = null,
            /// CC4G [4:4]
            /// Capture/compare 4 generation
            CC4G: ?u1 = null,
            /// COMG [5:5]
            /// Capture/Compare control update generation
            COMG: ?u1 = null,
            /// TG [6:6]
            /// Trigger generation
            TG: ?u1 = null,
            /// BG [7:7]
            /// Break generation
            BG: ?u1 = null,
        };

        /// capture/compare mode register (output mode)
        pub const CHCTLR1_Output = struct {
            /// CC1S [0:1]
            /// Capture/Compare 1 selection
            CC1S: ?u2 = null,
            /// OC1FE [2:2]
            /// Output Compare 1 fast enable
            OC1FE: ?u1 = null,
            /// OC1PE [3:3]
            /// Output Compare 1 preload enable
            OC1PE: ?u1 = null,
            /// OC1M [4:6]
            /// Output Compare 1 mode
            OC1M: ?u3 = null,
            /// OC1CE [7:7]
            /// Output Compare 1 clear enable
            OC1CE: ?u1 = null,
            /// CC2S [8:9]
            /// Capture/Compare 2 selection
            CC2S: ?u2 = null,
            /// OC2FE [10:10]
            /// Output Compare 2 fast enable
            OC2FE: ?u1 = null,
            /// OC2PE [11:11]
            /// Output Compare 2 preload enable
            OC2PE: ?u1 = null,
            /// OC2M [12:14]
            /// Output Compare 2 mode
            OC2M: ?u3 = null,
            /// OC2CE [15:15]
            /// Output Compare 2 clear enable
            OC2CE: ?u1 = null,
        };

        /// capture/compare mode register (output mode)
        pub const CHCTLR2_Output = struct {
            /// CC3S [0:1]
            /// Capture/Compare 3 selection
            CC3S: ?u2 = null,
            /// OC3FE [2:2]
            /// Output compare 3 fast enable
            OC3FE: ?u1 = null,
            /// OC3PE [3:3]
            /// Output compare 3 preload enable
            OC3PE: ?u1 = null,
            /// OC3M [4:6]
            /// Output compare 3 mode
            OC3M: ?u3 = null,
            /// OC3CE [7:7]
            /// Output compare 3 clear enable
            OC3CE: ?u1 = null,
            /// CC4S [8:9]
            /// Capture/Compare 4 selection
            CC4S: ?u2 = null,
            /// OC4FE [10:10]
            /// Output compare 4 fast enable
            OC4FE: ?u1 = null,
            /// OC4PE [11:11]
            /// Output compare 4 preload enable
            OC4PE: ?u1 = null,
            /// OC4M [12:14]
            /// Output compare 4 mode
            OC4M: ?u3 = null,
            /// OC4CE [15:15]
            /// Output compare 4 clear enable
            OC4CE: ?u1 = null,
        };

        /// capture/compare enable register
        pub const CCER = struct {
            /// CC1E [0:0]
            /// Capture/Compare 1 output enable
            CC1E: ?u1 = null,
            /// CC1P [1:1]
            /// Capture/Compare 1 output Polarity
            CC1P: ?u1 = null,
            /// CC1NE [2:2]
            /// Capture/Compare 1 complementary output enable
            CC1NE: ?u1 = null,
            /// CC1NP [3:3]
            /// Capture/Compare 1 output Polarity
            CC1NP: ?u1 = null,
            /// CC2E [4:4]
            /// Capture/Compare 2 output enable
            CC2E: ?u1 = null,
            /// CC2P [5:5]
            /// Capture/Compare 2 output Polarity
            CC2P: ?u1 = null,
            /// CC2NE [6:6]
            /// Capture/Compare 2 complementary output enable
            CC2NE: ?u1 = null,
            /// CC2NP [7:7]
            /// Capture/Compare 2 output Polarity
            CC2NP: ?u1 = null,
            /// CC3E [8:8]
            /// Capture/Compare 3 output enable
            CC3E: ?u1 = null,
            /// CC3P [9:9]
            /// Capture/Compare 3 output Polarity
            CC3P: ?u1 = null,
            /// CC3NE [10:10]
            /// Capture/Compare 3 complementary output enable
            CC3NE: ?u1 = null,
            /// CC3NP [11:11]
            /// Capture/Compare 3 output Polarity
            CC3NP: ?u1 = null,
            /// CC4E [12:12]
            /// Capture/Compare 4 output enable
            CC4E: ?u1 = null,
            /// CC4P [13:13]
            /// Capture/Compare 3 output Polarity
            CC4P: ?u1 = null,
        };

        /// counter
        pub const CNT = struct {
            /// CNT [0:15]
            /// counter value
            CNT: ?u16 = null,
        };

        /// prescaler
        pub const PSC = struct {
            /// PSC [0:15]
            /// Prescaler value
            PSC: ?u16 = null,
        };

        /// auto-reload register
        pub const ATRLR = struct {
            /// ATRLR [0:15]
            /// Auto-reload value
            ATRLR: ?u16 = null,
        };

        /// repetition counter register
        pub const RPTCR = struct {
            /// RPTCR [0:7]
            /// Repetition counter value
            RPTCR: ?u8 = null,
        };

        /// capture/compare register 1
        pub const CH1CVR = struct {
            /// CH1CVR [0:15]
            /// Capture/Compare 1 value
            CH1CVR: ?u16 = null,
        };

        /// capture/compare register 2
        pub const CH2CVR = struct {
            /// CH2CVR [0:15]
            /// Capture/Compare 2 value
            CH2CVR: ?u16 = null,
        };

        /// capture/compare register 3
        pub const CH3CVR = struct {
            /// CH3CVR [0:15]
            /// Capture/Compare value
            CH3CVR: ?u16 = null,
        };

        /// capture/compare register 4
        pub const CH4CVR = struct {
            /// CH4CVR [0:15]
            /// Capture/Compare value
            CH4CVR: ?u16 = null,
        };

        /// break and dead-time register
        pub const BDTR = struct {
            /// DTG [0:7]
            /// Dead-time generator setup
            DTG: ?u8 = null,
            /// LOCK [8:9]
            /// Lock configuration
            LOCK: ?u2 = null,
            /// OSSI [10:10]
            /// Off-state selection for Idle mode
            OSSI: ?u1 = null,
            /// OSSR [11:11]
            /// Off-state selection for Run mode
            OSSR: ?u1 = null,
            /// BKE [12:12]
            /// Break enable
            BKE: ?u1 = null,
            /// BKP [13:13]
            /// Break polarity
            BKP: ?u1 = null,
            /// AOE [14:14]
            /// Automatic output enable
            AOE: ?u1 = null,
            /// MOE [15:15]
            /// Main output enable
            MOE: ?u1 = null,
        };

        /// DMA control register
        pub const DMACFGR = struct {
            /// DBA [0:4]
            /// DMA base address
            DBA: ?u5 = null,
            /// DBL [8:12]
            /// DMA burst length
            DBL: ?u5 = null,
        };

        /// DMA address for full transfer
        pub const DMAADR = struct {
            /// DMAB [0:15]
            /// DMA register for burst accesses
            DMAB: ?u16 = null,
        };
    };

    /// General purpose timer
    /// Type for: TIM2
    pub const GeneralPurposeTimer = struct {
        /// control register 1
        pub const CTLR1 = struct {
            /// CEN [0:0]
            /// Counter enable
            CEN: ?u1 = null,
            /// UDIS [1:1]
            /// Update disable
            UDIS: ?u1 = null,
            /// URS [2:2]
            /// Update request source
            URS: ?u1 = null,
            /// OPM [3:3]
            /// One-pulse mode
            OPM: ?u1 = null,
            /// DIR [4:4]
            /// Direction
            DIR: ?u1 = null,
            /// CMS [5:6]
            /// Center-aligned mode selection
            CMS: ?u2 = null,
            /// ARPE [7:7]
            /// Auto-reload preload enable
            ARPE: ?u1 = null,
            /// CKD [8:9]
            /// Clock division
            CKD: ?u2 = null,
            /// CAPOV [14:14]
            /// Timer capture value configuration enable
            CAPOV: ?u1 = null,
            /// CAPLVL [15:15]
            /// Timer capture level indication enable
            CAPLVL: ?u1 = null,
        };

        /// control register 2
        pub const CTLR2 = struct {
            /// CCDS [3:3]
            /// Capture/compare DMA selection
            CCDS: ?u1 = null,
            /// MMS [4:6]
            /// Master mode selection
            MMS: ?u3 = null,
            /// TI1S [7:7]
            /// TI1 selection
            TI1S: ?u1 = null,
        };

        /// slave mode control register
        pub const SMCFGR = struct {
            /// SMS [0:2]
            /// Slave mode selection
            SMS: ?u3 = null,
            /// TS [4:6]
            /// Trigger selection
            TS: ?u3 = null,
            /// MSM [7:7]
            /// Master/Slave mode
            MSM: ?u1 = null,
            /// ETF [8:11]
            /// External trigger filter
            ETF: ?u4 = null,
            /// ETPS [12:13]
            /// External trigger prescaler
            ETPS: ?u2 = null,
            /// ECE [14:14]
            /// External clock enable
            ECE: ?u1 = null,
            /// ETP [15:15]
            /// External trigger polarity
            ETP: ?u1 = null,
        };

        /// DMA/Interrupt enable register
        pub const DMAINTENR = struct {
            /// UIE [0:0]
            /// Update interrupt enable
            UIE: ?u1 = null,
            /// CC1IE [1:1]
            /// Capture/Compare 1 interrupt enable
            CC1IE: ?u1 = null,
            /// CC2IE [2:2]
            /// Capture/Compare 2 interrupt enable
            CC2IE: ?u1 = null,
            /// CC3IE [3:3]
            /// Capture/Compare 3 interrupt enable
            CC3IE: ?u1 = null,
            /// CC4IE [4:4]
            /// Capture/Compare 4 interrupt enable
            CC4IE: ?u1 = null,
            /// TIE [6:6]
            /// Trigger interrupt enable
            TIE: ?u1 = null,
            /// UDE [8:8]
            /// Update DMA request enable
            UDE: ?u1 = null,
            /// CC1DE [9:9]
            /// Capture/Compare 1 DMA request enable
            CC1DE: ?u1 = null,
            /// CC2DE [10:10]
            /// Capture/Compare 2 DMA request enable
            CC2DE: ?u1 = null,
            /// CC3DE [11:11]
            /// Capture/Compare 3 DMA request enable
            CC3DE: ?u1 = null,
            /// CC4DE [12:12]
            /// Capture/Compare 4 DMA request enable
            CC4DE: ?u1 = null,
            /// TDE [14:14]
            /// Trigger DMA request enable
            TDE: ?u1 = null,
        };

        /// status register
        pub const INTFR = struct {
            /// UIF [0:0]
            /// Update interrupt flag
            UIF: ?u1 = null,
            /// CC1IF [1:1]
            /// Capture/compare 1 interrupt flag
            CC1IF: ?u1 = null,
            /// CC2IF [2:2]
            /// Capture/Compare 2 interrupt flag
            CC2IF: ?u1 = null,
            /// CC3IF [3:3]
            /// Capture/Compare 3 interrupt flag
            CC3IF: ?u1 = null,
            /// CC4IF [4:4]
            /// Capture/Compare 4 interrupt flag
            CC4IF: ?u1 = null,
            /// TIF [6:6]
            /// Trigger interrupt flag
            TIF: ?u1 = null,
            /// CC1OF [9:9]
            /// Capture/Compare 1 overcapture flag
            CC1OF: ?u1 = null,
            /// CC2OF [10:10]
            /// Capture/compare 2 overcapture flag
            CC2OF: ?u1 = null,
            /// CC3OF [11:11]
            /// Capture/Compare 3 overcapture flag
            CC3OF: ?u1 = null,
            /// CC4OF [12:12]
            /// Capture/Compare 4 overcapture flag
            CC4OF: ?u1 = null,
        };

        /// event generation register
        pub const SWEVGR = struct {
            /// UG [0:0]
            /// Update generation
            UG: ?u1 = null,
            /// CC1G [1:1]
            /// Capture/compare 1 generation
            CC1G: ?u1 = null,
            /// CC2G [2:2]
            /// Capture/compare 2 generation
            CC2G: ?u1 = null,
            /// CC3G [3:3]
            /// Capture/compare 3 generation
            CC3G: ?u1 = null,
            /// CC4G [4:4]
            /// Capture/compare 4 generation
            CC4G: ?u1 = null,
            /// TG [6:6]
            /// Trigger generation
            TG: ?u1 = null,
        };

        /// capture/compare mode register 1 (output mode)
        pub const CHCTLR1_Output = struct {
            /// CC1S [0:1]
            /// Capture/Compare 1 selection
            CC1S: ?u2 = null,
            /// OC1FE [2:2]
            /// Output compare 1 fast enable
            OC1FE: ?u1 = null,
            /// OC1PE [3:3]
            /// Output compare 1 preload enable
            OC1PE: ?u1 = null,
            /// OC1M [4:6]
            /// Output compare 1 mode
            OC1M: ?u3 = null,
            /// OC1CE [7:7]
            /// Output compare 1 clear enable
            OC1CE: ?u1 = null,
            /// CC2S [8:9]
            /// Capture/Compare channel 2 input selection
            CC2S: ?u2 = null,
            /// OC2FE [10:10]
            /// Output compare channel 2 fast enable
            OC2FE: ?u1 = null,
            /// OC2PE [11:11]
            /// Compare capture register 1 preload enable
            OC2PE: ?u1 = null,
            /// OC2M [12:14]
            /// Output compare channel 2 mode
            OC2M: ?u3 = null,
            /// OC2CE [15:15]
            /// Output compare channel 2 clear enable
            OC2CE: ?u1 = null,
        };

        /// capture/compare mode register 2 (output mode)
        pub const CHCTLR2_Output = struct {
            /// CC3S [0:1]
            /// Capture/Compare 3 selection
            CC3S: ?u2 = null,
            /// OC3FE [2:2]
            /// Output compare 3 fast enable
            OC3FE: ?u1 = null,
            /// OC3PE [3:3]
            /// Output compare 3 preload enable
            OC3PE: ?u1 = null,
            /// OC3M [4:6]
            /// Output compare 3 mode
            OC3M: ?u3 = null,
            /// OC3CE [7:7]
            /// Output compare 3 clear enable
            OC3CE: ?u1 = null,
            /// CC4S [8:9]
            /// Capture/Compare 4 selection
            CC4S: ?u2 = null,
            /// OC4FE [10:10]
            /// Output compare 4 fast enable
            OC4FE: ?u1 = null,
            /// OC4PE [11:11]
            /// Output compare 4 preload enable
            OC4PE: ?u1 = null,
            /// OC4M [12:14]
            /// Output compare 4 mode
            OC4M: ?u3 = null,
            /// OC4CE [15:15]
            /// Output compare 4 clear enable
            OC4CE: ?u1 = null,
        };

        /// capture/compare enable register
        pub const CCER = struct {
            /// CC1E [0:0]
            /// Capture/Compare channel 1 output enable
            CC1E: ?u1 = null,
            /// CC1P [1:1]
            /// Capture/Compare channel 1 output Polarity
            CC1P: ?u1 = null,
            /// CC2E [4:4]
            /// Capture/Compare channel 2 output enable
            CC2E: ?u1 = null,
            /// CC2P [5:5]
            /// Capture/Compare channel 2 output Polarity
            CC2P: ?u1 = null,
            /// CC3E [8:8]
            /// Capture/Compare channel 3 output enable
            CC3E: ?u1 = null,
            /// CC3P [9:9]
            /// Capture/Compare channel 3 output Polarity
            CC3P: ?u1 = null,
            /// CC4E [12:12]
            /// Capture/Compare channel 4 output enable
            CC4E: ?u1 = null,
            /// CC4P [13:13]
            /// Capture/Compare channel 4 output Polarity
            CC4P: ?u1 = null,
        };

        /// counter
        pub const CNT = struct {
            /// CNT [0:15]
            /// counter value
            CNT: ?u16 = null,
        };

        /// prescaler
        pub const PSC = struct {
            /// PSC [0:15]
            /// Prescaler value
            PSC: ?u16 = null,
        };

        /// auto-reload register
        pub const ATRLR = struct {
            /// ATRLR [0:15]
            /// Auto-reload value
            ATRLR: ?u16 = null,
        };

        /// capture/compare register 1
        pub const CH1CVR = struct {
            /// CH1CVR [0:15]
            /// Capture/Compare 1 value
            CH1CVR: ?u16 = null,
        };

        /// capture/compare register 2
        pub const CH2CVR = struct {
            /// CH2CVR [0:15]
            /// Capture/Compare 2 value
            CH2CVR: ?u16 = null,
        };

        /// capture/compare register 3
        pub const CH3CVR = struct {
            /// CH3CVR [0:15]
            /// Capture/Compare 3 value
            CH3CVR: ?u16 = null,
        };

        /// capture/compare register 4
        pub const CH4CVR = struct {
            /// CH4CVR [0:15]
            /// Capture/Compare 4 value
            CH4CVR: ?u16 = null,
        };

        /// DMA control register
        pub const DMACFGR = struct {
            /// DBA [0:4]
            /// DMA base address
            DBA: ?u5 = null,
            /// DBL [8:12]
            /// DMA burst length
            DBL: ?u5 = null,
        };

        /// DMA address for full transfer
        pub const DMAADR = struct {
            /// DMAADR [0:15]
            /// DMA register for burst accesses
            DMAADR: ?u16 = null,
        };
    };

    /// Inter integrated circuit
    /// Type for: I2C1
    pub const I2C = struct {
        /// Control register 1
        pub const CTLR1 = struct {
            /// PE [0:0]
            /// Peripheral enable
            PE: ?u1 = null,
            /// ENPEC [5:5]
            /// PEC enable
            ENPEC: ?u1 = null,
            /// ENGC [6:6]
            /// General call enable
            ENGC: ?u1 = null,
            /// NOSTRETCH [7:7]
            /// Clock stretching disable (Slave mode)
            NOSTRETCH: ?u1 = null,
            /// START [8:8]
            /// Start generation
            START: ?u1 = null,
            /// STOP [9:9]
            /// Stop generation
            STOP: ?u1 = null,
            /// ACK [10:10]
            /// Acknowledge enable
            ACK: ?u1 = null,
            /// POS [11:11]
            /// Acknowledge/PEC Position (for data reception)
            POS: ?u1 = null,
            /// PEC [12:12]
            /// Packet error checking
            PEC: ?u1 = null,
            /// SWRST [15:15]
            /// Software reset
            SWRST: ?u1 = null,
        };

        /// Control register 2
        pub const CTLR2 = struct {
            /// FREQ [0:5]
            /// Peripheral clock frequency
            FREQ: ?u6 = null,
            /// ITERREN [8:8]
            /// Error interrupt enable
            ITERREN: ?u1 = null,
            /// ITEVTEN [9:9]
            /// Event interrupt enable
            ITEVTEN: ?u1 = null,
            /// ITBUFEN [10:10]
            /// Buffer interrupt enable
            ITBUFEN: ?u1 = null,
            /// DMAEN [11:11]
            /// DMA requests enable
            DMAEN: ?u1 = null,
            /// LAST [12:12]
            /// DMA last transfer
            LAST: ?u1 = null,
        };

        /// Own address register 1
        pub const OADDR1 = struct {
            /// ADD0 [0:0]
            /// Interface address
            ADD0: ?u1 = null,
            /// ADD7_1 [1:7]
            /// Interface address
            ADD7_1: ?u7 = null,
            /// ADD9_8 [8:9]
            /// Interface address
            ADD9_8: ?u2 = null,
            /// ADDMODE [15:15]
            /// Addressing mode (slave mode)
            ADDMODE: ?u1 = null,
        };

        /// Own address register 2
        pub const OADDR2 = struct {
            /// ENDUAL [0:0]
            /// Dual addressing mode enable
            ENDUAL: ?u1 = null,
            /// ADD2 [1:7]
            /// Interface address
            ADD2: ?u7 = null,
        };

        /// Data register
        pub const DATAR = struct {
            /// DATAR [0:7]
            /// 8-bit data register
            DATAR: ?u8 = null,
        };

        /// Status register 1
        pub const STAR1 = struct {
            /// SB [0:0]
            /// Start bit (Master mode)
            SB: ?u1 = null,
            /// ADDR [1:1]
            /// Address sent (master mode)/matched (slave mode)
            ADDR: ?u1 = null,
            /// BTF [2:2]
            /// Byte transfer finished
            BTF: ?u1 = null,
            /// ADD10 [3:3]
            /// 10-bit header sent (Master mode)
            ADD10: ?u1 = null,
            /// STOPF [4:4]
            /// Stop detection (slave mode)
            STOPF: ?u1 = null,
            /// RxNE [6:6]
            /// Data register not empty (receivers)
            RxNE: ?u1 = null,
            /// TxE [7:7]
            /// Data register empty (transmitters)
            TxE: ?u1 = null,
            /// BERR [8:8]
            /// Bus error
            BERR: ?u1 = null,
            /// ARLO [9:9]
            /// Arbitration lost (master mode)
            ARLO: ?u1 = null,
            /// AF [10:10]
            /// Acknowledge failure
            AF: ?u1 = null,
            /// OVR [11:11]
            /// Overrun/Underrun
            OVR: ?u1 = null,
            /// PECERR [12:12]
            /// PEC Error in reception
            PECERR: ?u1 = null,
        };

        /// Status register 2
        pub const STAR2 = struct {
            /// MSL [0:0]
            /// Master/slave
            MSL: ?u1 = null,
            /// BUSY [1:1]
            /// Bus busy
            BUSY: ?u1 = null,
            /// TRA [2:2]
            /// Transmitter/receiver
            TRA: ?u1 = null,
            /// GENCALL [4:4]
            /// General call address (Slave mode)
            GENCALL: ?u1 = null,
            /// DUALF [7:7]
            /// Dual flag (Slave mode)
            DUALF: ?u1 = null,
            /// PEC [8:15]
            /// acket error checking register
            PEC: ?u8 = null,
        };

        /// Clock control register
        pub const CKCFGR = struct {
            /// CCR [0:11]
            /// Clock control register in Fast/Standard mode (Master mode)
            CCR: ?u12 = null,
            /// DUTY [14:14]
            /// Fast mode duty cycle
            DUTY: ?u1 = null,
            /// F_S [15:15]
            /// I2C master mode selection
            F_S: ?u1 = null,
        };
    };

    /// Serial peripheral interface
    /// Type for: SPI1
    pub const SPI = struct {
        /// control register 1
        pub const CTLR1 = struct {
            /// CPHA [0:0]
            /// Clock phase
            CPHA: ?u1 = null,
            /// CPOL [1:1]
            /// Clock polarity
            CPOL: ?u1 = null,
            /// MSTR [2:2]
            /// Master selection
            MSTR: ?u1 = null,
            /// BR [3:5]
            /// Baud rate control
            BR: ?u3 = null,
            /// SPE [6:6]
            /// SPI enable
            SPE: ?u1 = null,
            /// LSBFIRST [7:7]
            /// Frame format
            LSBFIRST: ?u1 = null,
            /// SSI [8:8]
            /// Internal slave select
            SSI: ?u1 = null,
            /// SSM [9:9]
            /// Software slave management
            SSM: ?u1 = null,
            /// RXONLY [10:10]
            /// Receive only
            RXONLY: ?u1 = null,
            /// DFF [11:11]
            /// Data frame format
            DFF: ?u1 = null,
            /// CRCNEXT [12:12]
            /// CRC transfer next
            CRCNEXT: ?u1 = null,
            /// CRCEN [13:13]
            /// Hardware CRC calculation enable
            CRCEN: ?u1 = null,
            /// BIDIOE [14:14]
            /// Output enable in bidirectional mode
            BIDIOE: ?u1 = null,
            /// BIDIMODE [15:15]
            /// Bidirectional data mode enable
            BIDIMODE: ?u1 = null,
        };

        /// control register 2
        pub const CTLR2 = struct {
            /// RXDMAEN [0:0]
            /// Rx buffer DMA enable
            RXDMAEN: ?u1 = null,
            /// TXDMAEN [1:1]
            /// Tx buffer DMA enable
            TXDMAEN: ?u1 = null,
            /// SSOE [2:2]
            /// SS output enable
            SSOE: ?u1 = null,
            /// ERRIE [5:5]
            /// Error interrupt enable
            ERRIE: ?u1 = null,
            /// RXNEIE [6:6]
            /// RX buffer not empty interrupt enable
            RXNEIE: ?u1 = null,
            /// TXEIE [7:7]
            /// Tx buffer empty interrupt enable
            TXEIE: ?u1 = null,
        };

        /// status register
        pub const STATR = struct {
            /// RXNE [0:0]
            /// Receive buffer not empty
            RXNE: ?u1 = null,
            /// TXE [1:1]
            /// Transmit buffer empty
            TXE: ?u1 = null,
            /// CHSID [2:2]
            /// Channel side
            CHSID: ?u1 = null,
            /// UDR [3:3]
            /// Underrun flag
            UDR: ?u1 = null,
            /// CRCERR [4:4]
            /// CRC error flag
            CRCERR: ?u1 = null,
            /// MODF [5:5]
            /// Mode fault
            MODF: ?u1 = null,
            /// OVR [6:6]
            /// Overrun flag
            OVR: ?u1 = null,
            /// BSY [7:7]
            /// Busy flag
            BSY: ?u1 = null,
        };

        /// data register
        pub const DATAR = struct {
            /// DATAR [0:15]
            /// Data register
            DATAR: ?u16 = null,
        };

        /// CRCR polynomial register
        pub const CRCR = struct {
            /// CRCPOLY [0:15]
            /// CRC polynomial register
            CRCPOLY: ?u16 = null,
        };

        /// RX CRC register
        pub const RCRCR = struct {
            /// RXCRC [0:15]
            /// Rx CRC register
            RXCRC: ?u16 = null,
        };

        /// send CRC register
        pub const TCRCR = struct {
            /// TXCRC [0:15]
            /// Tx CRC register
            TXCRC: ?u16 = null,
        };

        /// high speed control register
        pub const HSCR = struct {
            /// HSRXEN [0:0]
            /// High speed mode read enable
            HSRXEN: ?u1 = null,
        };
    };

    /// Universal synchronous asynchronous receiver transmitter
    /// Type for: USART1
    pub const USART = struct {
        /// Status register
        pub const STATR = struct {
            /// PE [0:0]
            /// Parity error
            PE: ?u1 = null,
            /// FE [1:1]
            /// Framing error
            FE: ?u1 = null,
            /// NE [2:2]
            /// Noise error flag
            NE: ?u1 = null,
            /// ORE [3:3]
            /// Overrun error
            ORE: ?u1 = null,
            /// IDLE [4:4]
            /// IDLE line detected
            IDLE: ?u1 = null,
            /// RXNE [5:5]
            /// Read data register not empty
            RXNE: ?u1 = null,
            /// TC [6:6]
            /// Transmission complete
            TC: ?u1 = null,
            /// TXE [7:7]
            /// Transmit data register empty
            TXE: ?u1 = null,
            /// LBD [8:8]
            /// LIN break detection flag
            LBD: ?u1 = null,
            /// CTS [9:9]
            /// CTS flag
            CTS: ?u1 = null,
        };

        /// Data register
        pub const DATAR = struct {
            /// DR [0:8]
            /// Data value
            DR: ?u9 = null,
        };

        /// Baud rate register
        pub const BRR = struct {
            /// DIV_Fraction [0:3]
            /// fraction of USARTDIV
            DIV_Fraction: ?u4 = null,
            /// DIV_Mantissa [4:15]
            /// mantissa of USARTDIV
            DIV_Mantissa: ?u12 = null,
        };

        /// Control register 1
        pub const CTLR1 = struct {
            /// SBK [0:0]
            /// Send break
            SBK: ?u1 = null,
            /// RWU [1:1]
            /// Receiver wakeup
            RWU: ?u1 = null,
            /// RE [2:2]
            /// Receiver enable
            RE: ?u1 = null,
            /// TE [3:3]
            /// Transmitter enable
            TE: ?u1 = null,
            /// IDLEIE [4:4]
            /// IDLE interrupt enable
            IDLEIE: ?u1 = null,
            /// RXNEIE [5:5]
            /// RXNE interrupt enable
            RXNEIE: ?u1 = null,
            /// TCIE [6:6]
            /// Transmission complete interrupt enable
            TCIE: ?u1 = null,
            /// TXEIE [7:7]
            /// TXE interrupt enable
            TXEIE: ?u1 = null,
            /// PEIE [8:8]
            /// PE interrupt enable
            PEIE: ?u1 = null,
            /// PS [9:9]
            /// Parity selection
            PS: ?u1 = null,
            /// PCE [10:10]
            /// Parity control enable
            PCE: ?u1 = null,
            /// WAKE [11:11]
            /// Wakeup method
            WAKE: ?u1 = null,
            /// M [12:12]
            /// Word length
            M: ?u1 = null,
            /// UE [13:13]
            /// USART enable
            UE: ?u1 = null,
        };

        /// Control register 2
        pub const CTLR2 = struct {
            /// ADD [0:3]
            /// Address of the USART node
            ADD: ?u4 = null,
            /// LBDL [5:5]
            /// lin break detection length
            LBDL: ?u1 = null,
            /// LBDIE [6:6]
            /// LIN break detection interrupt enable
            LBDIE: ?u1 = null,
            /// LBCL [8:8]
            /// Last bit clock pulse
            LBCL: ?u1 = null,
            /// CPHA [9:9]
            /// Clock phase
            CPHA: ?u1 = null,
            /// CPOL [10:10]
            /// Clock polarity
            CPOL: ?u1 = null,
            /// CLKEN [11:11]
            /// Clock enable
            CLKEN: ?u1 = null,
            /// STOP [12:13]
            /// STOP bits
            STOP: ?u2 = null,
            /// LINEN [14:14]
            /// LIN mode enable
            LINEN: ?u1 = null,
        };

        /// Control register 3
        pub const CTLR3 = struct {
            /// EIE [0:0]
            /// Error interrupt enable
            EIE: ?u1 = null,
            /// IREN [1:1]
            /// IrDA mode enable
            IREN: ?u1 = null,
            /// IRLP [2:2]
            /// IrDA low-power
            IRLP: ?u1 = null,
            /// HDSEL [3:3]
            /// Half-duplex selection
            HDSEL: ?u1 = null,
            /// NACK [4:4]
            /// Smartcard NACK enable
            NACK: ?u1 = null,
            /// SCEN [5:5]
            /// Smartcard mode enable
            SCEN: ?u1 = null,
            /// DMAR [6:6]
            /// DMA enable receiver
            DMAR: ?u1 = null,
            /// DMAT [7:7]
            /// DMA enable transmitter
            DMAT: ?u1 = null,
            /// RTSE [8:8]
            /// RTS enable
            RTSE: ?u1 = null,
            /// CTSE [9:9]
            /// CTS enable
            CTSE: ?u1 = null,
            /// CTSIE [10:10]
            /// CTS interrupt enable
            CTSIE: ?u1 = null,
        };

        /// Guard time and prescaler register
        pub const GPR = struct {
            /// PSC [0:7]
            /// Prescaler value
            PSC: ?u8 = null,
            /// GT [8:15]
            /// Guard time value
            GT: ?u8 = null,
        };
    };

    /// Analog to digital converter
    pub const ADC1 = struct {
        /// status register
        pub const STATR = struct {
            /// AWD [0:0]
            /// Analog watchdog flag
            AWD: ?u1 = null,
            /// EOC [1:1]
            /// Regular channel end of conversion
            EOC: ?u1 = null,
            /// JEOC [2:2]
            /// Injected channel end of conversion
            JEOC: ?u1 = null,
            /// JSTRT [3:3]
            /// Injected channel start flag
            JSTRT: ?u1 = null,
            /// STRT [4:4]
            /// Regular channel start flag
            STRT: ?u1 = null,
        };

        /// control register 1/TKEY_V_CTLR
        pub const CTLR1 = struct {
            /// AWDCH [0:4]
            /// Analog watchdog channel select bits
            AWDCH: ?u5 = null,
            /// EOCIE [5:5]
            /// Interrupt enable for EOC
            EOCIE: ?u1 = null,
            /// AWDIE [6:6]
            /// Analog watchdog interrupt enable
            AWDIE: ?u1 = null,
            /// JEOCIE [7:7]
            /// Interrupt enable for injected channels
            JEOCIE: ?u1 = null,
            /// SCAN [8:8]
            /// Scan mode enable
            SCAN: ?u1 = null,
            /// AWDSGL [9:9]
            /// Enable the watchdog on a single channel in scan mode
            AWDSGL: ?u1 = null,
            /// JAUTO [10:10]
            /// Automatic injected group conversion
            JAUTO: ?u1 = null,
            /// DISCEN [11:11]
            /// Discontinuous mode on regular channels
            DISCEN: ?u1 = null,
            /// JDISCEN [12:12]
            /// Discontinuous mode on injected channels
            JDISCEN: ?u1 = null,
            /// DISCNUM [13:15]
            /// Discontinuous mode channel count
            DISCNUM: ?u3 = null,
            /// JAWDEN [22:22]
            /// Analog watchdog enable on injected channels
            JAWDEN: ?u1 = null,
            /// AWDEN [23:23]
            /// Analog watchdog enable on regular channels
            AWDEN: ?u1 = null,
            /// CALVOL [25:26]
            /// ADC Calibration voltage selection
            CALVOL: ?u2 = null,
        };

        /// control register 2
        pub const CTLR2 = struct {
            /// ADON [0:0]
            /// A/D converter ON / OFF
            ADON: ?u1 = null,
            /// CONT [1:1]
            /// Continuous conversion
            CONT: ?u1 = null,
            /// CAL [2:2]
            /// A/D calibration
            CAL: ?u1 = null,
            /// RSTCAL [3:3]
            /// Reset calibration
            RSTCAL: ?u1 = null,
            /// DMA [8:8]
            /// Direct memory access mode
            DMA: ?u1 = null,
            /// ALIGN [11:11]
            /// Data alignment
            ALIGN: ?u1 = null,
            /// JEXTSEL [12:14]
            /// External event select for injected group
            JEXTSEL: ?u3 = null,
            /// JEXTTRIG [15:15]
            /// External trigger conversion mode for injected channels
            JEXTTRIG: ?u1 = null,
            /// EXTSEL [17:19]
            /// External event select for regular group
            EXTSEL: ?u3 = null,
            /// EXTTRIG [20:20]
            /// External trigger conversion mode for regular channels
            EXTTRIG: ?u1 = null,
            /// JSWSTART [21:21]
            /// Start conversion of injected channels
            JSWSTART: ?u1 = null,
            /// SWSTART [22:22]
            /// Start conversion of regular channels
            SWSTART: ?u1 = null,
        };

        /// sample time register 1
        pub const SAMPTR1 = struct {
            /// SMP10 [0:2]
            /// Channel 10 sample time selection
            SMP10: ?u3 = null,
            /// SMP11 [3:5]
            /// Channel 11 sample time selection
            SMP11: ?u3 = null,
            /// SMP12_TKCG12 [6:8]
            /// Channel 12 sample time selection
            SMP12_TKCG12: ?u3 = null,
            /// SMP13 [9:11]
            /// Channel 13 sample time selection
            SMP13: ?u3 = null,
            /// SMP14 [12:14]
            /// Channel 14 sample time selection
            SMP14: ?u3 = null,
            /// SMP15 [15:17]
            /// Channel 15 sample time selection
            SMP15: ?u3 = null,
        };

        /// sample time register 2
        pub const SAMPTR2 = struct {
            /// SMP0 [0:2]
            /// Channel 0 sample time selection
            SMP0: ?u3 = null,
            /// SMP1 [3:5]
            /// Channel 1 sample time selection
            SMP1: ?u3 = null,
            /// SMP2 [6:8]
            /// Channel 2 sample time selection
            SMP2: ?u3 = null,
            /// SMP3 [9:11]
            /// Channel 3 sample time selection
            SMP3: ?u3 = null,
            /// SMP4 [12:14]
            /// Channel 4 sample time selection
            SMP4: ?u3 = null,
            /// SMP5 [15:17]
            /// Channel 5 sample time selection
            SMP5: ?u3 = null,
            /// SMP6_TKCG6 [18:20]
            /// Channel 6 sample time selection
            SMP6_TKCG6: ?u3 = null,
            /// SMP7 [21:23]
            /// Channel 7 sample time selection
            SMP7: ?u3 = null,
            /// SMP8 [24:26]
            /// Channel 8 sample time selection
            SMP8: ?u3 = null,
            /// SMP9 [27:29]
            /// Channel 9 sample time selection
            SMP9: ?u3 = null,
        };

        /// injected channel data offset register x
        pub const IOFR1 = struct {
            /// JOFFSET1 [0:9]
            /// Data offset for injected channel x
            JOFFSET1: ?u10 = null,
        };

        /// injected channel data offset register x
        pub const IOFR2 = struct {
            /// JOFFSET2 [0:9]
            /// Data offset for injected channel x
            JOFFSET2: ?u10 = null,
        };

        /// injected channel data offset register x
        pub const IOFR3 = struct {
            /// JOFFSET3 [0:9]
            /// Data offset for injected channel x
            JOFFSET3: ?u10 = null,
        };

        /// injected channel data offset register x
        pub const IOFR4 = struct {
            /// JOFFSET4 [0:9]
            /// Data offset for injected channel x
            JOFFSET4: ?u10 = null,
        };

        /// watchdog higher threshold register
        pub const WDHTR = struct {
            /// HT [0:9]
            /// Analog watchdog higher threshold
            HT: ?u10 = null,
        };

        /// watchdog lower threshold register
        pub const WDLTR = struct {
            /// LT [0:9]
            /// Analog watchdog lower threshold
            LT: ?u10 = null,
        };

        /// regular sequence register 1
        pub const RSQR1 = struct {
            /// SQ13 [0:4]
            /// 13th conversion in regular sequence
            SQ13: ?u5 = null,
            /// SQ14 [5:9]
            /// 14th conversion in regular sequence
            SQ14: ?u5 = null,
            /// SQ15 [10:14]
            /// 15th conversion in regular sequence
            SQ15: ?u5 = null,
            /// SQ16 [15:19]
            /// 16th conversion in regular sequence
            SQ16: ?u5 = null,
            /// L [20:23]
            /// Regular channel sequence length
            L: ?u4 = null,
        };

        /// regular sequence register 2
        pub const RSQR2 = struct {
            /// SQ7 [0:4]
            /// 7th conversion in regular sequence
            SQ7: ?u5 = null,
            /// SQ8 [5:9]
            /// 8th conversion in regular sequence
            SQ8: ?u5 = null,
            /// SQ9 [10:14]
            /// 9th conversion in regular sequence
            SQ9: ?u5 = null,
            /// SQ10 [15:19]
            /// 10th conversion in regular sequence
            SQ10: ?u5 = null,
            /// SQ11 [20:24]
            /// 11th conversion in regular sequence
            SQ11: ?u5 = null,
            /// SQ12 [25:29]
            /// 12th conversion in regular sequence
            SQ12: ?u5 = null,
        };

        /// regular sequence register 3
        pub const RSQR3 = struct {
            /// SQ1 [0:4]
            /// 1st conversion in regular sequence
            SQ1: ?u5 = null,
            /// SQ2 [5:9]
            /// 2nd conversion in regular sequence
            SQ2: ?u5 = null,
            /// SQ3 [10:14]
            /// 3rd conversion in regular sequence
            SQ3: ?u5 = null,
            /// SQ4 [15:19]
            /// 4th conversion in regular sequence
            SQ4: ?u5 = null,
            /// SQ5 [20:24]
            /// 5th conversion in regular sequence
            SQ5: ?u5 = null,
            /// SQ6 [25:29]
            /// 6th conversion in regular sequence
            SQ6: ?u5 = null,
        };

        /// injected sequence register
        pub const ISQR = struct {
            /// JSQ1 [0:4]
            /// 1st conversion in injected sequence
            JSQ1: ?u5 = null,
            /// JSQ2 [5:9]
            /// 2nd conversion in injected sequence
            JSQ2: ?u5 = null,
            /// JSQ3 [10:14]
            /// 3rd conversion in injected sequence
            JSQ3: ?u5 = null,
            /// JSQ4 [15:19]
            /// 4th conversion in injected sequence
            JSQ4: ?u5 = null,
            /// JL [20:21]
            /// Injected sequence length
            JL: ?u2 = null,
        };

        /// injected data register 1
        pub const IDATAR1 = struct {
            /// IDATA [0:15]
            /// Injected data
            IDATA: ?u16 = null,
        };

        /// injected data register 2
        pub const IDATAR2 = struct {
            /// IDATA [0:15]
            /// Injected data
            IDATA: ?u16 = null,
        };

        /// injected data register 3
        pub const IDATAR3 = struct {
            /// IDATA [0:15]
            /// Injected data
            IDATA: ?u16 = null,
        };

        /// injected data register 4
        pub const IDATAR4 = struct {
            /// IDATA [0:15]
            /// Injected data
            IDATA: ?u16 = null,
        };

        /// regular data register
        pub const RDATAR = struct {
            /// DATA [0:31]
            /// Regular data
            DATA: ?u32 = null,
        };

        /// delay data register
        pub const DLYR = struct {
            /// DLYVLU [0:8]
            /// External trigger data delay time configuration
            DLYVLU: ?u9 = null,
            /// DLYSRC [9:9]
            /// External trigger source delay selection
            DLYSRC: ?u1 = null,
        };
    };

    /// Debug support
    pub const DBG = struct {
        /// DBGMCU_CFGR1
        pub const CR = struct {
            /// SLEEP [0:0]
            /// Debug Sleep mode
            SLEEP: ?u1 = null,
            /// STOP [1:1]
            /// Debug stop mode
            STOP: ?u1 = null,
            /// STANDBY [2:2]
            /// Debug standby mode
            STANDBY: ?u1 = null,
            /// IWDG_STOP [8:8]
            /// IWDG_STOP
            IWDG_STOP: ?u1 = null,
            /// WWDG_STOP [9:9]
            /// WWDG_STOP
            WWDG_STOP: ?u1 = null,
            /// TIM1_STOP [12:12]
            /// TIM1_STOP
            TIM1_STOP: ?u1 = null,
            /// TIM2_STOP [13:13]
            /// TIM2_STOP
            TIM2_STOP: ?u1 = null,
        };
    };

    /// Device electronic signature
    pub const ESIG = struct {
        /// Flash capacity register
        pub const FLACAP = struct {
            /// F_SIZE_15_0 [0:15]
            /// Flash size
            F_SIZE_15_0: ?u16 = null,
        };

        /// Unique identity 1
        pub const UNIID1 = struct {
            /// U_ID [0:31]
            /// Unique identity[31:0]
            U_ID: ?u32 = null,
        };

        /// Unique identity 2
        pub const UNIID2 = struct {
            /// U_ID [0:31]
            /// Unique identity[63:32]
            U_ID: ?u32 = null,
        };

        /// Unique identity 3
        pub const UNIID3 = struct {
            /// U_ID [0:31]
            /// Unique identity[95:64]
            U_ID: ?u32 = null,
        };
    };

    /// FLASH
    pub const FLASH = struct {
        /// Flash key register
        pub const ACTLR = struct {
            /// LATENCY [0:1]
            /// Number of FLASH wait states
            LATENCY: ?u2 = null,
        };

        /// Flash key register
        pub const KEYR = struct {
            /// KEYR [0:31]
            /// FPEC key
            KEYR: ?u32 = null,
        };

        /// Flash option key register
        pub const OBKEYR = struct {
            /// OPTKEY [0:31]
            /// Option byte key
            OPTKEY: ?u32 = null,
        };

        /// Status register
        pub const STATR = struct {
            /// BSY [0:0]
            /// Busy
            BSY: ?u1 = null,
            /// WRPRTERR [4:4]
            /// Write protection error
            WRPRTERR: ?u1 = null,
            /// EOP [5:5]
            /// End of operation
            EOP: ?u1 = null,
            /// BOOT_MODE [14:14]
            /// BOOT mode
            BOOT_MODE: ?u1 = null,
            /// BOOT_LOCK [15:15]
            /// BOOT lock
            BOOT_LOCK: ?u1 = null,
        };

        /// Control register
        pub const CTLR = struct {
            /// PG [0:0]
            /// Programming
            PG: ?u1 = null,
            /// PER [1:1]
            /// Page Erase
            PER: ?u1 = null,
            /// MER [2:2]
            /// Mass Erase
            MER: ?u1 = null,
            /// OBPG [4:4]
            /// Option byte programming
            OBPG: ?u1 = null,
            /// OBER [5:5]
            /// Option byte erase
            OBER: ?u1 = null,
            /// STRT [6:6]
            /// Start
            STRT: ?u1 = null,
            /// LOCK [7:7]
            /// Lock
            LOCK: ?u1 = null,
            /// OBWRE [9:9]
            /// Option bytes write enable
            OBWRE: ?u1 = null,
            /// ERRIE [10:10]
            /// Error interrupt enable
            ERRIE: ?u1 = null,
            /// EOPIE [12:12]
            /// End of operation interrupt enable
            EOPIE: ?u1 = null,
            /// FLOCK [15:15]
            /// Fast programmable lock
            FLOCK: ?u1 = null,
            /// FTPG [16:16]
            /// Fast programming
            FTPG: ?u1 = null,
            /// FTER [17:17]
            /// Fast erase
            FTER: ?u1 = null,
            /// BUFLOAD [18:18]
            /// Buffer load
            BUFLOAD: ?u1 = null,
            /// BUFRST [19:19]
            /// Buffer reset
            BUFRST: ?u1 = null,
        };

        /// Flash address register
        pub const ADDR = struct {
            /// FAR [0:31]
            /// Flash Address
            FAR: ?u32 = null,
        };

        /// Option byte register
        pub const OBR = struct {
            /// OBERR [0:0]
            /// Option byte error
            OBERR: ?u1 = null,
            /// RDPRT [1:1]
            /// Read protection
            RDPRT: ?u1 = null,
            /// IWDG_SW [2:2]
            /// IWDG_SW
            IWDG_SW: ?u1 = null,
            /// STANDY_RST [4:4]
            /// STANDY_RST
            STANDY_RST: ?u1 = null,
            /// RST_MODE [5:6]
            /// CFG_RST_MODE
            RST_MODE: ?u2 = null,
            /// STATR_MODE [7:7]
            /// STATR MODE
            STATR_MODE: ?u1 = null,
            /// DATA0 [10:17]
            /// DATA0
            DATA0: ?u8 = null,
            /// DATA1 [18:25]
            /// DATA1
            DATA1: ?u8 = null,
        };

        /// Write protection register
        pub const WPR = struct {
            /// WRP [0:15]
            /// Write protect
            WRP: ?u16 = null,
        };

        /// Mode select register
        pub const MODEKEYR = struct {
            /// MODEKEYR [0:31]
            /// Mode select
            MODEKEYR: ?u32 = null,
        };

        /// Boot mode key register
        pub const BOOT_MODEKEYP = struct {
            /// MODEKEYR [0:31]
            /// Boot mode key
            MODEKEYR: ?u32 = null,
        };
    };

    /// Programmable Fast Interrupt Controller
    pub const PFIC = struct {
        /// Interrupt Status Register
        pub const ISR1 = struct {
            /// INTENSTA2_3 [2:3]
            /// Interrupt ID Status
            INTENSTA2_3: ?u2 = null,
            /// INTENSTA12 [12:12]
            /// Interrupt ID Status
            INTENSTA12: ?u1 = null,
            /// INTENSTA14 [14:14]
            /// Interrupt ID Status
            INTENSTA14: ?u1 = null,
            /// INTENSTA16_31 [16:31]
            /// Interrupt ID Status
            INTENSTA16_31: ?u16 = null,
        };

        /// Interrupt Status Register
        pub const ISR2 = struct {
            /// INTENSTA [0:6]
            /// Interrupt ID Status
            INTENSTA: ?u7 = null,
        };

        /// Interrupt Pending Register
        pub const IPR1 = struct {
            /// PENDSTA2_3 [2:3]
            /// PENDSTA
            PENDSTA2_3: ?u2 = null,
            /// PENDSTA12 [12:12]
            /// PENDSTA
            PENDSTA12: ?u1 = null,
            /// INTENSTA14 [14:14]
            /// PENDSTA
            INTENSTA14: ?u1 = null,
            /// INTENSTA16_31 [16:31]
            /// PENDSTA
            INTENSTA16_31: ?u16 = null,
        };

        /// Interrupt Pending Register
        pub const IPR2 = struct {
            /// PENDSTA32_38 [0:6]
            /// PENDSTA
            PENDSTA32_38: ?u7 = null,
        };

        /// Interrupt Priority Register
        pub const ITHRESDR = struct {
            /// THRESHOLD [0:7]
            /// THRESHOLD
            THRESHOLD: ?u8 = null,
        };

        /// Interrupt Config Register
        pub const CFGR = struct {
            /// RSTSYS [7:7]
            /// RESET System
            RSTSYS: ?u1 = null,
            /// KEYCODE [16:31]
            /// KEYCODE
            KEYCODE: ?u16 = null,
        };

        /// Interrupt Global Register
        pub const GISR = struct {
            /// NESTSTA [0:7]
            /// NESTSTA
            NESTSTA: ?u8 = null,
            /// GACTSTA [8:8]
            /// GACTSTA
            GACTSTA: ?u1 = null,
            /// GPENDSTA [9:9]
            /// GPENDSTA
            GPENDSTA: ?u1 = null,
        };

        /// ID Config Register
        pub const VTFIDR = struct {
            /// VTFID0 [0:7]
            /// VTFID0
            VTFID0: ?u8 = null,
            /// VTFID1 [8:15]
            /// VTFID1
            VTFID1: ?u8 = null,
        };

        /// Interrupt 0 address Register
        pub const VTFADDRR0 = struct {
            /// VTF0EN [0:0]
            /// VTF0EN
            VTF0EN: ?u1 = null,
            /// ADDR0 [1:31]
            /// ADDR0
            ADDR0: ?u31 = null,
        };

        /// Interrupt 1 address Register
        pub const VTFADDRR1 = struct {
            /// VTF1EN [0:0]
            /// VTF1EN
            VTF1EN: ?u1 = null,
            /// ADDR1 [1:31]
            /// ADDR1
            ADDR1: ?u31 = null,
        };

        /// Interrupt Setting Register
        pub const IENR1 = struct {
            /// INTEN12 [12:12]
            /// INTEN12
            INTEN12: ?u1 = null,
            /// INTEN14 [14:14]
            /// INTEN14
            INTEN14: ?u1 = null,
            /// INTEN16_31 [16:31]
            /// INTEN16_31
            INTEN16_31: ?u16 = null,
        };

        /// Interrupt Setting Register
        pub const IENR2 = struct {
            /// INTEN [0:6]
            /// INTEN32_38
            INTEN: ?u7 = null,
        };

        /// Interrupt Clear Register
        pub const IRER1 = struct {
            /// INTRSET12 [12:12]
            /// INTRSET12
            INTRSET12: ?u1 = null,
            /// INTRSET14 [14:14]
            /// INTRSET14
            INTRSET14: ?u1 = null,
            /// INTRSET16_31 [16:31]
            /// INTRSET16_31
            INTRSET16_31: ?u16 = null,
        };

        /// Interrupt Clear Register
        pub const IRER2 = struct {
            /// INTRSET38_32 [0:6]
            /// INTRSET38_32
            INTRSET38_32: ?u7 = null,
        };

        /// Interrupt Pending Register
        pub const IPSR1 = struct {
            /// PENDSET2_3 [2:3]
            /// PENDSET
            PENDSET2_3: ?u2 = null,
            /// PENDSET12 [12:12]
            /// PENDSET
            PENDSET12: ?u1 = null,
            /// PENDSET14 [14:14]
            /// PENDSET
            PENDSET14: ?u1 = null,
            /// PENDSET16_31 [16:31]
            /// PENDSET
            PENDSET16_31: ?u16 = null,
        };

        /// Interrupt Pending Register
        pub const IPSR2 = struct {
            /// PENDSET32_38 [0:6]
            /// PENDSET32_38
            PENDSET32_38: ?u7 = null,
        };

        /// Interrupt Pending Clear Register
        pub const IPRR1 = struct {
            /// PENDRST2_3 [2:3]
            /// PENDRESET
            PENDRST2_3: ?u2 = null,
            /// PENDRST12 [12:12]
            /// PENDRESET
            PENDRST12: ?u1 = null,
            /// PENDRST14 [14:14]
            /// PENDRESET
            PENDRST14: ?u1 = null,
            /// PENDRST16_31 [16:31]
            /// PENDRESET
            PENDRST16_31: ?u16 = null,
        };

        /// Interrupt Pending Clear Register
        pub const IPRR2 = struct {
            /// PENDRST32_38 [0:6]
            /// PENDRESET32_38
            PENDRST32_38: ?u7 = null,
        };

        /// Interrupt ACTIVE Register
        pub const IACTR1 = struct {
            /// IACTS2_3 [2:3]
            /// IACTS
            IACTS2_3: ?u2 = null,
            /// IACTS12 [12:12]
            /// IACTS
            IACTS12: ?u1 = null,
            /// IACTS14 [14:14]
            /// IACTS
            IACTS14: ?u1 = null,
            /// IACTS16_31 [16:31]
            /// IACTS
            IACTS16_31: ?u16 = null,
        };

        /// Interrupt ACTIVE Register
        pub const IACTR2 = struct {
            /// IACTS [0:6]
            /// IACTS
            IACTS: ?u7 = null,
        };

        /// Interrupt Priority Register
        pub const IPRIOR0 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR1 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR2 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR3 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR4 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR5 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR6 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR7 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR8 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR9 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR10 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR11 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR12 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR13 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR14 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR15 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR16 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR17 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR18 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR19 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR20 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR21 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR22 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR23 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR24 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR25 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR26 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR27 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR28 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR29 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR30 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR31 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR32 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR33 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR34 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR35 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR36 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR37 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR38 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR39 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR40 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR41 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR42 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR43 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR44 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR45 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR46 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR47 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR48 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR49 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR50 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR51 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR52 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR53 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR54 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR55 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR56 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR57 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR58 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR59 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR60 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR61 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR62 = struct {};

        /// Interrupt Priority Register
        pub const IPRIOR63 = struct {};

        /// System Control Register
        pub const SCTLR = struct {
            /// SLEEPONEXIT [1:1]
            /// SLEEPONEXIT
            SLEEPONEXIT: ?u1 = null,
            /// SLEEPDEEP [2:2]
            /// SLEEPDEEP
            SLEEPDEEP: ?u1 = null,
            /// WFITOWFE [3:3]
            /// WFITOWFE
            WFITOWFE: ?u1 = null,
            /// SEVONPEND [4:4]
            /// SEVONPEND
            SEVONPEND: ?u1 = null,
            /// SETEVENT [5:5]
            /// SETEVENT
            SETEVENT: ?u1 = null,
            /// SYSRST [31:31]
            /// SYSRESET
            SYSRST: ?u1 = null,
        };

        /// System counter control register
        pub const STK_CTLR = struct {
            /// STE [0:0]
            /// System counter enable
            STE: ?u1 = null,
            /// STIE [1:1]
            /// System counter interrupt enable
            STIE: ?u1 = null,
            /// STCLK [2:2]
            /// System selects the clock source
            STCLK: ?u1 = null,
            /// STRE [3:3]
            /// System reload register
            STRE: ?u1 = null,
            /// MODE [4:4]
            /// System Mode
            MODE: ?u1 = null,
            /// INIT [5:5]
            /// System Initialization update
            INIT: ?u1 = null,
            /// SWIE [31:31]
            /// System software triggered interrupts enable
            SWIE: ?u1 = null,
        };

        /// System START
        pub const STK_SR = struct {
            /// CNTIF [0:0]
            /// CNTIF
            CNTIF: ?u1 = null,
        };

        /// System counter low register
        pub const STK_CNTL = struct {
            /// CNT [0:31]
            /// CNT
            CNT: ?u32 = null,
        };

        /// System compare low register
        pub const STK_CMPLR = struct {
            /// CMP [0:31]
            /// CMP
            CMP: ?u32 = null,
        };
    };
};

pub const interrupts = enum(u32) {
    /// Non-maskable interrupt
    NMI = 2,
    /// Abnormal interruptions
    HardFault = 3,
    /// System timer interrupt
    SysTick = 12,
    /// Software interrupt
    SW = 14,
    /// Window Watchdog interrupt
    WWDG = 16,
    /// PVD through EXTI line detection interrupt
    PVD = 17,
    /// Flash global interrupt
    FLASH = 18,
    /// Reset and clock control interrupt
    RCC = 19,
    /// EXTI Line[7:0] interrupt
    EXTI7_0 = 20,
    /// AWU global interrupt
    AWU = 21,
    /// DMA1 Channel 1 global interrupt
    DMA1_Channel1 = 22,
    /// DMA1 Channel 2 global interrupt
    DMA1_Channel2 = 23,
    /// DMA1 Channel 3 global interrupt
    DMA1_Channel3 = 24,
    /// DMA1 Channel 4 global interrupt
    DMA1_Channel4 = 25,
    /// DMA1 Channel 5 global interrupt
    DMA1_Channel5 = 26,
    /// DMA1 Channel 6 global interrupt
    DMA1_Channel6 = 27,
    /// DMA1 Channel 7 global interrupt
    DMA1_Channel7 = 28,
    /// ADC global interrupt
    ADC = 29,
    /// I2C1 event interrupt
    I2C1_EV = 30,
    /// I2C1 error interrupt
    I2C1_ER = 31,
    /// USART1 global interrupt
    USART1 = 32,
    /// SPI1 global interrupt
    SPI1 = 33,
    /// TIM1 Break interrupt
    TIM1BRK = 34,
    /// TIM1 Update interrupt
    TIM1UP = 35,
    /// TIM1 Trigger and Commutation interrupts
    TIM1RG = 36,
    /// TIM1 Capture Compare interrupt
    TIM1CC = 37,
    /// TIM2 global interrupt
    TIM2 = 38,

    pub const VectorTable = struct {
        const call_conv: @import("std").builtin.CallingConvention = if (@import("builtin").cpu.arch != .riscv32) .c else .{ .riscv32_interrupt = .{ .mode = .machine } };
        const Handler = *const fn () callconv(call_conv) void;

        /// 2: Non-maskable interrupt
        NMI: ?Handler = null,
        /// 3: Abnormal interruptions
        HardFault: ?Handler = null,
        /// 12: System timer interrupt
        SysTick: ?Handler = null,
        /// 14: Software interrupt
        SW: ?Handler = null,
        /// 16: Window Watchdog interrupt
        WWDG: ?Handler = null,
        /// 17: PVD through EXTI line detection interrupt
        PVD: ?Handler = null,
        /// 18: Flash global interrupt
        FLASH: ?Handler = null,
        /// 19: Reset and clock control interrupt
        RCC: ?Handler = null,
        /// 20: EXTI Line[7:0] interrupt
        EXTI7_0: ?Handler = null,
        /// 21: AWU global interrupt
        AWU: ?Handler = null,
        /// 22: DMA1 Channel 1 global interrupt
        DMA1_Channel1: ?Handler = null,
        /// 23: DMA1 Channel 2 global interrupt
        DMA1_Channel2: ?Handler = null,
        /// 24: DMA1 Channel 3 global interrupt
        DMA1_Channel3: ?Handler = null,
        /// 25: DMA1 Channel 4 global interrupt
        DMA1_Channel4: ?Handler = null,
        /// 26: DMA1 Channel 5 global interrupt
        DMA1_Channel5: ?Handler = null,
        /// 27: DMA1 Channel 6 global interrupt
        DMA1_Channel6: ?Handler = null,
        /// 28: DMA1 Channel 7 global interrupt
        DMA1_Channel7: ?Handler = null,
        /// 29: ADC global interrupt
        ADC: ?Handler = null,
        /// 30: I2C1 event interrupt
        I2C1_EV: ?Handler = null,
        /// 31: I2C1 error interrupt
        I2C1_ER: ?Handler = null,
        /// 32: USART1 global interrupt
        USART1: ?Handler = null,
        /// 33: SPI1 global interrupt
        SPI1: ?Handler = null,
        /// 34: TIM1 Break interrupt
        TIM1BRK: ?Handler = null,
        /// 35: TIM1 Update interrupt
        TIM1UP: ?Handler = null,
        /// 36: TIM1 Trigger and Commutation interrupts
        TIM1RG: ?Handler = null,
        /// 37: TIM1 Capture Compare interrupt
        TIM1CC: ?Handler = null,
        /// 38: TIM2 global interrupt
        TIM2: ?Handler = null,
    };
};
