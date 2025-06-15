{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.lang.deno;
in
{
  options.modules.lang.deno = {
    enable = mkEnableOption "Deno JavaScript/TypeScript runtime";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      deno
    ];
  };
}
