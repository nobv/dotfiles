{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.lang.nix;
in
{
  options.modules.lang.nix = {
    enable = mkEnableOption "Nix language support and tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nix
      nixpkgs-fmt
      #rnix-lsp # https://github.com/nix-community/rnix-lsp
    ];
  };
}
