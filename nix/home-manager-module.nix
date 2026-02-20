{ self }:

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.neovim-evan;
  packages = import ./packages.nix { inherit pkgs; };
in
{
  options.programs.neovim-evan = {
    enable = lib.mkEnableOption "neovim-evan configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      extraWrapperArgs = [
        "--prefix"
        "PATH"
        ":"
        (lib.makeBinPath packages.all)
      ];
    };

    # Symlink the config directory
    xdg.configFile."nvim" = {
      source = ../nvim;
      recursive = true;
    };
  };
}
