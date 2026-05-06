{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.development.vcs.worktrunk;
in
{
  options.modules.development.vcs.worktrunk = {
    enable = mkEnableOption "Enable worktrunk - CLI for Git worktree management";
    enableZshIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Enable zsh shell integration so `wt switch` can change directories";
    };
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "worktrunk" ];
    };

    home-manager.users.${username} = mkIf cfg.enableZshIntegration {
      programs.zsh.initContent = lib.mkAfter ''
        if command -v wt >/dev/null 2>&1; then
          eval "$(wt config shell init zsh)"
        fi
      '';
    };
  };
}
