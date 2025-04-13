const std = @import("std");
const config = @import("config");
const svd = @import("svd");

const hal = @import("hal.zig");
const RCC = svd.peripherals.RCC;
const DMA1 = svd.peripherals.DMA1;
const DMA2 = svd.peripherals.DMA2;

pub const Channel = union(enum) {
    dma1: Dma1Channel,
    dma2: Dma2Channel,

    pub fn enable(comptime self: Channel) void {
        const DMA = ChannelRegister.from(self);
        DMA.CFGR.modify(.{ .EN = 1 });
    }

    pub fn disable(comptime self: Channel) void {
        const DMA = ChannelRegister.from(self);
        DMA.CFGR.modify(.{ .EN = 0 });
    }

    pub fn reset(comptime self: Channel) void {
        const DMA = ChannelRegister.from(self);

        // Disable.
        DMA.CFGR.modify(.{ .EN = 0 });

        // Zero out the registers.
        DMA.CFGR.raw = 0;
        DMA.CNTR.raw = 0;
        DMA.PADDR.raw = 0;
        DMA.MADDR.raw = 0;

        // Clear flags.
        Interrupt.clearAll(self);
    }

    pub fn configure(comptime dma: Channel, comptime cfg: Config) void {
        switch (dma) {
            .dma1 => {
                RCC.AHBPCENR.modify(.{ .DMA1EN = 1, .SRAMEN = 1 });
            },
            .dma2 => {
                RCC.AHBPCENR.modify(.{ .DMA2EN = 1, .SRAMEN = 1 });
            },
        }

        const DMA = ChannelRegister.from(dma);
        DMA.CFGR.write(.{
            .DIR = @intFromEnum(cfg.direction),
            .CIRC = @intFromEnum(cfg.mode),
            .PINC = if (cfg.periph_inc) 1 else 0,
            .MINC = if (cfg.mem_inc) 1 else 0,
            .PSIZE = @intFromEnum(cfg.periph_data_size),
            .MSIZE = @intFromEnum(cfg.mem_data_size),
            .PL = @intFromEnum(cfg.priority),
            .MEM2MEM = if (cfg.mem_to_mem) 1 else 0,
        });
        if (cfg.data_length != 0) {
            DMA.CNTR.raw = cfg.data_length;
        }
        if (cfg.periph_ptr) |ptr| {
            DMA.PADDR.raw = @intFromPtr(ptr);
        }
        if (cfg.mem_ptr) |ptr| {
            DMA.MADDR.raw = @intFromPtr(ptr);
        }
    }

    /// Set the memory pointer. Length is optional.
    pub fn setMemoryPtr(comptime self: Channel, pointer: anytype, length: ?u32) void {
        const DMA = ChannelRegister.from(self);
        DMA.MADDR.raw = @intFromPtr(pointer);
        if (length) |len| {
            DMA.CNTR.raw = len;
        }
    }

    /// Set the peripheral pointer. Length is optional.
    pub fn setPeripheralPtr(comptime self: Channel, pointer: anytype, length: ?u32) void {
        const DMA = ChannelRegister.from(self);
        DMA.PADDR.raw = @intFromPtr(pointer);
        if (length) |len| {
            DMA.CNTR.raw = len;
        }
    }

    pub fn getRemaining(comptime self: Channel) u32 {
        const DMA = ChannelRegister.from(self);
        return DMA.CNTR.raw;
    }
};

