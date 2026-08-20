{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.development.vcs.workmux;
  sandboxConfig = lib.optionalString cfg.sandbox.enable ''

    sandbox:
      enabled: true
      backend: lima
      lima:
        isolation: ${cfg.sandbox.isolation}
        cpus: ${toString cfg.sandbox.cpus}
        memory: ${cfg.sandbox.memory}
      host_commands:
    ${lib.concatMapStringsSep "\n" (cmd: "    - ${cmd}") cfg.sandbox.hostCommands}
  '';
  configYaml = ''
    main_branch: main
    base_branch: origin/main
    worktree_dir: ~/.workmux/{project}
    nerdfont: true

    # Append new windows at the end instead of next to the current one, so
    # arrival order stays legible when several worktrees run in parallel.
    window_placement: rightmost

    # dracula owns window-status-format; @workmux_status is embedded there
    # explicitly instead (modules/terminal/tmux).
    status_format: false

    dashboard:
      preview_size: 60

    sidebar:
      position: left
      layout: tiles

    # Reuses the authenticated Claude Code CLI; haiku keeps naming calls cheap.
    auto_name:
      command: "claude --model haiku -p"
      system_prompt: |
        Generate a Conventional Commits branch name in the form
        <type>/<short-kebab-description>, where <type> is one of: feat, fix,
        docs, style, refactor, perf, test, build, ci, chore, revert.
        Output only the branch name, no explanation.
      background: true
  ''
  + sandboxConfig;
in
{
  options.modules.development.vcs.workmux = {
    enable = mkEnableOption "Enable workmux";
    sandbox = {
      enable = mkEnableOption "Enable workmux sandbox (requires Lima)";
      cpus = mkOption {
        type = types.int;
        default = 2;
        description = "Number of CPU cores per sandbox VM";
      };
      memory = mkOption {
        type = types.str;
        default = "2GiB";
        description = "Memory per sandbox VM";
      };
      isolation = mkOption {
        type = types.enum [
          "project"
          "shared"
        ];
        default = "project";
        description = "VM isolation mode: project (per-repo) or shared (single VM)";
      };
      hostCommands = mkOption {
        type = types.listOf types.str;
        default = [
          "just"
          "make"
        ];
        description = "Commands that can be proxied from sandbox to host";
      };
    };
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "raine/workmux/workmux" ];
    };

    home-manager.users.${username} =
      { config, ... }:
      {
        home.file.".config/workmux/config.yaml".text = configYaml;
      };
  };
}
