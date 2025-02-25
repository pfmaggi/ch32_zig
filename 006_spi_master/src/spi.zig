const std = @import("std");

const RCC_APB2PRSTR: *volatile u32 = @ptrFromInt(0x4002100C);
const RCC_APB2PCENR: *volatile u32 = @ptrFromInt(0x40021018);
const GPIOC_CFGLR: *volatile u32 = @ptrFromInt(0x40011000);

pub const SPI1: SPI = @enumFromInt(0x40013000);

pub const Mode = enum {
    master,
    slave,
};

pub const Config = struct {
    mode: Mode,
};

pub const TransmitError = error{
    Timeout,
};

pub const ReceiveError = error{
    Timeout,
};

pub const SPI = enum(u32) {
    _,

    const CTLR1_offset = 0x00;
    const CTLR2_offset = 0x04;
    const STATR_offset = 0x08;
    const DATAR_offset = 0x0C;

    pub const DeadlineFn = fn () bool;

    pub fn simpleDeadline(count: u32) ?DeadlineFn {
        return struct {
            var counter = count;
            pub fn deadline() bool {
                counter -= 1;
                return counter == 0;
            }
        }.deadline;
    }

    fn ptr(self: SPI, offset: u32) *volatile u32 {
        return @ptrFromInt(@intFromEnum(self) + offset);
    }

    pub fn setup(comptime self: SPI, cfg: Config) void {
        self.setupPins(cfg);
        self.setupCtrl(cfg);
    }

    fn setupPins(comptime self: SPI, cfg: Config) void {
        if (self != SPI1) {
            @compileLog(@intFromEnum(self));
            @compileLog(SPI1);
            @compileError("SPI not supported");
        }

        // SPI1 reset.
        RCC_APB2PRSTR.* |= @as(u32, 1 << 12);
        RCC_APB2PRSTR.* = 0;

        // Enable Port C clock.
        RCC_APB2PCENR.* |= @as(u32, 1 << 4);
        // Enable SPI1 clock.
        RCC_APB2PCENR.* |= @as(u32, 1 << 12);

        if (cfg.mode == .master) {
            // NSS - PC1 - Not used.

            // SCK - PC5 - Push-pull multiplexed output.
            // Clear all bits
            GPIOC_CFGLR.* &= ~@as(u32, 0b1111 << 4 * 5);
            // Mode 01: Output max 10MHz
            // CNF 10: Multiplexed Push-Pull
            GPIOC_CFGLR.* |= @as(u32, 0b10_01 << 4 * 5);

            // MOSI - PC6 - Push-pull multiplexed output.
            // Clear all bits
            GPIOC_CFGLR.* &= ~@as(u32, 0b1111 << 4 * 6);
            // Mode 01: Output max 10MHz
            // CNF 10: Multiplexed Push-Pull
            GPIOC_CFGLR.* |= @as(u32, 0b10_01 << 4 * 6);

            // MISO - PC7 - Floating input or pull-up input.
            // Clear all bits
            GPIOC_CFGLR.* &= ~@as(u32, 0b1111 << 4 * 7);
            // Mode 00: Input
            // CNF 01: Floating
            GPIOC_CFGLR.* |= @as(u32, 0b01_00 << 4 * 7);
        }
    }

    fn setupCtrl(comptime self: SPI, cfg: Config) void {
        _ = cfg;

        const SPI_CTLR1: *volatile u32 = self.ptr(CTLR1_offset);
        const SPI_CTLR2: *volatile u32 = self.ptr(CTLR2_offset);

        // Reset.
        SPI_CTLR1.* = 0;
        var v: u32 = 0;
        // BR: Baund rate control.
        // BR[2:0] = 011: fPCLK/16
        v |= @as(u32, 0b011 << 3);
        // DEF: Data frame format.
        // DEF = 0: 8-bit data frame format.
        // DEF = 1: 16-bit data frame format.
        // SPI_CTLR1.* |= @as(u32, 1 << 11);
        // LSBFIRST: Frame format control bit.
        // LSBFIRST = 0: The data transfer starts from the MSB bit.
        // LSBFIRST = 1: The data transfer starts from the LSB bit.
        // SPI_CTLR1.* |= @as(u32, 1 << 7);
        // MSTR: Master-slave select.
        // MSTR = 0: Slave.
        // MSTR = 1: Master.
        v |= @as(u32, 1 << 2);
        // SSM: Software slave management.
        // SSM = 0: Hardware control of the NSS pin.
        // SSM = 1: Software control of the NSS pin.
        // v |= @as(u32, 1 << 9);
        // SSI: Internal slave select.
        // SSI = 0: NSS is low.
        // SSI = 1: NSS is high.
        // v |= @as(u32, 1 << 8);

        SPI_CTLR1.* = v;

        // Reset.
        SPI_CTLR2.* = 0;

        // SPE: SPI enable.
        SPI_CTLR1.* |= @as(u32, 1 << 6);
    }

    pub inline fn isReadable(self: SPI) bool {
        const SPI_STATR: *volatile u32 = self.ptr(STATR_offset);
        const RXNE = 0;
        return (SPI_STATR.* >> RXNE) & 1 == 1;
    }

    pub inline fn isWriteable(self: SPI) bool {
        const SPI_STATR: *volatile u32 = self.ptr(STATR_offset);
        const TXE = 1;
        return (SPI_STATR.* >> TXE) & 1 == 1;
    }

    pub inline fn isBusy(self: SPI) bool {
        const SPI_STATR: *volatile u32 = self.ptr(STATR_offset);
        const BSY = 7;
        return (SPI_STATR.* >> BSY) & 1 == 1;
    }

    pub noinline fn writeBlocking(self: SPI, payload: []const u8, deadlineFn: ?DeadlineFn) TransmitError!usize {
        const SPI_DATAR: *volatile u32 = self.ptr(DATAR_offset);

        var offset: usize = 0;
        while (offset < payload.len) {
            while (!self.isWriteable()) {
                if (deadlineFn) |deadline| {
                    if (deadline()) {
                        if (offset > 0) {
                            return offset;
                        }

                        return error.Timeout;
                    }
                }
                asm volatile ("" ::: "memory");
            }
            SPI_DATAR.* = (SPI_DATAR.* & ~@as(u32, 0xFF)) | payload[offset];
            offset += 1;

            while (self.isBusy()) {
                if (deadlineFn) |deadline| {
                    if (deadline()) {
                        if (offset > 0) {
                            return offset;
                        }

                        return error.Timeout;
                    }
                }
                asm volatile ("" ::: "memory");
            }
        }

        return offset;
    }
};
