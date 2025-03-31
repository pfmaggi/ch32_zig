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
            const info = @typeInfo(@TypeOf(new_value));
            inline for (info.@"struct".fields) |field| {
                const old_field_value = @field(old_value, field.name);
                const new_field_value = @field(new_value, field.name);
                // Null values don't modify the field.
                const new_field_value_unwrapped = if (new_field_value == null) old_field_value else new_field_value.?;

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

pub const device_name = "CH32V103";
pub const device_revision = "1.1";
pub const device_description = "CH32V103 View File";

pub const peripherals = struct {
    /// Power control
    pub const PWR = types.PWR.from(0x40007000);

    /// Reset and clock control
    pub const RCC = types.RCC.from(0x40021000);

    /// extension configuration
    pub const EXTEND = types.EXTEND.from(0x40023800);

    /// General purpose I/O
    pub const GPIO = enum(u32) {
        GPIOA = 0x40010800,
        GPIOB = 0x40010c00,
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
    pub const GPIOB = GPIO.GPIOB.get();
    /// General purpose I/O
    pub const GPIOC = GPIO.GPIOC.get();
    /// General purpose I/O
    pub const GPIOD = GPIO.GPIOD.get();

    /// Alternate function I/O
    pub const AFIO = types.AFIO.from(0x40010000);

    /// EXTI
    pub const EXTI = types.EXTI.from(0x40010400);

    /// DMA controller
    pub const DMA = types.DMA.from(0x40020000);

    /// Real time clock
    pub const RTC = types.RTC.from(0x40002800);

    /// Backup registers
    pub const BKP = types.BKP.from(0x40006c00);

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
        TIM3 = 0x40000400,
        TIM4 = 0x40000800,

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
    /// General purpose timer
    pub const TIM3 = GeneralPurposeTimer.TIM3.get();
    /// General purpose timer
    pub const TIM4 = GeneralPurposeTimer.TIM4.get();

    /// Inter integrated circuit
    pub const I2C = enum(u32) {
        I2C1 = 0x40005400,
        I2C2 = 0x40005800,

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
    /// Inter integrated circuit
    pub const I2C2 = I2C.I2C2.get();

    /// Serial peripheral interface
    pub const SPI = enum(u32) {
        SPI1 = 0x40013000,
        SPI2 = 0x40003800,

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
    /// Serial peripheral interface
    pub const SPI2 = SPI.SPI2.get();

    /// Universal synchronous asynchronous receiver transmitter
    pub const USART = enum(u32) {
        USART1 = 0x40013800,
        USART2 = 0x40004400,
        USART3 = 0x40004800,

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
    /// Universal synchronous asynchronous receiver transmitter
    pub const USART2 = USART.USART2.get();
    /// Universal synchronous asynchronous receiver transmitter
    pub const USART3 = USART.USART3.get();

    /// Analog to digital converter
    pub const ADC = types.ADC.from(0x40012400);

    /// Digital to analog converter
    pub const DAC1 = types.DAC1.from(0x40007400);

    /// Debug support
    pub const DBG = types.DBG.from(0xe000d000);

    /// USB register
    pub const USBFS = types.USBFS.from(0x40023400);

    /// CRC calculation unit
    pub const CRC = types.CRC.from(0x40023000);

    /// FLASH
    pub const FLASH = types.FLASH.from(0x40022000);

    /// Programmable Fast Interrupt Controller
    pub const PFIC = types.PFIC.from(0xe000e000);

    /// Universal serial bus full-speed device interface
    pub const USBD = types.USBD.from(0x40005c00);

    /// Device electronic signature
    pub const ESIG = types.ESIG.from(0x1ffff7e0);
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
            /// LPDS [0:0]
            /// Low Power Deep Sleep
            LPDS: u1 = 0,
            /// PDDS [1:1]
            /// Power Down Deep Sleep
            PDDS: u1 = 0,
            /// CWUF [2:2]
            /// Clear Wake-up Flag
            CWUF: u1 = 0,
            /// CSBF [3:3]
            /// Clear STANDBY Flag
            CSBF: u1 = 0,
            /// PVDE [4:4]
            /// Power Voltage Detector Enable
            PVDE: u1 = 0,
            /// PLS [5:7]
            /// PVD Level Selection
            PLS: u3 = 0,
            /// DBP [8:8]
            /// Disable Backup Domain write protection
            DBP: u1 = 0,
            /// padding [9:31]
            _padding: u23 = 0,
        }, nullable_types.PWR.CTLR),

        /// Power control register (PWR_CSR)
        CSR: RegisterRW(packed struct(u32) {
            /// WUF [0:0]
            /// Wake-Up Flag
            WUF: u1 = 0,
            /// SBF [1:1]
            /// STANDBY Flag
            SBF: u1 = 0,
            /// PVDO [2:2]
            /// PVD Output
            PVDO: u1 = 0,
            /// unused [3:7]
            _unused3: u5 = 0,
            /// EWUP [8:8]
            /// Enable WKUP pin
            EWUP: u1 = 0,
            /// padding [9:31]
            _padding: u23 = 0,
        }, nullable_types.PWR.CSR),
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

        /// Clock configuration register(RCC_CFGR0)
        CFGR0: RegisterRW(packed struct(u32) {
            /// SW [0:1]
            /// System clock Switch
            SW: u2 = 0,
            /// SWS [2:3]
            /// System Clock Switch Status
            SWS: u2 = 0,
            /// HPRE [4:7]
            /// HB prescaler
            HPRE: u4 = 0,
            /// PPRE1 [8:10]
            /// PB Low speed prescaler(APB1)
            PPRE1: u3 = 0,
            /// PPRE2 [11:13]
            /// PB High speed prescaler(APB2)
            PPRE2: u3 = 0,
            /// ADCPRE [14:15]
            /// ADC prescaler
            ADCPRE: u2 = 0,
            /// PLLSRC [16:16]
            /// PLL entry clock source
            PLLSRC: u1 = 0,
            /// PLLXTPRE [17:17]
            /// HSE divider for PLL entry
            PLLXTPRE: u1 = 0,
            /// PLLMUL [18:21]
            /// PLL Multiplication Factor
            PLLMUL: u4 = 0,
            /// USBPRE [22:22]
            /// USB prescaler
            USBPRE: u1 = 0,
            /// unused [23:23]
            _unused23: u1 = 0,
            /// MCO [24:26]
            /// Microcontroller clock output
            MCO: u3 = 0,
            /// padding [27:31]
            _padding: u5 = 0,
        }, nullable_types.RCC.CFGR0),

        /// Clock interrupt register(RCC_INTR)
        INTR: RegisterRW(packed struct(u32) {
            /// LSIRDYF [0:0]
            /// LSI Ready Interrupt flag
            LSIRDYF: u1 = 0,
            /// LSERDYF [1:1]
            /// LSE Ready Interrupt flag
            LSERDYF: u1 = 0,
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
            /// LSERDYIE [9:9]
            /// LSE Ready Interrupt Enable
            LSERDYIE: u1 = 0,
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
            /// LSERDYC [17:17]
            /// LSE Ready Interrupt Clear
            LSERDYC: u1 = 0,
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

        /// PB2 peripheral reset register(RCC_APB2PRSTR)
        APB2PRSTR: RegisterRW(packed struct(u32) {
            /// AFIORST [0:0]
            /// Alternate function I/O reset
            AFIORST: u1 = 0,
            /// unused [1:1]
            _unused1: u1 = 0,
            /// IOPARST [2:2]
            /// IO port A reset
            IOPARST: u1 = 0,
            /// IOPBRST [3:3]
            /// IO port B reset
            IOPBRST: u1 = 0,
            /// IOPCRST [4:4]
            /// IO port C reset
            IOPCRST: u1 = 0,
            /// IOPDRST [5:5]
            /// IO port D reset
            IOPDRST: u1 = 0,
            /// unused [6:8]
            _unused6: u2 = 0,
            _unused8: u1 = 0,
            /// ADCRST [9:9]
            /// ADC interface reset
            ADCRST: u1 = 0,
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

        /// PB1 peripheral reset register(RCC_APB1PRSTR)
        APB1PRSTR: RegisterRW(packed struct(u32) {
            /// TIM2RST [0:0]
            /// Timer 2 reset
            TIM2RST: u1 = 0,
            /// TIM3RST [1:1]
            /// Timer 3 reset
            TIM3RST: u1 = 0,
            /// TIM4RST [2:2]
            /// Timer 4 reset
            TIM4RST: u1 = 0,
            /// unused [3:10]
            _unused3: u5 = 0,
            _unused8: u3 = 0,
            /// WWDGRST [11:11]
            /// Window watchdog reset
            WWDGRST: u1 = 0,
            /// unused [12:13]
            _unused12: u2 = 0,
            /// SPI2RST [14:14]
            /// SPI2 reset
            SPI2RST: u1 = 0,
            /// unused [15:16]
            _unused15: u1 = 0,
            _unused16: u1 = 0,
            /// USART2RST [17:17]
            /// USART 2 reset
            USART2RST: u1 = 0,
            /// USART3RST [18:18]
            /// USART 3 reset
            USART3RST: u1 = 0,
            /// unused [19:20]
            _unused19: u2 = 0,
            /// I2C1RST [21:21]
            /// I2C1 reset
            I2C1RST: u1 = 0,
            /// I2C2RST [22:22]
            /// I2C2 reset
            I2C2RST: u1 = 0,
            /// USBDRST [23:23]
            /// USBD reset
            USBDRST: u1 = 0,
            /// unused [24:24]
            _unused24: u1 = 0,
            /// CANRST [25:25]
            /// CAN reset
            CANRST: u1 = 0,
            /// unused [26:26]
            _unused26: u1 = 0,
            /// BKPRST [27:27]
            /// Backup interface reset
            BKPRST: u1 = 0,
            /// PWRRST [28:28]
            /// Power interface reset
            PWRRST: u1 = 0,
            /// DACRST [29:29]
            /// DAC interface reset
            DACRST: u1 = 0,
            /// padding [30:31]
            _padding: u2 = 0,
        }, nullable_types.RCC.APB1PRSTR),

        /// HB Peripheral Clock enable register(RCC_AHBPCENR)
        AHBPCENR: RegisterRW(packed struct(u32) {
            /// DMAEN [0:0]
            /// DMA clock enable
            DMAEN: u1 = 0,
            /// unused [1:1]
            _unused1: u1 = 0,
            /// SRAMEN [2:2]
            /// SRAM interface clock enable
            SRAMEN: u1 = 1,
            /// unused [3:3]
            _unused3: u1 = 0,
            /// FLITFEN [4:4]
            /// FLITF clock enable
            FLITFEN: u1 = 1,
            /// unused [5:5]
            _unused5: u1 = 0,
            /// CRCEN [6:6]
            /// CRC clock enable
            CRCEN: u1 = 0,
            /// unused [7:11]
            _unused7: u1 = 0,
            _unused8: u4 = 0,
            /// USBHDEN [12:12]
            /// USBHD clock enable
            USBHDEN: u1 = 0,
            /// padding [13:31]
            _padding: u19 = 0,
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
            /// IOPBEN [3:3]
            /// I/O port B clock enable
            IOPBEN: u1 = 0,
            /// IOPCEN [4:4]
            /// I/O port C clock enable
            IOPCEN: u1 = 0,
            /// IOPDEN [5:5]
            /// I/O port D clock enable
            IOPDEN: u1 = 0,
            /// unused [6:8]
            _unused6: u2 = 0,
            _unused8: u1 = 0,
            /// ADCEN [9:9]
            /// ADC interface clock enable
            ADCEN: u1 = 0,
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
            /// TIM3EN [1:1]
            /// Timer 3 clock enable
            TIM3EN: u1 = 0,
            /// TIM4EN [2:2]
            /// Timer 4 clock enable
            TIM4EN: u1 = 0,
            /// unused [3:10]
            _unused3: u5 = 0,
            _unused8: u3 = 0,
            /// WWDGEN [11:11]
            /// Window watchdog clock enable
            WWDGEN: u1 = 0,
            /// unused [12:13]
            _unused12: u2 = 0,
            /// SPI2EN [14:14]
            /// SPI 2 clock enable
            SPI2EN: u1 = 0,
            /// unused [15:16]
            _unused15: u1 = 0,
            _unused16: u1 = 0,
            /// USART2EN [17:17]
            /// USART 2 clock enable
            USART2EN: u1 = 0,
            /// USART3EN [18:18]
            /// USART 3 clock enable
            USART3EN: u1 = 0,
            /// unused [19:20]
            _unused19: u2 = 0,
            /// I2C1EN [21:21]
            /// I2C 1 clock enable
            I2C1EN: u1 = 0,
            /// I2C2EN [22:22]
            /// I2C 2 clock enable
            I2C2EN: u1 = 0,
            /// USBDEN [23:23]
            /// USBD clock enable
            USBDEN: u1 = 0,
            /// unused [24:24]
            _unused24: u1 = 0,
            /// CANEN [25:25]
            /// CAN clock enable
            CANEN: u1 = 0,
            /// unused [26:26]
            _unused26: u1 = 0,
            /// BKPEN [27:27]
            /// Backup interface clock enable
            BKPEN: u1 = 0,
            /// PWREN [28:28]
            /// Power interface clock enable
            PWREN: u1 = 0,
            /// DACEN [29:29]
            /// DAC interface clock enable
            DACEN: u1 = 0,
            /// padding [30:31]
            _padding: u2 = 0,
        }, nullable_types.RCC.APB1PCENR),

        /// Backup domain control register(RCC_BDCTLR)
        BDCTLR: RegisterRW(packed struct(u32) {
            /// LSEON [0:0]
            /// External Low Speed oscillator enable
            LSEON: u1 = 0,
            /// LSERDY [1:1]
            /// External Low Speed oscillator ready
            LSERDY: u1 = 0,
            /// LSEBYP [2:2]
            /// External Low Speed oscillator bypass
            LSEBYP: u1 = 0,
            /// unused [3:7]
            _unused3: u5 = 0,
            /// RTCSEL [8:9]
            /// RTC clock source selection
            RTCSEL: u2 = 0,
            /// unused [10:14]
            _unused10: u5 = 0,
            /// RTCEN [15:15]
            /// RTC clock enable
            RTCEN: u1 = 0,
            /// BDRST [16:16]
            /// Backup domain software reset
            BDRST: u1 = 0,
            /// padding [17:31]
            _padding: u15 = 0,
        }, nullable_types.RCC.BDCTLR),

        /// Control/status register(RCC_RSTSCKR)
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

        /// HB reset register(RCC_APHBRSTR)
        AHBRSTR: RegisterRW(packed struct(u32) {
            /// unused [0:11]
            _unused0: u8 = 0,
            _unused8: u4 = 0,
            /// USBHDRST [12:12]
            /// USBHD reset
            USBHDRST: u1 = 0,
            /// padding [13:31]
            _padding: u19 = 0,
        }, nullable_types.RCC.AHBRSTR),
    };

    /// extension configuration
    pub const EXTEND = extern struct {
        pub inline fn from(base: u32) *volatile types.EXTEND {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.EXTEND) u32 {
            return @intFromPtr(self);
        }

        /// EXTEND register
        EXTEND_CTR: RegisterRW(packed struct(u32) {
            /// USBDLS [0:0]
            /// USBD Lowspeed Enable
            USBDLS: u1 = 0,
            /// USBDPU [1:1]
            /// USBD pullup Enable
            USBDPU: u1 = 0,
            /// USBHDIO [2:2]
            /// USBHD IO(PB6/PB7) Enable
            USBHDIO: u1 = 0,
            /// USB5VSEL [3:3]
            /// USB 5V Enable
            USB5VSEL: u1 = 0,
            /// HSIPRE [4:4]
            /// Whether HSI is divided
            HSIPRE: u1 = 0,
            /// unused [5:5]
            _unused5: u1 = 0,
            /// LKUPEN [6:6]
            /// LOCKUP
            LKUPEN: u1 = 0,
            /// LKUPRST [7:7]
            /// LOCKUP RESET
            LKUPRST: u1 = 0,
            /// ULLDOTRIM [8:9]
            /// ULLDOTRIM
            ULLDOTRIM: u2 = 2,
            /// LDOTRIM [10:10]
            /// LDOTRIM
            LDOTRIM: u1 = 0,
            /// padding [11:31]
            _padding: u21 = 0,
        }, nullable_types.EXTEND.EXTEND_CTR),
    };

    /// General purpose I/O
    /// Type for: GPIOA GPIOB GPIOC GPIOD
    pub const GPIO = extern struct {
        pub const GPIOA = types.GPIO.from(0x40010800);
        pub const GPIOB = types.GPIO.from(0x40010c00);
        pub const GPIOC = types.GPIO.from(0x40011000);
        pub const GPIOD = types.GPIO.from(0x40011400);

        pub inline fn from(base: u32) *volatile types.GPIO {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.GPIO) u32 {
            return @intFromPtr(self);
        }

        /// Port configuration register low(GPIOn_CFGLR)
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

        /// Port configuration register high (GPIOn_CFGHR)
        CFGHR: RegisterRW(packed struct(u32) {
            /// MODE8 [0:1]
            /// Port n.8 mode bits
            MODE8: u2 = 0,
            /// CNF8 [2:3]
            /// Port n.8 configuration bits
            CNF8: u2 = 1,
            /// MODE9 [4:5]
            /// Port n.9 mode bits
            MODE9: u2 = 0,
            /// CNF9 [6:7]
            /// Port n.9 configuration bits
            CNF9: u2 = 1,
            /// MODE10 [8:9]
            /// Port n.10 mode bits
            MODE10: u2 = 0,
            /// CNF10 [10:11]
            /// Port n.10 configuration bits
            CNF10: u2 = 1,
            /// MODE11 [12:13]
            /// Port n.11 mode bits
            MODE11: u2 = 0,
            /// CNF11 [14:15]
            /// Port n.11 configuration bits
            CNF11: u2 = 1,
            /// MODE12 [16:17]
            /// Port n.12 mode bits
            MODE12: u2 = 0,
            /// CNF12 [18:19]
            /// Port n.12 configuration bits
            CNF12: u2 = 1,
            /// MODE13 [20:21]
            /// Port n.13 mode bits
            MODE13: u2 = 0,
            /// CNF13 [22:23]
            /// Port n.13 configuration bits
            CNF13: u2 = 1,
            /// MODE14 [24:25]
            /// Port n.14 mode bits
            MODE14: u2 = 0,
            /// CNF14 [26:27]
            /// Port n.14 configuration bits
            CNF14: u2 = 1,
            /// MODE15 [28:29]
            /// Port n.15 mode bits
            MODE15: u2 = 0,
            /// CNF15 [30:31]
            /// Port n.15 configuration bits
            CNF15: u2 = 1,
        }, nullable_types.GPIO.CFGHR),

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
            /// IDR8 [8:8]
            /// Port input data
            IDR8: u1 = 0,
            /// IDR9 [9:9]
            /// Port input data
            IDR9: u1 = 0,
            /// IDR10 [10:10]
            /// Port input data
            IDR10: u1 = 0,
            /// IDR11 [11:11]
            /// Port input data
            IDR11: u1 = 0,
            /// IDR12 [12:12]
            /// Port input data
            IDR12: u1 = 0,
            /// IDR13 [13:13]
            /// Port input data
            IDR13: u1 = 0,
            /// IDR14 [14:14]
            /// Port input data
            IDR14: u1 = 0,
            /// IDR15 [15:15]
            /// Port input data
            IDR15: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
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
            /// ODR8 [8:8]
            /// Port output data
            ODR8: u1 = 0,
            /// ODR9 [9:9]
            /// Port output data
            ODR9: u1 = 0,
            /// ODR10 [10:10]
            /// Port output data
            ODR10: u1 = 0,
            /// ODR11 [11:11]
            /// Port output data
            ODR11: u1 = 0,
            /// ODR12 [12:12]
            /// Port output data
            ODR12: u1 = 0,
            /// ODR13 [13:13]
            /// Port output data
            ODR13: u1 = 0,
            /// ODR14 [14:14]
            /// Port output data
            ODR14: u1 = 0,
            /// ODR15 [15:15]
            /// Port output data
            ODR15: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
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
            /// BS8 [8:8]
            /// Set bit 8
            BS8: u1 = 0,
            /// BS9 [9:9]
            /// Set bit 9
            BS9: u1 = 0,
            /// BS10 [10:10]
            /// Set bit 10
            BS10: u1 = 0,
            /// BS11 [11:11]
            /// Set bit 11
            BS11: u1 = 0,
            /// BS12 [12:12]
            /// Set bit 12
            BS12: u1 = 0,
            /// BS13 [13:13]
            /// Set bit 13
            BS13: u1 = 0,
            /// BS14 [14:14]
            /// Set bit 14
            BS14: u1 = 0,
            /// BS15 [15:15]
            /// Set bit 15
            BS15: u1 = 0,
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
            /// BR8 [24:24]
            /// Reset bit 8
            BR8: u1 = 0,
            /// BR9 [25:25]
            /// Reset bit 9
            BR9: u1 = 0,
            /// BR10 [26:26]
            /// Reset bit 10
            BR10: u1 = 0,
            /// BR11 [27:27]
            /// Reset bit 11
            BR11: u1 = 0,
            /// BR12 [28:28]
            /// Reset bit 12
            BR12: u1 = 0,
            /// BR13 [29:29]
            /// Reset bit 13
            BR13: u1 = 0,
            /// BR14 [30:30]
            /// Reset bit 14
            BR14: u1 = 0,
            /// BR15 [31:31]
            /// Reset bit 15
            BR15: u1 = 0,
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
            /// BR8 [8:8]
            /// Reset bit 8
            BR8: u1 = 0,
            /// BR9 [9:9]
            /// Reset bit 9
            BR9: u1 = 0,
            /// BR10 [10:10]
            /// Reset bit 10
            BR10: u1 = 0,
            /// BR11 [11:11]
            /// Reset bit 11
            BR11: u1 = 0,
            /// BR12 [12:12]
            /// Reset bit 12
            BR12: u1 = 0,
            /// BR13 [13:13]
            /// Reset bit 13
            BR13: u1 = 0,
            /// BR14 [14:14]
            /// Reset bit 14
            BR14: u1 = 0,
            /// BR15 [15:15]
            /// Reset bit 15
            BR15: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
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
            /// LCK8 [8:8]
            /// Port A Lock bit 8
            LCK8: u1 = 0,
            /// LCK9 [9:9]
            /// Port A Lock bit 9
            LCK9: u1 = 0,
            /// LCK10 [10:10]
            /// Port A Lock bit 10
            LCK10: u1 = 0,
            /// LCK11 [11:11]
            /// Port A Lock bit 11
            LCK11: u1 = 0,
            /// LCK12 [12:12]
            /// Port A Lock bit 12
            LCK12: u1 = 0,
            /// LCK13 [13:13]
            /// Port A Lock bit 13
            LCK13: u1 = 0,
            /// LCK14 [14:14]
            /// Port A Lock bit 14
            LCK14: u1 = 0,
            /// LCK15 [15:15]
            /// Port A Lock bit 15
            LCK15: u1 = 0,
            /// LCKK [16:16]
            /// Lock key
            LCKK: u1 = 0,
            /// padding [17:31]
            _padding: u15 = 0,
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

        /// Event Control Register (AFIO_ECR)
        ECR: RegisterRW(packed struct(u32) {
            /// PIN [0:3]
            /// Pin selection
            PIN: u4 = 0,
            /// PORT [4:6]
            /// Port selection
            PORT: u3 = 0,
            /// EVOE [7:7]
            /// Event Output Enable
            EVOE: u1 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }, nullable_types.AFIO.ECR),

        /// AF remap and debug I/O configuration register (AFIO_PCFR)
        PCFR: RegisterRW(packed struct(u32) {
            /// SPI1_RM [0:0]
            /// SPI1 remapping
            SPI1_RM: u1 = 0,
            /// I2C1_RM [1:1]
            /// I2C1 remapping
            I2C1_RM: u1 = 0,
            /// USART1_RM [2:2]
            /// USART1 remapping
            USART1_RM: u1 = 0,
            /// USART2_RM [3:3]
            /// USART2 remapping
            USART2_RM: u1 = 0,
            /// USART3_RM [4:5]
            /// USART3 remapping
            USART3_RM: u2 = 0,
            /// TIM1_RM [6:7]
            /// TIM1 remapping
            TIM1_RM: u2 = 0,
            /// TIM2_RM [8:9]
            /// TIM2 remapping
            TIM2_RM: u2 = 0,
            /// TIM3_RM [10:11]
            /// TIM3 remapping
            TIM3_RM: u2 = 0,
            /// unused [12:12]
            _unused12: u1 = 0,
            /// CAN_RM [13:14]
            /// CAN1 remapping
            CAN_RM: u2 = 0,
            /// PD01_RM [15:15]
            /// Port D0/Port D1 mapping on OSCIN/OSCOUT
            PD01_RM: u1 = 0,
            /// unused [16:23]
            _unused16: u8 = 0,
            /// SWCFG [24:26]
            /// Serial wire JTAG configuration
            SWCFG: u3 = 0,
            /// padding [27:31]
            _padding: u5 = 0,
        }, nullable_types.AFIO.PCFR),

        /// External interrupt configuration register 1 (AFIO_EXTICR1)
        EXTICR1: RegisterRW(packed struct(u32) {
            /// EXTI0 [0:3]
            /// EXTI0 configuration
            EXTI0: u4 = 0,
            /// EXTI1 [4:7]
            /// EXTI1 configuration
            EXTI1: u4 = 0,
            /// EXTI2 [8:11]
            /// EXTI2 configuration
            EXTI2: u4 = 0,
            /// EXTI3 [12:15]
            /// EXTI3 configuration
            EXTI3: u4 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AFIO.EXTICR1),

        /// External interrupt configuration register 2 (AFIO_EXTICR2)
        EXTICR2: RegisterRW(packed struct(u32) {
            /// EXTI4 [0:3]
            /// EXTI4 configuration
            EXTI4: u4 = 0,
            /// EXTI5 [4:7]
            /// EXTI5 configuration
            EXTI5: u4 = 0,
            /// EXTI6 [8:11]
            /// EXTI6 configuration
            EXTI6: u4 = 0,
            /// EXTI7 [12:15]
            /// EXTI7 configuration
            EXTI7: u4 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AFIO.EXTICR2),

        /// External interrupt configuration register 3 (AFIO_EXTICR3)
        EXTICR3: RegisterRW(packed struct(u32) {
            /// EXTI8 [0:3]
            /// EXTI8 configuration
            EXTI8: u4 = 0,
            /// EXTI9 [4:7]
            /// EXTI9 configuration
            EXTI9: u4 = 0,
            /// EXTI10 [8:11]
            /// EXTI10 configuration
            EXTI10: u4 = 0,
            /// EXTI11 [12:15]
            /// EXTI11 configuration
            EXTI11: u4 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AFIO.EXTICR3),

        /// External interrupt configuration register 4 (AFIO_EXTICR4)
        EXTICR4: RegisterRW(packed struct(u32) {
            /// EXTI12 [0:3]
            /// EXTI12 configuration
            EXTI12: u4 = 0,
            /// EXTI13 [4:7]
            /// EXTI13 configuration
            EXTI13: u4 = 0,
            /// EXTI14 [8:11]
            /// EXTI14 configuration
            EXTI14: u4 = 0,
            /// EXTI15 [12:15]
            /// EXTI15 configuration
            EXTI15: u4 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AFIO.EXTICR4),
    };

    /// EXTI
    pub const EXTI = extern struct {
        pub inline fn from(base: u32) *volatile types.EXTI {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.EXTI) u32 {
            return @intFromPtr(self);
        }

        /// Interrupt mask register(EXTI_INTENR)
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
            /// MR10 [10:10]
            /// Interrupt Mask on line 10
            MR10: u1 = 0,
            /// MR11 [11:11]
            /// Interrupt Mask on line 11
            MR11: u1 = 0,
            /// MR12 [12:12]
            /// Interrupt Mask on line 12
            MR12: u1 = 0,
            /// MR13 [13:13]
            /// Interrupt Mask on line 13
            MR13: u1 = 0,
            /// MR14 [14:14]
            /// Interrupt Mask on line 14
            MR14: u1 = 0,
            /// MR15 [15:15]
            /// Interrupt Mask on line 15
            MR15: u1 = 0,
            /// MR16 [16:16]
            /// Interrupt Mask on line 16
            MR16: u1 = 0,
            /// MR17 [17:17]
            /// Interrupt Mask on line 17
            MR17: u1 = 0,
            /// MR18 [18:18]
            /// Interrupt Mask on line 18
            MR18: u1 = 0,
            /// padding [19:31]
            _padding: u13 = 0,
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
            /// MR10 [10:10]
            /// Event Mask on line 10
            MR10: u1 = 0,
            /// MR11 [11:11]
            /// Event Mask on line 11
            MR11: u1 = 0,
            /// MR12 [12:12]
            /// Event Mask on line 12
            MR12: u1 = 0,
            /// MR13 [13:13]
            /// Event Mask on line 13
            MR13: u1 = 0,
            /// MR14 [14:14]
            /// Event Mask on line 14
            MR14: u1 = 0,
            /// MR15 [15:15]
            /// Event Mask on line 15
            MR15: u1 = 0,
            /// MR16 [16:16]
            /// Event Mask on line 16
            MR16: u1 = 0,
            /// MR17 [17:17]
            /// Event Mask on line 17
            MR17: u1 = 0,
            /// MR18 [18:18]
            /// Event Mask on line 18
            MR18: u1 = 0,
            /// padding [19:31]
            _padding: u13 = 0,
        }, nullable_types.EXTI.EVENR),

        /// Rising Trigger selection register(EXTI_RTENR)
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
            /// TR10 [10:10]
            /// Rising trigger event configuration of line 10
            TR10: u1 = 0,
            /// TR11 [11:11]
            /// Rising trigger event configuration of line 11
            TR11: u1 = 0,
            /// TR12 [12:12]
            /// Rising trigger event configuration of line 12
            TR12: u1 = 0,
            /// TR13 [13:13]
            /// Rising trigger event configuration of line 13
            TR13: u1 = 0,
            /// TR14 [14:14]
            /// Rising trigger event configuration of line 14
            TR14: u1 = 0,
            /// TR15 [15:15]
            /// Rising trigger event configuration of line 15
            TR15: u1 = 0,
            /// TR16 [16:16]
            /// Rising trigger event configuration of line 16
            TR16: u1 = 0,
            /// TR17 [17:17]
            /// Rising trigger event configuration of line 17
            TR17: u1 = 0,
            /// TR18 [18:18]
            /// Rising trigger event configuration of line 18
            TR18: u1 = 0,
            /// padding [19:31]
            _padding: u13 = 0,
        }, nullable_types.EXTI.RTENR),

        /// Falling Trigger selection register(EXTI_FTENR)
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
            /// TR10 [10:10]
            /// Falling trigger event configuration of line 10
            TR10: u1 = 0,
            /// TR11 [11:11]
            /// Falling trigger event configuration of line 11
            TR11: u1 = 0,
            /// TR12 [12:12]
            /// Falling trigger event configuration of line 12
            TR12: u1 = 0,
            /// TR13 [13:13]
            /// Falling trigger event configuration of line 13
            TR13: u1 = 0,
            /// TR14 [14:14]
            /// Falling trigger event configuration of line 14
            TR14: u1 = 0,
            /// TR15 [15:15]
            /// Falling trigger event configuration of line 15
            TR15: u1 = 0,
            /// TR16 [16:16]
            /// Falling trigger event configuration of line 16
            TR16: u1 = 0,
            /// TR17 [17:17]
            /// Falling trigger event configuration of line 17
            TR17: u1 = 0,
            /// TR18 [18:18]
            /// Falling trigger event configuration of line 18
            TR18: u1 = 0,
            /// padding [19:31]
            _padding: u13 = 0,
        }, nullable_types.EXTI.FTENR),

        /// Software interrupt event register(EXTI_SWIEVR)
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
            /// SWIER10 [10:10]
            /// Software Interrupt on line 10
            SWIER10: u1 = 0,
            /// SWIER11 [11:11]
            /// Software Interrupt on line 11
            SWIER11: u1 = 0,
            /// SWIER12 [12:12]
            /// Software Interrupt on line 12
            SWIER12: u1 = 0,
            /// SWIER13 [13:13]
            /// Software Interrupt on line 13
            SWIER13: u1 = 0,
            /// SWIER14 [14:14]
            /// Software Interrupt on line 14
            SWIER14: u1 = 0,
            /// SWIER15 [15:15]
            /// Software Interrupt on line 15
            SWIER15: u1 = 0,
            /// SWIER16 [16:16]
            /// Software Interrupt on line 16
            SWIER16: u1 = 0,
            /// SWIER17 [17:17]
            /// Software Interrupt on line 17
            SWIER17: u1 = 0,
            /// SWIER18 [18:18]
            /// Software Interrupt on line 18
            SWIER18: u1 = 0,
            /// padding [19:31]
            _padding: u13 = 0,
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
            /// IF10 [10:10]
            /// Pending bit 10
            IF10: u1 = 0,
            /// IF11 [11:11]
            /// Pending bit 11
            IF11: u1 = 0,
            /// IF12 [12:12]
            /// Pending bit 12
            IF12: u1 = 0,
            /// IF13 [13:13]
            /// Pending bit 13
            IF13: u1 = 0,
            /// IF14 [14:14]
            /// Pending bit 14
            IF14: u1 = 0,
            /// IF15 [15:15]
            /// Pending bit 15
            IF15: u1 = 0,
            /// IF16 [16:16]
            /// Pending bit 16
            IF16: u1 = 0,
            /// IF17 [17:17]
            /// Pending bit 17
            IF17: u1 = 0,
            /// IF18 [18:18]
            /// Pending bit 18
            IF18: u1 = 0,
            /// padding [19:31]
            _padding: u13 = 0,
        }, nullable_types.EXTI.INTFR),
    };

    /// DMA controller
    pub const DMA = extern struct {
        pub inline fn from(base: u32) *volatile types.DMA {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.DMA) u32 {
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
        }, nullable_types.DMA.INTFR),

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
        }, nullable_types.DMA.INTFCR),

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
        }, nullable_types.DMA.CFGR1),

        /// DMA channel 1 number of data register
        CNTR1: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.DMA.CNTR1),

        /// DMA channel 1 peripheral address register
        PADDR1: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }, nullable_types.DMA.PADDR1),

        /// DMA channel 1 memory address register
        MADDR1: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }, nullable_types.DMA.MADDR1),

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
        }, nullable_types.DMA.CFGR2),

        /// DMA channel 2 number of data register
        CNTR2: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.DMA.CNTR2),

        /// DMA channel 2 peripheral address register
        PADDR2: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }, nullable_types.DMA.PADDR2),

        /// DMA channel 2 memory address register
        MADDR2: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }, nullable_types.DMA.MADDR2),

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
        }, nullable_types.DMA.CFGR3),

        /// DMA channel 3 number of data register
        CNTR3: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.DMA.CNTR3),

        /// DMA channel 3 peripheral address register
        PADDR3: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }, nullable_types.DMA.PADDR3),

        /// DMA channel 3 memory address register
        MADDR3: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }, nullable_types.DMA.MADDR3),

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
        }, nullable_types.DMA.CFGR4),

        /// DMA channel 4 number of data register
        CNTR4: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.DMA.CNTR4),

        /// DMA channel 4 peripheral address register
        PADDR4: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }, nullable_types.DMA.PADDR4),

        /// DMA channel 4 memory address register
        MADDR4: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }, nullable_types.DMA.MADDR4),

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
        }, nullable_types.DMA.CFGR5),

        /// DMA channel 5 number of data register
        CNTR5: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.DMA.CNTR5),

        /// DMA channel 5 peripheral address register
        PADDR5: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }, nullable_types.DMA.PADDR5),

        /// DMA channel 5 memory address register
        MADDR5: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }, nullable_types.DMA.MADDR5),

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
        }, nullable_types.DMA.CFGR6),

        /// DMA channel 6 number of data register
        CNTR6: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.DMA.CNTR6),

        /// DMA channel 6 peripheral address register
        PADDR6: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }, nullable_types.DMA.PADDR6),

        /// DMA channel 6 memory address register
        MADDR6: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }, nullable_types.DMA.MADDR6),

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
        }, nullable_types.DMA.CFGR7),

        /// DMA channel 7 number of data register
        CNTR7: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.DMA.CNTR7),

        /// DMA channel 7 peripheral address register
        PADDR7: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }, nullable_types.DMA.PADDR7),

        /// DMA channel 7 memory address register
        MADDR7: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }, nullable_types.DMA.MADDR7),
    };

    /// Real time clock
    pub const RTC = extern struct {
        pub inline fn from(base: u32) *volatile types.RTC {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.RTC) u32 {
            return @intFromPtr(self);
        }

        /// RTC Control Register High
        CTLRH: RegisterRW(packed struct(u32) {
            /// SECIE [0:0]
            /// Second interrupt Enable
            SECIE: u1 = 0,
            /// ALRIE [1:1]
            /// Alarm interrupt Enable
            ALRIE: u1 = 0,
            /// OWIE [2:2]
            /// Overflow interrupt Enable
            OWIE: u1 = 0,
            /// padding [3:31]
            _padding: u29 = 0,
        }, nullable_types.RTC.CTLRH),

        /// RTC Control Register Low
        CTLRL: RegisterRW(packed struct(u16) {
            /// SECF [0:0]
            /// Second Flag
            SECF: u1 = 0,
            /// ALRF [1:1]
            /// Alarm Flag
            ALRF: u1 = 0,
            /// OWF [2:2]
            /// Overflow Flag
            OWF: u1 = 0,
            /// RSF [3:3]
            /// Registers Synchronized Flag
            RSF: u1 = 0,
            /// CNF [4:4]
            /// Configuration Flag
            CNF: u1 = 0,
            /// RTOFF [5:5]
            /// RTC operation OFF
            RTOFF: u1 = 1,
            /// padding [6:15]
            _padding: u10 = 0,
        }, nullable_types.RTC.CTLRL),

        /// offset 0x2
        _offset2: [2]u8,

        /// RTC Prescaler Load Register High
        PSCRH: RegisterRW(packed struct(u16) {
            /// PRLH [0:3]
            /// RTC Prescaler Load Register High
            PRLH: u4 = 0,
            /// padding [4:15]
            _padding: u12 = 0,
        }, nullable_types.RTC.PSCRH),

        /// offset 0x2
        _offset3: [2]u8,

        /// RTC Prescaler Load Register Low
        PSCRL: RegisterRW(packed struct(u16) {
            /// PRLL [0:15]
            /// RTC Prescaler Divider Register Low
            PRLL: u16 = 32768,
        }, nullable_types.RTC.PSCRL),

        /// offset 0x2
        _offset4: [2]u8,

        /// RTC Prescaler Divider Register High
        DIVH: RegisterRW(packed struct(u16) {
            /// DIVH [0:3]
            /// RTC prescaler divider register high
            DIVH: u4 = 0,
            /// padding [4:15]
            _padding: u12 = 0,
        }, nullable_types.RTC.DIVH),

        /// offset 0x2
        _offset5: [2]u8,

        /// RTC Prescaler Divider Register Low
        DIVL: RegisterRW(packed struct(u16) {
            /// DIVL [0:15]
            /// RTC prescaler divider register Low
            DIVL: u16 = 32768,
        }, nullable_types.RTC.DIVL),

        /// offset 0x2
        _offset6: [2]u8,

        /// RTC Counter Register High
        CNTH: RegisterRW(packed struct(u16) {
            /// CNTH [0:15]
            /// RTC counter register high
            CNTH: u16 = 0,
        }, nullable_types.RTC.CNTH),

        /// offset 0x2
        _offset7: [2]u8,

        /// RTC Counter Register Low
        CNTL: RegisterRW(packed struct(u16) {
            /// CNTL [0:15]
            /// RTC counter register Low
            CNTL: u16 = 0,
        }, nullable_types.RTC.CNTL),

        /// offset 0x2
        _offset8: [2]u8,

        /// RTC Alarm Register High
        ALRMH: RegisterRW(packed struct(u32) {
            /// ALRMH [0:15]
            /// RTC alarm register high
            ALRMH: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.RTC.ALRMH),

        /// RTC Alarm Register Low
        ALRML: RegisterRW(packed struct(u16) {
            /// ALRML [0:15]
            /// RTC alarm register low
            ALRML: u16 = 0,
        }, nullable_types.RTC.ALRML),
    };

    /// Backup registers
    pub const BKP = extern struct {
        pub inline fn from(base: u32) *volatile types.BKP {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.BKP) u32 {
            return @intFromPtr(self);
        }

        /// offset 0x4
        _offset0: [4]u8,

        /// Backup data register (BKP_DR)
        DATAR1: RegisterRW(packed struct(u16) {
            /// D1 [0:15]
            /// Backup data
            D1: u16 = 0,
        }, nullable_types.BKP.DATAR1),

        /// offset 0x2
        _offset1: [2]u8,

        /// Backup data register (BKP_DR)
        DATAR2: RegisterRW(packed struct(u16) {
            /// D2 [0:15]
            /// Backup data
            D2: u16 = 0,
        }, nullable_types.BKP.DATAR2),

        /// offset 0x2
        _offset2: [2]u8,

        /// Backup data register (BKP_DR)
        DATAR3: RegisterRW(packed struct(u16) {
            /// D3 [0:15]
            /// Backup data
            D3: u16 = 0,
        }, nullable_types.BKP.DATAR3),

        /// offset 0x2
        _offset3: [2]u8,

        /// Backup data register (BKP_DR)
        DATAR4: RegisterRW(packed struct(u16) {
            /// D4 [0:15]
            /// Backup data
            D4: u16 = 0,
        }, nullable_types.BKP.DATAR4),

        /// offset 0x2
        _offset4: [2]u8,

        /// Backup data register (BKP_DR)
        DATAR5: RegisterRW(packed struct(u16) {
            /// D5 [0:15]
            /// Backup data
            D5: u16 = 0,
        }, nullable_types.BKP.DATAR5),

        /// offset 0x2
        _offset5: [2]u8,

        /// Backup data register (BKP_DR)
        DATAR6: RegisterRW(packed struct(u16) {
            /// D6 [0:15]
            /// Backup data
            D6: u16 = 0,
        }, nullable_types.BKP.DATAR6),

        /// offset 0x2
        _offset6: [2]u8,

        /// Backup data register (BKP_DR)
        DATAR7: RegisterRW(packed struct(u16) {
            /// D7 [0:15]
            /// Backup data
            D7: u16 = 0,
        }, nullable_types.BKP.DATAR7),

        /// offset 0x2
        _offset7: [2]u8,

        /// Backup data register (BKP_DR)
        DATAR8: RegisterRW(packed struct(u16) {
            /// D8 [0:15]
            /// Backup data
            D8: u16 = 0,
        }, nullable_types.BKP.DATAR8),

        /// offset 0x2
        _offset8: [2]u8,

        /// Backup data register (BKP_DR)
        DATAR9: RegisterRW(packed struct(u16) {
            /// D9 [0:15]
            /// Backup data
            D9: u16 = 0,
        }, nullable_types.BKP.DATAR9),

        /// offset 0x2
        _offset9: [2]u8,

        /// Backup data register (BKP_DR)
        DATAR10: RegisterRW(packed struct(u16) {
            /// D10 [0:15]
            /// Backup data
            D10: u16 = 0,
        }, nullable_types.BKP.DATAR10),

        /// offset 0x2
        _offset10: [2]u8,

        /// RTC clock calibration register (BKP_OCTLR)
        OCTLR: RegisterRW(packed struct(u16) {
            /// CAL [0:6]
            /// Calibration value
            CAL: u7 = 0,
            /// CCO [7:7]
            /// Calibration Clock Output
            CCO: u1 = 0,
            /// ASOE [8:8]
            /// Alarm or second output enable
            ASOE: u1 = 0,
            /// ASOS [9:9]
            /// Alarm or second output selection
            ASOS: u1 = 0,
            /// padding [10:15]
            _padding: u6 = 0,
        }, nullable_types.BKP.OCTLR),

        /// offset 0x2
        _offset11: [2]u8,

        /// Backup control register (BKP_TPCTLR)
        TPCTLR: RegisterRW(packed struct(u16) {
            /// TPE [0:0]
            /// Tamper pin enable
            TPE: u1 = 0,
            /// TPAL [1:1]
            /// Tamper pin active level
            TPAL: u1 = 0,
            /// padding [2:15]
            _padding: u14 = 0,
        }, nullable_types.BKP.TPCTLR),

        /// offset 0x2
        _offset12: [2]u8,

        /// BKP_TPCSR control/status register (BKP_CSR)
        TPCSR: RegisterRW(packed struct(u32) {
            /// CTE [0:0]
            /// Clear Tamper event
            CTE: u1 = 0,
            /// CTI [1:1]
            /// Clear Tamper Interrupt
            CTI: u1 = 0,
            /// TPIE [2:2]
            /// Tamper Pin interrupt enable
            TPIE: u1 = 0,
            /// unused [3:7]
            _unused3: u5 = 0,
            /// TEF [8:8]
            /// Tamper Event Flag
            TEF: u1 = 0,
            /// TIF [9:9]
            /// Tamper Interrupt Flag
            TIF: u1 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }, nullable_types.BKP.TPCSR),
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
        CTLR: RegisterRW(packed struct(u16) {
            /// KEY [0:15]
            /// Key value
            KEY: u16 = 0,
        }, nullable_types.IWDG.CTLR),

        /// offset 0x2
        _offset1: [2]u8,

        /// Prescaler register (IWDG_PSCR)
        PSCR: RegisterRW(packed struct(u16) {
            /// PR [0:2]
            /// Prescaler divider
            PR: u3 = 0,
            /// padding [3:15]
            _padding: u13 = 0,
        }, nullable_types.IWDG.PSCR),

        /// offset 0x2
        _offset2: [2]u8,

        /// Reload register (IWDG_RLDR)
        RLDR: RegisterRW(packed struct(u16) {
            /// RL [0:11]
            /// Watchdog counter reload value
            RL: u12 = 4095,
            /// padding [12:15]
            _padding: u4 = 0,
        }, nullable_types.IWDG.RLDR),

        /// offset 0x2
        _offset3: [2]u8,

        /// Status register (IWDG_SR)
        STATR: RegisterRW(packed struct(u16) {
            /// PVU [0:0]
            /// Watchdog prescaler value update
            PVU: u1 = 0,
            /// RVU [1:1]
            /// Watchdog counter reload value update
            RVU: u1 = 0,
            /// padding [2:15]
            _padding: u14 = 0,
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
        CTLR: RegisterRW(packed struct(u16) {
            /// T [0:6]
            /// 7-bit counter (MSB to LSB)
            T: u7 = 127,
            /// WDGA [7:7]
            /// Activation bit
            WDGA: u1 = 0,
            /// padding [8:15]
            _padding: u8 = 0,
        }, nullable_types.WWDG.CTLR),

        /// offset 0x2
        _offset1: [2]u8,

        /// Configuration register (WWDG_CFR)
        CFGR: RegisterRW(packed struct(u16) {
            /// W [0:6]
            /// 7-bit window value
            W: u7 = 127,
            /// WDGTB [7:8]
            /// Timer Base
            WDGTB: u2 = 0,
            /// EWI [9:9]
            /// Early Wakeup Interrupt
            EWI: u1 = 0,
            /// padding [10:15]
            _padding: u6 = 0,
        }, nullable_types.WWDG.CFGR),

        /// offset 0x2
        _offset2: [2]u8,

        /// Status register (WWDG_SR)
        STATR: RegisterRW(packed struct(u32) {
            /// WEIF [0:0]
            /// Early Wakeup Interrupt Flag
            WEIF: u1 = 0,
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
        CTLR1: RegisterRW(packed struct(u16) {
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
            /// padding [10:15]
            _padding: u6 = 0,
        }, nullable_types.AdvancedTimer.CTLR1),

        /// offset 0x2
        _offset1: [2]u8,

        /// control register 2
        CTLR2: RegisterRW(packed struct(u16) {
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
            /// padding [15:15]
            _padding: u1 = 0,
        }, nullable_types.AdvancedTimer.CTLR2),

        /// offset 0x2
        _offset2: [2]u8,

        /// slave mode control register
        SMCFGR: RegisterRW(packed struct(u16) {
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
        }, nullable_types.AdvancedTimer.SMCFGR),

        /// offset 0x2
        _offset3: [2]u8,

        /// DMA/Interrupt enable register
        DMAINTENR: RegisterRW(packed struct(u16) {
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
            /// padding [15:15]
            _padding: u1 = 0,
        }, nullable_types.AdvancedTimer.DMAINTENR),

        /// offset 0x2
        _offset4: [2]u8,

        /// status register
        INTFR: RegisterRW(packed struct(u16) {
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
            /// padding [13:15]
            _padding: u3 = 0,
        }, nullable_types.AdvancedTimer.INTFR),

        /// offset 0x2
        _offset5: [2]u8,

        /// event generation register
        SWEVGR: RegisterRW(packed struct(u16) {
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
            /// padding [8:15]
            _padding: u8 = 0,
        }, nullable_types.AdvancedTimer.SWEVGR),

        /// offset 0x2
        _offset6: [2]u8,

        /// capture/compare mode register (output mode)
        CHCTLR1_Output: RegisterRW(packed struct(u16) {
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
        }, nullable_types.AdvancedTimer.CHCTLR1_Output),

        /// offset 0x2
        _offset9: [2]u8,

        /// capture/compare mode register (output mode)
        CHCTLR2_Output: RegisterRW(packed struct(u16) {
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
        }, nullable_types.AdvancedTimer.CHCTLR2_Output),

        /// offset 0x2
        _offset10: [2]u8,

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
        PSC: RegisterRW(packed struct(u16) {
            /// PSC [0:15]
            /// Prescaler value
            PSC: u16 = 0,
        }, nullable_types.AdvancedTimer.PSC),

        /// offset 0x2
        _offset13: [2]u8,

        /// auto-reload register
        ATRLR: RegisterRW(packed struct(u16) {
            /// ARR [0:15]
            /// Auto-reload value
            ARR: u16 = 65535,
        }, nullable_types.AdvancedTimer.ATRLR),

        /// offset 0x2
        _offset14: [2]u8,

        /// repetition counter register
        RPTCR: RegisterRW(packed struct(u16) {
            /// REP [0:7]
            /// Repetition counter value
            REP: u8 = 0,
            /// padding [8:15]
            _padding: u8 = 0,
        }, nullable_types.AdvancedTimer.RPTCR),

        /// offset 0x2
        _offset15: [2]u8,

        /// capture/compare register 1
        CH1CVR: RegisterRW(packed struct(u16) {
            /// CCR1 [0:15]
            /// Capture/Compare 1 value
            CCR1: u16 = 0,
        }, nullable_types.AdvancedTimer.CH1CVR),

        /// offset 0x2
        _offset16: [2]u8,

        /// capture/compare register 2
        CH2CVR: RegisterRW(packed struct(u16) {
            /// CCR2 [0:15]
            /// Capture/Compare 2 value
            CCR2: u16 = 0,
        }, nullable_types.AdvancedTimer.CH2CVR),

        /// offset 0x2
        _offset17: [2]u8,

        /// capture/compare register 3
        CH3CVR: RegisterRW(packed struct(u16) {
            /// CCR3 [0:15]
            /// Capture/Compare value
            CCR3: u16 = 0,
        }, nullable_types.AdvancedTimer.CH3CVR),

        /// offset 0x2
        _offset18: [2]u8,

        /// capture/compare register 4
        CH4CVR: RegisterRW(packed struct(u16) {
            /// CCR4 [0:15]
            /// Capture/Compare value
            CCR4: u16 = 0,
        }, nullable_types.AdvancedTimer.CH4CVR),

        /// offset 0x2
        _offset19: [2]u8,

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
        DMACFGR: RegisterRW(packed struct(u16) {
            /// DBA [0:4]
            /// DMA base address
            DBA: u5 = 0,
            /// unused [5:7]
            _unused5: u3 = 0,
            /// DBL [8:12]
            /// DMA burst length
            DBL: u5 = 0,
            /// padding [13:15]
            _padding: u3 = 0,
        }, nullable_types.AdvancedTimer.DMACFGR),

        /// offset 0x2
        _offset21: [2]u8,

        /// DMA address for full transfer
        DMAR: RegisterRW(packed struct(u32) {
            /// DMAB [0:15]
            /// DMA register for burst accesses
            DMAB: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.AdvancedTimer.DMAR),
    };

    /// General purpose timer
    /// Type for: TIM2 TIM3 TIM4
    pub const GeneralPurposeTimer = extern struct {
        pub const TIM2 = types.GeneralPurposeTimer.from(0x40000000);
        pub const TIM3 = types.GeneralPurposeTimer.from(0x40000400);
        pub const TIM4 = types.GeneralPurposeTimer.from(0x40000800);

        pub inline fn from(base: u32) *volatile types.GeneralPurposeTimer {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.GeneralPurposeTimer) u32 {
            return @intFromPtr(self);
        }

        /// control register 1
        CTLR1: RegisterRW(packed struct(u16) {
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
            /// padding [10:15]
            _padding: u6 = 0,
        }, nullable_types.GeneralPurposeTimer.CTLR1),

        /// offset 0x2
        _offset1: [2]u8,

        /// control register 2
        CTLR2: RegisterRW(packed struct(u16) {
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
            /// padding [8:15]
            _padding: u8 = 0,
        }, nullable_types.GeneralPurposeTimer.CTLR2),

        /// offset 0x2
        _offset2: [2]u8,

        /// slave mode control register
        SMCFGR: RegisterRW(packed struct(u16) {
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
        }, nullable_types.GeneralPurposeTimer.SMCFGR),

        /// offset 0x2
        _offset3: [2]u8,

        /// DMA/Interrupt enable register
        DMAINTENR: RegisterRW(packed struct(u16) {
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
            /// padding [15:15]
            _padding: u1 = 0,
        }, nullable_types.GeneralPurposeTimer.DMAINTENR),

        /// offset 0x2
        _offset4: [2]u8,

        /// status register
        INTFR: RegisterRW(packed struct(u16) {
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
            /// padding [13:15]
            _padding: u3 = 0,
        }, nullable_types.GeneralPurposeTimer.INTFR),

        /// offset 0x2
        _offset5: [2]u8,

        /// event generation register
        SWEVGR: RegisterRW(packed struct(u16) {
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
            /// padding [8:15]
            _padding: u8 = 0,
        }, nullable_types.GeneralPurposeTimer.SWEVGR),

        /// offset 0x2
        _offset6: [2]u8,

        /// capture/compare mode register 1 (output mode)
        CHCTLR1_Output: RegisterRW(packed struct(u16) {
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
            /// Capture/Compare 2 selection
            CC2S: u2 = 0,
            /// OC2FE [10:10]
            /// Output compare 2 fast enable
            OC2FE: u1 = 0,
            /// OC2PE [11:11]
            /// Output compare 2 preload enable
            OC2PE: u1 = 0,
            /// OC2M [12:14]
            /// Output compare 2 mode
            OC2M: u3 = 0,
            /// OC2CE [15:15]
            /// Output compare 2 clear enable
            OC2CE: u1 = 0,
        }, nullable_types.GeneralPurposeTimer.CHCTLR1_Output),

        /// offset 0x2
        _offset9: [2]u8,

        /// capture/compare mode register 2 (output mode)
        CHCTLR2_Output: RegisterRW(packed struct(u16) {
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
        }, nullable_types.GeneralPurposeTimer.CHCTLR2_Output),

        /// offset 0x2
        _offset10: [2]u8,

        /// capture/compare enable register
        CCER: RegisterRW(packed struct(u16) {
            /// CC1E [0:0]
            /// Capture/Compare 1 output enable
            CC1E: u1 = 0,
            /// CC1P [1:1]
            /// Capture/Compare 1 output Polarity
            CC1P: u1 = 0,
            /// unused [2:3]
            _unused2: u2 = 0,
            /// CC2E [4:4]
            /// Capture/Compare 2 output enable
            CC2E: u1 = 0,
            /// CC2P [5:5]
            /// Capture/Compare 2 output Polarity
            CC2P: u1 = 0,
            /// unused [6:7]
            _unused6: u2 = 0,
            /// CC3E [8:8]
            /// Capture/Compare 3 output enable
            CC3E: u1 = 0,
            /// CC3P [9:9]
            /// Capture/Compare 3 output Polarity
            CC3P: u1 = 0,
            /// unused [10:11]
            _unused10: u2 = 0,
            /// CC4E [12:12]
            /// Capture/Compare 4 output enable
            CC4E: u1 = 0,
            /// CC4P [13:13]
            /// Capture/Compare 3 output Polarity
            CC4P: u1 = 0,
            /// padding [14:15]
            _padding: u2 = 0,
        }, nullable_types.GeneralPurposeTimer.CCER),

        /// offset 0x2
        _offset11: [2]u8,

        /// counter
        CNT: RegisterRW(packed struct(u16) {
            /// CNT [0:15]
            /// counter value
            CNT: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.CNT),

        /// offset 0x2
        _offset12: [2]u8,

        /// prescaler
        PSC: RegisterRW(packed struct(u16) {
            /// PSC [0:15]
            /// Prescaler value
            PSC: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.PSC),

        /// offset 0x2
        _offset13: [2]u8,

        /// auto-reload register
        ATRLR: RegisterRW(packed struct(u16) {
            /// ARR [0:15]
            /// Auto-reload value
            ARR: u16 = 65535,
        }, nullable_types.GeneralPurposeTimer.ATRLR),

        /// offset 0x6
        _offset14: [6]u8,

        /// capture/compare register 1
        CH1CVR: RegisterRW(packed struct(u16) {
            /// CCR1 [0:15]
            /// Capture/Compare 1 value
            CCR1: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.CH1CVR),

        /// offset 0x2
        _offset15: [2]u8,

        /// capture/compare register 2
        CH2CVR: RegisterRW(packed struct(u16) {
            /// CCR2 [0:15]
            /// Capture/Compare 2 value
            CCR2: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.CH2CVR),

        /// offset 0x2
        _offset16: [2]u8,

        /// capture/compare register 3
        CH3CVR: RegisterRW(packed struct(u16) {
            /// CCR3 [0:15]
            /// Capture/Compare value
            CCR3: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.CH3CVR),

        /// offset 0x2
        _offset17: [2]u8,

        /// capture/compare register 4
        CH4CVR: RegisterRW(packed struct(u16) {
            /// CCR4 [0:15]
            /// Capture/Compare value
            CCR4: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.CH4CVR),

        /// offset 0x6
        _offset18: [6]u8,

        /// DMA control register
        DMACFGR: RegisterRW(packed struct(u16) {
            /// DBA [0:4]
            /// DMA base address
            DBA: u5 = 0,
            /// unused [5:7]
            _unused5: u3 = 0,
            /// DBL [8:12]
            /// DMA burst length
            DBL: u5 = 0,
            /// padding [13:15]
            _padding: u3 = 0,
        }, nullable_types.GeneralPurposeTimer.DMACFGR),

        /// offset 0x2
        _offset19: [2]u8,

        /// DMA address for full transfer
        DMAADR: RegisterRW(packed struct(u16) {
            /// DMAB [0:15]
            /// DMA register for burst accesses
            DMAB: u16 = 0,
        }, nullable_types.GeneralPurposeTimer.DMAADR),
    };

    /// Inter integrated circuit
    /// Type for: I2C1 I2C2
    pub const I2C = extern struct {
        pub const I2C1 = types.I2C.from(0x40005400);
        pub const I2C2 = types.I2C.from(0x40005800);

        pub inline fn from(base: u32) *volatile types.I2C {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.I2C) u32 {
            return @intFromPtr(self);
        }

        /// Control register 1
        CTLR1: RegisterRW(packed struct(u16) {
            /// PE [0:0]
            /// Peripheral enable
            PE: u1 = 0,
            /// SMBUS [1:1]
            /// SMBus mode
            SMBUS: u1 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// SMBTYPE [3:3]
            /// SMBus type
            SMBTYPE: u1 = 0,
            /// ENARP [4:4]
            /// ARP enable
            ENARP: u1 = 0,
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
            /// ALERT [13:13]
            /// SMBus alert
            ALERT: u1 = 0,
            /// unused [14:14]
            _unused14: u1 = 0,
            /// SWRST [15:15]
            /// Software reset
            SWRST: u1 = 0,
        }, nullable_types.I2C.CTLR1),

        /// offset 0x2
        _offset1: [2]u8,

        /// Control register 2
        CTLR2: RegisterRW(packed struct(u16) {
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
            /// padding [13:15]
            _padding: u3 = 0,
        }, nullable_types.I2C.CTLR2),

        /// offset 0x2
        _offset2: [2]u8,

        /// Own address register 1
        OADDR1: RegisterRW(packed struct(u16) {
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
        }, nullable_types.I2C.OADDR1),

        /// offset 0x2
        _offset3: [2]u8,

        /// Own address register 2
        OADDR2: RegisterRW(packed struct(u16) {
            /// ENDUAL [0:0]
            /// Dual addressing mode enable
            ENDUAL: u1 = 0,
            /// ADD2 [1:7]
            /// Interface address
            ADD2: u7 = 0,
            /// padding [8:15]
            _padding: u8 = 0,
        }, nullable_types.I2C.OADDR2),

        /// offset 0x2
        _offset4: [2]u8,

        /// Data register
        DATAR: RegisterRW(packed struct(u16) {
            /// DR [0:7]
            /// 8-bit data register
            DR: u8 = 0,
            /// padding [8:15]
            _padding: u8 = 0,
        }, nullable_types.I2C.DATAR),

        /// offset 0x2
        _offset5: [2]u8,

        /// Status register 1
        STAR1: RegisterRW(packed struct(u16) {
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
            /// unused [13:13]
            _unused13: u1 = 0,
            /// TIMEOUT [14:14]
            /// Timeout or Tlow error
            TIMEOUT: u1 = 0,
            /// SMBALERT [15:15]
            /// SMBus alert
            SMBALERT: u1 = 0,
        }, nullable_types.I2C.STAR1),

        /// offset 0x2
        _offset6: [2]u8,

        /// Status register 2
        STAR2: RegisterRW(packed struct(u16) {
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
            /// SMBDEFAULT [5:5]
            /// SMBus device default address (Slave mode)
            SMBDEFAULT: u1 = 0,
            /// SMBHOST [6:6]
            /// SMBus host header (Slave mode)
            SMBHOST: u1 = 0,
            /// DUALF [7:7]
            /// Dual flag (Slave mode)
            DUALF: u1 = 0,
            /// PEC [8:15]
            /// acket error checking register
            PEC: u8 = 0,
        }, nullable_types.I2C.STAR2),

        /// offset 0x2
        _offset7: [2]u8,

        /// Clock control register
        CKCFGR: RegisterRW(packed struct(u16) {
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
        }, nullable_types.I2C.CKCFGR),

        /// offset 0x2
        _offset8: [2]u8,

        /// risetime register
        RTR: RegisterRW(packed struct(u16) {
            /// TRISE [0:5]
            /// Maximum rise time in Fast/Standard mode (Master mode)
            TRISE: u6 = 2,
            /// padding [6:15]
            _padding: u10 = 0,
        }, nullable_types.I2C.RTR),
    };

    /// Serial peripheral interface
    /// Type for: SPI1 SPI2
    pub const SPI = extern struct {
        pub const SPI1 = types.SPI.from(0x40013000);
        pub const SPI2 = types.SPI.from(0x40003800);

        pub inline fn from(base: u32) *volatile types.SPI {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.SPI) u32 {
            return @intFromPtr(self);
        }

        /// control register 1
        CTLR1: RegisterRW(packed struct(u16) {
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
        }, nullable_types.SPI.CTLR1),

        /// offset 0x2
        _offset1: [2]u8,

        /// control register 2
        CTLR2: RegisterRW(packed struct(u16) {
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
            /// padding [8:15]
            _padding: u8 = 0,
        }, nullable_types.SPI.CTLR2),

        /// offset 0x2
        _offset2: [2]u8,

        /// status register
        STATR: RegisterRW(packed struct(u16) {
            /// RXNE [0:0]
            /// Receive buffer not empty
            RXNE: u1 = 0,
            /// TXE [1:1]
            /// Transmit buffer empty
            TXE: u1 = 1,
            /// unused [2:3]
            _unused2: u2 = 0,
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
            /// padding [8:15]
            _padding: u8 = 0,
        }, nullable_types.SPI.STATR),

        /// offset 0x2
        _offset3: [2]u8,

        /// data register
        DATAR: RegisterRW(packed struct(u16) {
            /// DATAR [0:15]
            /// Data register
            DATAR: u16 = 0,
        }, nullable_types.SPI.DATAR),

        /// offset 0x2
        _offset4: [2]u8,

        /// CRCR polynomial register
        CRCR: RegisterRW(packed struct(u16) {
            /// CRCPOLY [0:15]
            /// CRC polynomial register
            CRCPOLY: u16 = 7,
        }, nullable_types.SPI.CRCR),

        /// offset 0x2
        _offset5: [2]u8,

        /// RX CRC register
        RCRCR: RegisterRW(packed struct(u16) {
            /// RxCRC [0:15]
            /// Rx CRC register
            RxCRC: u16 = 0,
        }, nullable_types.SPI.RCRCR),

        /// offset 0x2
        _offset6: [2]u8,

        /// TX CRC register
        TCRCR: RegisterRW(packed struct(u16) {
            /// TxCRC [0:15]
            /// Tx CRC register
            TxCRC: u16 = 0,
        }, nullable_types.SPI.TCRCR),

        /// offset 0xa
        _offset7: [10]u8,

        /// High speed control register
        HSCR: RegisterRW(packed struct(u16) {
            /// HSRXEN [0:0]
            /// High speed read mode enable bit
            HSRXEN: u1 = 0,
            /// padding [1:15]
            _padding: u15 = 0,
        }, nullable_types.SPI.HSCR),
    };

    /// Universal synchronous asynchronous receiver transmitter
    /// Type for: USART1 USART2 USART3
    pub const USART = extern struct {
        pub const USART1 = types.USART.from(0x40013800);
        pub const USART2 = types.USART.from(0x40004400);
        pub const USART3 = types.USART.from(0x40004800);

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
    pub const ADC = extern struct {
        pub inline fn from(base: u32) *volatile types.ADC {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.ADC) u32 {
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
        }, nullable_types.ADC.STATR),

        /// control register 1 and TKEY_V control register
        CTLR1_TKEY_V_CTLR: RegisterRW(packed struct(u32) {
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
            /// Scan mode
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
            /// DUALMOD [16:19]
            /// Dual mode selection
            DUALMOD: u4 = 0,
            /// unused [20:21]
            _unused20: u2 = 0,
            /// JAWDEN [22:22]
            /// Analog watchdog enable on injected channels
            JAWDEN: u1 = 0,
            /// AWDEN [23:23]
            /// Analog watchdog enable on regular channels
            AWDEN: u1 = 0,
            /// TKENABLE [24:24]
            /// Touch key enable, including TKEY_F and TKEY_V
            TKENABLE: u1 = 0,
            /// TKIEN [25:25]
            /// count conversion complete interrupt enabled
            TKIEN: u1 = 0,
            /// TKCPS [26:26]
            /// count cycle selection
            TKCPS: u1 = 0,
            /// TKIF [27:27]
            /// count conversion complete flag
            TKIF: u1 = 0,
            /// CCSEL [28:28]
            /// Touch key count cycle time base
            CCSEL: u1 = 0,
            /// padding [29:31]
            _padding: u3 = 0,
        }, nullable_types.ADC.CTLR1_TKEY_V_CTLR),

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
            /// TSVREFE [23:23]
            /// Temperature sensor and VREFINT enable
            TSVREFE: u1 = 0,
            /// padding [24:31]
            _padding: u8 = 0,
        }, nullable_types.ADC.CTLR2),

        /// sample time register 1
        SAMPTR1: RegisterRW(packed struct(u32) {
            /// SMP10 [0:2]
            /// Channel 10 sample time selection
            SMP10: u3 = 0,
            /// SMP11 [3:5]
            /// Channel 11 sample time selection
            SMP11: u3 = 0,
            /// SMP12 [6:8]
            /// Channel 12 sample time selection
            SMP12: u3 = 0,
            /// SMP13 [9:11]
            /// Channel 13 sample time selection
            SMP13: u3 = 0,
            /// SMP14 [12:14]
            /// Channel 14 sample time selection
            SMP14: u3 = 0,
            /// SMP15 [15:17]
            /// Channel 15 sample time selection
            SMP15: u3 = 0,
            /// SMP16 [18:20]
            /// Channel 16 sample time selection
            SMP16: u3 = 0,
            /// SMP17 [21:23]
            /// Channel 17 sample time selection
            SMP17: u3 = 0,
            /// padding [24:31]
            _padding: u8 = 0,
        }, nullable_types.ADC.SAMPTR1),

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
            /// SMP6 [18:20]
            /// Channel 6 sample time selection
            SMP6: u3 = 0,
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
        }, nullable_types.ADC.SAMPTR2),

        /// injected channel data offset register x
        IOFR1: RegisterRW(packed struct(u32) {
            /// JOFFSET1 [0:11]
            /// Data offset for injected channel x
            JOFFSET1: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }, nullable_types.ADC.IOFR1),

        /// injected channel data offset register x
        IOFR2: RegisterRW(packed struct(u32) {
            /// JOFFSET2 [0:11]
            /// Data offset for injected channel x
            JOFFSET2: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }, nullable_types.ADC.IOFR2),

        /// injected channel data offset register x
        IOFR3: RegisterRW(packed struct(u32) {
            /// JOFFSET3 [0:11]
            /// Data offset for injected channel x
            JOFFSET3: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }, nullable_types.ADC.IOFR3),

        /// injected channel data offset register x
        IOFR4: RegisterRW(packed struct(u32) {
            /// JOFFSET4 [0:11]
            /// Data offset for injected channel x
            JOFFSET4: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }, nullable_types.ADC.IOFR4),

        /// watchdog higher threshold register
        WDHTR: RegisterRW(packed struct(u32) {
            /// HT [0:11]
            /// Analog watchdog higher threshold
            HT: u12 = 4095,
            /// padding [12:31]
            _padding: u20 = 0,
        }, nullable_types.ADC.WDHTR),

        /// watchdog lower threshold register
        WDLTR: RegisterRW(packed struct(u32) {
            /// LT [0:11]
            /// Analog watchdog lower threshold
            LT: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }, nullable_types.ADC.WDLTR),

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
        }, nullable_types.ADC.RSQR1),

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
        }, nullable_types.ADC.RSQR2),

        /// regular sequence register 3
        RSQR3: RegisterRW(packed struct(u32) {
            /// SQ1_CHSEL [0:4]
            /// 1st conversion in regular sequence_conversion count conversion channel selection
            SQ1_CHSEL: u5 = 0,
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
        }, nullable_types.ADC.RSQR3),

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
        }, nullable_types.ADC.ISQR),

        /// injected data register x
        IDATAR1: RegisterRW(packed struct(u32) {
            /// JDATA [0:15]
            /// Injected data
            JDATA: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.ADC.IDATAR1),

        /// injected data register x
        IDATAR2: RegisterRW(packed struct(u32) {
            /// JDATA [0:15]
            /// Injected data
            JDATA: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.ADC.IDATAR2),

        /// injected data register x
        IDATAR3: RegisterRW(packed struct(u32) {
            /// JDATA [0:15]
            /// Injected data
            JDATA: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.ADC.IDATAR3),

        /// injected data register x
        IDATAR4: RegisterRW(packed struct(u32) {
            /// JDATA [0:15]
            /// Injected data
            JDATA: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.ADC.IDATAR4),

        /// regular data register
        RDATAR: RegisterRW(packed struct(u32) {
            /// DATA0_13_TKDR [0:13]
            /// Regular data_count conversion value
            DATA0_13_TKDR: u14 = 0,
            /// DATA14 [14:14]
            /// Regular data
            DATA14: u1 = 0,
            /// DATA15_TKSTA [15:15]
            /// Regular data_current working state of TKEY_V
            DATA15_TKSTA: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.ADC.RDATAR),
    };

    /// Digital to analog converter
    pub const DAC1 = extern struct {
        pub inline fn from(base: u32) *volatile types.DAC1 {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.DAC1) u32 {
            return @intFromPtr(self);
        }

        /// Control register (DAC_CTLR)
        CTLR: RegisterRW(packed struct(u32) {
            /// EN1 [0:0]
            /// DAC channel1 enable
            EN1: u1 = 0,
            /// BOFF1 [1:1]
            /// DAC channel1 output buffer disable
            BOFF1: u1 = 0,
            /// TEN1 [2:2]
            /// DAC channel1 trigger enable
            TEN1: u1 = 0,
            /// TSEL1 [3:5]
            /// DAC channel1 trigger selection
            TSEL1: u3 = 0,
            /// WAVE1 [6:7]
            /// DAC channel1 noise/triangle wave generation enable
            WAVE1: u2 = 0,
            /// MAMP1 [8:11]
            /// DAC channel1 mask/amplitude selector
            MAMP1: u4 = 0,
            /// DMAEN1 [12:12]
            /// DAC channel1 DMA enable
            DMAEN1: u1 = 0,
            /// unused [13:15]
            _unused13: u3 = 0,
            /// EN2 [16:16]
            /// DAC channel2 enable
            EN2: u1 = 0,
            /// BOFF2 [17:17]
            /// DAC channel2 output buffer disable
            BOFF2: u1 = 0,
            /// TEN2 [18:18]
            /// DAC channel2 trigger enable
            TEN2: u1 = 0,
            /// TSEL2 [19:21]
            /// DAC channel2 trigger selection
            TSEL2: u3 = 0,
            /// WAVE2 [22:23]
            /// DAC channel2 noise/triangle wave generation enable
            WAVE2: u2 = 0,
            /// MAMP2 [24:27]
            /// DAC channel2 mask/amplitude selector
            MAMP2: u4 = 0,
            /// DMAEN2 [28:28]
            /// DAC channel2 DMA enable
            DMAEN2: u1 = 0,
            /// padding [29:31]
            _padding: u3 = 0,
        }, nullable_types.DAC1.CTLR),

        /// DAC software trigger register (DAC_SWTR)
        SWTR: RegisterRW(packed struct(u32) {
            /// SWTRIG1 [0:0]
            /// DAC channel1 software trigger
            SWTRIG1: u1 = 0,
            /// SWTRIG2 [1:1]
            /// DAC channel2 software trigger
            SWTRIG2: u1 = 0,
            /// padding [2:31]
            _padding: u30 = 0,
        }, nullable_types.DAC1.SWTR),

        /// DAC channel1 12-bit right-aligned data holding register(DAC_R12BDHR1)
        R12BDHR1: RegisterRW(packed struct(u32) {
            /// DACC1DHR [0:11]
            /// DAC channel1 12-bit right-aligned data
            DACC1DHR: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }, nullable_types.DAC1.R12BDHR1),

        /// DAC channel1 12-bit left aligned data holding register (DAC_L12BDHR1)
        L12BDHR1: RegisterRW(packed struct(u32) {
            /// unused [0:3]
            _unused0: u4 = 0,
            /// DACC1DHR [4:15]
            /// DAC channel1 12-bit left-aligned data
            DACC1DHR: u12 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.DAC1.L12BDHR1),

        /// offset 0x4
        _offset4: [4]u8,

        /// DAC channel2 12-bit right aligned data holding register (DAC_R12BDHR2)
        R12BDHR2: RegisterRW(packed struct(u32) {
            /// DACC2DHR [0:11]
            /// DAC channel2 12-bit right-aligned data
            DACC2DHR: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }, nullable_types.DAC1.R12BDHR2),

        /// DAC channel2 12-bit left aligned data holding register (DAC_L12BDHR2)
        L12BDHR2: RegisterRW(packed struct(u32) {
            /// unused [0:3]
            _unused0: u4 = 0,
            /// DACC2DHR [4:15]
            /// DAC channel2 12-bit left-aligned data
            DACC2DHR: u12 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }, nullable_types.DAC1.L12BDHR2),

        /// offset 0x10
        _offset6: [16]u8,

        /// DAC channel1 data output register (DAC_DOR1)
        DOR1: RegisterRW(packed struct(u32) {
            /// DACC1DOR [0:11]
            /// DAC channel1 data output
            DACC1DOR: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }, nullable_types.DAC1.DOR1),

        /// DAC channel2 data output register (DAC_DOR2)
        DOR2: RegisterRW(packed struct(u32) {
            /// DACC2DOR [0:11]
            /// DAC channel2 data output
            DACC2DOR: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }, nullable_types.DAC1.DOR2),
    };

    /// Debug support
    pub const DBG = extern struct {
        pub inline fn from(base: u32) *volatile types.DBG {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.DBG) u32 {
            return @intFromPtr(self);
        }

        /// DBGMCU_CR1
        CR1: RegisterRW(packed struct(u32) {
            /// IWDG_STOP [0:0]
            /// IWDG_STOP
            IWDG_STOP: u1 = 0,
            /// WWDG_STOP [1:1]
            /// WWDG_STOP
            WWDG_STOP: u1 = 0,
            /// I2C1_SMBUS_TIMEOUT [2:2]
            /// I2C1_SMBUS_TIMEOUT
            I2C1_SMBUS_TIMEOUT: u1 = 0,
            /// I2C2_SMBUS_TIMEOUT [3:3]
            /// I2C2_SMBUS_TIMEOUT
            I2C2_SMBUS_TIMEOUT: u1 = 0,
            /// TIM1_STOP [4:4]
            /// TIM1_STOP
            TIM1_STOP: u1 = 0,
            /// TIM2_STOP [5:5]
            /// TIM2_STOP
            TIM2_STOP: u1 = 0,
            /// TIM3_STOP [6:6]
            /// TIM3_STOP
            TIM3_STOP: u1 = 0,
            /// TIM4_STOP [7:7]
            /// TIM4_STOP
            TIM4_STOP: u1 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }, nullable_types.DBG.CR1),

        /// DBGMCU_CR2
        CR2: RegisterRW(packed struct(u32) {
            /// SLEEP [0:0]
            /// DBG_SLEEP
            SLEEP: u1 = 0,
            /// STOP [1:1]
            /// DBG_STOP
            STOP: u1 = 0,
            /// STANDBY [2:2]
            /// DBG_STANDBY
            STANDBY: u1 = 0,
            /// padding [3:31]
            _padding: u29 = 0,
        }, nullable_types.DBG.CR2),
    };

    /// USB register
    pub const USBFS = extern struct {
        pub inline fn from(base: u32) *volatile types.USBFS {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.USBFS) u32 {
            return @intFromPtr(self);
        }

        /// USB base control
        R8_USB_CTRL: RegisterRW(packed struct(u8) {
            /// RB_UC_DMA_EN [0:0]
            /// DMA enable and DMA interrupt enable for USB
            RB_UC_DMA_EN: u1 = 0,
            /// RB_UC_CLR_ALL [1:1]
            /// force clear FIFO and count of USB
            RB_UC_CLR_ALL: u1 = 1,
            /// RB_UC_RST_SIE [2:2]
            /// force reset USB SIE, need software clear
            RB_UC_RST_SIE: u1 = 1,
            /// RB_UC_INT_BUSY [3:3]
            /// enable automatic responding busy for device mode or automatic pause for host mode during interrupt flag UIF_TRANSFER valid
            RB_UC_INT_BUSY: u1 = 0,
            /// MASK_UC_SYS_CTRL [4:5]
            /// bit mask of USB system control
            MASK_UC_SYS_CTRL: u2 = 0,
            /// RB_UC_LOW_SPEED [6:6]
            /// enable USB low speed: 0=12Mbps, 1=1.5Mbps
            RB_UC_LOW_SPEED: u1 = 0,
            /// RB_UC_HOST_MODE [7:7]
            /// enable USB host mode: 0=device mode, 1=host mode
            RB_UC_HOST_MODE: u1 = 0,
        }, nullable_types.USBFS.R8_USB_CTRL),

        /// USB device physical prot control
        R8_UDEV_CTRL__R8_UHOST_CTRL: RegisterRW(packed struct(u8) {
            /// RB_UD_PORT_EN__RB_UH_PORT_EN [0:0]
            /// enable USB physical port I/O: 0=disable, 1=enable;enable USB port: 0=disable, 1=enable port, automatic disabled if USB device detached
            RB_UD_PORT_EN__RB_UH_PORT_EN: u1 = 0,
            /// RB_UD_GP_BIT__RB_UH_BUS_RESET [1:1]
            /// general purpose bit;control USB bus reset: 0=normal, 1=force bus reset
            RB_UD_GP_BIT__RB_UH_BUS_RESET: u1 = 0,
            /// RB_UD_LOW_SPEED__RB_UH_LOW_SPEED [2:2]
            /// enable USB physical port low speed: 0=full speed, 1=low speed;enable USB port low speed: 0=full speed, 1=low speed
            RB_UD_LOW_SPEED__RB_UH_LOW_SPEED: u1 = 0,
            /// unused [3:3]
            _unused3: u1 = 0,
            /// RB_UD_DM_PIN__RB_UH_DM_PIN [4:4]
            /// ReadOnly: indicate current UDM pin level
            RB_UD_DM_PIN__RB_UH_DM_PIN: u1 = 0,
            /// RB_UD_DP_PIN__RB_UH_DP_PIN [5:5]
            /// ReadOnly: indicate current UDP pin level
            RB_UD_DP_PIN__RB_UH_DP_PIN: u1 = 0,
            /// unused [6:6]
            _unused6: u1 = 0,
            /// RB_UD_PD_DIS__RB_UH_PD_DIS [7:7]
            /// disable USB UDP/UDM pulldown resistance: 0=enable pulldown, 1=disable
            RB_UD_PD_DIS__RB_UH_PD_DIS: u1 = 0,
        }, nullable_types.USBFS.R8_UDEV_CTRL__R8_UHOST_CTRL),

        /// USB interrupt enable
        R8_USB_INT_EN: RegisterRW(packed struct(u8) {
            /// RB_UIE_BUS_RST__RB_UIE_DETECT [0:0]
            /// enable interrupt for USB bus reset event for USB device mode;enable interrupt for USB device detected event for USB host mode
            RB_UIE_BUS_RST__RB_UIE_DETECT: u1 = 0,
            /// RB_UIE_TRANSFER [1:1]
            /// enable interrupt for USB transfer completion
            RB_UIE_TRANSFER: u1 = 0,
            /// RB_UIE_SUSPEND [2:2]
            /// enable interrupt for USB suspend or resume event
            RB_UIE_SUSPEND: u1 = 0,
            /// RB_UIE_HST_SOF [3:3]
            /// enable interrupt for host SOF timer action for USB host mode
            RB_UIE_HST_SOF: u1 = 0,
            /// RB_UIE_FIFO_OV [4:4]
            /// enable interrupt for FIFO overflow
            RB_UIE_FIFO_OV: u1 = 0,
            /// unused [5:5]
            _unused5: u1 = 0,
            /// RB_UIE_DEV_NAK [6:6]
            /// enable interrupt for NAK responded for USB device mode
            RB_UIE_DEV_NAK: u1 = 0,
            /// RB_UIE_DEV_SOF [7:7]
            /// enable interrupt for SOF received for USB device mode
            RB_UIE_DEV_SOF: u1 = 0,
        }, nullable_types.USBFS.R8_USB_INT_EN),

        /// USB device address
        R8_USB_DEV_AD: RegisterRW(packed struct(u8) {
            /// MASK_USB_ADDR [0:6]
            /// bit mask for USB device address
            MASK_USB_ADDR: u7 = 0,
            /// RB_UDA_GP_BIT [7:7]
            /// general purpose bit
            RB_UDA_GP_BIT: u1 = 0,
        }, nullable_types.USBFS.R8_USB_DEV_AD),

        /// offset 0x1
        _offset4: [1]u8,

        /// USB miscellaneous status
        R8_USB_MIS_ST: RegisterRW(packed struct(u8) {
            /// RB_UMS_DEV_ATTACH [0:0]
            /// RO, indicate device attached status on USB host
            RB_UMS_DEV_ATTACH: u1 = 0,
            /// RB_UMS_DM_LEVEL [1:1]
            /// RO, indicate UDM level saved at device attached to USB host
            RB_UMS_DM_LEVEL: u1 = 0,
            /// RB_UMS_SUSPEND [2:2]
            /// RO, indicate USB suspend status
            RB_UMS_SUSPEND: u1 = 0,
            /// RB_UMS_BUS_RESET [3:3]
            /// RO, indicate USB bus reset status
            RB_UMS_BUS_RESET: u1 = 0,
            /// RB_UMS_R_FIFO_RDY [4:4]
            /// RO, indicate USB receiving FIFO ready status (not empty)
            RB_UMS_R_FIFO_RDY: u1 = 0,
            /// RB_UMS_SIE_FREE [5:5]
            /// RO, indicate USB SIE free status
            RB_UMS_SIE_FREE: u1 = 0,
            /// RB_UMS_SOF_ACT [6:6]
            /// RO, indicate host SOF timer action status for USB host
            RB_UMS_SOF_ACT: u1 = 0,
            /// RB_UMS_SOF_PRES [7:7]
            /// RO, indicate host SOF timer presage status
            RB_UMS_SOF_PRES: u1 = 0,
        }, nullable_types.USBFS.R8_USB_MIS_ST),

        /// USB interrupt flag
        R8_USB_INT_FG: RegisterRW(packed struct(u8) {
            /// RB_UIF_BUS_RST__RB_UIF_DETECT [0:0]
            /// bus reset event interrupt flag for USB device mode, direct bit address clear or write 1 to clear;device detected event interrupt flag for USB host mode, direct bit address clear or write 1 to clear
            RB_UIF_BUS_RST__RB_UIF_DETECT: u1 = 0,
            /// RB_UIF_TRANSFER [1:1]
            /// USB transfer completion interrupt flag, direct bit address clear or write 1 to clear
            RB_UIF_TRANSFER: u1 = 0,
            /// RB_UIF_SUSPEND [2:2]
            /// USB suspend or resume event interrupt flag, direct bit address clear or write 1 to clear
            RB_UIF_SUSPEND: u1 = 0,
            /// RB_UIF_HST_SOF [3:3]
            /// host SOF timer interrupt flag for USB host, direct bit address clear or write 1 to clear
            RB_UIF_HST_SOF: u1 = 0,
            /// RB_UIF_FIFO_OV [4:4]
            /// FIFO overflow interrupt flag for USB, direct bit address clear or write 1 to clear
            RB_UIF_FIFO_OV: u1 = 0,
            /// RB_U_SIE_FREE [5:5]
            /// RO, indicate USB SIE free status
            RB_U_SIE_FREE: u1 = 0,
            /// RB_U_TOG_OK [6:6]
            /// RO, indicate current USB transfer toggle is OK
            RB_U_TOG_OK: u1 = 0,
            /// RB_U_IS_NAK [7:7]
            /// RO, indicate current USB transfer is NAK received
            RB_U_IS_NAK: u1 = 0,
        }, nullable_types.USBFS.R8_USB_INT_FG),

        /// USB interrupt status
        R8_USB_INT_ST: RegisterRW(packed struct(u8) {
            /// MASK_UIS_H_RES__MASK_UIS_ENDP [0:3]
            /// RO, bit mask of current transfer handshake response for USB host mode: 0000=no response, time out from device, others=handshake response PID received;RO, bit mask of current transfer endpoint number for USB device mode
            MASK_UIS_H_RES__MASK_UIS_ENDP: u4 = 0,
            /// MASK_UIS_TOKEN [4:5]
            /// RO, bit mask of current token PID code received for USB device mode
            MASK_UIS_TOKEN: u2 = 0,
            /// RB_UIS_TOG_OK [6:6]
            /// RO, indicate current USB transfer toggle is OK
            RB_UIS_TOG_OK: u1 = 0,
            /// RB_UIS_IS_NAK [7:7]
            /// RO, indicate current USB transfer is NAK received for USB device mode
            RB_UIS_IS_NAK: u1 = 0,
        }, nullable_types.USBFS.R8_USB_INT_ST),

        /// USB receiving length
        R8_USB_RX_LEN: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.USBFS.R8_USB_RX_LEN),

        /// offset 0x3
        _offset8: [3]u8,

        /// endpoint 4/1 mode
        R8_UEP4_1_MOD: RegisterRW(packed struct(u8) {
            /// unused [0:1]
            _unused0: u2 = 0,
            /// RB_UEP4_TX_EN [2:2]
            /// enable USB endpoint 4 transmittal (IN)
            RB_UEP4_TX_EN: u1 = 0,
            /// RB_UEP4_RX_EN [3:3]
            /// enable USB endpoint 4 receiving (OUT)
            RB_UEP4_RX_EN: u1 = 0,
            /// RB_UEP1_BUF_MOD [4:4]
            /// buffer mode of USB endpoint 1
            RB_UEP1_BUF_MOD: u1 = 0,
            /// unused [5:5]
            _unused5: u1 = 0,
            /// RB_UEP1_TX_EN [6:6]
            /// enable USB endpoint 1 transmittal (IN)
            RB_UEP1_TX_EN: u1 = 0,
            /// RB_UEP1_RX_EN [7:7]
            /// enable USB endpoint 1 receiving (OUT)
            RB_UEP1_RX_EN: u1 = 0,
        }, nullable_types.USBFS.R8_UEP4_1_MOD),

        /// endpoint 2/3 mode;host endpoint mode
        R8_UEP2_3_MOD__R8_UH_EP_MOD: RegisterRW(packed struct(u8) {
            /// RB_UEP2_BUF_MOD__RB_UH_EP_RBUF_MOD [0:0]
            /// buffer mode of USB endpoint 2;buffer mode of USB host IN endpoint
            RB_UEP2_BUF_MOD__RB_UH_EP_RBUF_MOD: u1 = 0,
            /// unused [1:1]
            _unused1: u1 = 0,
            /// RB_UEP2_TX_EN [2:2]
            /// enable USB endpoint 2 transmittal (IN)
            RB_UEP2_TX_EN: u1 = 0,
            /// RB_UEP2_RX_EN__RB_UH_EP_RX_EN [3:3]
            /// enable USB endpoint 2 receiving (OUT);enable USB host IN endpoint receiving
            RB_UEP2_RX_EN__RB_UH_EP_RX_EN: u1 = 0,
            /// RB_UEP3_BUF_MOD__RB_UH_EP_TBUF_MOD [4:4]
            /// buffer mode of USB endpoint 3;buffer mode of USB host OUT endpoint
            RB_UEP3_BUF_MOD__RB_UH_EP_TBUF_MOD: u1 = 0,
            /// unused [5:5]
            _unused5: u1 = 0,
            /// RB_UEP3_TX_EN__RB_UH_EP_TX_EN [6:6]
            /// enable USB endpoint 3 transmittal (IN);enable USB host OUT endpoint transmittal
            RB_UEP3_TX_EN__RB_UH_EP_TX_EN: u1 = 0,
            /// RB_UEP3_RX_EN [7:7]
            /// enable USB endpoint 3 receiving (OUT)
            RB_UEP3_RX_EN: u1 = 0,
        }, nullable_types.USBFS.R8_UEP2_3_MOD__R8_UH_EP_MOD),

        /// offset 0x2
        _offset10: [2]u8,

        /// endpoint 0 DMA buffer address
        R16_UEP0_DMA: RegisterRW(packed struct(u16) {
            /// padding [0:15]
            _padding: u16 = 0,
        }, nullable_types.USBFS.R16_UEP0_DMA),

        /// offset 0x2
        _offset11: [2]u8,

        /// endpoint 1 DMA buffer address
        R16_UEP1_DMA: RegisterRW(packed struct(u16) {
            /// padding [0:15]
            _padding: u16 = 0,
        }, nullable_types.USBFS.R16_UEP1_DMA),

        /// offset 0x2
        _offset12: [2]u8,

        /// endpoint 2 DMA buffer address;host rx endpoint buffer high address
        R16_UEP2_DMA__R16_UH_RX_DMA: RegisterRW(packed struct(u16) {
            /// padding [0:15]
            _padding: u16 = 0,
        }, nullable_types.USBFS.R16_UEP2_DMA__R16_UH_RX_DMA),

        /// offset 0x2
        _offset13: [2]u8,

        /// endpoint 3 DMA buffer address;host tx endpoint buffer high address
        R16_UEP3_DMA__R16_UH_TX_DMA: RegisterRW(packed struct(u16) {
            /// padding [0:15]
            _padding: u16 = 0,
        }, nullable_types.USBFS.R16_UEP3_DMA__R16_UH_TX_DMA),

        /// offset 0x2
        _offset14: [2]u8,

        /// endpoint 0 transmittal length
        R8_UEP0_T_LEN: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.USBFS.R8_UEP0_T_LEN),

        /// offset 0x1
        _offset15: [1]u8,

        /// endpoint 0 control
        R8_UEP0_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X transmittal (IN)
            MASK_UEP_T_RES: u2 = 0,
            /// MASK_UEP_R_RES [2:3]
            /// bit mask of handshake response type for USB endpoint X receiving (OUT)
            MASK_UEP_R_RES: u2 = 0,
            /// RB_UEP_AUTO_TOG [4:4]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG: u1 = 0,
            /// unused [5:5]
            _unused5: u1 = 0,
            /// RB_UEP_T_TOG [6:6]
            /// prepared data toggle flag of USB endpoint X transmittal (IN): 0=DATA0, 1=DATA1
            RB_UEP_T_TOG: u1 = 0,
            /// RB_UEP_R_TOG [7:7]
            /// expected data toggle flag of USB endpoint X receiving (OUT): 0=DATA0, 1=DATA1
            RB_UEP_R_TOG: u1 = 0,
        }, nullable_types.USBFS.R8_UEP0_CTRL),

        /// offset 0x1
        _offset16: [1]u8,

        /// endpoint 1 transmittal length
        R8_UEP1_T_LEN: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.USBFS.R8_UEP1_T_LEN),

        /// offset 0x1
        _offset17: [1]u8,

        /// endpoint 1 control;host aux setup
        R8_UEP1_CTRL__R8_UH_SETUP: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X transmittal (IN)
            MASK_UEP_T_RES: u2 = 0,
            /// MASK_UEP_R_RES [2:3]
            /// bit mask of handshake response type for USB endpoint X receiving (OUT)
            MASK_UEP_R_RES: u2 = 0,
            /// RB_UEP_AUTO_TOG [4:4]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG: u1 = 0,
            /// unused [5:5]
            _unused5: u1 = 0,
            /// RB_UEP_T_TOG__RB_UH_SOF_EN [6:6]
            /// prepared data toggle flag of USB endpoint X transmittal (IN): 0=DATA0, 1=DATA1;USB host automatic SOF enable
            RB_UEP_T_TOG__RB_UH_SOF_EN: u1 = 0,
            /// RB_UEP_R_TOG__RB_UH_PRE_PID_EN [7:7]
            /// expected data toggle flag of USB endpoint X receiving (OUT): 0=DATA0, 1=DATA1;RB_UH_PRE_PID_EN;USB host PRE PID enable for low speed device via hub
            RB_UEP_R_TOG__RB_UH_PRE_PID_EN: u1 = 0,
        }, nullable_types.USBFS.R8_UEP1_CTRL__R8_UH_SETUP),

        /// offset 0x1
        _offset18: [1]u8,

        /// endpoint 2 transmittal length;host endpoint and PID
        R8_UEP2_T_LEN__R8_UH_EP_PID: RegisterRW(packed struct(u8) {
            /// MASK_UH_ENDP [0:3]
            /// bit mask of endpoint number for USB host transfer
            MASK_UH_ENDP: u4 = 0,
            /// MASK_UH_TOKEN [4:7]
            /// bit mask of token PID for USB host transfer
            MASK_UH_TOKEN: u4 = 0,
        }, nullable_types.USBFS.R8_UEP2_T_LEN__R8_UH_EP_PID),

        /// offset 0x1
        _offset19: [1]u8,

        /// endpoint 2 control;host receiver endpoint control
        R8_UEP2_CTRL__R8_UH_RX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X transmittal (IN)
            MASK_UEP_T_RES: u2 = 0,
            /// MASK_UEP_R_RES [2:3]
            /// bit mask of handshake response type for USB endpoint X receiving (OUT)
            MASK_UEP_R_RES: u2 = 0,
            /// RB_UEP_AUTO_TOG__RB_UH_R_AUTO_TOG [4:4]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle;enable automatic toggle after successful transfer completion: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG__RB_UH_R_AUTO_TOG: u1 = 0,
            /// unused [5:5]
            _unused5: u1 = 0,
            /// RB_UEP_T_TOG [6:6]
            /// prepared data toggle flag of USB endpoint X transmittal (IN): 0=DATA0, 1=DATA1
            RB_UEP_T_TOG: u1 = 0,
            /// RB_UEP_R_TOG__RB_UH_R_TOG [7:7]
            /// expected data toggle flag of USB endpoint X receiving (OUT): 0=DATA0, 1=DATA1;expected data toggle flag of host receiving (IN): 0=DATA0, 1=DATA1
            RB_UEP_R_TOG__RB_UH_R_TOG: u1 = 0,
        }, nullable_types.USBFS.R8_UEP2_CTRL__R8_UH_RX_CTRL),

        /// offset 0x1
        _offset20: [1]u8,

        /// endpoint 3 transmittal length;host transmittal endpoint transmittal length
        R8_UEP3_T_LEN__R8_UH_TX_LEN: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.USBFS.R8_UEP3_T_LEN__R8_UH_TX_LEN),

        /// offset 0x1
        _offset21: [1]u8,

        /// endpoint 3 control;host transmittal endpoint control
        R8_UEP3_CTRL__R8_UH_TX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X transmittal (IN)
            MASK_UEP_T_RES: u2 = 0,
            /// MASK_UEP_R_RES [2:3]
            /// bit mask of handshake response type for USB endpoint X receiving (OUT)
            MASK_UEP_R_RES: u2 = 0,
            /// RB_UEP_AUTO_TOG [4:4]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG: u1 = 0,
            /// unused [5:5]
            _unused5: u1 = 0,
            /// RB_UEP_T_TOG [6:6]
            /// prepared data toggle flag of USB endpoint X transmittal (IN): 0=DATA0, 1=DATA1
            RB_UEP_T_TOG: u1 = 0,
            /// RB_UEP_R_TOG [7:7]
            /// expected data toggle flag of USB endpoint X receiving (OUT): 0=DATA0, 1=DATA1
            RB_UEP_R_TOG: u1 = 0,
        }, nullable_types.USBFS.R8_UEP3_CTRL__R8_UH_TX_CTRL),

        /// offset 0x1
        _offset22: [1]u8,

        /// endpoint 4 transmittal length
        R8_UEP4_T_LEN: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }, nullable_types.USBFS.R8_UEP4_T_LEN),

        /// offset 0x1
        _offset23: [1]u8,

        /// endpoint 4 control
        R8_UEP4_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X transmittal (IN)
            MASK_UEP_T_RES: u2 = 0,
            /// MASK_UEP_R_RES [2:3]
            /// bit mask of handshake response type for USB endpoint X receiving (OUT)
            MASK_UEP_R_RES: u2 = 0,
            /// RB_UEP_AUTO_TOG [4:4]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG: u1 = 0,
            /// unused [5:5]
            _unused5: u1 = 0,
            /// RB_UEP_T_TOG [6:6]
            /// prepared data toggle flag of USB endpoint X transmittal (IN): 0=DATA0, 1=DATA1
            RB_UEP_T_TOG: u1 = 0,
            /// RB_UEP_R_TOG [7:7]
            /// expected data toggle flag of USB endpoint X receiving (OUT): 0=DATA0, 1=DATA1
            RB_UEP_R_TOG: u1 = 0,
        }, nullable_types.USBFS.R8_UEP4_CTRL),

        /// offset 0x5
        _offset24: [5]u8,

        /// USB type-C control
        R8_USB_TYPE_C_CTRL: RegisterRW(packed struct(u8) {
            /// RB_UCC1_PU_EN [0:1]
            /// USB CC1 pullup resistance control
            RB_UCC1_PU_EN: u2 = 0,
            /// RB_UCC1_PD_EN [2:2]
            /// USB CC1 5.1K pulldown resistance: 0=disable, 1=enable pulldown
            RB_UCC1_PD_EN: u1 = 0,
            /// RB_VBUS_PD_EN [3:3]
            /// USB VBUS 10K pulldown resistance: 0=disable, 1=enable pullup
            RB_VBUS_PD_EN: u1 = 0,
            /// RB_UCC2_PU_EN [4:5]
            /// USB CC2 pullup resistance control
            RB_UCC2_PU_EN: u2 = 0,
            /// RB_UCC2_PD_EN [6:6]
            /// USB CC2 5.1K pulldown resistance: 0=disable, 1=enable pulldown
            RB_UCC2_PD_EN: u1 = 0,
            /// RB_UTCC_GP_BIT [7:7]
            /// USB general purpose bit
            RB_UTCC_GP_BIT: u1 = 0,
        }, nullable_types.USBFS.R8_USB_TYPE_C_CTRL),
    };

    /// CRC calculation unit
    pub const CRC = extern struct {
        pub inline fn from(base: u32) *volatile types.CRC {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.CRC) u32 {
            return @intFromPtr(self);
        }

        /// Data register
        DATAR: RegisterRW(packed struct(u32) {
            /// DATA [0:31]
            /// Data Register
            DATA: u32 = 4294967295,
        }, nullable_types.CRC.DATAR),

        /// Independent Data register
        IDATAR: RegisterRW(packed struct(u8) {
            /// IDATA [0:7]
            /// Independent Data register
            IDATA: u8 = 0,
        }, nullable_types.CRC.IDATAR),

        /// offset 0x3
        _offset2: [3]u8,

        /// Control register
        CTLR: RegisterRW(packed struct(u32) {
            /// RST [0:0]
            /// Reset bit
            RST: u1 = 0,
            /// padding [1:31]
            _padding: u31 = 0,
        }, nullable_types.CRC.CTLR),
    };

    /// FLASH
    pub const FLASH = extern struct {
        pub inline fn from(base: u32) *volatile types.FLASH {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.FLASH) u32 {
            return @intFromPtr(self);
        }

        /// Flash access control register
        ACTLR: RegisterRW(packed struct(u32) {
            /// LATENCY [0:2]
            /// Latency
            LATENCY: u3 = 0,
            /// unused [3:3]
            _unused3: u1 = 0,
            /// PRFTBE [4:4]
            /// Prefetch buffer enable
            PRFTBE: u1 = 1,
            /// PRFTBS [5:5]
            /// Prefetch buffer status
            PRFTBS: u1 = 1,
            /// padding [6:31]
            _padding: u26 = 0,
        }, nullable_types.FLASH.ACTLR),

        /// Flash key register
        KEYR: RegisterRW(packed struct(u32) {
            /// KEYR [0:31]
            /// FPEC key
            KEYR: u32 = 0,
        }, nullable_types.FLASH.KEYR),

        /// Flash option key register
        OBKEYR: RegisterRW(packed struct(u32) {
            /// OBKEYR [0:31]
            /// Option byte key
            OBKEYR: u32 = 0,
        }, nullable_types.FLASH.OBKEYR),

        /// Status register
        STATR: RegisterRW(packed struct(u32) {
            /// BSY [0:0]
            /// Busy
            BSY: u1 = 0,
            /// unused [1:1]
            _unused1: u1 = 0,
            /// PGERR [2:2]
            /// Programming error
            PGERR: u1 = 0,
            /// unused [3:3]
            _unused3: u1 = 0,
            /// WRPRTERR [4:4]
            /// Write protection error
            WRPRTERR: u1 = 0,
            /// EOP [5:5]
            /// End of operation
            EOP: u1 = 0,
            /// padding [6:31]
            _padding: u26 = 0,
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
            /// OPTWRE [9:9]
            /// Option bytes write enable
            OPTWRE: u1 = 0,
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
            /// FAST programming lock
            FLOCK: u1 = 0,
            /// FTPG [16:16]
            /// execute fast programming
            FTPG: u1 = 0,
            /// FTER [17:17]
            /// execute fast 128byte erase
            FTER: u1 = 0,
            /// BUFLOAD [18:18]
            /// execute data load inner buffer
            BUFLOAD: u1 = 0,
            /// BUFRST [19:19]
            /// execute inner buffer reset
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
            /// OPTERR [0:0]
            /// Option byte error
            OPTERR: u1 = 0,
            /// RDPRT [1:1]
            /// Read protection
            RDPRT: u1 = 0,
            /// IWDGSW [2:2]
            /// IWDG_SW
            IWDGSW: u1 = 1,
            /// STOPRST [3:3]
            /// nRST_STOP
            STOPRST: u1 = 1,
            /// STANDYRST [4:4]
            /// nRST_STDBY
            STANDYRST: u1 = 1,
            /// USBDMODE [5:5]
            /// USBD compatible speed mode configure
            USBDMODE: u1 = 1,
            /// USBDPU [6:6]
            /// USBD compatible inner pull up resistance configure
            USBDPU: u1 = 1,
            /// PORCTR [7:7]
            /// Power on reset time
            PORCTR: u1 = 1,
            /// padding [8:31]
            _padding: u24 = 262143,
        }, nullable_types.FLASH.OBR),

        /// Write protection register
        WPR: RegisterRW(packed struct(u32) {
            /// WRP [0:31]
            /// Write protect
            WRP: u32 = 0,
        }, nullable_types.FLASH.WPR),

        /// Extension key register
        MODEKEYR: RegisterRW(packed struct(u32) {
            /// MODEKEYR [0:31]
            /// high speed write /erase mode ENABLE
            MODEKEYR: u32 = 0,
        }, nullable_types.FLASH.MODEKEYR),
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
            INTENSTA2_3: u2 = 0,
            /// unused [4:11]
            _unused4: u4 = 0,
            _unused8: u4 = 0,
            /// INTENSTA12_31 [12:31]
            /// Interrupt ID Status
            INTENSTA12_31: u20 = 0,
        }, nullable_types.PFIC.ISR1),

        /// Interrupt Status Register
        ISR2: RegisterRW(packed struct(u32) {
            /// INTENSTA [0:27]
            /// Interrupt ID Status
            INTENSTA: u28 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
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
            /// PENDSTA12_31 [12:31]
            /// PENDSTA
            PENDSTA12_31: u20 = 0,
        }, nullable_types.PFIC.IPR1),

        /// Interrupt Pending Register
        IPR2: RegisterRW(packed struct(u32) {
            /// PENDSTA [0:27]
            /// PENDSTA
            PENDSTA: u28 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
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

        /// Interrupt Fast Address Register
        FIBADDRR: RegisterRW(packed struct(u32) {
            /// unused [0:27]
            _unused0: u8 = 0,
            _unused8: u8 = 0,
            _unused16: u8 = 0,
            _unused24: u4 = 0,
            /// BASEADDR [28:31]
            /// BASEADDR
            BASEADDR: u4 = 0,
        }, nullable_types.PFIC.FIBADDRR),

        /// Interrupt Config Register
        CFGR: RegisterRW(packed struct(u32) {
            /// HWSTKCTRL [0:0]
            /// HWSTKCTRL
            HWSTKCTRL: u1 = 0,
            /// NESTCTRL [1:1]
            /// NESTCTRL
            NESTCTRL: u1 = 0,
            /// NMISET [2:2]
            /// NMISET
            NMISET: u1 = 0,
            /// NMIRESET [3:3]
            /// NMIRESET
            NMIRESET: u1 = 0,
            /// EXCSET [4:4]
            /// EXCSET
            EXCSET: u1 = 0,
            /// EXCRESET [5:5]
            /// EXCRESET
            EXCRESET: u1 = 0,
            /// PFICRSET [6:6]
            /// PFICRSET
            PFICRSET: u1 = 0,
            /// SYSRESET [7:7]
            /// SYSRESET
            SYSRESET: u1 = 0,
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

        /// offset 0x10
        _offset8: [16]u8,

        /// Interrupt 0 address Register
        FIFOADDRR0: RegisterRW(packed struct(u32) {
            /// OFFADDR0 [0:23]
            /// OFFADDR0
            OFFADDR0: u24 = 0,
            /// IRQID0 [24:31]
            /// IRQID0
            IRQID0: u8 = 0,
        }, nullable_types.PFIC.FIFOADDRR0),

        /// Interrupt 1 address Register
        FIFOADDRR1: RegisterRW(packed struct(u32) {
            /// OFFADDR1 [0:23]
            /// OFFADDR1
            OFFADDR1: u24 = 0,
            /// IRQID1 [24:31]
            /// IRQID1
            IRQID1: u8 = 0,
        }, nullable_types.PFIC.FIFOADDRR1),

        /// Interrupt 2 address Register
        FIFOADDRR2: RegisterRW(packed struct(u32) {
            /// OFFADDR2 [0:23]
            /// OFFADDR2
            OFFADDR2: u24 = 0,
            /// IRQID2 [24:31]
            /// IRQID2
            IRQID2: u8 = 0,
        }, nullable_types.PFIC.FIFOADDRR2),

        /// Interrupt 3 address Register
        FIFOADDRR3: RegisterRW(packed struct(u32) {
            /// OFFADDR3 [0:23]
            /// OFFADDR3
            OFFADDR3: u24 = 0,
            /// IRQID3 [24:31]
            /// IRQID3
            IRQID3: u8 = 0,
        }, nullable_types.PFIC.FIFOADDRR3),

        /// offset 0x90
        _offset12: [144]u8,

        /// Interrupt Setting Register
        IENR1: RegisterRW(packed struct(u32) {
            /// unused [0:11]
            _unused0: u8 = 0,
            _unused8: u4 = 0,
            /// INTEN [12:31]
            /// INTEN
            INTEN: u20 = 0,
        }, nullable_types.PFIC.IENR1),

        /// Interrupt Setting Register
        IENR2: RegisterRW(packed struct(u32) {
            /// INTEN [0:27]
            /// INTEN
            INTEN: u28 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
        }, nullable_types.PFIC.IENR2),

        /// offset 0x78
        _offset14: [120]u8,

        /// Interrupt Clear Register
        IRER1: RegisterRW(packed struct(u32) {
            /// unused [0:11]
            _unused0: u8 = 0,
            _unused8: u4 = 0,
            /// INTRSET [12:31]
            /// INTRSET
            INTRSET: u20 = 0,
        }, nullable_types.PFIC.IRER1),

        /// Interrupt Clear Register
        IRER2: RegisterRW(packed struct(u32) {
            /// INTRSET [0:27]
            /// INTRSET
            INTRSET: u28 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
        }, nullable_types.PFIC.IRER2),

        /// offset 0x78
        _offset16: [120]u8,

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
            /// PENDSET12_31 [12:31]
            /// PENDSET
            PENDSET12_31: u20 = 0,
        }, nullable_types.PFIC.IPSR1),

        /// Interrupt Pending Register
        IPSR2: RegisterRW(packed struct(u32) {
            /// PENDSET [0:27]
            /// PENDSET
            PENDSET: u28 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
        }, nullable_types.PFIC.IPSR2),

        /// offset 0x78
        _offset18: [120]u8,

        /// Interrupt Pending Clear Register
        IPRR1: RegisterRW(packed struct(u32) {
            /// unused [0:1]
            _unused0: u2 = 0,
            /// PENDRESET2_3 [2:3]
            /// PENDRESET
            PENDRESET2_3: u2 = 0,
            /// unused [4:11]
            _unused4: u4 = 0,
            _unused8: u4 = 0,
            /// PENDRESET12_31 [12:31]
            /// PENDRESET
            PENDRESET12_31: u20 = 0,
        }, nullable_types.PFIC.IPRR1),

        /// Interrupt Pending Clear Register
        IPRR2: RegisterRW(packed struct(u32) {
            /// PENDRESET [0:27]
            /// PENDRESET
            PENDRESET: u28 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
        }, nullable_types.PFIC.IPRR2),

        /// offset 0x78
        _offset20: [120]u8,

        /// Interrupt ACTIVE Register
        IACTR1: RegisterRW(packed struct(u32) {
            /// unused [0:11]
            _unused0: u8 = 0,
            _unused8: u4 = 0,
            /// IACTS [12:31]
            /// IACTS
            IACTS: u20 = 0,
        }, nullable_types.PFIC.IACTR1),

        /// Interrupt ACTIVE Register
        IACTR2: RegisterRW(packed struct(u32) {
            /// IACTS [0:27]
            /// IACTS
            IACTS: u28 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
        }, nullable_types.PFIC.IACTR2),

        /// offset 0xa08
        _offset22: [2568]u8,

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
            /// padding [6:31]
            _padding: u26 = 0,
        }, nullable_types.PFIC.SCTLR),

        /// offset 0x2ec
        _offset23: [748]u8,

        /// System counting Control Register
        STK_CTLR: RegisterRW(packed struct(u32) {
            /// STE [0:27]
            /// STE
            STE: u28 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
        }, nullable_types.PFIC.STK_CTLR),
    };

    /// Universal serial bus full-speed device interface
    pub const USBD = extern struct {
        pub inline fn from(base: u32) *volatile types.USBD {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.USBD) u32 {
            return @intFromPtr(self);
        }

        /// endpoint 0 register
        EPR0: RegisterRW(packed struct(u16) {
            /// EA [0:3]
            /// Endpoint address
            EA: u4 = 0,
            /// STAT_TX [4:5]
            /// Status bits, for transmission transfers
            STAT_TX: u2 = 0,
            /// DTOG_TX [6:6]
            /// Data Toggle, for transmission transfers
            DTOG_TX: u1 = 0,
            /// CTR_TX [7:7]
            /// Correct Transfer for transmission
            CTR_TX: u1 = 0,
            /// EP_KIND [8:8]
            /// Endpoint kind
            EP_KIND: u1 = 0,
            /// EP_TYPE [9:10]
            /// Endpoint type
            EP_TYPE: u2 = 0,
            /// SETUP [11:11]
            /// Setup transaction completed
            SETUP: u1 = 0,
            /// STAT_RX [12:13]
            /// Status bits, for reception transfers
            STAT_RX: u2 = 0,
            /// DTOG_RX [14:14]
            /// Data Toggle, for reception transfers
            DTOG_RX: u1 = 0,
            /// CTR_RX [15:15]
            /// Correct transfer for reception
            CTR_RX: u1 = 0,
        }, nullable_types.USBD.EPR0),

        /// offset 0x2
        _offset1: [2]u8,

        /// endpoint 1 register
        EPR1: RegisterRW(packed struct(u16) {
            /// EA [0:3]
            /// Endpoint address
            EA: u4 = 0,
            /// STAT_TX [4:5]
            /// Status bits, for transmission transfers
            STAT_TX: u2 = 0,
            /// DTOG_TX [6:6]
            /// Data Toggle, for transmission transfers
            DTOG_TX: u1 = 0,
            /// CTR_TX [7:7]
            /// Correct Transfer for transmission
            CTR_TX: u1 = 0,
            /// EP_KIND [8:8]
            /// Endpoint kind
            EP_KIND: u1 = 0,
            /// EP_TYPE [9:10]
            /// Endpoint type
            EP_TYPE: u2 = 0,
            /// SETUP [11:11]
            /// Setup transaction completed
            SETUP: u1 = 0,
            /// STAT_RX [12:13]
            /// Status bits, for reception transfers
            STAT_RX: u2 = 0,
            /// DTOG_RX [14:14]
            /// Data Toggle, for reception transfers
            DTOG_RX: u1 = 0,
            /// CTR_RX [15:15]
            /// Correct transfer for reception
            CTR_RX: u1 = 0,
        }, nullable_types.USBD.EPR1),

        /// offset 0x2
        _offset2: [2]u8,

        /// endpoint 2 register
        EPR2: RegisterRW(packed struct(u16) {
            /// EA [0:3]
            /// Endpoint address
            EA: u4 = 0,
            /// STAT_TX [4:5]
            /// Status bits, for transmission transfers
            STAT_TX: u2 = 0,
            /// DTOG_TX [6:6]
            /// Data Toggle, for transmission transfers
            DTOG_TX: u1 = 0,
            /// CTR_TX [7:7]
            /// Correct Transfer for transmission
            CTR_TX: u1 = 0,
            /// EP_KIND [8:8]
            /// Endpoint kind
            EP_KIND: u1 = 0,
            /// EP_TYPE [9:10]
            /// Endpoint type
            EP_TYPE: u2 = 0,
            /// SETUP [11:11]
            /// Setup transaction completed
            SETUP: u1 = 0,
            /// STAT_RX [12:13]
            /// Status bits, for reception transfers
            STAT_RX: u2 = 0,
            /// DTOG_RX [14:14]
            /// Data Toggle, for reception transfers
            DTOG_RX: u1 = 0,
            /// CTR_RX [15:15]
            /// Correct transfer for reception
            CTR_RX: u1 = 0,
        }, nullable_types.USBD.EPR2),

        /// offset 0x2
        _offset3: [2]u8,

        /// endpoint 3 register
        EPR3: RegisterRW(packed struct(u16) {
            /// EA [0:3]
            /// Endpoint address
            EA: u4 = 0,
            /// STAT_TX [4:5]
            /// Status bits, for transmission transfers
            STAT_TX: u2 = 0,
            /// DTOG_TX [6:6]
            /// Data Toggle, for transmission transfers
            DTOG_TX: u1 = 0,
            /// CTR_TX [7:7]
            /// Correct Transfer for transmission
            CTR_TX: u1 = 0,
            /// EP_KIND [8:8]
            /// Endpoint kind
            EP_KIND: u1 = 0,
            /// EP_TYPE [9:10]
            /// Endpoint type
            EP_TYPE: u2 = 0,
            /// SETUP [11:11]
            /// Setup transaction completed
            SETUP: u1 = 0,
            /// STAT_RX [12:13]
            /// Status bits, for reception transfers
            STAT_RX: u2 = 0,
            /// DTOG_RX [14:14]
            /// Data Toggle, for reception transfers
            DTOG_RX: u1 = 0,
            /// CTR_RX [15:15]
            /// Correct transfer for reception
            CTR_RX: u1 = 0,
        }, nullable_types.USBD.EPR3),

        /// offset 0x2
        _offset4: [2]u8,

        /// endpoint 4 register
        EPR4: RegisterRW(packed struct(u16) {
            /// EA [0:3]
            /// Endpoint address
            EA: u4 = 0,
            /// STAT_TX [4:5]
            /// Status bits, for transmission transfers
            STAT_TX: u2 = 0,
            /// DTOG_TX [6:6]
            /// Data Toggle, for transmission transfers
            DTOG_TX: u1 = 0,
            /// CTR_TX [7:7]
            /// Correct Transfer for transmission
            CTR_TX: u1 = 0,
            /// EP_KIND [8:8]
            /// Endpoint kind
            EP_KIND: u1 = 0,
            /// EP_TYPE [9:10]
            /// Endpoint type
            EP_TYPE: u2 = 0,
            /// SETUP [11:11]
            /// Setup transaction completed
            SETUP: u1 = 0,
            /// STAT_RX [12:13]
            /// Status bits, for reception transfers
            STAT_RX: u2 = 0,
            /// DTOG_RX [14:14]
            /// Data Toggle, for reception transfers
            DTOG_RX: u1 = 0,
            /// CTR_RX [15:15]
            /// Correct transfer for reception
            CTR_RX: u1 = 0,
        }, nullable_types.USBD.EPR4),

        /// offset 0x2
        _offset5: [2]u8,

        /// endpoint 5 register
        EPR5: RegisterRW(packed struct(u16) {
            /// EA [0:3]
            /// Endpoint address
            EA: u4 = 0,
            /// STAT_TX [4:5]
            /// Status bits, for transmission transfers
            STAT_TX: u2 = 0,
            /// DTOG_TX [6:6]
            /// Data Toggle, for transmission transfers
            DTOG_TX: u1 = 0,
            /// CTR_TX [7:7]
            /// Correct Transfer for transmission
            CTR_TX: u1 = 0,
            /// EP_KIND [8:8]
            /// Endpoint kind
            EP_KIND: u1 = 0,
            /// EP_TYPE [9:10]
            /// Endpoint type
            EP_TYPE: u2 = 0,
            /// SETUP [11:11]
            /// Setup transaction completed
            SETUP: u1 = 0,
            /// STAT_RX [12:13]
            /// Status bits, for reception transfers
            STAT_RX: u2 = 0,
            /// DTOG_RX [14:14]
            /// Data Toggle, for reception transfers
            DTOG_RX: u1 = 0,
            /// CTR_RX [15:15]
            /// Correct transfer for reception
            CTR_RX: u1 = 0,
        }, nullable_types.USBD.EPR5),

        /// offset 0x2
        _offset6: [2]u8,

        /// endpoint 6 register
        EPR6: RegisterRW(packed struct(u16) {
            /// EA [0:3]
            /// Endpoint address
            EA: u4 = 0,
            /// STAT_TX [4:5]
            /// Status bits, for transmission transfers
            STAT_TX: u2 = 0,
            /// DTOG_TX [6:6]
            /// Data Toggle, for transmission transfers
            DTOG_TX: u1 = 0,
            /// CTR_TX [7:7]
            /// Correct Transfer for transmission
            CTR_TX: u1 = 0,
            /// EP_KIND [8:8]
            /// Endpoint kind
            EP_KIND: u1 = 0,
            /// EP_TYPE [9:10]
            /// Endpoint type
            EP_TYPE: u2 = 0,
            /// SETUP [11:11]
            /// Setup transaction completed
            SETUP: u1 = 0,
            /// STAT_RX [12:13]
            /// Status bits, for reception transfers
            STAT_RX: u2 = 0,
            /// DTOG_RX [14:14]
            /// Data Toggle, for reception transfers
            DTOG_RX: u1 = 0,
            /// CTR_RX [15:15]
            /// Correct transfer for reception
            CTR_RX: u1 = 0,
        }, nullable_types.USBD.EPR6),

        /// offset 0x2
        _offset7: [2]u8,

        /// endpoint 7 register
        EPR7: RegisterRW(packed struct(u16) {
            /// EA [0:3]
            /// Endpoint address
            EA: u4 = 0,
            /// STAT_TX [4:5]
            /// Status bits, for transmission transfers
            STAT_TX: u2 = 0,
            /// DTOG_TX [6:6]
            /// Data Toggle, for transmission transfers
            DTOG_TX: u1 = 0,
            /// CTR_TX [7:7]
            /// Correct Transfer for transmission
            CTR_TX: u1 = 0,
            /// EP_KIND [8:8]
            /// Endpoint kind
            EP_KIND: u1 = 0,
            /// EP_TYPE [9:10]
            /// Endpoint type
            EP_TYPE: u2 = 0,
            /// SETUP [11:11]
            /// Setup transaction completed
            SETUP: u1 = 0,
            /// STAT_RX [12:13]
            /// Status bits, for reception transfers
            STAT_RX: u2 = 0,
            /// DTOG_RX [14:14]
            /// Data Toggle, for reception transfers
            DTOG_RX: u1 = 0,
            /// CTR_RX [15:15]
            /// Correct transfer for reception
            CTR_RX: u1 = 0,
        }, nullable_types.USBD.EPR7),

        /// offset 0x22
        _offset8: [34]u8,

        /// control register
        CNTR: RegisterRW(packed struct(u16) {
            /// FRES [0:0]
            /// Force USB Reset
            FRES: u1 = 1,
            /// PDWN [1:1]
            /// Power down
            PDWN: u1 = 1,
            /// LPMODE [2:2]
            /// Low-power mode
            LPMODE: u1 = 0,
            /// FSUSP [3:3]
            /// Force suspend
            FSUSP: u1 = 0,
            /// RESUME [4:4]
            /// Resume request
            RESUME: u1 = 0,
            /// unused [5:7]
            _unused5: u3 = 0,
            /// ESOFM [8:8]
            /// Expected start of frame interrupt mask
            ESOFM: u1 = 0,
            /// SOFM [9:9]
            /// Start of frame interrupt mask
            SOFM: u1 = 0,
            /// RESETM [10:10]
            /// USB reset interrupt mask
            RESETM: u1 = 0,
            /// SUSPM [11:11]
            /// Suspend mode interrupt mask
            SUSPM: u1 = 0,
            /// WKUPM [12:12]
            /// Wakeup interrupt mask
            WKUPM: u1 = 0,
            /// ERRM [13:13]
            /// Error interrupt mask
            ERRM: u1 = 0,
            /// PMAOVRM [14:14]
            /// Packet memory area over / underrun interrupt mask
            PMAOVRM: u1 = 0,
            /// CTRM [15:15]
            /// Correct transfer interrupt mask
            CTRM: u1 = 0,
        }, nullable_types.USBD.CNTR),

        /// offset 0x2
        _offset9: [2]u8,

        /// interrupt status register
        ISTR: RegisterRW(packed struct(u16) {
            /// EP_ID [0:3]
            /// Endpoint Identifier
            EP_ID: u4 = 0,
            /// DIR [4:4]
            /// Direction of transaction
            DIR: u1 = 0,
            /// unused [5:7]
            _unused5: u3 = 0,
            /// ESOF [8:8]
            /// Expected start frame
            ESOF: u1 = 0,
            /// SOF [9:9]
            /// start of frame
            SOF: u1 = 0,
            /// RESET [10:10]
            /// reset request
            RESET: u1 = 0,
            /// SUSP [11:11]
            /// Suspend mode request
            SUSP: u1 = 0,
            /// WKUP [12:12]
            /// Wakeup
            WKUP: u1 = 0,
            /// ERR [13:13]
            /// Error
            ERR: u1 = 0,
            /// PMAOVR [14:14]
            /// Packet memory area over / underrun
            PMAOVR: u1 = 0,
            /// CTR [15:15]
            /// Correct transfer
            CTR: u1 = 0,
        }, nullable_types.USBD.ISTR),

        /// offset 0x2
        _offset10: [2]u8,

        /// frame number register
        FNR: RegisterRW(packed struct(u16) {
            /// FN [0:10]
            /// Frame number
            FN: u11 = 0,
            /// LSOF [11:12]
            /// Lost SOF
            LSOF: u2 = 0,
            /// LCK [13:13]
            /// Locked
            LCK: u1 = 0,
            /// RXDM [14:14]
            /// Receive data - line status
            RXDM: u1 = 0,
            /// RXDP [15:15]
            /// Receive data + line status
            RXDP: u1 = 0,
        }, nullable_types.USBD.FNR),

        /// offset 0x2
        _offset11: [2]u8,

        /// device address
        DADDR: RegisterRW(packed struct(u16) {
            /// ADD [0:6]
            /// Device address
            ADD: u7 = 0,
            /// EF [7:7]
            /// Enable function
            EF: u1 = 0,
            /// padding [8:15]
            _padding: u8 = 0,
        }, nullable_types.USBD.DADDR),

        /// offset 0x2
        _offset12: [2]u8,

        /// Buffer table address
        BTABLE: RegisterRW(packed struct(u16) {
            /// unused [0:2]
            _unused0: u3 = 0,
            /// BTABLE [3:15]
            /// Buffer table
            BTABLE: u13 = 0,
        }, nullable_types.USBD.BTABLE),
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
};

