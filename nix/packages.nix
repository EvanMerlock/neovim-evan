{ pkgs }:

let
  # LSPs - Web Development
  lsps-web = with pkgs; [
    typescript-language-server
    vscode-langservers-extracted # html, css, json, eslint
    tailwindcss-language-server
  ];

  # LSPs - Backend Languages
  lsps-backend = with pkgs; [
    rust-analyzer
    gopls
    elixir-ls
    jdt-language-server
    kotlin-language-server
    lua-language-server
  ];

  # LSPs - Infrastructure/Config
  lsps-infra = with pkgs; [
    yaml-language-server
    terraform-ls
    taplo # TOML
    nil # Nix LSP
  ];

  # Formatters
  formatters = with pkgs; [
    prettierd
    eslint_d
    rustfmt
    gofumpt
    golines
    stylua
    google-java-format
    ktlint
    nixpkgs-fmt
  ];

  # Linters
  linters = with pkgs; [
    eslint_d
    golangci-lint
    selene
    yamllint
    tflint
    hadolint
  ];

  # Core tools needed by neovim/plugins
  tools = with pkgs; [
    git
    gnumake
    unzip
    ripgrep
    gcc
    nodejs
    fd
    tree-sitter
  ];

in
{
  inherit lsps-web lsps-backend lsps-infra formatters linters tools;

  # All LSPs combined
  lsps = lsps-web ++ lsps-backend ++ lsps-infra;

  # All packages combined
  all = lsps-web ++ lsps-backend ++ lsps-infra ++ formatters ++ linters ++ tools;

  # Language-specific groups for home-manager module
  byLanguage = {
    web = lsps-web ++ (with pkgs; [ prettierd eslint_d ]);
    rust = with pkgs; [ rust-analyzer rustfmt ];
    go = with pkgs; [ gopls gofumpt golines golangci-lint ];
    elixir = with pkgs; [ elixir-ls ];
    java = with pkgs; [ jdt-language-server google-java-format ];
    kotlin = with pkgs; [ kotlin-language-server ktlint ];
    lua = with pkgs; [ lua-language-server stylua selene ];
    yaml = with pkgs; [ yaml-language-server yamllint ];
    terraform = with pkgs; [ terraform-ls tflint ];
    toml = with pkgs; [ taplo ];
    docker = with pkgs; [ hadolint ];
    nix = with pkgs; [ nil nixpkgs-fmt ];
  };
}
