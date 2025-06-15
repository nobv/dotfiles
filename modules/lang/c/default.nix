{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.lang.c;
in
{
  options.modules.lang.c = {
    enable = mkEnableOption "C/C++ development environment";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # clang
      # gcc
      # clang-tools
      # coreutils
      # editorconfig-core-c
      # libiconv
      # libiconvReal
    ];
  };
}
