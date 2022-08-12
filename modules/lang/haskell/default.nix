{ config, pkgs, lib, ... }:
let
  stable = import <nixpkgs-stable> { };
in
{
  # https://github.com/NixOS/nixpkgs/blob/a0dbe47318/doc/languages-frameworks/haskell.section.md
  home = {
    # file = { };

    packages = with pkgs; [
      haskell.compiler.ghc924
      haskellPackages.haskell-language-server
      haskellPackages.dhall-lsp-server
      haskellPackages.stack
    ];
  };

}
