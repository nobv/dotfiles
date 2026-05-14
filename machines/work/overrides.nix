{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  system.defaults = {
    dock = {
      orientation = "right";
    };
  };

  security = {
    pam = {
      services = {
        sudo_local = {
          watchIdAuth = false;
        };
      };
    };
  };

  # Machine-local environment variables (git-ignored, not Nix-managed).
  # Sourced last (mkAfter) so this machine-specific layer can override values
  # set by the generic config. See machines/work/env.local.example for the format.
  home-manager.users.${username}.programs.zsh.initContent =
    lib.mkIf config.modules.terminal.zsh.enable (
      lib.mkAfter ''
        [ -f ~/.dotfiles/machines/work/env.local ] && source ~/.dotfiles/machines/work/env.local
      ''
    );
}
