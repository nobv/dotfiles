{ config, pkgs, lib, ... }:
let
  unstable = import <nixpkgs-unstable> { };
  stable = import <nixpkgs-stable> { };
in
{
  home.packages = with pkgs; [
    haskell.compiler.ghc922
    haskellPackages.haskell-language-server
    haskellPackages.dhall-lsp-server
    haskellPackages.stack
  ];
}
