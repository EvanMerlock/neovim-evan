{ pkgs, runtimeDeps, configDir }:

let
  # Copy config to the nix store
  configStore = pkgs.stdenv.mkDerivation {
    name = "nvim-kickstart-config";
    src = configDir;
    installPhase = ''
      mkdir -p $out
      cp -r . $out/
    '';
  };

  # Create a wrapper script that sets up the environment
  neovimWrapped = pkgs.symlinkJoin {
    name = "neovim-kickstart";
    paths = [ pkgs.neovim ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nvim \
        --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps} \
        --set NVIM_APPNAME "nvim-kickstart" \
        --add-flags "--cmd 'set rtp^=${configStore}'" \
        --add-flags "-u ${configStore}/init.lua"
    '';
  };
in
neovimWrapped
