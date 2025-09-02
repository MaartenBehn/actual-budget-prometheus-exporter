{
  description = "actual-budget-prometheus-export";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    {
      nixpkgs,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      perSystem =
        {
          system,
          pkgs,
          self',
          lib,
          ...
        }:
        let
          nodeDependencies = (pkgs.callPackage ./default.nix {}).nodeDependencies;
        in        
          {
          packages = {
            default = pkgs.stdenv.mkDerivation {
              name = "my-webpack-app";
              src = ./my-app;
              buildInputs = [pkgs.nodejs];
              buildPhase = ''
                ln -s ${nodeDependencies}/lib/node_modules ./node_modules
                export PATH="${nodeDependencies}/bin:$PATH"

                # Build the distribution bundle in "dist"
                webpack
                cp -r dist $out/
              '';
            };
          };
        };
    };
}
