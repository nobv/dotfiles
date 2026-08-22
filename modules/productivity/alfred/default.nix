{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.productivity.alfred;
in
{
  options.modules.productivity.alfred = {
    enable = mkEnableOption "Application launcher and productivity software";
  };

  config = mkIf cfg.enable {
    # The settings bundle next to this file is tracked in git, but Nix does not
    # reference it: Alfred keeps the absolute path of its preferences folder in
    # ~/Library/Application Support/Alfred/prefs.json, so no symlink is
    # involved. Alfred writes the bundle while it runs, so settings changes
    # land here as diffs — commit them as they appear, or `just git sync` will
    # refuse to fast-forward.
    #
    # Once per machine: Alfred Preferences -> Advanced -> Syncing ->
    # Set preferences folder... -> <dotfiles>/modules/productivity/alfred
    # then `just alfred sync` to install the workflows, which the bundle does
    # not carry (see .gitignore and workflows.txt next to this file).
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "alfred" ];
    };
  };
}
