{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.languages.nodejs;
in
{
  options.modules.languages.nodejs = {
    enable = mkEnableOption "Enable Node.js development environment with Volta and Claude Code";
  };

  config = mkIf cfg.enable {
    # System packages
    environment.systemPackages = with pkgs; [
      # Runtime
      # nodejs_22
      # nodejs_23
      nodejs_24
      biome

      # LSP servers
      nodePackages.typescript-language-server

      # nodePackages.prettier
      # nodePackages.node-gyp
      # Package managers
      # yarn
      #      node-gyp
      #      volta
      # corepack
      pnpm
      pnpm-shell-completion
      # nest-cli
    ];

    # Home Manager configuration for Node.js
    /*
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
    */
  };
}
