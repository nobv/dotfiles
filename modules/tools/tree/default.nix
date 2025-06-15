{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.tree;
in
{
  options.modules.tools.tree = {
    enable = mkEnableOption "tree, a recursive directory listing command";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      tree
    ];
  };
}
