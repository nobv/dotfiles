{ config
, pkgs
, lib
, username
, ...
}:

with lib;

let
  cfg = config.modules.development.vcs.git;
  settings = import ./settings.nix;
  aliases = import ./aliases.nix;
in
{
  options.modules.development.vcs.git = {
    enable = mkEnableOption "Enable Git version control system with enhanced tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ghq
      tig
      lazygit
    ];

    # Git configuration should be in Home Manager context
    home-manager.users.${username}.programs.git = {
      enable = true;
      settings = settings;
      ignores = lib.splitString "\n" (builtins.readFile ./.gitignore_global);
      # package = unstable.git;
    };
  };
}
