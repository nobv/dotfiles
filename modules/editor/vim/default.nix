{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.editor.vim;
in
{
  options.modules.editor.vim = {
    enable = mkEnableOption "Vim text editor";
  };

  config = mkIf cfg.enable {
    programs = {
      vim = { enable = true; };
    };
  };
}


