-- =============================================================================
-- Neovim Configuration (based on kickstart.nvim)
-- See README.md for setup, CHEATSHEET.md for keybindings
-- =============================================================================

-- [[ Leader Key ]]
-- Must be set before plugins load. Using comma for easier reach than space.
vim.g.mapleader = ","
vim.g.maplocalleader = ","

vim.g.have_nerd_font = false

-- [[ Settings ]]
-- See :help vim.o and :help option-list

vim.o.number = true
vim.o.mouse = "a"
vim.o.showmode = false -- Mode shown in statusline
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end) -- Sync with system clipboard
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true -- Case-sensitive if uppercase in search
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split" -- Live preview for :s
vim.o.cursorline = true
vim.o.scrolloff = 10

-- Tab settings: 4-space indentation
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- Folding: indent-based, start mostly open
vim.o.foldenable = true
vim.o.foldlevelstart = 10
vim.o.foldnestmax = 10
vim.o.foldmethod = "indent"

vim.o.confirm = true -- Prompt to save instead of failing

-- [[ Keymaps ]]
-- See :help vim.keymap.set()

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostics
vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	virtual_text = true,
	virtual_lines = false,
	jump = { float = true },
})
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Terminal: double-Esc is easier to discover than C-\ C-n
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Window navigation with Ctrl+hjkl
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- =============================================================================
-- CUSTOM KEYMAPS (deviations from kickstart defaults)
-- =============================================================================

-- Ergonomic: jk is faster than reaching for Esc
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Frequency: : is used far more often than ; so swap them
vim.keymap.set("n", ";", ":", { desc = "Enter command mode" })
vim.keymap.set("n", ":", ";", { desc = "Repeat f/t motion" })

-- Wrapped lines: j/k should move visually, not by line number
vim.keymap.set("n", "j", "gj", { desc = "Move down by visual line" })
vim.keymap.set("n", "k", "gk", { desc = "Move up by visual line" })

-- Space for folds since leader is comma
vim.keymap.set("n", "<Space>", "za", { desc = "Toggle fold" })

-- [[ Autocommands ]]

