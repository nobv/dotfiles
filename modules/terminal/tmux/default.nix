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

          # Name auto-renamed windows after their directory. The stock format
          # uses #{pane_current_command}, which for agent CLIs is their version
          # string ("2.1.233"). Windows renamed by hand are unaffected — tmux
          # turns automatic-rename off per-window on a manual rename-window.
          set -g automatic-rename-format '#{?pane_in_mode,[tmux],#{b:pane_current_path}}#{?pane_dead,[dead],}'

          # Activity monitoring
          setw -g monitor-activity on

          # Thicken pane borders (makes agent-indicator's state colors easier to see)
          set -g pane-border-lines heavy

          # Dim inactive panes so the focused one stands out. window-style only
          # covers cells the running program left at default fg/bg (most
          # prompt/TUI output sets its own colors, so this alone is subtle) —
          # the border below is the primary focus cue.
          set -g window-style 'fg=#44475a,bg=#0a0a10'
          set -g window-active-style 'fg=#f8f8f2,bg=#282a36'

          # Turn the active pane's top border into a filled title bar. Inactive
          # panes keep a thin dim line, so the focused pane reads at a glance
          # even when its content paints its own colors.
          #
          # pane_title (not pane_current_command) is what agent CLIs set to the
          # current task — the command name is just their version string
          # ("2.1.233"). Truncated so a long task name cannot push the border
          # past the pane width.
          #
          # The directory is shown on inactive panes only: automatic-rename
          # already puts the ACTIVE pane's directory in the window name, and
          # panes within one window often sit in different worktrees, so this
          # is the only place an inactive pane's worktree shows up.
          #
          # Border colour means focus and nothing else, so it can never be
          # wrong: agent-indicator's border channel is off below because it
          # styles pane-active-border-style, which is window-scoped — a
          # BACKGROUND pane finishing would recolour whichever pane you are
          # sitting in. Per-pane agent state is carried in the title instead,
          # via the @pstate pane option set by the agent hooks.
          set -g pane-border-status top
          set -g pane-border-format '#{?pane_active, ,  #{b:pane_current_path} │ }#{?#{==:#{@pstate},needs-input},#[fg=#f1fa8c#,bold]⏸ #[default],#{?#{==:#{@pstate},done},#[fg=#50fa7b#,bold]✅ #[default],}}#{=40:pane_title} '
          set -g pane-border-style 'fg=#44475a'
          set -g pane-active-border-style 'bg=#ff79c6,fg=#282a36,bold'

          # Focusing a pane clears its pending marker — you have now seen it.
          # -t is explicit: `set-option -p` with no target resolves to the
          # ACTIVE pane rather than the one in context.
          set-hook -g pane-focus-in 'set-option -p -t "#{pane_id}" @pstate ""'

          # t: pop up a scratch shell in the current pane's directory
          # (overrides the stock clock-mode bind)
          bind-key t display-popup -d "#{pane_current_path}" -w 80% -h 80% -T " scratch " -E "zsh"

          # G: pop up lazygit
          bind-key G display-popup -d "#{pane_current_path}" -w 90% -h 90% -T " lazygit " -E "lazygit"

          # W: pop up workmux dashboard
          bind-key W display-popup -d "#{pane_current_path}" -w 90% -h 90% -T " workmux " -E "workmux dashboard"

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
              # Leave the border alone: it colours pane-active-border-style,
              # which tmux scopes to the whole window, so a state change in a
              # BACKGROUND pane recolours the border of whatever pane is
              # focused — the colour ends up describing the wrong pane. Border
              # is focus-only (see pane-active-border-style above); per-pane
              # state rides in the border title via @pstate instead.
              set -g @agent-indicator-border-enabled 'off'

              # Extend the notification display duration (default 5000ms)
              set -g @agent-indicator-notification-duration '8000'

              # Also fire a native macOS notification alongside tmux's
              # display-message, so it's noticeable even when focus is elsewhere.
              # $AGENT_NAME makes this correct for any agent (claude, codex, ...),
              # not just Claude Code.
              set -g @agent-indicator-notification-command 'osascript -e "display notification \"$AGENT_STATE in $AGENT_SESSION:$AGENT_WINDOW\" with title \"$AGENT_NAME\" sound name \"Glass\""'
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
