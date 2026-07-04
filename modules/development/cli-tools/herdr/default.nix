{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.cli-tools.herdr;
in
{
  options.modules.development.cli-tools.herdr = {
    enable = mkEnableOption "herdr, an agent multiplexer that lives in your terminal";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "herdr" ];
    };
  };
}
