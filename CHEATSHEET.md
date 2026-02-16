# Neovim Kickstart Cheatsheet

**Leader: `,`**

## Custom Keymaps

| Key | Mode | Action |
|-----|------|--------|
| `jk` | Insert | Exit insert mode |
| `;` | Normal | Enter command mode (swapped with `:`) |
| `:` | Normal | Repeat f/t motion |
| `j` / `k` | Normal | Move by visual line |
| `<Space>` | Normal | Toggle fold |
| `<Esc>` | Normal | Clear search highlight |

## Navigation (Telescope)

| Key | Action |
|-----|--------|
| `,sf` | Search files |
| `,sg` | Search by grep (live) |
| `,sw` | Search current word |
| `,sh` | Search help tags |
| `,sk` | Search keymaps |
| `,sc` | Search commands |
| `,sd` | Search diagnostics |
| `,sr` | Resume last search |
| `,s.` | Search recent files |
| `,ss` | Search Telescope pickers |
| `,/` | Fuzzy search in current buffer |
| `,s/` | Grep in open files |
| `,sn` | Search Neovim config files |
| `,,` | Find buffers |
| `,fb` | File browser |

## LSP (Buffer-local when attached)

| Key | Action |
|-----|--------|
| `grn` | Rename symbol |
| `gra` | Code action |
| `grd` | Go to definition |
| `grr` | Find references |
| `gri` | Go to implementation |
| `grt` | Go to type definition |
| `grD` | Go to declaration |
| `gO` | Document symbols |
| `gW` | Workspace symbols |
| `,th` | Toggle inlay hints |
| `,q` | Diagnostics to quickfix |
| `[d` / `]d` | Previous/next diagnostic |

## Formatting

| Key | Action |
|-----|--------|
| `,f` | Format buffer |
| (auto) | Format on save |

## Git

| Command | Action |
|---------|--------|
| `:G` | Fugitive status |
| `:G blame` | Git blame |
| `:G diff` | Git diff |
| `:G log` | Git log |
| `:G push` | Git push |

Gitsigns (in gutter):
- `+` added, `~` changed, `_` deleted

## Windows & Splits

| Key | Action |
|-----|--------|
| `Ctrl-h` | Focus left window |
| `Ctrl-j` | Focus lower window |
| `Ctrl-k` | Focus upper window |
| `Ctrl-l` | Focus right window |

## Buffers (Bufferline)

| Command | Action |
|---------|--------|
| `:bn` | Next buffer |
| `:bp` | Previous buffer |
| `:bd` | Close buffer |

## Text Objects (mini.ai)

| Pattern | Meaning |
|---------|---------|
| `va)` | Select around parentheses |
| `vi)` | Select inside parentheses |
| `vaq` | Select around quotes |
| `viq` | Select inside quotes |
| `yinq` | Yank inside next quote |
| `ci'` | Change inside single quotes |
| `da{` | Delete around braces |

## Surroundings (mini.surround)

| Key | Action |
|-----|--------|
| `saiw)` | Surround word with () |
| `sa$"` | Surround to end of line with "" |
| `sd'` | Delete surrounding quotes |
| `sr)"` | Replace () with "" |

## Folding

| Key | Action |
|-----|--------|
| `<Space>` | Toggle fold under cursor |
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zo` | Open fold |
| `zc` | Close fold |
| `za` | Toggle fold |

## Completion (blink.cmp)

| Key | Action |
|-----|--------|
| `Ctrl-n` | Next item |
| `Ctrl-p` | Previous item |
| `Ctrl-y` | Accept completion |
| `Ctrl-e` | Close menu |
| `Ctrl-Space` | Open menu / show docs |
| `Ctrl-k` | Toggle signature help |
| `Tab` | Jump to next snippet field |
| `Shift-Tab` | Jump to previous snippet field |

## Commands Reference

| Command | Action |
|---------|--------|
| `:Lazy` | Plugin manager |
| `:LspInfo` | LSP status |
| `:LspLog` | LSP logs |
| `:ConformInfo` | Formatter status |
| `:Telescope` | Telescope picker |
| `:checkhealth` | Health check |
| `:Tutor` | Vim tutorial |

## Vim Essentials

### Motion
| Key | Action |
|-----|--------|
| `h/j/k/l` | Left/down/up/right |
| `w/b/e` | Word forward/back/end |
| `0/$` | Line start/end |
| `gg/G` | File start/end |
| `{/}` | Paragraph up/down |
| `Ctrl-d/u` | Half-page down/up |
| `%` | Matching bracket |
| `f{c}/t{c}` | Find/till character |

### Editing
| Key | Action |
|-----|--------|
| `i/a` | Insert before/after cursor |
| `I/A` | Insert at line start/end |
| `o/O` | New line below/above |
| `x` | Delete character |
| `dd` | Delete line |
| `yy` | Yank line |
| `p/P` | Paste after/before |
| `u` | Undo |
| `Ctrl-r` | Redo |
| `.` | Repeat last change |
