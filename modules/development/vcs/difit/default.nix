{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.vcs.difit;
in
{
  options.modules.development.vcs.difit = {
    enable = mkEnableOption "Enable difit - Git diff viewer with GitHub-like UI";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "difit" ''
        exec ${pkgs.nodejs_24}/bin/npx --yes difit "$@"
      '')
    ];
  };
}
