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
- **Home-manager module**: `programs.neovim-evan.enable = true` installs everything
- **NVIM_APPNAME**: Set to `nvim-kickstart` to isolate config/data directories

### Plugin Management

- Plugins are managed by **lazy.nvim** (downloaded at runtime, not Nix)
- LSPs/formatters/linters are provided by **Nix** (not Mason)
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

Edit `nix/home-manager-module.nix`. The module is simple:
- `programs.neovim-evan.enable = true` installs everything from `packages.all`

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
