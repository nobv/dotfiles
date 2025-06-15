{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.checkers;
in
{
  options.modules.checkers = {
    enable = mkEnableOption "Spell checkers and text validation tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      hunspell
    ];
  };
}
