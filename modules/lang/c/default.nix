{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    # clang
    # gcc
    # clang-tools
    # coreutils
    # editorconfig-core-c
    # libiconv
    # libiconvReal
  ];
}
