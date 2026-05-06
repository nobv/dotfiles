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
  # macOS Sequoia 以降の SSID <redacted> 問題の修正 (dracula/tmux#358)
  dracula-patched = pkgs.tmuxPlugins.dracula.overrideAttrs (old: {
    version = "unstable-2025-12-18";
    src = pkgs.fetchFromGitHub {
      owner = "dracula";
      repo = "tmux";
      rev = "f3855313678d4b5c334604223fe37e6c4a60856a";
      hash = "sha256-a+rTH9rU7Dsgh4zSlpTdqYfeVUzD48+lyTPyAYvuPNc=";
    };
    # Fix: upstream uses `sw_vers -productVersion > 25.0` via bc, but bc
    # cannot parse versions with multiple dots (e.g. "26.3.1").
    # Replace with integer comparison on the major version (>= 15 = Sequoia).
    postPatch = ''
      substituteInPlace scripts/network.sh \
        --replace-fail \
          'if (( $(echo "$(sw_vers -productVersion) > 25.0" | bc -l) )); then' \
          'if (( $(sw_vers -productVersion | cut -d. -f1) >= 15 )); then'
    '';
  });
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
      escapeTime = 0;
      focusEvents = true;
      historyLimit = 10000;
      keyMode = "vi";
      mouse = true;
      prefix = "C-Space";
      sensibleOnTop = true;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "tmux-256color";
      extraConfig = ''
        # 設定ファイルをリロードする
        bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

        # 連打系（resize-pane など）の repeat 受付時間を短く
        set -g repeat-time 300

        # | でペインを縦に分割する
        bind | split-window -h

        # - でペインを横に分割する
        bind - split-window -v

        # アクティビティモニタリング
        setw -g monitor-activity on

        # コピーモード (vi風)
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi y send-keys -X copy-pipe-no-clear "pbcopy"
        unbind -T copy-mode-vi Enter
        bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-no-clear "pbcopy"

        # 拡張キー対応 (Shift+Enter 等)
        # https://github.com/anthropics/claude-code/issues/6072#issuecomment-3864208228
        set -s extended-keys on
        set -as terminal-features 'xterm*:extkeys'
        bind-key -T root S-Enter send-keys Escape "[13;2u"
      '';
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = dracula-patched; # https://draculatheme.com/tmux
          extraConfig = ''
            set -g @dracula-plugins 'git battery cpu-usage ram-usage network time'
            set -g @dracula-show-powerline true
            set -g @dracula-show-flags true
            set -g @dracula-border-contrast true
            set -g @dracula-show-empty-plugins false
            set -g @dracula-show-left-icon session
            set -g @dracula-military-time true
            set -g @dracula-show-timezone false
            set -g @dracula-cpu-display-load true
            set -g @dracula-show-battery-status true
            set -g @dracula-git-show-remote-status true
            set -g @dracula-git-no-repo-message ""
            set -g status-position top
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
