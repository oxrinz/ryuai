const std = @import("std");
const tensor = @import("tensor.zig");
const cpu = @import("backends/cpu_device.zig");

extern fn cudaMalloc(ptr: *?*anyopaque, size: usize) c_int;
extern fn cudaMemcpy(dest: *anyopaque, src: *const anyopaque, size: usize, kind: c_int) c_int;
extern fn cudaFree(ptr: *anyopaque) c_int;
extern fn cudaDeviceSynchronize() c_int;
extern fn cudaGetLastError() c_int;
extern fn cudaGetErrorString(errorNumber: c_int) [*:0]const u8;
extern "C" fn launchAddKernel(a: *anyopaque, b: *anyopaque, c: *anyopaque) void;

const cudaMemcpyHostToDevice = 1;
const cudaMemcpyDeviceToHost = 2;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

fn checkCudaError(errorNumber: c_int, operation: []const u8) bool {
    if (errorNumber != 0) {
        const err_str = cudaGetErrorString(errorNumber);
        std.debug.print("CUDA error in {s}: {s}\n", .{ operation, err_str });
        return false;
    }
    return true;
}

export fn add(a: i32, b: i32) i32 {
    var d_a: ?*anyopaque = undefined;
    var d_b: ?*anyopaque = undefined;
    var d_c: ?*anyopaque = undefined;
    var result: i32 = 0;

    if (!checkCudaError(cudaMalloc(&d_a, @sizeOf(i32)), "cudaMalloc(d_a)")) return -1;
    if (!checkCudaError(cudaMalloc(&d_b, @sizeOf(i32)), "cudaMalloc(d_b)")) return -1;
    if (!checkCudaError(cudaMalloc(&d_c, @sizeOf(i32)), "cudaMalloc(d_c)")) return -1;

    if (!checkCudaError(cudaMemcpy(d_a.?, &a, @sizeOf(i32), cudaMemcpyHostToDevice), "cudaMemcpy(d_a)")) return -1;
    if (!checkCudaError(cudaMemcpy(d_b.?, &b, @sizeOf(i32), cudaMemcpyHostToDevice), "cudaMemcpy(d_b)")) return -1;

    const zero: i32 = 0;
    if (!checkCudaError(cudaMemcpy(d_c.?, &zero, @sizeOf(i32), cudaMemcpyHostToDevice), "cudaMemcpy(d_c init)")) return -1;

    launchAddKernel(d_a.?, d_b.?, d_c.?);

    if (!checkCudaError(cudaGetLastError(), "kernel launch")) return -1;

    if (!checkCudaError(cudaDeviceSynchronize(), "cudaDeviceSynchronize")) return -1;

    if (!checkCudaError(cudaMemcpy(&result, d_c.?, @sizeOf(i32), cudaMemcpyDeviceToHost), "cudaMemcpy(result)")) return -1;

    _ = cudaFree(d_a.?);
    _ = cudaFree(d_b.?);
    _ = cudaFree(d_c.?);

    return result;
}

export fn hello() void {
    const tentype = tensor.Tensor(cpu.CpuInterface);
    var ten = tentype.init();
    ten.hello();
}

test "main" {
    std.debug.print("AHWHAG\n", .{});
    var ten2 = tensor.Tensor(cpu.CpuInterface);
    ten2.hello();
}
