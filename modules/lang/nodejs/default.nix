{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.modules.lang.nodejs;
in
{
  options.modules.lang.nodejs = {
    enable = mkEnableOption "Enable Node.js development environment with Volta and Claude Code";
  };

  config = mkIf cfg.enable {
    # System packages
    environment.systemPackages = with pkgs; [
      # Runtime
      # nodejs_22
      # nodejs_23
      # nodePackages.prettier
      # nodePackages.node-gyp
      # Package managers
      # yarn
      node-gyp
      volta
      # corepack
      # pnpm
      nest-cli
    ];

    # Home Manager configuration for Node.js
    home-manager.users.${username} = {
      home.sessionVariables = {
        NPM_CONFIG_PREFIX = "~/.npm-packages";
      };

      home.sessionPath = [
        "~/.npm-packages/bin"
      ];

      home.file.".npmrc".text = ''
        prefix=~/.npm-packages
      '';

    };
  };
}
