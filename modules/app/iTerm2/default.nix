{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.jetbrains;
in
{
  options.modules.app.jetbrains = {
    enable = mkEnableOption "JetBrains Toolbox for IDE management";
  };

  config = mkIf cfg.enable {
    homebrew = {
      casks = [
        "jetbrains-toolbox"
      ];
    };
  };
}
