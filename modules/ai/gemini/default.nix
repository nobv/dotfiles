{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.modules.ai.gemini;
in
{
  options.modules.ai.gemini = {
    enable = mkEnableOption "AI agent that brings the power of Gemini directly into your terminal";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gemini-cli
    ];
  };
}