pub const Interrupt = enum {
    /// Transfer complete interrupt.
    transfer_complete,
    /// Half transfer complete interrupt.
    half_transfer_complete,
    /// Transfer error interrupt.
    transfer_error,

    pub fn enable(comptime dma: Channel, comptime irq: Interrupt) void {
        enableInternal(dma, irq, 1);

        const irq_name = switch (dma) {
            .dma1 => |ch| "DMA1_Channel" ++ std.fmt.comptimePrint("{}", .{@intFromEnum(ch)}),
            .dma2 => |ch| "DMA2_Channel" ++ std.fmt.comptimePrint("{}", .{@intFromEnum(ch)}),
        };

        hal.interrupts.enable(std.meta.stringToEnum(svd.interrupts, irq_name).?);
    }

    pub fn disable(comptime dma: Channel, irq: Interrupt) void {
        enableInternal(dma, irq, 0);
    }

    fn enableInternal(comptime dma: Channel, irq: Interrupt, value: u1) void {
        const DMA = ChannelRegister.from(dma);
        switch (irq) {
            .transfer_complete => {
                DMA.CFGR.modify(.{ .TCIE = value });
            },
            .half_transfer_complete => {
                DMA.CFGR.modify(.{ .HTIE = value });
            },
            .transfer_error => {
                DMA.CFGR.modify(.{ .TEIE = value });
            },
        }
    }

    pub const Flags = struct {
        /// Global interrupt flag.
        global: bool,
        /// Transfer complete flag.
        transfer_complete: bool,
        /// Half transfer complete flag.
        half_transfer_complete: bool,
        /// Transfer error flag.
        transfer_error: bool,
    };

    pub fn status(comptime dma: Channel) Flags {
        const DMA, const ch = switch (dma) {
            .dma1 => |ch| .{ DMA1, ch },
            .dma2 => |ch| .{ DMA2, ch },
        };
        const ch_str = std.fmt.comptimePrint("{}", .{@intFromEnum(ch)});

        const flags = DMA.INTFR;
        return .{
            .global = @field(flags, "GIF" ++ ch_str),
            .transfer_complete = @field(flags, "TCIF" ++ ch_str),
            .half_transfer_complete = @field(flags, "HTIF" ++ ch_str),
            .transfer_error = @field(flags, "TEIF" ++ ch_str),
        };
    }

    pub const ClearFlag = enum {
        /// Clear global interrupt flag.
        global,
        /// Clear transfer complete flag.
        transfer_complete,
        /// Clear half transfer complete flag.
        half_transfer_complete,
        /// Clear transfer error flag.
        transfer_error,
    };

    pub fn clear(comptime dma: Channel, comptime flag: ClearFlag) void {
        const DMA, const ch = switch (dma) {
            .dma1 => |ch| .{ DMA1, ch },
            .dma2 => |ch| .{ DMA2, ch },
        };
        const ch_str = std.fmt.comptimePrint("{}", .{@intFromEnum(ch)});

        const name = comptime switch (flag) {
            .global => "CGIF" ++ ch_str,
            .transfer_complete => "CTCIF" ++ ch_str,
            .half_transfer_complete => "CHTIF" ++ ch_str,
            .transfer_error => "CTEIF" ++ ch_str,
        };

        var reg = DMA.INTFCR.default();
        @field(reg, name) = 1;
        DMA.INTFCR.write(reg);
    }

    pub fn clearAll(comptime dma: Channel) void {
        const DMA, const ch = switch (dma) {
            .dma1 => |ch| .{ DMA1, ch },
            .dma2 => |ch| .{ DMA2, ch },
        };
        const ch_str = std.fmt.comptimePrint("{}", .{@intFromEnum(ch)});

        const flag_names = &.{ "CGIF", "CTCIF", "CHTIF", "CTEIF" };
        var flags = DMA.INTFCR.read();
        inline for (flag_names) |flag| {
            @field(flags, flag ++ ch_str) = 0;
        }
        DMA.INTFCR.write(flags);
    }
};

pub const Dma1Channel = enum(u4) {
    channel1 = 1,
    channel2 = 2,
    channel3 = 3,
    channel4 = 4,
    channel5 = 5,
    channel6 = 6,
    channel7 = 7,
};

pub const Dma2Channel = enum(u4) {
    channel1 = 1,
    channel2 = 2,
    channel3 = 3,
    channel4 = 4,
    channel5 = 5,
    channel6 = 6,
    channel7 = 7,
    channel8 = 8,
    channel9 = 9,
    channel10 = 10,
    channel11 = 11,
};

