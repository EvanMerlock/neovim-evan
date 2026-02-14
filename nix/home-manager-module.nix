{ self }:

{ config, lib, pkgs, ... }:

let
  cfg = config.programs.neovim-kickstart;
  packages = import ./packages.nix { inherit pkgs; };

  # Build the list of packages based on enabled languages
  enabledPackages = packages.tools
    ++ (lib.optionals cfg.languages.web packages.byLanguage.web)
    ++ (lib.optionals cfg.languages.rust packages.byLanguage.rust)
    ++ (lib.optionals cfg.languages.go packages.byLanguage.go)
    ++ (lib.optionals cfg.languages.elixir packages.byLanguage.elixir)
    ++ (lib.optionals cfg.languages.java packages.byLanguage.java)
    ++ (lib.optionals cfg.languages.kotlin packages.byLanguage.kotlin)
    ++ (lib.optionals cfg.languages.lua packages.byLanguage.lua)
    ++ (lib.optionals cfg.languages.yaml packages.byLanguage.yaml)
    ++ (lib.optionals cfg.languages.terraform packages.byLanguage.terraform)
    ++ (lib.optionals cfg.languages.toml packages.byLanguage.toml)
    ++ (lib.optionals cfg.languages.docker packages.byLanguage.docker);

in
{
  options.programs.neovim-kickstart = {
    enable = lib.mkEnableOption "neovim-kickstart configuration";

    languages = {
      web = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable web development tools (TypeScript, HTML, CSS, Tailwind, ESLint)";
      };

      rust = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Rust development tools (rust-analyzer, rustfmt)";
      };

      go = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Go development tools (gopls, gofumpt, golangci-lint)";
      };

      elixir = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Elixir development tools (elixir-ls)";
      };

      java = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Java development tools (jdtls, google-java-format)";
      };

      kotlin = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Kotlin development tools (kotlin-language-server, ktlint)";
      };

      lua = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Lua development tools (lua-language-server, stylua, selene)";
      };

      yaml = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable YAML development tools (yaml-language-server, yamllint)";
      };

      terraform = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Terraform development tools (terraform-ls, tflint)";
      };

      toml = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable TOML development tools (taplo)";
      };

      docker = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Docker development tools (hadolint)";
      };

      all = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable all language tools";
      };
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional packages to include";
    };
  };

  config = lib.mkIf cfg.enable {
    # Override language options if 'all' is set
    programs.neovim-kickstart.languages = lib.mkIf cfg.languages.all {
      web = lib.mkDefault true;
      rust = lib.mkDefault true;
      go = lib.mkDefault true;
      elixir = lib.mkDefault true;
      java = lib.mkDefault true;
      kotlin = lib.mkDefault true;
      lua = lib.mkDefault true;
      yaml = lib.mkDefault true;
      terraform = lib.mkDefault true;
      toml = lib.mkDefault true;
      docker = lib.mkDefault true;
    };

    programs.neovim = {
      enable = true;
      extraPackages = enabledPackages ++ cfg.extraPackages;
    };

    # Symlink the config directory
    xdg.configFile."nvim" = {
      source = ../nvim;
      recursive = true;
    };
  };
}
