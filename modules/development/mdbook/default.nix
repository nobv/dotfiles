{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.mdbook;
in
{
  options.modules.tools.mdbook = {
    enable = mkEnableOption "Create books from markdown files";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      brews = [ "mdbook" ];
    };
  };
}