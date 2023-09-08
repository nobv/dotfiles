{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nix
    nixpkgs-fmt
    rnix-lsp # https://github.com/nix-community/rnix-lsp
  ];
}
