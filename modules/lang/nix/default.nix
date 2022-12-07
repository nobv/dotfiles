{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nix
    nixpkgs-fmt
    rnix-lsp
  ];
}
