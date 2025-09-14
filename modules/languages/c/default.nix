{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.languages.c;
in
{
  options.modules.languages.c = {
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
