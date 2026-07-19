{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.languages.bun;
in
{
  options.modules.languages.bun = {
    enable = mkEnableOption "Bun JavaScript/TypeScript runtime and package manager";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bun
    ];
  };
}
