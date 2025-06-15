{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.lang.lua;
in
{
  options.modules.lang.lua = {
    enable = mkEnableOption "Lua programming language";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lua
      #luajitPackages.lua-lsp # https://github.com/Alloyed/lua-lsp
      # lua-language-server # https://github.com/LuaLS/lua-language-server
    ];
  };
}
