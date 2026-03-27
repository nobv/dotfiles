{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.ai.claude;
  dotfilesPath = "/Users/${username}/.dotfiles";
in
{
  options.modules.ai.claude = {
    enable = mkEnableOption "Claude AI assistant desktop app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "claude" ];
    };

    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "claude-code"
      ];

    environment.systemPackages = with pkgs; [
      claude-code
    ];

    home-manager.users.${username} =
      { config, ... }:
      {
        home.file = {
          ".claude/settings.json".source =
            config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/ai/claude/settings.json";
          ".claude/CLAUDE.md".source =
            config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/ai/claude/CLAUDE.md";
          ".config/ccstatusline/settings.json".source =
            config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/ai/claude/ccstatusline-settings.json";
        };
      };
  };
}
