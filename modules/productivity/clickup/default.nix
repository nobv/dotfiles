{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.productivity.clickup;
in
{
  options.modules.productivity.clickup = {
    enable = mkEnableOption "Productivity platform for tasks, docs, goals, and chat";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "clickup" ];
    };
  };
}
