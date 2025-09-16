{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.vcs.fork;
in
{
  options.modules.development.vcs.fork = {
    enable = mkEnableOption "Fork Git client";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "fork" ];
    };
  };
}
