const std = @import("std");
const gpu_arch = "sm_75";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(.{
        .name = "starter",
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const cuda_obj = compileCuda(b);
    lib.addObjectFile(.{ .cwd_relative = cuda_obj });

    const cuda_path = std.process.getEnvVarOwned(b.allocator, "CUDA_PATH") catch "/usr/local/cuda";
    defer b.allocator.free(cuda_path);

    lib.addIncludePath(.{ .cwd_relative = b.fmt("{s}/include", .{cuda_path}) });
    lib.addLibraryPath(.{ .cwd_relative = b.fmt("{s}/lib64", .{cuda_path}) });
    lib.linkSystemLibrary("cuda");
    lib.linkSystemLibrary("cudart");
    lib.linkLibC();

    const install = b.addInstallArtifact(lib, .{
        .dest_dir = .{ .override = .{ .custom = "." } },
    });
    b.getInstallStep().dependOn(&install.step);

    const main_tests = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    main_tests.addObjectFile(.{ .cwd_relative = cuda_obj });
    main_tests.addIncludePath(.{ .cwd_relative = b.fmt("{s}/include", .{cuda_path}) });
    main_tests.addLibraryPath(.{ .cwd_relative = b.fmt("{s}/lib64", .{cuda_path}) });
    main_tests.linkSystemLibrary("cuda");
    main_tests.linkSystemLibrary("cudart");
    main_tests.linkLibC();

    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}

fn compileCuda(b: *std.Build) []const u8 {
    const source_path = b.pathJoin(&.{ "src", "backends", "cuda", "root.cu" });
    const target_path = b.pathJoin(&.{ "src", "backends", "cuda", "cuda.o" });

    const cc_path = std.process.getEnvVarOwned(b.allocator, "CC") catch |err| {
        std.log.err("Failed to get CC environment variable: {}", .{err});
        @panic("CC environment variable not set");
    };
    defer b.allocator.free(cc_path);

    const nvcc_args = &.{
        "nvcc",
        "-ccbin",
        cc_path,
        "-c",
        source_path,
        "-o",
        target_path,
        "-O3",
        b.fmt("--gpu-architecture={s}", .{gpu_arch}),
        "--compiler-options",
        "-fPIC",
    };

    const result = std.process.Child.run(.{
        .allocator = b.allocator,
        .argv = nvcc_args,
    }) catch @panic("Failed to compile CUDA code");

    if (result.stderr.len != 0) {
        std.log.err("NVCC Error: {s}", .{result.stderr});
        @panic("Failed to compile CUDA code");
    }
    return target_path;
}
