{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.editors.vim;
in
{
  options.modules.editors.vim = {
    enable = mkEnableOption "Vim text editor";
  };

  config = mkIf cfg.enable {
    programs = {
      vim = { enable = true; };
    };
  };
}


