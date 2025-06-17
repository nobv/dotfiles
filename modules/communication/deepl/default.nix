{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.communication.deepl;
in
{
  options.modules.communication.deepl = {
    enable = mkEnableOption "DeepL translator app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "deepl" ];
    };
  };
}