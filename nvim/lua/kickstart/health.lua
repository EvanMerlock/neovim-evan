--[[
--
-- This file is not required for your own configuration,
-- but helps people determine if their system is setup correctly.
--
-- Updated for Nix-based tool management (Mason disabled).
--
--]]

local check_version = function()
  local verstr = tostring(vim.version())
  if not vim.version.ge then
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
    return
  end

  if vim.version.ge(vim.version(), '0.11') then
    vim.health.ok(string.format("Neovim version is: '%s'", verstr))
  else
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
  end
end

local check_external_reqs = function()
  -- Basic utils: `git`, `make`, `unzip`
  for _, exe in ipairs { 'git', 'make', 'unzip', 'rg' } do
    local is_executable = vim.fn.executable(exe) == 1
    if is_executable then
      vim.health.ok(string.format("Found executable: '%s'", exe))
    else
      vim.health.warn(string.format("Could not find executable: '%s'", exe))
    end
  end

  return true
end

local check_lsps = function()
  vim.health.start 'LSP Servers (Nix-provided)'

  local lsps = {
    -- Web Development
    { name = 'typescript-language-server', desc = 'TypeScript/JavaScript' },
    { name = 'vscode-html-language-server', desc = 'HTML' },
    { name = 'vscode-css-language-server', desc = 'CSS' },
    { name = 'tailwindcss-language-server', desc = 'Tailwind CSS' },
    { name = 'vscode-eslint-language-server', desc = 'ESLint' },
    { name = 'vscode-json-language-server', desc = 'JSON' },

    -- Backend Languages
    { name = 'rust-analyzer', desc = 'Rust' },
    { name = 'gopls', desc = 'Go' },
    { name = 'elixir-ls', desc = 'Elixir' },
    { name = 'jdtls', desc = 'Java' },
    { name = 'kotlin-language-server', desc = 'Kotlin' },
    { name = 'lua-language-server', desc = 'Lua' },

    -- Infrastructure/Config
    { name = 'yaml-language-server', desc = 'YAML' },
    { name = 'terraform-ls', desc = 'Terraform' },
    { name = 'taplo', desc = 'TOML' },
  }

  for _, lsp in ipairs(lsps) do
    local is_executable = vim.fn.executable(lsp.name) == 1
    if is_executable then
      vim.health.ok(string.format('%s: found %s', lsp.desc, lsp.name))
    else
      vim.health.warn(string.format('%s: %s not found', lsp.desc, lsp.name))
    end
  end
end

local check_formatters = function()
  vim.health.start 'Formatters (Nix-provided)'

  local formatters = {
    { name = 'prettierd', desc = 'Prettier (daemon)' },
    { name = 'eslint_d', desc = 'ESLint (daemon)' },
    { name = 'rustfmt', desc = 'Rust' },
    { name = 'gofumpt', desc = 'Go (gofumpt)' },
    { name = 'golines', desc = 'Go (golines)' },
    { name = 'stylua', desc = 'Lua' },
    { name = 'google-java-format', desc = 'Java' },
    { name = 'ktlint', desc = 'Kotlin' },
  }

  for _, fmt in ipairs(formatters) do
    local is_executable = vim.fn.executable(fmt.name) == 1
    if is_executable then
      vim.health.ok(string.format('%s: found %s', fmt.desc, fmt.name))
    else
      vim.health.warn(string.format('%s: %s not found', fmt.desc, fmt.name))
    end
  end
end

local check_linters = function()
  vim.health.start 'Linters (Nix-provided)'

  local linters = {
    { name = 'eslint_d', desc = 'ESLint (daemon)' },
    { name = 'golangci-lint', desc = 'Go' },
    { name = 'selene', desc = 'Lua' },
    { name = 'yamllint', desc = 'YAML' },
    { name = 'tflint', desc = 'Terraform' },
    { name = 'hadolint', desc = 'Dockerfile' },
  }

  for _, linter in ipairs(linters) do
    local is_executable = vim.fn.executable(linter.name) == 1
    if is_executable then
      vim.health.ok(string.format('%s: found %s', linter.desc, linter.name))
    else
      vim.health.warn(string.format('%s: %s not found', linter.desc, linter.name))
    end
  end
end

return {
  check = function()
    vim.health.start 'kickstart.nvim (Nix Edition)'

    vim.health.info [[NOTE: This configuration uses Nix for tool management.
  Mason is disabled. All LSPs, formatters, and linters should be
  provided via Nix (either through `nix run` or home-manager).

  If tools are missing, ensure you're running neovim through:
    - `nix run .` (standalone)
    - `nix develop` (dev shell)
    - home-manager with this module enabled]]

    local uv = vim.uv or vim.loop
    vim.health.info('System Information: ' .. vim.inspect(uv.os_uname()))

    check_version()
    check_external_reqs()
    check_lsps()
    check_formatters()
    check_linters()
  end,
}
