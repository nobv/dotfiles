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
  # Shows running / needs-input / done on the pane border and window title,
  # driven by Claude Code / Codex hooks (not packaged in nixpkgs)
  tmux-agent-indicator = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-agent-indicator";
    version = "unstable-2026-07-26";
    rtpFilePath = "agent-indicator.tmux";
    src = pkgs.fetchFromGitHub {
      owner = "accessd";
      repo = "tmux-agent-indicator";
      rev = "8d2e84b0d76f0494b8851bef5057a536c0ba76c7";
      hash = "sha256-7Wm1M+yf8hIQGtPSbOyQ84b+yz5DYyGk2//0Fp6TBr8=";
    };
  };
in
{
  options.modules.terminal.tmux = {
    enable = mkEnableOption "Tmux terminal multiplexer with custom configuration and plugins";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      # Claude Code hooks (modules/ai/claude-code/settings.json) reference
      # $HOME/.tmux/plugins/tmux-agent-indicator/scripts/agent-state.sh directly,
      # so symlink it to the nix store path at a stable location
      home.file.".tmux/plugins/tmux-agent-indicator".source =
        "${tmux-agent-indicator}/share/tmux-plugins/tmux-agent-indicator";

      programs.tmux = {
        enable = true;
        baseIndex = 1;
        clock24 = true;
        customPaneNavigationAndResize = true;
        escapeTime = 0;
        focusEvents = true;
        historyLimit = 10000;
        keyMode = "vi";
        mouse = true;
        prefix = "C-a";
        sensibleOnTop = true;
        shell = "${pkgs.zsh}/bin/zsh";
        terminal = "tmux-256color";
        extraConfig = ''
          # Reload the config file
          bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

          # Shorten the repeat-time window for rapid-fire binds (e.g. resize-pane)
          set -g repeat-time 300

          # Renumber windows so there are no gaps after closing one
          set -g renumber-windows on

          # When the session you're attached to is destroyed (e.g. its last
          # window closes), land on another live session instead of detaching
          # all the way out to the outer shell
          set -g detach-on-destroy off

          # | splits into columns and keeps them evenly sized
          bind | split-window -h -c "#{pane_current_path}" \; select-layout even-horizontal

          # - splits into rows and keeps them evenly sized
          bind - split-window -v -c "#{pane_current_path}" \; select-layout even-vertical

          # Re-even remaining panes when one closes (explicit kill-pane or
          # the pane's shell/process exiting on its own)
          set-hook -g after-kill-pane "select-layout"
          set-hook -g pane-exited "select-layout"

          # Activity monitoring
          setw -g monitor-activity on

          # Thicken pane borders (makes agent-indicator's state colors easier to see)
          set -g pane-border-lines heavy

          # t: pop up a scratch shell in the current pane's directory
          # (overrides the stock clock-mode bind)
          bind-key t display-popup -d "#{pane_current_path}" -w 80% -h 80% -T " scratch " -E "zsh"

          # G: pop up lazygit
          bind-key G display-popup -d "#{pane_current_path}" -w 90% -h 90% -T " lazygit " -E "lazygit"

          # Copy mode (vi-style)
          bind-key -T copy-mode-vi v send-keys -X begin-selection
          bind-key -T copy-mode-vi y send-keys -X copy-pipe-no-clear "pbcopy"
          unbind -T copy-mode-vi Enter
          bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-no-clear "pbcopy"

          # Extended key support (e.g. Shift+Enter)
          # https://github.com/anthropics/claude-code/issues/6072#issuecomment-3864208228
          set -s extended-keys on
          set -as terminal-features 'xterm*:extkeys'
          bind-key -T root S-Enter send-keys Escape "[13;2u"
        '';
        plugins = with pkgs.tmuxPlugins; [
          {
            plugin = dracula-patched; # https://draculatheme.com/tmux
            extraConfig = ''
              # git branch/status is already shown by starship (shell), cship
              # (Claude Code), the codex statusline, or neovim's lualine, and
              # battery/cpu/ram/network/time duplicate iStat Menus (menu bar).
              # Drop both here and keep tmux focused on session/window display.
              # Must be " " not "": dracula treats "" as unset and falls back
              # to its "battery network weather" default.
              set -g @dracula-plugins " "
              set -g @dracula-show-powerline true
              set -g @dracula-show-flags true
              set -g @dracula-border-contrast true
              set -g @dracula-show-left-icon session
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
          {
            plugin = tmux-agent-indicator; # https://github.com/accessd/tmux-agent-indicator
            extraConfig = ''
              # Border colors matched to the dracula palette (the default ANSI
              # green/yellow have weak contrast against dracula's normal
              # border color #bd93f9)
              set -g @agent-indicator-done-border '#50fa7b'
              set -g @agent-indicator-needs-input-border '#f1fa8c'

              # Extend the notification display duration (default 5000ms)
              set -g @agent-indicator-notification-duration '8000'

              # Also fire a native macOS notification alongside tmux's
              # display-message, so it's noticeable even when focus is elsewhere
              set -g @agent-indicator-notification-command 'osascript -e "display notification \"$AGENT_STATE in $AGENT_SESSION:$AGENT_WINDOW\" with title \"Claude Code\" sound name \"Glass\""'
            '';
          }
          {
            plugin = tmux-thumbs; # https://github.com/fcsonline/tmux-thumbs (prefix Space shows hints)
          }
        ];
      };
    };
  };
}
