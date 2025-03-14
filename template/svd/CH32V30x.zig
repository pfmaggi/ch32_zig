const std = @import("std");

pub fn RegisterRW(comptime Register: type) type {
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

        pub inline fn modify(self: *volatile Self, new_value: anytype) void {
            var old_value = self.read();
            const info = @typeInfo(@TypeOf(new_value));
            inline for (info.@"struct".fields) |field| {
                const new_field_value = @field(new_value, field.name);

                // Allow set boolean values.
                const old_field_value_type_info = @typeInfo(@TypeOf(@field(old_value, field.name)));
                const new_field_value_type_info = @typeInfo(@TypeOf(new_field_value));
                if (old_field_value_type_info.int.signedness == .unsigned and old_field_value_type_info.int.bits == 1 and new_field_value_type_info == .bool) {
                    @field(old_value, field.name) = if (new_field_value) 1 else 0;
                    continue;
                }

                @field(old_value, field.name) = new_field_value;
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

        pub inline fn default(_: *volatile Self) Register {
            return Register{};
        }
    };
}

pub const device_name = "CH32V30x";
pub const device_revision = "1.2";
pub const device_description = "CH32V30x View File";

pub const peripherals = struct {
    /// Random number generator
    pub const RNG = types.RNG.from(0x40023c00);

    /// Universal serial bus full-speed device interface
    pub const USB = types.USB.from(0x40005c00);

    /// Controller area network
    pub const CAN = enum(u32) {
        CAN1 = 0x40006400,
        CAN2 = 0x40006800,

        pub inline fn addr(self: CAN) u32 {
            return @intFromEnum(self);
        }

        pub inline fn get(self: CAN) *volatile types.CAN {
            return types.CAN.from(self.addr());
        }

        pub inline fn from(address: u32) CAN {
            return types.CAN.from(address);
        }
    };
    /// Controller area network
    pub const CAN1 = CAN.CAN1.get();
    /// Controller area network
    pub const CAN2 = CAN.CAN2.get();

    /// Ethernet: media access control
    pub const ETHERNET_MAC = types.ETHERNET_MAC.from(0x40028000);

    /// Ethernet: MAC management counters
    pub const ETHERNET_MMC = types.ETHERNET_MMC.from(0x40028100);

    /// Ethernet: Precision time protocol
    pub const ETHERNET_PTP = types.ETHERNET_PTP.from(0x40028700);

    /// Ethernet: DMA controller operation
    pub const ETHERNET_DMA = types.ETHERNET_DMA.from(0x40029000);

    /// Secure digital input/output interface
    pub const SDIO = types.SDIO.from(0x40018000);

    /// Flexible static memory controller
    pub const FSMC = types.FSMC.from(0xa00030d0);

    /// Digital Video Port
    pub const DVP = types.DVP.from(0x50050000);

    /// Digital to analog converter
    pub const DAC = types.DAC.from(0x40007400);

    /// Power control
    pub const PWR = types.PWR.from(0x40007000);

    /// Reset and clock control
    pub const RCC = types.RCC.from(0x40021000);

    /// Extend configuration
    pub const EXTEND = types.EXTEND.from(0x40023800);

    /// General purpose I/O
    pub const GPIO = enum(u32) {
        GPIOA = 0x40010800,
        GPIOB = 0x40010c00,
        GPIOC = 0x40011000,
        GPIOD = 0x40011400,
        GPIOE = 0x40011800,

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
    /// General purpose I/O
    pub const GPIOE = GPIO.GPIOE.get();

    /// Alternate function I/O
    pub const AFIO = types.AFIO.from(0x40010000);

    /// EXTI
    pub const EXTI = types.EXTI.from(0x40010400);

    /// DMA1 controller
    pub const DMA1 = types.DMA1.from(0x40020000);

    /// DMA2 controller
    pub const DMA2 = types.DMA2.from(0x40020400);

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
        TIM8 = 0x40013400,
        TIM9 = 0x40014c00,
        TIM10 = 0x40015000,

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
    /// Advanced timer
    pub const TIM8 = AdvancedTimer.TIM8.get();
    /// Advanced timer
    pub const TIM9 = AdvancedTimer.TIM9.get();
    /// Advanced timer
    pub const TIM10 = AdvancedTimer.TIM10.get();

    /// General purpose timer
    pub const GeneralPurposeTimer = enum(u32) {
        TIM2 = 0x40000000,
        TIM3 = 0x40000400,
        TIM4 = 0x40000800,
        TIM5 = 0x40000c00,

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
    /// General purpose timer
    pub const TIM5 = GeneralPurposeTimer.TIM5.get();

    /// Basic timer
    pub const BasicTimer = enum(u32) {
        TIM6 = 0x40001000,
        TIM7 = 0x40001400,

        pub inline fn addr(self: BasicTimer) u32 {
            return @intFromEnum(self);
        }

        pub inline fn get(self: BasicTimer) *volatile types.BasicTimer {
            return types.BasicTimer.from(self.addr());
        }

        pub inline fn from(address: u32) BasicTimer {
            return types.BasicTimer.from(address);
        }
    };
    /// Basic timer
    pub const TIM6 = BasicTimer.TIM6.get();
    /// Basic timer
    pub const TIM7 = BasicTimer.TIM7.get();

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
    pub const SPI_2 = enum(u32) {
        SPI2 = 0x40003800,
        SPI3 = 0x40003c00,

        pub inline fn addr(self: SPI_2) u32 {
            return @intFromEnum(self);
        }

        pub inline fn get(self: SPI_2) *volatile types.SPI_2 {
            return types.SPI_2.from(self.addr());
        }

        pub inline fn from(address: u32) SPI_2 {
            return types.SPI_2.from(address);
        }
    };
    /// Serial peripheral interface
    pub const SPI2 = SPI_2.SPI2.get();
    /// Serial peripheral interface
    pub const SPI3 = SPI_2.SPI3.get();

    /// Universal synchronous asynchronous receiver transmitter
    pub const USART = enum(u32) {
        USART1 = 0x40013800,
        USART2 = 0x40004400,
        USART3 = 0x40004800,
        UART4 = 0x40004c00,
        UART5 = 0x40005000,
        UART6 = 0x40001800,
        UART7 = 0x40001c00,
        UART8 = 0x40002000,

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
    /// Universal synchronous asynchronous receiver transmitter
    pub const UART4 = USART.UART4.get();
    /// Universal synchronous asynchronous receiver transmitter
    pub const UART5 = USART.UART5.get();
    /// Universal synchronous asynchronous receiver transmitter
    pub const UART6 = USART.UART6.get();
    /// Universal synchronous asynchronous receiver transmitter
    pub const UART7 = USART.UART7.get();
    /// Universal synchronous asynchronous receiver transmitter
    pub const UART8 = USART.UART8.get();

    /// Analog to digital converter
    pub const ADC1 = types.ADC1.from(0x40012400);

    /// Analog to digital converter
    pub const ADC2 = types.ADC2.from(0x40012800);

    /// USB register
    pub const USBHS = types.USBHS.from(0x40023400);

    /// CRC calculation unit
    pub const CRC = types.CRC.from(0x40023000);

    /// FLASH
    pub const FLASH = types.FLASH.from(0x40022000);

    /// USB FS OTG register
    pub const USB_OTG_FS = types.USB_OTG_FS.from(0x50000000);

    /// Programmable Fast Interrupt Controller
    pub const PFIC = types.PFIC.from(0xe000e000);
};

pub const types = struct {
    /// Random number generator
    pub const RNG = extern struct {
        pub inline fn from(base: u32) *volatile types.RNG {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.RNG) u32 {
            return @intFromPtr(self);
        }

        /// control register
        CR: RegisterRW(packed struct(u32) {
            /// unused [0:1]
            _unused0: u2 = 0,
            /// RNGEN [2:2]
            /// Random number generator enable
            RNGEN: u1 = 0,
            /// IE [3:3]
            /// Interrupt enable
            IE: u1 = 0,
            /// padding [4:31]
            _padding: u28 = 0,
        }),

        /// status register
        SR: RegisterRW(packed struct(u32) {
            /// DRDY [0:0]
            /// Data ready
            DRDY: u1 = 0,
            /// CECS [1:1]
            /// Clock error current status
            CECS: u1 = 0,
            /// SECS [2:2]
            /// Seed error current status
            SECS: u1 = 0,
            /// unused [3:4]
            _unused3: u2 = 0,
            /// CEIS [5:5]
            /// Clock error interrupt status
            CEIS: u1 = 0,
            /// SEIS [6:6]
            /// Seed error interrupt status
            SEIS: u1 = 0,
            /// padding [7:31]
            _padding: u25 = 0,
        }),

        /// data register
        DR: RegisterRW(packed struct(u32) {
            /// RNDATA [0:31]
            /// Random data
            RNDATA: u32 = 0,
        }),
    };

    /// Universal serial bus full-speed device interface
    pub const USB = extern struct {
        pub inline fn from(base: u32) *volatile types.USB {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.USB) u32 {
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
            /// unused [5:6]
            _unused5: u2 = 0,
            /// MODE_1WIRE [7:7]
            /// USB 1 WIRE MODE
            MODE_1WIRE: u1 = 0,
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
            /// RST [10:10]
            /// reset request
            RST: u1 = 0,
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
        BTABLE: RegisterRW(packed struct(u32) {
            /// unused [0:2]
            _unused0: u3 = 0,
            /// BTABLE [3:15]
            /// Buffer table
            BTABLE: u13 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),
    };

    /// Controller area network
    /// Type for: CAN1 CAN2
    pub const CAN = extern struct {
        pub const CAN1 = types.CAN.from(0x40006400);
        pub const CAN2 = types.CAN.from(0x40006800);

        pub inline fn from(base: u32) *volatile types.CAN {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.CAN) u32 {
            return @intFromPtr(self);
        }

        /// CAN Master control register
        CTLR: RegisterRW(packed struct(u32) {
            /// INRQ [0:0]
            /// Initialization request
            INRQ: u1 = 0,
            /// SLEEP [1:1]
            /// Sleep mode request
            SLEEP: u1 = 1,
            /// TXFP [2:2]
            /// Transmit FIFO priority
            TXFP: u1 = 0,
            /// RFLM [3:3]
            /// Receive FIFO locked mode
            RFLM: u1 = 0,
            /// NART [4:4]
            /// No automatic retransmission
            NART: u1 = 0,
            /// AWUM [5:5]
            /// Automatic wakeup mode
            AWUM: u1 = 0,
            /// ABOM [6:6]
            /// Automatic bus-off management
            ABOM: u1 = 0,
            /// TTCM [7:7]
            /// Time triggered communication mode
            TTCM: u1 = 0,
            /// unused [8:14]
            _unused8: u7 = 0,
            /// RST [15:15]
            /// Software master reset
            RST: u1 = 0,
            /// DBF [16:16]
            /// Debug freeze
            DBF: u1 = 1,
            /// padding [17:31]
            _padding: u15 = 0,
        }),

        /// CAN master status register
        STATR: RegisterRW(packed struct(u32) {
            /// INAK [0:0]
            /// Initialization acknowledge
            INAK: u1 = 0,
            /// SLAK [1:1]
            /// Sleep acknowledge
            SLAK: u1 = 1,
            /// ERRI [2:2]
            /// Error interrupt
            ERRI: u1 = 0,
            /// WKUI [3:3]
            /// Wakeup interrupt
            WKUI: u1 = 0,
            /// SLAKI [4:4]
            /// Sleep acknowledge interrupt
            SLAKI: u1 = 0,
            /// unused [5:7]
            _unused5: u3 = 0,
            /// TXM [8:8]
            /// Transmit mode
            TXM: u1 = 0,
            /// RXM [9:9]
            /// Receive mode
            RXM: u1 = 0,
            /// SAMP [10:10]
            /// Last sample point
            SAMP: u1 = 1,
            /// RX [11:11]
            /// Rx signal
            RX: u1 = 1,
            /// padding [12:31]
            _padding: u20 = 0,
        }),

        /// CAN transmit status register
        TSTATR: RegisterRW(packed struct(u32) {
            /// RQCP0 [0:0]
            /// Request completed mailbox0
            RQCP0: u1 = 0,
            /// TXOK0 [1:1]
            /// Transmission OK of mailbox0
            TXOK0: u1 = 0,
            /// ALST0 [2:2]
            /// Arbitration lost for mailbox0
            ALST0: u1 = 0,
            /// TERR0 [3:3]
            /// Transmission error of mailbox0
            TERR0: u1 = 0,
            /// unused [4:6]
            _unused4: u3 = 0,
            /// ABRQ0 [7:7]
            /// Abort request for mailbox0
            ABRQ0: u1 = 0,
            /// RQCP1 [8:8]
            /// Request completed mailbox1
            RQCP1: u1 = 0,
            /// TXOK1 [9:9]
            /// Transmission OK of mailbox1
            TXOK1: u1 = 0,
            /// ALST1 [10:10]
            /// Arbitration lost for mailbox1
            ALST1: u1 = 0,
            /// TERR1 [11:11]
            /// Transmission error of mailbox1
            TERR1: u1 = 0,
            /// unused [12:14]
            _unused12: u3 = 0,
            /// ABRQ1 [15:15]
            /// Abort request for mailbox 1
            ABRQ1: u1 = 0,
            /// RQCP2 [16:16]
            /// Request completed mailbox2
            RQCP2: u1 = 0,
            /// TXOK2 [17:17]
            /// Transmission OK of mailbox 2
            TXOK2: u1 = 0,
            /// ALST2 [18:18]
            /// Arbitration lost for mailbox 2
            ALST2: u1 = 0,
            /// TERR2 [19:19]
            /// Transmission error of mailbox 2
            TERR2: u1 = 0,
            /// unused [20:22]
            _unused20: u3 = 0,
            /// ABRQ2 [23:23]
            /// Abort request for mailbox 2
            ABRQ2: u1 = 0,
            /// CODE [24:25]
            /// Mailbox code
            CODE: u2 = 0,
            /// TME0 [26:26]
            /// Transmit mailbox 0 empty
            TME0: u1 = 1,
            /// TME1 [27:27]
            /// Transmit mailbox 1 empty
            TME1: u1 = 1,
            /// TME2 [28:28]
            /// Transmit mailbox 2 empty
            TME2: u1 = 1,
            /// LOW0 [29:29]
            /// Lowest priority flag for mailbox 0
            LOW0: u1 = 0,
            /// LOW1 [30:30]
            /// Lowest priority flag for mailbox 1
            LOW1: u1 = 0,
            /// LOW2 [31:31]
            /// Lowest priority flag for mailbox 2
            LOW2: u1 = 0,
        }),

        /// CAN receive FIFO 0 register
        RFIFO0: RegisterRW(packed struct(u32) {
            /// FMP0 [0:1]
            /// FIFO 0 message pending
            FMP0: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// FULL0 [3:3]
            /// FIFO 0 full
            FULL0: u1 = 0,
            /// FOVR0 [4:4]
            /// FIFO 0 overrun
            FOVR0: u1 = 0,
            /// RFOM0 [5:5]
            /// Release FIFO 0 output mailbox
            RFOM0: u1 = 0,
            /// padding [6:31]
            _padding: u26 = 0,
        }),

        /// CAN receive FIFO 1 register
        RFIFO1: RegisterRW(packed struct(u32) {
            /// FMP1 [0:1]
            /// FIFO 1 message pending
            FMP1: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// FULL1 [3:3]
            /// FIFO 1 full
            FULL1: u1 = 0,
            /// FOVR1 [4:4]
            /// FIFO 1 overrun
            FOVR1: u1 = 0,
            /// RFOM1 [5:5]
            /// Release FIFO 1 output mailbox
            RFOM1: u1 = 0,
            /// padding [6:31]
            _padding: u26 = 0,
        }),

        /// CAN interrupt enable register
        INTENR: RegisterRW(packed struct(u32) {
            /// TMEIE [0:0]
            /// Transmit mailbox empty interrupt enable
            TMEIE: u1 = 0,
            /// FMPIE0 [1:1]
            /// FIFO message pending interrupt enable
            FMPIE0: u1 = 0,
            /// FFIE0 [2:2]
            /// FIFO full interrupt enable
            FFIE0: u1 = 0,
            /// FOVIE0 [3:3]
            /// FIFO overrun interrupt enable
            FOVIE0: u1 = 0,
            /// FMPIE1 [4:4]
            /// FIFO message pending interrupt enable
            FMPIE1: u1 = 0,
            /// FFIE1 [5:5]
            /// FIFO full interrupt enable
            FFIE1: u1 = 0,
            /// FOVIE1 [6:6]
            /// FIFO overrun interrupt enable
            FOVIE1: u1 = 0,
            /// unused [7:7]
            _unused7: u1 = 0,
            /// EWGIE [8:8]
            /// Error warning interrupt enable
            EWGIE: u1 = 0,
            /// EPVIE [9:9]
            /// Error passive interrupt enable
            EPVIE: u1 = 0,
            /// BOFIE [10:10]
            /// Bus-off interrupt enable
            BOFIE: u1 = 0,
            /// LECIE [11:11]
            /// Last error code interrupt enable
            LECIE: u1 = 0,
            /// unused [12:14]
            _unused12: u3 = 0,
            /// ERRIE [15:15]
            /// Error interrupt enable
            ERRIE: u1 = 0,
            /// WKUIE [16:16]
            /// Wakeup interrupt enable
            WKUIE: u1 = 0,
            /// SLKIE [17:17]
            /// Sleep interrupt enable
            SLKIE: u1 = 0,
            /// padding [18:31]
            _padding: u14 = 0,
        }),

        /// CAN error status register
        ERRSR: RegisterRW(packed struct(u32) {
            /// EWGF [0:0]
            /// Error warning flag
            EWGF: u1 = 0,
            /// EPVF [1:1]
            /// Error passive flag
            EPVF: u1 = 0,
            /// BOFF [2:2]
            /// Bus-off flag
            BOFF: u1 = 0,
            /// unused [3:3]
            _unused3: u1 = 0,
            /// LEC [4:6]
            /// Last error code
            LEC: u3 = 0,
            /// unused [7:15]
            _unused7: u1 = 0,
            _unused8: u8 = 0,
            /// TEC [16:23]
            /// Least significant byte of the 9-bit transmit error counter
            TEC: u8 = 0,
            /// REC [24:31]
            /// Receive error counter
            REC: u8 = 0,
        }),

        /// CAN bit timing register
        BTIMR: RegisterRW(packed struct(u32) {
            /// BRP [0:9]
            /// Baud rate prescaler
            BRP: u10 = 0,
            /// unused [10:15]
            _unused10: u6 = 0,
            /// TS1 [16:19]
            /// Time segment 1
            TS1: u4 = 3,
            /// TS2 [20:22]
            /// Time segment 2
            TS2: u3 = 2,
            /// unused [23:23]
            _unused23: u1 = 0,
            /// SJW [24:25]
            /// Resynchronization jump width
            SJW: u2 = 1,
            /// unused [26:29]
            _unused26: u4 = 0,
            /// LBKM [30:30]
            /// Loop back mode (debug)
            LBKM: u1 = 0,
            /// SILM [31:31]
            /// Silent mode (debug)
            SILM: u1 = 0,
        }),

        /// offset 0x160
        _offset8: [352]u8,

        /// CAN TX mailbox identifier register
        TXMIR0: RegisterRW(packed struct(u32) {
            /// TXRQ [0:0]
            /// Transmit mailbox request
            TXRQ: u1 = 0,
            /// RTR [1:1]
            /// Remote transmission request
            RTR: u1 = 0,
            /// IDE [2:2]
            /// Identifier extension
            IDE: u1 = 0,
            /// EXID [3:20]
            /// extended identifier
            EXID: u18 = 0,
            /// STID [21:31]
            /// Standard identifier
            STID: u11 = 0,
        }),

        /// CAN mailbox data length control and time stamp register
        TXMDTR0: RegisterRW(packed struct(u32) {
            /// DLC [0:3]
            /// Data length code
            DLC: u4 = 0,
            /// unused [4:7]
            _unused4: u4 = 0,
            /// TGT [8:8]
            /// Transmit global time
            TGT: u1 = 0,
            /// unused [9:15]
            _unused9: u7 = 0,
            /// TIME [16:31]
            /// Message time stamp
            TIME: u16 = 0,
        }),

        /// CAN mailbox data low register
        TXMDLR0: RegisterRW(packed struct(u32) {
            /// DATA0 [0:7]
            /// Data byte 0
            DATA0: u8 = 0,
            /// DATA1 [8:15]
            /// Data byte 1
            DATA1: u8 = 0,
            /// DATA2 [16:23]
            /// Data byte 2
            DATA2: u8 = 0,
            /// DATA3 [24:31]
            /// Data byte 3
            DATA3: u8 = 0,
        }),

        /// CAN mailbox data high register
        TXMDHR0: RegisterRW(packed struct(u32) {
            /// DATA4 [0:7]
            /// Data byte 4
            DATA4: u8 = 0,
            /// DATA5 [8:15]
            /// Data byte 5
            DATA5: u8 = 0,
            /// DATA6 [16:23]
            /// Data byte 6
            DATA6: u8 = 0,
            /// DATA7 [24:31]
            /// Data byte 7
            DATA7: u8 = 0,
        }),

        /// CAN TX mailbox identifier register
        TXMIR1: RegisterRW(packed struct(u32) {
            /// TXRQ [0:0]
            /// Transmit mailbox request
            TXRQ: u1 = 0,
            /// RTR [1:1]
            /// Remote transmission request
            RTR: u1 = 0,
            /// IDE [2:2]
            /// Identifier extension
            IDE: u1 = 0,
            /// EXID [3:20]
            /// extended identifier
            EXID: u18 = 0,
            /// STID [21:31]
            /// Standard identifier
            STID: u11 = 0,
        }),

        /// CAN mailbox data length control and time stamp register
        TXMDTR1: RegisterRW(packed struct(u32) {
            /// DLC [0:3]
            /// Data length code
            DLC: u4 = 0,
            /// unused [4:7]
            _unused4: u4 = 0,
            /// TGT [8:8]
            /// Transmit global time
            TGT: u1 = 0,
            /// unused [9:15]
            _unused9: u7 = 0,
            /// TIME [16:31]
            /// Message time stamp
            TIME: u16 = 0,
        }),

        /// CAN mailbox data low register
        TXMDLR1: RegisterRW(packed struct(u32) {
            /// DATA0 [0:7]
            /// Data byte 0
            DATA0: u8 = 0,
            /// DATA1 [8:15]
            /// Data byte 1
            DATA1: u8 = 0,
            /// DATA2 [16:23]
            /// Data byte 2
            DATA2: u8 = 0,
            /// DATA3 [24:31]
            /// Data byte 3
            DATA3: u8 = 0,
        }),

        /// CAN mailbox data high register
        TXMDHR1: RegisterRW(packed struct(u32) {
            /// DATA4 [0:7]
            /// Data byte 4
            DATA4: u8 = 0,
            /// DATA5 [8:15]
            /// Data byte 5
            DATA5: u8 = 0,
            /// DATA6 [16:23]
            /// Data byte 6
            DATA6: u8 = 0,
            /// DATA7 [24:31]
            /// Data byte 7
            DATA7: u8 = 0,
        }),

        /// CAN TX mailbox identifier register
        TXMIR2: RegisterRW(packed struct(u32) {
            /// TXRQ [0:0]
            /// Transmit mailbox request
            TXRQ: u1 = 0,
            /// RTR [1:1]
            /// Remote transmission request
            RTR: u1 = 0,
            /// IDE [2:2]
            /// Identifier extension
            IDE: u1 = 0,
            /// EXID [3:20]
            /// extended identifier
            EXID: u18 = 0,
            /// STID [21:31]
            /// Standard identifier
            STID: u11 = 0,
        }),

        /// CAN mailbox data length control and time stamp register
        TXMDTR2: RegisterRW(packed struct(u32) {
            /// DLC [0:3]
            /// Data length code
            DLC: u4 = 0,
            /// unused [4:7]
            _unused4: u4 = 0,
            /// TGT [8:8]
            /// Transmit global time
            TGT: u1 = 0,
            /// unused [9:15]
            _unused9: u7 = 0,
            /// TIME [16:31]
            /// Message time stamp
            TIME: u16 = 0,
        }),

        /// CAN mailbox data low register
        TXMDLR2: RegisterRW(packed struct(u32) {
            /// DATA0 [0:7]
            /// Data byte 0
            DATA0: u8 = 0,
            /// DATA1 [8:15]
            /// Data byte 1
            DATA1: u8 = 0,
            /// DATA2 [16:23]
            /// Data byte 2
            DATA2: u8 = 0,
            /// DATA3 [24:31]
            /// Data byte 3
            DATA3: u8 = 0,
        }),

        /// CAN mailbox data high register
        TXMDHR2: RegisterRW(packed struct(u32) {
            /// DATA4 [0:7]
            /// Data byte 4
            DATA4: u8 = 0,
            /// DATA5 [8:15]
            /// Data byte 5
            DATA5: u8 = 0,
            /// DATA6 [16:23]
            /// Data byte 6
            DATA6: u8 = 0,
            /// DATA7 [24:31]
            /// Data byte 7
            DATA7: u8 = 0,
        }),

        /// CAN receive FIFO mailbox identifier register
        RXMIR0: RegisterRW(packed struct(u32) {
            /// unused [0:0]
            _unused0: u1 = 0,
            /// RTR [1:1]
            /// Remote transmission request
            RTR: u1 = 0,
            /// IDE [2:2]
            /// Identifier extension
            IDE: u1 = 0,
            /// EXID [3:20]
            /// extended identifier
            EXID: u18 = 0,
            /// STID [21:31]
            /// Standard identifier
            STID: u11 = 0,
        }),

        /// CAN receive FIFO mailbox data length control and time stamp register
        RXMDTR0: RegisterRW(packed struct(u32) {
            /// DLC [0:3]
            /// Data length code
            DLC: u4 = 0,
            /// unused [4:7]
            _unused4: u4 = 0,
            /// FMI [8:15]
            /// Filter match index
            FMI: u8 = 0,
            /// TIME [16:31]
            /// Message time stamp
            TIME: u16 = 0,
        }),

        /// CAN receive FIFO mailbox data low register
        RXMDLR0: RegisterRW(packed struct(u32) {
            /// DATA0 [0:7]
            /// Data Byte 0
            DATA0: u8 = 0,
            /// DATA1 [8:15]
            /// Data Byte 1
            DATA1: u8 = 0,
            /// DATA2 [16:23]
            /// Data Byte 2
            DATA2: u8 = 0,
            /// DATA3 [24:31]
            /// Data Byte 3
            DATA3: u8 = 0,
        }),

        /// CAN receive FIFO mailbox data high register
        RXMDHR0: RegisterRW(packed struct(u32) {
            /// DATA4 [0:7]
            /// DATA4
            DATA4: u8 = 0,
            /// DATA5 [8:15]
            /// DATA5
            DATA5: u8 = 0,
            /// DATA6 [16:23]
            /// DATA6
            DATA6: u8 = 0,
            /// DATA7 [24:31]
            /// DATA7
            DATA7: u8 = 0,
        }),

        /// CAN receive FIFO mailbox identifier register
        RXMIR1: RegisterRW(packed struct(u32) {
            /// unused [0:0]
            _unused0: u1 = 0,
            /// RTR [1:1]
            /// Remote transmission request
            RTR: u1 = 0,
            /// IDE [2:2]
            /// Identifier extension
            IDE: u1 = 0,
            /// EXID [3:20]
            /// extended identifier
            EXID: u18 = 0,
            /// STID [21:31]
            /// Standard identifier
            STID: u11 = 0,
        }),

        /// CAN receive FIFO mailbox data length control and time stamp register
        RXMDTR1: RegisterRW(packed struct(u32) {
            /// DLC [0:3]
            /// Data length code
            DLC: u4 = 0,
            /// unused [4:7]
            _unused4: u4 = 0,
            /// FMI [8:15]
            /// Filter match index
            FMI: u8 = 0,
            /// TIME [16:31]
            /// Message time stamp
            TIME: u16 = 0,
        }),

        /// CAN receive FIFO mailbox data low register
        RXMDLR1: RegisterRW(packed struct(u32) {
            /// DATA0 [0:7]
            /// Data Byte 0
            DATA0: u8 = 0,
            /// DATA1 [8:15]
            /// Data Byte 1
            DATA1: u8 = 0,
            /// DATA2 [16:23]
            /// Data Byte 2
            DATA2: u8 = 0,
            /// DATA3 [24:31]
            /// Data Byte 3
            DATA3: u8 = 0,
        }),

        /// CAN receive FIFO mailbox data high register
        RXMDHR1: RegisterRW(packed struct(u32) {
            /// DATA4 [0:7]
            /// DATA4
            DATA4: u8 = 0,
            /// DATA5 [8:15]
            /// DATA5
            DATA5: u8 = 0,
            /// DATA6 [16:23]
            /// DATA6
            DATA6: u8 = 0,
            /// DATA7 [24:31]
            /// DATA7
            DATA7: u8 = 0,
        }),

        /// offset 0x30
        _offset28: [48]u8,

        /// CAN filter master register
        FCTLR: RegisterRW(packed struct(u32) {
            /// FINIT [0:0]
            /// Filter init mode
            FINIT: u1 = 1,
            /// unused [1:7]
            _unused1: u7 = 0,
            /// CAN2SB [8:13]
            /// CAN2 start bank
            CAN2SB: u6 = 14,
            /// padding [14:31]
            _padding: u18 = 43120,
        }),

        /// CAN filter mode register
        FMCFGR: RegisterRW(packed struct(u32) {
            /// FBM0 [0:0]
            /// Filter mode
            FBM0: u1 = 0,
            /// FBM1 [1:1]
            /// Filter mode
            FBM1: u1 = 0,
            /// FBM2 [2:2]
            /// Filter mode
            FBM2: u1 = 0,
            /// FBM3 [3:3]
            /// Filter mode
            FBM3: u1 = 0,
            /// FBM4 [4:4]
            /// Filter mode
            FBM4: u1 = 0,
            /// FBM5 [5:5]
            /// Filter mode
            FBM5: u1 = 0,
            /// FBM6 [6:6]
            /// Filter mode
            FBM6: u1 = 0,
            /// FBM7 [7:7]
            /// Filter mode
            FBM7: u1 = 0,
            /// FBM8 [8:8]
            /// Filter mode
            FBM8: u1 = 0,
            /// FBM9 [9:9]
            /// Filter mode
            FBM9: u1 = 0,
            /// FBM10 [10:10]
            /// Filter mode
            FBM10: u1 = 0,
            /// FBM11 [11:11]
            /// Filter mode
            FBM11: u1 = 0,
            /// FBM12 [12:12]
            /// Filter mode
            FBM12: u1 = 0,
            /// FBM13 [13:13]
            /// Filter mode
            FBM13: u1 = 0,
            /// padding [14:31]
            _padding: u18 = 0,
        }),

        /// offset 0x4
        _offset30: [4]u8,

        /// CAN filter scale register
        FSCFGR: RegisterRW(packed struct(u32) {
            /// FSC0 [0:0]
            /// Filter scale configuration
            FSC0: u1 = 0,
            /// FSC1 [1:1]
            /// Filter scale configuration
            FSC1: u1 = 0,
            /// FSC2 [2:2]
            /// Filter scale configuration
            FSC2: u1 = 0,
            /// FSC3 [3:3]
            /// Filter scale configuration
            FSC3: u1 = 0,
            /// FSC4 [4:4]
            /// Filter scale configuration
            FSC4: u1 = 0,
            /// FSC5 [5:5]
            /// Filter scale configuration
            FSC5: u1 = 0,
            /// FSC6 [6:6]
            /// Filter scale configuration
            FSC6: u1 = 0,
            /// FSC7 [7:7]
            /// Filter scale configuration
            FSC7: u1 = 0,
            /// FSC8 [8:8]
            /// Filter scale configuration
            FSC8: u1 = 0,
            /// FSC9 [9:9]
            /// Filter scale configuration
            FSC9: u1 = 0,
            /// FSC10 [10:10]
            /// Filter scale configuration
            FSC10: u1 = 0,
            /// FSC11 [11:11]
            /// Filter scale configuration
            FSC11: u1 = 0,
            /// FSC12 [12:12]
            /// Filter scale configuration
            FSC12: u1 = 0,
            /// FSC13 [13:13]
            /// Filter scale configuration
            FSC13: u1 = 0,
            /// padding [14:31]
            _padding: u18 = 0,
        }),

        /// offset 0x4
        _offset31: [4]u8,

        /// CAN filter FIFO assignment register
        FAFIFOR: RegisterRW(packed struct(u32) {
            /// FFA0 [0:0]
            /// Filter FIFO assignment for filter 0
            FFA0: u1 = 0,
            /// FFA1 [1:1]
            /// Filter FIFO assignment for filter 1
            FFA1: u1 = 0,
            /// FFA2 [2:2]
            /// Filter FIFO assignment for filter 2
            FFA2: u1 = 0,
            /// FFA3 [3:3]
            /// Filter FIFO assignment for filter 3
            FFA3: u1 = 0,
            /// FFA4 [4:4]
            /// Filter FIFO assignment for filter 4
            FFA4: u1 = 0,
            /// FFA5 [5:5]
            /// Filter FIFO assignment for filter 5
            FFA5: u1 = 0,
            /// FFA6 [6:6]
            /// Filter FIFO assignment for filter 6
            FFA6: u1 = 0,
            /// FFA7 [7:7]
            /// Filter FIFO assignment for filter 7
            FFA7: u1 = 0,
            /// FFA8 [8:8]
            /// Filter FIFO assignment for filter 8
            FFA8: u1 = 0,
            /// FFA9 [9:9]
            /// Filter FIFO assignment for filter 9
            FFA9: u1 = 0,
            /// FFA10 [10:10]
            /// Filter FIFO assignment for filter 10
            FFA10: u1 = 0,
            /// FFA11 [11:11]
            /// Filter FIFO assignment for filter 11
            FFA11: u1 = 0,
            /// FFA12 [12:12]
            /// Filter FIFO assignment for filter 12
            FFA12: u1 = 0,
            /// FFA13 [13:13]
            /// Filter FIFO assignment for filter 13
            FFA13: u1 = 0,
            /// padding [14:31]
            _padding: u18 = 0,
        }),

        /// offset 0x4
        _offset32: [4]u8,

        /// CAN filter activation register
        FWR: RegisterRW(packed struct(u32) {
            /// FACT0 [0:0]
            /// Filter active
            FACT0: u1 = 0,
            /// FACT1 [1:1]
            /// Filter active
            FACT1: u1 = 0,
            /// FACT2 [2:2]
            /// Filter active
            FACT2: u1 = 0,
            /// FACT3 [3:3]
            /// Filter active
            FACT3: u1 = 0,
            /// FACT4 [4:4]
            /// Filter active
            FACT4: u1 = 0,
            /// FACT5 [5:5]
            /// Filter active
            FACT5: u1 = 0,
            /// FACT6 [6:6]
            /// Filter active
            FACT6: u1 = 0,
            /// FACT7 [7:7]
            /// Filter active
            FACT7: u1 = 0,
            /// FACT8 [8:8]
            /// Filter active
            FACT8: u1 = 0,
            /// FACT9 [9:9]
            /// Filter active
            FACT9: u1 = 0,
            /// FACT10 [10:10]
            /// Filter active
            FACT10: u1 = 0,
            /// FACT11 [11:11]
            /// Filter active
            FACT11: u1 = 0,
            /// FACT12 [12:12]
            /// Filter active
            FACT12: u1 = 0,
            /// FACT13 [13:13]
            /// Filter active
            FACT13: u1 = 0,
            /// padding [14:31]
            _padding: u18 = 0,
        }),

        /// offset 0x20
        _offset33: [32]u8,

        /// Filter bank 0 register 1
        F0R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 0 register 2
        F0R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 1 register 1
        F1R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 1 register 2
        F1R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 2 register 1
        F2R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 2 register 2
        F2R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 3 register 1
        F3R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 3 register 2
        F3R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 4 register 1
        F4R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 4 register 2
        F4R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 5 register 1
        F5R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 5 register 2
        F5R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 6 register 1
        F6R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 6 register 2
        F6R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 7 register 1
        F7R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 7 register 2
        F7R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 8 register 1
        F8R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 8 register 2
        F8R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 9 register 1
        F9R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 9 register 2
        F9R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 10 register 1
        F10R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 10 register 2
        F10R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 11 register 1
        F11R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 11 register 2
        F11R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 4 register 1
        F12R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 12 register 2
        F12R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 13 register 1
        F13R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 13 register 2
        F13R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 14 register 1
        F14R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 14 register 2
        F14R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 15 register 1
        F15R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 15 register 2
        F15R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 16 register 1
        F16R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 16 register 2
        F16R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 17 register 1
        F17R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 17 register 2
        F17R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 18 register 1
        F18R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 18 register 2
        F18R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 19 register 1
        F19R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 19 register 2
        F19R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 20 register 1
        F20R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 20 register 2
        F20R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 21 register 1
        F21R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 21 register 2
        F21R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 22 register 1
        F22R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 22 register 2
        F22R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 23 register 1
        F23R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 23 register 2
        F23R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 24 register 1
        F24R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 24 register 2
        F24R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 25 register 1
        F25R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 25 register 2
        F25R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 26 register 1
        F26R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 26 register 2
        F26R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 27 register 1
        F27R1: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),

        /// Filter bank 27 register 2
        F27R2: RegisterRW(packed struct(u32) {
            /// FB0 [0:0]
            /// Filter bits
            FB0: u1 = 0,
            /// FB1 [1:1]
            /// Filter bits
            FB1: u1 = 0,
            /// FB2 [2:2]
            /// Filter bits
            FB2: u1 = 0,
            /// FB3 [3:3]
            /// Filter bits
            FB3: u1 = 0,
            /// FB4 [4:4]
            /// Filter bits
            FB4: u1 = 0,
            /// FB5 [5:5]
            /// Filter bits
            FB5: u1 = 0,
            /// FB6 [6:6]
            /// Filter bits
            FB6: u1 = 0,
            /// FB7 [7:7]
            /// Filter bits
            FB7: u1 = 0,
            /// FB8 [8:8]
            /// Filter bits
            FB8: u1 = 0,
            /// FB9 [9:9]
            /// Filter bits
            FB9: u1 = 0,
            /// FB10 [10:10]
            /// Filter bits
            FB10: u1 = 0,
            /// FB11 [11:11]
            /// Filter bits
            FB11: u1 = 0,
            /// FB12 [12:12]
            /// Filter bits
            FB12: u1 = 0,
            /// FB13 [13:13]
            /// Filter bits
            FB13: u1 = 0,
            /// FB14 [14:14]
            /// Filter bits
            FB14: u1 = 0,
            /// FB15 [15:15]
            /// Filter bits
            FB15: u1 = 0,
            /// FB16 [16:16]
            /// Filter bits
            FB16: u1 = 0,
            /// FB17 [17:17]
            /// Filter bits
            FB17: u1 = 0,
            /// FB18 [18:18]
            /// Filter bits
            FB18: u1 = 0,
            /// FB19 [19:19]
            /// Filter bits
            FB19: u1 = 0,
            /// FB20 [20:20]
            /// Filter bits
            FB20: u1 = 0,
            /// FB21 [21:21]
            /// Filter bits
            FB21: u1 = 0,
            /// FB22 [22:22]
            /// Filter bits
            FB22: u1 = 0,
            /// FB23 [23:23]
            /// Filter bits
            FB23: u1 = 0,
            /// FB24 [24:24]
            /// Filter bits
            FB24: u1 = 0,
            /// FB25 [25:25]
            /// Filter bits
            FB25: u1 = 0,
            /// FB26 [26:26]
            /// Filter bits
            FB26: u1 = 0,
            /// FB27 [27:27]
            /// Filter bits
            FB27: u1 = 0,
            /// FB28 [28:28]
            /// Filter bits
            FB28: u1 = 0,
            /// FB29 [29:29]
            /// Filter bits
            FB29: u1 = 0,
            /// FB30 [30:30]
            /// Filter bits
            FB30: u1 = 0,
            /// FB31 [31:31]
            /// Filter bits
            FB31: u1 = 0,
        }),
    };

    /// Ethernet: media access control
    pub const ETHERNET_MAC = extern struct {
        pub inline fn from(base: u32) *volatile types.ETHERNET_MAC {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.ETHERNET_MAC) u32 {
            return @intFromPtr(self);
        }

        /// Ethernet MAC configuration register (ETH_MACCR)
        MACCR: RegisterRW(packed struct(u32) {
            /// unused [0:0]
            _unused0: u1 = 0,
            /// TCF [1:1]
            /// Send clock reversal
            TCF: u1 = 0,
            /// RE [2:2]
            /// Receiver enable
            RE: u1 = 0,
            /// TE [3:3]
            /// Transmitter enable
            TE: u1 = 0,
            /// DC [4:4]
            /// Deferral check
            DC: u1 = 0,
            /// unused [5:6]
            _unused5: u2 = 0,
            /// APCS [7:7]
            /// Automatic pad/CRC stripping
            APCS: u1 = 0,
            /// unused [8:9]
            _unused8: u2 = 0,
            /// IPCO [10:10]
            /// IPv4 checksum offload
            IPCO: u1 = 0,
            /// DM [11:11]
            /// Duplex mode
            DM: u1 = 0,
            /// LM [12:12]
            /// Loopback mode
            LM: u1 = 0,
            /// unused [13:13]
            _unused13: u1 = 0,
            /// FES [14:15]
            /// Fast Ethernet speed
            FES: u2 = 0,
            /// unused [16:16]
            _unused16: u1 = 0,
            /// IFG [17:19]
            /// Interframe gap
            IFG: u3 = 0,
            /// PR [20:20]
            /// 10MPHY 50 Ohm set
            PR: u1 = 0,
            /// PI [21:21]
            /// 10MPHY TX DRIVER bisa current
            PI: u1 = 0,
            /// JD [22:22]
            /// Jabber disable
            JD: u1 = 0,
            /// WD [23:23]
            /// Watchdog disable
            WD: u1 = 0,
            /// unused [24:28]
            _unused24: u5 = 0,
            /// TCD [29:31]
            /// SEND clock delay
            TCD: u3 = 0,
        }),

        /// Ethernet MAC frame filter register (ETH_MACCFFR)
        MACFFR: RegisterRW(packed struct(u32) {
            /// PM [0:0]
            /// Promiscuous mode
            PM: u1 = 0,
            /// HU [1:1]
            /// Hash unicast
            HU: u1 = 0,
            /// HM [2:2]
            /// Hash multicast
            HM: u1 = 0,
            /// DAIF [3:3]
            /// Destination address inverse filtering
            DAIF: u1 = 0,
            /// PAM [4:4]
            /// Pass all multicast
            PAM: u1 = 0,
            /// BFD [5:5]
            /// Broadcast frames disable
            BFD: u1 = 0,
            /// PCF [6:7]
            /// Pass control frames
            PCF: u2 = 0,
            /// SAIF [8:8]
            /// Source address inverse filtering
            SAIF: u1 = 0,
            /// SAF [9:9]
            /// Source address filter
            SAF: u1 = 0,
            /// HPF [10:10]
            /// Hash or perfect filter
            HPF: u1 = 0,
            /// unused [11:30]
            _unused11: u5 = 0,
            _unused16: u8 = 0,
            _unused24: u7 = 0,
            /// RA [31:31]
            /// Receive all
            RA: u1 = 0,
        }),

        /// Ethernet MAC hash table high register
        MACHTHR: RegisterRW(packed struct(u32) {
            /// HTH [0:31]
            /// Hash table high
            HTH: u32 = 0,
        }),

        /// Ethernet MAC hash table low register
        MACHTLR: RegisterRW(packed struct(u32) {
            /// HTL [0:31]
            /// Hash table low
            HTL: u32 = 0,
        }),

        /// Ethernet MAC MII address register (ETH_MACMIIAR)
        MACMIIAR: RegisterRW(packed struct(u32) {
            /// MB [0:0]
            /// MII busy
            MB: u1 = 0,
            /// MW [1:1]
            /// MII write
            MW: u1 = 0,
            /// CR [2:4]
            /// Clock range
            CR: u3 = 0,
            /// unused [5:5]
            _unused5: u1 = 0,
            /// MR [6:10]
            /// MII register
            MR: u5 = 0,
            /// PA [11:15]
            /// PHY address
            PA: u5 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Ethernet MAC MII data register (ETH_MACMIIDR)
        MACMIIDR: RegisterRW(packed struct(u32) {
            /// MD [0:15]
            /// MII data
            MD: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Ethernet MAC flow control register (ETH_MACFCR)
        MACFCR: RegisterRW(packed struct(u32) {
            /// FCB_BPA [0:0]
            /// Flow control busy/back pressure activate
            FCB_BPA: u1 = 0,
            /// TFCE [1:1]
            /// Transmit flow control enable
            TFCE: u1 = 0,
            /// RFCE [2:2]
            /// Receive flow control enable
            RFCE: u1 = 0,
            /// UPFD [3:3]
            /// Unicast pause frame detect
            UPFD: u1 = 0,
            /// unused [4:15]
            _unused4: u4 = 0,
            _unused8: u8 = 0,
            /// PT [16:31]
            /// Pass control frames
            PT: u16 = 0,
        }),

        /// Ethernet MAC VLAN tag register (ETH_MACVLANTR)
        MACVLANTR: RegisterRW(packed struct(u32) {
            /// VLANTI [0:15]
            /// VLAN tag identifier (for receive frames)
            VLANTI: u16 = 0,
            /// VLANTC [16:16]
            /// 12-bit VLAN tag comparison
            VLANTC: u1 = 0,
            /// padding [17:31]
            _padding: u15 = 0,
        }),

        /// offset 0x8
        _offset8: [8]u8,

        /// Ethernet MAC remote wakeup frame filter register (ETH_MACRWUFFR)
        MACRWUFFR: RegisterRW(packed struct(u32) {
            /// padding [0:31]
            _padding: u32 = 0,
        }),

        /// Ethernet MAC PMT control and status register (ETH_MACPMTCSR)
        MACPMTCSR: RegisterRW(packed struct(u32) {
            /// PD [0:0]
            /// Power down
            PD: u1 = 0,
            /// MPE [1:1]
            /// Magic Packet enable
            MPE: u1 = 0,
            /// WFE [2:2]
            /// Wakeup frame enable
            WFE: u1 = 0,
            /// unused [3:4]
            _unused3: u2 = 0,
            /// MPR [5:5]
            /// Magic packet received
            MPR: u1 = 0,
            /// WFR [6:6]
            /// Wakeup frame received
            WFR: u1 = 0,
            /// unused [7:8]
            _unused7: u1 = 0,
            _unused8: u1 = 0,
            /// GU [9:9]
            /// Global unicast
            GU: u1 = 0,
            /// unused [10:30]
            _unused10: u6 = 0,
            _unused16: u8 = 0,
            _unused24: u7 = 0,
            /// WFFRPR [31:31]
            /// Wakeup frame filter register pointer reset
            WFFRPR: u1 = 0,
        }),

        /// offset 0x8
        _offset10: [8]u8,

        /// Ethernet MAC interrupt status register (ETH_MACSR)
        MACSR: RegisterRW(packed struct(u32) {
            /// unused [0:2]
            _unused0: u3 = 0,
            /// PMTS [3:3]
            /// PMT status
            PMTS: u1 = 0,
            /// MMCS [4:4]
            /// MMC status
            MMCS: u1 = 0,
            /// MMCRS [5:5]
            /// MMC receive status
            MMCRS: u1 = 0,
            /// MMCTS [6:6]
            /// MMC transmit status
            MMCTS: u1 = 0,
            /// unused [7:8]
            _unused7: u1 = 0,
            _unused8: u1 = 0,
            /// TSTS [9:9]
            /// Time stamp trigger status
            TSTS: u1 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }),

        /// Ethernet MAC interrupt mask register (ETH_MACIMR)
        MACIMR: RegisterRW(packed struct(u32) {
            /// unused [0:2]
            _unused0: u3 = 0,
            /// PMTIM [3:3]
            /// PMT interrupt mask
            PMTIM: u1 = 0,
            /// unused [4:8]
            _unused4: u4 = 0,
            _unused8: u1 = 0,
            /// TSTIM [9:9]
            /// Time stamp trigger interrupt mask
            TSTIM: u1 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }),

        /// Ethernet MAC address 0 high register (ETH_MACA0HR)
        MACA0HR: RegisterRW(packed struct(u32) {
            /// MACA0H [0:15]
            /// MAC address0 high
            MACA0H: u16 = 65535,
            /// unused [16:30]
            _unused16: u8 = 0,
            _unused24: u7 = 0,
            /// MO [31:31]
            /// Always 1
            MO: u1 = 1,
        }),

        /// Ethernet MAC address 0 low register
        MACA0LR: RegisterRW(packed struct(u32) {
            /// MACA0L [0:31]
            /// MAC address0 low
            MACA0L: u32 = 4294967295,
        }),

        /// Ethernet MAC address 1 high register (ETH_MACA1HR)
        MACA1HR: RegisterRW(packed struct(u32) {
            /// MACA1H [0:15]
            /// MAC address1 high
            MACA1H: u16 = 65535,
            /// unused [16:23]
            _unused16: u8 = 0,
            /// MBC [24:29]
            /// Mask byte control
            MBC: u6 = 0,
            /// SA [30:30]
            /// Source address
            SA: u1 = 0,
            /// AE [31:31]
            /// Address enable
            AE: u1 = 0,
        }),

        /// Ethernet MAC address1 low register
        MACA1LR: RegisterRW(packed struct(u32) {
            /// MACA1L [0:31]
            /// MAC address1 low
            MACA1L: u32 = 4294967295,
        }),

        /// Ethernet MAC address 2 high register (ETH_MACA2HR)
        MACA2HR: RegisterRW(packed struct(u32) {
            /// ETH_MACA2HR [0:15]
            /// Ethernet MAC address 2 high register
            ETH_MACA2HR: u16 = 65535,
            /// unused [16:23]
            _unused16: u8 = 0,
            /// MBC [24:29]
            /// Mask byte control
            MBC: u6 = 0,
            /// SA [30:30]
            /// Source address
            SA: u1 = 0,
            /// AE [31:31]
            /// Address enable
            AE: u1 = 0,
        }),

        /// Ethernet MAC address 2 low register
        MACA2LR: RegisterRW(packed struct(u32) {
            /// MACA2L [0:30]
            /// MAC address2 low
            MACA2L: u31 = 2147483647,
            /// padding [31:31]
            _padding: u1 = 1,
        }),

        /// Ethernet MAC address 3 high register (ETH_MACA3HR)
        MACA3HR: RegisterRW(packed struct(u32) {
            /// MACA3H [0:15]
            /// MAC address3 high
            MACA3H: u16 = 65535,
            /// unused [16:23]
            _unused16: u8 = 0,
            /// MBC [24:29]
            /// Mask byte control
            MBC: u6 = 0,
            /// SA [30:30]
            /// Source address
            SA: u1 = 0,
            /// AE [31:31]
            /// Address enable
            AE: u1 = 0,
        }),

        /// Ethernet MAC address 3 low register
        MACA3LR: RegisterRW(packed struct(u32) {
            /// MBCA3L [0:31]
            /// MAC address3 low
            MBCA3L: u32 = 4294967295,
        }),

        /// offset 0x38
        _offset20: [56]u8,

        /// Ethernet software reset control register 0
        MACCFG0: RegisterRW(packed struct(u32) {
            /// unused [0:27]
            _unused0: u8 = 0,
            _unused8: u8 = 0,
            _unused16: u8 = 0,
            _unused24: u4 = 0,
            /// DMATX_RST [28:28]
            /// DMA sent reset control
            DMATX_RST: u1 = 0,
            /// DMARX_RST [29:29]
            /// DMA receive reset control
            DMARX_RST: u1 = 0,
            /// MACTX_RST [30:30]
            /// MAC sent reset control
            MACTX_RST: u1 = 0,
            /// MACRX_RST [31:31]
            /// MAC receive reset control
            MACRX_RST: u1 = 0,
        }),
    };

    /// Ethernet: MAC management counters
    pub const ETHERNET_MMC = extern struct {
        pub inline fn from(base: u32) *volatile types.ETHERNET_MMC {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.ETHERNET_MMC) u32 {
            return @intFromPtr(self);
        }

        /// Ethernet MMC control register (ETH_MMCCR)
        MMCCR: RegisterRW(packed struct(u32) {
            /// CR [0:0]
            /// Counter reset
            CR: u1 = 0,
            /// CSR [1:1]
            /// Counter stop rollover
            CSR: u1 = 0,
            /// ROR [2:2]
            /// Reset on read
            ROR: u1 = 0,
            /// unused [3:30]
            _unused3: u5 = 0,
            _unused8: u8 = 0,
            _unused16: u8 = 0,
            _unused24: u7 = 0,
            /// MCF [31:31]
            /// MMC counter freeze
            MCF: u1 = 0,
        }),

        /// Ethernet MMC receive interrupt register (ETH_MMCRIR)
        MMCRIR: RegisterRW(packed struct(u32) {
            /// unused [0:4]
            _unused0: u5 = 0,
            /// RFCES [5:5]
            /// Received frames CRC error status
            RFCES: u1 = 0,
            /// unused [6:16]
            _unused6: u2 = 0,
            _unused8: u8 = 0,
            _unused16: u1 = 0,
            /// RGUFS [17:17]
            /// Received Good Unicast Frames Status
            RGUFS: u1 = 0,
            /// padding [18:31]
            _padding: u14 = 0,
        }),

        /// Ethernet MMC transmit interrupt register (ETH_MMCTIR)
        MMCTIR: RegisterRW(packed struct(u32) {
            /// unused [0:20]
            _unused0: u8 = 0,
            _unused8: u8 = 0,
            _unused16: u5 = 0,
            /// TGFS [21:21]
            /// Transmitted good frames status
            TGFS: u1 = 0,
            /// padding [22:31]
            _padding: u10 = 0,
        }),

        /// Ethernet MMC receive interrupt mask register (ETH_MMCRIMR)
        MMCRIMR: RegisterRW(packed struct(u32) {
            /// unused [0:4]
            _unused0: u5 = 0,
            /// RFCEM [5:5]
            /// Received frame CRC error mask
            RFCEM: u1 = 0,
            /// unused [6:16]
            _unused6: u2 = 0,
            _unused8: u8 = 0,
            _unused16: u1 = 0,
            /// RGUFM [17:17]
            /// Received good unicast frames mask
            RGUFM: u1 = 0,
            /// padding [18:31]
            _padding: u14 = 0,
        }),

        /// Ethernet MMC transmit interrupt mask register (ETH_MMCTIMR)
        MMCTIMR: RegisterRW(packed struct(u32) {
            /// unused [0:20]
            _unused0: u8 = 0,
            _unused8: u8 = 0,
            _unused16: u5 = 0,
            /// TGFM [21:21]
            /// Transmitted good frames mask
            TGFM: u1 = 0,
            /// padding [22:31]
            _padding: u10 = 0,
        }),

        /// offset 0x38
        _offset5: [56]u8,

        /// Ethernet MMC transmitted good frames after a single collision counter
        MMCTGFSCCR: RegisterRW(packed struct(u32) {
            /// TGFSCC [0:31]
            /// Transmitted good frames after a single collision counter
            TGFSCC: u32 = 0,
        }),

        /// Ethernet MMC transmitted good frames after more than a single collision
        MMCTGFMSCCR: RegisterRW(packed struct(u32) {
            /// TGFMSCC [0:31]
            /// Transmitted good frames after more than a single collision counter
            TGFMSCC: u32 = 0,
        }),

        /// offset 0x14
        _offset7: [20]u8,

        /// Ethernet MMC transmitted good frames counter register
        MMCTGFCR: RegisterRW(packed struct(u32) {
            /// TGFC [0:31]
            /// Transmitted good frames counter
            TGFC: u32 = 0,
        }),

        /// offset 0x28
        _offset8: [40]u8,

        /// Ethernet MMC received frames with CRC error counter register
        MMCRFCECR: RegisterRW(packed struct(u32) {
            /// RFCFC [0:31]
            /// Received frames with CRC error counter
            RFCFC: u32 = 0,
        }),

        /// Ethernet MMC received frames with alignment error counter register
        MMCRFAECR: RegisterRW(packed struct(u32) {
            /// RFAEC [0:31]
            /// Received frames with alignment error counter
            RFAEC: u32 = 0,
        }),

        /// offset 0x28
        _offset10: [40]u8,

        /// MMC received good unicast frames counter register
        MMCRGUFCR: RegisterRW(packed struct(u32) {
            /// RGUFC [0:31]
            /// Received good unicast frames counter
            RGUFC: u32 = 0,
        }),
    };

    /// Ethernet: Precision time protocol
    pub const ETHERNET_PTP = extern struct {
        pub inline fn from(base: u32) *volatile types.ETHERNET_PTP {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.ETHERNET_PTP) u32 {
            return @intFromPtr(self);
        }

        /// Ethernet PTP time stamp control register (ETH_PTPTSCR)
        PTPTSCR: RegisterRW(packed struct(u32) {
            /// TSE [0:0]
            /// Time stamp enable
            TSE: u1 = 0,
            /// TSFCU [1:1]
            /// Time stamp fine or coarse update
            TSFCU: u1 = 0,
            /// TSSTI [2:2]
            /// Time stamp system time initialize
            TSSTI: u1 = 0,
            /// TSSTU [3:3]
            /// Time stamp system time update
            TSSTU: u1 = 0,
            /// TSITE [4:4]
            /// Time stamp interrupt trigger enable
            TSITE: u1 = 0,
            /// TSARU [5:5]
            /// Time stamp addend register update
            TSARU: u1 = 0,
            /// padding [6:31]
            _padding: u26 = 0,
        }),

        /// Ethernet PTP subsecond increment register
        PTPSSIR: RegisterRW(packed struct(u32) {
            /// STSSI [0:7]
            /// System time subsecond increment
            STSSI: u8 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }),

        /// Ethernet PTP time stamp high register
        PTPTSHR: RegisterRW(packed struct(u32) {
            /// STS [0:31]
            /// System time second
            STS: u32 = 0,
        }),

        /// Ethernet PTP time stamp low register (ETH_PTPTSLR)
        PTPTSLR: RegisterRW(packed struct(u32) {
            /// STSS [0:30]
            /// System time subseconds
            STSS: u31 = 0,
            /// STPNS [31:31]
            /// System time positive or negative sign
            STPNS: u1 = 0,
        }),

        /// Ethernet PTP time stamp high update register
        PTPTSHUR: RegisterRW(packed struct(u32) {
            /// TSUS [0:31]
            /// Time stamp update second
            TSUS: u32 = 0,
        }),

        /// Ethernet PTP time stamp low update register (ETH_PTPTSLUR)
        PTPTSLUR: RegisterRW(packed struct(u32) {
            /// TSUSS [0:30]
            /// Time stamp update subseconds
            TSUSS: u31 = 0,
            /// TSUPNS [31:31]
            /// Time stamp update positive or negative sign
            TSUPNS: u1 = 0,
        }),

        /// Ethernet PTP time stamp addend register
        PTPTSAR: RegisterRW(packed struct(u32) {
            /// TSA [0:31]
            /// Time stamp addend
            TSA: u32 = 0,
        }),

        /// Ethernet PTP target time high register
        PTPTTHR: RegisterRW(packed struct(u32) {
            /// TTSH [0:31]
            /// Target time stamp high
            TTSH: u32 = 0,
        }),

        /// Ethernet PTP target time low register
        PTPTTLR: RegisterRW(packed struct(u32) {
            /// TTSL [0:31]
            /// Target time stamp low
            TTSL: u32 = 0,
        }),
    };

    /// Ethernet: DMA controller operation
    pub const ETHERNET_DMA = extern struct {
        pub inline fn from(base: u32) *volatile types.ETHERNET_DMA {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.ETHERNET_DMA) u32 {
            return @intFromPtr(self);
        }

        /// Ethernet DMA bus mode register
        DMABMR: RegisterRW(packed struct(u32) {
            /// SR [0:0]
            /// Software reset
            SR: u1 = 0,
            /// unused [1:1]
            _unused1: u1 = 0,
            /// DSL [2:6]
            /// Descriptor skip length
            DSL: u5 = 0,
            /// padding [7:31]
            _padding: u25 = 0,
        }),

        /// Ethernet DMA transmit poll demand register
        DMATPDR: RegisterRW(packed struct(u32) {
            /// TPD [0:31]
            /// Transmit poll demand
            TPD: u32 = 0,
        }),

        /// EHERNET DMA receive poll demand register
        DMARPDR: RegisterRW(packed struct(u32) {
            /// RPD [0:31]
            /// Receive poll demand
            RPD: u32 = 0,
        }),

        /// Ethernet DMA receive descriptor list address register
        DMARDLAR: RegisterRW(packed struct(u32) {
            /// RDLAR [0:31]
            /// Start of receive list
            RDLAR: u32 = 0,
        }),

        /// Ethernet DMA transmit descriptor list address register
        DMATDLAR: RegisterRW(packed struct(u32) {
            /// TDLAR [0:31]
            /// Start of transmit list
            TDLAR: u32 = 0,
        }),

        /// Ethernet DMA status register
        DMASR: RegisterRW(packed struct(u32) {
            /// TS [0:0]
            /// Transmit status
            TS: u1 = 0,
            /// TPSS [1:1]
            /// Transmit process stopped status
            TPSS: u1 = 0,
            /// TBUS [2:2]
            /// Transmit buffer unavailable status
            TBUS: u1 = 0,
            /// TJTS [3:3]
            /// Transmit jabber timeout status
            TJTS: u1 = 0,
            /// ROS [4:4]
            /// Receive overflow status
            ROS: u1 = 0,
            /// TUS [5:5]
            /// Transmit underflow status
            TUS: u1 = 0,
            /// RS [6:6]
            /// Receive status
            RS: u1 = 0,
            /// RBUS [7:7]
            /// Receive buffer unavailable status
            RBUS: u1 = 0,
            /// RPSS [8:8]
            /// Receive process stopped status
            RPSS: u1 = 0,
            /// PWTS [9:9]
            /// Receive watchdog timeout status
            PWTS: u1 = 0,
            /// ETS [10:10]
            /// Early transmit status
            ETS: u1 = 0,
            /// unused [11:12]
            _unused11: u2 = 0,
            /// FBES [13:13]
            /// Fatal bus error status
            FBES: u1 = 0,
            /// ERS [14:14]
            /// Early receive status
            ERS: u1 = 0,
            /// AIS [15:15]
            /// Abnormal interrupt summary
            AIS: u1 = 0,
            /// NIS [16:16]
            /// Normal interrupt summary
            NIS: u1 = 0,
            /// RPS [17:19]
            /// Receive process state
            RPS: u3 = 0,
            /// TPS [20:22]
            /// Transmit process state
            TPS: u3 = 0,
            /// EBS [23:25]
            /// Error bits status
            EBS: u3 = 0,
            /// unused [26:26]
            _unused26: u1 = 0,
            /// MMCS [27:27]
            /// MMC status
            MMCS: u1 = 0,
            /// PMTS [28:28]
            /// PMT status
            PMTS: u1 = 0,
            /// TSTS [29:29]
            /// Time stamp trigger status
            TSTS: u1 = 0,
            /// unused [30:30]
            _unused30: u1 = 0,
            /// PLS [31:31]
            /// 10MPHY Physical layer variation
            PLS: u1 = 0,
        }),

        /// Ethernet DMA operation mode register
        DMAOMR: RegisterRW(packed struct(u32) {
            /// unused [0:0]
            _unused0: u1 = 0,
            /// SR [1:1]
            /// SR
            SR: u1 = 0,
            /// unused [2:5]
            _unused2: u4 = 0,
            /// FUGF [6:6]
            /// FUGF
            FUGF: u1 = 0,
            /// FEF [7:7]
            /// FEF
            FEF: u1 = 0,
            /// unused [8:12]
            _unused8: u5 = 0,
            /// ST [13:13]
            /// ST
            ST: u1 = 0,
            /// unused [14:19]
            _unused14: u2 = 0,
            _unused16: u4 = 0,
            /// FTF [20:20]
            /// FTF
            FTF: u1 = 0,
            /// TSF [21:21]
            /// TSF
            TSF: u1 = 0,
            /// unused [22:25]
            _unused22: u2 = 0,
            _unused24: u2 = 0,
            /// DTCEFD [26:26]
            /// DTCEFD
            DTCEFD: u1 = 0,
            /// padding [27:31]
            _padding: u5 = 0,
        }),

        /// Ethernet DMA interrupt enable register
        DMAIER: RegisterRW(packed struct(u32) {
            /// TIE [0:0]
            /// Transmit interrupt enable
            TIE: u1 = 0,
            /// TPSIE [1:1]
            /// Transmit process stopped interrupt enable
            TPSIE: u1 = 0,
            /// TBUIE [2:2]
            /// Transmit buffer unavailable interrupt enable
            TBUIE: u1 = 0,
            /// TJTIE [3:3]
            /// Transmit jabber timeout interrupt enable
            TJTIE: u1 = 0,
            /// ROIE [4:4]
            /// Overflow interrupt enable
            ROIE: u1 = 0,
            /// TUIE [5:5]
            /// Underflow interrupt enable
            TUIE: u1 = 0,
            /// RIE [6:6]
            /// Receive interrupt enable
            RIE: u1 = 0,
            /// RBUIE [7:7]
            /// Receive buffer unavailable interrupt enable
            RBUIE: u1 = 0,
            /// RPSIE [8:8]
            /// Receive process stopped interrupt enable
            RPSIE: u1 = 0,
            /// RWTIE [9:9]
            /// receive watchdog timeout interrupt enable
            RWTIE: u1 = 0,
            /// ETIE [10:10]
            /// Early transmit interrupt enable
            ETIE: u1 = 0,
            /// unused [11:12]
            _unused11: u2 = 0,
            /// FBES [13:13]
            /// Fatal bus error interrupt enable
            FBES: u1 = 0,
            /// ERS [14:14]
            /// Early receive interrupt enable
            ERS: u1 = 0,
            /// AISE [15:15]
            /// Abnormal interrupt summary enable
            AISE: u1 = 0,
            /// NISE [16:16]
            /// Normal interrupt summary enable
            NISE: u1 = 0,
            /// unused [17:30]
            _unused17: u7 = 0,
            _unused24: u7 = 0,
            /// PLE [31:31]
            /// 10M Physical layer connection
            PLE: u1 = 0,
        }),

        /// Ethernet DMA missed frame and buffer overflow counter register
        DMAMFBOCR: RegisterRW(packed struct(u32) {
            /// MFC [0:15]
            /// Missed frames by the controller
            MFC: u16 = 0,
            /// OMFC [16:16]
            /// Overflow bit for missed frame counter
            OMFC: u1 = 0,
            /// MFA [17:27]
            /// Missed frames by the application
            MFA: u11 = 0,
            /// OFOC [28:28]
            /// Overflow bit for FIFO overflow counter
            OFOC: u1 = 0,
            /// padding [29:31]
            _padding: u3 = 0,
        }),

        /// offset 0x24
        _offset9: [36]u8,

        /// Ethernet DMA current host transmit descriptor register
        DMACHTDR: RegisterRW(packed struct(u32) {
            /// HTDAP [0:31]
            /// Host transmit descriptor address pointer
            HTDAP: u32 = 0,
        }),

        /// Ethernet DMA current host receive descriptor register
        DMACHRDR: RegisterRW(packed struct(u32) {
            /// HRDAP [0:31]
            /// Host receive descriptor address pointer
            HRDAP: u32 = 0,
        }),

        /// Ethernet DMA current host transmit buffer address register
        DMACHTBAR: RegisterRW(packed struct(u32) {
            /// HTBAP [0:31]
            /// Host transmit buffer address pointer
            HTBAP: u32 = 0,
        }),

        /// Ethernet DMA current host receive buffer address register
        DMACHRBAR: RegisterRW(packed struct(u32) {
            /// HRBAP [0:31]
            /// Host receive buffer address pointer
            HRBAP: u32 = 0,
        }),
    };

    /// Secure digital input/output interface
    pub const SDIO = extern struct {
        pub inline fn from(base: u32) *volatile types.SDIO {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.SDIO) u32 {
            return @intFromPtr(self);
        }

        /// Bits 1:0 = PWRCTRL: Power supply control bits
        POWER: RegisterRW(packed struct(u32) {
            /// PWRCTRL [0:1]
            /// Power supply control bits
            PWRCTRL: u2 = 0,
            /// padding [2:31]
            _padding: u30 = 0,
        }),

        /// SDI clock control register (SDIO_CLKCR)
        CLKCR: RegisterRW(packed struct(u32) {
            /// CLKDIV [0:7]
            /// Clock divide factor
            CLKDIV: u8 = 0,
            /// CLKEN [8:8]
            /// Clock enable bit
            CLKEN: u1 = 0,
            /// PWRSAV [9:9]
            /// Power saving configuration bit
            PWRSAV: u1 = 0,
            /// BYPASS [10:10]
            /// Clock divider bypass enable bit
            BYPASS: u1 = 0,
            /// WIDBUS [11:12]
            /// Wide bus mode enable bit
            WIDBUS: u2 = 0,
            /// NEGEDGE [13:13]
            /// SDIO_CK dephasing selection bit
            NEGEDGE: u1 = 0,
            /// HWFC_EN [14:14]
            /// HW Flow Control enable
            HWFC_EN: u1 = 0,
            /// padding [15:31]
            _padding: u17 = 0,
        }),

        /// Bits 31:0 = : Command argument
        ARG: RegisterRW(packed struct(u32) {
            /// CMDARG [0:31]
            /// Command argument
            CMDARG: u32 = 0,
        }),

        /// SDIO command register (SDIO_CMD)
        CMD: RegisterRW(packed struct(u32) {
            /// CMDINDEX [0:5]
            /// Command index
            CMDINDEX: u6 = 0,
            /// WAITRESP [6:7]
            /// Wait for response bits
            WAITRESP: u2 = 0,
            /// WAITINT [8:8]
            /// CPSM waits for interrupt request
            WAITINT: u1 = 0,
            /// WAITPEND [9:9]
            /// CPSM Waits for ends of data transfer (CmdPend internal signal)
            WAITPEND: u1 = 0,
            /// CPSMEN [10:10]
            /// Command path state machine (CPSM) Enable bit
            CPSMEN: u1 = 0,
            /// SDIOSuspend [11:11]
            /// SD I/O suspend command
            SDIOSuspend: u1 = 0,
            /// ENCMDcompl [12:12]
            /// Enable CMD completion
            ENCMDcompl: u1 = 0,
            /// NIEN [13:13]
            /// not Interrupt Enable
            NIEN: u1 = 0,
            /// ATACMD [14:14]
            /// CE-ATA command
            ATACMD: u1 = 0,
            /// padding [15:31]
            _padding: u17 = 0,
        }),

        /// SDIO command register
        RESPCMD: RegisterRW(packed struct(u32) {
            /// RESPCMD [0:5]
            /// Response command index
            RESPCMD: u6 = 0,
            /// padding [6:31]
            _padding: u26 = 0,
        }),

        /// Bits 127:96 = CARDSTATUS1
        RESP1: RegisterRW(packed struct(u32) {
            /// CARDSTATUS1 [0:31]
            /// Card status 1
            CARDSTATUS1: u32 = 0,
        }),

        /// Bits 95:64 = CARDSTATUS2
        RESP2: RegisterRW(packed struct(u32) {
            /// CARDSTATUS2 [0:31]
            /// Card status 2
            CARDSTATUS2: u32 = 0,
        }),

        /// Bits 63:32 = CARDSTATUS3
        RESP3: RegisterRW(packed struct(u32) {
            /// CARDSTATUS3 [0:31]
            /// Card status 3
            CARDSTATUS3: u32 = 0,
        }),

        /// Bits 31:0 = CARDSTATUS4
        RESP4: RegisterRW(packed struct(u32) {
            /// CARDSTATUS4 [0:31]
            /// Card status 4
            CARDSTATUS4: u32 = 0,
        }),

        /// Bits 31:0 = DATATIME: Data timeout period
        DTIMER: RegisterRW(packed struct(u32) {
            /// DATATIME [0:31]
            /// Data timeout period
            DATATIME: u32 = 0,
        }),

        /// Bits 24:0 = DATALENGTH: Data length value
        DLEN: RegisterRW(packed struct(u32) {
            /// DATALENGTH [0:24]
            /// Data length value
            DATALENGTH: u25 = 0,
            /// padding [25:31]
            _padding: u7 = 0,
        }),

        /// SDIO data control register (SDIO_DCTRL)
        DCTRL: RegisterRW(packed struct(u32) {
            /// DTEN [0:0]
            /// Data transfer enabled bit
            DTEN: u1 = 0,
            /// DTDIR [1:1]
            /// Data transfer direction selection
            DTDIR: u1 = 0,
            /// DTMODE [2:2]
            /// Data transfer mode selection 1: Stream or SDIO multibyte data transfer
            DTMODE: u1 = 0,
            /// DMAEN [3:3]
            /// DMA enable bit
            DMAEN: u1 = 0,
            /// DBLOCKSIZE [4:7]
            /// Data block size
            DBLOCKSIZE: u4 = 0,
            /// PWSTART [8:8]
            /// Read wait start
            PWSTART: u1 = 0,
            /// PWSTOP [9:9]
            /// Read wait stop
            PWSTOP: u1 = 0,
            /// RWMOD [10:10]
            /// Read wait mode
            RWMOD: u1 = 0,
            /// SDIOEN [11:11]
            /// SD I/O enable functions
            SDIOEN: u1 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }),

        /// Bits 24:0 = DATACOUNT: Data count value
        DCOUNT: RegisterRW(packed struct(u32) {
            /// DATACOUNT [0:24]
            /// Data count value
            DATACOUNT: u25 = 0,
            /// padding [25:31]
            _padding: u7 = 0,
        }),

        /// SDIO status register (SDIO_STA)
        STA: RegisterRW(packed struct(u32) {
            /// CCRCFAIL [0:0]
            /// Command response received (CRC check failed)
            CCRCFAIL: u1 = 0,
            /// DCRCFAIL [1:1]
            /// Data block sent/received (CRC check failed)
            DCRCFAIL: u1 = 0,
            /// CTIMEOUT [2:2]
            /// Command response timeout
            CTIMEOUT: u1 = 0,
            /// DTIMEOUT [3:3]
            /// Data timeout
            DTIMEOUT: u1 = 0,
            /// TXUNDERR [4:4]
            /// Transmit FIFO underrun error
            TXUNDERR: u1 = 0,
            /// RXOVERR [5:5]
            /// Received FIFO overrun error
            RXOVERR: u1 = 0,
            /// CMDREND [6:6]
            /// Command response received (CRC check passed)
            CMDREND: u1 = 0,
            /// CMDSENT [7:7]
            /// Command sent (no response required)
            CMDSENT: u1 = 0,
            /// DATAEND [8:8]
            /// Data end (data counter, SDIDCOUNT, is zero)
            DATAEND: u1 = 0,
            /// STBITERR [9:9]
            /// Start bit not detected on all data signals in wide bus mode
            STBITERR: u1 = 0,
            /// DBCKEND [10:10]
            /// Data block sent/received (CRC check passed)
            DBCKEND: u1 = 0,
            /// CMDACT [11:11]
            /// Command transfer in progress
            CMDACT: u1 = 0,
            /// TXACT [12:12]
            /// Data transmit in progress
            TXACT: u1 = 0,
            /// RXACT [13:13]
            /// Data receive in progress
            RXACT: u1 = 0,
            /// TXFIFOHE [14:14]
            /// Transmit FIFO half empty: at least 8 words can be written into the FIFO
            TXFIFOHE: u1 = 0,
            /// RXFIFOHF [15:15]
            /// Receive FIFO half full: there are at least 8 words in the FIFO
            RXFIFOHF: u1 = 0,
            /// TXFIFOF [16:16]
            /// Transmit FIFO full
            TXFIFOF: u1 = 0,
            /// RXFIFOF [17:17]
            /// Receive FIFO full
            RXFIFOF: u1 = 0,
            /// TXFIFOE [18:18]
            /// Transmit FIFO empty
            TXFIFOE: u1 = 0,
            /// RXFIFOE [19:19]
            /// Receive FIFO empty
            RXFIFOE: u1 = 0,
            /// TXDAVL [20:20]
            /// Data available in transmit FIFO
            TXDAVL: u1 = 0,
            /// RXDAVL [21:21]
            /// Data available in receive FIFO
            RXDAVL: u1 = 0,
            /// SDIOIT [22:22]
            /// SDIO interrupt received
            SDIOIT: u1 = 0,
            /// CEATAEND [23:23]
            /// CE-ATA command completion signal received for CMD61
            CEATAEND: u1 = 0,
            /// padding [24:31]
            _padding: u8 = 0,
        }),

        /// SDIO interrupt clear register (SDIO_ICR)
        ICR: RegisterRW(packed struct(u32) {
            /// CCRCFAILC [0:0]
            /// CCRCFAIL flag clear bit
            CCRCFAILC: u1 = 0,
            /// DCRCFAILC [1:1]
            /// DCRCFAIL flag clear bit
            DCRCFAILC: u1 = 0,
            /// CTIMEOUTC [2:2]
            /// CTIMEOUT flag clear bit
            CTIMEOUTC: u1 = 0,
            /// DTIMEOUTC [3:3]
            /// DTIMEOUT flag clear bit
            DTIMEOUTC: u1 = 0,
            /// TXUNDERRC [4:4]
            /// TXUNDERR flag clear bit
            TXUNDERRC: u1 = 0,
            /// RXOVERRC [5:5]
            /// RXOVERR flag clear bit
            RXOVERRC: u1 = 0,
            /// CMDRENDC [6:6]
            /// CMDREND flag clear bit
            CMDRENDC: u1 = 0,
            /// CMDSENTC [7:7]
            /// CMDSENT flag clear bit
            CMDSENTC: u1 = 0,
            /// DATAENDC [8:8]
            /// DATAEND flag clear bit
            DATAENDC: u1 = 0,
            /// STBITERRC [9:9]
            /// STBITERR flag clear bit
            STBITERRC: u1 = 0,
            /// DBCKENDC [10:10]
            /// DBCKEND flag clear bit
            DBCKENDC: u1 = 0,
            /// unused [11:21]
            _unused11: u5 = 0,
            _unused16: u6 = 0,
            /// SDIOITC [22:22]
            /// SDIOIT flag clear bit
            SDIOITC: u1 = 0,
            /// CEATAENDC [23:23]
            /// CEATAEND flag clear bit
            CEATAENDC: u1 = 0,
            /// padding [24:31]
            _padding: u8 = 0,
        }),

        /// SDIO mask register (SDIO_MASK)
        MASK: RegisterRW(packed struct(u32) {
            /// CCRCFAILIE [0:0]
            /// Command CRC fail interrupt enable
            CCRCFAILIE: u1 = 0,
            /// DCRCFAILIE [1:1]
            /// Data CRC fail interrupt enable
            DCRCFAILIE: u1 = 0,
            /// CTIMEOUTIE [2:2]
            /// Command timeout interrupt enable
            CTIMEOUTIE: u1 = 0,
            /// DTIMEOUTIE [3:3]
            /// Data timeout interrupt enable
            DTIMEOUTIE: u1 = 0,
            /// TXUNDERRIE [4:4]
            /// Tx FIFO underrun error interrupt enable
            TXUNDERRIE: u1 = 0,
            /// RXOVERRIE [5:5]
            /// Rx FIFO overrun error interrupt enable
            RXOVERRIE: u1 = 0,
            /// CMDRENDIE [6:6]
            /// Command response received interrupt enable
            CMDRENDIE: u1 = 0,
            /// CMDSENTIE [7:7]
            /// Command sent interrupt enable
            CMDSENTIE: u1 = 0,
            /// DATAENDIE [8:8]
            /// Data end interrupt enable
            DATAENDIE: u1 = 0,
            /// STBITERRIE [9:9]
            /// Start bit error interrupt enable
            STBITERRIE: u1 = 0,
            /// DBACKENDIE [10:10]
            /// Data block end interrupt enable
            DBACKENDIE: u1 = 0,
            /// CMDACTIE [11:11]
            /// Command acting interrupt enable
            CMDACTIE: u1 = 0,
            /// TXACTIE [12:12]
            /// Data transmit acting interrupt enable
            TXACTIE: u1 = 0,
            /// RXACTIE [13:13]
            /// Data receive acting interrupt enable
            RXACTIE: u1 = 0,
            /// TXFIFOHEIE [14:14]
            /// Tx FIFO half empty interrupt enable
            TXFIFOHEIE: u1 = 0,
            /// RXFIFOHFIE [15:15]
            /// Rx FIFO half full interrupt enable
            RXFIFOHFIE: u1 = 0,
            /// TXFIFOFIE [16:16]
            /// Tx FIFO full interrupt enable
            TXFIFOFIE: u1 = 0,
            /// RXFIFOFIE [17:17]
            /// Rx FIFO full interrupt enable
            RXFIFOFIE: u1 = 0,
            /// TXFIFOEIE [18:18]
            /// Tx FIFO empty interrupt enable
            TXFIFOEIE: u1 = 0,
            /// RXFIFOEIE [19:19]
            /// Rx FIFO empty interrupt enable
            RXFIFOEIE: u1 = 0,
            /// TXDAVLIE [20:20]
            /// Data available in Tx FIFO interrupt enable
            TXDAVLIE: u1 = 0,
            /// RXDAVLIE [21:21]
            /// Data available in Rx FIFO interrupt enable
            RXDAVLIE: u1 = 0,
            /// SDIOITIE [22:22]
            /// SDIO mode interrupt received interrupt enable
            SDIOITIE: u1 = 0,
            /// CEATENDIE [23:23]
            /// CE-ATA command completion signal received interrupt enable
            CEATENDIE: u1 = 0,
            /// padding [24:31]
            _padding: u8 = 0,
        }),

        /// offset 0x8
        _offset16: [8]u8,

        /// Bits 23:0 = FIFOCOUNT: Remaining number of words to be written to or read from the FIFO
        FIFOCNT: RegisterRW(packed struct(u32) {
            /// FIF0COUNT [0:31]
            /// Remaining number of words to be written to or read from the FIFO
            FIF0COUNT: u32 = 0,
        }),

        /// offset 0x14
        _offset17: [20]u8,

        /// Data control register 2
        DCTRL2: RegisterRW(packed struct(u32) {
            /// DBLOCKSIZE2 [0:11]
            /// data block length field of arbirary byte length pattern
            DBLOCKSIZE2: u12 = 0,
            /// unused [12:15]
            _unused12: u4 = 0,
            /// RANDOM_LEN_EN [16:16]
            /// data block arbirary byte length enable bit
            RANDOM_LEN_EN: u1 = 0,
            /// unused [17:23]
            _unused17: u7 = 0,
            /// SLV_MODE [24:24]
            /// slave mode enable bit
            SLV_MODE: u1 = 0,
            /// SLV_FORCE_ERR [25:25]
            /// in slave mode software forces data block CRC errors
            SLV_FORCE_ERR: u1 = 0,
            /// SLV_CK_PHASE [26:26]
            /// phase selection bit when DATA is output from the mode
            SLV_CK_PHASE: u1 = 0,
            /// padding [27:31]
            _padding: u5 = 0,
        }),

        /// offset 0x1c
        _offset18: [28]u8,

        /// bits 31:0 = FIFOData: Receive and transmit FIFO data
        FIFO: RegisterRW(packed struct(u32) {
            /// FIFOData [0:31]
            /// Receive and transmit FIFO data
            FIFOData: u32 = 0,
        }),
    };

    /// Flexible static memory controller
    pub const FSMC = extern struct {
        pub inline fn from(base: u32) *volatile types.FSMC {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.FSMC) u32 {
            return @intFromPtr(self);
        }

        /// SRAM/NOR-Flash chip-select control register 1
        BCR1: RegisterRW(packed struct(u32) {
            /// MBKEN [0:0]
            /// Memory bank enable bit
            MBKEN: u1 = 0,
            /// MUXEN [1:1]
            /// Address/data multiplexing enable bit
            MUXEN: u1 = 0,
            /// MTYP [2:3]
            /// Memory type
            MTYP: u2 = 0,
            /// MWID [4:5]
            /// Memory databus width
            MWID: u2 = 1,
            /// FACCEN [6:6]
            /// Flash access enable
            FACCEN: u1 = 1,
            /// unused [7:7]
            _unused7: u1 = 1,
            /// BURSTEN [8:8]
            /// Burst enable bit
            BURSTEN: u1 = 0,
            /// WAITPOL [9:9]
            /// Wait signal polarity bit
            WAITPOL: u1 = 0,
            /// WRAPMOD [10:10]
            /// Wrapped burst mode support
            WRAPMOD: u1 = 0,
            /// WAITCFG [11:11]
            /// Wait timing configuration
            WAITCFG: u1 = 0,
            /// WREN [12:12]
            /// Write enable bit
            WREN: u1 = 1,
            /// WAITEN [13:13]
            /// Wait enable bit
            WAITEN: u1 = 1,
            /// EXTMOD [14:14]
            /// Extended mode enable
            EXTMOD: u1 = 0,
            /// ASYNCWAIT [15:15]
            /// Wait signal during asynchronous transfers
            ASYNCWAIT: u1 = 0,
            /// unused [16:18]
            _unused16: u3 = 0,
            /// CBURSTRW [19:19]
            /// Write burst enable
            CBURSTRW: u1 = 0,
            /// padding [20:31]
            _padding: u12 = 0,
        }),

        /// SRAM/NOR-Flash chip-select timing register 1
        BTR1: RegisterRW(packed struct(u32) {
            /// ADDSET [0:3]
            /// Address setup phase duration
            ADDSET: u4 = 15,
            /// ADDHLD [4:7]
            /// Address-hold phase duration
            ADDHLD: u4 = 15,
            /// DATAST [8:15]
            /// Data-phase duration
            DATAST: u8 = 255,
            /// BUSTURN [16:19]
            /// Bus turnaround phase duration
            BUSTURN: u4 = 15,
            /// CLKDIV [20:23]
            /// Clock divide ratio (for FSMC_CLK signal)
            CLKDIV: u4 = 15,
            /// DATLAT [24:27]
            /// Data latency for synchronous NOR Flash memory
            DATLAT: u4 = 15,
            /// ACCMOD [28:29]
            /// Access mode
            ACCMOD: u2 = 3,
            /// padding [30:31]
            _padding: u2 = 3,
        }),

        /// offset 0x58
        _offset2: [88]u8,

        /// PC Card/NAND Flash control register 2
        PCR2: RegisterRW(packed struct(u32) {
            /// unused [0:0]
            _unused0: u1 = 0,
            /// PWAITEN [1:1]
            /// Wait feature enable bit
            PWAITEN: u1 = 0,
            /// PBKEN [2:2]
            /// PC Card/NAND Flash memory bank enable bit
            PBKEN: u1 = 0,
            /// PTYP [3:3]
            /// Memory type
            PTYP: u1 = 1,
            /// PWID [4:5]
            /// Databus width
            PWID: u2 = 1,
            /// ECCEN [6:6]
            /// ECC computation logic enable bit
            ECCEN: u1 = 0,
            /// unused [7:8]
            _unused7: u1 = 0,
            _unused8: u1 = 0,
            /// TCLR [9:12]
            /// CLE to RE delay
            TCLR: u4 = 0,
            /// TAR [13:16]
            /// ALE to RE delay
            TAR: u4 = 0,
            /// ECCPS [17:19]
            /// ECC page size
            ECCPS: u3 = 0,
            /// padding [20:31]
            _padding: u12 = 0,
        }),

        /// FIFO status and interrupt register 2
        SR2: RegisterRW(packed struct(u32) {
            /// unused [0:5]
            _unused0: u6 = 0,
            /// FEMPT [6:6]
            /// FIFO empty
            FEMPT: u1 = 1,
            /// padding [7:31]
            _padding: u25 = 0,
        }),

        /// Common memory space timing register 2
        PMEM2: RegisterRW(packed struct(u32) {
            /// MEMSETx [0:7]
            /// Common memory x setup time
            MEMSETx: u8 = 252,
            /// MEMWAITx [8:15]
            /// Common memory x wait time
            MEMWAITx: u8 = 252,
            /// MEMHOLDx [16:23]
            /// Common memory x hold time
            MEMHOLDx: u8 = 252,
            /// MEMHIZx [24:31]
            /// Common memory x databus HiZ time
            MEMHIZx: u8 = 252,
        }),

        /// Attribute memory space timing register 2
        PATT2: RegisterRW(packed struct(u32) {
            /// ATTSETx [0:7]
            /// Attribute memory x setup time
            ATTSETx: u8 = 252,
            /// ATTWAITx [8:15]
            /// Attribute memory x wait time
            ATTWAITx: u8 = 252,
            /// ATTHOLDx [16:23]
            /// Attribute memory x hold time
            ATTHOLDx: u8 = 252,
            /// ATTHIZx [24:31]
            /// Attribute memory x databus HiZ time
            ATTHIZx: u8 = 252,
        }),

        /// offset 0x4
        _offset6: [4]u8,

        /// ECC result register 2
        ECCR2: RegisterRW(packed struct(u32) {
            /// ECCx [0:31]
            /// ECC result
            ECCx: u32 = 0,
        }),

        /// offset 0x8c
        _offset7: [140]u8,

        /// SRAM/NOR-Flash write timing registers 1
        BWTR1: RegisterRW(packed struct(u32) {
            /// ADDSET [0:3]
            /// Address setup phase duration
            ADDSET: u4 = 15,
            /// ADDHLD [4:7]
            /// Address-hold phase duration
            ADDHLD: u4 = 15,
            /// DATAST [8:15]
            /// Data-phase duration
            DATAST: u8 = 255,
            /// unused [16:27]
            _unused16: u8 = 255,
            _unused24: u4 = 15,
            /// ACCMOD [28:29]
            /// Access mode
            ACCMOD: u2 = 0,
            /// padding [30:31]
            _padding: u2 = 0,
        }),
    };

    /// Digital Video Port
    pub const DVP = extern struct {
        pub inline fn from(base: u32) *volatile types.DVP {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.DVP) u32 {
            return @intFromPtr(self);
        }

        /// Digital Video control register (DVP_CR0)
        CR0: RegisterRW(packed struct(u8) {
            /// RB_DVP_ENABLE [0:0]
            /// DVP enable
            RB_DVP_ENABLE: u1 = 0,
            /// RB_DVP_V_POLAR [1:1]
            /// DVP VSYNC polarity control
            RB_DVP_V_POLAR: u1 = 0,
            /// RB_DVP_H_POLAR [2:2]
            /// DVP HSYNC polarity control
            RB_DVP_H_POLAR: u1 = 0,
            /// RB_DVP_P_POLAR [3:3]
            /// DVP PCLK polarity control
            RB_DVP_P_POLAR: u1 = 0,
            /// RB_DVP_MSK_DAT_MOD [4:5]
            /// DVP data mode
            RB_DVP_MSK_DAT_MOD: u2 = 0,
            /// RB_DVP_JPEG [6:6]
            /// DVP JPEG mode
            RB_DVP_JPEG: u1 = 0,
            /// padding [7:7]
            _padding: u1 = 0,
        }),

        /// Digital Video control register (DVP_CR1)
        CR1: RegisterRW(packed struct(u8) {
            /// RB_DVP_DMA_ENABLE [0:0]
            /// DVP dma enable
            RB_DVP_DMA_ENABLE: u1 = 0,
            /// RB_DVP_ALL_CLR [1:1]
            /// DVP all clear
            RB_DVP_ALL_CLR: u1 = 1,
            /// RB_DVP_RCV_CLR [2:2]
            /// DVP receive logic clear
            RB_DVP_RCV_CLR: u1 = 1,
            /// RB_DVP_BUF_TOG [3:3]
            /// DVP bug toggle by software
            RB_DVP_BUF_TOG: u1 = 0,
            /// RB_DVP_CM [4:4]
            /// DVP capture mode
            RB_DVP_CM: u1 = 0,
            /// RB_DVP_CROP [5:5]
            /// DVP Crop feature enable
            RB_DVP_CROP: u1 = 0,
            /// RB_DVP_FCRC [6:7]
            /// DVP frame capture rate control
            RB_DVP_FCRC: u2 = 0,
        }),

        /// Digital Video Interrupt register (DVP_IER)
        IER: RegisterRW(packed struct(u8) {
            /// RB_DVP_IE_STR_FRM [0:0]
            /// DVP frame start interrupt enable
            RB_DVP_IE_STR_FRM: u1 = 0,
            /// RB_DVP_IE_ROW_DONE [1:1]
            /// DVP row received done interrupt enable
            RB_DVP_IE_ROW_DONE: u1 = 0,
            /// RB_DVP_IE_FRM_DONE [2:2]
            /// DVP frame received done interrupt enable
            RB_DVP_IE_FRM_DONE: u1 = 0,
            /// RB_DVP_IE_FIFO_OV [3:3]
            /// DVP receive fifo overflow interrupt enable
            RB_DVP_IE_FIFO_OV: u1 = 0,
            /// RB_DVP_IE_STP_FRM [4:4]
            /// DVP frame stop interrupt enable
            RB_DVP_IE_STP_FRM: u1 = 0,
            /// padding [5:7]
            _padding: u3 = 0,
        }),

        /// offset 0x1
        _offset3: [1]u8,

        /// Image line count configuration register (DVP_ROW_NUM)
        ROW_NUM: RegisterRW(packed struct(u16) {
            /// RB_DVP_ROW_NUM [0:15]
            /// The number of rows of frame image data
            RB_DVP_ROW_NUM: u16 = 0,
        }),

        /// Image column number configuration register (DVP_COL_NUM)
        COL_NUM: RegisterRW(packed struct(u16) {
            /// RB_DVP_COL_NUM [0:15]
            /// Number of PCLK cycles for row data
            RB_DVP_COL_NUM: u16 = 0,
        }),

        /// Digital Video DMA address register (DVP_DMA_BUF0)
        DMA_BUF0: RegisterRW(packed struct(u32) {
            /// RB_DVP_DMA_BUF0 [0:31]
            /// DMA receive address 0
            RB_DVP_DMA_BUF0: u32 = 0,
        }),

        /// Digital Video DMA address register (DVP_DMA_BUF1)
        DMA_BUF1: RegisterRW(packed struct(u32) {
            /// RB_DVP_DMA_BUF1 [0:31]
            /// DMA receive address 1
            RB_DVP_DMA_BUF1: u32 = 0,
        }),

        /// Digital Video Flag register (DVP_IFR)
        IFR: RegisterRW(packed struct(u8) {
            /// RB_DVP_IF_STR_FRM [0:0]
            /// DVP frame start interrupt enable
            RB_DVP_IF_STR_FRM: u1 = 0,
            /// RB_DVP_IF_ROW_DONE [1:1]
            /// DVP row received done interrupt enable
            RB_DVP_IF_ROW_DONE: u1 = 0,
            /// RB_DVP_IF_FRM_DONE [2:2]
            /// DVP frame received done interrupt enable
            RB_DVP_IF_FRM_DONE: u1 = 0,
            /// RB_DVP_IF_FIFO_OV [3:3]
            /// DVP receive fifo overflow interrupt enable
            RB_DVP_IF_FIFO_OV: u1 = 0,
            /// RB_DVP_IF_STP_FRM [4:4]
            /// DVP frame stop interrupt enable
            RB_DVP_IF_STP_FRM: u1 = 0,
            /// padding [5:7]
            _padding: u3 = 0,
        }),

        /// Digital Video STATUS register (DVP_STATUS)
        STATUS: RegisterRW(packed struct(u8) {
            /// RB_DVP_FIFO_RDY [0:0]
            /// DVP frame start interrupt enable
            RB_DVP_FIFO_RDY: u1 = 0,
            /// RB_DVP_FIFO_FULL [1:1]
            /// DVP row received done interrupt enable
            RB_DVP_FIFO_FULL: u1 = 0,
            /// RB_DVP_FIFO_OV [2:2]
            /// DVP frame received done interrupt enable
            RB_DVP_FIFO_OV: u1 = 0,
            /// unused [3:3]
            _unused3: u1 = 0,
            /// RB_DVP_MSK_FIFO_CNT [4:6]
            /// DVP receive fifo overflow interrupt enable
            RB_DVP_MSK_FIFO_CNT: u3 = 0,
            /// padding [7:7]
            _padding: u1 = 0,
        }),

        /// offset 0x2
        _offset9: [2]u8,

        /// Digital Video line counter register (DVP_ROW_CNT)
        ROW_CNT: RegisterRW(packed struct(u16) {
            /// RB_DVP_ROW_CNT [0:15]
            /// The number of rows of frame image data
            RB_DVP_ROW_CNT: u16 = 0,
        }),

        /// offset 0x2
        _offset10: [2]u8,

        /// Digital Video horizontal displacement register (DVP_HOFFCNT)
        HOFFCNT: RegisterRW(packed struct(u16) {
            /// RB_DVP_HOFFCNT [0:15]
            /// Number of PCLK cycles for row data
            RB_DVP_HOFFCNT: u16 = 0,
        }),

        /// Digital Video line number register (DVP_VST)
        VST: RegisterRW(packed struct(u16) {
            /// RB_DVP_VST [0:15]
            /// The number of lines captured by the image
            RB_DVP_VST: u16 = 0,
        }),

        /// Digital Video Capture count register (DVP_CAPCNT)
        CAPCNT: RegisterRW(packed struct(u16) {
            /// RB_DVP_CAPCNT [0:15]
            /// Number of PCLK cycles captured by clipping window
            RB_DVP_CAPCNT: u16 = 0,
        }),

        /// Digital Video Vertical line count register (DVP_VLINE)
        VLINE: RegisterRW(packed struct(u16) {
            /// RB_DVP_VLINE [0:15]
            /// Crop the number of rows captured by window
            RB_DVP_VLINE: u16 = 0,
        }),

        /// Digital Video Data register (DVP_DR)
        DR: RegisterRW(packed struct(u32) {
            /// RB_DVP_DR [0:31]
            /// Prevent DMA overflow
            RB_DVP_DR: u32 = 0,
        }),
    };

    /// Digital to analog converter
    pub const DAC = extern struct {
        pub inline fn from(base: u32) *volatile types.DAC {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.DAC) u32 {
            return @intFromPtr(self);
        }

        /// Control register (DAC_CR)
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

        /// DAC software trigger register (DAC_SWTRIGR)
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

        /// DAC channel1 12-bit right-aligned data holding register(DAC_DHR12R1)
        R12BDHR1: RegisterRW(packed struct(u32) {
            /// DACC1DHR [0:11]
            /// DAC channel1 12-bit right-aligned data
            DACC1DHR: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }),

        /// DAC channel1 12-bit left aligned data holding register (DAC_DHR12L1)
        L12BDHR1: RegisterRW(packed struct(u32) {
            /// unused [0:3]
            _unused0: u4 = 0,
            /// DACC1DHR [4:15]
            /// DAC channel1 12-bit left-aligned data
            DACC1DHR: u12 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// DAC channel1 8-bit right aligned data holding register (DAC_DHR8R1)
        R8BDHR1: RegisterRW(packed struct(u32) {
            /// DACC1DHR [0:7]
            /// DAC channel1 8-bit right-aligned data
            DACC1DHR: u8 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }),

        /// DAC channel2 12-bit right aligned data holding register (DAC_DHR12R2)
        R12BDHR2: RegisterRW(packed struct(u32) {
            /// DACC2DHR [0:11]
            /// DAC channel2 12-bit right-aligned data
            DACC2DHR: u12 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }),

        /// DAC channel2 12-bit left aligned data holding register (DAC_DHR12L2)
        L12BDHR2: RegisterRW(packed struct(u32) {
            /// unused [0:3]
            _unused0: u4 = 0,
            /// DACC2DHR [4:15]
            /// DAC channel2 12-bit left-aligned data
            DACC2DHR: u12 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// DAC channel2 8-bit right-aligned data holding register (DAC_DHR8R2)
        R8BDHR2: RegisterRW(packed struct(u32) {
            /// DACC2DHR [0:7]
            /// DAC channel2 8-bit right-aligned data
            DACC2DHR: u8 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }),

        /// Dual DAC 12-bit right-aligned data holding register (DAC_DHR12RD), Bits 31:28 Reserved, Bits 15:12 Reserved
        RD12BDHR: RegisterRW(packed struct(u32) {
            /// DACC1DHR [0:11]
            /// DAC channel1 12-bit right-aligned data
            DACC1DHR: u12 = 0,
            /// unused [12:15]
            _unused12: u4 = 0,
            /// DACC2DHR [16:27]
            /// DAC channel2 12-bit right-aligned data
            DACC2DHR: u12 = 0,
            /// padding [28:31]
            _padding: u4 = 0,
        }),

        /// DUAL DAC 12-bit left aligned data holding register (DAC_DHR12LD), Bits 19:16 Reserved, Bits 3:0 Reserved
        LD12BDHR: RegisterRW(packed struct(u32) {
            /// unused [0:3]
            _unused0: u4 = 0,
            /// DACC1DHR [4:15]
            /// DAC channel1 12-bit left-aligned data
            DACC1DHR: u12 = 0,
            /// unused [16:19]
            _unused16: u4 = 0,
            /// DACC2DHR [20:31]
            /// DAC channel2 12-bit right-aligned data
            DACC2DHR: u12 = 0,
        }),

        /// DUAL DAC 8-bit right aligned data holding register (DAC_DHR8RD), Bits 31:16 Reserved
        RD8BDHR: RegisterRW(packed struct(u32) {
            /// DACC1DHR [0:7]
            /// DAC channel1 8-bit right-aligned data
            DACC1DHR: u8 = 0,
            /// DACC2DHR [8:15]
            /// DAC channel2 8-bit right-aligned data
            DACC2DHR: u8 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

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
            /// unused [9:15]
            _unused9: u7 = 0,
            /// R2KSTY [16:16]
            /// standby 2k ram enable
            R2KSTY: u1 = 0,
            /// R30KSTY [17:17]
            /// standby 30k ram enable
            R30KSTY: u1 = 0,
            /// R2KVBAT [18:18]
            /// VBAT 30k ram enable
            R2KVBAT: u1 = 0,
            /// R30KVBAT [19:19]
            /// VBAT 30k ram enable
            R30KVBAT: u1 = 0,
            /// RAMLV [20:20]
            /// Ram LV Enable
            RAMLV: u1 = 0,
            /// padding [21:31]
            _padding: u11 = 0,
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
            /// PLL2ON [26:26]
            /// PLL2 enable
            PLL2ON: u1 = 0,
            /// PLL2RDY [27:27]
            /// PLL2 clock ready flag
            PLL2RDY: u1 = 0,
            /// PLL3ON [28:28]
            /// PLL3 enable
            PLL3ON: u1 = 0,
            /// PLL3RDY [29:29]
            /// PLL3 clock ready flag
            PLL3RDY: u1 = 0,
            /// padding [30:31]
            _padding: u2 = 0,
        }),

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
            HPRE: u4 = 0,
            /// PPRE1 [8:10]
            /// PB Low speed prescaler (PB1)
            PPRE1: u3 = 0,
            /// PPRE2 [11:13]
            /// PB High speed prescaler (PB2)
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
            /// USBPRE [22:23]
            /// USB prescaler
            USBPRE: u2 = 0,
            /// MCO [24:27]
            /// Microcontroller clock output
            MCO: u4 = 0,
            /// unused [28:29]
            _unused28: u2 = 0,
            /// ADC_DUTY_SEL [30:30]
            /// ADC clock duty cycle selection
            ADC_DUTY_SEL: u1 = 0,
            /// ADCDUTY [31:31]
            /// ADC clock duty cycle adjustment
            ADCDUTY: u1 = 0,
        }),

        /// Clock interrupt register (RCC_INTR)
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
            /// PLL2RDYF [5:5]
            /// PLL2 Ready Interrupt flag
            PLL2RDYF: u1 = 0,
            /// PLL3RDYF [6:6]
            /// PLL3 Ready Interrupt flag
            PLL3RDYF: u1 = 0,
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
            /// PLL2RDYIE [13:13]
            /// PLL2 Ready Interrupt Enable
            PLL2RDYIE: u1 = 0,
            /// PLL3RDYIE [14:14]
            /// PLL3 Ready Interrupt Enable
            PLL3RDYIE: u1 = 0,
            /// unused [15:15]
            _unused15: u1 = 0,
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
            /// PLL2RDYC [21:21]
            /// PLL2 Ready Interrupt Clear
            PLL2RDYC: u1 = 0,
            /// PLL3RDYC [22:22]
            /// PLL3 Ready Interrupt Clear
            PLL3RDYC: u1 = 0,
            /// CSSC [23:23]
            /// Clock security system interrupt clear
            CSSC: u1 = 0,
            /// padding [24:31]
            _padding: u8 = 0,
        }),

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
            /// IOPBRST [3:3]
            /// IO port B reset
            IOPBRST: u1 = 0,
            /// IOPCRST [4:4]
            /// IO port C reset
            IOPCRST: u1 = 0,
            /// IOPDRST [5:5]
            /// IO port D reset
            IOPDRST: u1 = 0,
            /// IOPERST [6:6]
            /// IO port E reset
            IOPERST: u1 = 0,
            /// unused [7:8]
            _unused7: u1 = 0,
            _unused8: u1 = 0,
            /// ADC1RST [9:9]
            /// ADC 1 interface reset
            ADC1RST: u1 = 0,
            /// ADC2RST [10:10]
            /// ADC 2 interface reset
            ADC2RST: u1 = 0,
            /// TIM1RST [11:11]
            /// TIM1 timer reset
            TIM1RST: u1 = 0,
            /// SPI1RST [12:12]
            /// SPI 1 reset
            SPI1RST: u1 = 0,
            /// TIM8RST [13:13]
            /// TIM8 timer reset
            TIM8RST: u1 = 0,
            /// USART1RST [14:14]
            /// USART1 reset
            USART1RST: u1 = 0,
            /// unused [15:18]
            _unused15: u1 = 0,
            _unused16: u3 = 0,
            /// TIM9RST [19:19]
            /// TIM9 timer reset
            TIM9RST: u1 = 0,
            /// TIM10RST [20:20]
            /// TIM10 timer reset
            TIM10RST: u1 = 0,
            /// padding [21:31]
            _padding: u11 = 0,
        }),

        /// PB1 peripheral reset register (RCC_APB1PRSTR)
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
            /// TIM5RST [3:3]
            /// Timer 5 reset
            TIM5RST: u1 = 0,
            /// TIM6RST [4:4]
            /// Timer 6 reset
            TIM6RST: u1 = 0,
            /// TIM7RST [5:5]
            /// Timer 7 reset
            TIM7RST: u1 = 0,
            /// UART6RST [6:6]
            /// UART 6 reset
            UART6RST: u1 = 0,
            /// UART7RST [7:7]
            /// UART 7 reset
            UART7RST: u1 = 0,
            /// UART8RST [8:8]
            /// UART 8 reset
            UART8RST: u1 = 0,
            /// unused [9:10]
            _unused9: u2 = 0,
            /// WWDGRST [11:11]
            /// Window watchdog reset
            WWDGRST: u1 = 0,
            /// unused [12:13]
            _unused12: u2 = 0,
            /// SPI2RST [14:14]
            /// SPI2 reset
            SPI2RST: u1 = 0,
            /// SPI3RST [15:15]
            /// SPI3 reset
            SPI3RST: u1 = 0,
            /// unused [16:16]
            _unused16: u1 = 0,
            /// USART2RST [17:17]
            /// USART 2 reset
            USART2RST: u1 = 0,
            /// USART3RST [18:18]
            /// USART 3 reset
            USART3RST: u1 = 0,
            /// USART4RST [19:19]
            /// USART 4 reset
            USART4RST: u1 = 0,
            /// USART5RST [20:20]
            /// USART 5 reset
            USART5RST: u1 = 0,
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
            /// CAN1RST [25:25]
            /// CAN1 reset
            CAN1RST: u1 = 0,
            /// CAN2RST [26:26]
            /// CAN2 reset
            CAN2RST: u1 = 0,
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

        /// HB Peripheral Clock enable register (RCC_AHBPCENR)
        AHBPCENR: RegisterRW(packed struct(u32) {
            /// DMA1EN [0:0]
            /// DMA clock enable
            DMA1EN: u1 = 0,
            /// DMA2EN [1:1]
            /// DMA2 clock enable
            DMA2EN: u1 = 0,
            /// SRAMEN [2:2]
            /// SRAM interface clock enable
            SRAMEN: u1 = 1,
            /// unused [3:5]
            _unused3: u3 = 2,
            /// CRCEN [6:6]
            /// CRC clock enable
            CRCEN: u1 = 0,
            /// unused [7:7]
            _unused7: u1 = 0,
            /// FSMCEN [8:8]
            /// FSMC clock enable
            FSMCEN: u1 = 0,
            /// TRNG_EN [9:9]
            /// TRNG clock enable
            TRNG_EN: u1 = 0,
            /// SDIOEN [10:10]
            /// SDIO clock enable
            SDIOEN: u1 = 0,
            /// USBHS_EN [11:11]
            /// USBHS clock enable
            USBHS_EN: u1 = 0,
            /// OTG_EN [12:12]
            /// OTG clock enable
            OTG_EN: u1 = 0,
            /// DVP_EN [13:13]
            /// DVP clock enable
            DVP_EN: u1 = 0,
            /// ETHMACEN [14:14]
            /// Ethernet MAC clock enable
            ETHMACEN: u1 = 0,
            /// ETHMACTXEN [15:15]
            /// Ethernet MAC TX clock enable
            ETHMACTXEN: u1 = 0,
            /// ETHMACRXEN [16:16]
            /// Ethernet MAC RX clock enable
            ETHMACRXEN: u1 = 0,
            /// padding [17:31]
            _padding: u15 = 0,
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
            /// IOPEEN [6:6]
            /// I/O port E clock enable
            IOPEEN: u1 = 0,
            /// unused [7:8]
            _unused7: u1 = 0,
            _unused8: u1 = 0,
            /// ADC1EN [9:9]
            /// ADC1 interface clock enable
            ADC1EN: u1 = 0,
            /// ADC2EN [10:10]
            /// ADC 2 interface clock enable
            ADC2EN: u1 = 0,
            /// TIM1EN [11:11]
            /// TIM1 Timer clock enable
            TIM1EN: u1 = 0,
            /// SPI1EN [12:12]
            /// SPI 1 clock enable
            SPI1EN: u1 = 0,
            /// TIM8EN [13:13]
            /// TIM8 Timer clock enable
            TIM8EN: u1 = 0,
            /// USART1EN [14:14]
            /// USART1 clock enable
            USART1EN: u1 = 0,
            /// unused [15:18]
            _unused15: u1 = 0,
            _unused16: u3 = 0,
            /// TIM9_EN [19:19]
            /// TIM9 Timer clock enable
            TIM9_EN: u1 = 0,
            /// TIM10_EN [20:20]
            /// TIM10 Timer clock enable
            TIM10_EN: u1 = 0,
            /// padding [21:31]
            _padding: u11 = 0,
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
            /// TIM5EN [3:3]
            /// Timer 5 clock enable
            TIM5EN: u1 = 0,
            /// TIM6EN [4:4]
            /// Timer 6 clock enable
            TIM6EN: u1 = 0,
            /// TIM7EN [5:5]
            /// Timer 7 clock enable
            TIM7EN: u1 = 0,
            /// USART6_EN [6:6]
            /// USART 6 clock enable
            USART6_EN: u1 = 0,
            /// USART7_EN [7:7]
            /// USART 7 clock enable
            USART7_EN: u1 = 0,
            /// USART8_EN [8:8]
            /// USART 8 clock enable
            USART8_EN: u1 = 0,
            /// unused [9:10]
            _unused9: u2 = 0,
            /// WWDGEN [11:11]
            /// Window watchdog clock enable
            WWDGEN: u1 = 0,
            /// unused [12:13]
            _unused12: u2 = 0,
            /// SPI2EN [14:14]
            /// SPI 2 clock enable
            SPI2EN: u1 = 0,
            /// SPI3EN [15:15]
            /// SPI 3 clock enable
            SPI3EN: u1 = 0,
            /// unused [16:16]
            _unused16: u1 = 0,
            /// USART2EN [17:17]
            /// USART 2 clock enable
            USART2EN: u1 = 0,
            /// USART3EN [18:18]
            /// USART 3 clock enable
            USART3EN: u1 = 0,
            /// UART4EN [19:19]
            /// UART 4 clock enable
            UART4EN: u1 = 0,
            /// UART5EN [20:20]
            /// UART 5 clock enable
            UART5EN: u1 = 0,
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
            /// CAN1EN [25:25]
            /// CAN1 clock enable
            CAN1EN: u1 = 0,
            /// CAN2EN [26:26]
            /// CAN2 clock enable
            CAN2EN: u1 = 0,
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

        /// Backup domain control register (RCC_BDCTLR)
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
        }),

        /// HB reset register (RCC_APHBRSTR)
        AHBRSTR: RegisterRW(packed struct(u32) {
            /// unused [0:11]
            _unused0: u8 = 0,
            _unused8: u4 = 0,
            /// OTGFSRST [12:12]
            /// USBHD reset
            OTGFSRST: u1 = 0,
            /// DVPRST [13:13]
            /// DVP reset
            DVPRST: u1 = 0,
            /// ETHMACRST [14:14]
            /// Ethernet MAC reset
            ETHMACRST: u1 = 0,
            /// padding [15:31]
            _padding: u17 = 0,
        }),

        /// Clock configuration register2 (RCC_CFGR2)
        CFGR2: RegisterRW(packed struct(u32) {
            /// PREDIV1 [0:3]
            /// PREDIV1 division factor
            PREDIV1: u4 = 0,
            /// PREDIV2 [4:7]
            /// PREDIV2 division factor
            PREDIV2: u4 = 0,
            /// PLL2MUL [8:11]
            /// PLL2 Multiplication Factor
            PLL2MUL: u4 = 0,
            /// PLL3MUL [12:15]
            /// PLL3 Multiplication Factor
            PLL3MUL: u4 = 0,
            /// PREDIV1SRC [16:16]
            /// PREDIV1 entry clock source
            PREDIV1SRC: u1 = 0,
            /// I2S2SRC [17:17]
            /// I2S2 clock source
            I2S2SRC: u1 = 0,
            /// I2S3SRC [18:18]
            /// I2S3 clock source
            I2S3SRC: u1 = 0,
            /// TRNGSRC [19:19]
            /// TRNG clock source
            TRNGSRC: u1 = 0,
            /// ETH1GSRC [20:21]
            /// ETH1G clock source
            ETH1GSRC: u2 = 0,
            /// ETH1GEN [22:22]
            /// ETH1G _125M clock enable
            ETH1GEN: u1 = 0,
            /// unused [23:23]
            _unused23: u1 = 0,
            /// USBHSDIV [24:26]
            /// USB HS PREDIV division factor
            USBHSDIV: u3 = 0,
            /// USBHSPLLSRC [27:27]
            /// USB HS Multiplication Factor clock source
            USBHSPLLSRC: u1 = 0,
            /// USBHSCLK [28:29]
            /// USB HS Peference Clock source
            USBHSCLK: u2 = 0,
            /// USBHSPLL [30:30]
            /// USB HS Multiplication control
            USBHSPLL: u1 = 0,
            /// USBFSSRC [31:31]
            /// USB FS clock source
            USBFSSRC: u1 = 0,
        }),
    };

    /// Extend configuration
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
            /// ETH10M [2:2]
            /// ETH 10M Enable
            ETH10M: u1 = 0,
            /// ETHRGMII [3:3]
            /// ETH RGMII Enable
            ETHRGMII: u1 = 0,
            /// HSIPRE [4:4]
            /// Whether HSI is divided
            HSIPRE: u1 = 0,
            /// unused [5:5]
            _unused5: u1 = 0,
            /// LKUPEN [6:6]
            /// LOCKUP_Eable
            LKUPEN: u1 = 1,
            /// LOCKUP_RSTF [7:7]
            /// LOCKUP RESET
            LOCKUP_RSTF: u1 = 0,
            /// ULLDOTRIM [8:9]
            /// ULLDO_TRIM
            ULLDOTRIM: u2 = 2,
            /// LDOTRIM [10:11]
            /// LDO_TRIM
            LDOTRIM: u2 = 2,
            /// HSEKPLP [12:12]
            /// HSE_KEEP_LP
            HSEKPLP: u1 = 0,
            /// padding [13:31]
            _padding: u19 = 0,
        }),

        /// OPA Control register
        CR: RegisterRW(packed struct(u32) {
            /// EN1 [0:0]
            /// OPA Enable1
            EN1: u1 = 0,
            /// MODE1 [1:1]
            /// OPA MODE1
            MODE1: u1 = 0,
            /// NSEL1 [2:2]
            /// OPA NSEL1
            NSEL1: u1 = 0,
            /// PSEL1 [3:3]
            /// OPA PSEL1
            PSEL1: u1 = 0,
            /// EN2 [4:4]
            /// OPA Enable2
            EN2: u1 = 0,
            /// MODE2 [5:5]
            /// OPA MODE2
            MODE2: u1 = 0,
            /// NSEL2 [6:6]
            /// OPA NSEL2
            NSEL2: u1 = 0,
            /// PSEL2 [7:7]
            /// OPA PSEL2
            PSEL2: u1 = 0,
            /// EN3 [8:8]
            /// OPA Eable3
            EN3: u1 = 0,
            /// MODE3 [9:9]
            /// OPA MODE3
            MODE3: u1 = 0,
            /// NSEL3 [10:10]
            /// OPA NSEL3
            NSEL3: u1 = 0,
            /// PSEL3 [11:11]
            /// OPA PSEL3
            PSEL3: u1 = 0,
            /// EN4 [12:12]
            /// OPA Enable4
            EN4: u1 = 0,
            /// MODE4 [13:13]
            /// OPA MODE4
            MODE4: u1 = 0,
            /// NSEL4 [14:14]
            /// OPA NSEL4
            NSEL4: u1 = 0,
            /// PSEL4 [15:15]
            /// OPA PSEL4
            PSEL4: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// EXTEND register 2
        CTR2: RegisterRW(packed struct(u32) {
            /// OPA1_HSMD [0:0]
            /// OPA1 high-speed mode enable
            OPA1_HSMD: u1 = 0,
            /// OPA2_HSMD [1:1]
            /// OPA2 high-speed mode enable
            OPA2_HSMD: u1 = 0,
            /// OPA3_HSMD [2:2]
            /// OPA3 high-speed mode enable
            OPA3_HSMD: u1 = 0,
            /// OPA4_HSMD [3:3]
            /// OPA4 high-speed mode enable
            OPA4_HSMD: u1 = 0,
            /// padding [4:31]
            _padding: u28 = 0,
        }),
    };

    /// General purpose I/O
    /// Type for: GPIOA GPIOB GPIOC GPIOD GPIOE
    pub const GPIO = extern struct {
        pub const GPIOA = types.GPIO.from(0x40010800);
        pub const GPIOB = types.GPIO.from(0x40010c00);
        pub const GPIOC = types.GPIO.from(0x40011000);
        pub const GPIOD = types.GPIO.from(0x40011400);
        pub const GPIOE = types.GPIO.from(0x40011800);

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
        }),

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
            /// TIM4_RM [12:12]
            /// TIM4 remapping
            TIM4_RM: u1 = 0,
            /// CAN1_RM [13:14]
            /// CAN1 remapping
            CAN1_RM: u2 = 0,
            /// PD01_RM [15:15]
            /// Port D0/Port D1 mapping on OSCIN/OSCOUT
            PD01_RM: u1 = 0,
            /// TIM5CH4_RM [16:16]
            /// TIM5 channel4 internal remap
            TIM5CH4_RM: u1 = 0,
            /// ADC1_ETRGINJ_RM [17:17]
            /// ADC 1 External trigger injected conversion remapping
            ADC1_ETRGINJ_RM: u1 = 0,
            /// ADC1_ETRGREG_RM [18:18]
            /// ADC 1 external trigger regular conversion remapping
            ADC1_ETRGREG_RM: u1 = 0,
            /// ADC2_ETRGINJ_RM [19:19]
            /// ADC 2 External trigger injected conversion remapping
            ADC2_ETRGINJ_RM: u1 = 0,
            /// ADC2_ETRGREG_RM [20:20]
            /// ADC 2 external trigger regular conversion remapping
            ADC2_ETRGREG_RM: u1 = 0,
            /// ETH_RM [21:21]
            /// Ethernet remapping
            ETH_RM: u1 = 0,
            /// CAN2_RM [22:22]
            /// CAN2 remapping
            CAN2_RM: u1 = 0,
            /// MII_RMII_SEL [23:23]
            /// MII_RMII_SEL
            MII_RMII_SEL: u1 = 0,
            /// SW_CFG [24:26]
            /// Serial wire JTAG configuration
            SW_CFG: u3 = 0,
            /// unused [27:27]
            _unused27: u1 = 0,
            /// SPI3_RM [28:28]
            /// SPI3 remapping
            SPI3_RM: u1 = 0,
            /// TIM2ITR1_RM [29:29]
            /// TIM2 internally triggers 1 remapping
            TIM2ITR1_RM: u1 = 0,
            /// PTP_PPS_RM [30:30]
            /// Ethernet PTP_PPS remapping
            PTP_PPS_RM: u1 = 0,
            /// padding [31:31]
            _padding: u1 = 0,
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

        /// offset 0x4
        _offset6: [4]u8,

        /// AF remap and debug I/O configuration register (AFIO_PCFR2)
        PCFR2: RegisterRW(packed struct(u32) {
            /// unused [0:1]
            _unused0: u2 = 0,
            /// TIM8_RM [2:2]
            /// TIM8 remapping
            TIM8_RM: u1 = 0,
            /// TIM9_RM [3:4]
            /// TIM9 remapping
            TIM9_RM: u2 = 0,
            /// TIM10_RM [5:6]
            /// TIM10 remapping
            TIM10_RM: u2 = 0,
            /// unused [7:9]
            _unused7: u1 = 0,
            _unused8: u2 = 0,
            /// FSMC_NADV [10:10]
            /// FSMC_NADV
            FSMC_NADV: u1 = 0,
            /// unused [11:15]
            _unused11: u5 = 0,
            /// UART4_RM [16:17]
            /// UART4 remapping
            UART4_RM: u2 = 0,
            /// UART5_RM [18:19]
            /// UART5 remapping
            UART5_RM: u2 = 0,
            /// UART6_RM [20:21]
            /// UART6 remapping
            UART6_RM: u2 = 0,
            /// UART7_RM [22:23]
            /// UART7 remapping
            UART7_RM: u2 = 0,
            /// UART8_RM [24:25]
            /// UART8 remapping
            UART8_RM: u2 = 0,
            /// UART1_RM1 [26:26]
            /// UART1 remapping
            UART1_RM1: u1 = 0,
            /// padding [27:31]
            _padding: u5 = 0,
        }),
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
            /// MR19 [19:19]
            /// Interrupt Mask on line 19
            MR19: u1 = 0,
            /// MR20 [20:20]
            /// Interrupt Mask on line 20
            MR20: u1 = 0,
            /// MR21 [21:21]
            /// Interrupt Mask on line 21
            MR21: u1 = 0,
            /// padding [22:31]
            _padding: u10 = 0,
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
            /// MR19 [19:19]
            /// Event Mask on line 19
            MR19: u1 = 0,
            /// MR20 [20:20]
            /// Event Mask on line 20
            MR20: u1 = 0,
            /// MR21 [21:21]
            /// Event Mask on line 21
            MR21: u1 = 0,
            /// padding [22:31]
            _padding: u10 = 0,
        }),

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
            /// TR19 [19:19]
            /// Rising trigger event configuration of line 19
            TR19: u1 = 0,
            /// TR20 [20:20]
            /// Rising trigger event configuration of line 20
            TR20: u1 = 0,
            /// TR21 [21:21]
            /// Rising trigger event configuration of line 21
            TR21: u1 = 0,
            /// padding [22:31]
            _padding: u10 = 0,
        }),

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
            /// TR19 [19:19]
            /// Falling trigger event configuration of line 19
            TR19: u1 = 0,
            /// TR20 [20:20]
            /// Falling trigger event configuration of line 20
            TR20: u1 = 0,
            /// TR21 [21:21]
            /// Falling trigger event configuration of line 21
            TR21: u1 = 0,
            /// padding [22:31]
            _padding: u10 = 0,
        }),

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
            /// SWIER19 [19:19]
            /// Software Interrupt on line 19
            SWIER19: u1 = 0,
            /// SWIER20 [20:20]
            /// Software Interrupt on line 20
            SWIER20: u1 = 0,
            /// SWIER21 [21:21]
            /// Software Interrupt on line 21
            SWIER21: u1 = 0,
            /// padding [22:31]
            _padding: u10 = 0,
        }),

        /// Pending register (EXTI_INTFR)
        INTFR: RegisterRW(packed struct(u32) {
            /// PR0 [0:0]
            /// Pending bit 0
            PR0: u1 = 0,
            /// PR1 [1:1]
            /// Pending bit 1
            PR1: u1 = 0,
            /// PR2 [2:2]
            /// Pending bit 2
            PR2: u1 = 0,
            /// PR3 [3:3]
            /// Pending bit 3
            PR3: u1 = 0,
            /// PR4 [4:4]
            /// Pending bit 4
            PR4: u1 = 0,
            /// PR5 [5:5]
            /// Pending bit 5
            PR5: u1 = 0,
            /// PR6 [6:6]
            /// Pending bit 6
            PR6: u1 = 0,
            /// PR7 [7:7]
            /// Pending bit 7
            PR7: u1 = 0,
            /// PR8 [8:8]
            /// Pending bit 8
            PR8: u1 = 0,
            /// PR9 [9:9]
            /// Pending bit 9
            PR9: u1 = 0,
            /// PR10 [10:10]
            /// Pending bit 10
            PR10: u1 = 0,
            /// PR11 [11:11]
            /// Pending bit 11
            PR11: u1 = 0,
            /// PR12 [12:12]
            /// Pending bit 12
            PR12: u1 = 0,
            /// PR13 [13:13]
            /// Pending bit 13
            PR13: u1 = 0,
            /// PR14 [14:14]
            /// Pending bit 14
            PR14: u1 = 0,
            /// PR15 [15:15]
            /// Pending bit 15
            PR15: u1 = 0,
            /// PR16 [16:16]
            /// Pending bit 16
            PR16: u1 = 0,
            /// PR17 [17:17]
            /// Pending bit 17
            PR17: u1 = 0,
            /// PR18 [18:18]
            /// Pending bit 18
            PR18: u1 = 0,
            /// PR19 [19:19]
            /// Pending bit 19
            PR19: u1 = 0,
            /// PR20 [20:20]
            /// Pending bit 20
            PR20: u1 = 0,
            /// PR21 [21:21]
            /// Pending bit 21
            PR21: u1 = 0,
            /// padding [22:31]
            _padding: u10 = 0,
        }),
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

    /// DMA2 controller
    pub const DMA2 = extern struct {
        pub inline fn from(base: u32) *volatile types.DMA2 {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.DMA2) u32 {
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

        /// DMA channel configuration register (DMA_CFGR) used in ch32v30x_D8/D8C
        CFGR8: RegisterRW(packed struct(u32) {
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

        /// DMA channel 8 number of data register used in ch32v30x_D8/D8C
        CNTR8: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// DMA channel 8 peripheral address register used in ch32v30x_D8/D8C
        PADDR8: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }),

        /// DMA channel 8 memory address register used in ch32v30x_D8/D8C
        MADDR8: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }),

        /// DMA channel configuration register (DMA_CFGR) used in ch32v30x_D8/D8C
        CFGR9: RegisterRW(packed struct(u32) {
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

        /// DMA channel 9 number of data register used in ch32v30x_D8/D8C
        CNTR9: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// DMA channel 7 peripheral address register used in ch32v30x_D8/D8C
        PADDR9: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }),

        /// DMA channel 9 memory address register used in ch32v30x_D8/D8C
        MADDR9: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }),

        /// DMA channel configuration register (DMA_CFGR) used in ch32v30x_D8/D8C
        CFGR10: RegisterRW(packed struct(u32) {
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

        /// DMA channel 10 number of data register used in ch32v30x_D8/D8C
        CNTR10: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// DMA channel 10 peripheral address register used in ch32v30x_D8/D8C
        PADDR10: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }),

        /// DMA channel 10 memory address register used in ch32v30x_D8/D8C
        MADDR10: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }),

        /// DMA channel configuration register (DMA_CFGR) used in ch32v30x_D8/D8C
        CFGR11: RegisterRW(packed struct(u32) {
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

        /// DMA channel 11 number of data register used in ch32v30x_D8/D8C
        CNTR11: RegisterRW(packed struct(u32) {
            /// NDT [0:15]
            /// Number of data to transfer
            NDT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// DMA channel 11 peripheral address register used in ch32v30x_D8/D8C
        PADDR11: RegisterRW(packed struct(u32) {
            /// PA [0:31]
            /// Peripheral address
            PA: u32 = 0,
        }),

        /// DMA channel 11 memory address register used in ch32v30x_D8/D8C
        MADDR11: RegisterRW(packed struct(u32) {
            /// MA [0:31]
            /// Memory address
            MA: u32 = 0,
        }),

        /// DMA2 EXTEN interrupt status register (DMA_INTFR)used in ch32v30x_D8/D8C
        EXTEN_INTFR: RegisterRW(packed struct(u32) {
            /// GIF8 [0:0]
            /// Channel 8 Global interrupt flag
            GIF8: u1 = 0,
            /// TCIF8 [1:1]
            /// Channel 8 Transfer Complete flag
            TCIF8: u1 = 0,
            /// HTIF8 [2:2]
            /// Channel 8 Half Transfer Complete flag
            HTIF8: u1 = 0,
            /// TEIF8 [3:3]
            /// Channel 8 Transfer Error flag
            TEIF8: u1 = 0,
            /// GIF9 [4:4]
            /// Channel 9 Global interrupt flag
            GIF9: u1 = 0,
            /// TCIF9 [5:5]
            /// Channel 9 Transfer Complete flag
            TCIF9: u1 = 0,
            /// HTIF9 [6:6]
            /// Channel 9 Half Transfer Complete flag
            HTIF9: u1 = 0,
            /// TEIF9 [7:7]
            /// Channel 9 Transfer Error flag
            TEIF9: u1 = 0,
            /// GIF10 [8:8]
            /// Channel 10 Global interrupt flag
            GIF10: u1 = 0,
            /// TCIF10 [9:9]
            /// Channel 10 Transfer Complete flag
            TCIF10: u1 = 0,
            /// HTIF10 [10:10]
            /// Channel 10 Half Transfer Complete flag
            HTIF10: u1 = 0,
            /// TEIF10 [11:11]
            /// Channel 10 Transfer Error flag
            TEIF10: u1 = 0,
            /// GIF11 [12:12]
            /// Channel 11 Global interrupt flag
            GIF11: u1 = 0,
            /// TCIF11 [13:13]
            /// Channel 11 Transfer Complete flag
            TCIF11: u1 = 0,
            /// HTIF11 [14:14]
            /// Channel 11 Half Transfer Complete flag
            HTIF11: u1 = 0,
            /// TEIF11 [15:15]
            /// Channel 11 Transfer Error flag
            TEIF11: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// DMA2 EXTEN interrupt flag clear register (DMA_INTFCR)used in ch32v30x_D8/D8C
        EXTEN_INTFCR: RegisterRW(packed struct(u32) {
            /// CGIF8 [0:0]
            /// Channel 8 Global interrupt clear
            CGIF8: u1 = 0,
            /// CTCIF8 [1:1]
            /// Channel 8 Global interrupt clear
            CTCIF8: u1 = 0,
            /// CHTIF8 [2:2]
            /// Channel 8 Global interrupt clear
            CHTIF8: u1 = 0,
            /// CTEIF8 [3:3]
            /// Channel 8 Global interrupt clear
            CTEIF8: u1 = 0,
            /// CGIF9 [4:4]
            /// Channel 9 Global interrupt clear
            CGIF9: u1 = 0,
            /// CTCIF9 [5:5]
            /// Channel 9 Global interrupt clear
            CTCIF9: u1 = 0,
            /// CHTIF9 [6:6]
            /// Channel 9 Global interrupt clear
            CHTIF9: u1 = 0,
            /// CTEIF9 [7:7]
            /// Channel 9 Global interrupt clear
            CTEIF9: u1 = 0,
            /// CGIF10 [8:8]
            /// Channel 10 Global interrupt clear
            CGIF10: u1 = 0,
            /// CTCIF10 [9:9]
            /// Channel 10 Global interrupt clear
            CTCIF10: u1 = 0,
            /// CHTIF10 [10:10]
            /// Channel 10 Global interrupt clear
            CHTIF10: u1 = 0,
            /// CTEIF10 [11:11]
            /// Channel 10 Global interrupt clear
            CTEIF10: u1 = 0,
            /// CGIF11 [12:12]
            /// Channel 11 Global interrupt clear
            CGIF11: u1 = 0,
            /// CTCIF11 [13:13]
            /// Channel 11 Global interrupt clear
            CTCIF11: u1 = 0,
            /// CHTIF11 [14:14]
            /// Channel 11 Global interrupt clear
            CHTIF11: u1 = 0,
            /// CTEIF11 [15:15]
            /// Channel 11 Global interrupt clear
            CTEIF11: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),
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
        }),

        /// RTC Control Register Low
        CTLRL: RegisterRW(packed struct(u32) {
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
            /// padding [6:31]
            _padding: u26 = 0,
        }),

        /// RTC Prescaler Load Register High
        PSCRH: RegisterRW(packed struct(u32) {
            /// PRL [0:3]
            /// RTC Prescaler Load Register High
            PRL: u4 = 0,
            /// padding [4:31]
            _padding: u28 = 0,
        }),

        /// RTC Prescaler Load Register Low
        PSCRL: RegisterRW(packed struct(u32) {
            /// PRL [0:15]
            /// RTC Prescaler Divider Register Low
            PRL: u16 = 32768,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// RTC Prescaler Divider Register High
        DIVH: RegisterRW(packed struct(u32) {
            /// DIV [0:3]
            /// RTC prescaler divider register high
            DIV: u4 = 0,
            /// padding [4:31]
            _padding: u28 = 0,
        }),

        /// RTC Prescaler Divider Register Low
        DIVL: RegisterRW(packed struct(u32) {
            /// DIV [0:15]
            /// RTC prescaler divider register Low
            DIV: u16 = 32768,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// RTC Counter Register High
        CNTH: RegisterRW(packed struct(u32) {
            /// CNT [0:15]
            /// RTC counter register high
            CNT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// RTC Counter Register Low
        CNTL: RegisterRW(packed struct(u32) {
            /// CNT [0:15]
            /// RTC counter register Low
            CNT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// RTC Alarm Register High
        ALRMH: RegisterRW(packed struct(u32) {
            /// ALR [0:15]
            /// RTC alarm register high
            ALR: u16 = 65535,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// RTC Alarm Register Low
        ALRML: RegisterRW(packed struct(u32) {
            /// ALR [0:15]
            /// RTC alarm register low
            ALR: u16 = 65535,
            /// padding [16:31]
            _padding: u16 = 0,
        }),
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
        DATAR1: RegisterRW(packed struct(u32) {
            /// D1 [0:15]
            /// Backup data
            D1: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR2: RegisterRW(packed struct(u32) {
            /// D2 [0:15]
            /// Backup data
            D2: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR3: RegisterRW(packed struct(u32) {
            /// D3 [0:15]
            /// Backup data
            D3: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR4: RegisterRW(packed struct(u32) {
            /// D4 [0:15]
            /// Backup data
            D4: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR5: RegisterRW(packed struct(u32) {
            /// D5 [0:15]
            /// Backup data
            D5: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR6: RegisterRW(packed struct(u32) {
            /// D6 [0:15]
            /// Backup data
            D6: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR7: RegisterRW(packed struct(u32) {
            /// D7 [0:15]
            /// Backup data
            D7: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR8: RegisterRW(packed struct(u32) {
            /// D8 [0:15]
            /// Backup data
            D8: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR9: RegisterRW(packed struct(u32) {
            /// D9 [0:15]
            /// Backup data
            D9: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR10: RegisterRW(packed struct(u32) {
            /// D10 [0:15]
            /// Backup data
            D10: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// RTC clock calibration register (BKP_OCTLR)
        OCTLR: RegisterRW(packed struct(u32) {
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
            /// padding [10:31]
            _padding: u22 = 0,
        }),

        /// Backup control register (BKP_TPCTLR)
        TPCTLR: RegisterRW(packed struct(u32) {
            /// TPE [0:0]
            /// Tamper pin enable
            TPE: u1 = 0,
            /// TPAL [1:1]
            /// Tamper pin active level
            TPAL: u1 = 0,
            /// padding [2:31]
            _padding: u30 = 0,
        }),

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

        /// offset 0x8
        _offset13: [8]u8,

        /// Backup data register (BKP_DR)
        DATAR11: RegisterRW(packed struct(u32) {
            /// DR11 [0:15]
            /// Backup data
            DR11: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR12: RegisterRW(packed struct(u32) {
            /// DR12 [0:15]
            /// Backup data
            DR12: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR13: RegisterRW(packed struct(u32) {
            /// DR13 [0:15]
            /// Backup data
            DR13: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR14: RegisterRW(packed struct(u32) {
            /// D14 [0:15]
            /// Backup data
            D14: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR15: RegisterRW(packed struct(u32) {
            /// D15 [0:15]
            /// Backup data
            D15: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR16: RegisterRW(packed struct(u32) {
            /// D16 [0:15]
            /// Backup data
            D16: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR17: RegisterRW(packed struct(u32) {
            /// D17 [0:15]
            /// Backup data
            D17: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR18: RegisterRW(packed struct(u32) {
            /// D18 [0:15]
            /// Backup data
            D18: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR19: RegisterRW(packed struct(u32) {
            /// D19 [0:15]
            /// Backup data
            D19: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR20: RegisterRW(packed struct(u32) {
            /// D20 [0:15]
            /// Backup data
            D20: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR21: RegisterRW(packed struct(u32) {
            /// D21 [0:15]
            /// Backup data
            D21: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR22: RegisterRW(packed struct(u32) {
            /// D22 [0:15]
            /// Backup data
            D22: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR23: RegisterRW(packed struct(u32) {
            /// D23 [0:15]
            /// Backup data
            D23: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR24: RegisterRW(packed struct(u32) {
            /// D24 [0:15]
            /// Backup data
            D24: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR25: RegisterRW(packed struct(u32) {
            /// D25 [0:15]
            /// Backup data
            D25: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR26: RegisterRW(packed struct(u32) {
            /// D26 [0:15]
            /// Backup data
            D26: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR27: RegisterRW(packed struct(u32) {
            /// D27 [0:15]
            /// Backup data
            D27: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR28: RegisterRW(packed struct(u32) {
            /// D28 [0:15]
            /// Backup data
            D28: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR29: RegisterRW(packed struct(u32) {
            /// D29 [0:15]
            /// Backup data
            D29: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR30: RegisterRW(packed struct(u32) {
            /// D30 [0:15]
            /// Backup data
            D30: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR31: RegisterRW(packed struct(u32) {
            /// D31 [0:15]
            /// Backup data
            D31: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR32: RegisterRW(packed struct(u32) {
            /// D32 [0:15]
            /// Backup data
            D32: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR33: RegisterRW(packed struct(u32) {
            /// D33 [0:15]
            /// Backup data
            D33: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR34: RegisterRW(packed struct(u32) {
            /// D34 [0:15]
            /// Backup data
            D34: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR35: RegisterRW(packed struct(u32) {
            /// D35 [0:15]
            /// Backup data
            D35: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR36: RegisterRW(packed struct(u32) {
            /// D36 [0:15]
            /// Backup data
            D36: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR37: RegisterRW(packed struct(u32) {
            /// D37 [0:15]
            /// Backup data
            D37: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR38: RegisterRW(packed struct(u32) {
            /// D38 [0:15]
            /// Backup data
            D38: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR39: RegisterRW(packed struct(u32) {
            /// D39 [0:15]
            /// Backup data
            D39: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR40: RegisterRW(packed struct(u32) {
            /// D40 [0:15]
            /// Backup data
            D40: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR41: RegisterRW(packed struct(u32) {
            /// D41 [0:15]
            /// Backup data
            D41: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Backup data register (BKP_DR)
        DATAR42: RegisterRW(packed struct(u32) {
            /// D42 [0:15]
            /// Backup data
            D42: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),
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
        }),

        /// Prescaler register (IWDG_PSCR)
        PSCR: RegisterRW(packed struct(u32) {
            /// PR [0:2]
            /// Prescaler divider
            PR: u3 = 0,
            /// padding [3:31]
            _padding: u29 = 0,
        }),

        /// Reload register (IWDG_RLDR)
        RLDR: RegisterRW(packed struct(u32) {
            /// RL [0:11]
            /// Watchdog counter reload value
            RL: u12 = 4095,
            /// padding [12:31]
            _padding: u20 = 0,
        }),

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
        }),
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
        }),

        /// Configuration register (WWDG_CFGR)
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
        }),

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
    /// Type for: TIM1 TIM8 TIM9 TIM10
    pub const AdvancedTimer = extern struct {
        pub const TIM1 = types.AdvancedTimer.from(0x40012c00);
        pub const TIM8 = types.AdvancedTimer.from(0x40013400);
        pub const TIM9 = types.AdvancedTimer.from(0x40014c00);
        pub const TIM10 = types.AdvancedTimer.from(0x40015000);

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
            /// padding [10:31]
            _padding: u22 = 0,
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        }),

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
        PSC: RegisterRW(packed struct(u32) {
            /// PSC [0:15]
            /// Prescaler value
            PSC: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// auto-reload register
        ATRLR: RegisterRW(packed struct(u32) {
            /// ATRLR [0:15]
            /// Auto-reload value
            ATRLR: u16 = 65535,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// repetition counter register
        RPTCR: RegisterRW(packed struct(u32) {
            /// RPTCR [0:7]
            /// Repetition counter value
            RPTCR: u8 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }),

        /// capture/compare register 1
        CH1CVR: RegisterRW(packed struct(u32) {
            /// CCR1 [0:15]
            /// Capture/Compare 1 value
            CCR1: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// capture/compare register 2
        CH2CVR: RegisterRW(packed struct(u32) {
            /// CCR2 [0:15]
            /// Capture/Compare 2 value
            CCR2: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// capture/compare register 3
        CH3CVR: RegisterRW(packed struct(u32) {
            /// CCR3 [0:15]
            /// Capture/Compare value
            CCR3: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// capture/compare register 4
        CH4CVR: RegisterRW(packed struct(u32) {
            /// CCR4 [0:15]
            /// Capture/Compare value
            CCR4: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

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
        }),

        /// DMA address for full transfer
        DMAADR: RegisterRW(packed struct(u32) {
            /// DMAADR [0:15]
            /// DMA register for burst accesses
            DMAADR: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Double-side egde capture register
        AUX: RegisterRW(packed struct(u16) {
            /// CAP_ED_CH2 [0:0]
            /// Double-side egde capture is enable for channel2
            CAP_ED_CH2: u1 = 0,
            /// CAP_ED_CH3 [1:1]
            /// Double-side egde capture is enable for channel3
            CAP_ED_CH3: u1 = 0,
            /// CAP_ED_CH4 [2:2]
            /// Double-side egde capture is enable for channel4
            CAP_ED_CH4: u1 = 0,
            /// padding [3:15]
            _padding: u13 = 0,
        }),
    };

    /// General purpose timer
    /// Type for: TIM2 TIM3 TIM4 TIM5
    pub const GeneralPurposeTimer = extern struct {
        pub const TIM2 = types.GeneralPurposeTimer.from(0x40000000);
        pub const TIM3 = types.GeneralPurposeTimer.from(0x40000400);
        pub const TIM4 = types.GeneralPurposeTimer.from(0x40000800);
        pub const TIM5 = types.GeneralPurposeTimer.from(0x40000c00);

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
            /// padding [10:31]
            _padding: u22 = 0,
        }),

        /// control register 2
        CTLR2: RegisterRW(packed struct(u32) {
            /// CCPC [0:0]
            /// Compare selection
            CCPC: u1 = 0,
            /// unused [1:1]
            _unused1: u1 = 0,
            /// CCUS [2:2]
            /// Update selection
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
            /// padding [8:31]
            _padding: u24 = 0,
        }),

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
        }),

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
            /// COMDE [13:13]
            /// COM DMA request enable
            COMDE: u1 = 0,
            /// TDE [14:14]
            /// Trigger DMA request enable
            TDE: u1 = 0,
            /// padding [15:31]
            _padding: u17 = 0,
        }),

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
        }),

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
            /// Capture/compare generation
            COMG: u1 = 0,
            /// TG [6:6]
            /// Trigger generation
            TG: u1 = 0,
            /// BG [7:7]
            /// Brake generation
            BG: u1 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }),

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
            /// padding [16:31]
            _padding: u16 = 0,
        }),

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
        }),

        /// capture/compare enable register
        CCER: RegisterRW(packed struct(u32) {
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
        PSC: RegisterRW(packed struct(u32) {
            /// PSC [0:15]
            /// Prescaler value
            PSC: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// auto-reload register
        ATRLR: RegisterRW(packed struct(u32) {
            /// ARR [0:15]
            /// Auto-reload value
            ARR: u16 = 65535,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// offset 0x4
        _offset14: [4]u8,

        /// capture/compare register 1
        CH1CVR: RegisterRW(packed struct(u32) {
            /// CCR1 [0:15]
            /// Capture/Compare 1 value
            CCR1: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// capture/compare register 2
        CH2CVR: RegisterRW(packed struct(u32) {
            /// CCR2 [0:15]
            /// Capture/Compare 2 value
            CCR2: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// capture/compare register 3
        CH3CVR: RegisterRW(packed struct(u32) {
            /// CCR3 [0:15]
            /// Capture/Compare value
            CCR3: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// capture/compare register 4
        CH4CVR: RegisterRW(packed struct(u32) {
            /// CCR4 [0:15]
            /// Capture/Compare value
            CCR4: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

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
        }),

        /// DMA address for full transfer
        DMAADR: RegisterRW(packed struct(u32) {
            /// DMAADR [0:15]
            /// DMA register for burst accesses
            DMAADR: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// Double-side egde capture register
        AUX: RegisterRW(packed struct(u16) {
            /// CAP_ED_CH2 [0:0]
            /// Double-side egde capture is enable for channel2
            CAP_ED_CH2: u1 = 0,
            /// CAP_ED_CH3 [1:1]
            /// Double-side egde capture is enable for channel3
            CAP_ED_CH3: u1 = 0,
            /// CAP_ED_CH4 [2:2]
            /// Double-side egde capture is enable for channel4
            CAP_ED_CH4: u1 = 0,
            /// padding [3:15]
            _padding: u13 = 0,
        }),
    };

    /// Basic timer
    /// Type for: TIM6 TIM7
    pub const BasicTimer = extern struct {
        pub const TIM6 = types.BasicTimer.from(0x40001000);
        pub const TIM7 = types.BasicTimer.from(0x40001400);

        pub inline fn from(base: u32) *volatile types.BasicTimer {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.BasicTimer) u32 {
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
            /// unused [4:6]
            _unused4: u3 = 0,
            /// ARPE [7:7]
            /// Auto-reload preload enable
            ARPE: u1 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }),

        /// control register 2
        CTLR2: RegisterRW(packed struct(u32) {
            /// unused [0:3]
            _unused0: u4 = 0,
            /// MMS [4:6]
            /// Master mode selection
            MMS: u3 = 0,
            /// padding [7:31]
            _padding: u25 = 0,
        }),

        /// offset 0x4
        _offset2: [4]u8,

        /// DMA/Interrupt enable register
        DMAINTENR: RegisterRW(packed struct(u32) {
            /// UIE [0:0]
            /// Update interrupt enable
            UIE: u1 = 0,
            /// unused [1:7]
            _unused1: u7 = 0,
            /// UDE [8:8]
            /// Update DMA request enable
            UDE: u1 = 0,
            /// padding [9:31]
            _padding: u23 = 0,
        }),

        /// status register
        INTFR: RegisterRW(packed struct(u32) {
            /// UIF [0:0]
            /// Update interrupt flag
            UIF: u1 = 0,
            /// padding [1:31]
            _padding: u31 = 0,
        }),

        /// event generation register
        SWEVGR: RegisterRW(packed struct(u32) {
            /// UG [0:0]
            /// Update generation
            UG: u1 = 0,
            /// padding [1:31]
            _padding: u31 = 0,
        }),

        /// offset 0xc
        _offset5: [12]u8,

        /// counter
        CNT: RegisterRW(packed struct(u32) {
            /// CNT [0:15]
            /// counter value
            CNT: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// prescaler
        PSC: RegisterRW(packed struct(u32) {
            /// PSC [0:15]
            /// Prescaler value
            PSC: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// auto-reload register
        ATRLR: RegisterRW(packed struct(u32) {
            /// ARR [0:15]
            /// Auto-reload value
            ARR: u16 = 65535,
            /// padding [16:31]
            _padding: u16 = 0,
        }),
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
        CTLR1: RegisterRW(packed struct(u32) {
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
            /// padding [16:31]
            _padding: u16 = 0,
        }),

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
        }),

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
            /// unused [10:13]
            _unused10: u4 = 0,
            /// MUST1 [14:14]
            /// Must be 1
            MUST1: u1 = 0,
            /// ADDMODE [15:15]
            /// Addressing mode (slave mode)
            ADDMODE: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

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
        }),

        /// Data register
        DATAR: RegisterRW(packed struct(u32) {
            /// DATAR [0:7]
            /// 8-bit data register
            DATAR: u8 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }),

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
            /// unused [13:13]
            _unused13: u1 = 0,
            /// TIMEOUT [14:14]
            /// Timeout or Tlow error
            TIMEOUT: u1 = 0,
            /// SMBALERT [15:15]
            /// SMBus alert
            SMBALERT: u1 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

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
            /// padding [16:31]
            _padding: u16 = 0,
        }),

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
        }),

        /// Raise time register
        RTR: RegisterRW(packed struct(u32) {
            /// TRISE [0:5]
            /// Maximum rise time in Fast/Standard mode (Master mode)
            TRISE: u6 = 2,
            /// padding [6:31]
            _padding: u26 = 0,
        }),
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
        }),

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
        }),

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
        }),

        /// data register
        DATAR: RegisterRW(packed struct(u32) {
            /// DR [0:15]
            /// Data register
            DR: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// CRCR polynomial register
        CRCR: RegisterRW(packed struct(u32) {
            /// CRCPOLY [0:15]
            /// CRC polynomial register
            CRCPOLY: u16 = 7,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// RX CRC register
        RCRCR: RegisterRW(packed struct(u32) {
            /// RXCRC [0:15]
            /// Rx CRC register
            RXCRC: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// TX CRC register
        TCRCR: RegisterRW(packed struct(u32) {
            /// TXCRC [0:15]
            /// Tx CRC register
            TXCRC: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// SPI_I2S configure register
        SPI_I2S_CFGR: RegisterRW(packed struct(u32) {
            /// CHLEN [0:0]
            /// Channel length (number of bits per audio channel)
            CHLEN: u1 = 0,
            /// DATLEN [1:2]
            /// DATLEN[1:0] bits (Data length to be transferred)
            DATLEN: u2 = 0,
            /// CKPOL [3:3]
            /// steady state clock polarity
            CKPOL: u1 = 0,
            /// I2SSTD [4:5]
            /// I2SSTD[1:0] bits (I2S standard selection)
            I2SSTD: u2 = 0,
            /// unused [6:6]
            _unused6: u1 = 0,
            /// PCMSYNC [7:7]
            /// PCM frame synchronization
            PCMSYNC: u1 = 0,
            /// I2SCFG [8:9]
            /// I2SCFG[1:0] bits (I2S configuration mode)
            I2SCFG: u2 = 0,
            /// I2SE [10:10]
            /// I2S Enable
            I2SE: u1 = 0,
            /// I2SMOD [11:11]
            /// I2S mode selection
            I2SMOD: u1 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }),

        /// offset 0x4
        _offset8: [4]u8,

        /// high speed control register
        HSCR: RegisterRW(packed struct(u32) {
            /// HSRXEN [0:0]
            /// High speed mode read enable
            HSRXEN: u1 = 0,
            /// unused [1:1]
            _unused1: u1 = 0,
            /// HSRXEN2 [2:2]
            /// High speed mode 2 read enable
            HSRXEN2: u1 = 0,
            /// padding [3:31]
            _padding: u29 = 0,
        }),
    };

    /// Serial peripheral interface
    /// Type for: SPI2 SPI3
    pub const SPI_2 = extern struct {
        pub const SPI2 = types.SPI_2.from(0x40003800);
        pub const SPI3 = types.SPI_2.from(0x40003c00);

        pub inline fn from(base: u32) *volatile types.SPI_2 {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.SPI_2) u32 {
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
        }),

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
        }),

        /// status register
        STATR: RegisterRW(packed struct(u32) {
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
            /// padding [8:31]
            _padding: u24 = 0,
        }),

        /// data register
        DATAR: RegisterRW(packed struct(u32) {
            /// DR [0:15]
            /// Data register
            DR: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// CRCR polynomial register
        CRCR: RegisterRW(packed struct(u32) {
            /// CRCPOLY [0:15]
            /// CRC polynomial register
            CRCPOLY: u16 = 7,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// RX CRC register
        RCRCR: RegisterRW(packed struct(u32) {
            /// RXCRC [0:15]
            /// Rx CRC register
            RXCRC: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// TX CRC register
        TCRCR: RegisterRW(packed struct(u32) {
            /// TXCRC [0:15]
            /// Tx CRC register
            TXCRC: u16 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// I2S configuration register
        I2SCFGR: RegisterRW(packed struct(u32) {
            /// CHLEN [0:0]
            /// Channel length (number of bits per audio channel)
            CHLEN: u1 = 0,
            /// DATLEN [1:2]
            /// Data length to be transferred
            DATLEN: u2 = 0,
            /// CKPOL [3:3]
            /// Steady state clock polarity
            CKPOL: u1 = 0,
            /// I2SSTD [4:5]
            /// I2S standard selection
            I2SSTD: u2 = 0,
            /// unused [6:6]
            _unused6: u1 = 0,
            /// PCMSYNC [7:7]
            /// PCM frame synchronization
            PCMSYNC: u1 = 0,
            /// I2SCFG [8:9]
            /// I2S configuration mode
            I2SCFG: u2 = 0,
            /// I2SE [10:10]
            /// I2S Enable
            I2SE: u1 = 0,
            /// I2SMOD [11:11]
            /// I2S mode selection
            I2SMOD: u1 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
        }),

        /// I2S prescaler register
        I2SPR: RegisterRW(packed struct(u32) {
            /// I2SDIV [0:7]
            /// I2S Linear prescaler
            I2SDIV: u8 = 10,
            /// ODD [8:8]
            /// Odd factor for the prescaler
            ODD: u1 = 0,
            /// MCKOE [9:9]
            /// Master clock output enable
            MCKOE: u1 = 0,
            /// padding [10:31]
            _padding: u22 = 0,
        }),

        /// high speed control register
        HSCR: RegisterRW(packed struct(u32) {
            /// HSRXEN [0:0]
            /// High speed mode read enable
            HSRXEN: u1 = 0,
            /// unused [1:1]
            _unused1: u1 = 0,
            /// HSRXEN2 [2:2]
            /// High speed mode 2 read enable
            HSRXEN2: u1 = 0,
            /// padding [3:31]
            _padding: u29 = 0,
        }),
    };

    /// Universal synchronous asynchronous receiver transmitter
    /// Type for: USART1 USART2 USART3 UART4 UART5 UART6 UART7 UART8
    pub const USART = extern struct {
        pub const USART1 = types.USART.from(0x40013800);
        pub const USART2 = types.USART.from(0x40004400);
        pub const USART3 = types.USART.from(0x40004800);
        pub const UART4 = types.USART.from(0x40004c00);
        pub const UART5 = types.USART.from(0x40005000);
        pub const UART6 = types.USART.from(0x40001800);
        pub const UART7 = types.USART.from(0x40001c00);
        pub const UART8 = types.USART.from(0x40002000);

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
            /// RX_BUSY [10:10]
            /// receive status indication bit
            RX_BUSY: u1 = 0,
            /// MS_ERR [11:11]
            /// MARK or SPACE check error flag
            MS_ERR: u1 = 0,
            /// padding [12:31]
            _padding: u20 = 0,
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
            /// M_EXT [14:15]
            /// data length extension bit
            M_EXT: u2 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
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

        /// Control register 4
        CTLR4: RegisterRW(packed struct(u32) {
            /// unused [0:0]
            _unused0: u1 = 0,
            /// MS_ERRIE [1:1]
            /// SPACE or mark check error enable bit
            MS_ERRIE: u1 = 0,
            /// CHECK_SEL [2:4]
            /// check function selection bit
            CHECK_SEL: u3 = 0,
            /// padding [5:31]
            _padding: u27 = 0,
        }),
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
        }),

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
            /// TKEYEN [24:24]
            /// TKEY enable, including TKEY_F and TKEY_V
            TKEYEN: u1 = 0,
            /// TKITUNE [25:25]
            /// TKEY_I enable
            TKITUNE: u1 = 0,
            /// BUFEN [26:26]
            /// TKEY_BUF_Enable
            BUFEN: u1 = 0,
            /// PGA [27:28]
            /// ADC_PGA
            PGA: u2 = 0,
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
        SAMPTR1_CHARGE1: RegisterRW(packed struct(u32) {
            /// SMP10_TKCG10 [0:2]
            /// Channel 10 sample time selection
            SMP10_TKCG10: u3 = 0,
            /// SMP11_TKCG11 [3:5]
            /// Channel 11 sample time selection
            SMP11_TKCG11: u3 = 0,
            /// SMP12_TKCG12 [6:8]
            /// Channel 12 sample time selection
            SMP12_TKCG12: u3 = 0,
            /// SMP13_TKCG13 [9:11]
            /// Channel 13 sample time selection
            SMP13_TKCG13: u3 = 0,
            /// SMP14_TKCG14 [12:14]
            /// Channel 14 sample time selection
            SMP14_TKCG14: u3 = 0,
            /// SMP15_TKCG15 [15:17]
            /// Channel 15 sample time selection
            SMP15_TKCG15: u3 = 0,
            /// SMP16_TKCG16 [18:20]
            /// Channel 16 sample time selection
            SMP16_TKCG16: u3 = 0,
            /// SMP17_TKCG17 [21:23]
            /// Channel 17 sample time selection
            SMP17_TKCG17: u3 = 0,
            /// padding [24:31]
            _padding: u8 = 0,
        }),

        /// sample time register 2
        SAMPTR2_CHARGE2: RegisterRW(packed struct(u32) {
            /// SMP0_TKCG0 [0:2]
            /// Channel 0 sample time selection
            SMP0_TKCG0: u3 = 0,
            /// SMP1_TKCG1 [3:5]
            /// Channel 1 sample time selection
            SMP1_TKCG1: u3 = 0,
            /// SMP2_TKCG2 [6:8]
            /// Channel 2 sample time selection
            SMP2_TKCG2: u3 = 0,
            /// SMP3_TKCG3 [9:11]
            /// Channel 3 sample time selection
            SMP3_TKCG3: u3 = 0,
            /// SMP4_TKCG4 [12:14]
            /// Channel 4 sample time selection
            SMP4_TKCG4: u3 = 0,
            /// SMP5_TKCG5 [15:17]
            /// Channel 5 sample time selection
            SMP5_TKCG5: u3 = 0,
            /// SMP6_TKCG6 [18:20]
            /// Channel 6 sample time selection
            SMP6_TKCG6: u3 = 0,
            /// SMP7_TKCG7 [21:23]
            /// Channel 7 sample time selection
            SMP7_TKCG7: u3 = 0,
            /// SMP8_TKCG8 [24:26]
            /// Channel 8 sample time selection
            SMP8_TKCG8: u3 = 0,
            /// SMP9_TKCG9 [27:29]
            /// Channel 9 sample time selection
            SMP9_TKCG9: u3 = 0,
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

        /// regular sequence register 3;TKEY_V_CHANNEL
        RSQR3__CHANNEL: RegisterRW(packed struct(u32) {
            /// SQ1__CHSEL [0:4]
            /// 1st conversion in regular sequence;TKDY_V channel select
            SQ1__CHSEL: u5 = 0,
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

        /// injected data register x_Charge data offset for injected channel x
        IDATAR1_CHGOFFSET: RegisterRW(packed struct(u32) {
            /// IDATA0_7_TKCGOFFSET [0:7]
            /// Injected data_Touch key charge data offset for injected channel x
            IDATA0_7_TKCGOFFSET: u8 = 0,
            /// IDATA8_15 [8:15]
            /// Injected data
            IDATA8_15: u8 = 0,
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

        /// regular data register_start and discharge time register
        RDATAR_DR_ACT_DCG: RegisterRW(packed struct(u32) {
            /// DATA0_7_TKACT_DCG [0:7]
            /// Regular data_Touch key start and discharge time register
            DATA0_7_TKACT_DCG: u8 = 0,
            /// DATA8_15 [8:15]
            /// Regular data
            DATA8_15: u8 = 0,
            /// ADC2DATA [16:31]
            /// converter data
            ADC2DATA: u16 = 0,
        }),

        /// offset 0x4
        _offset20: [4]u8,

        /// ADC time register
        AUX: RegisterRW(packed struct(u32) {
            /// ADC_SMP_SEL0 [0:0]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL0: u1 = 0,
            /// ADC_SMP_SEL1 [1:1]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL1: u1 = 0,
            /// ADC_SMP_SEL2 [2:2]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL2: u1 = 0,
            /// ADC_SMP_SEL3 [3:3]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL3: u1 = 0,
            /// ADC_SMP_SEL4 [4:4]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL4: u1 = 0,
            /// ADC_SMP_SEL5 [5:5]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL5: u1 = 0,
            /// ADC_SMP_SEL6 [6:6]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL6: u1 = 0,
            /// ADC_SMP_SEL7 [7:7]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL7: u1 = 0,
            /// ADC_SMP_SEL8 [8:8]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL8: u1 = 0,
            /// ADC_SMP_SEL9 [9:9]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL9: u1 = 0,
            /// ADC_SMP_SEL10 [10:10]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL10: u1 = 0,
            /// ADC_SMP_SEL11 [11:11]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL11: u1 = 0,
            /// ADC_SMP_SEL12 [12:12]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL12: u1 = 0,
            /// ADC_SMP_SEL13 [13:13]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL13: u1 = 0,
            /// ADC_SMP_SEL14 [14:14]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL14: u1 = 0,
            /// ADC_SMP_SEL15 [15:15]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL15: u1 = 0,
            /// ADC_SMP_SEL16 [16:16]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL16: u1 = 0,
            /// ADC_SMP_SEL17 [17:17]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL17: u1 = 0,
            /// padding [18:31]
            _padding: u14 = 0,
        }),
    };

    /// Analog to digital converter
    pub const ADC2 = extern struct {
        pub inline fn from(base: u32) *volatile types.ADC2 {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.ADC2) u32 {
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
        }),

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
            /// TKEYEN [24:24]
            /// TKEY enable, including TKEY_F and TKEY_V
            TKEYEN: u1 = 0,
            /// TKITUNE [25:25]
            /// TKEY_I enable
            TKITUNE: u1 = 0,
            /// BUFEN [26:26]
            /// TKEY_BUF_Enable
            BUFEN: u1 = 0,
            /// PGA [27:28]
            /// ADC_PGA
            PGA: u2 = 0,
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
        SAMPTR1_CHARGE1: RegisterRW(packed struct(u32) {
            /// SMP10_TKCG10 [0:2]
            /// Channel 10 sample time selection
            SMP10_TKCG10: u3 = 0,
            /// SMP11_TKCG11 [3:5]
            /// Channel 11 sample time selection
            SMP11_TKCG11: u3 = 0,
            /// SMP12_TKCG12 [6:8]
            /// Channel 12 sample time selection
            SMP12_TKCG12: u3 = 0,
            /// SMP13_TKCG13 [9:11]
            /// Channel 13 sample time selection
            SMP13_TKCG13: u3 = 0,
            /// SMP14_TKCG14 [12:14]
            /// Channel 14 sample time selection
            SMP14_TKCG14: u3 = 0,
            /// SMP15_TKCG15 [15:17]
            /// Channel 15 sample time selection
            SMP15_TKCG15: u3 = 0,
            /// SMP16_TKCG16 [18:20]
            /// Channel 16 sample time selection
            SMP16_TKCG16: u3 = 0,
            /// SMP17_TKCG17 [21:23]
            /// Channel 17 sample time selection
            SMP17_TKCG17: u3 = 0,
            /// padding [24:31]
            _padding: u8 = 0,
        }),

        /// sample time register 2
        SAMPTR2_CHARGE2: RegisterRW(packed struct(u32) {
            /// SMP0_TKCG0 [0:2]
            /// Channel 0 sample time selection
            SMP0_TKCG0: u3 = 0,
            /// SMP1_TKCG1 [3:5]
            /// Channel 1 sample time selection
            SMP1_TKCG1: u3 = 0,
            /// SMP2_TKCG2 [6:8]
            /// Channel 2 sample time selection
            SMP2_TKCG2: u3 = 0,
            /// SMP3_TKCG3 [9:11]
            /// Channel 3 sample time selection
            SMP3_TKCG3: u3 = 0,
            /// SMP4_TKCG4 [12:14]
            /// Channel 4 sample time selection
            SMP4_TKCG4: u3 = 0,
            /// SMP5_TKCG5 [15:17]
            /// Channel 5 sample time selection
            SMP5_TKCG5: u3 = 0,
            /// SMP6_TKCG6 [18:20]
            /// Channel 6 sample time selection
            SMP6_TKCG6: u3 = 0,
            /// SMP7_TKCG7 [21:23]
            /// Channel 7 sample time selection
            SMP7_TKCG7: u3 = 0,
            /// SMP8_TKCG8 [24:26]
            /// Channel 8 sample time selection
            SMP8_TKCG8: u3 = 0,
            /// SMP9_TKCG9 [27:29]
            /// Channel 9 sample time selection
            SMP9_TKCG9: u3 = 0,
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

        /// regular sequence register 3;TKEY_V_CHANNEL
        RSQR3__CHANNEL: RegisterRW(packed struct(u32) {
            /// SQ1__CHSEL [0:4]
            /// 1st conversion in regular sequence;TKDY_V channel select
            SQ1__CHSEL: u5 = 0,
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

        /// injected data register x_Charge data offset for injected channel x
        IDATAR1_CHGOFFSET: RegisterRW(packed struct(u32) {
            /// IDATA0_7_TKCGOFFSET [0:7]
            /// Injected data_Touch key charge data offset for injected channel x
            IDATA0_7_TKCGOFFSET: u8 = 0,
            /// IDATA8_15 [8:15]
            /// Injected data
            IDATA8_15: u8 = 0,
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

        /// regular data register_start and discharge time register
        RDATAR_DR_ACT_DCG: RegisterRW(packed struct(u32) {
            /// DATA0_7_TKACT_DCG [0:7]
            /// Regular data_Touch key start and discharge time register
            DATA0_7_TKACT_DCG: u8 = 0,
            /// DATA8_15 [8:15]
            /// Regular data
            DATA8_15: u8 = 0,
            /// padding [16:31]
            _padding: u16 = 0,
        }),

        /// offset 0x4
        _offset20: [4]u8,

        /// ADC time register
        AUX: RegisterRW(packed struct(u32) {
            /// ADC_SMP_SEL0 [0:0]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL0: u1 = 0,
            /// ADC_SMP_SEL1 [1:1]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL1: u1 = 0,
            /// ADC_SMP_SEL2 [2:2]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL2: u1 = 0,
            /// ADC_SMP_SEL3 [3:3]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL3: u1 = 0,
            /// ADC_SMP_SEL4 [4:4]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL4: u1 = 0,
            /// ADC_SMP_SEL5 [5:5]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL5: u1 = 0,
            /// ADC_SMP_SEL6 [6:6]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL6: u1 = 0,
            /// ADC_SMP_SEL7 [7:7]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL7: u1 = 0,
            /// ADC_SMP_SEL8 [8:8]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL8: u1 = 0,
            /// ADC_SMP_SEL9 [9:9]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL9: u1 = 0,
            /// ADC_SMP_SEL10 [10:10]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL10: u1 = 0,
            /// ADC_SMP_SEL11 [11:11]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL11: u1 = 0,
            /// ADC_SMP_SEL12 [12:12]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL12: u1 = 0,
            /// ADC_SMP_SEL13 [13:13]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL13: u1 = 0,
            /// ADC_SMP_SEL14 [14:14]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL14: u1 = 0,
            /// ADC_SMP_SEL15 [15:15]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL15: u1 = 0,
            /// ADC_SMP_SEL16 [16:16]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL16: u1 = 0,
            /// ADC_SMP_SEL17 [17:17]
            /// channel sampling time optional enable bit
            ADC_SMP_SEL17: u1 = 0,
            /// padding [18:31]
            _padding: u14 = 0,
        }),
    };

    /// USB register
    pub const USBHS = extern struct {
        pub inline fn from(base: u32) *volatile types.USBHS {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.USBHS) u32 {
            return @intFromPtr(self);
        }

        /// USB base control
        USB_CTRL: RegisterRW(packed struct(u8) {
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
            /// RB_UC_DEV_PU_EN [4:4]
            /// USB device enable and internal pullup resistance enable
            RB_UC_DEV_PU_EN: u1 = 0,
            /// RB_UC_SPEED_TYPE [5:6]
            /// enable USB low speed: 00=full speed, 01=high speed, 10 =low speed
            RB_UC_SPEED_TYPE: u2 = 0,
            /// RB_UC_HOST_MODE [7:7]
            /// enable USB host mode: 0=device mode, 1=host mode
            RB_UC_HOST_MODE: u1 = 0,
        }),

        /// USB HOST control
        UHOST_CTRL: RegisterRW(packed struct(u8) {
            /// RB_UH_TX_BUS_RST [0:0]
            /// USB host bus reset status
            RB_UH_TX_BUS_RST: u1 = 0,
            /// bUH_TX_BUS_SUSPENDRB_UH_TX_BUS_SUSPEND [1:1]
            /// the host sends hang sigal
            bUH_TX_BUS_SUSPENDRB_UH_TX_BUS_SUSPEND: u1 = 0,
            /// RB_UH_TX_BUS_RESUME [2:2]
            /// host wake up device
            RB_UH_TX_BUS_RESUME: u1 = 0,
            /// RB_UH_REMOTE_WKUP [3:3]
            /// the remoke wake-up
            RB_UH_REMOTE_WKUP: u1 = 0,
            /// RB_UH_PHY_SUSPENDM [4:4]
            /// USB-PHY thesuspended state the internal USB-PLL is turned off
            RB_UH_PHY_SUSPENDM: u1 = 0,
            /// unused [5:5]
            _unused5: u1 = 0,
            /// RB_UH_SOF_FREE [6:6]
            /// the bus is idle
            RB_UH_SOF_FREE: u1 = 0,
            /// RB_UH_SOF_EN [7:7]
            /// automatically generate the SOF packet enabling control bit
            RB_UH_SOF_EN: u1 = 0,
        }),

        /// USB interrupt enable
        USB_INT_EN: RegisterRW(packed struct(u8) {
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
            /// indicate host SOF timer action status for USB host
            RB_UIE_HST_SOF: u1 = 0,
            /// RB_UIE_FIFO_OV [4:4]
            /// enable interrupt for FIFO overflow
            RB_UIE_FIFO_OV: u1 = 0,
            /// RB_U_1WIRE_MODE [5:5]
            /// enable USB sigle wire mode overflow
            RB_U_1WIRE_MODE: u1 = 0,
            /// RB_UIE_DEV_NAK [6:6]
            /// enable interrupt for NAK responded for USB device mode
            RB_UIE_DEV_NAK: u1 = 0,
            /// padding [7:7]
            _padding: u1 = 0,
        }),

        /// USB device address
        USB_DEV_AD: RegisterRW(packed struct(u8) {
            /// MASK_USB_ADDR [0:6]
            /// bit mask for USB device address
            MASK_USB_ADDR: u7 = 0,
            /// padding [7:7]
            _padding: u1 = 0,
        }),

        /// USB_FRAME_NO
        USB_FRAME_NO: RegisterRW(packed struct(u16) {
            /// USB_FRAME_NO [0:15]
            /// USB_FRAME_NO
            USB_FRAME_NO: u16 = 0,
        }),

        /// indicate USB suspend status
        USB_USB_SUSPEND: RegisterRW(packed struct(u8) {
            /// USB_SYS_MOD [0:1]
            /// USB_SYS_MOD
            USB_SYS_MOD: u2 = 0,
            /// USB_WAKEUP [2:2]
            /// remote resume
            USB_WAKEUP: u1 = 0,
            /// unused [3:3]
            _unused3: u1 = 0,
            /// USB_LINESTATE [4:5]
            /// USB_LINESTATE
            USB_LINESTATE: u2 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// offset 0x1
        _offset6: [1]u8,

        /// USB_SPEED_TYPE
        USB_SPEED_TYPE: RegisterRW(packed struct(u8) {
            /// USB_SPEED_TYPE [0:1]
            /// USB_SPEED_TYPE
            USB_SPEED_TYPE: u2 = 0,
            /// padding [2:7]
            _padding: u6 = 0,
        }),

        /// USB miscellaneous status
        USB_MIS_ST: RegisterRW(packed struct(u8) {
            /// RB_UMS_SPLIT_CAN [0:0]
            /// RO, indicate device attached status on USB host
            RB_UMS_SPLIT_CAN: u1 = 0,
            /// RB_UMS_ATTACH [1:1]
            /// RO, indicate UDM level saved at device attached to USB host
            RB_UMS_ATTACH: u1 = 0,
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
        USB_INT_FG: RegisterRW(packed struct(u8) {
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
            /// RB_UIF_SETUP_ACT [5:5]
            /// USB_SETUP_ACT
            RB_UIF_SETUP_ACT: u1 = 1,
            /// RB_UIF_ISO_ACT [6:6]
            /// UIF_ISO_ACT
            RB_UIF_ISO_ACT: u1 = 0,
            /// padding [7:7]
            _padding: u1 = 0,
        }),

        /// USB interrupt status
        USB_INT_ST: RegisterRW(packed struct(u8) {
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
        USB_RX_LEN: RegisterRW(packed struct(u16) {
            /// R16_USB_RX_LEN [0:15]
            /// length of received bytes
            R16_USB_RX_LEN: u16 = 0,
        }),

        /// offset 0x2
        _offset11: [2]u8,

        /// USB endpoint configuration
        UEP_CONFIG__UHOST_CTRL: RegisterRW(packed struct(u32) {
            /// unused [0:0]
            _unused0: u1 = 0,
            /// RB_UEP_T_EN_bUH_TX_EN [1:15]
            /// endpoint TX enable/bUH_TX_EN
            RB_UEP_T_EN_bUH_TX_EN: u15 = 0,
            /// unused [16:16]
            _unused16: u1 = 0,
            /// RB_UEP_T_EN__UH_EP_MOD [17:31]
            /// endpoint RX enable/bUH_TX_EN
            RB_UEP_T_EN__UH_EP_MOD: u15 = 0,
        }),

        /// USB endpoint type
        UEP_TYPE: RegisterRW(packed struct(u32) {
            /// unused [0:0]
            _unused0: u1 = 0,
            /// RB_UEP_T_TYPE [1:15]
            /// endpoint TX type
            RB_UEP_T_TYPE: u15 = 0,
            /// unused [16:16]
            _unused16: u1 = 0,
            /// RB_UEP_R_TYPE [17:31]
            /// endpoint RX type
            RB_UEP_R_TYPE: u15 = 0,
        }),

        /// USB endpoint buffer mode
        UEP_BUF_MOD: RegisterRW(packed struct(u32) {
            /// RB_UEP_BUF_MOD [0:15]
            /// buffer mode of USB endpoint
            RB_UEP_BUF_MOD: u16 = 0,
            /// RB_UEP_ISO_BUF_MOD [16:31]
            /// buffer mode of USB endpoint
            RB_UEP_ISO_BUF_MOD: u16 = 0,
        }),

        /// B endpoint 0 DMA buffer address
        UEP0_DMA: RegisterRW(packed struct(u32) {
            /// UEP0_DMA [0:31]
            /// endpoint 0 DMA buffer address
            UEP0_DMA: u32 = 0,
        }),

        /// endpoint 1 DMA RX buffer address
        UEP1_RX_DMA: RegisterRW(packed struct(u32) {
            /// UEP1_RX_DMA [0:31]
            /// endpoint 1 DMA buffer address
            UEP1_RX_DMA: u32 = 0,
        }),

        /// endpoint 2 DMA RX buffer address/UH_RX_DMA
        UEP2_RX_DMA__UH_RX_DMA: RegisterRW(packed struct(u32) {
            /// UEP2_RX_DMA__UH_RX_DMA [0:31]
            /// endpoint 2 DMA buffer address
            UEP2_RX_DMA__UH_RX_DMA: u32 = 0,
        }),

        /// endpoint 3 DMA RX buffer address
        UEP3_RX_DMA: RegisterRW(packed struct(u32) {
            /// UEP3_RX_DMA [0:31]
            /// endpoint 3 DMA buffer address
            UEP3_RX_DMA: u32 = 0,
        }),

        /// endpoint 4 DMA RX buffer address
        UEP4_RX_DMA: RegisterRW(packed struct(u32) {
            /// UEP4_RX_DMA [0:31]
            /// endpoint 4 DMA buffer address
            UEP4_RX_DMA: u32 = 0,
        }),

        /// endpoint 5 DMA RX buffer address
        UEP5_RX_DMA: RegisterRW(packed struct(u32) {
            /// UEP5_DMA [0:31]
            /// endpoint 5 DMA buffer address
            UEP5_DMA: u32 = 0,
        }),

        /// endpoint 6 DMA RX buffer address
        UEP6_RX_DMA: RegisterRW(packed struct(u32) {
            /// UEP6_RX_DMA [0:31]
            /// endpoint 6 DMA buffer address
            UEP6_RX_DMA: u32 = 0,
        }),

        /// endpoint 7 DMA RX buffer address
        UEP7_RX_DMA: RegisterRW(packed struct(u32) {
            /// UEP7_RX_DMA [0:31]
            /// endpoint 7 DMA buffer address
            UEP7_RX_DMA: u32 = 0,
        }),

        /// endpoint 8 DMA RX buffer address
        UEP8_RX_DMA: RegisterRW(packed struct(u32) {
            /// UEP8_RX_DMA [0:31]
            /// endpoint 8 DMA buffer address
            UEP8_RX_DMA: u32 = 0,
        }),

        /// endpoint 9 DMA RX buffer address
        UEP9_RX_DMA: RegisterRW(packed struct(u32) {
            /// UEP9_RX_DMA [0:31]
            /// endpoint 9 DMA buffer address
            UEP9_RX_DMA: u32 = 0,
        }),

        /// endpoint 10 DMA RX buffer address
        UEP10_RX_DMA: RegisterRW(packed struct(u32) {
            /// UEP10_RX_DMA [0:31]
            /// endpoint 10 DMA buffer address
            UEP10_RX_DMA: u32 = 0,
        }),

        /// endpoint 11 DMA RX buffer address
        UEP11_RX_DMA: RegisterRW(packed struct(u32) {
            /// UEP11_RX_DMA [0:31]
            /// endpoint 11 DMA buffer address
            UEP11_RX_DMA: u32 = 0,
        }),

        /// endpoint 12 DMA RX buffer address
        UEP12_RX_DMA: RegisterRW(packed struct(u32) {
            /// UEP12_RX_DMA [0:31]
            /// endpoint 12 DMA buffer address
            UEP12_RX_DMA: u32 = 0,
        }),

        /// endpoint 13 DMA RX buffer address
        UEP13_RX_DMA: RegisterRW(packed struct(u32) {
            /// UEP13_RX_DMA [0:31]
            /// endpoint 13 DMA buffer address
            UEP13_RX_DMA: u32 = 0,
        }),

        /// endpoint 14 DMA RX buffer address
        UEP14_RX_DMA: RegisterRW(packed struct(u32) {
            /// UEP14_RX_DMA [0:31]
            /// endpoint 14 DMA buffer address
            UEP14_RX_DMA: u32 = 0,
        }),

        /// endpoint 15 DMA RX buffer address
        UEP15_RX_DMA: RegisterRW(packed struct(u32) {
            /// UEP15_RX_DMA [0:31]
            /// endpoint 15 DMA buffer address
            UEP15_RX_DMA: u32 = 0,
        }),

        /// endpoint 1 DMA TX buffer address
        UEP1_TX_DMA: RegisterRW(packed struct(u32) {
            /// UEP1_TX_DMA [0:31]
            /// endpoint 1 DMA buffer address
            UEP1_TX_DMA: u32 = 0,
        }),

        /// endpoint 2 DMA TX buffer address
        UEP2_TX_DMA: RegisterRW(packed struct(u32) {
            /// UEP2_TX_DMA [0:31]
            /// endpoint 2 DMA buffer address
            UEP2_TX_DMA: u32 = 0,
        }),

        /// endpoint 3 DMA TX buffer address
        UEP3_TX_DMA__UH_TX_DMA: RegisterRW(packed struct(u32) {
            /// UEP3_TX_DMA__UH_TX_DMA [0:31]
            /// endpoint 3 DMA buffer address
            UEP3_TX_DMA__UH_TX_DMA: u32 = 0,
        }),

        /// endpoint 4 DMA TX buffer address
        UEP4_TX_DMA: RegisterRW(packed struct(u32) {
            /// UEP4_TX_DMA [0:31]
            /// endpoint 4 DMA buffer address
            UEP4_TX_DMA: u32 = 0,
        }),

        /// endpoint 5 DMA TX buffer address
        UEP5_TX_DMA: RegisterRW(packed struct(u32) {
            /// UEP5_TX_DMA [0:31]
            /// endpoint 5 DMA buffer address
            UEP5_TX_DMA: u32 = 0,
        }),

        /// endpoint 6 DMA TX buffer address
        UEP6_TX_DMA: RegisterRW(packed struct(u32) {
            /// UEP6_TX_DMA [0:31]
            /// endpoint 6 DMA buffer address
            UEP6_TX_DMA: u32 = 0,
        }),

        /// endpoint 7 DMA TX buffer address
        UEP7_TX_DMA: RegisterRW(packed struct(u32) {
            /// UEP7_TX_DMA [0:31]
            /// endpoint 7 DMA buffer address
            UEP7_TX_DMA: u32 = 0,
        }),

        /// endpoint 8 DMA TX buffer address
        UEP8_TX_DMA: RegisterRW(packed struct(u32) {
            /// UEP8_TX_DMA [0:31]
            /// endpoint 8 DMA buffer address
            UEP8_TX_DMA: u32 = 0,
        }),

        /// endpoint 9 DMA TX buffer address
        UEP9_TX_DMA: RegisterRW(packed struct(u32) {
            /// UEP9_TX_DMA [0:31]
            /// endpoint 9 DMA buffer address
            UEP9_TX_DMA: u32 = 0,
        }),

        /// endpoint 10 DMA TX buffer address
        UEP10_TX_DMA: RegisterRW(packed struct(u32) {
            /// UEP10_TX_DMA [0:31]
            /// endpoint 10 DMA buffer address
            UEP10_TX_DMA: u32 = 0,
        }),

        /// endpoint 11 DMA TX buffer address
        UEP11_TX_DMA: RegisterRW(packed struct(u32) {
            /// UEP11_TX_DMA [0:31]
            /// endpoint 11 DMA buffer address
            UEP11_TX_DMA: u32 = 0,
        }),

        /// endpoint 12 DMA TX buffer address
        UEP12_TX_DMA____UH_SPLIT_DATA: RegisterRW(packed struct(u32) {
            /// UEP12_TX_DMA___UH_SPLIT_DATA [0:31]
            /// endpoint 12 DMA buffer address
            UEP12_TX_DMA___UH_SPLIT_DATA: u32 = 0,
        }),

        /// endpoint 13 DMA TX buffer address
        UEP13_TX_DMA: RegisterRW(packed struct(u32) {
            /// UEP13_TX_DMA [0:31]
            /// endpoint 13 DMA buffer address
            UEP13_TX_DMA: u32 = 0,
        }),

        /// endpoint 14 DMA TX buffer address
        UEP14_TX_DMA: RegisterRW(packed struct(u32) {
            /// UEP14_TX_DMA [0:31]
            /// endpoint 14 DMA buffer address
            UEP14_TX_DMA: u32 = 0,
        }),

        /// endpoint 15 DMA TX buffer address
        UEP15_TX_DMA: RegisterRW(packed struct(u32) {
            /// UEP15_TX_DMA [0:31]
            /// endpoint 15 DMA buffer address
            UEP15_TX_DMA: u32 = 0,
        }),

        /// endpoint 0 max acceptable length
        UEP0_MAX_LEN: RegisterRW(packed struct(u16) {
            /// UEP0_MAX_LEN [0:10]
            /// endpoint 0 max acceptable length
            UEP0_MAX_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// offset 0x2
        _offset46: [2]u8,

        /// endpoint 1 max acceptable length
        UEP1_MAX_LEN: RegisterRW(packed struct(u16) {
            /// UEP1_MAX_LEN [0:10]
            /// endpoint 1 max acceptable length
            UEP1_MAX_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// offset 0x2
        _offset47: [2]u8,

        /// endpoint 2 max acceptable length
        UEP2_MAX_LEN__UH_RX_MAX_LEN: RegisterRW(packed struct(u16) {
            /// UEP2_MAX_LEN__UH_RX_MAX_LEN [0:10]
            /// endpoint 2 max acceptable length
            UEP2_MAX_LEN__UH_RX_MAX_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// offset 0x2
        _offset48: [2]u8,

        /// endpoint 3 MAX_LEN TX
        UEP3_MAX_LEN: RegisterRW(packed struct(u16) {
            /// UEP3_MAX_LEN [0:10]
            /// endpoint 3 max acceptable length
            UEP3_MAX_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// offset 0x2
        _offset49: [2]u8,

        /// endpoint 4 max acceptable length
        UEP4_MAX_LEN: RegisterRW(packed struct(u16) {
            /// UEP4_MAX_LEN [0:10]
            /// endpoint 4 max acceptable length
            UEP4_MAX_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// offset 0x2
        _offset50: [2]u8,

        /// endpoint 5 max acceptable length
        UEP5_MAX_LEN: RegisterRW(packed struct(u16) {
            /// UEP5_MAX_LEN [0:10]
            /// endpoint 5 max acceptable length
            UEP5_MAX_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// offset 0x2
        _offset51: [2]u8,

        /// endpoint 6 max acceptable length
        UEP6_MAX_LEN: RegisterRW(packed struct(u16) {
            /// UEP6_MAX_LEN [0:10]
            /// endpoint 6 max acceptable length
            UEP6_MAX_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// offset 0x2
        _offset52: [2]u8,

        /// endpoint 7 max acceptable length
        UEP7_MAX_LEN: RegisterRW(packed struct(u16) {
            /// UEP7_MAX_LEN [0:10]
            /// endpoint 7 max acceptable length
            UEP7_MAX_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// offset 0x2
        _offset53: [2]u8,

        /// endpoint 8 max acceptable length
        UEP8_MAX_LEN: RegisterRW(packed struct(u16) {
            /// UEP8_MAX_LEN [0:10]
            /// endpoint 8 max acceptable length
            UEP8_MAX_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// offset 0x2
        _offset54: [2]u8,

        /// endpoint 9 max acceptable length
        UEP9_MAX_LEN: RegisterRW(packed struct(u16) {
            /// UEP9_MAX_LEN [0:10]
            /// endpoint 9 max acceptable length
            UEP9_MAX_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// offset 0x2
        _offset55: [2]u8,

        /// endpoint 10 max acceptable length
        UEP10_MAX_LEN: RegisterRW(packed struct(u16) {
            /// UEP10_MAX_LEN [0:10]
            /// endpoint 10 max acceptable length
            UEP10_MAX_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// offset 0x2
        _offset56: [2]u8,

        /// endpoint 11 max acceptable length
        UEP11_MAX_LEN: RegisterRW(packed struct(u16) {
            /// UEP11_MAX_LEN [0:10]
            /// endpoint 11 max acceptable length
            UEP11_MAX_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// offset 0x2
        _offset57: [2]u8,

        /// endpoint 12 max acceptable length
        UEP12_MAX_LEN: RegisterRW(packed struct(u16) {
            /// UEP12_MAX_LEN [0:10]
            /// endpoint 12 max acceptable length
            UEP12_MAX_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// offset 0x2
        _offset58: [2]u8,

        /// endpoint 13 max acceptable length
        UEP13_MAX_LEN: RegisterRW(packed struct(u16) {
            /// UEP13_MAX_LEN [0:10]
            /// endpoint 13 max acceptable length
            UEP13_MAX_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// offset 0x2
        _offset59: [2]u8,

        /// endpoint 14 max acceptable length
        UEP14_MAX_LEN: RegisterRW(packed struct(u16) {
            /// UEP14_MAX_LEN [0:10]
            /// endpoint 14 max acceptable length
            UEP14_MAX_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// offset 0x2
        _offset60: [2]u8,

        /// endpoint 15 max acceptable length
        UEP15_MAX_LEN: RegisterRW(packed struct(u16) {
            /// UEP15_MAX_LEN [0:10]
            /// endpoint 15 max acceptable length
            UEP15_MAX_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// offset 0x2
        _offset61: [2]u8,

        /// endpoint 0 send the length
        UEP0_T_LEN: RegisterRW(packed struct(u16) {
            /// UEP0_T_LEN [0:6]
            /// endpoint 0 send the length
            UEP0_T_LEN: u7 = 0,
            /// padding [7:15]
            _padding: u9 = 0,
        }),

        /// endpoint 0 send control
        UEP0_TX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// endpoint 0 control of the send response to IN transactions
            MASK_UEP_T_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_T_TOG [3:4]
            /// endpoint 0 synchronous trigger bit for the sender to prepare
            MASK_UEP_T_TOG: u2 = 0,
            /// RB_UEP_T_TOG_AUTO [5:5]
            /// endpoint 0 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_T_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 0 send control
        UEP0_RX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// endpoint 0 control of the accept response to OUT transactions
            MASK_UEP_R_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_R_TOG [3:4]
            /// endpoint 0 synchronous trigger bit for the accept to prepare
            MASK_UEP_R_TOG: u2 = 0,
            /// RB_UEP_R_TOG_AUTO [5:5]
            /// endpoint 0 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_R_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 1 send the length
        UEP1_T_LEN: RegisterRW(packed struct(u16) {
            /// UEP1_T_LEN [0:10]
            /// endpoint 1 send the length
            UEP1_T_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// endpoint 1 send control
        UEP1_TX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// endpoint 1 control of the send response to IN transactions
            MASK_UEP_T_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_T_TOG [3:4]
            /// endpoint 1 synchronous trigger bit for the sender to prepare
            MASK_UEP_T_TOG: u2 = 0,
            /// RB_UEP_T_TOG_AUTO [5:5]
            /// endpoint 1 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_T_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 1 send control
        UEP1_RX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// endpoint 1 control of the accept response to OUT transactions
            MASK_UEP_R_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_R_TOG [3:4]
            /// endpoint 1 synchronous trigger bit for the accept to prepare
            MASK_UEP_R_TOG: u2 = 0,
            /// RB_UEP_R_TOG_AUTO [5:5]
            /// endpoint 1 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_R_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 2 send the length
        UEP2_T_LEN__UH_EP_PID: RegisterRW(packed struct(u16) {
            /// UEP2_T_LEN__MASK_UH_ENDP__MASK_UH_TOKEN [0:10]
            /// endpoint 2 send the length
            UEP2_T_LEN__MASK_UH_ENDP__MASK_UH_TOKEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// endpoint 2 send control
        UEP2_TX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// endpoint 2 control of the send response to IN transactions
            MASK_UEP_T_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_T_TOG [3:4]
            /// endpoint 2 synchronous trigger bit for the sender to prepare
            MASK_UEP_T_TOG: u2 = 0,
            /// RB_UEP_T_TOG_AUTO [5:5]
            /// endpoint 2 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_T_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 2 send control
        UEP2_RX_CTRL__UH_RX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES__MASK_UH_R_RES [0:1]
            /// endpoint 2 control of the accept response to OUT transactions
            MASK_UEP_R_RES__MASK_UH_R_RES: u2 = 0,
            /// bUH_R_RES_NO [2:2]
            /// bUH_R_RES_NO
            bUH_R_RES_NO: u1 = 0,
            /// MASK_UEP_R_TOG__MASK_UH_R_TOG [3:4]
            /// endpoint 2 synchronous trigger bit for the accept to prepare
            MASK_UEP_R_TOG__MASK_UH_R_TOG: u2 = 0,
            /// bUEP_R_TOG_AUTO__bUH_R_AUTO_TOG [5:5]
            /// endpoint 2 synchronous trigger bit automatic filp enables the control bit
            bUEP_R_TOG_AUTO__bUH_R_AUTO_TOG: u1 = 0,
            /// RB_UH_R_DATA_NO [6:6]
            /// bUH_R_DATA_NO
            RB_UH_R_DATA_NO: u1 = 0,
            /// padding [7:7]
            _padding: u1 = 0,
        }),

        /// endpoint 3 send the length
        UEP3_T_LEN___UH_TX_LEN_H: RegisterRW(packed struct(u16) {
            /// UEP3_T_LEN___UH_TX_LEN_H [0:10]
            /// endpoint 3 send the length
            UEP3_T_LEN___UH_TX_LEN_H: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// endpoint 3 send control
        UEP3_TX_CTRL___UH_TX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES_____MASK_UH_T_RES [0:1]
            /// endpoint 3 control of the send response to IN transactions
            MASK_UEP_T_RES_____MASK_UH_T_RES: u2 = 0,
            /// bUH_T_RES_NO [2:2]
            /// bUH_T_RES_NO
            bUH_T_RES_NO: u1 = 0,
            /// MASK_UEP_T_TOG____MASK_UH_T_TOG [3:4]
            /// endpoint 3 synchronous trigger bit for the sender to prepare
            MASK_UEP_T_TOG____MASK_UH_T_TOG: u2 = 0,
            /// RB_UEP_T_TOG_AUTO____bUH_T_AUTO_TOG [5:5]
            /// endpoint 3 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_T_TOG_AUTO____bUH_T_AUTO_TOG: u1 = 0,
            /// bUH_T_DATA_NO [6:6]
            /// bUH_T_DATA_NO
            bUH_T_DATA_NO: u1 = 0,
            /// padding [7:7]
            _padding: u1 = 0,
        }),

        /// endpoint 3 send control
        UEP3_RX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// endpoint 3 control of the accept response to OUT transactions
            MASK_UEP_R_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_R_TOG [3:4]
            /// endpoint 3 synchronous trigger bit for the accept to prepare
            MASK_UEP_R_TOG: u2 = 0,
            /// RB_UEP_R_TOG_AUTO [5:5]
            /// endpoint 3 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_R_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 4 send the length
        UEP4_T_LEN: RegisterRW(packed struct(u16) {
            /// UEP4_T_LEN [0:10]
            /// endpoint 0 send the length
            UEP4_T_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// endpoint 4 send control
        UEP4_TX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// endpoint 4 control of the send response to IN transactions
            MASK_UEP_T_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_T_TOG [3:4]
            /// endpoint 4 synchronous trigger bit for the sender to prepare
            MASK_UEP_T_TOG: u2 = 0,
            /// RB_UEP_T_TOG_AUTO [5:5]
            /// endpoint 4 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_T_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 4 send control
        UEP4_RX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// endpoint 4 control of the accept response to OUT transactions
            MASK_UEP_R_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_R_TOG [3:4]
            /// endpoint 4 synchronous trigger bit for the accept to prepare
            MASK_UEP_R_TOG: u2 = 0,
            /// RB_UEP_R_TOG_AUTO [5:5]
            /// endpoint 4 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_R_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 5 send the length
        UEP5_T_LEN: RegisterRW(packed struct(u16) {
            /// UEP5_T_LEN [0:10]
            /// endpoint 5 send the length
            UEP5_T_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// endpoint 5 send control
        UEP5_TX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// endpoint 5 control of the send response to IN transactions
            MASK_UEP_T_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_T_TOG [3:4]
            /// endpoint 5 synchronous trigger bit for the sender to prepare
            MASK_UEP_T_TOG: u2 = 0,
            /// RB_UEP_T_TOG_AUTO [5:5]
            /// endpoint 5 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_T_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 5 send control
        UEP5_RX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// endpoint 5 control of the accept response to OUT transactions
            MASK_UEP_R_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_R_TOG [3:4]
            /// endpoint 5 synchronous trigger bit for the accept to prepare
            MASK_UEP_R_TOG: u2 = 0,
            /// RB_UEP_R_TOG_AUTO [5:5]
            /// endpoint 5 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_R_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 6 send the length
        UEP6_T_LEN: RegisterRW(packed struct(u16) {
            /// UEP6_T_LEN [0:10]
            /// endpoint 6 send the length
            UEP6_T_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// endpoint 6 send control
        UEP6_TX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// endpoint 6 control of the send response to IN transactions
            MASK_UEP_T_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_T_TOG [3:4]
            /// endpoint 6 synchronous trigger bit for the sender to prepare
            MASK_UEP_T_TOG: u2 = 0,
            /// RB_UEP_T_TOG_AUTO [5:5]
            /// endpoint 6 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_T_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 6 send control
        UEP6_RX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// endpoint 6 control of the accept response to OUT transactions
            MASK_UEP_R_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_R_TOG [3:4]
            /// endpoint 6 synchronous trigger bit for the accept to prepare
            MASK_UEP_R_TOG: u2 = 0,
            /// RB_UEP_R_TOG_AUTO [5:5]
            /// endpoint 6 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_R_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 7 send the length
        UEP7_T_LEN: RegisterRW(packed struct(u16) {
            /// UEP7_T_LEN [0:10]
            /// endpoint 7 send the length
            UEP7_T_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// endpoint 7 send control
        UEP7_TX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// endpoint 7 control of the send response to IN transactions
            MASK_UEP_T_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_T_TOG [3:4]
            /// endpoint 7 synchronous trigger bit for the sender to prepare
            MASK_UEP_T_TOG: u2 = 0,
            /// RB_UEP_T_TOG_AUTO [5:5]
            /// endpoint 7 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_T_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 7 send control
        UEP7_RX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// endpoint 7 control of the accept response to OUT transactions
            MASK_UEP_R_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_R_TOG [3:4]
            /// endpoint 7 synchronous trigger bit for the accept to prepare
            MASK_UEP_R_TOG: u2 = 0,
            /// RB_UEP_R_TOG_AUTO [5:5]
            /// endpoint 7 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_R_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 8 send the length
        UEP8_T_LEN: RegisterRW(packed struct(u16) {
            /// UEP8_T_LEN [0:10]
            /// endpoint 8 send the length
            UEP8_T_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// endpoint 8 send control
        UEP8_TX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// endpoint 8 control of the send response to IN transactions
            MASK_UEP_T_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_T_TOG [3:4]
            /// endpoint 8 synchronous trigger bit for the sender to prepare
            MASK_UEP_T_TOG: u2 = 0,
            /// RB_UEP_T_TOG_AUTO [5:5]
            /// endpoint 8 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_T_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 8 send control
        UEP8_RX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// endpoint 8 control of the accept response to OUT transactions
            MASK_UEP_R_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_R_TOG [3:4]
            /// endpoint 8 synchronous trigger bit for the accept to prepare
            MASK_UEP_R_TOG: u2 = 0,
            /// RB_UEP_R_TOG_AUTO [5:5]
            /// endpoint 8 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_R_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint9 send the length
        UEP9_T_LEN: RegisterRW(packed struct(u16) {
            /// UEP9_T_LEN [0:10]
            /// endpoint 9 send the length
            UEP9_T_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// endpoint 9 send control
        UEP9_TX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// endpoint 9 control of the send response to IN transactions
            MASK_UEP_T_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_T_TOG [3:4]
            /// endpoint 9 synchronous trigger bit for the sender to prepare
            MASK_UEP_T_TOG: u2 = 0,
            /// RB_UEP_T_TOG_AUTO [5:5]
            /// endpoint 9 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_T_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 9 send control
        UEP9_RX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// endpoint 9 control of the accept response to OUT transactions
            MASK_UEP_R_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_R_TOG [3:4]
            /// endpoint 9 synchronous trigger bit for the accept to prepare
            MASK_UEP_R_TOG: u2 = 0,
            /// RB_UEP_R_TOG_AUTO [5:5]
            /// endpoint 9 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_R_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 10 send the length
        UEP10_T_LEN: RegisterRW(packed struct(u16) {
            /// UEP10_T_LEN [0:10]
            /// endpoint 10 send the length
            UEP10_T_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// endpoint 10 send control
        UEP10_TX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// endpoint 10 control of the send response to IN transactions
            MASK_UEP_T_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_T_TOG [3:4]
            /// endpoint 10 synchronous trigger bit for the sender to prepare
            MASK_UEP_T_TOG: u2 = 0,
            /// RB_UEP_T_TOG_AUTO [5:5]
            /// endpoint 10 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_T_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 10 send control
        UEP10_RX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// endpoint 10 control of the accept response to OUT transactions
            MASK_UEP_R_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_R_TOG [3:4]
            /// endpoint 10 synchronous trigger bit for the accept to prepare
            MASK_UEP_R_TOG: u2 = 0,
            /// RB_UEP_R_TOG_AUTO [5:5]
            /// endpoint 10 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_R_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 11 send the length
        UEP11_T_LEN: RegisterRW(packed struct(u16) {
            /// UEP0_T_LEN [0:10]
            /// endpoint 11 send the length
            UEP0_T_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// endpoint 11 send control
        UEP11_TX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// endpoint 11 control of the send response to IN transactions
            MASK_UEP_T_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_T_TOG [3:4]
            /// endpoint 11 synchronous trigger bit for the sender to prepare
            MASK_UEP_T_TOG: u2 = 0,
            /// RB_UEP_T_TOG_AUTO [5:5]
            /// endpoint 11 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_T_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 11 send control
        UEP11_RX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// endpoint 11 control of the accept response to OUT transactions
            MASK_UEP_R_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_R_TOG [3:4]
            /// endpoint 11 synchronous trigger bit for the accept to prepare
            MASK_UEP_R_TOG: u2 = 0,
            /// RB_UEP_R_TOG_AUTO [5:5]
            /// endpoint 11 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_R_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 12 send the length
        UEP12_T_LEN: RegisterRW(packed struct(u16) {
            /// UEP0_T_LEN [0:10]
            /// endpoint 12 send the length
            UEP0_T_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// endpoint 12 send control
        UEP12_TX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// endpoint 12 control of the send response to IN transactions
            MASK_UEP_T_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_T_TOG [3:4]
            /// endpoint 12 synchronous trigger bit for the sender to prepare
            MASK_UEP_T_TOG: u2 = 0,
            /// RB_UEP_T_TOG_AUTO [5:5]
            /// endpoint 12 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_T_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 12 send control
        UEP12_RX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// endpoint 12 control of the accept response to OUT transactions
            MASK_UEP_R_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_R_TOG [3:4]
            /// endpoint 12 synchronous trigger bit for the accept to prepare
            MASK_UEP_R_TOG: u2 = 0,
            /// RB_UEP_R_TOG_AUTO [5:5]
            /// endpoint 12 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_R_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 13 send the length
        UEP13_T_LEN: RegisterRW(packed struct(u16) {
            /// UEP13_T_LEN [0:10]
            /// endpoint 13 send the length
            UEP13_T_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// endpoint 13 send control
        UEP13_TX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// endpoint 13 control of the send response to IN transactions
            MASK_UEP_T_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_T_TOG [3:4]
            /// endpoint 13 synchronous trigger bit for the sender to prepare
            MASK_UEP_T_TOG: u2 = 0,
            /// RB_UEP_T_TOG_AUTO [5:5]
            /// endpoint 13 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_T_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 13 send control
        UEP13_RX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// endpoint 13 control of the accept response to OUT transactions
            MASK_UEP_R_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_R_TOG [3:4]
            /// endpoint 13 synchronous trigger bit for the accept to prepare
            MASK_UEP_R_TOG: u2 = 0,
            /// RB_UEP_R_TOG_AUTO [5:5]
            /// endpoint 13 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_R_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 14 send the length
        UEP14_T_LEN: RegisterRW(packed struct(u16) {
            /// UEP14_T_LEN [0:10]
            /// endpoint 14 send the length
            UEP14_T_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// endpoint 14 send control
        UEP14_TX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// endpoint 14 control of the send response to IN transactions
            MASK_UEP_T_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_T_TOG [3:4]
            /// endpoint 14 synchronous trigger bit for the sender to prepare
            MASK_UEP_T_TOG: u2 = 0,
            /// RB_UEP_T_TOG_AUTO [5:5]
            /// endpoint 14 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_T_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 14 send control
        UEP14_RX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// endpoint 14 control of the accept response to OUT transactions
            MASK_UEP_R_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_R_TOG [3:4]
            /// endpoint 14 synchronous trigger bit for the accept to prepare
            MASK_UEP_R_TOG: u2 = 0,
            /// RB_UEP_R_TOG_AUTO [5:5]
            /// endpoint 14 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_R_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 15 send the length
        UEP15_T_LEN: RegisterRW(packed struct(u16) {
            /// UEP0_T_LEN [0:10]
            /// endpoint 15 send the length
            UEP0_T_LEN: u11 = 0,
            /// padding [11:15]
            _padding: u5 = 0,
        }),

        /// endpoint 15 send control
        UEP15_TX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// endpoint 15 control of the send response to IN transactions
            MASK_UEP_T_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_T_TOG [3:4]
            /// endpoint 15 synchronous trigger bit for the sender to prepare
            MASK_UEP_T_TOG: u2 = 0,
            /// RB_UEP_T_TOG_AUTO [5:5]
            /// endpoint 15 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_T_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),

        /// endpoint 15 send control
        UEP15_RX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// endpoint 15 control of the accept response to OUT transactions
            MASK_UEP_R_RES: u2 = 0,
            /// unused [2:2]
            _unused2: u1 = 0,
            /// MASK_UEP_R_TOG [3:4]
            /// endpoint 15 synchronous trigger bit for the accept to prepare
            MASK_UEP_R_TOG: u2 = 0,
            /// RB_UEP_R_TOG_AUTO [5:5]
            /// endpoint 15 synchronous trigger bit automatic filp enables the control bit
            RB_UEP_R_TOG_AUTO: u1 = 0,
            /// padding [6:7]
            _padding: u2 = 0,
        }),
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
            /// DR [0:31]
            /// Data Register
            DR: u32 = 4294967295,
        }),

        /// Independent Data register
        IDATAR: RegisterRW(packed struct(u32) {
            /// IDR [0:7]
            /// Independent Data register
            IDR: u8 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }),

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
        pub inline fn from(base: u32) *volatile types.FLASH {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.FLASH) u32 {
            return @intFromPtr(self);
        }

        /// offset 0x4
        _offset0: [4]u8,

        /// Flash key register
        KEYR: RegisterRW(packed struct(u32) {
            /// KEYR [0:31]
            /// FPEC key
            KEYR: u32 = 0,
        }),

        /// Flash option key register
        OBKEYR: RegisterRW(packed struct(u32) {
            /// OPTKEY [0:31]
            /// Option byte key
            OPTKEY: u32 = 0,
        }),

        /// Status register
        STATR: RegisterRW(packed struct(u32) {
            /// BSY [0:0]
            /// Busy
            BSY: u1 = 0,
            /// WRBSY [1:1]
            /// Quick page programming
            WRBSY: u1 = 0,
            /// unused [2:3]
            _unused2: u2 = 0,
            /// WRPRTERR [4:4]
            /// Write protection error
            WRPRTERR: u1 = 0,
            /// EOP [5:5]
            /// End of operation
            EOP: u1 = 0,
            /// unused [6:6]
            _unused6: u1 = 0,
            /// EHMODS [7:7]
            /// Enhance mode start
            EHMODS: u1 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
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
            FLOCK: u1 = 0,
            /// FTPG [16:16]
            /// Fast programming
            FTPG: u1 = 0,
            /// FTER [17:17]
            /// Fast erase
            FTER: u1 = 0,
            /// BER32 [18:18]
            /// Block Erase 32K
            BER32: u1 = 0,
            /// BER64 [19:19]
            /// Block Erase 64K
            BER64: u1 = 0,
            /// unused [20:20]
            _unused20: u1 = 0,
            /// PGSTRT [21:21]
            /// Page Programming Start
            PGSTRT: u1 = 0,
            /// RSENACT [22:22]
            /// Reset Flash Enhance read mode
            RSENACT: u1 = 0,
            /// unused [23:23]
            _unused23: u1 = 0,
            /// EHMOD [24:24]
            /// Flash Enhance read mode
            EHMOD: u1 = 0,
            /// SCKMODE [25:25]
            /// Flash SCK mode
            SCKMODE: u1 = 0,
            /// padding [26:31]
            _padding: u6 = 0,
        }),

        /// Flash address register
        ADDR: RegisterRW(packed struct(u32) {
            /// FAR [0:31]
            /// Flash Address
            FAR: u32 = 0,
        }),

        /// offset 0x4
        _offset5: [4]u8,

        /// Option byte register
        OBR: RegisterRW(packed struct(u32) {
            /// OBERR [0:0]
            /// Option byte error
            OBERR: u1 = 0,
            /// RDPRT [1:1]
            /// Read protection
            RDPRT: u1 = 0,
            /// IWDGSW [2:2]
            /// IWDG_SW
            IWDGSW: u1 = 1,
            /// STOPRST [3:3]
            /// STOP_RST
            STOPRST: u1 = 1,
            /// STANDYRST [4:4]
            /// STANDY_RST
            STANDYRST: u1 = 1,
            /// unused [5:6]
            _unused5: u2 = 3,
            /// SRAM_CODE_MODE [7:9]
            /// SRAM_CODE_MODE
            SRAM_CODE_MODE: u3 = 7,
            /// padding [10:31]
            _padding: u22 = 65535,
        }),

        /// Write protection register
        WPR: RegisterRW(packed struct(u32) {
            /// WRP [0:31]
            /// Write protect
            WRP: u32 = 4294967295,
        }),

        /// Mode select register
        MODEKEYR: RegisterRW(packed struct(u32) {
            /// MODEKEYR [0:31]
            /// Mode select
            MODEKEYR: u32 = 0,
        }),
    };

    /// USB FS OTG register
    pub const USB_OTG_FS = extern struct {
        pub inline fn from(base: u32) *volatile types.USB_OTG_FS {
            return @ptrFromInt(base);
        }

        pub inline fn addr(self: *volatile types.USB_OTG_FS) u32 {
            return @intFromPtr(self);
        }

        /// USB base control
        R8_USB_CTRL: RegisterRW(packed struct(u8) {
            /// RB_UC_DMA_EN [0:0]
            /// DMA enable and DMA interrupt enable for USB
            RB_UC_DMA_EN: u1 = 0,
            /// RB_UC_CLR_ALL [1:1]
            /// force clear FIFO and count of USB
            RB_UC_CLR_ALL: u1 = 0,
            /// RB_UC_RST_SIE [2:2]
            /// force reset USB SIE, need software clear
            RB_UC_RST_SIE: u1 = 0,
            /// RB_UC_INT_BUSY [3:3]
            /// enable automatic responding busy for device mode or automatic pause for host mode during interrupt flag UIF_TRANSFER valid
            RB_UC_INT_BUSY: u1 = 0,
            /// MASK_UC_SYS_CTRL_RB_UC_DEV_PU_EN [4:5]
            /// USB device enable and internal pullup resistance enable
            MASK_UC_SYS_CTRL_RB_UC_DEV_PU_EN: u2 = 0,
            /// RB_UC_LOW_SPEED [6:6]
            /// enable USB low speed: 0=12Mbps, 1=1.5Mbps
            RB_UC_LOW_SPEED: u1 = 0,
            /// RB_UC_HOST_MODE [7:7]
            /// enable USB host mode: 0=device mode, 1=host mode
            RB_UC_HOST_MODE: u1 = 0,
        }),

        /// USB device/host physical prot control
        UDEV_CTRL__UHOST_CTRL: RegisterRW(packed struct(u8) {
            /// RB_UH_PORT_EN__RB_UD_PORT_EN [0:0]
            /// enable USB port: 0=disable, 1=enable port, automatic disabled if USB device detached
            RB_UH_PORT_EN__RB_UD_PORT_EN: u1 = 0,
            /// RB_UH_BUS_RESET__RB_UD_GP_BIT [1:1]
            /// force clear FIFO and count of USB
            RB_UH_BUS_RESET__RB_UD_GP_BIT: u1 = 0,
            /// RB_UH_LOW_SPEED__RB_UD_LOW_SPEED [2:2]
            /// enable USB port low speed: 0=full speed, 1=low speed
            RB_UH_LOW_SPEED__RB_UD_LOW_SPEED: u1 = 0,
            /// unused [3:3]
            _unused3: u1 = 0,
            /// RB_UH_DM_PIN__RB_UD_DM_PIN [4:4]
            /// ReadOnly: indicate current UDM pin level
            RB_UH_DM_PIN__RB_UD_DM_PIN: u1 = 0,
            /// RB_UH_DP_PIN__RB_UD_DP_PIN [5:5]
            /// USB device enable and internal pullup resistance enable
            RB_UH_DP_PIN__RB_UD_DP_PIN: u1 = 0,
            /// unused [6:6]
            _unused6: u1 = 0,
            /// RB_UH_PD_DIS__RB_UD_PD_DIS [7:7]
            /// disable USB UDP/UDM pulldown resistance: 0=enable pulldown, 1=disable
            RB_UH_PD_DIS__RB_UD_PD_DIS: u1 = 0,
        }),

        /// USB interrupt enable
        R8_USB_INT_EN: RegisterRW(packed struct(u8) {
            /// RB_UIE_BUS_RST__RB_UIE_DETECT [0:0]
            /// enable interrupt for USB bus reset event for USB device mode
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
        R16_USB_RX_LEN: RegisterRW(packed struct(u16) {
            /// padding [0:15]
            _padding: u16 = 0,
        }),

        /// offset 0x2
        _offset8: [2]u8,

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

        /// endpoint 5/6 mode
        R8_UEP5_6_MOD: RegisterRW(packed struct(u8) {
            /// RB_UEP5_BUF_MOD [0:0]
            /// buffer mode of USB endpoint 5
            RB_UEP5_BUF_MOD: u1 = 0,
            /// unused [1:1]
            _unused1: u1 = 0,
            /// RB_UEP5_TX_EN [2:2]
            /// enable USB endpoint 5 transmittal (IN)
            RB_UEP5_TX_EN: u1 = 0,
            /// RB_UEP5_RX_EN [3:3]
            /// enable USB endpoint 5 receiving (OUT)
            RB_UEP5_RX_EN: u1 = 0,
            /// RB_UEP6_BUF_MOD [4:4]
            /// buffer mode of USB endpoint 6
            RB_UEP6_BUF_MOD: u1 = 0,
            /// unused [5:5]
            _unused5: u1 = 0,
            /// RB_UEP6_TX_EN [6:6]
            /// enable USB endpoint 6 transmittal (IN)
            RB_UEP6_TX_EN: u1 = 0,
            /// RB_UEP3_RX_EN [7:7]
            /// enable USB endpoint 6 receiving (OUT)
            RB_UEP3_RX_EN: u1 = 0,
        }),

        /// endpoint 7 mode
        R8_UEP7_MOD: RegisterRW(packed struct(u8) {
            /// RB_UEP7_BUF_MOD [0:0]
            /// buffer mode of USB endpoint 7
            RB_UEP7_BUF_MOD: u1 = 0,
            /// unused [1:1]
            _unused1: u1 = 0,
            /// RB_UEP7_TX_EN [2:2]
            /// enable USB endpoint 7 transmittal (IN)
            RB_UEP7_TX_EN: u1 = 0,
            /// RB_UEP7_RX_EN [3:3]
            /// enable USB endpoint 7 receiving (OUT)
            RB_UEP7_RX_EN: u1 = 0,
            /// padding [4:7]
            _padding: u4 = 0,
        }),

        /// endpoint 0 DMA buffer address
        R32_UEP0_DMA: RegisterRW(packed struct(u32) {
            /// padding [0:31]
            _padding: u32 = 0,
        }),

        /// endpoint 1 DMA buffer address
        R32_UEP1_DMA: RegisterRW(packed struct(u32) {
            /// padding [0:31]
            _padding: u32 = 0,
        }),

        /// endpoint 2 DMA buffer address;host rx endpoint buffer high address
        R32_UEP2_DMA__R32_UH_RX_DMA: RegisterRW(packed struct(u32) {
            /// padding [0:31]
            _padding: u32 = 0,
        }),

        /// endpoint 3 DMA buffer address;host tx endpoint buffer high address
        R32_UEP3_DMA__R32_UH_TX_DMA: RegisterRW(packed struct(u32) {
            /// padding [0:31]
            _padding: u32 = 0,
        }),

        /// endpoint 4 DMA buffer address
        R32_UEP4_DMA: RegisterRW(packed struct(u32) {
            /// padding [0:31]
            _padding: u32 = 0,
        }),

        /// endpoint 5 DMA buffer address
        R32_UEP5_DMA: RegisterRW(packed struct(u32) {
            /// padding [0:31]
            _padding: u32 = 0,
        }),

        /// endpoint 6 DMA buffer address
        R32_UEP6_DMA: RegisterRW(packed struct(u32) {
            /// padding [0:31]
            _padding: u32 = 0,
        }),

        /// endpoint 7 DMA buffer address
        R32_UEP7_DMA: RegisterRW(packed struct(u32) {
            /// padding [0:31]
            _padding: u32 = 0,
        }),

        /// endpoint 0 transmittal length
        R8_UEP0_T_LEN: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// offset 0x1
        _offset21: [1]u8,

        /// endpoint 0 control
        R8_UEP0_T_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X transmittal (IN)
            MASK_UEP_T_RES: u2 = 0,
            /// RB_UEP_T_TOG [2:2]
            /// prepared data toggle flag of USB endpoint X transmittal (IN): 0=DATA0, 1=DATA1
            RB_UEP_T_TOG: u1 = 0,
            /// RB_UEP_AUTO_TOG [3:3]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG: u1 = 0,
            /// padding [4:7]
            _padding: u4 = 0,
        }),

        /// endpoint 0 control
        R8_UEP0_R_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X receiving (OUT)
            MASK_UEP_R_RES: u2 = 0,
            /// RB_UEP_R_TOG [2:2]
            /// expected data toggle flag of USB endpoint X receiving (OUT): 0=DATA0, 1=DATA1
            RB_UEP_R_TOG: u1 = 0,
            /// RB_UEP_AUTO_TOG [3:3]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG: u1 = 0,
            /// padding [4:7]
            _padding: u4 = 0,
        }),

        /// endpoint 1 transmittal length
        R8_UEP1_T_LEN: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// offset 0x1
        _offset24: [1]u8,

        /// endpoint 1 control
        R8_UEP1_T_CTRL___USBHD_UH_SETUP: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X transmittal (IN)
            MASK_UEP_T_RES: u2 = 0,
            /// RB_UEP_T_TOG_ [2:2]
            /// prepared data toggle flag of USB endpoint X transmittal (IN): 0=DATA0, 1=DATA1
            RB_UEP_T_TOG_: u1 = 0,
            /// RB_UEP_AUTO_TOG [3:3]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG: u1 = 0,
            /// unused [4:5]
            _unused4: u2 = 0,
            /// RB_UH_SOF_EN [6:6]
            /// USB host automatic SOF enable
            RB_UH_SOF_EN: u1 = 0,
            /// RB_UH_PRE_PID_EN [7:7]
            /// USB host PRE PID enable for low speed device via hub
            RB_UH_PRE_PID_EN: u1 = 0,
        }),

        /// endpoint 1 control
        R8_UEP1_R_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X receiving (OUT)
            MASK_UEP_R_RES: u2 = 0,
            /// RB_UEP_R_TOG [2:2]
            /// expected data toggle flag of USB endpoint X receiving (OUT): 0=DATA0, 1=DATA1
            RB_UEP_R_TOG: u1 = 0,
            /// RB_UEP_AUTO_TOG [3:3]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG: u1 = 0,
            /// padding [4:7]
            _padding: u4 = 0,
        }),

        /// endpoint 2 transmittal length
        R8_UEP2_T_LEN__USBHD_UH_EP_PID: RegisterRW(packed struct(u8) {
            /// RB_UH_ENDP_MASK [0:3]
            /// bit mask of endpoint number for USB host transfer
            RB_UH_ENDP_MASK: u4 = 0,
            /// RB_UH_TOKEN_MASK [4:7]
            /// bit mask of token PID for USB host transfer
            RB_UH_TOKEN_MASK: u4 = 0,
        }),

        /// offset 0x1
        _offset27: [1]u8,

        /// endpoint 2 control
        R8_UEP2_T_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X transmittal (IN)
            MASK_UEP_T_RES: u2 = 0,
            /// RB_UEP_T_TOG_ [2:2]
            /// prepared data toggle flag of USB endpoint X transmittal (IN): 0=DATA0, 1=DATA1
            RB_UEP_T_TOG_: u1 = 0,
            /// RB_UEP_AUTO_TOG [3:3]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG: u1 = 0,
            /// padding [4:7]
            _padding: u4 = 0,
        }),

        /// endpoint 2 control
        R8_UEP2_R_CTRL__USBHD_UH_RX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES___RB_UH_R_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X receiving (OUT)
            MASK_UEP_R_RES___RB_UH_R_RES: u2 = 0,
            /// RB_UEP_R_TOG___RB_UH_R_TOG [2:2]
            /// expected data toggle flag of USB endpoint X receiving (OUT): 0=DATA0, 1=DATA1
            RB_UEP_R_TOG___RB_UH_R_TOG: u1 = 0,
            /// RB_UEP_AUTO_TOG___RB_UH_R_AUTO_TOG [3:3]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG___RB_UH_R_AUTO_TOG: u1 = 0,
            /// padding [4:7]
            _padding: u4 = 0,
        }),

        /// endpoint 3 transmittal length
        R8_UEP3_T_LEN__USBHD_UH_TX_LEN: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// offset 0x1
        _offset30: [1]u8,

        /// endpoint 3 control
        R8_UEP3_T_CTRL__USBHD_UH_TX_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES___RB_UH_T_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X transmittal (IN)
            MASK_UEP_T_RES___RB_UH_T_RES: u2 = 0,
            /// RB_UEP_T_TOG___RB_UH_T_TOG [2:2]
            /// prepared data toggle flag of USB endpoint X transmittal (IN): 0=DATA0, 1=DATA1
            RB_UEP_T_TOG___RB_UH_T_TOG: u1 = 0,
            /// RB_UEP_AUTO_TOG__RB_UH_T_AUTO_TOG [3:3]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG__RB_UH_T_AUTO_TOG: u1 = 0,
            /// padding [4:7]
            _padding: u4 = 0,
        }),

        /// endpoint 3 control
        R8_UEP3_R_CTRL_: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X receiving (OUT)
            MASK_UEP_R_RES: u2 = 0,
            /// RB_UEP_R_TOG [2:2]
            /// expected data toggle flag of USB endpoint X receiving (OUT): 0=DATA0, 1=DATA1
            RB_UEP_R_TOG: u1 = 0,
            /// RB_UEP_AUTO_TOG [3:3]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG: u1 = 0,
            /// padding [4:7]
            _padding: u4 = 0,
        }),

        /// endpoint 4 transmittal length
        R8_UEP4_T_LEN: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// offset 0x1
        _offset33: [1]u8,

        /// endpoint 4 control
        R8_UEP4_T_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X transmittal (IN)
            MASK_UEP_T_RES: u2 = 0,
            /// RB_UEP_T_TOG___RB_UH_T_TOG [2:2]
            /// prepared data toggle flag of USB endpoint X transmittal (IN): 0=DATA0, 1=DATA1
            RB_UEP_T_TOG___RB_UH_T_TOG: u1 = 0,
            /// RB_UEP_AUTO_TOG__RB_UH_T_AUTO_TOG [3:3]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG__RB_UH_T_AUTO_TOG: u1 = 0,
            /// padding [4:7]
            _padding: u4 = 0,
        }),

        /// endpoint 4 control
        R8_UEP4_R_CTRL_: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X receiving (OUT)
            MASK_UEP_R_RES: u2 = 0,
            /// RB_UEP_R_TOG [2:2]
            /// expected data toggle flag of USB endpoint X receiving (OUT): 0=DATA0, 1=DATA1
            RB_UEP_R_TOG: u1 = 0,
            /// RB_UEP_AUTO_TOG [3:3]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG: u1 = 0,
            /// padding [4:7]
            _padding: u4 = 0,
        }),

        /// endpoint 5 transmittal length
        R8_UEP5_T_LEN: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// offset 0x1
        _offset36: [1]u8,

        /// endpoint 5 control
        R8_UEP5_T_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X transmittal (IN)
            MASK_UEP_T_RES: u2 = 0,
            /// RB_UEP_T_TOG___RB_UH_T_TOG [2:2]
            /// prepared data toggle flag of USB endpoint X transmittal (IN): 0=DATA0, 1=DATA1
            RB_UEP_T_TOG___RB_UH_T_TOG: u1 = 0,
            /// RB_UEP_AUTO_TOG__RB_UH_T_AUTO_TOG [3:3]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG__RB_UH_T_AUTO_TOG: u1 = 0,
            /// padding [4:7]
            _padding: u4 = 0,
        }),

        /// endpoint 5 control
        R8_UEP5_R_CTRL_: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X receiving (OUT)
            MASK_UEP_R_RES: u2 = 0,
            /// RB_UEP_R_TOG [2:2]
            /// expected data toggle flag of USB endpoint X receiving (OUT): 0=DATA0, 1=DATA1
            RB_UEP_R_TOG: u1 = 0,
            /// RB_UEP_AUTO_TOG [3:3]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG: u1 = 0,
            /// padding [4:7]
            _padding: u4 = 0,
        }),

        /// endpoint 6 transmittal length
        R8_UEP6_T_LEN: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// offset 0x1
        _offset39: [1]u8,

        /// endpoint 6 control
        R8_UEP6_T_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X transmittal (IN)
            MASK_UEP_T_RES: u2 = 0,
            /// RB_UEP_T_TOG___RB_UH_T_TOG [2:2]
            /// prepared data toggle flag of USB endpoint X transmittal (IN): 0=DATA0, 1=DATA1
            RB_UEP_T_TOG___RB_UH_T_TOG: u1 = 0,
            /// RB_UEP_AUTO_TOG__RB_UH_T_AUTO_TOG [3:3]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG__RB_UH_T_AUTO_TOG: u1 = 0,
            /// padding [4:7]
            _padding: u4 = 0,
        }),

        /// endpoint 6 control
        R8_UEP6_R_CTRL_: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X receiving (OUT)
            MASK_UEP_R_RES: u2 = 0,
            /// RB_UEP_R_TOG [2:2]
            /// expected data toggle flag of USB endpoint X receiving (OUT): 0=DATA0, 1=DATA1
            RB_UEP_R_TOG: u1 = 0,
            /// RB_UEP_AUTO_TOG [3:3]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG: u1 = 0,
            /// padding [4:7]
            _padding: u4 = 0,
        }),

        /// endpoint 7 transmittal length
        R8_UEP7_T_LEN: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// offset 0x1
        _offset42: [1]u8,

        /// endpoint 7 control
        R8_UEP7_T_CTRL: RegisterRW(packed struct(u8) {
            /// MASK_UEP_T_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X transmittal (IN)
            MASK_UEP_T_RES: u2 = 0,
            /// RB_UEP_T_TOG___RB_UH_T_TOG [2:2]
            /// prepared data toggle flag of USB endpoint X transmittal (IN): 0=DATA0, 1=DATA1
            RB_UEP_T_TOG___RB_UH_T_TOG: u1 = 0,
            /// RB_UEP_AUTO_TOG__RB_UH_T_AUTO_TOG [3:3]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG__RB_UH_T_AUTO_TOG: u1 = 0,
            /// padding [4:7]
            _padding: u4 = 0,
        }),

        /// endpoint 7 control
        R8_UEP7_R_CTRL_: RegisterRW(packed struct(u8) {
            /// MASK_UEP_R_RES [0:1]
            /// bit mask of handshake response type for USB endpoint X receiving (OUT)
            MASK_UEP_R_RES: u2 = 0,
            /// RB_UEP_R_TOG [2:2]
            /// expected data toggle flag of USB endpoint X receiving (OUT): 0=DATA0, 1=DATA1
            RB_UEP_R_TOG: u1 = 0,
            /// RB_UEP_AUTO_TOG [3:3]
            /// enable automatic toggle after successful transfer completion on endpoint 1/2/3: 0=manual toggle, 1=automatic toggle
            RB_UEP_AUTO_TOG: u1 = 0,
            /// padding [4:7]
            _padding: u4 = 0,
        }),

        /// offset 0x4
        _offset44: [4]u8,

        /// usb otg control
        USB_OTG_CR: RegisterRW(packed struct(u32) {
            /// USB_OTG_CR_DISCHARGEVBUS [0:0]
            /// usb otg control
            USB_OTG_CR_DISCHARGEVBUS: u1 = 0,
            /// USB_OTG_CR_CHARGEVBUS [1:1]
            /// usb otg control
            USB_OTG_CR_CHARGEVBUS: u1 = 0,
            /// USB_OTG_CR_IDPU [2:2]
            /// usb otg control
            USB_OTG_CR_IDPU: u1 = 0,
            /// USB_OTG_CR_OTG_EN [3:3]
            /// usb otg control
            USB_OTG_CR_OTG_EN: u1 = 0,
            /// USB_OTG_CR_VBUS [4:4]
            /// usb otg control
            USB_OTG_CR_VBUS: u1 = 0,
            /// USB_OTG_CR_SESS [5:5]
            /// usb otg control
            USB_OTG_CR_SESS: u1 = 0,
            /// padding [6:31]
            _padding: u26 = 0,
        }),

        /// usb otg status
        USB_OTG_SR: RegisterRW(packed struct(u32) {
            /// USB_OTG_SR_VBUS_VLD [0:0]
            /// usb otg status
            USB_OTG_SR_VBUS_VLD: u1 = 0,
            /// USB_OTG_SR_SESS_VLD [1:1]
            /// usb otg status
            USB_OTG_SR_SESS_VLD: u1 = 0,
            /// USB_OTG_SR_SESS_END [2:2]
            /// usb otg status
            USB_OTG_SR_SESS_END: u1 = 0,
            /// USB_OTG_SR_ID_DIG [3:3]
            /// usb otg status
            USB_OTG_SR_ID_DIG: u1 = 0,
            /// padding [4:31]
            _padding: u28 = 0,
        }),
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
            /// INTENSTA12_31 [12:31]
            /// Interrupt ID Status
            INTENSTA12_31: u20 = 0,
        }),

        /// Interrupt Status Register
        ISR2: RegisterRW(packed struct(u32) {
            /// INTENSTA [0:31]
            /// Interrupt ID Status
            INTENSTA: u32 = 0,
        }),

        /// Interrupt Status Register
        ISR3: RegisterRW(packed struct(u32) {
            /// INTENSTA [0:31]
            /// Interrupt ID Status
            INTENSTA: u32 = 0,
        }),

        /// Interrupt Status Register
        ISR4: RegisterRW(packed struct(u32) {
            /// INTENSTA [0:7]
            /// Interrupt ID Status
            INTENSTA: u8 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }),

        /// offset 0x10
        _offset4: [16]u8,

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
            /// PENDSTA [0:31]
            /// PENDSTA
            PENDSTA: u32 = 0,
        }),

        /// Interrupt Pending Register
        IPR3: RegisterRW(packed struct(u32) {
            /// PENDSTA [0:31]
            /// PENDSTA
            PENDSTA: u32 = 0,
        }),

        /// Interrupt Pending Register
        IPR4: RegisterRW(packed struct(u32) {
            /// PENDSTA [0:7]
            /// PENDSTA
            PENDSTA: u8 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }),

        /// offset 0x10
        _offset8: [16]u8,

        /// Interrupt Priority Register
        ITHRESDR: RegisterRW(packed struct(u32) {
            /// THRESHOLD [0:7]
            /// THRESHOLD
            THRESHOLD: u8 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }),

        /// offset 0x4
        _offset9: [4]u8,

        /// Interrupt Config Register
        CFGR: RegisterRW(packed struct(u32) {
            /// unused [0:6]
            _unused0: u7 = 0,
            /// RESETSYS [7:7]
            /// RESETSYS
            RESETSYS: u1 = 0,
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

        /// ID Config Register
        VTFIDR: RegisterRW(packed struct(u32) {
            /// VTFID0 [0:7]
            /// VTFID0
            VTFID0: u8 = 0,
            /// VTFID1 [8:15]
            /// VTFID1
            VTFID1: u8 = 0,
            /// VTFID2 [16:23]
            /// VTFID2
            VTFID2: u8 = 0,
            /// VTFID3 [24:31]
            /// VTFID3
            VTFID3: u8 = 0,
        }),

        /// offset 0xc
        _offset12: [12]u8,

        /// Interrupt 0 address Register
        VTFADDRR0: RegisterRW(packed struct(u32) {
            /// VTF0EN [0:0]
            /// VTF0EN
            VTF0EN: u1 = 0,
            /// ADDR0 [1:31]
            /// ADDR0
            ADDR0: u31 = 0,
        }),

        /// Interrupt 1 address Register
        VTFADDRR1: RegisterRW(packed struct(u32) {
            /// VTF1EN [0:0]
            /// VTF1EN
            VTF1EN: u1 = 0,
            /// ADDR1 [1:31]
            /// ADDR1
            ADDR1: u31 = 0,
        }),

        /// Interrupt 2 address Register
        VTFADDRR2: RegisterRW(packed struct(u32) {
            /// VTF2EN [0:0]
            /// VTF2EN
            VTF2EN: u1 = 0,
            /// ADDR2 [1:31]
            /// ADDR2
            ADDR2: u31 = 0,
        }),

        /// Interrupt 3 address Register
        VTFADDRR3: RegisterRW(packed struct(u32) {
            /// VTF3EN [0:0]
            /// VTF3EN
            VTF3EN: u1 = 0,
            /// ADDR3 [1:31]
            /// ADDR3
            ADDR3: u31 = 0,
        }),

        /// offset 0x90
        _offset16: [144]u8,

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
            /// INTEN [0:31]
            /// INTEN
            INTEN: u32 = 0,
        }),

        /// Interrupt Setting Register
        IENR3: RegisterRW(packed struct(u32) {
            /// INTEN [0:31]
            /// INTEN
            INTEN: u32 = 0,
        }),

        /// Interrupt Setting Register
        IENR4: RegisterRW(packed struct(u32) {
            /// INTEN [0:7]
            /// INTEN
            INTEN: u8 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }),

        /// offset 0x70
        _offset20: [112]u8,

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
            /// INTRSET [0:31]
            /// INTRSET
            INTRSET: u32 = 0,
        }),

        /// Interrupt Clear Register
        IRER3: RegisterRW(packed struct(u32) {
            /// INTRSET [0:31]
            /// INTRSET
            INTRSET: u32 = 0,
        }),

        /// Interrupt Clear Register
        IRER4: RegisterRW(packed struct(u32) {
            /// INTRSET [0:7]
            /// INTRSET
            INTRSET: u8 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }),

        /// offset 0x70
        _offset24: [112]u8,

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
            /// PENDSET [0:31]
            /// PENDSET
            PENDSET: u32 = 0,
        }),

        /// Interrupt Pending Register
        IPSR3: RegisterRW(packed struct(u32) {
            /// PENDSET [0:31]
            /// PENDSET
            PENDSET: u32 = 0,
        }),

        /// Interrupt Pending Register
        IPSR4: RegisterRW(packed struct(u32) {
            /// PENDSET [0:7]
            /// PENDSET
            PENDSET: u8 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }),

        /// offset 0x70
        _offset28: [112]u8,

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
            /// PENDRESET [0:31]
            /// PENDRESET
            PENDRESET: u32 = 0,
        }),

        /// Interrupt Pending Clear Register
        IPRR3: RegisterRW(packed struct(u32) {
            /// PENDRESET [0:31]
            /// PENDRESET
            PENDRESET: u32 = 0,
        }),

        /// Interrupt Pending Clear Register
        IPRR4: RegisterRW(packed struct(u32) {
            /// PENDRESET [0:7]
            /// PENDRESET
            PENDRESET: u8 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }),

        /// offset 0x70
        _offset32: [112]u8,

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
            /// IACTS12_31 [12:31]
            /// IACTS
            IACTS12_31: u20 = 0,
        }),

        /// Interrupt ACTIVE Register
        IACTR2: RegisterRW(packed struct(u32) {
            /// IACTS [0:31]
            /// IACTS
            IACTS: u32 = 0,
        }),

        /// Interrupt ACTIVE Register
        IACTR3: RegisterRW(packed struct(u32) {
            /// IACTS [0:31]
            /// IACTS
            IACTS: u32 = 0,
        }),

        /// Interrupt ACTIVE Register
        IACTR4: RegisterRW(packed struct(u32) {
            /// IACTS [0:7]
            /// IACTS
            IACTS: u8 = 0,
            /// padding [8:31]
            _padding: u24 = 0,
        }),

        /// offset 0xf0
        _offset36: [240]u8,

        /// Interrupt Priority Register
        IPRIOR0: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR1: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR2: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR3: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR4: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR5: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR6: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR7: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR8: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR9: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR10: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR11: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR12: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR13: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR14: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR15: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR16: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR17: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR18: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR19: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR20: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR21: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR22: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR23: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR24: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR25: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR26: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR27: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR28: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR29: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR30: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR31: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR32: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR33: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR34: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR35: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR36: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR37: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR38: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR39: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR40: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR41: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR42: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR43: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR44: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR45: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR46: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR47: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR48: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR49: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR50: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR51: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR52: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR53: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR54: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR55: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR56: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR57: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR58: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR59: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR60: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR61: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR62: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR63: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR64: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR65: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR66: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR67: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR68: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR69: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR70: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR71: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR72: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR73: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR74: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR75: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR76: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR77: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR78: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR79: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR80: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR81: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR82: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR83: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR84: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR85: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR86: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR87: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR88: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR89: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR90: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR91: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR92: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR93: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR94: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR95: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR96: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR97: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR98: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR99: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR100: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR101: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR102: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR103: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR104: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR105: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR106: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR107: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR108: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR109: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR110: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR111: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR112: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR113: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR114: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR115: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR116: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR117: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR118: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR119: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR120: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR121: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR122: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR123: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR124: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR125: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR126: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR127: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR128: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR129: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR130: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR131: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR132: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR133: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR134: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR135: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR136: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR137: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR138: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR139: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR140: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR141: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR142: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR143: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR144: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR145: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR146: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR147: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR148: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR149: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR150: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR151: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR152: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR153: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR154: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR155: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR156: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR157: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR158: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR159: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR160: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR161: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR162: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR163: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR164: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR165: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR166: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR167: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR168: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR169: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR170: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR171: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR172: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR173: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR174: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR175: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR176: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR177: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR178: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR179: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR180: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR181: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR182: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR183: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR184: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR185: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR186: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR187: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR188: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR189: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR190: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR191: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR192: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR193: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR194: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR195: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR196: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR197: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR198: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR199: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR200: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR201: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR202: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR203: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR204: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR205: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR206: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR207: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR208: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR209: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR210: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR211: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR212: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR213: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR214: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR215: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR216: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR217: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR218: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR219: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR220: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR221: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR222: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR223: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR224: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR225: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR226: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR227: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR228: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR229: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR230: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR231: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR232: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR233: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR234: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR235: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR236: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR237: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR238: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR239: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR240: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR241: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR242: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR243: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR244: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR245: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR246: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR247: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR248: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR249: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR250: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR251: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR252: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR253: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR254: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// Interrupt Priority Register
        IPRIOR255: RegisterRW(packed struct(u8) {
            /// padding [0:7]
            _padding: u8 = 0,
        }),

        /// offset 0x810
        _offset292: [2064]u8,

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
            /// SYSRESET [31:31]
            /// SYSRESET
            SYSRESET: u1 = 0,
        }),

        /// offset 0x2ec
        _offset293: [748]u8,

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
        }),

        /// System START
        STK_SR: RegisterRW(packed struct(u32) {
            /// CNTIF [0:0]
            /// CNTIF
            CNTIF: u1 = 0,
            /// padding [1:31]
            _padding: u31 = 0,
        }),

        /// System counter low register
        STK_CNTL: RegisterRW(packed struct(u32) {
            /// CNTL [0:31]
            /// CNTL
            CNTL: u32 = 0,
        }),

        /// System counter high register
        STK_CNTH: RegisterRW(packed struct(u32) {
            /// CNTH [0:31]
            /// CNTH
            CNTH: u32 = 0,
        }),

        /// System compare low register
        STK_CMPLR: RegisterRW(packed struct(u32) {
            /// CMPL [0:31]
            /// CMPL
            CMPL: u32 = 0,
        }),

        /// System compare high register
        STK_CMPHR: RegisterRW(packed struct(u32) {
            /// CMPH [0:31]
            /// CMPH
            CMPH: u32 = 0,
        }),
    };
};

pub const interrupts = struct {
    pub const CAN2_SCE = 82;
    pub const DMA2_Channel10 = 102;
    pub const DMA1_Channel2 = 28;
    pub const DMA1_Channel7 = 33;
    pub const DMA2_Channel1 = 72;
    pub const DMA2_Channel5 = 76;
    pub const DMA2_Channel7 = 99;
    pub const TIM1_TRG_COM = 42;
    pub const USBHS = 85;
    pub const TIM9_UP_ = 91;
    pub const UART5 = 69;
    pub const TIM9_CC = 93;
    pub const TIM6 = 70;
    pub const CAN1_RX1 = 37;
    pub const DMA1_Channel1 = 27;
    pub const DMA2_Channel9 = 101;
    pub const DMA1_Channel3 = 29;
    pub const DMA2_Channel3 = 74;
    pub const USART3 = 55;
    pub const TIM7 = 71;
    pub const TIM8_TRG_COM = 61;
    pub const UART8 = 89;
    pub const DMA2_Channel2 = 73;
    pub const TIM4 = 46;
    pub const USB_LP_CAN1_RX0 = 36;
    pub const USART2 = 54;
    pub const CAN2_RX0 = 80;
    pub const PVD = 17;
    pub const TIM10_BRK = 94;
    pub const TAMPER = 18;
    pub const FLASH = 20;
    pub const SDIO = 65;
    pub const DMA1_Channel6 = 32;
    pub const DMA2_Channel6 = 98;
    pub const WWDG = 16;
    pub const USBHSWakeup = 84;
    pub const TIM2 = 44;
    pub const TIM8_BRK = 59;
    pub const TIM8_UP_ = 60;
    pub const TIM1_CC = 43;
    pub const I2C2_ER = 50;
    pub const RNG = 63;
    pub const USB_HP_CAN1_TX = 35;
    pub const SPI2 = 52;
    pub const EXTI0 = 22;
    pub const DMA1_Channel4 = 30;
    pub const DMA2_Channel8 = 100;
    pub const TIM9_BRK = 90;
    pub const TIM5 = 66;
    pub const CAN1_SCE = 38;
    pub const UART7 = 88;
    pub const OTG_FS = 83;
    pub const I2C1_ER = 48;
    pub const EXTI2 = 24;
    pub const RTCAlarm = 57;
    pub const TIM8_CC = 62;
    pub const TIM10_CC = 97;
    pub const I2C2_EV = 49;
    pub const RCC = 21;
    pub const DMA2_Channel11 = 103;
    pub const USBWakeUp = 58;
    pub const TIM10_UP_ = 95;
    pub const TIM1_BRK = 40;
    pub const TIM3 = 45;
    pub const ADC = 34;
    pub const SPI1 = 51;
    pub const SPI3 = 67;
    pub const EXTI4 = 26;
    pub const DMA1_Channel5 = 31;
    pub const ETH_WKUP = 78;
    pub const CAN2_TX = 79;
    pub const ETH = 77;
    pub const TIM1_UP_ = 41;
    pub const DMA2_Channel4 = 75;
    pub const TIM9_TRG_COM = 92;
    pub const EXTI9_5 = 39;
    pub const DVP = 86;
    pub const EXTI3 = 25;
    pub const RTC = 19;
    pub const EXTI1 = 23;
    pub const TIM10_TRG_COM = 96;
    pub const I2C1_EV = 47;
    pub const USART1 = 53;
    pub const CAN2_RX1 = 81;
    pub const UART4 = 68;
    pub const EXTI15_10 = 56;
    pub const UART6 = 87;
};
