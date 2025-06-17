{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.languages.deno;
in
{
  options.modules.languages.deno = {
    enable = mkEnableOption "Deno JavaScript/TypeScript runtime";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      deno
    ];
  };
}
