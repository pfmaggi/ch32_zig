const std = @import("std");
const builtin = @import("builtin");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const AutoHashMap = std.AutoHashMap;
const warn = std.debug.warn;

pub const DeduplMap = std.StringHashMap(u32);

/// Top Level
pub const Device = struct {
    name: ArrayList(u8),
    version: ArrayList(u8),
    description: ArrayList(u8),
    cpu: ?Cpu,

    /// Bus Interface Properties
    /// Smallest addressable unit in bits
    address_unit_bits: ?u32,

    /// The Maximum data bit width accessible within a single transfer
    max_bit_width: ?u32,

    /// Start register default properties
    reg_default_size: ?u32,
    reg_default_reset_value: ?u32,
    reg_default_reset_mask: ?u32,
    peripherals: Peripherals,
    interrupts: Interrupts,

    allocator: Allocator,

    const Self = @This();

    pub fn init(allocator: Allocator) !Self {
        var name = ArrayList(u8).init(allocator);
        errdefer name.deinit();
        var version = ArrayList(u8).init(allocator);
        errdefer version.deinit();
        var description = ArrayList(u8).init(allocator);
        errdefer description.deinit();
        var peripherals = Peripherals.init(allocator);
        errdefer peripherals.deinit();
        var interrupts = Interrupts.init(allocator);
        errdefer interrupts.deinit();

        return Self{
            .name = name,
            .version = version,
            .description = description,
            .cpu = null,
            .address_unit_bits = null,
            .max_bit_width = null,
            .reg_default_size = null,
            .reg_default_reset_value = null,
            .reg_default_reset_mask = null,
            .peripherals = peripherals,
            .interrupts = interrupts,

            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.name.deinit();
        self.version.deinit();
        self.description.deinit();
        self.peripherals.deinit();
        self.interrupts.deinit();
    }

    pub fn format(self: Self, comptime _: []const u8, _: std.fmt.FormatOptions, out_stream: anytype) !void {
        const name = if (self.name.items.len == 0) "unknown" else self.name.items;
        const version = if (self.version.items.len == 0) "unknown" else self.version.items;
        const description = if (self.description.items.len == 0) "unknown" else self.description.items;

        try out_stream.print(
            \\pub const device_name = "{s}";
            \\pub const device_revision = "{s}";
            \\pub const device_description = "{s}";
            \\
        , .{ name, version, description });
        if (self.cpu) |the_cpu| {
            try out_stream.print("{}\n", .{the_cpu});
        }

        var padded_writer = PaddedWriter.init("    ", out_stream);
        var padded_out_stream = padded_writer.writer();

        try out_stream.writeAll(
            \\
            \\pub const peripherals = struct {
        );

        var dedupl = DeduplMap.init(self.allocator);
        defer dedupl.deinit();

        for (self.peripherals.items) |peripheral| {
            // Skip generate for derived peripherals.
            if (peripheral.derived_from.items.len > 0) {
                continue;
            }

            try peripheral.write_instance(padded_out_stream, &dedupl);
        }

        try out_stream.writeAll(
            \\};
            \\
            \\pub const types = struct {
        );

        dedupl.clearAndFree();

        for (self.peripherals.items) |peripheral| {
            // Skip generate for derived peripherals.
            if (peripheral.derived_from.items.len > 0) {
                continue;
            }

            try peripheral.write_type(padded_out_stream, &dedupl);
        }

        try out_stream.writeAll("};\n");

        // now print interrupt table
        try out_stream.writeAll("\npub const interrupts = struct {\n");
        var iter = self.interrupts.iterator();
        while (iter.next()) |entry| {
            const interrupt = entry.value_ptr.*;
            if (interrupt.value) |int_value| {
                try padded_out_stream.print(
                    "pub const {s} = {};\n",
                    .{ interrupt.name.items, int_value },
                );
            }
        }
        try out_stream.writeAll("};");
        return;
    }
};

pub const Cpu = struct {
    name: ArrayList(u8),
    revision: ArrayList(u8),
    endian: ArrayList(u8),
    mpu_present: ?bool,
    fpu_present: ?bool,
    nvic_prio_bits: ?u32,
    vendor_systick_config: ?bool,

    const Self = @This();

    pub fn init(allocator: Allocator) !Self {
        var name = ArrayList(u8).init(allocator);
        errdefer name.deinit();
        var revision = ArrayList(u8).init(allocator);
        errdefer revision.deinit();
        var endian = ArrayList(u8).init(allocator);
        errdefer endian.deinit();

        return Self{
            .name = name,
            .revision = revision,
            .endian = endian,
            .mpu_present = null,
            .fpu_present = null,
            .nvic_prio_bits = null,
            .vendor_systick_config = null,
        };
    }

    pub fn deinit(self: *Self) void {
        self.name.deinit();
        self.revision.deinit();
        self.endian.deinit();
    }

    pub fn format(self: Self, comptime _: []const u8, _: std.fmt.FormatOptions, out_stream: anytype) !void {
        try out_stream.writeAll("\n");

        const name = if (self.name.items.len == 0) "unknown" else self.name.items;
        const revision = if (self.revision.items.len == 0) "unknown" else self.revision.items;
        const endian = if (self.endian.items.len == 0) "unknown" else self.endian.items;
        const mpu_present = self.mpu_present orelse false;
        const fpu_present = self.mpu_present orelse false;
        const vendor_systick_config = self.vendor_systick_config orelse false;
        try out_stream.print(
            \\pub const cpu = struct {{
            \\    pub const name = "{s}";
            \\    pub const revision = "{s}";
            \\    pub const endian = "{s}";
            \\    pub const mpu_present = {};
            \\    pub const fpu_present = {};
            \\    pub const vendor_systick_config = {};
            \\
        , .{ name, revision, endian, mpu_present, fpu_present, vendor_systick_config });
        if (self.nvic_prio_bits) |prio_bits| {
            try out_stream.print(
                \\    pub const nvic_prio_bits = {};
                \\
            , .{prio_bits});
        }
        try out_stream.writeAll("};");
        return;
    }
};

pub const Peripherals = ArrayList(Peripheral);

pub const Peripheral = struct {
    name: ArrayList(u8),
    group_name: ArrayList(u8),
    description: ArrayList(u8),
    derived_from: ArrayList(u8),
    derived_peripherals: Peripherals,
    base_address: ?u32,
    address_block: ?AddressBlock,
    registers: Registers,

    allocator: Allocator,

    const Self = @This();

    pub fn init(allocator: Allocator) !Self {
        var name = ArrayList(u8).init(allocator);
        errdefer name.deinit();
        var group_name = ArrayList(u8).init(allocator);
        errdefer group_name.deinit();
        var description = ArrayList(u8).init(allocator);
        errdefer description.deinit();
        var derived_from = ArrayList(u8).init(allocator);
        errdefer derived_from.deinit();
        var derived_peripherals = Peripherals.init(allocator);
        errdefer derived_peripherals.deinit();
        var registers = Registers.init(allocator);
        errdefer registers.deinit();

        return Self{
            .name = name,
            .group_name = group_name,
            .description = description,
            .derived_from = derived_from,
            .derived_peripherals = derived_peripherals,
            .base_address = null,
            .address_block = null,
            .registers = registers,

            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.name.deinit();
        self.group_name.deinit();
        self.description.deinit();
        self.derived_from.deinit();
        self.derived_peripherals.deinit();
        self.registers.deinit();
    }

    pub fn isValid(self: Self) bool {
        if (self.name.items.len == 0) {
            return false;
        }
        _ = self.base_address orelse return false;

        return true;
    }

    fn registersSortCompare(_: void, left: Register, right: Register) bool {
        if (left.address_offset != null and right.address_offset != null) {
            if (left.address_offset.? < right.address_offset.?) {
                return true;
            }
            if (left.address_offset.? > right.address_offset.?) {
                return false;
            }
        } else if (left.address_offset == null) {
            return true;
        }

        return false;
    }

    fn writeOffsetRegister(num: usize, first_unused: u32, last_unused: u32, out_stream: anytype) !void {
        const size = last_unused - first_unused;
        try out_stream.print("\n/// offset 0x{x}\n", .{size});
        try out_stream.print("_offset{}: [{}]u8,\n", .{ num, size });
    }

    fn generateCommonName(self: Self, dedupl: *DeduplMap) !struct { []u8, bool } {
        const name = self.name.items;
        const description = self.description.items;

        var common_name = ArrayList(u8).init(self.allocator);
        var has_common_name = false;

        // Handle special case for timers
        const timer_name, const has_timer_name = if (std.mem.eql(u8, "Advanced timer", description))
            .{ "AdvancedTimer", true }
        else if (std.mem.eql(u8, "General purpose timer", description))
            .{ "GeneralPurposeTimer", true }
        else if (std.mem.eql(u8, "Basic timer", description))
            .{ "BasicTimer", true }
        else
            .{ "", false };
        if (has_timer_name) {
            try common_name.replaceRange(0, common_name.items.len, timer_name);
            has_common_name = true;
        }

        const common_prefixes = [_][]const u8{ "USART", "GPIO", "UART", "CAN", "I2C", "SPI" };
        for (common_prefixes) |prefix| {
            if (std.mem.startsWith(u8, name, prefix)) {
                try common_name.replaceRange(0, common_name.items.len, prefix);
                has_common_name = true;
                break;
            }
        }

        if (!has_common_name) {
            return .{ common_name.items, has_common_name };
        }

        // Because a HashMap is used, we should not free the memory occupied by
        // common_name(otherwise it will cause a panic), so it is necessary to
        // consciously allow a memory leak. But this is not a problem, as we use
        // ArenaAllocator and the application has a very short lifespan.
        if (dedupl.get(common_name.items)) |v| {
            try dedupl.put(common_name.items, v + 1);
            try common_name.appendSlice(try std.fmt.allocPrint(self.allocator, "_{}", .{v + 1}));
        } else {
            try dedupl.put(common_name.items, 1);
        }

        return .{ common_name.items, has_common_name };
    }

    pub fn write_instance(self: Self, out_stream: anytype, dedupl: *DeduplMap) !void {
        try out_stream.writeAll("\n");
        if (!self.isValid()) {
            try out_stream.writeAll("// Not enough info to print peripheral value\n");
            return;
        }

        const name = self.name.items;
        const common_name, const has_common_name = try self.generateCommonName(dedupl);

        const description = if (self.description.items.len == 0) "No description" else self.description.items;
        try out_stream.print(
            \\/// {s}
            \\
        , .{description});

        if (self.derived_peripherals.items.len > 0 or has_common_name) {
            var periph_name = ArrayList(u8).init(self.allocator);
            defer periph_name.deinit();

            if (has_common_name) {
                try periph_name.replaceRange(0, periph_name.items.len, common_name);
            } else {
                try periph_name.replaceRange(0, periph_name.items.len, name);
                try periph_name.append('x');
            }

            try out_stream.print(
                \\pub const {s} = enum(u32) {{
                \\
            , .{periph_name.items});

            try out_stream.print(
                \\    {s} = 0x{x},
                \\
            , .{ name, self.base_address.? });

            for (self.derived_peripherals.items) |peripheral| {
                const derived_name = peripheral.name.items;
                try out_stream.print(
                    \\    {s} = 0x{x},
                    \\
                , .{ derived_name, peripheral.base_address.? });
            }

            try out_stream.print(
                \\
                \\    pub inline fn addr(self: {s}) u32 {{
                \\        return @intFromEnum(self);
                \\    }}
                \\
                \\    pub inline fn get(self: {s}) *volatile types.{s} {{
                \\        return types.{s}.from(self.addr());
                \\    }}
                \\
                \\    pub inline fn from(address: u32) {s} {{
                \\        return types.{s}.from(address);
                \\    }}
                \\}};
                \\
            , .{ periph_name.items, periph_name.items, periph_name.items, periph_name.items, periph_name.items, periph_name.items });

            try out_stream.print(
                \\/// {s}
                \\pub const {s} = {s}.{s}.get();
            , .{ description, name, periph_name.items, name });

            for (self.derived_peripherals.items) |peripheral| {
                const derived_name = peripheral.name.items;
                const derived_description = if (peripheral.description.items.len == 0) description else peripheral.description.items;
                try out_stream.print(
                    \\
                    \\/// {s}
                    \\pub const {s} = {s}.{s}.get();
                , .{ derived_description, derived_name, periph_name.items, derived_name });
            }
        } else {
            try out_stream.print(
                \\pub const {s} = types.{s}.from(0x{x});
            , .{ name, name, self.base_address.? });
        }
        try out_stream.writeAll("\n");
    }

    pub fn write_type(self: Self, out_stream: anytype, dedupl: *DeduplMap) !void {
        try out_stream.writeAll("\n");
        if (!self.isValid()) {
            try out_stream.writeAll("// Not enough info to print peripheral value\n");
            return;
        }

        const name = self.name.items;
        const common_name, const has_common_name = try self.generateCommonName(dedupl);

        const description = if (self.description.items.len == 0) "No description" else self.description.items;
        try out_stream.print(
            \\/// {s}
            \\
        , .{description});

        var periph_name = ArrayList(u8).init(self.allocator);
        defer periph_name.deinit();
        if (has_common_name) {
            try periph_name.replaceRange(0, periph_name.items.len, common_name);
        } else {
            try periph_name.replaceRange(0, periph_name.items.len, name);
        }

        if (has_common_name) {
            try out_stream.writeAll("/// Type for: ");

            try out_stream.print("{s} ", .{name});
            for (self.derived_peripherals.items) |peripheral| {
                try out_stream.print("{s} ", .{peripheral.name.items});
            }

            try out_stream.writeAll("\n");
        }

        try out_stream.print(
            \\pub const {s} = extern struct {{
            \\    pub fn from(base: u32) *volatile types.{s} {{
            \\        return @ptrFromInt(base);
            \\    }}
            \\
            \\    pub fn addr(self: *volatile types.{s}) u32 {{
            \\        return @intFromPtr(self);
            \\    }}
            \\
        , .{ periph_name.items, periph_name.items, periph_name.items });

        // Sort registers by address offset for next step
        std.sort.heap(Register, self.registers.items, {}, registersSortCompare);

        var padded_writer = PaddedWriter.init("    ", out_stream);
        var padded_out_stream = padded_writer.writer();

        var last_uncovered_offset: u32 = 0;
        for (self.registers.items, 0..) |register, i| {
            if (register.alternate_register.items.len > 0) {
                // FIXME: use union?
                continue;
            }

            if (register.address_offset == null) {
                try padded_out_stream.writeAll("// Not enough info to print register\n");
                return;
            }

            const address_offset = register.address_offset.?;
            if (last_uncovered_offset != address_offset) {
                try writeOffsetRegister(i, last_uncovered_offset, address_offset, padded_out_stream);
            }

            try padded_out_stream.print("{}\n", .{register});
            last_uncovered_offset = address_offset + register.size / 8;
        }

        // and close the peripheral
        try out_stream.print("}};\n", .{});

        return;
    }
};

pub const AddressBlock = struct {
    offset: ?u32,
    size: ?u32,
    usage: ArrayList(u8),

    const Self = @This();

    pub fn init(allocator: Allocator) !Self {
        var usage = ArrayList(u8).init(allocator);
        errdefer usage.deinit();

        return Self{
            .offset = null,
            .size = null,
            .usage = usage,
        };
    }

    pub fn deinit(self: *Self) void {
        self.usage.deinit();
    }
};

pub const Interrupts = AutoHashMap(u32, Interrupt);

pub const Interrupt = struct {
    name: ArrayList(u8),
    description: ArrayList(u8),
    value: ?u32,

    const Self = @This();

    pub fn init(allocator: Allocator) !Self {
        var name = ArrayList(u8).init(allocator);
        errdefer name.deinit();
        var description = ArrayList(u8).init(allocator);
        errdefer description.deinit();

        return Self{
            .name = name,
            .description = description,
            .value = null,
        };
    }

    pub fn copy(self: Self, allocator: Allocator) !Self {
        var the_copy = try Self.init(allocator);

        try the_copy.name.append(self.name.items);
        try the_copy.description.append(self.description.items);
        the_copy.value = self.value;

        return the_copy;
    }

    pub fn deinit(self: *Self) void {
        self.name.deinit();
        self.description.deinit();
    }

    pub fn isValid(self: Self) bool {
        if (self.name.items.len == 0) {
            return false;
        }
        _ = self.value orelse return false;

        return true;
    }

    pub fn format(self: Self, comptime _: []const u8, _: std.fmt.FormatOptions, out_stream: anytype) !void {
        try out_stream.writeAll("\n");
        if (!self.isValid()) {
            try out_stream.writeAll("// Not enough info to print interrupt value\n");
            return;
        }
        const name = self.name.items;
        const description = if (self.description.items.len == 0) "No description" else self.description.items;
        try out_stream.print(
            \\/// {s}
            \\pub const {s} = {s};
            \\
        , .{ description, name, self.value.? });
    }
};

const Registers = ArrayList(Register);

pub const Register = struct {
    periph_containing: ArrayList(u8),
    name: ArrayList(u8),
    display_name: ArrayList(u8),
    description: ArrayList(u8),
    alternate_register: ArrayList(u8),
    address_offset: ?u32,
    size: u32,
    reset_value: u32,
    fields: Fields,

    access: Access = .ReadWrite,

    const Self = @This();

    pub fn init(allocator: Allocator, periph: []const u8, reset_value: u32, size: u32) !Self {
        var prefix = ArrayList(u8).init(allocator);
        errdefer prefix.deinit();
        try prefix.appendSlice(periph);
        var name = ArrayList(u8).init(allocator);
        errdefer name.deinit();
        var display_name = ArrayList(u8).init(allocator);
        errdefer display_name.deinit();
        var description = ArrayList(u8).init(allocator);
        errdefer description.deinit();
        var alternate_register = ArrayList(u8).init(allocator);
        errdefer alternate_register.deinit();
        var fields = Fields.init(allocator);
        errdefer fields.deinit();

        return Self{
            .periph_containing = prefix,
            .name = name,
            .display_name = display_name,
            .description = description,
            .alternate_register = alternate_register,
            .address_offset = null,
            .size = size,
            .reset_value = reset_value,
            .fields = fields,
        };
    }

    pub fn deinit(self: *Self) void {
        self.periph_containing.deinit();
        self.name.deinit();
        self.display_name.deinit();
        self.description.deinit();
        self.alternate_register.deinit();

        self.fields.deinit();
    }

    pub fn isValid(self: Self) bool {
        if (self.name.items.len == 0) {
            return false;
        }
        _ = self.address_offset orelse return false;

        return true;
    }

    fn fieldsSortCompare(_: void, left: Field, right: Field) bool {
        if (left.bit_offset != null and right.bit_offset != null) {
            if (left.bit_offset.? < right.bit_offset.?) {
                return true;
            }
            if (left.bit_offset.? > right.bit_offset.?) {
                return false;
            }
        } else if (left.bit_offset == null) {
            return true;
        }

        return false;
    }

    fn alignedEndOfUnusedChunk(chunk_start: u32, last_unused: u32) u32 {
        // Next multiple of 8 from chunk_start + 1
        const next_multiple = (chunk_start + 8) & ~@as(u32, 7);
        return @min(next_multiple, last_unused);
    }

    fn writeUnusedField(first_unused: u32, last_unused: u32, reg_reset_value: u32, out_stream: anytype) !void {
        // Fill unused bits between two fields
        // TODO: right now we have to manually chunk unused bits to 8-bit boundaries as a workaround
        // to this bug https://github.com/ziglang/zig/issues/2627
        var chunk_start = first_unused;
        var chunk_end = alignedEndOfUnusedChunk(chunk_start, last_unused);
        try out_stream.print("\n/// unused [{}:{}]", .{ first_unused, last_unused - 1 });
        while (chunk_start < last_unused) : ({
            chunk_start = chunk_end;
            chunk_end = alignedEndOfUnusedChunk(chunk_start, last_unused);
        }) {
            try out_stream.writeAll("\n");
            const chunk_width = chunk_end - chunk_start;
            const unused_value = Field.fieldResetValue(chunk_start, chunk_width, reg_reset_value);

            try out_stream.print("_unused{}: u{} = {},", .{ chunk_start, chunk_width, unused_value });
        }
    }

    fn alignedEndOfPaddingChunk(chunk_start: u32, last_unused: u32) u32 {
        // Next multiple of 32 from chunk_start + 1
        const next_multiple = (chunk_start + 32) & ~@as(u32, 31);
        return @min(next_multiple, last_unused);
    }

    fn writePaddingField(first_unused: u32, last_unused: u32, reg_reset_value: u32, out_stream: anytype) !void {
        const chunk_start = first_unused;
        const chunk_end = alignedEndOfPaddingChunk(chunk_start, last_unused);
        try out_stream.print("\n/// padding [{}:{}]", .{ first_unused, last_unused - 1 });
        try out_stream.writeAll("\n");
        const chunk_width = chunk_end - chunk_start;
        const unused_value = Field.fieldResetValue(chunk_start, chunk_width, reg_reset_value);

        try out_stream.print("_padding: u{} = {},", .{ chunk_width, unused_value });
    }

    pub fn format(self: Self, comptime _: []const u8, _: std.fmt.FormatOptions, out_stream: anytype) !void {
        try out_stream.writeAll("\n");
        if (!self.isValid()) {
            try out_stream.writeAll("// Not enough info to print register value\n");
            return;
        }
        const name = self.name.items;
        // const periph = self.periph_containing.items;
        const description = if (self.description.items.len == 0) "No description" else self.description.items;
        // print packed struct containing fields
        try out_stream.print(
            \\/// {s}
            \\{s}: RegisterRW(packed struct(u{}) {{
        , .{ description, name, self.size });

        // Sort fields from LSB to MSB for next step
        std.sort.heap(Field, self.fields.items, {}, fieldsSortCompare);

        var padded_writer = PaddedWriter.init("    ", out_stream);
        var padded_out_stream = padded_writer.writer();

        var last_uncovered_bit: u32 = 0;
        for (self.fields.items) |field| {
            if ((field.bit_offset == null) or (field.bit_width == null)) {
                try padded_out_stream.writeAll("// Not enough info to print register\n");
                return;
            }

            const bit_offset = field.bit_offset.?;
            const bit_width = field.bit_width.?;
            if (last_uncovered_bit != bit_offset) {
                try writeUnusedField(last_uncovered_bit, bit_offset, self.reset_value, padded_out_stream);
            }

            try padded_out_stream.print("{}", .{field});
            last_uncovered_bit = bit_offset + bit_width;
        }

        // Check if we need padding at the end
        if (last_uncovered_bit != self.size) {
            try writePaddingField(last_uncovered_bit, self.size, self.reset_value, padded_out_stream);
        }

        // close the struct and init the register
        try out_stream.print(
            \\
            \\}}),
        , .{});

        return;
    }
};

pub const Access = enum {
    ReadOnly,
    WriteOnly,
    ReadWrite,
};

pub const Fields = ArrayList(Field);

pub const Field = struct {
    periph: ArrayList(u8),
    register: ArrayList(u8),
    register_reset_value: u32,
    name: ArrayList(u8),
    description: ArrayList(u8),
    bit_offset: ?u32,
    bit_width: ?u32,

    access: Access = .ReadWrite,

    const Self = @This();

    pub fn init(allocator: Allocator, periph_containing: []const u8, register_containing: []const u8, register_reset_value: u32) !Self {
        var periph = ArrayList(u8).init(allocator);
        try periph.appendSlice(periph_containing);
        errdefer periph.deinit();
        var register = ArrayList(u8).init(allocator);
        try register.appendSlice(register_containing);
        errdefer register.deinit();
        var name = ArrayList(u8).init(allocator);
        errdefer name.deinit();
        var description = ArrayList(u8).init(allocator);
        errdefer description.deinit();

        return Self{
            .periph = periph,
            .register = register,
            .register_reset_value = register_reset_value,
            .name = name,
            .description = description,
            .bit_offset = null,
            .bit_width = null,
        };
    }

    pub fn copy(self: Self, allocator: Allocator) !Self {
        var the_copy = try Self.init(allocator, self.periph.items, self.register.items, self.register_reset_value);

        try the_copy.name.appendSlice(self.name.items);
        try the_copy.description.appendSlice(self.description.items);
        the_copy.bit_offset = self.bit_offset;
        the_copy.bit_width = self.bit_width;
        the_copy.access = self.access;

        return the_copy;
    }

    pub fn deinit(self: *Self) void {
        self.periph.deinit();
        self.register.deinit();
        self.name.deinit();
        self.description.deinit();
    }

    pub fn fieldResetValue(bit_start: u32, bit_width: u32, reg_reset_value: u32) u32 {
        const shifted_reset_value = reg_reset_value >> @as(u5, @intCast(bit_start));
        const reset_value_mask = @as(u32, @intCast((@as(u33, 1) << @as(u6, @intCast(bit_width))) - 1));

        return shifted_reset_value & reset_value_mask;
    }

    pub fn format(self: Self, comptime _: []const u8, _: std.fmt.FormatOptions, out_stream: anytype) !void {
        try out_stream.writeAll("\n");
        if (self.name.items.len == 0) {
            try out_stream.writeAll("// No name to print field value\n");
            return;
        }
        if ((self.bit_offset == null) or (self.bit_width == null)) {
            try out_stream.writeAll("// Not enough info to print field\n");
            return;
        }
        const name = self.name.items;
        const description = if (self.description.items.len == 0) "No description" else self.description.items;
        const start_bit = self.bit_offset.?;
        const end_bit = (start_bit + self.bit_width.? - 1);
        const bit_width = self.bit_width.?;
        const reg_reset_value = self.register_reset_value;
        const reset_value = fieldResetValue(start_bit, bit_width, reg_reset_value);
        try out_stream.print(
            \\/// {s} [{}:{}]
            \\/// {s}
            \\{s}: u{} = {},
        , .{
            name,
            start_bit,
            end_bit,
            // description
            description,
            // val
            name,
            bit_width,
            reset_value,
        });
        return;
    }
};

const PaddedWriter = struct {
    pub fn init(indent: []const u8, out_writer: anytype) Self {
        return .{ .indent = indent, .out_writer = out_writer };
    }

    indent: []const u8,
    out_writer: std.io.AnyWriter,
    needs_indent: bool = true,

    const Self = @This();

    pub fn writer(self: *Self) std.io.AnyWriter {
        return .{ .context = self, .writeFn = anyWriterFn };
    }

    pub fn reset(self: *Self) void {
        self.needs_indent = true;
    }

    fn anyWriterFn(context: *const anyopaque, buffer: []const u8) anyerror!usize {
        const self: *Self = @constCast(@alignCast(@ptrCast(context)));
        return self.writerFn(buffer);
    }

    fn writerFn(self: *Self, buffer: []const u8) anyerror!usize {
        var count: usize = 0;
        var new_buffer = buffer;

        while (new_buffer.len > 0) {
            const maybe_idx = std.mem.indexOf(u8, new_buffer, "\n");

            const out = self.out_writer;

            if (self.needs_indent and (maybe_idx == null or maybe_idx.? > 0)) {
                var index: usize = 0;
                while (index != self.indent.len) {
                    index += try out.write(self.indent[index..]);
                }

                self.needs_indent = false;
            }

            const idx = maybe_idx orelse {
                count += try out.write(new_buffer);
                return count;
            };

            const idx_after = idx + 1;
            count += try out.write(new_buffer[0..idx_after]);

            self.needs_indent = true;
            new_buffer = new_buffer[idx_after..];
        }

        return count;
    }
};

test "Field print" {
    const allocator = std.testing.allocator;
    const fieldDesiredPrint =
        \\
        \\/// RNGEN [2:2]
        \\/// RNGEN comment
        \\RNGEN: u1 = 1,
        \\
    ;

    var output_buffer = ArrayList(u8).init(allocator);
    defer output_buffer.deinit();
    var buf_stream = output_buffer.writer();

    var field = try Field.init(allocator, "PERIPH", "RND", 0b101);
    defer field.deinit();

    try field.name.appendSlice("RNGEN");
    try field.description.appendSlice("RNGEN comment");
    field.bit_offset = 2;
    field.bit_width = 1;

    try buf_stream.print("{}\n", .{field});
    try std.testing.expectEqualStrings(fieldDesiredPrint, output_buffer.items);
}

test "Register Print" {
    const allocator = std.testing.allocator;
    const registerDesiredPrint =
        \\
        \\/// RND comment
        \\RND: RegisterRW(packed struct(u32) {
        \\    /// unused [0:1]
        \\    _unused0: u2 = 1,
        \\    /// RNGEN [2:2]
        \\    /// RNGEN comment
        \\    RNGEN: u1 = 1,
        \\    /// unused [3:9]
        \\    _unused3: u5 = 0,
        \\    _unused8: u2 = 0,
        \\    /// SEED [10:12]
        \\    /// SEED comment
        \\    SEED: u3 = 0,
        \\    /// padding [13:31]
        \\    _padding: u19 = 0,
        \\}),
        \\
    ;

    var output_buffer = ArrayList(u8).init(allocator);
    defer output_buffer.deinit();
    var buf_stream = output_buffer.writer();

    var register = try Register.init(allocator, "PERIPH", 0b101, 0x20);
    defer register.deinit();
    try register.name.appendSlice("RND");
    try register.description.appendSlice("RND comment");
    register.address_offset = 0x100;
    register.size = 0x20;

    var field = try Field.init(allocator, "PERIPH", "RND", 0b101);
    defer field.deinit();

    try field.name.appendSlice("RNGEN");
    try field.description.appendSlice("RNGEN comment");
    field.bit_offset = 2;
    field.bit_width = 1;
    field.access = .ReadWrite; // write field will exist

    var field2 = try Field.init(allocator, "PERIPH", "RND", 0b101);
    defer field2.deinit();

    try field2.name.appendSlice("SEED");
    try field2.description.appendSlice("SEED comment");
    field2.bit_offset = 10;
    field2.bit_width = 3;
    field2.access = .ReadWrite;

    try register.fields.append(field);
    try register.fields.append(field2);

    try buf_stream.print("{}\n", .{register});
    try std.testing.expectEqualStrings(registerDesiredPrint, output_buffer.items);
}

test "Peripheral Print" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const peripheralDesiredPrint =
        \\
        \\/// PERIPH comment
        \\pub const PERIPH = extern struct {
        \\    pub fn from(base: u32) *volatile types.PERIPH {
        \\        return @ptrFromInt(base);
        \\    }
        \\
        \\    /// offset 0x100
        \\    _offset0: [256]u8,
        \\
        \\    /// RND comment
        \\    RND: RegisterRW(packed struct(u32) {
        \\        /// unused [0:1]
        \\        _unused0: u2 = 1,
        \\        /// RNGEN [2:2]
        \\        /// RNGEN comment
        \\        RNGEN: u1 = 1,
        \\        /// unused [3:9]
        \\        _unused3: u5 = 0,
        \\        _unused8: u2 = 0,
        \\        /// SEED [10:12]
        \\        /// SEED comment
        \\        SEED: u3 = 0,
        \\        /// padding [13:31]
        \\        _padding: u19 = 0,
        \\    }),
        \\};
        \\
    ;

    var output_buffer = ArrayList(u8).init(allocator);
    defer output_buffer.deinit();
    const buf_stream = output_buffer.writer().any();

    var peripheral = try Peripheral.init(allocator);
    defer peripheral.deinit();
    try peripheral.name.appendSlice("PERIPH");
    try peripheral.description.appendSlice("PERIPH comment");
    peripheral.base_address = 0x24000;

    var register = try Register.init(allocator, "PERIPH", 0b101, 0x20);
    defer register.deinit();
    try register.name.appendSlice("RND");
    try register.description.appendSlice("RND comment");
    register.address_offset = 0x100;
    register.size = 0x20;

    var field = try Field.init(allocator, "PERIPH", "RND", 0b101);
    defer field.deinit();

    try field.name.appendSlice("RNGEN");
    try field.description.appendSlice("RNGEN comment");
    field.bit_offset = 2;
    field.bit_width = 1;
    field.access = .ReadOnly; // since only register, write field will not exist

    var field2 = try Field.init(allocator, "PERIPH", "RND", 0b101);
    defer field2.deinit();

    try field2.name.appendSlice("SEED");
    try field2.description.appendSlice("SEED comment");
    field2.bit_offset = 10;
    field2.bit_width = 3;
    field2.access = .ReadWrite;

    try register.fields.append(field);
    try register.fields.append(field2);

    try peripheral.registers.append(register);

    var dedupl = DeduplMap.init(allocator);
    defer dedupl.deinit();

    try peripheral.write_type(buf_stream, &dedupl);
    try std.testing.expectEqualStrings(peripheralDesiredPrint, output_buffer.items);
}

fn bitWidthToMask(width: u32) u32 {
    const max_supported_bits = 32;
    const width_to_mask = blk: {
        const mask_array: [max_supported_bits + 1]u32 = undefined;
        inline for (mask_array, 0..) |*item, i| {
            const i_use = if (i == 0) max_supported_bits else i;
            // This is needed to support both Zig 0.7 and 0.8
            const int_type_info =
                if (@hasField(builtin.TypeInfo.Int, "signedness"))
                    .{ .signedness = .unsigned, .bits = i_use }
                else
                    .{ .is_signed = false, .bits = i_use };

            item.* = std.math.maxInt(@Type(builtin.TypeInfo{ .Int = int_type_info }));
        }
        break :blk mask_array;
    };
    const width_to_mask_slice = width_to_mask[0..];

    return width_to_mask_slice[if (width > max_supported_bits) 0 else width];
}
