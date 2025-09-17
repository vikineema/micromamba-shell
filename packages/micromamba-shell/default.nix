{ pkgs ? import <nixpkgs> {}}:
let
  micromamba-setup = pkgs.writeText
    "micromamba-setup"
    ''
    # Set up the required variables
    export MAMBA_ROOT_PREFIX="$HOME/micromamba"
    export MAMBA_EXE="${pkgs.micromamba}/bin/micromamba"
    export CONDA_EXE="${pkgs.micromamba}/bin/micromamba"

    # Use conda as micromamba command
    alias conda='micromamba'

    # Initialize the shell
    eval "$($MAMBA_EXE shell hook --shell=posix --root-prefix=$MAMBA_ROOT_PREFIX)"
    
    # Configure an exclusive conda set up
    micromamba config append channels conda-forge
    micromamba config append channels nodefaults
    micromamba config set channel_priority strict
    '';

  micromamba-init = pkgs.writeText
    "micromamba-init"
    ''
    source ${micromamba-setup}

    ## The lines below replace ./bin/micromamba shell init -s bash -r ~/micromamba
    ## to allow bash autocompletion for micromamba commands.
    
    # >>> mamba initialize >>>
    # !! Contents within this block are managed by 'mamba init' !!
    export MAMBA_EXE="${pkgs.micromamba}/bin/micromamba";
    export MAMBA_ROOT_PREFIX="$HOME/micromamba";
    __mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__mamba_setup"
    else
        alias micromamba="$MAMBA_EXE"  # Fallback on help from mamba activate
    fi
    unset __mamba_setup
    # <<< mamba initialize <<<

    # Source the bashrc file.
    source ~/.bashrc
    '';
in
pkgs.buildFHSEnv {
    name = "micromamba-shell";

    targetPkgs = _: [
      pkgs.micromamba
      pkgs.bash-completion
    ];
    
    profile = ''
        set -ex
                
        # Source micromamba initialization script
        source ${micromamba-setup}
        
        # Activate the base environment
        micromamba activate
        set +e

    '';

runScript = "bash --init-file ${micromamba-init}";

}