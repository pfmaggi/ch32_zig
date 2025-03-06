pub fn RegisterRW(comptime Register: type) type {
    return extern struct {
        raw: u32,

        const Self = @This();

        pub inline fn read(self: *volatile Self) Register {
            return @bitCast(self.raw);
        }

        pub inline fn write(self: *volatile Self, value: Register) void {
            self.write_raw(@bitCast(value));
        }

        pub inline fn modify(self: *volatile Self, new_value: anytype) void {
            var old_value = self.read();
            const info = @typeInfo(@TypeOf(new_value));
            inline for (info.Struct.fields) |field| {
                @field(old_value, field.name) = @field(new_value, field.name);
            }
            self.write(old_value);
        }

        pub inline fn write_raw(self: *volatile Self, value: u32) void {
            self.raw = value;
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
    pub const GPIOx = enum(u32) {
        GPIOA = 0x40010800,
        GPIOB = 0x40010c00,
        GPIOC = 0x40011000,
        GPIOD = 0x40011400,

        pub inline fn get(self: GPIOx) *volatile types.GPIOx {
            return types.GPIOx.from(@intFromEnum(self));
        }
    };
    /// General purpose I/O
    pub const GPIOA = GPIOx.GPIOA.get();
    /// General purpose I/O
    pub const GPIOB = GPIOx.GPIOB.get();
    /// General purpose I/O
    pub const GPIOC = GPIOx.GPIOC.get();
    /// General purpose I/O
    pub const GPIOD = GPIOx.GPIOD.get();

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
    pub const TIM1 = types.TIM1.from(0x40012c00);

    /// General purpose timer
    pub const TIM2x = enum(u32) {
        TIM2 = 0x40000000,
        TIM3 = 0x40000400,
        TIM4 = 0x40000800,

        pub inline fn get(self: TIM2) *volatile types.TIM2 {
            return types.TIM2.from(@intFromEnum(self));
        }
    };
    /// General purpose timer
    pub const TIM2 = TIM2.TIM2.get();
    /// General purpose timer
    pub const TIM3 = TIM2.TIM3.get();
    /// General purpose timer
    pub const TIM4 = TIM2.TIM4.get();

    /// Inter integrated circuit
    pub const I2Cx = enum(u32) {
        I2C1 = 0x40005400,
        I2C2 = 0x40005800,

        pub inline fn get(self: I2Cx) *volatile types.I2Cx {
            return types.I2Cx.from(@intFromEnum(self));
        }
    };
    /// Inter integrated circuit
    pub const I2C1 = I2Cx.I2C1.get();
    /// Inter integrated circuit
    pub const I2C2 = I2Cx.I2C2.get();

    /// Serial peripheral interface
    pub const SPIx = enum(u32) {
        SPI1 = 0x40013000,
        SPI2 = 0x40003800,

        pub inline fn get(self: SPIx) *volatile types.SPIx {
            return types.SPIx.from(@intFromEnum(self));
        }
    };
    /// Serial peripheral interface
    pub const SPI1 = SPIx.SPI1.get();
    /// Serial peripheral interface
    pub const SPI2 = SPIx.SPI2.get();

    /// Universal synchronous asynchronous receiver transmitter
    pub const USARTx = enum(u32) {
        USART1 = 0x40013800,
        USART2 = 0x40004400,
        USART3 = 0x40004800,

        pub inline fn get(self: USARTx) *volatile types.USARTx {
            return types.USARTx.from(@intFromEnum(self));
        }
    };
    /// Universal synchronous asynchronous receiver transmitter
    pub const USART1 = USARTx.USART1.get();
    /// Universal synchronous asynchronous receiver transmitter
    pub const USART2 = USARTx.USART2.get();
    /// Universal synchronous asynchronous receiver transmitter
    pub const USART3 = USARTx.USART3.get();

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
        pub fn from(base: u32) *volatile types.PWR {
            return @ptrFromInt(base);
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
        }),

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
        }),
    };

    /// Reset and clock control
    pub const RCC = extern struct {
        pub fn from(base: u32) *volatile types.RCC {
            return @ptrFromInt(base);
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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),
    };

    /// extension configuration
    pub const EXTEND = extern struct {
        pub fn from(base: u32) *volatile types.EXTEND {
            return @ptrFromInt(base);
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
        }),
    };

    /// General purpose I/O
    /// Type for: GPIOA GPIOB GPIOC GPIOD 
    pub const GPIOx = extern struct {
        pub fn from(base: u32) *volatile types.GPIOx {
            return @ptrFromInt(base);
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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),
    };

    /// Alternate function I/O
    pub const AFIO = extern struct {
        pub fn from(base: u32) *volatile types.AFIO {
            return @ptrFromInt(base);
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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),
    };

    /// EXTI
    pub const EXTI = extern struct {
        pub fn from(base: u32) *volatile types.EXTI {
            return @ptrFromInt(base);
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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),
    };

    /// DMA controller
    pub const DMA = extern struct {
        pub fn from(base: u32) *volatile types.DMA {
            return @ptrFromInt(base);
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
        }),

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
        }),

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
        }),

        /// DMA channel 1 number of data register
        CNTR1: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// DMA channel 1 peripheral address register
        PADDR1: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }),

        /// DMA channel 1 memory address register
        MADDR1: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }),

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
        }),

        /// DMA channel 2 number of data register
        CNTR2: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// DMA channel 2 peripheral address register
        PADDR2: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }),

        /// DMA channel 2 memory address register
        MADDR2: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }),

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
        }),

        /// DMA channel 3 number of data register
        CNTR3: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// DMA channel 3 peripheral address register
        PADDR3: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }),

        /// DMA channel 3 memory address register
        MADDR3: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }),

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
        }),

        /// DMA channel 4 number of data register
        CNTR4: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// DMA channel 4 peripheral address register
        PADDR4: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }),

        /// DMA channel 4 memory address register
        MADDR4: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }),

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
        }),

        /// DMA channel 5 number of data register
        CNTR5: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// DMA channel 5 peripheral address register
        PADDR5: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }),

        /// DMA channel 5 memory address register
        MADDR5: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }),

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
        }),

        /// DMA channel 6 number of data register
        CNTR6: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// DMA channel 6 peripheral address register
        PADDR6: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }),

        /// DMA channel 6 memory address register
        MADDR6: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }),

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
        }),

        /// DMA channel 7 number of data register
        CNTR7: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// DMA channel 7 peripheral address register
        PADDR7: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }),

        /// DMA channel 7 memory address register
        MADDR7: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }),
    };

    /// Real time clock
    pub const RTC = extern struct {
        pub fn from(base: u32) *volatile types.RTC {
            return @ptrFromInt(base);
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
        }),

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
        }),

        /// offset 0x2
        _offset2: [2]u8,

        /// RTC Prescaler Load Register High
        PSCRH: RegisterRW(packed struct(u16) {
            /// PRLH [0:3]
            /// RTC Prescaler Load Register High
            PRLH: u4 = 0,
            /// padding [4:15]
            _padding: u12 = 0,
        }),

        /// offset 0x2
        _offset3: [2]u8,

        /// RTC Prescaler Load Register Low
        PSCRL: RegisterRW(packed struct(u16) {
            /// PRLL [0:15]
            /// RTC Prescaler Divider Register Low
            PRLL: u16 = 32768,
        }),

        /// offset 0x2
        _offset4: [2]u8,

        /// RTC Prescaler Divider Register High
        DIVH: RegisterRW(packed struct(u16) {
            /// DIVH [0:3]
            /// RTC prescaler divider register high
            DIVH: u4 = 0,
            /// padding [4:15]
            _padding: u12 = 0,
        }),

        /// offset 0x2
        _offset5: [2]u8,

        /// RTC Prescaler Divider Register Low
        DIVL: RegisterRW(packed struct(u16) {
            /// DIVL [0:15]
            /// RTC prescaler divider register Low
            DIVL: u16 = 32768,
        }),

        /// offset 0x2
        _offset6: [2]u8,

        /// RTC Counter Register High
        CNTH: RegisterRW(packed struct(u16) {
            /// CNTH [0:15]
            /// RTC counter register high
            CNTH: u16 = 0,
        }),

        /// offset 0x2
        _offset7: [2]u8,

        /// RTC Counter Register Low
        CNTL: RegisterRW(packed struct(u16) {
            /// CNTL [0:15]
            /// RTC counter register Low
            CNTL: u16 = 0,
        }),

        /// offset 0x2
        _offset8: [2]u8,

        /// RTC Alarm Register High
        ALRMH: RegisterRW(packed struct(u32) {
            /// ALRMH [0:15]
            /// RTC alarm register high
            ALRMH: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// RTC Alarm Register Low
        ALRML: RegisterRW(packed struct(u16) {
            /// ALRML [0:15]
            /// RTC alarm register low
            ALRML: u16 = 0,
        }),
    };

    /// Backup registers
    pub const BKP = extern struct {
        pub fn from(base: u32) *volatile types.BKP {
            return @ptrFromInt(base);
        }

        /// offset 0x4
        _offset0: [4]u8,

        /// Backup data register (BKP_DR)
        DATAR1: RegisterRW(packed struct(u16) {
            /// D1 [0:15]
            /// Backup data
            D1: u16 = 0,
        }),

        /// offset 0x2
        _offset1: [2]u8,

        /// Backup data register (BKP_DR)
        DATAR2: RegisterRW(packed struct(u16) {
            /// D2 [0:15]
            /// Backup data
            D2: u16 = 0,
        }),

        /// offset 0x2
        _offset2: [2]u8,

        /// Backup data register (BKP_DR)
        DATAR3: RegisterRW(packed struct(u16) {
            /// D3 [0:15]
            /// Backup data
            D3: u16 = 0,
        }),

        /// offset 0x2
        _offset3: [2]u8,

        /// Backup data register (BKP_DR)
        DATAR4: RegisterRW(packed struct(u16) {
            /// D4 [0:15]
            /// Backup data
            D4: u16 = 0,
        }),

        /// offset 0x2
        _offset4: [2]u8,

        /// Backup data register (BKP_DR)
        DATAR5: RegisterRW(packed struct(u16) {
            /// D5 [0:15]
            /// Backup data
            D5: u16 = 0,
        }),

        /// offset 0x2
        _offset5: [2]u8,

        /// Backup data register (BKP_DR)
        DATAR6: RegisterRW(packed struct(u16) {
            /// D6 [0:15]
            /// Backup data
            D6: u16 = 0,
        }),

        /// offset 0x2
        _offset6: [2]u8,

        /// Backup data register (BKP_DR)
        DATAR7: RegisterRW(packed struct(u16) {
            /// D7 [0:15]
            /// Backup data
            D7: u16 = 0,
        }),

        /// offset 0x2
        _offset7: [2]u8,

        /// Backup data register (BKP_DR)
        DATAR8: RegisterRW(packed struct(u16) {
            /// D8 [0:15]
            /// Backup data
            D8: u16 = 0,
        }),

        /// offset 0x2
        _offset8: [2]u8,

        /// Backup data register (BKP_DR)
        DATAR9: RegisterRW(packed struct(u16) {
            /// D9 [0:15]
            /// Backup data
            D9: u16 = 0,
        }),

        /// offset 0x2
        _offset9: [2]u8,

        /// Backup data register (BKP_DR)
        DATAR10: RegisterRW(packed struct(u16) {
            /// D10 [0:15]
            /// Backup data
            D10: u16 = 0,
        }),

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
        }),

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
        }),

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
        }),
    };

    /// Independent watchdog
    pub const IWDG = extern struct {
        pub fn from(base: u32) *volatile types.IWDG {
            return @ptrFromInt(base);
        }

        /// Key register (IWDG_CTLR)
        CTLR: RegisterRW(packed struct(u16) {
            /// KEY [0:15]
            /// Key value
            KEY: u16 = 0,
        }),

        /// offset 0x2
        _offset1: [2]u8,

        /// Prescaler register (IWDG_PSCR)
        PSCR: RegisterRW(packed struct(u16) {
            /// PR [0:2]
            /// Prescaler divider
            PR: u3 = 0,
            /// padding [3:15]
            _padding: u13 = 0,
        }),

        /// offset 0x2
        _offset2: [2]u8,

        /// Reload register (IWDG_RLDR)
        RLDR: RegisterRW(packed struct(u16) {
            /// RL [0:11]
            /// Watchdog counter reload value
            RL: u12 = 4095,
            /// padding [12:15]
            _padding: u4 = 0,
        }),

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
        }),
    };

    /// Window watchdog
    pub const WWDG = extern struct {
        pub fn from(base: u32) *volatile types.WWDG {
            return @ptrFromInt(base);
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
        }),

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
        }),

        /// offset 0x2
        _offset2: [2]u8,

        /// Status register (WWDG_SR)
        STATR: RegisterRW(packed struct(u32) {
            /// WEIF [0:0]
            /// Early Wakeup Interrupt Flag
            WEIF: u1 = 0,
            /// padding [1:31]
            _padding: u31 = 0,
        }),
    };

    /// Advanced timer
    pub const AdvancedTimer = types.TIM1;
    /// Advanced timer
    pub const TIM1 = extern struct {
        pub fn from(base: u32) *volatile types.TIM1 {
            return @ptrFromInt(base);
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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

        /// counter
        CNT: RegisterRW(packed struct(u32) {
            /// CNT [0:15]
            /// counter value
            CNT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// prescaler
        PSC: RegisterRW(packed struct(u16) {
            /// PSC [0:15]
            /// Prescaler value
            PSC: u16 = 0,
        }),

        /// offset 0x2
        _offset13: [2]u8,

        /// auto-reload register
        ATRLR: RegisterRW(packed struct(u16) {
            /// ARR [0:15]
            /// Auto-reload value
            ARR: u16 = 65535,
        }),

        /// offset 0x2
        _offset14: [2]u8,

        /// repetition counter register
        RPTCR: RegisterRW(packed struct(u16) {
            /// REP [0:7]
            /// Repetition counter value
            REP: u8 = 0,
            /// padding [8:15]
            _padding: u8 = 0,
        }),

        /// offset 0x2
        _offset15: [2]u8,

        /// capture/compare register 1
        CH1CVR: RegisterRW(packed struct(u16) {
            /// CCR1 [0:15]
            /// Capture/Compare 1 value
            CCR1: u16 = 0,
        }),

        /// offset 0x2
        _offset16: [2]u8,

        /// capture/compare register 2
        CH2CVR: RegisterRW(packed struct(u16) {
            /// CCR2 [0:15]
            /// Capture/Compare 2 value
            CCR2: u16 = 0,
        }),

        /// offset 0x2
        _offset17: [2]u8,

        /// capture/compare register 3
        CH3CVR: RegisterRW(packed struct(u16) {
            /// CCR3 [0:15]
            /// Capture/Compare value
            CCR3: u16 = 0,
        }),

        /// offset 0x2
        _offset18: [2]u8,

        /// capture/compare register 4
        CH4CVR: RegisterRW(packed struct(u16) {
            /// CCR4 [0:15]
            /// Capture/Compare value
            CCR4: u16 = 0,
        }),

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
        }),

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
        }),

        /// offset 0x2
        _offset21: [2]u8,

        /// DMA address for full transfer
        DMAR: RegisterRW(packed struct(u32) {
            /// DMAB [0:15]
            /// DMA register for burst accesses
            DMAB: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),
    };

    /// General purpose timer
    pub const GeneralPurposeTimer = types.TIM2;
    /// General purpose timer
    pub const TIM2 = extern struct {
        pub fn from(base: u32) *volatile types.TIM2 {
            return @ptrFromInt(base);
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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

        /// offset 0x2
        _offset11: [2]u8,

        /// counter
        CNT: RegisterRW(packed struct(u16) {
            /// CNT [0:15]
            /// counter value
            CNT: u16 = 0,
        }),

        /// offset 0x2
        _offset12: [2]u8,

        /// prescaler
        PSC: RegisterRW(packed struct(u16) {
            /// PSC [0:15]
            /// Prescaler value
            PSC: u16 = 0,
        }),

        /// offset 0x2
        _offset13: [2]u8,

        /// auto-reload register
        ATRLR: RegisterRW(packed struct(u16) {
            /// ARR [0:15]
            /// Auto-reload value
            ARR: u16 = 65535,
        }),

        /// offset 0x6
        _offset14: [6]u8,

        /// capture/compare register 1
        CH1CVR: RegisterRW(packed struct(u16) {
            /// CCR1 [0:15]
            /// Capture/Compare 1 value
            CCR1: u16 = 0,
        }),

        /// offset 0x2
        _offset15: [2]u8,

        /// capture/compare register 2
        CH2CVR: RegisterRW(packed struct(u16) {
            /// CCR2 [0:15]
            /// Capture/Compare 2 value
            CCR2: u16 = 0,
        }),

        /// offset 0x2
        _offset16: [2]u8,

        /// capture/compare register 3
        CH3CVR: RegisterRW(packed struct(u16) {
            /// CCR3 [0:15]
            /// Capture/Compare value
            CCR3: u16 = 0,
        }),

        /// offset 0x2
        _offset17: [2]u8,

        /// capture/compare register 4
        CH4CVR: RegisterRW(packed struct(u16) {
            /// CCR4 [0:15]
            /// Capture/Compare value
            CCR4: u16 = 0,
        }),

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
        }),

        /// offset 0x2
        _offset19: [2]u8,

        /// DMA address for full transfer
        DMAADR: RegisterRW(packed struct(u16) {
            /// DMAB [0:15]
            /// DMA register for burst accesses
            DMAB: u16 = 0,
        }),
    };

    /// Inter integrated circuit
    /// Type for: I2C1 I2C2 
    pub const I2Cx = extern struct {
        pub fn from(base: u32) *volatile types.I2Cx {
            return @ptrFromInt(base);
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
        }),

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
        }),

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
        }),

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
        }),

        /// offset 0x2
        _offset4: [2]u8,

        /// Data register
        DATAR: RegisterRW(packed struct(u16) {
            /// DR [0:7]
            /// 8-bit data register
            DR: u8 = 0,
            /// padding [8:15]
            _padding: u8 = 0,
        }),

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
        }),

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
        }),

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
        }),

        /// offset 0x2
        _offset8: [2]u8,

        /// risetime register
        RTR: RegisterRW(packed struct(u16) {
            /// TRISE [0:5]
            /// Maximum rise time in Fast/Standard mode (Master mode)
            TRISE: u6 = 2,
            /// padding [6:15]
            _padding: u10 = 0,
        }),
    };

    /// Serial peripheral interface
    /// Type for: SPI1 SPI2 
    pub const SPIx = extern struct {
        pub fn from(base: u32) *volatile types.SPIx {
            return @ptrFromInt(base);
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
        }),

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
        }),

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
        }),

        /// offset 0x2
        _offset3: [2]u8,

        /// data register
        DATAR: RegisterRW(packed struct(u16) {
            /// DATAR [0:15]
            /// Data register
            DATAR: u16 = 0,
        }),

        /// offset 0x2
        _offset4: [2]u8,

        /// CRCR polynomial register
        CRCR: RegisterRW(packed struct(u16) {
            /// CRCPOLY [0:15]
            /// CRC polynomial register
            CRCPOLY: u16 = 7,
        }),

        /// offset 0x2
        _offset5: [2]u8,

        /// RX CRC register
        RCRCR: RegisterRW(packed struct(u16) {
            /// RxCRC [0:15]
            /// Rx CRC register
            RxCRC: u16 = 0,
        }),

        /// offset 0x2
        _offset6: [2]u8,

        /// TX CRC register
        TCRCR: RegisterRW(packed struct(u16) {
            /// TxCRC [0:15]
            /// Tx CRC register
            TxCRC: u16 = 0,
        }),

        /// offset 0xa
        _offset7: [10]u8,

        /// High speed control register
        HSCR: RegisterRW(packed struct(u16) {
            /// HSRXEN [0:0]
            /// High speed read mode enable bit
            HSRXEN: u1 = 0,
            /// padding [1:15]
            _padding: u15 = 0,
        }),
    };

    /// Universal synchronous asynchronous receiver transmitter
    /// Type for: USART1 USART2 USART3 
    pub const USARTx = extern struct {
        pub fn from(base: u32) *volatile types.USARTx {
            return @ptrFromInt(base);
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
        }),

        /// Data register
        DATAR: RegisterRW(packed struct(u32) {
            /// DR [0:8]
            /// Data value
            DR: u9 = 0,
            /// padding [9:31]
            _padding: u23 = 0,
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),
    };

    /// Analog to digital converter
    pub const ADC = extern struct {
        pub fn from(base: u32) *volatile types.ADC {
            return @ptrFromInt(base);
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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

        /// injected channel data offset register x
        IOFR1: RegisterRW(packed struct(u32) {
            /// JOFFSET1 [0:11]
            /// Data offset for injected channel x
            JOFFSET1: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }),

        /// injected channel data offset register x
        IOFR2: RegisterRW(packed struct(u32) {
            /// JOFFSET2 [0:11]
            /// Data offset for injected channel x
            JOFFSET2: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }),

        /// injected channel data offset register x
        IOFR3: RegisterRW(packed struct(u32) {
            /// JOFFSET3 [0:11]
            /// Data offset for injected channel x
            JOFFSET3: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }),

        /// injected channel data offset register x
        IOFR4: RegisterRW(packed struct(u32) {
            /// JOFFSET4 [0:11]
            /// Data offset for injected channel x
            JOFFSET4: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }),

        /// watchdog higher threshold register
        WDHTR: RegisterRW(packed struct(u32) {
            /// HT [0:11]
            /// Analog watchdog higher threshold
            HT: u12 = 4095,
            /// padding [12:31]
            _padding: u20 = 0,
        }),

        /// watchdog lower threshold register
        WDLTR: RegisterRW(packed struct(u32) {
            /// LT [0:11]
            /// Analog watchdog lower threshold
            LT: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }),

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
        }),

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
        }),

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
        }),

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
        }),

        /// injected data register x
        IDATAR1: RegisterRW(packed struct(u32) {
            /// JDATA [0:15]
            /// Injected data
            JDATA: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// injected data register x
        IDATAR2: RegisterRW(packed struct(u32) {
            /// JDATA [0:15]
            /// Injected data
            JDATA: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// injected data register x
        IDATAR3: RegisterRW(packed struct(u32) {
            /// JDATA [0:15]
            /// Injected data
            JDATA: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// injected data register x
        IDATAR4: RegisterRW(packed struct(u32) {
            /// JDATA [0:15]
            /// Injected data
            JDATA: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

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
        }),
    };

    /// Digital to analog converter
    pub const DAC1 = extern struct {
        pub fn from(base: u32) *volatile types.DAC1 {
            return @ptrFromInt(base);
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
        }),

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
        }),

        /// DAC channel1 12-bit right-aligned data holding register(DAC_R12BDHR1)
        R12BDHR1: RegisterRW(packed struct(u32) {
            /// DACC1DHR [0:11]
            /// DAC channel1 12-bit right-aligned data
            DACC1DHR: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }),

        /// DAC channel1 12-bit left aligned data holding register (DAC_L12BDHR1)
        L12BDHR1: RegisterRW(packed struct(u32) {
            /// unused [0:3]
            _unused0: u4 = 0,
            /// DACC1DHR [4:15]
            /// DAC channel1 12-bit left-aligned data
            DACC1DHR: u12 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// offset 0x4
        _offset4: [4]u8,

        /// DAC channel2 12-bit right aligned data holding register (DAC_R12BDHR2)
        R12BDHR2: RegisterRW(packed struct(u32) {
            /// DACC2DHR [0:11]
            /// DAC channel2 12-bit right-aligned data
            DACC2DHR: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }),

        /// DAC channel2 12-bit left aligned data holding register (DAC_L12BDHR2)
        L12BDHR2: RegisterRW(packed struct(u32) {
            /// unused [0:3]
            _unused0: u4 = 0,
            /// DACC2DHR [4:15]
            /// DAC channel2 12-bit left-aligned data
            DACC2DHR: u12 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// offset 0x10
        _offset6: [16]u8,

        /// DAC channel1 data output register (DAC_DOR1)
        DOR1: RegisterRW(packed struct(u32) {
            /// DACC1DOR [0:11]
            /// DAC channel1 data output
            DACC1DOR: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }),

        /// DAC channel2 data output register (DAC_DOR2)
        DOR2: RegisterRW(packed struct(u32) {
            /// DACC2DOR [0:11]
            /// DAC channel2 data output
            DACC2DOR: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }),
    };

    /// Debug support
    pub const DBG = extern struct {
        pub fn from(base: u32) *volatile types.DBG {
            return @ptrFromInt(base);
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
        }),

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
        }),
    };

    /// USB register
    pub const USBFS = extern struct {
        pub fn from(base: u32) *volatile types.USBFS {
            return @ptrFromInt(base);
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
        }),

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
        }),

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
        }),

        /// USB device address
        R8_USB_DEV_AD: RegisterRW(packed struct(u8) {
            /// MASK_USB_ADDR [0:6]
            /// bit mask for USB device address
            MASK_USB_ADDR: u7 = 0,
            /// RB_UDA_GP_BIT [7:7]
            /// general purpose bit
            RB_UDA_GP_BIT: u1 = 0,
        }),

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
        }),

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
        }),

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
        }),

        /// USB receiving length
        R8_USB_RX_LEN: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

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
        }),

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
        }),

        /// offset 0x2
        _offset10: [2]u8,

        /// endpoint 0 DMA buffer address
        R16_UEP0_DMA: RegisterRW(packed struct(u16) {
            /// padding [0:15]
            _padding: u16 = 0,
        }),

        /// offset 0x2
        _offset11: [2]u8,

        /// endpoint 1 DMA buffer address
        R16_UEP1_DMA: RegisterRW(packed struct(u16) {
            /// padding [0:15]
            _padding: u16 = 0,
        }),

        /// offset 0x2
        _offset12: [2]u8,

        /// endpoint 2 DMA buffer address;host rx endpoint buffer high address
        R16_UEP2_DMA__R16_UH_RX_DMA: RegisterRW(packed struct(u16) {
            /// padding [0:15]
            _padding: u16 = 0,
        }),

        /// offset 0x2
        _offset13: [2]u8,

        /// endpoint 3 DMA buffer address;host tx endpoint buffer high address
        R16_UEP3_DMA__R16_UH_TX_DMA: RegisterRW(packed struct(u16) {
            /// padding [0:15]
            _padding: u16 = 0,
        }),

        /// offset 0x2
        _offset14: [2]u8,

        /// endpoint 0 transmittal length
        R8_UEP0_T_LEN: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

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
        }),

        /// offset 0x1
        _offset16: [1]u8,

        /// endpoint 1 transmittal length
        R8_UEP1_T_LEN: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

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
        }),

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
        }),

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
        }),

        /// offset 0x1
        _offset20: [1]u8,

        /// endpoint 3 transmittal length;host transmittal endpoint transmittal length
        R8_UEP3_T_LEN__R8_UH_TX_LEN: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

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
        }),

        /// offset 0x1
        _offset22: [1]u8,

        /// endpoint 4 transmittal length
        R8_UEP4_T_LEN: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

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
        }),

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
        }),
    };

    /// CRC calculation unit
    pub const CRC = extern struct {
        pub fn from(base: u32) *volatile types.CRC {
            return @ptrFromInt(base);
        }

        /// Data register
        DATAR: RegisterRW(packed struct(u32) {
            /// DATA [0:31]
            /// Data Register
            DATA: u32 = 4294967295,
        }),

        /// Independent Data register
        IDATAR: RegisterRW(packed struct(u8) {
            /// IDATA [0:7]
            /// Independent Data register
            IDATA: u8 = 0,
        }),

        /// offset 0x3
        _offset2: [3]u8,

        /// Control register
        CTLR: RegisterRW(packed struct(u32) {
            /// RST [0:0]
            /// Reset bit
            RST: u1 = 0,
            /// padding [1:31]
            _padding: u31 = 0,
        }),
    };

    /// FLASH
    pub const FLASH = extern struct {
        pub fn from(base: u32) *volatile types.FLASH {
            return @ptrFromInt(base);
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
        }),

        /// Flash key register
        KEYR: RegisterRW(packed struct(u32) {
            /// KEYR [0:31]
            /// FPEC key
            KEYR: u32 = 0,
        }),

        /// Flash option key register
        OBKEYR: RegisterRW(packed struct(u32) {
            /// OBKEYR [0:31]
            /// Option byte key
            OBKEYR: u32 = 0,
        }),

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
        }),

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
        }),

        /// Flash address register
        ADDR: RegisterRW(packed struct(u32) {
            /// FAR [0:31]
            /// Flash Address
            FAR: u32 = 0,
        }),

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
        }),

        /// Write protection register
        WPR: RegisterRW(packed struct(u32) {
            /// WRP [0:31]
            /// Write protect
            WRP: u32 = 0,
        }),

        /// Extension key register
        MODEKEYR: RegisterRW(packed struct(u32) {
            /// MODEKEYR [0:31]
            /// high speed write /erase mode ENABLE
            MODEKEYR: u32 = 0,
        }),
    };

    /// Programmable Fast Interrupt Controller
    pub const PFIC = extern struct {
        pub fn from(base: u32) *volatile types.PFIC {
            return @ptrFromInt(base);
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
        }),

        /// Interrupt Status Register
        ISR2: RegisterRW(packed struct(u32) {
            /// INTENSTA [0:27]
            /// Interrupt ID Status
            INTENSTA: u28 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
        }),

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
        }),

        /// Interrupt Pending Register
        IPR2: RegisterRW(packed struct(u32) {
            /// PENDSTA [0:27]
            /// PENDSTA
            PENDSTA: u28 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
        }),

        /// offset 0x18
        _offset4: [24]u8,

        /// Interrupt Priority Register
        ITHRESDR: RegisterRW(packed struct(u32) {
            /// THRESHOLD [0:7]
            /// THRESHOLD
            THRESHOLD: u8 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }),

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
        }),

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
        }),

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
        }),

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
        }),

        /// Interrupt 1 address Register
        FIFOADDRR1: RegisterRW(packed struct(u32) {
            /// OFFADDR1 [0:23]
            /// OFFADDR1
            OFFADDR1: u24 = 0,
            /// IRQID1 [24:31]
            /// IRQID1
            IRQID1: u8 = 0,
        }),

        /// Interrupt 2 address Register
        FIFOADDRR2: RegisterRW(packed struct(u32) {
            /// OFFADDR2 [0:23]
            /// OFFADDR2
            OFFADDR2: u24 = 0,
            /// IRQID2 [24:31]
            /// IRQID2
            IRQID2: u8 = 0,
        }),

        /// Interrupt 3 address Register
        FIFOADDRR3: RegisterRW(packed struct(u32) {
            /// OFFADDR3 [0:23]
            /// OFFADDR3
            OFFADDR3: u24 = 0,
            /// IRQID3 [24:31]
            /// IRQID3
            IRQID3: u8 = 0,
        }),

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
        }),

        /// Interrupt Setting Register
        IENR2: RegisterRW(packed struct(u32) {
            /// INTEN [0:27]
            /// INTEN
            INTEN: u28 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
        }),

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
        }),

        /// Interrupt Clear Register
        IRER2: RegisterRW(packed struct(u32) {
            /// INTRSET [0:27]
            /// INTRSET
            INTRSET: u28 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
        }),

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
        }),

        /// Interrupt Pending Register
        IPSR2: RegisterRW(packed struct(u32) {
            /// PENDSET [0:27]
            /// PENDSET
            PENDSET: u28 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
        }),

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
        }),

        /// Interrupt Pending Clear Register
        IPRR2: RegisterRW(packed struct(u32) {
            /// PENDRESET [0:27]
            /// PENDRESET
            PENDRESET: u28 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
        }),

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
        }),

        /// Interrupt ACTIVE Register
        IACTR2: RegisterRW(packed struct(u32) {
            /// IACTS [0:27]
            /// IACTS
            IACTS: u28 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
        }),

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
        }),

        /// offset 0x2ec
        _offset23: [748]u8,

        /// System counting Control Register
        STK_CTLR: RegisterRW(packed struct(u32) {
            /// STE [0:27]
            /// STE
            STE: u28 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
        }),
    };

    /// Universal serial bus full-speed device interface
    pub const USBD = extern struct {
        pub fn from(base: u32) *volatile types.USBD {
            return @ptrFromInt(base);
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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

        /// offset 0x2
        _offset12: [2]u8,

        /// Buffer table address
        BTABLE: RegisterRW(packed struct(u16) {
            /// unused [0:2]
            _unused0: u3 = 0,
            /// BTABLE [3:15]
            /// Buffer table
            BTABLE: u13 = 0,
        }),
    };

    /// Device electronic signature
    pub const ESIG = extern struct {
        pub fn from(base: u32) *volatile types.ESIG {
            return @ptrFromInt(base);
        }

        /// Flash capacity register
        FLACAP: RegisterRW(packed struct(u16) {
            /// F_SIZE_15_0 [0:15]
            /// Flash size
            F_SIZE_15_0: u16 = 0,
        }),

        /// offset 0x6
        _offset1: [6]u8,

        /// Unique identity 1
        UNIID1: RegisterRW(packed struct(u32) {
            /// U_ID [0:31]
            /// Unique identity[31:0]
            U_ID: u32 = 0,
        }),

        /// Unique identity 2
        UNIID2: RegisterRW(packed struct(u32) {
            /// U_ID [0:31]
            /// Unique identity[63:32]
            U_ID: u32 = 0,
        }),

        /// Unique identity 3
        UNIID3: RegisterRW(packed struct(u32) {
            /// U_ID [0:31]
            /// Unique identity[95:64]
            U_ID: u32 = 0,
        }),
    };
};

