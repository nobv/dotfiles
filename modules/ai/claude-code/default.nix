{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.ai.claude-code;
  dotfilesPath = "/Users/${username}/.dotfiles";
in
{
  options.modules.ai.claude-code.enable = mkEnableOption "Claude Code CLI and dotfiles";

  config = mkIf cfg.enable {
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
            config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/ai/claude-code/settings.json";
          ".claude/CLAUDE.md".source =
            config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/ai/claude-code/CLAUDE.md";
          ".config/ccstatusline/settings.json".source =
            config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/ai/claude-code/ccstatusline-settings.json";
        };
      };
  };
}
