{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.editor.typora;
in
{
  options.modules.editor.typora = {
    enable = mkEnableOption "Typora markdown editor";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "typora" ];
    };
  };
}