/// DMA configuration options.
pub const Config = struct {
    /// Peripheral pointer. Can be configured later through setPeripheralPtr().
    /// Use @volatileCast() for converting peripheral pointer to anyopaque.
    periph_ptr: ?*anyopaque = null,
    /// Memory pointer. Can be configured later through setMemoryPtr().
    /// Use @constCast() for converting pointer to anyopaque.
    mem_ptr: ?*anyopaque = null,
    /// Direction of data transfer.
    direction: Direction,
    /// Data length. Can be configured later.
    data_length: u32 = 0,
    /// Peripheral increment mode.
    periph_inc: bool,
    /// Memory increment mode.
    mem_inc: bool,
    /// Peripheral data size.
    periph_data_size: Size,
    /// Memory data size.
    mem_data_size: Size,
    /// Transfer mode. Normal or circular.
    mode: Mode = .normal,
    /// Priority level.
    priority: Priority,
    /// Memory to memory mode.
    mem_to_mem: bool = false,
};

/// Transfer mode.
pub const Mode = enum(u1) {
    /// Normal mode.
    normal = 0,
    /// Circular mode.
    circular = 1,
};

/// Direction of data transfer.
pub const Direction = enum(u1) {
    /// From peripheral to memory.
    periph_to_mem = 0,
    /// From memory to peripheral.
    mem_to_periphh = 1,
};

/// Size of data transfer.
pub const Size = enum(u2) {
    /// 8 bits.
    byte = 0b00,
    /// 16 bits.
    half_word = 0b01,
    /// 32 bits.
    word = 0b10,
};

/// Priority level of DMA transfer.
pub const Priority = enum(u2) {
    /// Low priority.
    low = 0b00,
    /// Medium priority.
    medium = 0b01,
    /// High priority.
    high = 0b10,
    /// Very high priority.
    very_high = 0b11,
};

const ChannelRegister = extern struct {
    pub inline fn from(comptime dma: Channel) *volatile ChannelRegister {
        const DMA, const ch = switch (dma) {
            .dma1 => |ch| .{ DMA1, ch },
            .dma2 => |ch| .{ DMA2, ch },
        };
        const ch_str = std.fmt.comptimePrint("{}", .{@intFromEnum(ch)});
        // Get channel offset from the DMA peripheral.
        const ch_offset = @offsetOf(@TypeOf(DMA.*), "CFGR" ++ ch_str);
        return @ptrFromInt(DMA.addr() + ch_offset);
    }

    pub inline fn addr(self: *volatile ChannelRegister) u32 {
        return @intFromPtr(self);
    }

    /// DMA channel configuration register (DMA_CFGR)
    CFGR: svd.RegisterRW(svd.types.DMA1.CFGRx, svd.nullable_types.DMA1.CFGRx),
    /// DMA channel number of data register
    CNTR: svd.RegisterRW(svd.types.DMA1.CNTRx, svd.nullable_types.DMA1.CNTRx),
    /// DMA channel peripheral address register
    PADDR: svd.RegisterRW(svd.types.DMA1.PADDRx, svd.nullable_types.DMA1.PADDRx),
    /// DMA channel memory address register
    MADDR: svd.RegisterRW(svd.types.DMA1.MADDRx, svd.nullable_types.DMA1.MADDRx),
};

test "ChannelRegister offsets" {
    if (config.chip.series != .ch32v30x) {
        return error.SkipZigTest;
    }

    try std.testing.expectEqual(0x40020008, ChannelRegister.from(.{ .dma1 = .channel1 }).addr());
    try std.testing.expectEqual(0x40020058, ChannelRegister.from(.{ .dma1 = .channel5 }).addr());
    try std.testing.expectEqual(0x40020080, ChannelRegister.from(.{ .dma1 = .channel7 }).addr());

    try std.testing.expectEqual(0x40020408, ChannelRegister.from(.{ .dma2 = .channel1 }).addr());
    try std.testing.expectEqual(0x40020458, ChannelRegister.from(.{ .dma2 = .channel5 }).addr());
    try std.testing.expectEqual(0x40020480, ChannelRegister.from(.{ .dma2 = .channel7 }).addr());
    try std.testing.expectEqual(0x40020490, ChannelRegister.from(.{ .dma2 = .channel8 }).addr());
    try std.testing.expectEqual(0x400204A0, ChannelRegister.from(.{ .dma2 = .channel9 }).addr());
    try std.testing.expectEqual(0x400204B0, ChannelRegister.from(.{ .dma2 = .channel10 }).addr());
    try std.testing.expectEqual(0x400204C0, ChannelRegister.from(.{ .dma2 = .channel11 }).addr());
}
