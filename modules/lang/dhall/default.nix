{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.lang.dhall;
in
{
  options.modules.lang.dhall = {
    enable = mkEnableOption "Dhall configuration language";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      dhall-lsp-server
    ];
  };
}
