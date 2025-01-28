const std = @import("std");
const backend = @import("backends/backend.zig");
const BackendInterface = backend.BackendInterface;

pub const Op = enum { ADD, SUB, MUL, DIV };

pub const Backend = enum {
    CPU,
    CUDA,
    // RYU,
    // ROCM
};

pub fn Tensor(comptime BackendType: type) type {
    return struct {
        backend: backend.BackendInterface(BackendType),

        const Self = @This();

        pub fn init() Self {
            return .{ .backend = backend.getDevice(BackendType) };
        }

        pub fn hello(self: *Self) void {
            self.backend.hello();
        }
    };
}
