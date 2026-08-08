{ self }:

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.neovim-evan;
  packages = import ./packages.nix { inherit pkgs; };

  # Language toolchains (LSP + formatter + linter) the user opted into.
  selectedLangs = if cfg.allLanguages then packages.languageNames else cfg.languages;

  # Custom languages declared as home-manager blocks. Each block declares its
  # filetypes once, a required LSP server, and optional formatters/linters; we
  # fold them into the JSON payload consumed by nvim/lua/neovim_evan_custom.lua.
  langs = cfg.customLanguages;

  # server.name -> vim.lsp.config table, with the block filetypes injected
  # unless the server config sets its own.
  serverConfigs = lib.foldlAttrs
    (acc: _: l: acc // {
      ${l.server.name} = l.server.config // {
        filetypes = l.server.config.filetypes or l.filetypes;
      };
    }) { } langs;

  # filetype -> [tool names], using each block's filetypes for its tools.
  # Languages with no tools of this kind contribute nothing (no empty entries).
  byFt = getTools: lib.foldlAttrs
    (acc: _: l:
      let names = lib.attrNames (getTools l); in
      if names == [ ] then acc
      else lib.foldl' (a: ft: a // { ${ft} = (a.${ft} or [ ]) ++ names; }) acc l.filetypes)
    { } langs;

  # extension -> filetype, for filetypes Neovim does not detect on its own.
  # Merged into init.lua's own vim.filetype.add call.
  filetypeExtensions = lib.foldlAttrs (acc: _: l: acc // l.filetypeExtensions) { } langs;

  # tool name -> definition, keeping only non-empty definitions.
  defsOf = getTools: lib.filterAttrs (_: d: d != { })
    (lib.foldlAttrs (acc: _: l: acc // lib.mapAttrs (_: t: t.definition) (getTools l)) { } langs);

  pkgsIn = attrs: lib.filter (p: p != null) (lib.mapAttrsToList (_: t: t.package) attrs);

  # Binaries for every custom server/formatter/linter.
  customPkgs = lib.concatLists (lib.mapAttrsToList
    (_: l:
      lib.optional (l.server.package != null) l.server.package
      ++ pkgsIn l.formatters ++ pkgsIn l.linters)
    langs);

  customConfig = {
    servers = serverConfigs;
    filetype_extensions = filetypeExtensions;
    formatters_by_ft = byFt (l: l.formatters);
    formatter_defs = defsOf (l: l.formatters);
    linters_by_ft = byFt (l: l.linters);
    linter_defs = defsOf (l: l.linters);
  };
  hasCustom = langs != { };

  # Serialize the payload to a store JSON file and generate a Lua module that
  # reads it (readfile avoids any long-bracket escaping concerns).
  customJsonFile = pkgs.writeText "neovim-evan-custom.json" (builtins.toJSON customConfig);
  customLuaModule =
    ''return vim.json.decode(table.concat(vim.fn.readfile("${customJsonFile}"), "\n"))'';

  optInPackages = packages.packagesForLanguages selectedLangs ++ cfg.extraPackages ++ customPkgs;

  # Submodule for a formatter/linter entry: its binary plus an optional
  # conform/nvim-lint invocation definition.
  toolModule = lib.types.submodule {
    options = {
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        description = "Package providing the tool binary (added to Neovim's PATH).";
      };
      definition = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = ''
          Optional declarative definition for the tool, passed verbatim to
          conform's `formatters.<name>` or nvim-lint's `linters.<name>`.
          Function-valued fields are not supported (JSON-serialized).
        '';
      };
    };
  };

  languageModule = lib.types.submodule {
    options = {
      filetypes = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        example = [ "gleam" ];
        description = "Filetypes this language covers (used for the LSP and formatter/linter mappings).";
      };
      filetypeExtensions = lib.mkOption {
        type = with lib.types; attrsOf str;
        default = { };
        example = { hlisp = "hlisp"; };
        description = ''
          File extensions to map to a filetype, passed to vim.filetype.add.
          Needed when the language's filetype is not one Neovim detects by
          itself; without it the LSP has nothing to attach to.
        '';
      };
      server = lib.mkOption {
        type = lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "LSP name used with vim.lsp.enable (e.g. \"gleam\").";
            };
            package = lib.mkOption {
              type = lib.types.nullOr lib.types.package;
              default = null;
              description = "Package providing the language server binary.";
            };
            config = lib.mkOption {
              type = lib.types.attrs;
              default = { };
              description = ''
                Config passed verbatim to vim.lsp.config (cmd, root_markers,
                settings, …). Filetypes default to the block's `filetypes`.
              '';
            };
          };
        };
        description = "Language server definition (required).";
      };
      formatters = lib.mkOption {
        type = with lib.types; attrsOf toolModule;
        default = { };
        description = "Formatters for this language, keyed by conform formatter name.";
      };
      linters = lib.mkOption {
        type = with lib.types; attrsOf toolModule;
        default = { };
        description = "Linters for this language, keyed by nvim-lint linter name.";
      };
    };
  };
in
{
  options.programs.neovim-evan = {
    enable = lib.mkEnableOption "neovim-evan configuration";

    languages = lib.mkOption {
      type = with lib.types; listOf (enum packages.languageNames);
      default = [];
      example = [ "rust" "go" ];
      description = ''
        Language toolchains to install for Neovim (each bundles the LSP,
        formatter, and linter for that language). By default nothing is
        installed and LSPs are inherited from the ambient environment/PATH.
      '';
    };

    extraPackages = lib.mkOption {
      type = with lib.types; listOf package;
      default = [];
      example = lib.literalExpression "[ pkgs.some-custom-lsp ]";
      description = ''
        Extra packages (e.g. custom or newly-available LSPs) to make available
        to Neovim without adding them to the ambient environment.
      '';
    };

    allLanguages = lib.mkEnableOption "install every bundled language toolchain";

    customLanguages = lib.mkOption {
      type = with lib.types; attrsOf languageModule;
      default = { };
      example = lib.literalExpression ''
        {
          gleam = {
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
        }
      '';
      description = ''
        Custom languages to register with Neovim entirely from home-manager,
        without editing init.lua. Each block declares its filetypes, a required
        LSP server, and optional formatters/linters (each carrying its own
        package). Definitions are declarative/JSON-serializable only.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withRuby = false;
      withPython3 = true;
      extraWrapperArgs = [
        # Core tools are always bundled so the editor/plugins work.
        "--prefix"
        "PATH"
        ":"
        (lib.makeBinPath packages.tools)
      ] ++ lib.optionals (optInPackages != []) [
        # Opt-in tools are appended so matching binaries already in the user's
        # environment take precedence, with these as a fallback.
        "--suffix"
        "PATH"
        ":"
        (lib.makeBinPath optInPackages)
      ] ++ [
        "--set"
        "YAMLLINT_CONFIG_FILE"
        "${../yamllint.yaml}"
      ];
    };

    # Symlink the config directory
    xdg.configFile."nvim" = {
      source = ../nvim;
      recursive = true;
    };

    # Generated Lua module carrying custom-language definitions, delivered the
    # same way as the checked-in config Lua. init.lua/lint.lua pcall-require it.
    xdg.configFile."nvim/lua/neovim_evan_custom.lua" = lib.mkIf hasCustom {
      text = customLuaModule;
    };
  };
}
