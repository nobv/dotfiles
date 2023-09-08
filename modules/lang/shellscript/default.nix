{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    bats
    shellcheck
    nodePackages.bash-language-server
  ];
}
