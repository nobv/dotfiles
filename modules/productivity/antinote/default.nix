{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.productivity.antinote;
in
{
  options.modules.productivity.antinote = {
    enable = mkEnableOption "Antinote temporary notes and scratchpad app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "antinote" ];
    };
  };
}
