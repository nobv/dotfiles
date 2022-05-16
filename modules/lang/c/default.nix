{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    clang
    clang-tools
    coreutils
    editorconfig-core-c
  ];
}
