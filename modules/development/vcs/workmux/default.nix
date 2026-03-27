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
    base_branch: origin/main
    nerdfont: true
    worktree_dir: .worktrees

    pre_add:
      - git fetch origin
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
