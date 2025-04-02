const std = @import("std");
const config = @import("config");
const svd = @import("svd");

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
        // TODO: interrupts
        .TCIE = 0,
        .HTIE = 0,
        .TEIE = 0,
        .DIR = @intFromEnum(cfg.direction),
        .CIRC = @intFromEnum(cfg.mode),
        .PINC = if (cfg.periph_inc) 1 else 0,
        .MINC = if (cfg.mem_inc) 1 else 0,
        .PSIZE = @intFromEnum(cfg.periph_data_size),
        .MSIZE = @intFromEnum(cfg.mem_data_size),
        .PL = @intFromEnum(cfg.priority),
        .MEM2MEM = if (cfg.mem_to_mem) 1 else 0,
    };

    // Copy the configuration from the pre_reg_cfg to the reg_cfg.
    comptime var reg_cfg = @field(DMA, "CFGR" ++ ch_str).default();
    inline for (@typeInfo(@TypeOf(pre_reg_cfg)).@"struct".fields) |field| {
        if (@field(pre_reg_cfg, field.name)) |v| {
            @field(reg_cfg, field.name) = v;
        }
    }

    @field(DMA, "CFGR" ++ ch_str).write(@bitCast(reg_cfg));

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
