{ config, pkgs, lib, ... }:

let
  extraConfig = import ./extraConfig.nix;
  aliases = import ./aliases.nix;
in
{
  home.packages = with pkgs; [
    gh
    ghq
    # hub
    tig
  ];

  programs = {
    git = {
      enable = true;
      aliases = aliases;
      extraConfig = extraConfig;
      ignores = lib.splitString "\n" (builtins.readFile ./.gitignore_global);
      userEmail = "36393714+nobv@users.noreply.github.com";
      userName = "nobv";
    };

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


