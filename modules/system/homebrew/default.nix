{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.system.homebrew;
in
{
  options.modules.system.homebrew = {
    enable = mkEnableOption "Enable homebrew package manager";
  };

  config = mkIf cfg.enable {
    homebrew = {
      brewPrefix = "/opt/homebrew/bin";
      enable = true;
      onActivation = {
        autoUpdate = true;
        cleanup = "zap";
        upgrade = true;
      };
      global = {
        brewfile = true;
        lockfiles = true;
      };
    };
  };
}