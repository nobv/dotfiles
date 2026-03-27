{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.productivity.todoist;
in
{
  options.modules.productivity.todoist = {
    enable = mkEnableOption "Todoist task management app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "todoist" ];
    };
  };
}
