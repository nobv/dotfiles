{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.languages.purescript;
in
{
  options.modules.languages.purescript = {
    enable = mkEnableOption "PureScript functional programming language";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      purescript
      spago
      nodePackages.purescript-language-server
      nodePackages.purty
      nodePackages.purs-tidy
    ];
  };
}
