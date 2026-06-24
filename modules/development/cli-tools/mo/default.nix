{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.cli-tools.mo;
in
{
  options.modules.development.cli-tools.mo = {
    enable = mkEnableOption "mo - Markdown viewer in browser with live-reload (k1LoW/mo)";
  };

  config = mkIf cfg.enable {
    # Not in nixpkgs; install via Homebrew tap. k1LoW/tap is a non-official tap,
    # so it must be marked trusted or HOMEBREW_REQUIRE_TAP_TRUST (default since
    # Homebrew 6.0.0) aborts activation. Requires nix-darwin >= 2026-06-17 (PR #1789).
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      taps = [ { name = "k1LoW/tap"; trusted = true; } ];
      brews = [ "k1LoW/tap/mo" ];
    };
  };
}
