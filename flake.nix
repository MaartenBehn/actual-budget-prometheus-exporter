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
          nodeEnv = import ./default.nix { inherit pkgs; };
        in     
          {
          packages = {
            default = pkgs.stdenv.mkDerivation {
              pname = "actual-budget-prometheus-export";
              version = "1.0.0";

              src = ./.;

              buildInputs = [ nodeEnv ];

              installPhase = ''
                mkdir -p $out/bin
                # Wrap your npm script as an executable
                cat > $out/bin/actual-budget-prometheus-export <<EOF
                #!/bin/sh
                exec ${nodeEnv}/bin/npm run prod 
                EOF
                chmod +x $out/bin/start-my-service
              '';
            };
          };
        };
    };
}
