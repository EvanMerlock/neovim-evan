# neovim-evan

A Nix flake wrapping [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) with reproducible LSPs, formatters, and linters.

## Features

- **Solarized dark** colorscheme
- **Telescope** for fuzzy finding (files, grep, buffers, help)
- **LSP support** for 15+ languages via Nix-provided servers
- **Autoformatting** on save with conform.nvim
- **Git integration** via fugitive and gitsigns
- **Treesitter** syntax highlighting
- **Blink.cmp** autocompletion with snippet support
- **Which-key** for discoverability (press leader and wait)
- **Lazydev.nvim** for Neovim Lua API completions

See [CHEATSHEET.md](CHEATSHEET.md) for keybindings.

## Prerequisites

- Nix with flakes enabled (`experimental-features = nix-command flakes` in `nix.conf`)

## Quick Start

### Try It (No Install)

```bash
nix run github:evanmerlock/nvim-testing
```

### Development Shell

```bash
nix develop
nvim
```

### Home-Manager (Permanent Install)

Add the flake input:

```nix
{
  inputs.neovim-evan.url = "github:evanmerlock/nvim-testing";
}
```

Then in your Home-Manager configuration:

```nix
{ inputs, ... }:
{
  imports = [ inputs.neovim-evan.homeManagerModules.default ];

  programs.neovim-evan.enable = true;
}
```

This installs Neovim with all LSPs, formatters, and linters included.

## Language Support

| Language | LSP | Formatter | Linter |
|----------|-----|-----------|--------|
| Web (TS/JS/HTML/CSS) | ts_ls, html, cssls, tailwindcss, eslint | prettierd | eslint_d |
| Rust | rust-analyzer | rustfmt | clippy (via LSP) |
| Go | gopls | gofumpt, golines | golangci-lint |
| Elixir | elixir-ls | mix format | - |
| Java | jdtls | google-java-format | - |
| Kotlin | kotlin-language-server | ktlint | ktlint |
| Lua | lua_ls | stylua | selene |
| YAML | yaml-language-server | prettier | yamllint |
| Terraform | terraform-ls | terraform fmt | tflint |
| TOML | taplo | taplo | - |
| Nix | nil | nixpkgs-fmt | - |
| Docker | - | - | hadolint |

## Lua Development

This config includes **lazydev.nvim** which automatically provides Neovim API completions when editing Lua files.

For **selene** (Lua linter) to recognize the `vim` global, the repo includes:
- `selene.toml` - points to the vim standard library
- `vim.yml` - defines `vim` as a valid global

## Optional Plugins

These plugins are enabled in `init.lua`:

| Plugin | Description |
|--------|-------------|
| debug | DAP debugging support |
| indent_line | Show indent guides |
| autopairs | Auto-close brackets/quotes |
| neo-tree | File tree sidebar |
| gitsigns keymaps | Additional git hunk navigation |

### Adding Custom Plugins

Create files in `nvim/lua/custom/plugins/` and uncomment the import line in `init.lua`:

```lua
{ import = 'custom.plugins' },
```

## Customization Notes

This config diverges from upstream kickstart.nvim:

- **Leader** is `,` (not `<Space>`)
- **`;` and `:`** are swapped (`;` enters command mode)
- **`jk`** exits insert mode
- **`<Space>`** toggles folds
- **`j`/`k`** move by visual line (wrapped lines)

See [CHEATSHEET.md](CHEATSHEET.md) for the complete keybinding reference.

## Health Check

```vim
:checkhealth
```

Check specific areas:

```vim
:checkhealth lspconfig
:checkhealth telescope
:checkhealth treesitter
```

## Troubleshooting

### LSP not attaching

1. Ensure the language server is on PATH: `:!which rust-analyzer`
2. Check LSP logs: `:LspLog`
3. Verify filetype detection: `:set ft?`

### Formatter not running

1. Check conform status: `:ConformInfo`
2. Ensure formatter is on PATH: `:!which prettierd`

### Selene complaining about `vim`

Ensure you're running nvim from the repo root where `selene.toml` and `vim.yml` are located.

## Acknowledgments

Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) by TJ DeVries.
