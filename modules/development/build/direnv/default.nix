{
  config,
  lib,
  pkgs,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.development.build.direnv;
in
{
  options.modules.development.build.direnv = {
    enable = mkEnableOption "direnv shell environment manager";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };
  };
}
