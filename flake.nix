{
  description = "micromamba wrapped in FHS environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.x86_64-linux.default =
        (pkgs.buildFHSEnv {
          pname = "micromamba-fhs-env";
          version = "v0.1.0";
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
            export MAMBA_ROOT_PREFIX='${builtins.getEnv "HOME"}/micromamba';
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
        }).env;
    };
}