pub const nullable_types = struct {
    /// Power control
    pub const PWR = struct {
        /// Power control register (PWR_CTRL)
        pub const CTLR = struct {
            /// LPDS [0:0]
            /// Low Power Deep Sleep
            LPDS: ?u1 = null,
            /// PDDS [1:1]
            /// Power Down Deep Sleep
            PDDS: ?u1 = null,
            /// CWUF [2:2]
            /// Clear Wake-up Flag
            CWUF: ?u1 = null,
            /// CSBF [3:3]
            /// Clear STANDBY Flag
            CSBF: ?u1 = null,
            /// PVDE [4:4]
            /// Power Voltage Detector Enable
            PVDE: ?u1 = null,
            /// PLS [5:7]
            /// PVD Level Selection
            PLS: ?u3 = null,
            /// DBP [8:8]
            /// Disable Backup Domain write protection
            DBP: ?u1 = null,
        };

        /// Power control register (PWR_CSR)
        pub const CSR = struct {
            /// WUF [0:0]
            /// Wake-Up Flag
            WUF: ?u1 = null,
            /// SBF [1:1]
            /// STANDBY Flag
            SBF: ?u1 = null,
            /// PVDO [2:2]
            /// PVD Output
            PVDO: ?u1 = null,
            /// EWUP [8:8]
            /// Enable WKUP pin
            EWUP: ?u1 = null,
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

        /// Clock configuration register(RCC_CFGR0)
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
            /// PPRE1 [8:10]
            /// PB Low speed prescaler(APB1)
            PPRE1: ?u3 = null,
            /// PPRE2 [11:13]
            /// PB High speed prescaler(APB2)
            PPRE2: ?u3 = null,
            /// ADCPRE [14:15]
            /// ADC prescaler
            ADCPRE: ?u2 = null,
            /// PLLSRC [16:16]
            /// PLL entry clock source
            PLLSRC: ?u1 = null,
            /// PLLXTPRE [17:17]
            /// HSE divider for PLL entry
            PLLXTPRE: ?u1 = null,
            /// PLLMUL [18:21]
            /// PLL Multiplication Factor
            PLLMUL: ?u4 = null,
            /// USBPRE [22:22]
            /// USB prescaler
            USBPRE: ?u1 = null,
            /// MCO [24:26]
            /// Microcontroller clock output
            MCO: ?u3 = null,
        };

        /// Clock interrupt register(RCC_INTR)
        pub const INTR = struct {
            /// LSIRDYF [0:0]
            /// LSI Ready Interrupt flag
            LSIRDYF: ?u1 = null,
            /// LSERDYF [1:1]
            /// LSE Ready Interrupt flag
            LSERDYF: ?u1 = null,
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
            /// LSERDYIE [9:9]
            /// LSE Ready Interrupt Enable
            LSERDYIE: ?u1 = null,
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
            /// LSERDYC [17:17]
            /// LSE Ready Interrupt Clear
            LSERDYC: ?u1 = null,
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

        /// PB2 peripheral reset register(RCC_APB2PRSTR)
        pub const APB2PRSTR = struct {
            /// AFIORST [0:0]
            /// Alternate function I/O reset
            AFIORST: ?u1 = null,
            /// IOPARST [2:2]
            /// IO port A reset
            IOPARST: ?u1 = null,
            /// IOPBRST [3:3]
            /// IO port B reset
            IOPBRST: ?u1 = null,
            /// IOPCRST [4:4]
            /// IO port C reset
            IOPCRST: ?u1 = null,
            /// IOPDRST [5:5]
            /// IO port D reset
            IOPDRST: ?u1 = null,
            /// ADCRST [9:9]
            /// ADC interface reset
            ADCRST: ?u1 = null,
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

        /// PB1 peripheral reset register(RCC_APB1PRSTR)
        pub const APB1PRSTR = struct {
            /// TIM2RST [0:0]
            /// Timer 2 reset
            TIM2RST: ?u1 = null,
            /// TIM3RST [1:1]
            /// Timer 3 reset
            TIM3RST: ?u1 = null,
            /// TIM4RST [2:2]
            /// Timer 4 reset
            TIM4RST: ?u1 = null,
            /// WWDGRST [11:11]
            /// Window watchdog reset
            WWDGRST: ?u1 = null,
            /// SPI2RST [14:14]
            /// SPI2 reset
            SPI2RST: ?u1 = null,
            /// USART2RST [17:17]
            /// USART 2 reset
            USART2RST: ?u1 = null,
            /// USART3RST [18:18]
            /// USART 3 reset
            USART3RST: ?u1 = null,
            /// I2C1RST [21:21]
            /// I2C1 reset
            I2C1RST: ?u1 = null,
            /// I2C2RST [22:22]
            /// I2C2 reset
            I2C2RST: ?u1 = null,
            /// USBDRST [23:23]
            /// USBD reset
            USBDRST: ?u1 = null,
            /// CANRST [25:25]
            /// CAN reset
            CANRST: ?u1 = null,
            /// BKPRST [27:27]
            /// Backup interface reset
            BKPRST: ?u1 = null,
            /// PWRRST [28:28]
            /// Power interface reset
            PWRRST: ?u1 = null,
            /// DACRST [29:29]
            /// DAC interface reset
            DACRST: ?u1 = null,
        };

        /// HB Peripheral Clock enable register(RCC_AHBPCENR)
        pub const AHBPCENR = struct {
            /// DMAEN [0:0]
            /// DMA clock enable
            DMAEN: ?u1 = null,
            /// SRAMEN [2:2]
            /// SRAM interface clock enable
            SRAMEN: ?u1 = null,
            /// FLITFEN [4:4]
            /// FLITF clock enable
            FLITFEN: ?u1 = null,
            /// CRCEN [6:6]
            /// CRC clock enable
            CRCEN: ?u1 = null,
            /// USBHDEN [12:12]
            /// USBHD clock enable
            USBHDEN: ?u1 = null,
        };

        /// PB2 peripheral clock enable register (RCC_APB2PCENR)
        pub const APB2PCENR = struct {
            /// AFIOEN [0:0]
            /// Alternate function I/O clock enable
            AFIOEN: ?u1 = null,
            /// IOPAEN [2:2]
            /// I/O port A clock enable
            IOPAEN: ?u1 = null,
            /// IOPBEN [3:3]
            /// I/O port B clock enable
            IOPBEN: ?u1 = null,
            /// IOPCEN [4:4]
            /// I/O port C clock enable
            IOPCEN: ?u1 = null,
            /// IOPDEN [5:5]
            /// I/O port D clock enable
            IOPDEN: ?u1 = null,
            /// ADCEN [9:9]
            /// ADC interface clock enable
            ADCEN: ?u1 = null,
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
            /// TIM3EN [1:1]
            /// Timer 3 clock enable
            TIM3EN: ?u1 = null,
            /// TIM4EN [2:2]
            /// Timer 4 clock enable
            TIM4EN: ?u1 = null,
            /// WWDGEN [11:11]
            /// Window watchdog clock enable
            WWDGEN: ?u1 = null,
            /// SPI2EN [14:14]
            /// SPI 2 clock enable
            SPI2EN: ?u1 = null,
            /// USART2EN [17:17]
            /// USART 2 clock enable
            USART2EN: ?u1 = null,
            /// USART3EN [18:18]
            /// USART 3 clock enable
            USART3EN: ?u1 = null,
            /// I2C1EN [21:21]
            /// I2C 1 clock enable
            I2C1EN: ?u1 = null,
            /// I2C2EN [22:22]
            /// I2C 2 clock enable
            I2C2EN: ?u1 = null,
            /// USBDEN [23:23]
            /// USBD clock enable
            USBDEN: ?u1 = null,
            /// CANEN [25:25]
            /// CAN clock enable
            CANEN: ?u1 = null,
            /// BKPEN [27:27]
            /// Backup interface clock enable
            BKPEN: ?u1 = null,
            /// PWREN [28:28]
            /// Power interface clock enable
            PWREN: ?u1 = null,
            /// DACEN [29:29]
            /// DAC interface clock enable
            DACEN: ?u1 = null,
        };

        /// Backup domain control register(RCC_BDCTLR)
        pub const BDCTLR = struct {
            /// LSEON [0:0]
            /// External Low Speed oscillator enable
            LSEON: ?u1 = null,
            /// LSERDY [1:1]
            /// External Low Speed oscillator ready
            LSERDY: ?u1 = null,
            /// LSEBYP [2:2]
            /// External Low Speed oscillator bypass
            LSEBYP: ?u1 = null,
            /// RTCSEL [8:9]
            /// RTC clock source selection
            RTCSEL: ?u2 = null,
            /// RTCEN [15:15]
            /// RTC clock enable
            RTCEN: ?u1 = null,
            /// BDRST [16:16]
            /// Backup domain software reset
            BDRST: ?u1 = null,
        };

        /// Control/status register(RCC_RSTSCKR)
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

        /// HB reset register(RCC_APHBRSTR)
        pub const AHBRSTR = struct {
            /// USBHDRST [12:12]
            /// USBHD reset
            USBHDRST: ?u1 = null,
        };
    };

    /// extension configuration
    pub const EXTEND = struct {
        /// EXTEND register
        pub const EXTEND_CTR = struct {
            /// USBDLS [0:0]
            /// USBD Lowspeed Enable
            USBDLS: ?u1 = null,
            /// USBDPU [1:1]
            /// USBD pullup Enable
            USBDPU: ?u1 = null,
            /// USBHDIO [2:2]
            /// USBHD IO(PB6/PB7) Enable
            USBHDIO: ?u1 = null,
            /// USB5VSEL [3:3]
            /// USB 5V Enable
            USB5VSEL: ?u1 = null,
            /// HSIPRE [4:4]
            /// Whether HSI is divided
            HSIPRE: ?u1 = null,
            /// LKUPEN [6:6]
            /// LOCKUP
            LKUPEN: ?u1 = null,
            /// LKUPRST [7:7]
            /// LOCKUP RESET
            LKUPRST: ?u1 = null,
            /// ULLDOTRIM [8:9]
            /// ULLDOTRIM
            ULLDOTRIM: ?u2 = null,
            /// LDOTRIM [10:10]
            /// LDOTRIM
            LDOTRIM: ?u1 = null,
        };
    };

    /// General purpose I/O
    /// Type for: GPIOA GPIOB GPIOC GPIOD
    pub const GPIO = struct {
        /// Port configuration register low(GPIOn_CFGLR)
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

        /// Port configuration register high (GPIOn_CFGHR)
        pub const CFGHR = struct {
            /// MODE8 [0:1]
            /// Port n.8 mode bits
            MODE8: ?u2 = null,
            /// CNF8 [2:3]
            /// Port n.8 configuration bits
            CNF8: ?u2 = null,
            /// MODE9 [4:5]
            /// Port n.9 mode bits
            MODE9: ?u2 = null,
            /// CNF9 [6:7]
            /// Port n.9 configuration bits
            CNF9: ?u2 = null,
            /// MODE10 [8:9]
            /// Port n.10 mode bits
            MODE10: ?u2 = null,
            /// CNF10 [10:11]
            /// Port n.10 configuration bits
            CNF10: ?u2 = null,
            /// MODE11 [12:13]
            /// Port n.11 mode bits
            MODE11: ?u2 = null,
            /// CNF11 [14:15]
            /// Port n.11 configuration bits
            CNF11: ?u2 = null,
            /// MODE12 [16:17]
            /// Port n.12 mode bits
            MODE12: ?u2 = null,
            /// CNF12 [18:19]
            /// Port n.12 configuration bits
            CNF12: ?u2 = null,
            /// MODE13 [20:21]
            /// Port n.13 mode bits
            MODE13: ?u2 = null,
            /// CNF13 [22:23]
            /// Port n.13 configuration bits
            CNF13: ?u2 = null,
            /// MODE14 [24:25]
            /// Port n.14 mode bits
            MODE14: ?u2 = null,
            /// CNF14 [26:27]
            /// Port n.14 configuration bits
            CNF14: ?u2 = null,
            /// MODE15 [28:29]
            /// Port n.15 mode bits
            MODE15: ?u2 = null,
            /// CNF15 [30:31]
            /// Port n.15 configuration bits
            CNF15: ?u2 = null,
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
            /// IDR8 [8:8]
            /// Port input data
            IDR8: ?u1 = null,
            /// IDR9 [9:9]
            /// Port input data
            IDR9: ?u1 = null,
            /// IDR10 [10:10]
            /// Port input data
            IDR10: ?u1 = null,
            /// IDR11 [11:11]
            /// Port input data
            IDR11: ?u1 = null,
            /// IDR12 [12:12]
            /// Port input data
            IDR12: ?u1 = null,
            /// IDR13 [13:13]
            /// Port input data
            IDR13: ?u1 = null,
            /// IDR14 [14:14]
            /// Port input data
            IDR14: ?u1 = null,
            /// IDR15 [15:15]
            /// Port input data
            IDR15: ?u1 = null,
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
            /// ODR8 [8:8]
            /// Port output data
            ODR8: ?u1 = null,
            /// ODR9 [9:9]
            /// Port output data
            ODR9: ?u1 = null,
            /// ODR10 [10:10]
            /// Port output data
            ODR10: ?u1 = null,
            /// ODR11 [11:11]
            /// Port output data
            ODR11: ?u1 = null,
            /// ODR12 [12:12]
            /// Port output data
            ODR12: ?u1 = null,
            /// ODR13 [13:13]
            /// Port output data
            ODR13: ?u1 = null,
            /// ODR14 [14:14]
            /// Port output data
            ODR14: ?u1 = null,
            /// ODR15 [15:15]
            /// Port output data
            ODR15: ?u1 = null,
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
            /// BS8 [8:8]
            /// Set bit 8
            BS8: ?u1 = null,
            /// BS9 [9:9]
            /// Set bit 9
            BS9: ?u1 = null,
            /// BS10 [10:10]
            /// Set bit 10
            BS10: ?u1 = null,
            /// BS11 [11:11]
            /// Set bit 11
            BS11: ?u1 = null,
            /// BS12 [12:12]
            /// Set bit 12
            BS12: ?u1 = null,
            /// BS13 [13:13]
            /// Set bit 13
            BS13: ?u1 = null,
            /// BS14 [14:14]
            /// Set bit 14
            BS14: ?u1 = null,
            /// BS15 [15:15]
            /// Set bit 15
            BS15: ?u1 = null,
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
            /// BR8 [24:24]
            /// Reset bit 8
            BR8: ?u1 = null,
            /// BR9 [25:25]
            /// Reset bit 9
            BR9: ?u1 = null,
            /// BR10 [26:26]
            /// Reset bit 10
            BR10: ?u1 = null,
            /// BR11 [27:27]
            /// Reset bit 11
            BR11: ?u1 = null,
            /// BR12 [28:28]
            /// Reset bit 12
            BR12: ?u1 = null,
            /// BR13 [29:29]
            /// Reset bit 13
            BR13: ?u1 = null,
            /// BR14 [30:30]
            /// Reset bit 14
            BR14: ?u1 = null,
            /// BR15 [31:31]
            /// Reset bit 15
            BR15: ?u1 = null,
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
            /// BR8 [8:8]
            /// Reset bit 8
            BR8: ?u1 = null,
            /// BR9 [9:9]
            /// Reset bit 9
            BR9: ?u1 = null,
            /// BR10 [10:10]
            /// Reset bit 10
            BR10: ?u1 = null,
            /// BR11 [11:11]
            /// Reset bit 11
            BR11: ?u1 = null,
            /// BR12 [12:12]
            /// Reset bit 12
            BR12: ?u1 = null,
            /// BR13 [13:13]
            /// Reset bit 13
            BR13: ?u1 = null,
            /// BR14 [14:14]
            /// Reset bit 14
            BR14: ?u1 = null,
            /// BR15 [15:15]
            /// Reset bit 15
            BR15: ?u1 = null,
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
            /// LCK8 [8:8]
            /// Port A Lock bit 8
            LCK8: ?u1 = null,
            /// LCK9 [9:9]
            /// Port A Lock bit 9
            LCK9: ?u1 = null,
            /// LCK10 [10:10]
            /// Port A Lock bit 10
            LCK10: ?u1 = null,
            /// LCK11 [11:11]
            /// Port A Lock bit 11
            LCK11: ?u1 = null,
            /// LCK12 [12:12]
            /// Port A Lock bit 12
            LCK12: ?u1 = null,
            /// LCK13 [13:13]
            /// Port A Lock bit 13
            LCK13: ?u1 = null,
            /// LCK14 [14:14]
            /// Port A Lock bit 14
            LCK14: ?u1 = null,
            /// LCK15 [15:15]
            /// Port A Lock bit 15
            LCK15: ?u1 = null,
            /// LCKK [16:16]
            /// Lock key
            LCKK: ?u1 = null,
        };
    };

    /// Alternate function I/O
    pub const AFIO = struct {
        /// Event Control Register (AFIO_ECR)
        pub const ECR = struct {
            /// PIN [0:3]
            /// Pin selection
            PIN: ?u4 = null,
            /// PORT [4:6]
            /// Port selection
            PORT: ?u3 = null,
            /// EVOE [7:7]
            /// Event Output Enable
            EVOE: ?u1 = null,
        };

        /// AF remap and debug I/O configuration register (AFIO_PCFR)
        pub const PCFR = struct {
            /// SPI1_RM [0:0]
            /// SPI1 remapping
            SPI1_RM: ?u1 = null,
            /// I2C1_RM [1:1]
            /// I2C1 remapping
            I2C1_RM: ?u1 = null,
            /// USART1_RM [2:2]
            /// USART1 remapping
            USART1_RM: ?u1 = null,
            /// USART2_RM [3:3]
            /// USART2 remapping
            USART2_RM: ?u1 = null,
            /// USART3_RM [4:5]
            /// USART3 remapping
            USART3_RM: ?u2 = null,
            /// TIM1_RM [6:7]
            /// TIM1 remapping
            TIM1_RM: ?u2 = null,
            /// TIM2_RM [8:9]
            /// TIM2 remapping
            TIM2_RM: ?u2 = null,
            /// TIM3_RM [10:11]
            /// TIM3 remapping
            TIM3_RM: ?u2 = null,
            /// CAN_RM [13:14]
            /// CAN1 remapping
            CAN_RM: ?u2 = null,
            /// PD01_RM [15:15]
            /// Port D0/Port D1 mapping on OSCIN/OSCOUT
            PD01_RM: ?u1 = null,
            /// SWCFG [24:26]
            /// Serial wire JTAG configuration
            SWCFG: ?u3 = null,
        };

        /// External interrupt configuration register 1 (AFIO_EXTICR1)
        pub const EXTICR1 = struct {
            /// EXTI0 [0:3]
            /// EXTI0 configuration
            EXTI0: ?u4 = null,
            /// EXTI1 [4:7]
            /// EXTI1 configuration
            EXTI1: ?u4 = null,
            /// EXTI2 [8:11]
            /// EXTI2 configuration
            EXTI2: ?u4 = null,
            /// EXTI3 [12:15]
            /// EXTI3 configuration
            EXTI3: ?u4 = null,
        };

        /// External interrupt configuration register 2 (AFIO_EXTICR2)
        pub const EXTICR2 = struct {
            /// EXTI4 [0:3]
            /// EXTI4 configuration
            EXTI4: ?u4 = null,
            /// EXTI5 [4:7]
            /// EXTI5 configuration
            EXTI5: ?u4 = null,
            /// EXTI6 [8:11]
            /// EXTI6 configuration
            EXTI6: ?u4 = null,
            /// EXTI7 [12:15]
            /// EXTI7 configuration
            EXTI7: ?u4 = null,
        };

        /// External interrupt configuration register 3 (AFIO_EXTICR3)
        pub const EXTICR3 = struct {
            /// EXTI8 [0:3]
            /// EXTI8 configuration
            EXTI8: ?u4 = null,
            /// EXTI9 [4:7]
            /// EXTI9 configuration
            EXTI9: ?u4 = null,
            /// EXTI10 [8:11]
            /// EXTI10 configuration
            EXTI10: ?u4 = null,
            /// EXTI11 [12:15]
            /// EXTI11 configuration
            EXTI11: ?u4 = null,
        };

        /// External interrupt configuration register 4 (AFIO_EXTICR4)
        pub const EXTICR4 = struct {
            /// EXTI12 [0:3]
            /// EXTI12 configuration
            EXTI12: ?u4 = null,
            /// EXTI13 [4:7]
            /// EXTI13 configuration
            EXTI13: ?u4 = null,
            /// EXTI14 [8:11]
            /// EXTI14 configuration
            EXTI14: ?u4 = null,
            /// EXTI15 [12:15]
            /// EXTI15 configuration
            EXTI15: ?u4 = null,
        };
    };

    /// EXTI
    pub const EXTI = struct {
        /// Interrupt mask register(EXTI_INTENR)
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
            /// MR10 [10:10]
            /// Interrupt Mask on line 10
            MR10: ?u1 = null,
            /// MR11 [11:11]
            /// Interrupt Mask on line 11
            MR11: ?u1 = null,
            /// MR12 [12:12]
            /// Interrupt Mask on line 12
            MR12: ?u1 = null,
            /// MR13 [13:13]
            /// Interrupt Mask on line 13
            MR13: ?u1 = null,
            /// MR14 [14:14]
            /// Interrupt Mask on line 14
            MR14: ?u1 = null,
            /// MR15 [15:15]
            /// Interrupt Mask on line 15
            MR15: ?u1 = null,
            /// MR16 [16:16]
            /// Interrupt Mask on line 16
            MR16: ?u1 = null,
            /// MR17 [17:17]
            /// Interrupt Mask on line 17
            MR17: ?u1 = null,
            /// MR18 [18:18]
            /// Interrupt Mask on line 18
            MR18: ?u1 = null,
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
            /// MR10 [10:10]
            /// Event Mask on line 10
            MR10: ?u1 = null,
            /// MR11 [11:11]
            /// Event Mask on line 11
            MR11: ?u1 = null,
            /// MR12 [12:12]
            /// Event Mask on line 12
            MR12: ?u1 = null,
            /// MR13 [13:13]
            /// Event Mask on line 13
            MR13: ?u1 = null,
            /// MR14 [14:14]
            /// Event Mask on line 14
            MR14: ?u1 = null,
            /// MR15 [15:15]
            /// Event Mask on line 15
            MR15: ?u1 = null,
            /// MR16 [16:16]
            /// Event Mask on line 16
            MR16: ?u1 = null,
            /// MR17 [17:17]
            /// Event Mask on line 17
            MR17: ?u1 = null,
            /// MR18 [18:18]
            /// Event Mask on line 18
            MR18: ?u1 = null,
        };

        /// Rising Trigger selection register(EXTI_RTENR)
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
            /// TR10 [10:10]
            /// Rising trigger event configuration of line 10
            TR10: ?u1 = null,
            /// TR11 [11:11]
            /// Rising trigger event configuration of line 11
            TR11: ?u1 = null,
            /// TR12 [12:12]
            /// Rising trigger event configuration of line 12
            TR12: ?u1 = null,
            /// TR13 [13:13]
            /// Rising trigger event configuration of line 13
            TR13: ?u1 = null,
            /// TR14 [14:14]
            /// Rising trigger event configuration of line 14
            TR14: ?u1 = null,
            /// TR15 [15:15]
            /// Rising trigger event configuration of line 15
            TR15: ?u1 = null,
            /// TR16 [16:16]
            /// Rising trigger event configuration of line 16
            TR16: ?u1 = null,
            /// TR17 [17:17]
            /// Rising trigger event configuration of line 17
            TR17: ?u1 = null,
            /// TR18 [18:18]
            /// Rising trigger event configuration of line 18
            TR18: ?u1 = null,
        };

        /// Falling Trigger selection register(EXTI_FTENR)
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
            /// TR10 [10:10]
            /// Falling trigger event configuration of line 10
            TR10: ?u1 = null,
            /// TR11 [11:11]
            /// Falling trigger event configuration of line 11
            TR11: ?u1 = null,
            /// TR12 [12:12]
            /// Falling trigger event configuration of line 12
            TR12: ?u1 = null,
            /// TR13 [13:13]
            /// Falling trigger event configuration of line 13
            TR13: ?u1 = null,
            /// TR14 [14:14]
            /// Falling trigger event configuration of line 14
            TR14: ?u1 = null,
            /// TR15 [15:15]
            /// Falling trigger event configuration of line 15
            TR15: ?u1 = null,
            /// TR16 [16:16]
            /// Falling trigger event configuration of line 16
            TR16: ?u1 = null,
            /// TR17 [17:17]
            /// Falling trigger event configuration of line 17
            TR17: ?u1 = null,
            /// TR18 [18:18]
            /// Falling trigger event configuration of line 18
            TR18: ?u1 = null,
        };

        /// Software interrupt event register(EXTI_SWIEVR)
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
            /// SWIER10 [10:10]
            /// Software Interrupt on line 10
            SWIER10: ?u1 = null,
            /// SWIER11 [11:11]
            /// Software Interrupt on line 11
            SWIER11: ?u1 = null,
            /// SWIER12 [12:12]
            /// Software Interrupt on line 12
            SWIER12: ?u1 = null,
            /// SWIER13 [13:13]
            /// Software Interrupt on line 13
            SWIER13: ?u1 = null,
            /// SWIER14 [14:14]
            /// Software Interrupt on line 14
            SWIER14: ?u1 = null,
            /// SWIER15 [15:15]
            /// Software Interrupt on line 15
            SWIER15: ?u1 = null,
            /// SWIER16 [16:16]
            /// Software Interrupt on line 16
            SWIER16: ?u1 = null,
            /// SWIER17 [17:17]
            /// Software Interrupt on line 17
            SWIER17: ?u1 = null,
            /// SWIER18 [18:18]
            /// Software Interrupt on line 18
            SWIER18: ?u1 = null,
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
            /// IF10 [10:10]
            /// Pending bit 10
            IF10: ?u1 = null,
            /// IF11 [11:11]
            /// Pending bit 11
            IF11: ?u1 = null,
            /// IF12 [12:12]
            /// Pending bit 12
            IF12: ?u1 = null,
            /// IF13 [13:13]
            /// Pending bit 13
            IF13: ?u1 = null,
            /// IF14 [14:14]
            /// Pending bit 14
            IF14: ?u1 = null,
            /// IF15 [15:15]
            /// Pending bit 15
            IF15: ?u1 = null,
            /// IF16 [16:16]
            /// Pending bit 16
            IF16: ?u1 = null,
            /// IF17 [17:17]
            /// Pending bit 17
            IF17: ?u1 = null,
            /// IF18 [18:18]
            /// Pending bit 18
            IF18: ?u1 = null,
        };
    };

    /// DMA controller
    pub const DMA = struct {
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

    /// Real time clock
    pub const RTC = struct {
        /// RTC Control Register High
        pub const CTLRH = struct {
            /// SECIE [0:0]
            /// Second interrupt Enable
            SECIE: ?u1 = null,
            /// ALRIE [1:1]
            /// Alarm interrupt Enable
            ALRIE: ?u1 = null,
            /// OWIE [2:2]
            /// Overflow interrupt Enable
            OWIE: ?u1 = null,
        };

        /// RTC Control Register Low
        pub const CTLRL = struct {
            /// SECF [0:0]
            /// Second Flag
            SECF: ?u1 = null,
            /// ALRF [1:1]
            /// Alarm Flag
            ALRF: ?u1 = null,
            /// OWF [2:2]
            /// Overflow Flag
            OWF: ?u1 = null,
            /// RSF [3:3]
            /// Registers Synchronized Flag
            RSF: ?u1 = null,
            /// CNF [4:4]
            /// Configuration Flag
            CNF: ?u1 = null,
            /// RTOFF [5:5]
            /// RTC operation OFF
            RTOFF: ?u1 = null,
        };

        /// RTC Prescaler Load Register High
        pub const PSCRH = struct {
            /// PRLH [0:3]
            /// RTC Prescaler Load Register High
            PRLH: ?u4 = null,
        };

        /// RTC Prescaler Load Register Low
        pub const PSCRL = struct {
            /// PRLL [0:15]
            /// RTC Prescaler Divider Register Low
            PRLL: ?u16 = null,
        };

        /// RTC Prescaler Divider Register High
        pub const DIVH = struct {
            /// DIVH [0:3]
            /// RTC prescaler divider register high
            DIVH: ?u4 = null,
        };

        /// RTC Prescaler Divider Register Low
        pub const DIVL = struct {
            /// DIVL [0:15]
            /// RTC prescaler divider register Low
            DIVL: ?u16 = null,
        };

        /// RTC Counter Register High
        pub const CNTH = struct {
            /// CNTH [0:15]
            /// RTC counter register high
            CNTH: ?u16 = null,
        };

        /// RTC Counter Register Low
        pub const CNTL = struct {
            /// CNTL [0:15]
            /// RTC counter register Low
            CNTL: ?u16 = null,
        };

        /// RTC Alarm Register High
        pub const ALRMH = struct {
            /// ALRMH [0:15]
            /// RTC alarm register high
            ALRMH: ?u16 = null,
        };

        /// RTC Alarm Register Low
        pub const ALRML = struct {
            /// ALRML [0:15]
            /// RTC alarm register low
            ALRML: ?u16 = null,
        };
    };

    /// Backup registers
    pub const BKP = struct {
        /// Backup data register (BKP_DR)
        pub const DATAR1 = struct {
            /// D1 [0:15]
            /// Backup data
            D1: ?u16 = null,
        };

        /// Backup data register (BKP_DR)
        pub const DATAR2 = struct {
            /// D2 [0:15]
            /// Backup data
            D2: ?u16 = null,
        };

        /// Backup data register (BKP_DR)
        pub const DATAR3 = struct {
            /// D3 [0:15]
            /// Backup data
            D3: ?u16 = null,
        };

        /// Backup data register (BKP_DR)
        pub const DATAR4 = struct {
            /// D4 [0:15]
            /// Backup data
            D4: ?u16 = null,
        };

        /// Backup data register (BKP_DR)
        pub const DATAR5 = struct {
            /// D5 [0:15]
            /// Backup data
            D5: ?u16 = null,
        };

        /// Backup data register (BKP_DR)
        pub const DATAR6 = struct {
            /// D6 [0:15]
            /// Backup data
            D6: ?u16 = null,
        };

        /// Backup data register (BKP_DR)
        pub const DATAR7 = struct {
            /// D7 [0:15]
            /// Backup data
            D7: ?u16 = null,
        };

        /// Backup data register (BKP_DR)
        pub const DATAR8 = struct {
            /// D8 [0:15]
            /// Backup data
            D8: ?u16 = null,
        };

        /// Backup data register (BKP_DR)
        pub const DATAR9 = struct {
            /// D9 [0:15]
            /// Backup data
            D9: ?u16 = null,
        };

        /// Backup data register (BKP_DR)
        pub const DATAR10 = struct {
            /// D10 [0:15]
            /// Backup data
            D10: ?u16 = null,
        };

        /// RTC clock calibration register (BKP_OCTLR)
        pub const OCTLR = struct {
            /// CAL [0:6]
            /// Calibration value
            CAL: ?u7 = null,
            /// CCO [7:7]
            /// Calibration Clock Output
            CCO: ?u1 = null,
            /// ASOE [8:8]
            /// Alarm or second output enable
            ASOE: ?u1 = null,
            /// ASOS [9:9]
            /// Alarm or second output selection
            ASOS: ?u1 = null,
        };

        /// Backup control register (BKP_TPCTLR)
        pub const TPCTLR = struct {
            /// TPE [0:0]
            /// Tamper pin enable
            TPE: ?u1 = null,
            /// TPAL [1:1]
            /// Tamper pin active level
            TPAL: ?u1 = null,
        };

        /// BKP_TPCSR control/status register (BKP_CSR)
        pub const TPCSR = struct {
            /// CTE [0:0]
            /// Clear Tamper event
            CTE: ?u1 = null,
            /// CTI [1:1]
            /// Clear Tamper Interrupt
            CTI: ?u1 = null,
            /// TPIE [2:2]
            /// Tamper Pin interrupt enable
            TPIE: ?u1 = null,
            /// TEF [8:8]
            /// Tamper Event Flag
            TEF: ?u1 = null,
            /// TIF [9:9]
            /// Tamper Interrupt Flag
            TIF: ?u1 = null,
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
            /// WEIF [0:0]
            /// Early Wakeup Interrupt Flag
            WEIF: ?u1 = null,
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
            /// ARR [0:15]
            /// Auto-reload value
            ARR: ?u16 = null,
        };

        /// repetition counter register
        pub const RPTCR = struct {
            /// REP [0:7]
            /// Repetition counter value
            REP: ?u8 = null,
        };

        /// capture/compare register 1
        pub const CH1CVR = struct {
            /// CCR1 [0:15]
            /// Capture/Compare 1 value
            CCR1: ?u16 = null,
        };

        /// capture/compare register 2
        pub const CH2CVR = struct {
            /// CCR2 [0:15]
            /// Capture/Compare 2 value
            CCR2: ?u16 = null,
        };

        /// capture/compare register 3
        pub const CH3CVR = struct {
            /// CCR3 [0:15]
            /// Capture/Compare value
            CCR3: ?u16 = null,
        };

        /// capture/compare register 4
        pub const CH4CVR = struct {
            /// CCR4 [0:15]
            /// Capture/Compare value
            CCR4: ?u16 = null,
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
        pub const DMAR = struct {
            /// DMAB [0:15]
            /// DMA register for burst accesses
            DMAB: ?u16 = null,
        };
    };

    /// General purpose timer
    /// Type for: TIM2 TIM3 TIM4
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
            /// Capture/Compare 2 selection
            CC2S: ?u2 = null,
            /// OC2FE [10:10]
            /// Output compare 2 fast enable
            OC2FE: ?u1 = null,
            /// OC2PE [11:11]
            /// Output compare 2 preload enable
            OC2PE: ?u1 = null,
            /// OC2M [12:14]
            /// Output compare 2 mode
            OC2M: ?u3 = null,
            /// OC2CE [15:15]
            /// Output compare 2 clear enable
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
            /// Capture/Compare 1 output enable
            CC1E: ?u1 = null,
            /// CC1P [1:1]
            /// Capture/Compare 1 output Polarity
            CC1P: ?u1 = null,
            /// CC2E [4:4]
            /// Capture/Compare 2 output enable
            CC2E: ?u1 = null,
            /// CC2P [5:5]
            /// Capture/Compare 2 output Polarity
            CC2P: ?u1 = null,
            /// CC3E [8:8]
            /// Capture/Compare 3 output enable
            CC3E: ?u1 = null,
            /// CC3P [9:9]
            /// Capture/Compare 3 output Polarity
            CC3P: ?u1 = null,
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
            /// ARR [0:15]
            /// Auto-reload value
            ARR: ?u16 = null,
        };

        /// capture/compare register 1
        pub const CH1CVR = struct {
            /// CCR1 [0:15]
            /// Capture/Compare 1 value
            CCR1: ?u16 = null,
        };

        /// capture/compare register 2
        pub const CH2CVR = struct {
            /// CCR2 [0:15]
            /// Capture/Compare 2 value
            CCR2: ?u16 = null,
        };

        /// capture/compare register 3
        pub const CH3CVR = struct {
            /// CCR3 [0:15]
            /// Capture/Compare value
            CCR3: ?u16 = null,
        };

        /// capture/compare register 4
        pub const CH4CVR = struct {
            /// CCR4 [0:15]
            /// Capture/Compare value
            CCR4: ?u16 = null,
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

    /// Inter integrated circuit
    /// Type for: I2C1 I2C2
    pub const I2C = struct {
        /// Control register 1
        pub const CTLR1 = struct {
            /// PE [0:0]
            /// Peripheral enable
            PE: ?u1 = null,
            /// SMBUS [1:1]
            /// SMBus mode
            SMBUS: ?u1 = null,
            /// SMBTYPE [3:3]
            /// SMBus type
            SMBTYPE: ?u1 = null,
            /// ENARP [4:4]
            /// ARP enable
            ENARP: ?u1 = null,
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
            /// ALERT [13:13]
            /// SMBus alert
            ALERT: ?u1 = null,
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
            /// DR [0:7]
            /// 8-bit data register
            DR: ?u8 = null,
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
            /// TIMEOUT [14:14]
            /// Timeout or Tlow error
            TIMEOUT: ?u1 = null,
            /// SMBALERT [15:15]
            /// SMBus alert
            SMBALERT: ?u1 = null,
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
            /// SMBDEFAULT [5:5]
            /// SMBus device default address (Slave mode)
            SMBDEFAULT: ?u1 = null,
            /// SMBHOST [6:6]
            /// SMBus host header (Slave mode)
            SMBHOST: ?u1 = null,
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

        /// risetime register
        pub const RTR = struct {
            /// TRISE [0:5]
            /// Maximum rise time in Fast/Standard mode (Master mode)
            TRISE: ?u6 = null,
        };
    };

    /// Serial peripheral interface
    /// Type for: SPI1 SPI2
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
            /// RxCRC [0:15]
            /// Rx CRC register
            RxCRC: ?u16 = null,
        };

        /// TX CRC register
        pub const TCRCR = struct {
            /// TxCRC [0:15]
            /// Tx CRC register
            TxCRC: ?u16 = null,
        };

        /// High speed control register
        pub const HSCR = struct {
            /// HSRXEN [0:0]
            /// High speed read mode enable bit
            HSRXEN: ?u1 = null,
        };
    };

    /// Universal synchronous asynchronous receiver transmitter
    /// Type for: USART1 USART2 USART3
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
    pub const ADC = struct {
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

        /// control register 1 and TKEY_V control register
        pub const CTLR1_TKEY_V_CTLR = struct {
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
            /// Scan mode
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
            /// DUALMOD [16:19]
            /// Dual mode selection
            DUALMOD: ?u4 = null,
            /// JAWDEN [22:22]
            /// Analog watchdog enable on injected channels
            JAWDEN: ?u1 = null,
            /// AWDEN [23:23]
            /// Analog watchdog enable on regular channels
            AWDEN: ?u1 = null,
            /// TKENABLE [24:24]
            /// Touch key enable, including TKEY_F and TKEY_V
            TKENABLE: ?u1 = null,
            /// TKIEN [25:25]
            /// count conversion complete interrupt enabled
            TKIEN: ?u1 = null,
            /// TKCPS [26:26]
            /// count cycle selection
            TKCPS: ?u1 = null,
            /// TKIF [27:27]
            /// count conversion complete flag
            TKIF: ?u1 = null,
            /// CCSEL [28:28]
            /// Touch key count cycle time base
            CCSEL: ?u1 = null,
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
            /// TSVREFE [23:23]
            /// Temperature sensor and VREFINT enable
            TSVREFE: ?u1 = null,
        };

        /// sample time register 1
        pub const SAMPTR1 = struct {
            /// SMP10 [0:2]
            /// Channel 10 sample time selection
            SMP10: ?u3 = null,
            /// SMP11 [3:5]
            /// Channel 11 sample time selection
            SMP11: ?u3 = null,
            /// SMP12 [6:8]
            /// Channel 12 sample time selection
            SMP12: ?u3 = null,
            /// SMP13 [9:11]
            /// Channel 13 sample time selection
            SMP13: ?u3 = null,
            /// SMP14 [12:14]
            /// Channel 14 sample time selection
            SMP14: ?u3 = null,
            /// SMP15 [15:17]
            /// Channel 15 sample time selection
            SMP15: ?u3 = null,
            /// SMP16 [18:20]
            /// Channel 16 sample time selection
            SMP16: ?u3 = null,
            /// SMP17 [21:23]
            /// Channel 17 sample time selection
            SMP17: ?u3 = null,
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
            /// SMP6 [18:20]
            /// Channel 6 sample time selection
            SMP6: ?u3 = null,
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
            /// JOFFSET1 [0:11]
            /// Data offset for injected channel x
            JOFFSET1: ?u12 = null,
        };

        /// injected channel data offset register x
        pub const IOFR2 = struct {
            /// JOFFSET2 [0:11]
            /// Data offset for injected channel x
            JOFFSET2: ?u12 = null,
        };

        /// injected channel data offset register x
        pub const IOFR3 = struct {
            /// JOFFSET3 [0:11]
            /// Data offset for injected channel x
            JOFFSET3: ?u12 = null,
        };

        /// injected channel data offset register x
        pub const IOFR4 = struct {
            /// JOFFSET4 [0:11]
            /// Data offset for injected channel x
            JOFFSET4: ?u12 = null,
        };

        /// watchdog higher threshold register
        pub const WDHTR = struct {
            /// HT [0:11]
            /// Analog watchdog higher threshold
            HT: ?u12 = null,
        };

        /// watchdog lower threshold register
        pub const WDLTR = struct {
            /// LT [0:11]
            /// Analog watchdog lower threshold
            LT: ?u12 = null,
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
            /// SQ1_CHSEL [0:4]
            /// 1st conversion in regular sequence_conversion count conversion channel selection
            SQ1_CHSEL: ?u5 = null,
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

        /// injected data register x
        pub const IDATAR1 = struct {
            /// JDATA [0:15]
            /// Injected data
            JDATA: ?u16 = null,
        };

        /// injected data register x
        pub const IDATAR2 = struct {
            /// JDATA [0:15]
            /// Injected data
            JDATA: ?u16 = null,
        };

        /// injected data register x
        pub const IDATAR3 = struct {
            /// JDATA [0:15]
            /// Injected data
            JDATA: ?u16 = null,
        };

        /// injected data register x
        pub const IDATAR4 = struct {
            /// JDATA [0:15]
            /// Injected data
            JDATA: ?u16 = null,
        };

        /// regular data register
        pub const RDATAR = struct {
            /// DATA0_13_TKDR [0:13]
            /// Regular data_count conversion value
            DATA0_13_TKDR: ?u14 = null,
            /// DATA14 [14:14]
            /// Regular data
            DATA14: ?u1 = null,
            /// DATA15_TKSTA [15:15]
            /// Regular data_current working state of TKEY_V
            DATA15_TKSTA: ?u1 = null,
        };
    };

    /// Digital to analog converter
    pub const DAC1 = struct {
        /// Control register (DAC_CTLR)
        pub const CTLR = struct {
            /// EN1 [0:0]
            /// DAC channel1 enable
            EN1: ?u1 = null,
            /// BOFF1 [1:1]
            /// DAC channel1 output buffer disable
            BOFF1: ?u1 = null,
            /// TEN1 [2:2]
            /// DAC channel1 trigger enable
            TEN1: ?u1 = null,
            /// TSEL1 [3:5]
            /// DAC channel1 trigger selection
            TSEL1: ?u3 = null,
            /// WAVE1 [6:7]
            /// DAC channel1 noise/triangle wave generation enable
            WAVE1: ?u2 = null,
            /// MAMP1 [8:11]
            /// DAC channel1 mask/amplitude selector
            MAMP1: ?u4 = null,
            /// DMAEN1 [12:12]
            /// DAC channel1 DMA enable
            DMAEN1: ?u1 = null,
            /// EN2 [16:16]
            /// DAC channel2 enable
            EN2: ?u1 = null,
            /// BOFF2 [17:17]
            /// DAC channel2 output buffer disable
            BOFF2: ?u1 = null,
            /// TEN2 [18:18]
            /// DAC channel2 trigger enable
            TEN2: ?u1 = null,
            /// TSEL2 [19:21]
            /// DAC channel2 trigger selection
            TSEL2: ?u3 = null,
            /// WAVE2 [22:23]
            /// DAC channel2 noise/triangle wave generation enable
            WAVE2: ?u2 = null,
            /// MAMP2 [24:27]
            /// DAC channel2 mask/amplitude selector
            MAMP2: ?u4 = null,
            /// DMAEN2 [28:28]
            /// DAC channel2 DMA enable
            DMAEN2: ?u1 = null,
        };

        /// DAC software trigger register (DAC_SWTR)
        pub const SWTR = struct {
            /// SWTRIG1 [0:0]
            /// DAC channel1 software trigger
            SWTRIG1: ?u1 = null,
            /// SWTRIG2 [1:1]
            /// DAC channel2 software trigger
            SWTRIG2: ?u1 = null,
        };

        /// DAC channel1 12-bit right-aligned data holding register(DAC_R12BDHR1)
        pub const R12BDHR1 = struct {
            /// DACC1DHR [0:11]
            /// DAC channel1 12-bit right-aligned data
            DACC1DHR: ?u12 = null,
        };

        /// DAC channel1 12-bit left aligned data holding register (DAC_L12BDHR1)
        pub const L12BDHR1 = struct {
            /// DACC1DHR [4:15]
            /// DAC channel1 12-bit left-aligned data
            DACC1DHR: ?u12 = null,
        };

        /// DAC channel2 12-bit right aligned data holding register (DAC_R12BDHR2)
        pub const R12BDHR2 = struct {
            /// DACC2DHR [0:11]
            /// DAC channel2 12-bit right-aligned data
            DACC2DHR: ?u12 = null,
        };

        /// DAC channel2 12-bit left aligned data holding register (DAC_L12BDHR2)
        pub const L12BDHR2 = struct {
            /// DACC2DHR [4:15]
            /// DAC channel2 12-bit left-aligned data
            DACC2DHR: ?u12 = null,
        };

        /// DAC channel1 data output register (DAC_DOR1)
        pub const DOR1 = struct {
            /// DACC1DOR [0:11]
            /// DAC channel1 data output
            DACC1DOR: ?u12 = null,
        };

        /// DAC channel2 data output register (DAC_DOR2)
        pub const DOR2 = struct {
            /// DACC2DOR [0:11]
            /// DAC channel2 data output
            DACC2DOR: ?u12 = null,
        };
    };

    /// Debug support
    pub const DBG = struct {
        /// DBGMCU_CR1
        pub const CR1 = struct {
            /// IWDG_STOP [0:0]
            /// IWDG_STOP
            IWDG_STOP: ?u1 = null,
            /// WWDG_STOP [1:1]
            /// WWDG_STOP
            WWDG_STOP: ?u1 = null,
            /// I2C1_SMBUS_TIMEOUT [2:2]
            /// I2C1_SMBUS_TIMEOUT
            I2C1_SMBUS_TIMEOUT: ?u1 = null,
            /// I2C2_SMBUS_TIMEOUT [3:3]
            /// I2C2_SMBUS_TIMEOUT
            I2C2_SMBUS_TIMEOUT: ?u1 = null,
            /// TIM1_STOP [4:4]
            /// TIM1_STOP
            TIM1_STOP: ?u1 = null,
            /// TIM2_STOP [5:5]
            /// TIM2_STOP
            TIM2_STOP: ?u1 = null,
            /// TIM3_STOP [6:6]
            /// TIM3_STOP
            TIM3_STOP: ?u1 = null,
            /// TIM4_STOP [7:7]
            /// TIM4_STOP
            TIM4_STOP: ?u1 = null,
        };

        /// DBGMCU_CR2
        pub const CR2 = struct {
            /// SLEEP [0:0]
            /// DBG_SLEEP
            SLEEP: ?u1 = null,
            /// STOP [1:1]
            /// DBG_STOP
            STOP: ?u1 = null,
            /// STANDBY [2:2]
            /// DBG_STANDBY
            STANDBY: ?u1 = null,
        };
    };

    /// USB register
    pub const USBFS = struct {
        /// USB base control
        pub const R8_USB_CTRL = struct {
            /// RB_UC_DMA_EN [0:0]
            /// DMA enable and DMA interrupt enable for USB
            RB_UC_DMA_EN: ?u1 = null,
            /// RB_UC_CLR_ALL [1:1]
            /// force clear FIFO and count of USB
            RB_UC_CLR_ALL: ?u1 = null,
            /// RB_UC_RST_SIE [2:2]
            /// force reset USB SIE, need software clear
            RB_UC_RST_SIE: ?u1 = null,
            /// RB_UC_INT_BUSY [3:3]
            /// enable automatic responding busy for device mode or automatic pause for host mode during interrupt flag UIF_TRANSFER valid
            RB_UC_INT_BUSY: ?u1 = null,
            /// MASK_UC_SYS_CTRL [4:5]
            /// bit mask of USB system control
            MASK_UC_SYS_CTRL: ?u2 = null,
            /// RB_UC_LOW_SPEED [6:6]
            /// enable USB low speed: 0=12Mbps, 1=1.5Mbps
            RB_UC_LOW_SPEED: ?u1 = null,
            /// RB_UC_HOST_MODE [7:7]
            /// enable USB host mode: 0=device mode, 1=host mode
            RB_UC_HOST_MODE: ?u1 = null,
        };

        /// USB device physical prot control
        pub const R8_UDEV_CTRL__R8_UHOST_CTRL = struct {
            /// RB_UD_PORT_EN__RB_UH_PORT_EN [0:0]
            /// enable USB physical port I/O: 0=disable, 1=enable;enable USB port: 0=disable, 1=enable port, automatic disabled if USB device detached
            RB_UD_PORT_EN__RB_UH_PORT_EN: ?u1 = null,
            /// RB_UD_GP_BIT__RB_UH_BUS_RESET [1:1]
            /// general purpose bit;control USB bus reset: 0=normal, 1=force bus reset
            RB_UD_GP_BIT__RB_UH_BUS_RESET: ?u1 = null,
            /// RB_UD_LOW_SPEED__RB_UH_LOW_SPEED [2:2]
            /// enable USB physical port low speed: 0=full speed, 1=low speed;enable USB port low speed: 0=full speed, 1=low speed
            RB_UD_LOW_SPEED__RB_UH_LOW_SPEED: ?u1 = null,
            /// RB_UD_DM_PIN__RB_UH_DM_PIN [4:4]
            /// ReadOnly: indicate current UDM pin level
            RB_UD_DM_PIN__RB_UH_DM_PIN: ?u1 = null,
            /// RB_UD_DP_PIN__RB_UH_DP_PIN [5:5]
            /// ReadOnly: indicate current UDP pin level
            RB_UD_DP_PIN__RB_UH_DP_PIN: ?u1 = null,
            /// RB_UD_PD_DIS__RB_UH_PD_DIS [7:7]
            /// disable USB UDP/UDM pulldown resistance: 0=enable pulldown, 1=disable
            RB_UD_PD_DIS__RB_UH_PD_DIS: ?u1 = null,
        };

        /// USB interrupt enable
        pub const R8_USB_INT_EN = struct {
            /// RB_UIE_BUS_RST__RB_UIE_DETECT [0:0]
            /// enable interrupt for USB bus reset event for USB device mode;enable interrupt for USB device detected event for USB host mode
            RB_UIE_BUS_RST__RB_UIE_DETECT: ?u1 = null,
            /// RB_UIE_TRANSFER [1:1]
            /// enable interrupt for USB transfer completion
            RB_UIE_TRANSFER: ?u1 = null,
            /// RB_UIE_SUSPEND [2:2]
            /// enable interrupt for USB suspend or resume event
            RB_UIE_SUSPEND: ?u1 = null,
            /// RB_UIE_HST_SOF [3:3]
            /// enable interrupt for host SOF timer action for USB host mode
            RB_UIE_HST_SOF: ?u1 = null,
            /// RB_UIE_FIFO_OV [4:4]
            /// enable interrupt for FIFO overflow
            RB_UIE_FIFO_OV: ?u1 = null,
            /// RB_UIE_DEV_NAK [6:6]
            /// enable interrupt for NAK responded for USB device mode
            RB_UIE_DEV_NAK: ?u1 = null,
            /// RB_UIE_DEV_SOF [7:7]
            /// enable interrupt for SOF received for USB device mode
            RB_UIE_DEV_SOF: ?u1 = null,
        };

        /// USB device address
        pub const R8_USB_DEV_AD = struct {
            /// MASK_USB_ADDR [0:6]
            /// bit mask for USB device address
            MASK_USB_ADDR: ?u7 = null,
            /// RB_UDA_GP_BIT [7:7]
            /// general purpose bit
            RB_UDA_GP_BIT: ?u1 = null,
        };

        /// USB miscellaneous status
        pub const R8_USB_MIS_ST = struct {
            /// RB_UMS_DEV_ATTACH [0:0]
            /// RO, indicate device attached status on USB host
            RB_UMS_DEV_ATTACH: ?u1 = null,
            /// RB_UMS_DM_LEVEL [1:1]
            /// RO, indicate UDM level saved at device attached to USB host
            RB_UMS_DM_LEVEL: ?u1 = null,
            /// RB_UMS_SUSPEND [2:2]
            /// RO, indicate USB suspend status
            RB_UMS_SUSPEND: ?u1 = null,
            /// RB_UMS_BUS_RESET [3:3]
            /// RO, indicate USB bus reset status
            RB_UMS_BUS_RESET: ?u1 = null,
            /// RB_UMS_R_FIFO_RDY [4:4]
            /// RO, indicate USB receiving FIFO ready status (not empty)
            RB_UMS_R_FIFO_RDY: ?u1 = null,
            /// RB_UMS_SIE_FREE [5:5]
            /// RO, indicate USB SIE free status
            RB_UMS_SIE_FREE: ?u1 = null,
            /// RB_UMS_SOF_ACT [6:6]
            /// RO, indicate host SOF timer action status for USB host
            RB_UMS_SOF_ACT: ?u1 = null,
            /// RB_UMS_SOF_PRES [7:7]
            /// RO, indicate host SOF timer presage status
            RB_UMS_SOF_PRES: ?u1 = null,
        };

        /// USB interrupt flag
        pub const R8_USB_INT_FG = struct {
            /// RB_UIF_BUS_RST__RB_UIF_DETECT [0:0]
            /// bus reset event interrupt flag for USB device mode, direct bit address clear or write 1 to clear;device detected event interrupt flag for USB host mode, direct bit address clear or write 1 to clear
            RB_UIF_BUS_RST__RB_UIF_DETECT: ?u1 = null,
            /// RB_UIF_TRANSFER [1:1]
            /// USB transfer completion interrupt flag, direct bit address clear or write 1 to clear
            RB_UIF_TRANSFER: ?u1 = null,
            /// RB_UIF_SUSPEND [2:2]
            /// USB suspend or resume event interrupt flag, direct bit address clear or write 1 to clear
            RB_UIF_SUSPEND: ?u1 = null,
            /// RB_UIF_HST_SOF [3:3]
            /// host SOF timer interrupt flag for USB host, direct bit address clear or write 1 to clear
            RB_UIF_HST_SOF: ?u1 = null,
            /// RB_UIF_FIFO_OV [4:4]
            /// FIFO overflow interrupt flag for USB, direct bit address clear or write 1 to clear
            RB_UIF_FIFO_OV: ?u1 = null,
            /// RB_U_SIE_FREE [5:5]
            /// RO, indicate USB SIE free status
            RB_U_SIE_FREE: ?u1 = null,
            /// RB_U_TOG_OK [6:6]
            /// RO, indicate current USB transfer toggle is OK
            RB_U_TOG_OK: ?u1 = null,
            /// RB_U_IS_NAK [7:7]
            /// RO, indicate current USB transfer is NAK received
            RB_U_IS_NAK: ?u1 = null,
        };

        /// USB interrupt status
        pub const R8_USB_INT_ST = struct {
            /// MASK_UIS_H_RES__MASK_UIS_ENDP [0:3]
            /// RO, bit mask of current transfer handshake response for USB host mode: 0000=no response, time out from device, others=handshake response PID received;RO, bit mask of current transfer endpoint number for USB device mode
            MASK_UIS_H_RES__MASK_UIS_ENDP: ?u4 = null,
            /// MASK_UIS_TOKEN [4:5]
            /// RO, bit mask of current token PID code received for USB device mode
            MASK_UIS_TOKEN: ?u2 = null,
            /// RB_UIS_TOG_OK [6:6]
            /// RO, indicate current USB transfer toggle is OK
            RB_UIS_TOG_OK: ?u1 = null,
            /// RB_UIS_IS_NAK [7:7]
            /// RO, indicate current USB transfer is NAK received for USB device mode
            RB_UIS_IS_NAK: ?u1 = null,
        };

        /// USB receiving length
        pub const R8_USB_RX_LEN = struct {};

        /// endpoint 4/1 mode
        pub const R8_UEP4_1_MOD = struct {
            /// RB_UEP4_TX_EN [2:2]
            /// enable USB endpoint 4 transmittal (IN)
            RB_UEP4_TX_EN: ?u1 = null,
            /// RB_UEP4_RX_EN [3:3]
            /// enable USB endpoint 4 receiving (OUT)
            RB_UEP4_RX_EN: ?u1 = null,
            /// RB_UEP1_BUF_MOD [4:4]
            /// buffer mode of USB endpoint 1
            RB_UEP1_BUF_MOD: ?u1 = null,
            /// RB_UEP1_TX_EN [6:6]
            /// enable USB endpoint 1 transmittal (IN)
            RB_UEP1_TX_EN: ?u1 = null,
            /// RB_UEP1_RX_EN [7:7]
            /// enable USB endpoint 1 receiving (OUT)
            RB_UEP1_RX_EN: ?u1 = null,
        };

        /// endpoint 2/3 mode;host endpoint mode
        pub const R8_UEP2_3_MOD__R8_UH_EP_MOD = struct {
            /// RB_UEP2_BUF_MOD__RB_UH_EP_RBUF_MOD [0:0]
            /// buffer mode of USB endpoint 2;buffer mode of USB host IN endpoint
            RB_UEP2_BUF_MOD__RB_UH_EP_RBUF_MOD: ?u1 = null,
            /// RB_UEP2_TX_EN [2:2]
            /// enable USB endpoint 2 transmittal (IN)
            RB_UEP2_TX_EN: ?u1 = null,
            /// RB_UEP2_RX_EN__RB_UH_EP_RX_EN [3:3]
            /// enable USB endpoint 2 receiving (OUT);enable USB host IN endpoint receiving
            RB_UEP2_RX_EN__RB_UH_EP_RX_EN: ?u1 = null,
            /// RB_UEP3_BUF_MOD__RB_UH_EP_TBUF_MOD [4:4]
            /// buffer mode of USB endpoint 3;buffer mode of USB host OUT endpoint
            RB_UEP3_BUF_MOD__RB_UH_EP_TBUF_MOD: ?u1 = null,
            /// RB_UEP3_TX_EN__RB_UH_EP_TX_EN [6:6]
            /// enable USB endpoint 3 transmittal (IN);enable USB host OUT endpoint transmittal
            RB_UEP3_TX_EN__RB_UH_EP_TX_EN: ?u1 = null,
            /// RB_UEP3_RX_EN [7:7]
            /// enable USB endpoint 3 receiving (OUT)
            RB_UEP3_RX_EN: ?u1 = null,
        };

        /// endpoint 0 DMA buffer address
        pub const R16_UEP0_DMA = struct {};

        /// endpoint 1 DMA buffer address
        pub const R16_UEP1_DMA = struct {};

        /// endpoint 2 DMA buffer address;host rx endpoint buffer high address
        pub const R16_UEP2_DMA__R16_UH_RX_DMA = struct {};

        /// endpoint 3 DMA buffer address;host tx endpoint buffer high address
        pub const R16_UEP3_DMA__R16_UH_TX_DMA = struct {};

        /// endpoint 0 transmittal length
        pub const R8_UEP0_T_LEN = struct {};

        /// endpoint 0 control
        pub const R8_UEP0_CTRL = struct {
            /// MASK_UEP_T_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X transmittal (IN)
            MASK_UEP_T_RES: ?u2 = null,
            /// MASK_UEP_R_RES [2:3]
            /// bit mask of handshake response type for USB endpoint X receiving (OUT)
            MASK_UEP_R_RES: ?u2 = null,
            /// RB_UEP_AUTO_TOG [4:4]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG: ?u1 = null,
            /// RB_UEP_T_TOG [6:6]
            /// prepared data toggle flag of USB endpoint X transmittal (IN): 0=DATA0, 1=DATA1
            RB_UEP_T_TOG: ?u1 = null,
            /// RB_UEP_R_TOG [7:7]
            /// expected data toggle flag of USB endpoint X receiving (OUT): 0=DATA0, 1=DATA1
            RB_UEP_R_TOG: ?u1 = null,
        };

        /// endpoint 1 transmittal length
        pub const R8_UEP1_T_LEN = struct {};

        /// endpoint 1 control;host aux setup
        pub const R8_UEP1_CTRL__R8_UH_SETUP = struct {
            /// MASK_UEP_T_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X transmittal (IN)
            MASK_UEP_T_RES: ?u2 = null,
            /// MASK_UEP_R_RES [2:3]
            /// bit mask of handshake response type for USB endpoint X receiving (OUT)
            MASK_UEP_R_RES: ?u2 = null,
            /// RB_UEP_AUTO_TOG [4:4]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG: ?u1 = null,
            /// RB_UEP_T_TOG__RB_UH_SOF_EN [6:6]
            /// prepared data toggle flag of USB endpoint X transmittal (IN): 0=DATA0, 1=DATA1;USB host automatic SOF enable
            RB_UEP_T_TOG__RB_UH_SOF_EN: ?u1 = null,
            /// RB_UEP_R_TOG__RB_UH_PRE_PID_EN [7:7]
            /// expected data toggle flag of USB endpoint X receiving (OUT): 0=DATA0, 1=DATA1;RB_UH_PRE_PID_EN;USB host PRE PID enable for low speed device via hub
            RB_UEP_R_TOG__RB_UH_PRE_PID_EN: ?u1 = null,
        };

        /// endpoint 2 transmittal length;host endpoint and PID
        pub const R8_UEP2_T_LEN__R8_UH_EP_PID = struct {
            /// MASK_UH_ENDP [0:3]
            /// bit mask of endpoint number for USB host transfer
            MASK_UH_ENDP: ?u4 = null,
            /// MASK_UH_TOKEN [4:7]
            /// bit mask of token PID for USB host transfer
            MASK_UH_TOKEN: ?u4 = null,
        };

        /// endpoint 2 control;host receiver endpoint control
        pub const R8_UEP2_CTRL__R8_UH_RX_CTRL = struct {
            /// MASK_UEP_T_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X transmittal (IN)
            MASK_UEP_T_RES: ?u2 = null,
            /// MASK_UEP_R_RES [2:3]
            /// bit mask of handshake response type for USB endpoint X receiving (OUT)
            MASK_UEP_R_RES: ?u2 = null,
            /// RB_UEP_AUTO_TOG__RB_UH_R_AUTO_TOG [4:4]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle;enable automatic toggle after successful transfer completion: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG__RB_UH_R_AUTO_TOG: ?u1 = null,
            /// RB_UEP_T_TOG [6:6]
            /// prepared data toggle flag of USB endpoint X transmittal (IN): 0=DATA0, 1=DATA1
            RB_UEP_T_TOG: ?u1 = null,
            /// RB_UEP_R_TOG__RB_UH_R_TOG [7:7]
            /// expected data toggle flag of USB endpoint X receiving (OUT): 0=DATA0, 1=DATA1;expected data toggle flag of host receiving (IN): 0=DATA0, 1=DATA1
            RB_UEP_R_TOG__RB_UH_R_TOG: ?u1 = null,
        };

        /// endpoint 3 transmittal length;host transmittal endpoint transmittal length
        pub const R8_UEP3_T_LEN__R8_UH_TX_LEN = struct {};

        /// endpoint 3 control;host transmittal endpoint control
        pub const R8_UEP3_CTRL__R8_UH_TX_CTRL = struct {
            /// MASK_UEP_T_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X transmittal (IN)
            MASK_UEP_T_RES: ?u2 = null,
            /// MASK_UEP_R_RES [2:3]
            /// bit mask of handshake response type for USB endpoint X receiving (OUT)
            MASK_UEP_R_RES: ?u2 = null,
            /// RB_UEP_AUTO_TOG [4:4]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG: ?u1 = null,
            /// RB_UEP_T_TOG [6:6]
            /// prepared data toggle flag of USB endpoint X transmittal (IN): 0=DATA0, 1=DATA1
            RB_UEP_T_TOG: ?u1 = null,
            /// RB_UEP_R_TOG [7:7]
            /// expected data toggle flag of USB endpoint X receiving (OUT): 0=DATA0, 1=DATA1
            RB_UEP_R_TOG: ?u1 = null,
        };

        /// endpoint 4 transmittal length
        pub const R8_UEP4_T_LEN = struct {};

        /// endpoint 4 control
        pub const R8_UEP4_CTRL = struct {
            /// MASK_UEP_T_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X transmittal (IN)
            MASK_UEP_T_RES: ?u2 = null,
            /// MASK_UEP_R_RES [2:3]
            /// bit mask of handshake response type for USB endpoint X receiving (OUT)
            MASK_UEP_R_RES: ?u2 = null,
            /// RB_UEP_AUTO_TOG [4:4]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG: ?u1 = null,
            /// RB_UEP_T_TOG [6:6]
            /// prepared data toggle flag of USB endpoint X transmittal (IN): 0=DATA0, 1=DATA1
            RB_UEP_T_TOG: ?u1 = null,
            /// RB_UEP_R_TOG [7:7]
            /// expected data toggle flag of USB endpoint X receiving (OUT): 0=DATA0, 1=DATA1
            RB_UEP_R_TOG: ?u1 = null,
        };

        /// USB type-C control
        pub const R8_USB_TYPE_C_CTRL = struct {
            /// RB_UCC1_PU_EN [0:1]
            /// USB CC1 pullup resistance control
            RB_UCC1_PU_EN: ?u2 = null,
            /// RB_UCC1_PD_EN [2:2]
            /// USB CC1 5.1K pulldown resistance: 0=disable, 1=enable pulldown
            RB_UCC1_PD_EN: ?u1 = null,
            /// RB_VBUS_PD_EN [3:3]
            /// USB VBUS 10K pulldown resistance: 0=disable, 1=enable pullup
            RB_VBUS_PD_EN: ?u1 = null,
            /// RB_UCC2_PU_EN [4:5]
            /// USB CC2 pullup resistance control
            RB_UCC2_PU_EN: ?u2 = null,
            /// RB_UCC2_PD_EN [6:6]
            /// USB CC2 5.1K pulldown resistance: 0=disable, 1=enable pulldown
            RB_UCC2_PD_EN: ?u1 = null,
            /// RB_UTCC_GP_BIT [7:7]
            /// USB general purpose bit
            RB_UTCC_GP_BIT: ?u1 = null,
        };
    };

    /// CRC calculation unit
    pub const CRC = struct {
        /// Data register
        pub const DATAR = struct {
            /// DATA [0:31]
            /// Data Register
            DATA: ?u32 = null,
        };

        /// Independent Data register
        pub const IDATAR = struct {
            /// IDATA [0:7]
            /// Independent Data register
            IDATA: ?u8 = null,
        };

        /// Control register
        pub const CTLR = struct {
            /// RST [0:0]
            /// Reset bit
            RST: ?u1 = null,
        };
    };

    /// FLASH
    pub const FLASH = struct {
        /// Flash access control register
        pub const ACTLR = struct {
            /// LATENCY [0:2]
            /// Latency
            LATENCY: ?u3 = null,
            /// PRFTBE [4:4]
            /// Prefetch buffer enable
            PRFTBE: ?u1 = null,
            /// PRFTBS [5:5]
            /// Prefetch buffer status
            PRFTBS: ?u1 = null,
        };

        /// Flash key register
        pub const KEYR = struct {
            /// KEYR [0:31]
            /// FPEC key
            KEYR: ?u32 = null,
        };

        /// Flash option key register
        pub const OBKEYR = struct {
            /// OBKEYR [0:31]
            /// Option byte key
            OBKEYR: ?u32 = null,
        };

        /// Status register
        pub const STATR = struct {
            /// BSY [0:0]
            /// Busy
            BSY: ?u1 = null,
            /// PGERR [2:2]
            /// Programming error
            PGERR: ?u1 = null,
            /// WRPRTERR [4:4]
            /// Write protection error
            WRPRTERR: ?u1 = null,
            /// EOP [5:5]
            /// End of operation
            EOP: ?u1 = null,
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
            /// OPTWRE [9:9]
            /// Option bytes write enable
            OPTWRE: ?u1 = null,
            /// ERRIE [10:10]
            /// Error interrupt enable
            ERRIE: ?u1 = null,
            /// EOPIE [12:12]
            /// End of operation interrupt enable
            EOPIE: ?u1 = null,
            /// FLOCK [15:15]
            /// FAST programming lock
            FLOCK: ?u1 = null,
            /// FTPG [16:16]
            /// execute fast programming
            FTPG: ?u1 = null,
            /// FTER [17:17]
            /// execute fast 128byte erase
            FTER: ?u1 = null,
            /// BUFLOAD [18:18]
            /// execute data load inner buffer
            BUFLOAD: ?u1 = null,
            /// BUFRST [19:19]
            /// execute inner buffer reset
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
            /// OPTERR [0:0]
            /// Option byte error
            OPTERR: ?u1 = null,
            /// RDPRT [1:1]
            /// Read protection
            RDPRT: ?u1 = null,
            /// IWDGSW [2:2]
            /// IWDG_SW
            IWDGSW: ?u1 = null,
            /// STOPRST [3:3]
            /// nRST_STOP
            STOPRST: ?u1 = null,
            /// STANDYRST [4:4]
            /// nRST_STDBY
            STANDYRST: ?u1 = null,
            /// USBDMODE [5:5]
            /// USBD compatible speed mode configure
            USBDMODE: ?u1 = null,
            /// USBDPU [6:6]
            /// USBD compatible inner pull up resistance configure
            USBDPU: ?u1 = null,
            /// PORCTR [7:7]
            /// Power on reset time
            PORCTR: ?u1 = null,
        };

        /// Write protection register
        pub const WPR = struct {
            /// WRP [0:31]
            /// Write protect
            WRP: ?u32 = null,
        };

        /// Extension key register
        pub const MODEKEYR = struct {
            /// MODEKEYR [0:31]
            /// high speed write /erase mode ENABLE
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
            /// INTENSTA12_31 [12:31]
            /// Interrupt ID Status
            INTENSTA12_31: ?u20 = null,
        };

        /// Interrupt Status Register
        pub const ISR2 = struct {
            /// INTENSTA [0:27]
            /// Interrupt ID Status
            INTENSTA: ?u28 = null,
        };

        /// Interrupt Pending Register
        pub const IPR1 = struct {
            /// PENDSTA2_3 [2:3]
            /// PENDSTA
            PENDSTA2_3: ?u2 = null,
            /// PENDSTA12_31 [12:31]
            /// PENDSTA
            PENDSTA12_31: ?u20 = null,
        };

        /// Interrupt Pending Register
        pub const IPR2 = struct {
            /// PENDSTA [0:27]
            /// PENDSTA
            PENDSTA: ?u28 = null,
        };

        /// Interrupt Priority Register
        pub const ITHRESDR = struct {
            /// THRESHOLD [0:7]
            /// THRESHOLD
            THRESHOLD: ?u8 = null,
        };

        /// Interrupt Fast Address Register
        pub const FIBADDRR = struct {
            /// BASEADDR [28:31]
            /// BASEADDR
            BASEADDR: ?u4 = null,
        };

        /// Interrupt Config Register
        pub const CFGR = struct {
            /// HWSTKCTRL [0:0]
            /// HWSTKCTRL
            HWSTKCTRL: ?u1 = null,
            /// NESTCTRL [1:1]
            /// NESTCTRL
            NESTCTRL: ?u1 = null,
            /// NMISET [2:2]
            /// NMISET
            NMISET: ?u1 = null,
            /// NMIRESET [3:3]
            /// NMIRESET
            NMIRESET: ?u1 = null,
            /// EXCSET [4:4]
            /// EXCSET
            EXCSET: ?u1 = null,
            /// EXCRESET [5:5]
            /// EXCRESET
            EXCRESET: ?u1 = null,
            /// PFICRSET [6:6]
            /// PFICRSET
            PFICRSET: ?u1 = null,
            /// SYSRESET [7:7]
            /// SYSRESET
            SYSRESET: ?u1 = null,
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

        /// Interrupt 0 address Register
        pub const FIFOADDRR0 = struct {
            /// OFFADDR0 [0:23]
            /// OFFADDR0
            OFFADDR0: ?u24 = null,
            /// IRQID0 [24:31]
            /// IRQID0
            IRQID0: ?u8 = null,
        };

        /// Interrupt 1 address Register
        pub const FIFOADDRR1 = struct {
            /// OFFADDR1 [0:23]
            /// OFFADDR1
            OFFADDR1: ?u24 = null,
            /// IRQID1 [24:31]
            /// IRQID1
            IRQID1: ?u8 = null,
        };

        /// Interrupt 2 address Register
        pub const FIFOADDRR2 = struct {
            /// OFFADDR2 [0:23]
            /// OFFADDR2
            OFFADDR2: ?u24 = null,
            /// IRQID2 [24:31]
            /// IRQID2
            IRQID2: ?u8 = null,
        };

        /// Interrupt 3 address Register
        pub const FIFOADDRR3 = struct {
            /// OFFADDR3 [0:23]
            /// OFFADDR3
            OFFADDR3: ?u24 = null,
            /// IRQID3 [24:31]
            /// IRQID3
            IRQID3: ?u8 = null,
        };

        /// Interrupt Setting Register
        pub const IENR1 = struct {
            /// INTEN [12:31]
            /// INTEN
            INTEN: ?u20 = null,
        };

        /// Interrupt Setting Register
        pub const IENR2 = struct {
            /// INTEN [0:27]
            /// INTEN
            INTEN: ?u28 = null,
        };

        /// Interrupt Clear Register
        pub const IRER1 = struct {
            /// INTRSET [12:31]
            /// INTRSET
            INTRSET: ?u20 = null,
        };

        /// Interrupt Clear Register
        pub const IRER2 = struct {
            /// INTRSET [0:27]
            /// INTRSET
            INTRSET: ?u28 = null,
        };

        /// Interrupt Pending Register
        pub const IPSR1 = struct {
            /// PENDSET2_3 [2:3]
            /// PENDSET
            PENDSET2_3: ?u2 = null,
            /// PENDSET12_31 [12:31]
            /// PENDSET
            PENDSET12_31: ?u20 = null,
        };

        /// Interrupt Pending Register
        pub const IPSR2 = struct {
            /// PENDSET [0:27]
            /// PENDSET
            PENDSET: ?u28 = null,
        };

        /// Interrupt Pending Clear Register
        pub const IPRR1 = struct {
            /// PENDRESET2_3 [2:3]
            /// PENDRESET
            PENDRESET2_3: ?u2 = null,
            /// PENDRESET12_31 [12:31]
            /// PENDRESET
            PENDRESET12_31: ?u20 = null,
        };

        /// Interrupt Pending Clear Register
        pub const IPRR2 = struct {
            /// PENDRESET [0:27]
            /// PENDRESET
            PENDRESET: ?u28 = null,
        };

        /// Interrupt ACTIVE Register
        pub const IACTR1 = struct {
            /// IACTS [12:31]
            /// IACTS
            IACTS: ?u20 = null,
        };

        /// Interrupt ACTIVE Register
        pub const IACTR2 = struct {
            /// IACTS [0:27]
            /// IACTS
            IACTS: ?u28 = null,
        };

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
        };

        /// System counting Control Register
        pub const STK_CTLR = struct {
            /// STE [0:27]
            /// STE
            STE: ?u28 = null,
        };
    };

    /// Universal serial bus full-speed device interface
    pub const USBD = struct {
        /// endpoint 0 register
        pub const EPR0 = struct {
            /// EA [0:3]
            /// Endpoint address
            EA: ?u4 = null,
            /// STAT_TX [4:5]
            /// Status bits, for transmission transfers
            STAT_TX: ?u2 = null,
            /// DTOG_TX [6:6]
            /// Data Toggle, for transmission transfers
            DTOG_TX: ?u1 = null,
            /// CTR_TX [7:7]
            /// Correct Transfer for transmission
            CTR_TX: ?u1 = null,
            /// EP_KIND [8:8]
            /// Endpoint kind
            EP_KIND: ?u1 = null,
            /// EP_TYPE [9:10]
            /// Endpoint type
            EP_TYPE: ?u2 = null,
            /// SETUP [11:11]
            /// Setup transaction completed
            SETUP: ?u1 = null,
            /// STAT_RX [12:13]
            /// Status bits, for reception transfers
            STAT_RX: ?u2 = null,
            /// DTOG_RX [14:14]
            /// Data Toggle, for reception transfers
            DTOG_RX: ?u1 = null,
            /// CTR_RX [15:15]
            /// Correct transfer for reception
            CTR_RX: ?u1 = null,
        };

        /// endpoint 1 register
        pub const EPR1 = struct {
            /// EA [0:3]
            /// Endpoint address
            EA: ?u4 = null,
            /// STAT_TX [4:5]
            /// Status bits, for transmission transfers
            STAT_TX: ?u2 = null,
            /// DTOG_TX [6:6]
            /// Data Toggle, for transmission transfers
            DTOG_TX: ?u1 = null,
            /// CTR_TX [7:7]
            /// Correct Transfer for transmission
            CTR_TX: ?u1 = null,
            /// EP_KIND [8:8]
            /// Endpoint kind
            EP_KIND: ?u1 = null,
            /// EP_TYPE [9:10]
            /// Endpoint type
            EP_TYPE: ?u2 = null,
            /// SETUP [11:11]
            /// Setup transaction completed
            SETUP: ?u1 = null,
            /// STAT_RX [12:13]
            /// Status bits, for reception transfers
            STAT_RX: ?u2 = null,
            /// DTOG_RX [14:14]
            /// Data Toggle, for reception transfers
            DTOG_RX: ?u1 = null,
            /// CTR_RX [15:15]
            /// Correct transfer for reception
            CTR_RX: ?u1 = null,
        };

        /// endpoint 2 register
        pub const EPR2 = struct {
            /// EA [0:3]
            /// Endpoint address
            EA: ?u4 = null,
            /// STAT_TX [4:5]
            /// Status bits, for transmission transfers
            STAT_TX: ?u2 = null,
            /// DTOG_TX [6:6]
            /// Data Toggle, for transmission transfers
            DTOG_TX: ?u1 = null,
            /// CTR_TX [7:7]
            /// Correct Transfer for transmission
            CTR_TX: ?u1 = null,
            /// EP_KIND [8:8]
            /// Endpoint kind
            EP_KIND: ?u1 = null,
            /// EP_TYPE [9:10]
            /// Endpoint type
            EP_TYPE: ?u2 = null,
            /// SETUP [11:11]
            /// Setup transaction completed
            SETUP: ?u1 = null,
            /// STAT_RX [12:13]
            /// Status bits, for reception transfers
            STAT_RX: ?u2 = null,
            /// DTOG_RX [14:14]
            /// Data Toggle, for reception transfers
            DTOG_RX: ?u1 = null,
            /// CTR_RX [15:15]
            /// Correct transfer for reception
            CTR_RX: ?u1 = null,
        };

        /// endpoint 3 register
        pub const EPR3 = struct {
            /// EA [0:3]
            /// Endpoint address
            EA: ?u4 = null,
            /// STAT_TX [4:5]
            /// Status bits, for transmission transfers
            STAT_TX: ?u2 = null,
            /// DTOG_TX [6:6]
            /// Data Toggle, for transmission transfers
            DTOG_TX: ?u1 = null,
            /// CTR_TX [7:7]
            /// Correct Transfer for transmission
            CTR_TX: ?u1 = null,
            /// EP_KIND [8:8]
            /// Endpoint kind
            EP_KIND: ?u1 = null,
            /// EP_TYPE [9:10]
            /// Endpoint type
            EP_TYPE: ?u2 = null,
            /// SETUP [11:11]
            /// Setup transaction completed
            SETUP: ?u1 = null,
            /// STAT_RX [12:13]
            /// Status bits, for reception transfers
            STAT_RX: ?u2 = null,
            /// DTOG_RX [14:14]
            /// Data Toggle, for reception transfers
            DTOG_RX: ?u1 = null,
            /// CTR_RX [15:15]
            /// Correct transfer for reception
            CTR_RX: ?u1 = null,
        };

        /// endpoint 4 register
        pub const EPR4 = struct {
            /// EA [0:3]
            /// Endpoint address
            EA: ?u4 = null,
            /// STAT_TX [4:5]
            /// Status bits, for transmission transfers
            STAT_TX: ?u2 = null,
            /// DTOG_TX [6:6]
            /// Data Toggle, for transmission transfers
            DTOG_TX: ?u1 = null,
            /// CTR_TX [7:7]
            /// Correct Transfer for transmission
            CTR_TX: ?u1 = null,
            /// EP_KIND [8:8]
            /// Endpoint kind
            EP_KIND: ?u1 = null,
            /// EP_TYPE [9:10]
            /// Endpoint type
            EP_TYPE: ?u2 = null,
            /// SETUP [11:11]
            /// Setup transaction completed
            SETUP: ?u1 = null,
            /// STAT_RX [12:13]
            /// Status bits, for reception transfers
            STAT_RX: ?u2 = null,
            /// DTOG_RX [14:14]
            /// Data Toggle, for reception transfers
            DTOG_RX: ?u1 = null,
            /// CTR_RX [15:15]
            /// Correct transfer for reception
            CTR_RX: ?u1 = null,
        };

        /// endpoint 5 register
        pub const EPR5 = struct {
            /// EA [0:3]
            /// Endpoint address
            EA: ?u4 = null,
            /// STAT_TX [4:5]
            /// Status bits, for transmission transfers
            STAT_TX: ?u2 = null,
            /// DTOG_TX [6:6]
            /// Data Toggle, for transmission transfers
            DTOG_TX: ?u1 = null,
            /// CTR_TX [7:7]
            /// Correct Transfer for transmission
            CTR_TX: ?u1 = null,
            /// EP_KIND [8:8]
            /// Endpoint kind
            EP_KIND: ?u1 = null,
            /// EP_TYPE [9:10]
            /// Endpoint type
            EP_TYPE: ?u2 = null,
            /// SETUP [11:11]
            /// Setup transaction completed
            SETUP: ?u1 = null,
            /// STAT_RX [12:13]
            /// Status bits, for reception transfers
            STAT_RX: ?u2 = null,
            /// DTOG_RX [14:14]
            /// Data Toggle, for reception transfers
            DTOG_RX: ?u1 = null,
            /// CTR_RX [15:15]
            /// Correct transfer for reception
            CTR_RX: ?u1 = null,
        };

        /// endpoint 6 register
        pub const EPR6 = struct {
            /// EA [0:3]
            /// Endpoint address
            EA: ?u4 = null,
            /// STAT_TX [4:5]
            /// Status bits, for transmission transfers
            STAT_TX: ?u2 = null,
            /// DTOG_TX [6:6]
            /// Data Toggle, for transmission transfers
            DTOG_TX: ?u1 = null,
            /// CTR_TX [7:7]
            /// Correct Transfer for transmission
            CTR_TX: ?u1 = null,
            /// EP_KIND [8:8]
            /// Endpoint kind
            EP_KIND: ?u1 = null,
            /// EP_TYPE [9:10]
            /// Endpoint type
            EP_TYPE: ?u2 = null,
            /// SETUP [11:11]
            /// Setup transaction completed
            SETUP: ?u1 = null,
            /// STAT_RX [12:13]
            /// Status bits, for reception transfers
            STAT_RX: ?u2 = null,
            /// DTOG_RX [14:14]
            /// Data Toggle, for reception transfers
            DTOG_RX: ?u1 = null,
            /// CTR_RX [15:15]
            /// Correct transfer for reception
            CTR_RX: ?u1 = null,
        };

        /// endpoint 7 register
        pub const EPR7 = struct {
            /// EA [0:3]
            /// Endpoint address
            EA: ?u4 = null,
            /// STAT_TX [4:5]
            /// Status bits, for transmission transfers
            STAT_TX: ?u2 = null,
            /// DTOG_TX [6:6]
            /// Data Toggle, for transmission transfers
            DTOG_TX: ?u1 = null,
            /// CTR_TX [7:7]
            /// Correct Transfer for transmission
            CTR_TX: ?u1 = null,
            /// EP_KIND [8:8]
            /// Endpoint kind
            EP_KIND: ?u1 = null,
            /// EP_TYPE [9:10]
            /// Endpoint type
            EP_TYPE: ?u2 = null,
            /// SETUP [11:11]
            /// Setup transaction completed
            SETUP: ?u1 = null,
            /// STAT_RX [12:13]
            /// Status bits, for reception transfers
            STAT_RX: ?u2 = null,
            /// DTOG_RX [14:14]
            /// Data Toggle, for reception transfers
            DTOG_RX: ?u1 = null,
            /// CTR_RX [15:15]
            /// Correct transfer for reception
            CTR_RX: ?u1 = null,
        };

        /// control register
        pub const CNTR = struct {
            /// FRES [0:0]
            /// Force USB Reset
            FRES: ?u1 = null,
            /// PDWN [1:1]
            /// Power down
            PDWN: ?u1 = null,
            /// LPMODE [2:2]
            /// Low-power mode
            LPMODE: ?u1 = null,
            /// FSUSP [3:3]
            /// Force suspend
            FSUSP: ?u1 = null,
            /// RESUME [4:4]
            /// Resume request
            RESUME: ?u1 = null,
            /// ESOFM [8:8]
            /// Expected start of frame interrupt mask
            ESOFM: ?u1 = null,
            /// SOFM [9:9]
            /// Start of frame interrupt mask
            SOFM: ?u1 = null,
            /// RESETM [10:10]
            /// USB reset interrupt mask
            RESETM: ?u1 = null,
            /// SUSPM [11:11]
            /// Suspend mode interrupt mask
            SUSPM: ?u1 = null,
            /// WKUPM [12:12]
            /// Wakeup interrupt mask
            WKUPM: ?u1 = null,
            /// ERRM [13:13]
            /// Error interrupt mask
            ERRM: ?u1 = null,
            /// PMAOVRM [14:14]
            /// Packet memory area over / underrun interrupt mask
            PMAOVRM: ?u1 = null,
            /// CTRM [15:15]
            /// Correct transfer interrupt mask
            CTRM: ?u1 = null,
        };

        /// interrupt status register
        pub const ISTR = struct {
            /// EP_ID [0:3]
            /// Endpoint Identifier
            EP_ID: ?u4 = null,
            /// DIR [4:4]
            /// Direction of transaction
            DIR: ?u1 = null,
            /// ESOF [8:8]
            /// Expected start frame
            ESOF: ?u1 = null,
            /// SOF [9:9]
            /// start of frame
            SOF: ?u1 = null,
            /// RESET [10:10]
            /// reset request
            RESET: ?u1 = null,
            /// SUSP [11:11]
            /// Suspend mode request
            SUSP: ?u1 = null,
            /// WKUP [12:12]
            /// Wakeup
            WKUP: ?u1 = null,
            /// ERR [13:13]
            /// Error
            ERR: ?u1 = null,
            /// PMAOVR [14:14]
            /// Packet memory area over / underrun
            PMAOVR: ?u1 = null,
            /// CTR [15:15]
            /// Correct transfer
            CTR: ?u1 = null,
        };

        /// frame number register
        pub const FNR = struct {
            /// FN [0:10]
            /// Frame number
            FN: ?u11 = null,
            /// LSOF [11:12]
            /// Lost SOF
            LSOF: ?u2 = null,
            /// LCK [13:13]
            /// Locked
            LCK: ?u1 = null,
            /// RXDM [14:14]
            /// Receive data - line status
            RXDM: ?u1 = null,
            /// RXDP [15:15]
            /// Receive data + line status
            RXDP: ?u1 = null,
        };

        /// device address
        pub const DADDR = struct {
            /// ADD [0:6]
            /// Device address
            ADD: ?u7 = null,
            /// EF [7:7]
            /// Enable function
            EF: ?u1 = null,
        };

        /// Buffer table address
        pub const BTABLE = struct {
            /// BTABLE [3:15]
            /// Buffer table
            BTABLE: ?u13 = null,
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
};

pub const interrupts = enum(u32) {
    /// Reset
    Reset = 1,
    /// Non-maskable interrupt
    NMI = 2,
    /// Exception interrupt
    EXC = 3,
    /// System timer interrupt
    SysTick = 12,
    /// Software interrupt
    SW = 14,
    /// Window Watchdog interrupt
    WWDG = 16,
    /// PVD through EXTI line detection interrupt
    PVD = 17,
    /// Tamper interrupt
    TAMPER = 18,
    /// RTC global interrupt
    RTC = 19,
    /// Flash global interrupt
    FLASH = 20,
    /// RCC global interrupt
    RCC = 21,
    /// EXTI Line0 interrupt
    EXTI0 = 22,
    /// EXTI Line1 interrupt
    EXTI1 = 23,
    /// EXTI Line2 interrupt
    EXTI2 = 24,
    /// EXTI Line3 interrupt
    EXTI3 = 25,
    /// EXTI Line4 interrupt
    EXTI4 = 26,
    /// DMA1 Channel1 global interrupt
    DMA1_CH1 = 27,
    /// DMA1 Channel2 global interrupt
    DMA1_CH2 = 28,
    /// DMA1 Channel3 global interrupt
    DMA1_CH3 = 29,
    /// DMA1 Channel4 global interrupt
    DMA1_CH4 = 30,
    /// DMA1 Channel5 global interrupt
    DMA1_CH5 = 31,
    /// DMA1 Channel6 global interrupt
    DMA1_CH6 = 32,
    /// DMA1 Channel7 global interrupt
    DMA1_CH7 = 33,
    /// ADC1 global interrupt
    ADC = 34,
    /// EXTI Line[9:5] interrupts
    EXTI9_5 = 39,
    /// TIM1 Break interrupt and TIM9 global interrupt
    TIM1_BRK = 40,
    /// TIM1 Update interrupt and TIM10 global interrupt
    TIM1_UP = 41,
    /// TIM1 Trigger and Commutation interrupts and TIM11 global interrupt
    TIM1_TRG_COM = 42,
    /// TIM1 Capture Compare interrupt
    TIM1_CC = 43,
    /// TIM2 global interrupt
    TIM2 = 44,
    /// TIM3 global interrupt
    TIM3 = 45,
    /// TIM4 global interrupt
    TIM4 = 46,
    /// I2C1 event interrupt
    I2C1_EV = 47,
    /// I2C1 error interrupt
    I2C1_ER = 48,
    /// I2C2 event interrupt
    I2C2_EV = 49,
    /// I2C2 error interrupt
    I2C2_ER = 50,
    /// SPI1 global interrupt
    SPI1 = 51,
    /// SPI2 global interrupt
    SPI2 = 52,
    /// USART1 global interrupt
    USART1 = 53,
    /// USART2 global interrupt
    USART2 = 54,
    /// USART3 global interrupt
    USART3 = 55,
    /// EXTI Line[15:10] interrupts
    EXTI15_10 = 56,
    /// RTC Alarms through EXTI line interrupt
    RTCAlarm = 57,
    /// USB Device FS Wakeup through EXTI line interrupt
    USB_FS_WKUP = 58,
    /// USBFS_IRQHandler
    USBFS = 59,

    pub const VectorTable = struct {
        const call_conv: @import("std").builtin.CallingConvention = if (@import("builtin").cpu.arch != .riscv32) .c else .{ .riscv32_interrupt = .{ .mode = .machine } };
        const Handler = *const fn () callconv(call_conv) void;

        /// 1: Reset
        Reset: ?Handler = null,
        /// 2: Non-maskable interrupt
        NMI: ?Handler = null,
        /// 3: Exception interrupt
        EXC: ?Handler = null,
        /// 12: System timer interrupt
        SysTick: ?Handler = null,
        /// 14: Software interrupt
        SW: ?Handler = null,
        /// 16: Window Watchdog interrupt
        WWDG: ?Handler = null,
        /// 17: PVD through EXTI line detection interrupt
        PVD: ?Handler = null,
        /// 18: Tamper interrupt
        TAMPER: ?Handler = null,
        /// 19: RTC global interrupt
        RTC: ?Handler = null,
        /// 20: Flash global interrupt
        FLASH: ?Handler = null,
        /// 21: RCC global interrupt
        RCC: ?Handler = null,
        /// 22: EXTI Line0 interrupt
        EXTI0: ?Handler = null,
        /// 23: EXTI Line1 interrupt
        EXTI1: ?Handler = null,
        /// 24: EXTI Line2 interrupt
        EXTI2: ?Handler = null,
        /// 25: EXTI Line3 interrupt
        EXTI3: ?Handler = null,
        /// 26: EXTI Line4 interrupt
        EXTI4: ?Handler = null,
        /// 27: DMA1 Channel1 global interrupt
        DMA1_CH1: ?Handler = null,
        /// 28: DMA1 Channel2 global interrupt
        DMA1_CH2: ?Handler = null,
        /// 29: DMA1 Channel3 global interrupt
        DMA1_CH3: ?Handler = null,
        /// 30: DMA1 Channel4 global interrupt
        DMA1_CH4: ?Handler = null,
        /// 31: DMA1 Channel5 global interrupt
        DMA1_CH5: ?Handler = null,
        /// 32: DMA1 Channel6 global interrupt
        DMA1_CH6: ?Handler = null,
        /// 33: DMA1 Channel7 global interrupt
        DMA1_CH7: ?Handler = null,
        /// 34: ADC1 global interrupt
        ADC: ?Handler = null,
        /// 39: EXTI Line[9:5] interrupts
        EXTI9_5: ?Handler = null,
        /// 40: TIM1 Break interrupt and TIM9 global interrupt
        TIM1_BRK: ?Handler = null,
        /// 41: TIM1 Update interrupt and TIM10 global interrupt
        TIM1_UP: ?Handler = null,
        /// 42: TIM1 Trigger and Commutation interrupts and TIM11 global interrupt
        TIM1_TRG_COM: ?Handler = null,
        /// 43: TIM1 Capture Compare interrupt
        TIM1_CC: ?Handler = null,
        /// 44: TIM2 global interrupt
        TIM2: ?Handler = null,
        /// 45: TIM3 global interrupt
        TIM3: ?Handler = null,
        /// 46: TIM4 global interrupt
        TIM4: ?Handler = null,
        /// 47: I2C1 event interrupt
        I2C1_EV: ?Handler = null,
        /// 48: I2C1 error interrupt
        I2C1_ER: ?Handler = null,
        /// 49: I2C2 event interrupt
        I2C2_EV: ?Handler = null,
        /// 50: I2C2 error interrupt
        I2C2_ER: ?Handler = null,
        /// 51: SPI1 global interrupt
        SPI1: ?Handler = null,
        /// 52: SPI2 global interrupt
        SPI2: ?Handler = null,
        /// 53: USART1 global interrupt
        USART1: ?Handler = null,
        /// 54: USART2 global interrupt
        USART2: ?Handler = null,
        /// 55: USART3 global interrupt
        USART3: ?Handler = null,
        /// 56: EXTI Line[15:10] interrupts
        EXTI15_10: ?Handler = null,
        /// 57: RTC Alarms through EXTI line interrupt
        RTCAlarm: ?Handler = null,
        /// 58: USB Device FS Wakeup through EXTI line interrupt
        USB_FS_WKUP: ?Handler = null,
        /// 59: USBFS_IRQHandler
        USBFS: ?Handler = null,
    };
};
