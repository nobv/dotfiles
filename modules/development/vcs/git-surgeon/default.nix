{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.vcs.git-surgeon;
in
{
  options.modules.development.vcs.git-surgeon = {
    enable = mkEnableOption "Enable git-surgeon - surgical, non-interactive git hunk control for AI agents";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      taps = [ "raine/git-surgeon" ];
      brews = [ "raine/git-surgeon/git-surgeon" ];
    };
  };
}
