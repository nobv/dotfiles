{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.claude;
in
{
  options.modules.app.claude = {
    enable = mkEnableOption "Claude AI assistant desktop app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "claude" ];
    };
  };
}