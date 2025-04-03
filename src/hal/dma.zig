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
        enableInternal(self, 1);
    }

    pub fn disable(comptime self: Channel) void {
        enableInternal(self, 0);
    }

    pub fn reset(comptime self: Channel) void {
        const v = switch (self) {
            .dma1 => |ch| .{ DMA1, ch },
            .dma2 => |ch| .{ DMA2, ch },
        };
        const DMA = v[0];
        const ch = v[1];
        const ch_str = std.fmt.comptimePrint("{}", .{@intFromEnum(ch)});

        // Zero out the registers.
        @field(DMA, "CFGR" ++ ch_str).raw = 0;
        @field(DMA, "CNTR" ++ ch_str).raw = 0;
        @field(DMA, "PADDR" ++ ch_str).raw = 0;
        @field(DMA, "MADDR" ++ ch_str).raw = 0;

        // Clear flags.
        const flag_names = comptime &.{ "CGIF", "CTCIF", "CHTIF", "CTEIF" };
        var flags = DMA.INTFCR.read();
        inline for (flag_names) |flag| {
            @field(flags, flag ++ ch_str) = 0;
        }
        DMA.INTFCR.write(flags);
    }

    pub fn configure(comptime dma: Channel, comptime cfg: Config) void {
        switch (dma) {
            .dma1 => |ch| {
                RCC.AHBPCENR.modify(.{ .DMA1EN = 1, .SRAMEN = 1 });
                configureInternal(DMA1, @intFromEnum(ch), cfg);
            },
            .dma2 => |ch| {
                RCC.AHBPCENR.modify(.{ .DMA2EN = 1, .SRAMEN = 1 });
                configureInternal(DMA2, @intFromEnum(ch), cfg);
            },
        }
    }

    pub fn setMemoryPtr(comptime self: Channel, ptr: *anyopaque, length: ?u32) void {
        const v = switch (self) {
            .dma1 => |ch| .{ DMA1, ch },
            .dma2 => |ch| .{ DMA2, ch },
        };
        const DMA = v[0];
        const ch = v[1];
        const ch_str = std.fmt.comptimePrint("{}", .{@intFromEnum(ch)});

        @field(DMA, "MADDR" ++ ch_str).raw = @intFromPtr(ptr);
        if (length) |len| {
            @field(DMA, "CNTR" ++ ch_str).raw = len;
        }
    }

    pub fn setPeripheralPtr(comptime self: Channel, ptr: *anyopaque, length: ?u32) void {
        const v = switch (self) {
            .dma1 => |ch| .{ DMA1, ch },
            .dma2 => |ch| .{ DMA2, ch },
        };
        const DMA = v[0];
        const ch = v[1];
        const ch_str = std.fmt.comptimePrint("{}", .{@intFromEnum(ch)});

        @field(DMA, "PADDR" ++ ch_str).raw = @intFromPtr(ptr);
        if (length) |len| {
            @field(DMA, "CNTR" ++ ch_str).raw = len;
        }
    }

    pub fn getRemaining(comptime self: Channel) u32 {
        const v = switch (self) {
            .dma1 => |ch| .{ DMA1, ch },
            .dma2 => |ch| .{ DMA2, ch },
        };
        const DMA = v[0];
        const ch = v[1];
        const ch_str = std.fmt.comptimePrint("{}", .{@intFromEnum(ch)});

        return @field(DMA, "CNTR" ++ ch_str).raw;
    }
};

pub const Interrupts = enum {
    /// Transfer complete interrupt.
    transfer_complete,
    /// Half transfer complete interrupt.
    half_transfer_complete,
    /// Transfer error interrupt.
    transfer_error,

    /// Enabled interrupt for the DMA channel.
    pub fn enable(comptime dma: Channel, comptime irq: Interrupts) void {
        enableInterruptsInternal(dma, irq, 1);

        const irq_name = switch (dma) {
            .dma1 => |ch| "DMA1_Channel" ++ std.fmt.comptimePrint("{}", .{@intFromEnum(ch)}),
            .dma2 => |ch| "DMA2_Channel" ++ std.fmt.comptimePrint("{}", .{@intFromEnum(ch)}),
        };

        hal.interrupts.enable(std.meta.stringToEnum(svd.interrupts, irq_name).?);
    }

    /// Disabled interrupt for the DMA channel.
    pub fn disable(comptime dma: Channel, irq: Interrupts) void {
        enableInterruptsInternal(dma, irq, 0);
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
        const v = switch (dma) {
            .dma1 => |ch| .{ DMA1, ch },
            .dma2 => |ch| .{ DMA2, ch },
        };
        const DMA = v[0];
        const ch = v[1];
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
        const v = switch (dma) {
            .dma1 => |ch| .{ DMA1, ch },
            .dma2 => |ch| .{ DMA2, ch },
        };
        const DMA = v[0];
        const ch = v[1];
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
    /// Peripheral pointer. Can be configured later.
    periph_ptr: ?*anyopaque = null,
    /// Memory pointer. Can be configured later.
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

inline fn enableInternal(comptime dma: Channel, comptime value: u1) void {
    const v = switch (dma) {
        .dma1 => |ch| .{ DMA1, ch },
        .dma2 => |ch| .{ DMA2, ch },
    };

    const DMA = v[0];
    const ch = v[1];
    const ch_str = std.fmt.comptimePrint("{}", .{@intFromEnum(ch)});

    @field(DMA, "CFGR" ++ ch_str).modify(.{ .EN = value });
}

inline fn configureInternal(comptime DMA: anytype, ch_num: u4, comptime cfg: Config) void {
    const ch_str = std.fmt.comptimePrint("{}", .{ch_num});

    const pre_reg_cfg = svd.nullable_types.DMA1.CFGR1{
        .DIR = @intFromEnum(cfg.direction),
        .CIRC = @intFromEnum(cfg.mode),
        .PINC = if (cfg.periph_inc) 1 else 0,
        .MINC = if (cfg.mem_inc) 1 else 0,
        .PSIZE = @intFromEnum(cfg.periph_data_size),
        .MSIZE = @intFromEnum(cfg.mem_data_size),
        .PL = @intFromEnum(cfg.priority),
        .MEM2MEM = if (cfg.mem_to_mem) 1 else 0,
    };

    @field(DMA, "CFGR" ++ ch_str).writeAny(pre_reg_cfg);

    if (cfg.data_length != 0) {
        @field(DMA, "CNTR" ++ ch_str).raw = cfg.data_length;
    }
    if (cfg.periph_ptr) |ptr| {
        @field(DMA, "PADDR" ++ ch_str).raw = @intFromPtr(ptr);
    }
    if (cfg.mem_ptr) |ptr| {
        @field(DMA, "MADDR" ++ ch_str).raw = @intFromPtr(ptr);
    }
}

fn enableInterruptsInternal(comptime dma: Channel, irq: Interrupts, value: u1) void {
    const v = switch (dma) {
        .dma1 => |ch| .{ DMA1, ch },
        .dma2 => |ch| .{ DMA2, ch },
    };
    const DMA = v[0];
    const ch = v[1];
    const ch_str = std.fmt.comptimePrint("{}", .{@intFromEnum(ch)});

    switch (irq) {
        .transfer_complete => {
            @field(DMA, "CFGR" ++ ch_str).modify(.{ .TCIE = value });
        },
        .half_transfer_complete => {
            @field(DMA, "CFGR" ++ ch_str).modify(.{ .HTIE = value });
        },
        .transfer_error => {
            @field(DMA, "CFGR" ++ ch_str).modify(.{ .TEIE = value });
        },
    }
}
