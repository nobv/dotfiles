{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    gh
    act
  ];

  programs = {
    # comment out until resolive this issue.
    # https://github.com/nix-community/home-manager/issues/1654
    # gh = {
    #   enable = true;
    #   settings = {
    #     git_protocol = "ssh";
    #   };

    # };
  };


}