pub const interrupts = struct {
    pub const I2C2_ER = 50;
    pub const SPI2 = 52;
    pub const DMA1_CH2 = 28;
    pub const EXTI0 = 22;
    pub const DMA1_CH4 = 30;
    pub const DMA1_CH7 = 33;
    pub const TIM1_TRG_COM = 42;
    pub const RCC = 5;
    pub const I2C1_ER = 48;
    pub const DMA1_CH1 = 27;
    pub const EXTI2 = 24;
    pub const RTCAlarm = 57;
    pub const DMA1_CH3 = 29;
    pub const I2C2_EV = 49;
    pub const USART3 = 55;
    pub const USB_FS_WKUP = 58;
    pub const TIM1_BRK = 40;
    pub const TIM3 = 45;
    pub const TIM4 = 46;
    pub const SPI1 = 51;
    pub const USART2 = 54;
    pub const PVD = 17;
    pub const EXTI4 = 26;
    pub const DMA1_CH5 = 31;
    pub const ADC = 34;
    pub const TAMPER = 18;
    pub const TIM1_UP = 41;
    pub const FLASH = 20;
    pub const I2C1_EV = 47;
    pub const EXTI9_5 = 39;
    pub const DMA1_CH6 = 32;
    pub const EXTI3 = 25;
    pub const RTC = 19;
    pub const EXTI1 = 23;
    pub const WWDG = 16;
    pub const USART1 = 53;
    pub const TIM2 = 44;
    pub const USBFS = 59;
    pub const EXTI15_10 = 56;
    pub const TIM1_CC = 43;
};
