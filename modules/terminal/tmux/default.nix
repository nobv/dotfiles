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
  # Claude Code / Codex の hooks から pane border・window title に
  # running / needs-input / done を表示する (nixpkgs 未収載)
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
      # Claude Code hooks (modules/ai/claude-code/settings.json) は
      # $HOME/.tmux/plugins/tmux-agent-indicator/scripts/agent-state.sh を
      # 参照するため、nix store の実体へ安定パスで symlink を張る
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
          # 設定ファイルをリロードする
          bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

          # 連打系（resize-pane など）の repeat 受付時間を短く
          set -g repeat-time 300

          # ウィンドウを閉じた時に番号を詰める
          set -g renumber-windows on

          # 現在のセッションが (continuum の再起動等で) 破棄されても
          # クライアントは他のセッションにアタッチしたままにする
          set -g detach-on-destroy off

          # | でペインを縦に分割し、常に均等幅に整列する
          bind | split-window -h -c "#{pane_current_path}" \; select-layout even-horizontal

          # - でペインを横に分割し、常に均等高さに整列する
          bind - split-window -v -c "#{pane_current_path}" \; select-layout even-vertical

          # アクティビティモニタリング
          setw -g monitor-activity on

          # g: カレントディレクトリでスクラッチシェルを popup 表示
          bind-key g display-popup -d "#{pane_current_path}" -w 80% -h 80% -T " scratch " -E "zsh"

          # G: lazygit を popup 表示
          bind-key G display-popup -d "#{pane_current_path}" -w 90% -h 90% -T " lazygit " -E "lazygit"

          # a: Claude/Codex/Gemini/dotfiles 編集を専用 window に切り替え (無ければ作成)
          bind-key a display-menu -T " agent / dotfiles " \
            "Claude"   c "run-shell 'tmux select-window -t claude 2>/dev/null || tmux new-window -n claude claude'" \
            "Codex"    x "run-shell 'tmux select-window -t codex 2>/dev/null || tmux new-window -n codex codex'" \
            "Gemini"   g "run-shell 'tmux select-window -t gemini 2>/dev/null || tmux new-window -n gemini gemini'" \
            "Dotfiles" d "run-shell 'tmux select-window -t dotfiles 2>/dev/null || tmux new-window -n dotfiles -c ~/.dotfiles vim'"

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
              # git branch/status は starship (shell) / cship (Claude Code) /
              # codex statusline / neovim lualine のいずれかに常に表示され、
              # battery/cpu/ram/network/time は iStat Menus (menu bar) と重複するため
              # tmux 側では持たず、セッション/ウィンドウ表示に専念させる
              set -g @dracula-plugins ""
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
          }
          {
            plugin = tmux-thumbs; # https://github.com/fcsonline/tmux-thumbs (prefix Space でヒント表示)
          }
        ];
      };
    };
  };
}
