{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.editors.neovim;
  plugins = (import ./lua/plugins pkgs);
  dotfilesPath = "/Users/${username}/.dotfiles";
in
{
  options.modules.editors.neovim = {
    enable = mkEnableOption "Neovim text editor with custom configuration";

    lazyvim.enable = mkEnableOption "LazyVim Neovim distro, run via NVIM_APPNAME=lazyvim (lvim)";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} =
      { config, ... }:
      {
        xdg.configFile = {
          "nvim/after".source =
            config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/editors/neovim/after";

          "nvim/lua".source =
            config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/editors/neovim/lua";
        }
        // optionalAttrs cfg.lazyvim.enable {
          # Coexists with the hand-rolled config above; launch this one with
          # `lvim`. The config lives in the repo and is symlinked
          # out-of-store, so edits and lazy.nvim's lazy-lock.json writes are
          # live without a rebuild.
          "lazyvim".source =
            config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/editors/neovim/lazyvim/config";
        };

        programs.neovim = {
          enable = true;
          viAlias = true;
          vimAlias = true;
          vimdiffAlias = true;
          withRuby = false;
          withPython3 = false;
          extraConfig = "source ~/.config/nvim/lua/init.lua";
          plugins = plugins.vimPlugins;
        };

        home.packages = mkIf cfg.lazyvim.enable (
          with pkgs;
          [
            # External CLIs LazyVim / its extras call from PATH. Plugins and
            # most LSPs are managed at runtime by lazy.nvim / Mason (pinned
            # via the committed lazy-lock.json); these are the bits Mason
            # does not reliably provide on this setup.
            ripgrep # grep / snacks picker
            fd # file finding
            fzf # fuzzy finder
            lazygit # git UI (<leader>gg)
            tree-sitter # nvim-treesitter `main` needs the CLI to build parsers
            nixfmt-rfc-style # nix extra: formatter (conform -> nixfmt)
            statix # nix extra: linter (nvim-lint)
            nil # nix extra: LSP (nil_ls); paired with mason=false so Mason won't cargo-build it
            # marksman / gopls / pyright / etc. are installed by Mason at runtime
          ]
        );

        programs.zsh.shellAliases = mkIf cfg.lazyvim.enable {
          # `vim`/`vi` shadow the hand-rolled config's binaries in interactive
          # shells; `nvim` stays the hand-rolled config. Merges with the zsh
          # module's aliases.
          lvim = "NVIM_APPNAME=lazyvim nvim";
          vim = "NVIM_APPNAME=lazyvim nvim";
          vi = "NVIM_APPNAME=lazyvim nvim";
        };
      };
  };
}
