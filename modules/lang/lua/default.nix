{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    lua
    #luajitPackages.lua-lsp # https://github.com/Alloyed/lua-lsp
    sumneko-lua-language-server # https://github.com/LuaLS/lua-language-server
  ];
}
