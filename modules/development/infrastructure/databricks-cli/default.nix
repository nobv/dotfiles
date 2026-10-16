{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.infrastructure.databricks-cli;
in
{
  options.modules.development.infrastructure.databricks-cli = {
    enable = mkEnableOption "Command-line interface for the Databricks platform";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      taps = [
        {
          name = "databricks/tap";
          trusted = true;
        }
      ];
      brews = [ "databricks/tap/databricks" ];
    };
  };
}
