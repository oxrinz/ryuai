const std = @import("std");
const backend = @import("backend.zig");

pub const CpuInterface = struct {
    pub fn init() CpuInterface {
        return .{};
    }

    pub fn hello(self: *CpuInterface) void {
        std.debug.print("hello from CPU {*}\n", .{self});
    }

    pub fn interface(self: *CpuInterface) backend.BackendInterface(CpuInterface) {
        return .{
            .ptr = self,
            .vtable = &.{
                .hello = hello,
            },
        };
    }

    pub fn deinit(self: *CpuInterface) void {
        self.allocator.destroy(self);
    }
};
