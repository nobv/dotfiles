{
  config,
  pkgs,
  lib,
  username,
  ...
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
      enable = true;
      baseIndex = 1;
      clock24 = true;
      customPaneNavigationAndResize = true;
      escapeTime = 1;
      focusEvents = true;
      historyLimit = 10000;
      keyMode = "vi";
      mouse = true;
      prefix = "C-a";
      sensibleOnTop = true;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "tmux-256color";
      extraConfig = ''
        # 設定ファイルをリロードする
        bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

        # | でペインを縦に分割する
        bind | split-window -h

        # - でペインを横に分割する
        bind - split-window -v

        # ステータスバー
        set -g status-style bg=black
        set -g status-position top
        set-option -g status-interval 1

        # アクティビティモニタリング
        setw -g monitor-activity on
        set -g visual-activity on

        # コピーモード (vi風)
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
        unbind -T copy-mode-vi Enter
        bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "pbcopy"

        # 拡張キー対応 (Shift+Enter 等)
        # https://github.com/anthropics/claude-code/issues/6072#issuecomment-3864208228
        set -s extended-keys on
        set -as terminal-features 'xterm*:extkeys'
        bind-key -T root S-Enter send-keys Escape "[13;2u"
      '';
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
            set -g @continuum-save-interval '30'
          '';
        }
        {
          plugin = vim-tmux-navigator; # https://github.com/christoomey/vim-tmux-navigator
        }
        {
          plugin = tmux-fzf; # https://github.com/sainnhe/tmux-fzf
        }
      ];
    };
  };
}
