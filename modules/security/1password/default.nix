{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.security."1password";

  agentSockRel = "Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  opSshSign = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";

  agentToml = concatMapStringsSep "\n" (
    k:
    ''
      [[ssh-keys]]
      item = "${k.item}"
    ''
    + optionalString (k.vault != null) ''
      vault = "${k.vault}"
    ''
  ) cfg.sshAgent.keys;
in
{
  options.modules.security."1password" = {
    enable = mkEnableOption "1Password password manager";

    sshAgent = {
      enable = mkEnableOption "the 1Password SSH agent as this machine's ssh-agent";

      keys = mkOption {
        default = [ ];
        example = [ { item = "GitHub (work)"; } ];
        description = ''
          SSH key items the agent may offer, rendered to
          ~/.config/1Password/ssh/agent.toml. Empty falls back to 1Password's
          default, which reaches neither user-created vaults nor a per-machine
          split, so it offers other machines' keys.
        '';
        type = types.listOf (
          types.submodule {
            options = {
              item = mkOption {
                type = types.str;
                description = "Title or ID of the SSH Key item, matched across every reachable vault.";
              };
              vault = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Restrict the lookup to this vault.";
              };
            };
          }
        );
      };
    };

    gitSigning = {
      enable = mkEnableOption "git commit/tag signing through 1Password (op-ssh-sign)";

      key = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...";
        description = ''
          Public key for user.signingKey, key material only. Must be registered
          on GitHub as a Signing key; an Authentication key does not cover it.
        '';
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      homebrew = mkIf (config.modules.system.homebrew.enable or false) {
        casks = [ "1password" ];
      };
    }

    (mkIf cfg.sshAgent.enable {
      home-manager.users.${username} = {
        # No ~ expansion here, and ssh_config needs the space in the path
        # quoted — hence the absolute path and the embedded quotes below.
        home.sessionVariables.SSH_AUTH_SOCK = "/Users/${username}/${agentSockRel}";

        programs.ssh.settings."*".IdentityAgent = ''"~/${agentSockRel}"'';

        home.file.".config/1Password/ssh/agent.toml" = mkIf (cfg.sshAgent.keys != [ ]) {
          text = agentToml;
        };
      };
    })

    (mkIf cfg.gitSigning.enable {
      # signing.* rather than settings: it reaches iniContent with mkDefault, so
      # a machine can override it, and it avoids fighting over ownership of
      # programs.git.settings with modules/development/vcs/git.
      home-manager.users.${username}.programs.git.signing = {
        format = "ssh";
        signer = opSshSign;
        key = cfg.gitSigning.key;
        signByDefault = true;
      };
    })

    {
      assertions = [
        {
          assertion = !cfg.gitSigning.enable || cfg.gitSigning.key != null;
          message = ''modules.security."1password".gitSigning.key must be set when gitSigning.enable is true'';
        }
        {
          assertion = !cfg.sshAgent.enable || config.modules.security.ssh.enable;
          message = ''modules.security."1password".sshAgent.enable requires modules.security.ssh.enable, which owns ~/.ssh/config'';
        }
      ];
    }
  ]);
}
