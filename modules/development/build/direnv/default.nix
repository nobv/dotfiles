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
    home-manager.users.${username}.programs = {
      zsh.initContent = mkBefore ''
        export DIRENV_LOG_FORMAT=""
      '';

      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv = {
          enable = true;
        };
        config = {
          global = {
            # direnv: loading / direnv: export ~PATH ... のログを抑制
            log_format = "";
          };
        };
      };
    };
  };
}
