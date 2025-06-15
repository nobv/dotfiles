{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.lang.nodejs;
in
{
  options.modules.lang.nodejs = {
    enable = mkEnableOption "Enable Node.js development environment with Volta and Claude Code";
  };

  config = mkIf cfg.enable {
    # https://github.com/NixOS/nixpkgs/blob/a0dbe47318/doc/languages-frameworks/javascript.section.md
    home = {
      packages = with pkgs; [
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

      sessionVariables = {
        NPM_CONFIG_PREFIX = "~/.npm-packages";
      };

      sessionPath = [
        "~/.npm-packages/bin"
      ];

      file.".npmrc".text = ''
        prefix=~/.npm-packages
      '';

      activation = {
        setupNpmPackage = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          HOME_DIR="$HOME"
          NPM_GLOBAL_DIR="$HOME_DIR/.npm-packages"
            if [ ! -d "$NPM_GLOBAL_DIR" ]; then
              $DRY_RUN_CMD mkdir -p "$NPM_GLOBAL_DIR"
              $DRY_RUN_CMD ${pkgs.nodejs}/bin/npm config set prefix "$NPM_GLOBAL_DIR"
            fi
        '';
        # installAdminJSCli = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        #   HOME_DIR="$HOME"
        #   NPM_GLOBAL_DIR="$HOME_DIR/.npm-packages"
        #   if [ ! -f "$NPM_GLOBAL_DIR/bin/adminjs" ]; then
        #     run echo "Installing AdminJS CLI..."
        #     $DRY_RUN_CMD ${pkgs.nodejs}/bin/npm install -g @adminjs/cli
        #   fi
        # '';
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
