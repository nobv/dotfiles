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
      go-bin
      gopls
      delve
      golangci-lint
      protoc-gen-go
      protoc-gen-connect-go
    ];

    # Go configuration should be in Home Manager context
    home-manager.users.${username}.programs.go = {
      enable = true;
      # programs.go also installs its package into the user profile; without
      # this an unpatched pkgs.go stays on PATH there.
      package = pkgs.go-bin;
      # goPath = "src";
    };
  };
}
