{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.ai.apm;
  dotfilesPath = "/Users/${username}/.dotfiles";
in
{
  options.modules.ai.apm.enable = mkEnableOption "Agent Package Manager (microsoft/apm)";

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      taps = [
        {
          name = "microsoft/apm";
          trusted = true;
        }
      ];
      brews = [ "microsoft/apm/apm" ];
    };

    home-manager.users.${username} =
      { config, ... }:
      {
        # apm.yml is immutable (nix-store). apm.lock.yaml uses
        # mkOutOfStoreSymlink so that `apm install -g` updates can flow
        # back to the dotfiles repo for version control.
        # Frozen install is wired into `just switch` (see Justfile), not
        # home.activation, so rebuild and apm-sync stay separately
        # observable.
        home.file = {
          ".apm/apm.yml".source = ./apm.yml;
          ".apm/apm.lock.yaml".source =
            config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/ai/apm/apm.lock.yaml";
        };
      };
  };
}
