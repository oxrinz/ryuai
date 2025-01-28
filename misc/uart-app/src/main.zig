const std = @import("std");
const zig_serial = @import("serial.zig");

pub fn main() !void {
    var serial = try std.fs.cwd().openFile("/dev/ttyUSB1", .{ .mode = .read_write });
    defer serial.close();

    try zig_serial.configureSerialPort(serial, zig_serial.SerialConfig{
        .baud_rate = 115200,
        .word_size = .eight,
        .parity = .none,
        .stop_bits = .one,
        .handshake = .none,
    });

    const binary_str = "00000000100000100001000010101010";
    var instruction: u32 = 0;

    for (binary_str, 0..) |bit, i| {
        switch (bit) {
            '0' => {},
            '1' => {
                instruction |= @as(u32, 1) << @intCast(31 - i);
            },
            else => return error.InvalidBinaryString,
        }
    }

    var bytes: [4]u8 = undefined;
    bytes[0] = @truncate((instruction >> 24) & 0xFF);
    bytes[1] = @truncate((instruction >> 16) & 0xFF);
    bytes[2] = @truncate((instruction >> 8) & 0xFF);
    bytes[3] = @truncate(instruction & 0xFF);

    for (bytes) |byte| {
        std.debug.print("sent byte: 0b{b:0>8}\n", .{byte});
        _ = try serial.write(&[_]u8{byte});

        // figure out why this is needed & get rid of it
        std.time.sleep(std.time.ns_per_ms * 1);
    }

    const stdout = std.io.getStdOut().writer();
    for (0..4) |i| {
        var read_buffer: [1]u8 = undefined;
        const bytes_read = try serial.read(&read_buffer);

        if (bytes_read > 0) {
            try stdout.print("Received byte {d}: 0b{b:0>8}\n", .{ i, read_buffer[0] });
        } else {
            std.debug.print("No data received for byte {d}\n", .{i});
        }
    }
}
