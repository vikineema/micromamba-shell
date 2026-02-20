{
  description = "Micromamba shell environment using Nix and FHS";

  inputs = {
    # NixOS official package source, using the nixos-25.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux"];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      pkgsFor = forAllSystems (system: import nixpkgs {
        localSystem = system;
        config.allowUnfree = false;
      });

    in  {
    ######################################################
    ##
    ## Package Definitions
    ##
    ######################################################
    packages = forAllSystems (system: 
      let 
        pkgs = pkgsFor.${system}; 
      in rec {
        micromamba-shell = pkgs.callPackage ./packages/micromamba-shell { };
        default = micromamba-shell;
      }
    );
    
    ######################################################
    ##
    ## Apps
    ##
    ######################################################
    apps = forAllSystems (system: {
        micromamba-shell = {
          type = "app";
          program = "${self.packages.${system}.micromamba-shell}/bin/micromamba-shell";
        };

        default = self.apps.${system}.micromamba-shell;
    });
  };
}
