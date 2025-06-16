{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.pre-commit;
in
{
  options.modules.tools.pre-commit = {
    enable = mkEnableOption "Framework for managing and maintaining multi-language pre-commit hooks";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      brews = [ "pre-commit" ];
    };
  };
}