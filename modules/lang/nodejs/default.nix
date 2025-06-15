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

      home.activation = {
        setupNpmPackage = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          HOME_DIR="$HOME"
          NPM_GLOBAL_DIR="$HOME_DIR/.npm-packages"
            if [ ! -d "$NPM_GLOBAL_DIR" ]; then
              $DRY_RUN_CMD mkdir -p "$NPM_GLOBAL_DIR"
              $DRY_RUN_CMD ${pkgs.nodejs}/bin/npm config set prefix "$NPM_GLOBAL_DIR"
            fi
        '';
        installClaude-code = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          HOME_DIR="$HOME"
          NPM_GLOBAL_DIR="$HOME_DIR/.npm-packages"
          if [ ! -f "$NPM_GLOBAL_DIR/bin/claude" ]; then
            run echo "Installing @anthropic-ai/claude-code..."
            $DRY_RUN_CMD $HOME_DIR/.volta/bin/npm install -g @anthropic-ai/claude-code
          fi
        '';
      };
    };
  };
}
