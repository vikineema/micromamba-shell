{
  description = "Micromamba shell environment using Nix and FHS";

  inputs = {
    # NixOS official package source, using the nixos-25.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";

      # Use a system-specific version of Nixpkgs
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = false;
      };
    in  {
    ######################################################
    ##
    ## Package Definitions
    ##
    ######################################################
    packages.${system} = rec {
        micromamba-shell = pkgs.callPackage ./packages/micromamba-shell { };
        default = micromamba-shell;
      };
    
    ######################################################
    ##
    ## Apps
    ##
    ######################################################
      apps.${system} = {
        micromamba-shell = {
          type = "app";
          program = "${self.packages.${system}.micromamba-shell}/bin/micromamba-shell";
        };

        default = self.apps.${system}.micromamba-shell;
      };
    };
}
