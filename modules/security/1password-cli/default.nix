{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.security."1password-cli";
in
{
  options.modules.security."1password-cli" = {
    enable = mkEnableOption "1Password CLI (op)";

    shellPlugins.enable = mkEnableOption ''
      sourcing ~/.config/op/plugins.sh in zsh, so the aliases written by
      `op plugin init <tool>` (gh, aws, …) take effect
    '';
  };

  config = mkIf cfg.enable {
    # Deliberately Homebrew rather than nixpkgs' _1password-cli: the desktop app
    # and the CLI talk over XPC and verify each other's code signature, so `op`
    # has to be the AgileBits-signed binary from the same source as the app
    # (cask "1password"). Mixing a nix-built CLI with a cask GUI breaks Touch ID
    # unlock — see NixOS/nixpkgs#258139.
    #
    # The cask ships `binary "op"` plus generated completions, which land in
    # /opt/homebrew/{bin,share/zsh/site-functions}; `brew shellenv` in .zprofile
    # puts both on PATH/FPATH before .zshrc runs compinit, so no extra wiring.
    #
    # Note: the cask's zap stanza removes ~/.config/op, and the homebrew module
    # activates with cleanup = "zap", so disabling this module also discards the
    # shell-plugin state below. Recreate it with `op plugin init <tool>`.
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "1password-cli" ];
    };

    home-manager.users.${username}.programs.zsh.initContent =
      mkIf (cfg.shellPlugins.enable && config.modules.terminal.zsh.enable)
        (mkAfter ''
          [ -f ~/.config/op/plugins.sh ] && source ~/.config/op/plugins.sh
        '');
  };
}
