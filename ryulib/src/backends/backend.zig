const std = @import("std");
const cpu = @import("cpu_device.zig");

pub fn BackendInterface(comptime T: type) type {
    return struct {
        ptr: *T,
        vtable: *const VTable,

        pub const VTable = struct {
            hello: *const fn (ptr: *T) void,
        };

        pub fn hello(self: @This()) void {
            self.vtable.hello(self.ptr);
        }
    };
}

pub fn getDevice(comptime T: type) BackendInterface(T) {
    var interface = T.init();
    return interface.interface();
}
