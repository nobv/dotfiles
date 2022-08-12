{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    # hasklig v1.1 doesn't work in VSCode well.
    # For some reason, this PR was closed.
    # https://github.com/NixOS/nixpkgs/pull/135938
    # hasklig
    (nerdfonts.override {
      fonts = [
        "SourceCodePro"
        "Hack"
        "Hasklig"
        "FiraCode"
      ];
    })
  ];
  #fonts = { fontconfig = { enable = true; }; };
}
