const std = @import("std");

const RCC_APB2PRSTR: *volatile u32 = @ptrFromInt(0x4002100C);
const RCC_APB2PCENR: *volatile u32 = @ptrFromInt(0x40021018);
const GPIOC_CFGLR: *volatile u32 = @ptrFromInt(0x40011000);

pub const SPI1: SPI = @bitCast(@as(u32, 0x40013000));

pub const Mode = enum {
    master,
    slave,
};

pub const Config = struct {
    mode: Mode,
};

pub const SPI = packed struct(u32) {
    addr: u32,

    const CTLR1_offset = 0x00;
    const CTLR2_offset = 0x04;
    const STATR_offset = 0x08;
    const DATAR_offset = 0x0C;

    fn ptr(self: SPI, offset: u32) *volatile u32 {
        return @ptrFromInt(self.addr + offset);
    }

    pub fn configure(comptime self: SPI, comptime cfg: Config) void {
        self.configurePins(cfg);
        self.configureCtrl(cfg);
    }

    fn configurePins(comptime self: SPI, comptime cfg: Config) void {
        if (self != SPI1) {
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
        } else {
            @compileError("SPI slave mode not implemented");
        }
    }

    fn configureCtrl(comptime self: SPI, comptime cfg: Config) void {
        _ = cfg;

        const SPI_CTLR1: *volatile u32 = self.ptr(CTLR1_offset);
        const SPI_CTLR2: *volatile u32 = self.ptr(CTLR2_offset);

        // Reset.
        SPI_CTLR1.* = 0;
        SPI_CTLR2.* = 0;

        // BR: Baund rate control.
        // BR[2:0] = 011: fPCLK/16
        SPI_CTLR1.* |= @as(u32, 0b011) << 3;

        // SSM: Software slave management.
        // SSM = 0: Hardware control of the NSS pin.
        // SSM = 1: Software control of the NSS pin.
        SPI_CTLR1.* |= @as(u32, 1) << 9;

        // SSI: Internal slave select. Required for master mode.
        // SSI = 0: NSS is low.
        // SSI = 1: NSS is high.
        SPI_CTLR1.* |= @as(u32, 1 << 8);

        // MSTR: Master-slave select.
        // MSTR = 0: Slave.
        // MSTR = 1: Master.
        SPI_CTLR1.* |= @as(u32, 1) << 2;

        // DFF: Data frame format.
        // DFF = 0: 8-bit data frame format.
        // DFF = 1: 16-bit data frame format.
        SPI_CTLR1.* &= ~(@as(u32, 1) << 11);
        // SPI_CTLR1.* |= @as(u32, 1) << 11;

        // SPE: SPI enable.
        SPI_CTLR1.* |= @as(u32, 1 << 6);
    }

    pub inline fn isWriteable(self: SPI) bool {
        const SPI_STATR: *volatile u32 = self.ptr(STATR_offset);
        const TXE = @as(u32, 1) << 1;
        return (SPI_STATR.* & TXE) != 0;
    }

    pub inline fn isBusy(self: SPI) bool {
        const SPI_STATR: *volatile u32 = self.ptr(STATR_offset);
        const BSY = @as(u32, 1) << 7;
        return (SPI_STATR.* & BSY) != 0;
    }

    pub noinline fn writeBlocking(self: SPI, payload: []const u8) usize {
        const SPI_DATAR: *volatile u32 = self.ptr(DATAR_offset);

        var offset: usize = 0;
        while (offset < payload.len) {
            while (!self.isWriteable()) {
                asm volatile ("" ::: "memory");
            }

            SPI_DATAR.* = (SPI_DATAR.* & ~@as(u32, 0xFF)) | payload[offset];
            offset += 1;

            while (self.isBusy()) {
                asm volatile ("" ::: "memory");
            }
        }

        return offset;
    }
};
