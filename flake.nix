{
  description = "micromamba wrapped in FHS environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      micromamba-fhs-name = "micromamba-shell";
      micromamba-fhs-version = "v1.0.0";

      micromamba-fhs = pkgs.buildFHSEnv {
        pname = micromamba-fhs-name;
        version = micromamba-fhs-version;

        targetPkgs =
          pkgs: with pkgs; [
            micromamba
            bash-completion
          ];

        profile = ''
          # Silence 'complete' command errors if the builtin isn't ready
          type complete &>/dev/null || complete() { :; }

          # Copied from micromamba shell init -s bash -r ~/micromamba
          # >>> mamba initialize >>>
          # !! Contents within this block are managed by 'micromamba shell init' !!
          export MAMBA_EXE='${pkgs.micromamba}/bin/micromamba';
          # export MAMBA_ROOT_PREFIX='${builtins.getEnv "HOME"}/micromamba';
          export MAMBA_ROOT_PREFIX="$HOME/micromamba";
          __mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
          if [ $? -eq 0 ]; then
              eval "$__mamba_setup"
          else
              alias micromamba="$MAMBA_EXE"  # Fallback on help from micromamba activate
          fi
          unset __mamba_setup
          # <<< mamba initialize <<<

        '';
        # Force bash to execute the /etc/profile every time.
        runScript = "bash --login --rcfile /etc/profile";
      };
    in
    {
      # Installable package
      packages.${system}.default = micromamba-fhs;
      
      # Used for nix-develop
      devShells.${system}.default = pkgs.mkShell {
        name = micromamba-fhs-name + "-" + micromamba-fhs-version;
        buildInputs = [
          micromamba-fhs
        ];
        shellHook = ''
          exec ${micromamba-fhs-name}
        '';
      };

    };
}
