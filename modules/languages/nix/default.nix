{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.languages.nix;
in
{
  options.modules.languages.nix = {
    enable = mkEnableOption "Nix language support and tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nix
      nixfmt-rfc-style
      #rnix-lsp # https://github.com/nix-community/rnix-lsp
    ];
  };
}
