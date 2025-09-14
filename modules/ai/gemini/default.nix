{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.modules.ai.gemini;
in
{
  options.modules.ai.gemini = {
    enable = mkEnableOption "gemini AI application";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.programs.gemini = {
      enable = true;
      # Add configuration options here
    };
  };
}
