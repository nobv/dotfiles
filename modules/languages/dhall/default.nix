{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.languages.dhall;
in
{
  options.modules.languages.dhall = {
    enable = mkEnableOption "Dhall configuration language";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      dhall-lsp-server
    ];
  };
}
