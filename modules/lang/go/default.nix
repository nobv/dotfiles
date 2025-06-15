{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.lang.go;
in
{
  options.modules.lang.go = {
    enable = mkEnableOption "Enable Go development environment";
  };

  config = mkIf cfg.enable {
    programs.go = {
      enable = true;
      # goPath = "src";
    };

    # https://github.com/NixOS/nixpkgs/blob/a0dbe47318/doc/languages-frameworks/go.section.md
    home.packages = with pkgs; [
      gopls
      delve
      golangci-lint
      protoc-gen-go
      protoc-gen-connect-go
    ];
  };
}
