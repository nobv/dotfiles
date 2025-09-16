{ config
, pkgs
, lib
, username
, ...
}:

with lib;

let
  cfg = config.modules.terminal.tmux;
in
{
  options.modules.terminal.tmux = {
    enable = mkEnableOption "Tmux terminal multiplexer with custom configuration and plugins";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.programs.tmux = {
      #package = pkgs.tmux.overrideAttrs (_: rec {
      #  version = "3.3";
      #  src = pkgs.fetchFromGitHub {
      #    owner = "tmux";
      #    repo = "tmux";
      #    rev = version;
      #    sha256 = "sha256-Sxj2vXkbbPNRrqJKeIYwI7xdBtwRbl6a6a3yZr7UWW0=";
      #  };
      #});
      enable = true;
      baseIndex = 1;
      customPaneNavigationAndResize = true;
      keyMode = "vi";
      prefix = "C-a";
      extraConfig =
        builtins.readFile ./.tmux.conf
        + ''
          set-option -g default-shell ${pkgs.zsh}/bin/zsh
          set-option -g default-command ${pkgs.zsh}/bin/zsh
        '';
      historyLimit = 10000;
      clock24 = true;
      mouse = true;
      sensibleOnTop = true;
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = dracula; # https://draculatheme.com/tmux
          extraConfig = ''
            set -g @dracula-plugins 'battery cpu-usage ram-usage network time'
            set -g @dracula-show-powerline true
            set -g @dracula-show-flags false
            set -g @dracula-border-contrast true
            set -g @dracula-military-time true
            set -g @dracula-show-fahrenheit false
            set -g @dracula-show-location false
          '';
        }
        {
          plugin = resurrect; # https://github.com/tmux-plugins/tmux-resurrect
          extraConfig = ''
            set -g @resurrect-capture-pane-contents 'on'
          '';
        }
        {
          plugin = continuum; # https://github.com/tmux-plugins/tmux-continuum
          extraConfig = ''
            set -g @continuum-boot 'on'
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '1'
          '';
        }
        {
          plugin = vim-tmux-navigator; # https://github.com/tmux-plugins/tmux-continuum
        }
        {
          plugin = tmux-fzf; # https://github.com/sainnhe/tmux-fzf
        }
      ];
      terminal = "screen-256color";
    };
  };
}
