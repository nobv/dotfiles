{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.languages.haskell;
  stable = import <nixpkgs-stable> { };
in
{
  options.modules.languages.haskell = {
    enable = mkEnableOption "Haskell programming language";
  };

  config = mkIf cfg.enable {
    # https://github.com/NixOS/nixpkgs/blob/a0dbe47318/doc/languages-frameworks/haskell.section.md
    environment.systemPackages = with pkgs; [
      haskell.compiler.ghc94
      haskell-language-server
      stack
    ];
  };
}
