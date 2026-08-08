# CLAUDE.md

This file provides context for Claude Code when working on this repository.

## Project Overview

This is a Nix flake that packages a customized Neovim configuration based on kickstart.nvim. The configuration includes LSPs, formatters, linters, and plugins - all managed through Nix for reproducibility.

## Repository Structure

```
.
├── flake.nix                 # Main flake definition
├── nix/
│   ├── neovim.nix           # Neovim wrapper with runtime deps
│   ├── packages.nix         # LSPs, formatters, linters grouped by language
│   └── home-manager-module.nix  # Home-manager integration
├── nvim/
│   ├── init.lua             # Main Neovim configuration
│   └── lua/kickstart/plugins/  # Optional plugin configurations
├── selene.toml              # Selene linter config (points to vim.yml)
└── vim.yml                  # Selene standard library for Neovim
```

## Key Technical Details

### Nix Setup

- **Development shell**: `nix develop` provides nvim with all tools on PATH
- **Home-manager module**: `programs.neovim-evan.enable = true` bundles only the core `tools`; LSPs are inherited from the environment. Opt into extras with `languages`, `extraPackages`, or `allLanguages` (see below).
- **NVIM_APPNAME**: Set to `nvim-kickstart` to isolate config/data directories

### Plugin Management

- Plugins are managed by **lazy.nvim** (downloaded at runtime, not Nix)
- Core `tools` (git, ripgrep, fd, gcc, tree-sitter, nodejs, …) are provided by **Nix** (not Mason) and always bundled
- LSPs/formatters/linters are **inherited from the ambient environment/PATH** by default; install them via the home-manager module's `languages`/`extraPackages` options
- Plugin specs are in `nvim/init.lua`

### LSP Configuration

- Uses Neovim 0.11+ native `vim.lsp.config()` and `vim.lsp.enable()` APIs
- **lazydev.nvim** provides Neovim Lua API completions to lua_ls
- Server configs are in the `servers` table in init.lua

### Linting

- **nvim-lint** runs linters on save (configured in `lua/kickstart/plugins/lint.lua`)
- **selene** is used for Lua linting
- `selene.toml` and `vim.yml` at repo root configure selene to recognize `vim` global

## Common Tasks

### Adding a new LSP

1. Add the server package to `nix/packages.nix`
2. Add config to the `servers` table in `nvim/init.lua`
3. Add formatter to `formatters_by_ft` in conform.nvim config if needed

### Modifying the home-manager module

Edit `nix/home-manager-module.nix`. Options:
- `programs.neovim-evan.enable = true` bundles only `packages.tools`; LSPs are inherited from the environment
- `languages = [ "rust" "go" ]` installs those `byLanguage` toolchains (LSP + formatter + linter)
- `extraPackages = [ pkgs.some-custom-lsp ]` adds arbitrary/custom LSPs
- `allLanguages = true` installs every bundled toolchain (restores the old "everything" behavior)
- `customLanguages.<lang>` registers a brand-new language entirely from home-manager (no init.lua edits): a block declares its `filetypes`, an optional `filetypeExtensions` (extension → filetype, for filetypes Neovim doesn't detect itself), a required `server` (`{ name; package; config; }` → `vim.lsp.config`), and optional `formatters`/`linters` (`attrsOf { package; definition; }`, keyed by conform/nvim-lint tool name). Each tool carries its own `package`. The module writes a store-backed `~/.config/nvim/lua/neovim_evan_custom.lua` that `init.lua`/`lint.lua` merge in. Definitions are declarative/JSON-serializable only — function fields (`on_attach`, function `settings`, function `parser`, `cwd`/`condition`) must go in init.lua.

Example:
```nix
programs.neovim-evan.customLanguages.gleam = {
  filetypes = [ "gleam" ];
  server = {
    name = "gleam";
    package = pkgs.gleam;
    config = { cmd = [ "gleam" "lsp" ]; root_markers = [ "gleam.toml" ]; };
  };
  formatters.gleam_fmt = {
    package = pkgs.gleam;
    definition = { command = "gleam"; args = [ "format" "--stdin" ]; stdin = true; };
  };
};
```

### Testing changes

```bash
# Rebuild and enter shell
nix develop

# Or run directly
nix run .
```

## Conventions

- Leader key is `,`
- `;` and `:` are swapped (`;` enters command mode)
- `jk` exits insert mode
- Indent: 4 spaces (tabs expanded)
