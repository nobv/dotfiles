{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.editors.lazyvim;
  dotfilesPath = "/Users/${username}/.dotfiles";
in
{
  options.modules.editors.lazyvim = {
    enable = mkEnableOption "LazyVim Neovim distro, run via NVIM_APPNAME=lazyvim (lvim)";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} =
      { config, ... }:
      {
        # Coexists with the hand-rolled `nvim` (modules.editors.neovim); launch
        # this one with `lvim`. The config lives in the repo and is symlinked
        # out-of-store, so edits and lazy.nvim's lazy-lock.json writes are live
        # without a rebuild. Requires the neovim module for the `nvim` binary.
        xdg.configFile."lazyvim".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/editors/lazyvim/config";

        # External CLIs LazyVim / its extras call from PATH. Plugins and most
        # LSPs are managed at runtime by lazy.nvim / Mason (pinned via the
        # committed lazy-lock.json); these are the bits Mason does not reliably
        # provide on this setup.
        home.packages = with pkgs; [
          ripgrep # grep / snacks picker
          fd # file finding
          fzf # fuzzy finder
          lazygit # git UI (<leader>gg)
          tree-sitter # nvim-treesitter `main` needs the CLI to build parsers
          nixfmt-rfc-style # nix extra: formatter (conform -> nixfmt)
          statix # nix extra: linter (nvim-lint)
          nil # nix extra: LSP (nil_ls); paired with mason=false so Mason won't cargo-build it
          # marksman / gopls / pyright / etc. are installed by Mason at runtime
        ];

        # Launch the LazyVim profile. `vim`/`vi` shadow the neovim module's
        # binaries in interactive shells; `nvim` stays the hand-rolled config.
        # Merges with the zsh module's aliases.
        programs.zsh.shellAliases = {
          lvim = "NVIM_APPNAME=lazyvim nvim";
          vim = "NVIM_APPNAME=lazyvim nvim";
          vi = "NVIM_APPNAME=lazyvim nvim";
        };
      };
  };
}
