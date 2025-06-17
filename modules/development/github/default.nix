{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.development.github;
in
{
  options.modules.development.github = {
    enable = mkEnableOption "GitHub CLI and development tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gh
      act
    ];

    programs = {
      # comment out until resolive this issue.
      # https://github.com/nix-community/home-manager/issues/1654
      # gh = {
      #   enable = true;
      #   settings = {
      #     git_protocol = "ssh";
      #   };

      # };
    };
  };
}
