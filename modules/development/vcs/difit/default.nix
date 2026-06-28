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
      # Inside cmux, difit's `open(url)` is intercepted by cmux's `open` shim
      # (HTTP/S URLs route to cmux's built-in browser), so no special handling
      # is needed here — just run difit.
      (pkgs.writeShellScriptBin "difit" ''
        exec ${pkgs.nodejs_24}/bin/npx --yes difit@5.0.2 "$@"
      '')
    ];
  };
}
