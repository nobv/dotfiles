{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.development.cli-tools.peco;
  pecoConfig = import ./config.nix;
in
{
  options.modules.development.cli-tools.peco = {
    enable = mkEnableOption "peco interactive filtering tool";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      peco
    ];

    home-manager.users.${username}.home.file = {
      "config" = {
        target = ".config/peco/config.json";
        text = builtins.toJSON pecoConfig;
      };
    };
  };
}
