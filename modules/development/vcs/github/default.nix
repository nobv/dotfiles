{ config
, lib
, pkgs
, username
, ...
}:

with lib;

let
  cfg = config.modules.development.vcs.github;
in
{
  options.modules.development.vcs.github = {
    enable = mkEnableOption "GitHub CLI and development tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      act
    ];

    home-manager.users.${username}.programs = {
      gh = {
        enable = true;
        settings = {
          git_protocol = "ssh";
        };
      };
    };
  };
}
