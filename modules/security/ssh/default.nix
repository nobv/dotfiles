{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.security.ssh;
in
{
  options.modules.security.ssh = {
    enable = mkEnableOption "OpenSSH client configuration (~/.ssh/config)";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.programs.ssh = {
      enable = true;

      # Leave `package` null: setting it puts a nixpkgs ssh ahead of Apple's on
      # PATH, because .zprofile deliberately orders nix paths first.

      # Upstream's defaults are deprecated and warn on activation.
      enableDefaultConfig = false;

      settings."*" = {
        UserKnownHostsFile = "~/.ssh/known_hosts";
      };
    };
  };
}
