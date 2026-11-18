{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.languages.go;
in
{
  options.modules.languages.go = {
    enable = mkEnableOption "Enable Go development environment";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      go_1_26
      gopls
      delve
      golangci-lint
      protoc-gen-go
      protoc-gen-connect-go
    ];

    # Go configuration should be in Home Manager context
    home-manager.users.${username}.programs.go = {
      enable = true;
      # Go comes from systemPackages above. Left unset, programs.go installs
      # pkgs.go into the user profile as a second, differently versioned copy.
      package = null;
      # goPath = "src";
    };
  };
}
