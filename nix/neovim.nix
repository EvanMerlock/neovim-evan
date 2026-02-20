{ pkgs, runtimeDeps, configDir }:

let
  # Copy config to the nix store
  configStore = pkgs.stdenv.mkDerivation {
    name = "neovim-evan-config";
    src = configDir;
    installPhase = ''
      mkdir -p $out
      cp -r . $out/
    '';
  };

  # Create a wrapper script that sets up the environment
  neovimWrapped = pkgs.symlinkJoin {
    name = "neovim-evan";
    paths = [ pkgs.neovim ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nvim \
        --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps} \
        --set NVIM_APPNAME "neovim-evan" \
        --add-flags "--cmd 'set rtp^=${configStore}'" \
        --add-flags "-u ${configStore}/init.lua"
    '';
  };
in
neovimWrapped
