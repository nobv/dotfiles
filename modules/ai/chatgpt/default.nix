{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.ai.chatgpt;
in
{
  options.modules.ai.chatgpt = {
    enable = mkEnableOption "ChatGPT desktop application";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "chatgpt" ];
    };
  };
}
