{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.security."1password";
in
{
  options.modules.security."1password" = {
    enable = mkEnableOption "1Password password manager";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "1password" ];
    };
  };
}
