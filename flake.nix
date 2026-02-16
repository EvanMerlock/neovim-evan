{
  description = "Evan's personal nvim config, based on Kickstart.nvim and adjusted to be Nix-friendly";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager }:
    let
      # System-independent outputs
      systemIndependent = {
        homeManagerModules.default = import ./nix/home-manager-module.nix { inherit self; };
      };

      # System-dependent outputs
      systemDependent = flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          packages = import ./nix/packages.nix { inherit pkgs; };
          wrappedNeovim = import ./nix/neovim.nix {
            inherit pkgs;
            runtimeDeps = packages.all;
            configDir = ./nvim;
          };
        in
        {
          packages = {
            default = wrappedNeovim;
            neovim = wrappedNeovim;
          };

          apps.default = {
            type = "app";
            program = "${wrappedNeovim}/bin/nvim";
          };

          devShells.default = pkgs.mkShell {
            buildInputs = [ wrappedNeovim ] ++ packages.all;
            shellHook = ''
              echo "Neovim development shell"
              echo "Run 'nvim' to start the editor"
            '';
          };

          # Export packages for home-manager module
          legacyPackages = {
            inherit packages wrappedNeovim;
          };
        }
      );
    in
    systemIndependent // systemDependent;
}
