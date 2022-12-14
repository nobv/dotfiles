{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    lua
    luajitPackages.lua-lsp # https://github.com/Alloyed/lua-lsp
  ];
}
