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

    shellPlugins.enable = mkEnableOption "sourcing ~/.config/op/plugins.sh in zsh";
  };

  config = mkIf cfg.enable {
    # Not nixpkgs' _1password-cli: the desktop app and the CLI verify each
    # other's code signature over XPC, so `op` must be the AgileBits-signed
    # binary from the same source as the app. See NixOS/nixpkgs#258139.
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
