{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.font;
in
{
  options.modules.font = {
    enable = mkEnableOption "Enable font module";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # hasklig v1.1 doesn't work in VSCode well.
      # For some reason, this PR was closed.
      # https://github.com/NixOS/nixpkgs/pull/135938
      # hasklig
      jetbrains-mono
      nerd-fonts.sauce-code-pro
      nerd-fonts.hack
      nerd-fonts.hasklug
      nerd-fonts.fira-code
    ];
    #fonts = { fontconfig = { enable = true; }; };
  };
}

