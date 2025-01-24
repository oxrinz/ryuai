{
 description = "UART Python Dev Environment";

 inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
 inputs.flake-utils.url = "github:numtide/flake-utils";

 outputs = { self, nixpkgs, flake-utils }:
   flake-utils.lib.eachDefaultSystem (system:
     let
       pkgs = nixpkgs.legacyPackages.${system};
     in
     {
       devShell = pkgs.mkShell {
         buildInputs = with pkgs; [
           python3
           python3Packages.pip
           python3Packages.pyserial
           python3Packages.virtualenv
         ];
       };
     });
}