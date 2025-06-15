{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.git;
  extraConfig = import ./extraConfig.nix;
  aliases = import ./aliases.nix;
in
{
  options.modules.tools.git = {
    enable = mkEnableOption "Enable Git version control system with enhanced tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ghq
      tig
      lazygit
    ];

    programs.git = {
      enable = true;
      aliases = aliases;
      extraConfig = extraConfig;
      ignores = lib.splitString "\n" (builtins.readFile ./.gitignore_global);
      userEmail = "36393714+nobv@users.noreply.github.com";
      userName = "nobv";
      # package = unstable.git;
    };
  };
}
