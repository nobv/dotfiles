{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    dhall-lsp-server
  ];
}
