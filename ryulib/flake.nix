
{
  description = "CUDA development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            cudaPackages.cuda_nvcc
            cudaPackages.cuda_cudart
            cudaPackages.cuda_cccl
            
            gcc13
            gdb
            cmake
            gnumake

            clang-tools
            ninja
            pkg-config
          ];

          shellHook = ''
            export CUDA_PATH=${pkgs.cudaPackages.cuda_cudart}
            export LD_LIBRARY_PATH=${pkgs.cudaPackages.cuda_cudart}/lib:$LD_LIBRARY_PATH
            export EXTRA_LDFLAGS="-L/lib -L${pkgs.cudaPackages.cuda_cudart}/lib"
            export EXTRA_CCFLAGS="-I/usr/include"
            export PATH=${pkgs.gcc13}/bin:$PATH
            export CC=${pkgs.gcc13}/bin/gcc
            export CXX=${pkgs.gcc13}/bin/g++
            echo "CUDA development environment loaded!"
          '';
        };
      }
    );
}