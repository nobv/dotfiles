{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.mdbook;
in
{
  options.modules.development.mdbook = {
    enable = mkEnableOption "Create books from markdown files";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "mdbook" ];
    };
  };
}