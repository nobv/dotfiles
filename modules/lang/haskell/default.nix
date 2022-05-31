{ config, pkgs, lib, ... }:
let
  unstable = import <nixpkgs-unstable> { };
  stable = import <nixpkgs-stable> { };
in
{
  # https://github.com/NixOS/nixpkgs/blob/a0dbe47318/doc/languages-frameworks/haskell.section.md
  home = {
    file = { };

    packages = with pkgs; [
      haskell.compiler.ghc922
      haskellPackages.haskell-language-server
      haskellPackages.dhall-lsp-server
      haskellPackages.stack
    ];
  };

}
