{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.tree;
in
{
  options.modules.development.tree = {
    enable = mkEnableOption "tree, a recursive directory listing command";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      tree
    ];
  };
}
