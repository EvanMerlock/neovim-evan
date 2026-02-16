# neovim-kickstart-nix

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
  inputs.neovim-kickstart.url = "github:evanmerlock/nvim-testing";
}
```

Then in your Home-Manager configuration:

```nix
{ inputs, ... }:
{
  imports = [ inputs.neovim-kickstart.homeManagerModules.default ];

  programs.neovim-kickstart = {
    enable = true;
    languages = {
      web = true;      # TypeScript, HTML, CSS, Tailwind, ESLint
      rust = true;     # rust-analyzer, rustfmt
      go = true;       # gopls, gofumpt, golangci-lint
      # all = true;    # Enable everything
    };
  };
}
```

## Configuration

### Language Support

| Language | LSP | Formatter | Linter | Home-Manager Flag |
|----------|-----|-----------|--------|-------------------|
| Web (TS/JS/HTML/CSS) | ts_ls, html, cssls, tailwindcss, eslint | prettierd | eslint_d | `languages.web` |
| Rust | rust-analyzer | rustfmt | clippy (via LSP) | `languages.rust` |
| Go | gopls | gofumpt, golines | golangci-lint | `languages.go` |
| Elixir | elixir-ls | mix format | - | `languages.elixir` |
| Java | jdtls | google-java-format | - | `languages.java` |
| Kotlin | kotlin-language-server | ktlint | ktlint | `languages.kotlin` |
| Lua | lua_ls | stylua | selene | `languages.lua` (default: on) |
| YAML | yaml-language-server | prettier | yamllint | `languages.yaml` |
| Terraform | terraform-ls | terraform fmt | tflint | `languages.terraform` |
| TOML | taplo | taplo | - | `languages.toml` |
| Nix | nil | nixpkgs-fmt | - | (always included) |
| Docker | - | - | hadolint | `languages.docker` |

### Enabling Optional Plugins

These plugins are available but commented out in `init.lua`:

| Plugin | Description | Require |
|--------|-------------|---------|
| debug | DAP debugging support | `kickstart.plugins.debug` |
| indent_line | Show indent guides | `kickstart.plugins.indent_line` |
| autopairs | Auto-close brackets/quotes | `kickstart.plugins.autopairs` |
| neo-tree | File tree sidebar | `kickstart.plugins.neo-tree` |
| gitsigns keymaps | Additional git hunk navigation | `kickstart.plugins.gitsigns` |

To enable, uncomment the corresponding `require` line in `init.lua` (around line 965).

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

## Acknowledgments

Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) by TJ DeVries.
