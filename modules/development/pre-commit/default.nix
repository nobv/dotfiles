{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.pre-commit;
in
{
  options.modules.development.pre-commit = {
    enable = mkEnableOption "Framework for managing and maintaining multi-language pre-commit hooks";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "pre-commit" ];
    };
  };
}