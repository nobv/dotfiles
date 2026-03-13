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
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = { config, ... }: {
      xdg.configFile = {
        "nvim/after".source =
          config.lib.file.mkOutOfStoreSymlink
            "${dotfilesPath}/modules/editors/neovim/after";

        "nvim/lua".source =
          config.lib.file.mkOutOfStoreSymlink
            "${dotfilesPath}/modules/editors/neovim/lua";
      };

      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        extraConfig = "source ~/.config/nvim/lua/init.lua";
        plugins = plugins.vimPlugins;
      };
    };
  };
}