-- Brief highlight on yank for visual feedback
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- [[ Plugin Manager: lazy.nvim ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Plugins ]]
-- Use :Lazy to manage, :Lazy update to update
require("lazy").setup({

	-- [[ Plugin: Core ]]

	-- Detects indentation style (tabs vs spaces) from file content
	{ "NMAC427/guess-indent.nvim", opts = {} },

	-- Shows git diff markers in the sign column (colored bar)
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { text = "│" },
				topdelete = { text = "│" },
				changedelete = { text = "│" },
			},
		},
	},

	-- Displays available keybindings in a popup as you type
	{
		"folke/which-key.nvim",
		event = "VimEnter",
		opts = {
			-- delay between pressing a key and opening which-key (milliseconds)
			delay = 0,
			icons = { mappings = vim.g.have_nerd_font },

			-- Document existing key chains
			spec = {
				{ "<leader>s", group = "[S]earch", mode = { "n", "v" } },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			},
		},
	},

	-- [[ Plugin: Telescope ]]
	-- Fuzzy finder for files, grep, buffers, LSP symbols, and more
	{
		"nvim-telescope/telescope.nvim",
		enabled = true,
		event = "VimEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			-- See :help telescope for picker keymaps (? in normal, C-/ in insert)
			require("telescope").setup({
				extensions = {
					["ui-select"] = { require("telescope.themes").get_dropdown() },
				},
			})

			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

			-- LSP keymaps via Telescope (set on LspAttach)
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
				callback = function(event)
					local buf = event.buf
					vim.keymap.set("n", "grr", builtin.lsp_references, { buffer = buf, desc = "[G]oto [R]eferences" })
					vim.keymap.set(
						"n",
						"gri",
						builtin.lsp_implementations,
						{ buffer = buf, desc = "[G]oto [I]mplementation" }
					)
					vim.keymap.set("n", "grd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })
					vim.keymap.set(
						"n",
						"gO",
						builtin.lsp_document_symbols,
						{ buffer = buf, desc = "Open Document Symbols" }
					)
					vim.keymap.set(
						"n",
						"gW",
						builtin.lsp_dynamic_workspace_symbols,
						{ buffer = buf, desc = "Open Workspace Symbols" }
					)
					vim.keymap.set(
						"n",
						"grt",
						builtin.lsp_type_definitions,
						{ buffer = buf, desc = "[G]oto [T]ype Definition" }
					)
				end,
			})

			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(
					require("telescope.themes").get_dropdown({ winblend = 10, previewer = false })
				)
			end, { desc = "[/] Fuzzily search in current buffer" })

			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
			end, { desc = "[S]earch [/] in Open Files" })

			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	-- [[ Plugin: LSP ]]
	-- Configures language servers for code intelligence (completions, go-to-definition, etc.)
	-- LSPs are provided by Nix, not Mason. See :help lsp for details.
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "j-hui/fidget.nvim", opts = {} }, -- Shows LSP progress in bottom-right corner
			"saghen/blink.cmp",
		},
		config = function()
			-- Buffer-local keymaps when LSP attaches
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
					map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- Highlight references under cursor
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client:supports_method("textDocument/documentHighlight", event.buf) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					if client and client:supports_method("textDocument/inlayHint", event.buf) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- Server configs (LSPs provided by Nix, must be on PATH)
			local servers = {
				-- Web
				ts_ls = {},
				html = {},
				cssls = {},
				tailwindcss = {},
				eslint = {},
				jsonls = {},
				-- Backend
				rust_analyzer = { settings = { ["rust-analyzer"] = { checkOnSave = { command = "clippy" } } } },
				gopls = { settings = { gopls = { gofumpt = true } } },
				elixirls = { cmd = { "elixir-ls" } },
				jdtls = {},
				kotlin_language_server = {},
				-- Infrastructure
				yamlls = {},
				terraformls = {},
				taplo = {},
				nil_ls = {},
			}

			for name, config in pairs(servers) do
				config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
				vim.lsp.config(name, config)
				vim.lsp.enable(name)
			end

			-- Lua: special config for Neovim development
			vim.lsp.config("lua_ls", {
				on_init = function(client)
					if client.workspace_folders then
						local path = client.workspace_folders[1].name
						if
							path ~= vim.fn.stdpath("config")
							and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
						then
							return
						end
					end
					client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
						runtime = { version = "LuaJIT", path = { "lua/?.lua", "lua/?/init.lua" } },
						workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
					})
				end,
				settings = { Lua = {} },
			})
			vim.lsp.enable("lua_ls")
		end,
	},

	-- [[ Plugin: Conform ]]
	-- Auto-formats code on save using external formatters (prettier, rustfmt, etc.)
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				local disable_filetypes = { c = true, cpp = true }
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				end
				return { timeout_ms = 500, lsp_format = "fallback" }
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				scss = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", "prettier", stop_after_first = true },
				jsonc = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "prettierd", "prettier", stop_after_first = true },
				rust = { "rustfmt" },
				go = { "gofumpt", "golines" },
				elixir = { "mix" },
				java = { "google-java-format" },
				kotlin = { "ktlint" },
				yaml = { "prettierd", "prettier", stop_after_first = true },
				toml = { "taplo" },
				terraform = { "terraform_fmt" },
				["terraform-vars"] = { "terraform_fmt" },
				nix = { "nixpkgs-fmt" },
			},
		},
	},

	-- [[ Plugin: Blink.cmp ]]
	-- Fast autocompletion with LSP, path, and snippet sources
	{
		"saghen/blink.cmp",
		event = "VimEnter",
		version = "1.*",
		dependencies = {
			-- Snippet engine for expandable completions
			{
				"L3MON4D3/LuaSnip",
				version = "2.*",
				build = (function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				opts = {},
			},
		},
		--- @module 'blink.cmp'
		--- @type blink.cmp.Config
		opts = {
			keymap = { preset = "default" }, -- See :h blink-cmp-config-keymap
			appearance = { nerd_font_variant = "mono" },
			completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } },
			sources = { default = { "lsp", "path", "snippets" } },
			snippets = { preset = "luasnip" },
			fuzzy = { implementation = "lua" },
			signature = { enabled = true },
		},
	},

	-- [[ Plugin: UI ]]

	-- Solarized dark colorscheme
	{
		"ishan9299/nvim-solarized-lua",
		priority = 1000,
		config = function()
			vim.o.background = "dark"
			vim.cmd.colorscheme("solarized")
		end,
	},

	-- Tab-like bar showing open buffers at the top of the screen
	{ "akinsho/bufferline.nvim", version = "*", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {} },

	-- File browser extension for Telescope (replaces netrw)
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").load_extension("file_browser")
			vim.keymap.set("n", "<leader>fb", ":Telescope file_browser<CR>", { desc = "[F]ile [B]rowser" })
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
		end,
	},

	-- [[ Plugin: Git ]]
	-- Git commands in Vim (:G status, :G commit, :G blame, etc.)
	{ "tpope/vim-fugitive" },

	-- [[ Plugin: LaTeX ]]
	-- LaTeX editing with compilation, preview, and syntax support
	{
		"lervag/vimtex",
		ft = { "tex", "latex" },
		config = function()
			vim.g.vimtex_view_method = "skim"
		end,
	},

	-- [[ Plugin: Extras ]]

	-- Highlights TODO, FIXME, NOTE, etc. in comments
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	-- Collection of small, independent plugins:
	-- - mini.ai: Enhanced text objects (va), ci', yinq, etc.)
	-- - mini.surround: Add/delete/change surroundings (saiw), sd', sr)')
	-- - mini.statusline: Minimal statusline
	{
		"nvim-mini/mini.nvim",
		config = function()
			require("mini.ai").setup({ n_lines = 500 })
			require("mini.surround").setup()
			local statusline = require("mini.statusline")
			statusline.setup({ use_icons = vim.g.have_nerd_font })
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end
		end,
	},

	-- [[ Plugin: Treesitter ]]
	-- Syntax highlighting and code parsing using tree-sitter grammars
	{
		"nvim-treesitter/nvim-treesitter",
		config = function()
			local filetypes = {
				"bash",
				"c",
				"cpp",
				"lua",
				"luadoc",
				"vim",
				"vimdoc",
				"query",
				"css",
				"html",
				"javascript",
				"json",
				"tsx",
				"typescript",
				"rust",
				"go",
				"gomod",
				"gosum",
				"zig",
				"java",
				"kotlin",
				"scala",
				"elixir",
				"erlang",
				"haskell",
				"ocaml",
				"clojure",
				"dockerfile",
				"terraform",
				"yaml",
				"toml",
				"nix",
				"cmake",
				"make",
				"xml",
				"csv",
				"sql",
				"graphql",
				"markdown",
				"markdown_inline",
				"latex",
				"diff",
				"python",
				"ruby",
				"perl",
				"awk",
				"regex",
				"git_rebase",
				"gitcommit",
			}
			require("nvim-treesitter").install(filetypes)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = filetypes,
				callback = function()
					vim.treesitter.start()
				end,
			})
		end,
	},

	-- [[ Optional Plugins ]]
	-- Uncomment to enable (restart required)
	require("kickstart.plugins.debug"), -- DAP debugger integration
	require("kickstart.plugins.lint"), -- Async linting with nvim-lint
	require("kickstart.plugins.indent_line"), -- Visual indent guides
	require("kickstart.plugins.autopairs"), -- Auto-close brackets and quotes
	require("kickstart.plugins.neo-tree"), -- File tree sidebar
	require("kickstart.plugins.gitsigns"), -- Git hunk navigation keymaps

	-- Custom plugins: create files in lua/custom/plugins/ and uncomment:
	-- { import = 'custom.plugins' },
}, {
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

-- vim: ts=2 sts=2 sw=2 et
