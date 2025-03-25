const std = @import("std");
const config = @import("config");
const svd = @import("svd");

pub const DMDATA0: *volatile u32 = @ptrFromInt(isCpuQingkeV2(0xe00000f4, 0xe0000380));
pub const DMDATA1: *volatile u32 = @ptrFromInt(isCpuQingkeV2(0xe00000f8, 0xe0000384));
// Reads as 0x00000000 if debugger is attached.
const DMSTATUS_SENTINEL: *volatile u32 = @ptrFromInt(isCpuQingkeV2(0xe00000fc, 0xe0000388));

fn isCpuQingkeV2(yes: comptime_int, no: comptime_int) comptime_int {
    if (config.chip_series == .ch32v003) {
        return yes;
    }

    return no;
}

pub fn didDebuggerAttach() bool {
    return DMSTATUS_SENTINEL.* == 0;
}

pub const sdi_print = struct {
    pub fn isBufferFree() bool {
        return (DMDATA0.* & 0x80) == 0;
    }

    pub fn enable() void {
        DMDATA0.* = 0x00;
        DMDATA1.* = 0x80;
        var timeout: u32 = 100_000;
        while (timeout > 0) : (timeout -= 1) {
            // ZIG please don't optimize this loop away.
            asm volatile ("" ::: "memory");
        }
    }

    /// Transfer data to and from the debug print buffer.
    /// Example:
    /// ```zig
    ///     // Print and read from debug print.
    ///     var recvBuf: [32]u8 = undefined;
    ///     var len = hal.debug.transfer("Hello Debug Print: ", &recvBuf);
    ///     len += hal.debug.transfer(intToStr(&buffer, count), recvBuf[len..]);
    ///     len += hal.debug.transfer("\r\n", recvBuf[len..]);
    ///     if (len > 0) {
    ///         _ = try USART1.writeBlocking("Debug recv: ", null);
    ///         _ = try USART1.writeBlocking(recvBuf[0..len], null);
    ///         _ = try USART1.writeBlocking("\r\n", null);
    ///     }
    /// ```
    pub fn transfer(send: ?[]const u8, recv: ?[]u8) usize {
        // Timeout.
        if ((DMDATA0.* & 0xc0) == 0xc0) return 0;

        var last_dmd = DMDATA0.*;

        if (send) |send_buf| {
            var recv_len: usize = 0;
            var timeout: u32 = 100_000;
            var buffer: [8]u8 = undefined;

            // Split send_buf into 7 byte chunks.
            var win = std.mem.window(u8, send_buf, 7, 7);
            while (win.next()) |buf| {
                last_dmd = DMDATA0.*;
                while (last_dmd & 0x80 != 0) : (last_dmd = DMDATA0.*) {
                    if (timeout == 0) {
                        DMDATA0.* |= 0xc0;
                        return 0;
                    }
                    timeout -= 1;
                }

                if (recv) |r| {
                    recv_len += pollInput(r);
                }

                timeout = 100_000;

                for (0..buf.len) |i| buffer[i + 1] = buf[i];
                buffer[0] = 0x80 | @as(u8, @truncate(buf.len + 4));

                DMDATA1.* = std.mem.readInt(u32, buffer[4..buffer.len], .little);
                DMDATA0.* = std.mem.readInt(u32, buffer[0..4], .little);
            }

            return recv_len;
        }

        if (recv) |r| {
            return pollInput(r);
        }

        return 0;
    }

    pub fn write(buf: []const u8) void {
        _ = transfer(buf, null);
    }

    // Returns max 3 bytes per call.
    pub fn pollInput(buf: []u8) usize {
        if (DMDATA0.* & 0x80 != 0) {
            return 0;
        }

        var dmd0 = DMDATA0.*;
        const len = (dmd0 & 0x3f) - 4;
        if (len == 0 or len >= 16) {
            return 0;
        }

        for (0..len) |i| {
            if (i >= buf.len) {
                return i;
            }

            dmd0 >>= 8;
            buf[i] = @truncate(dmd0);
        }

        DMDATA0.* = 0x84;

        return len;
    }

    const Context = struct {};
    pub const Writer = std.io.GenericWriter(Context, error{}, genericWriterFn);

    pub fn writer() Writer {
        return .{ .context = Context{} };
    }

    pub fn genericWriterFn(_: Context, buffer: []const u8) error{}!usize {
        write(buffer);
        return buffer.len;
    }
};
