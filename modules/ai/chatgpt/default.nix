{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.chatgpt;
in
{
  options.modules.app.chatgpt = {
    enable = mkEnableOption "ChatGPT desktop application";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "chatgpt" ];
    };
  };
}