{ config, pkgs, lib, ... }:
{
  # https://github.com/NixOS/nixpkgs/blob/a0dbe47318/doc/languages-frameworks/javascript.section.md
  home.packages = with pkgs; [
    nodejs
    nodePackages.prettier

    # Package managers
    yarn
    volta

    nest-cli
  ];
}
