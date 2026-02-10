{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.languages.lua;
in
{
  options.modules.languages.lua = {
    enable = mkEnableOption "Lua programming language";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lua
      lua-language-server
      #luajitPackages.lua-lsp # https://github.com/Alloyed/lua-lsp
      # lua-language-server # https://github.com/LuaLS/lua-language-server
    ];
  };
}
