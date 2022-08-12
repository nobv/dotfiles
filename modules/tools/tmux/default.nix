{ config, pkgs, lib, ... }:

{
  programs = {
    tmux = {
      enable = true;
      baseIndex = 1;
      customPaneNavigationAndResize = true;
      keyMode = "vi";
      prefix = "C-a";
      extraConfig = builtins.readFile ./.tmux.conf;
      historyLimit = 10000;
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = ''
            set -g @resurrect-capture-pane-contents 'on'
          '';
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-boot 'on'
            set -g @continuum-boot-options 'iterm'
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '1'
          '';
        }
      ];
      terminal = "screen-256color";
    };
  };

}


