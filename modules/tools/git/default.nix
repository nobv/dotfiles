{ config, pkgs, lib, ... }:

{
  programs = {
    git = {
      enable = true;
      aliases = builtins.fromJSON (builtins.readFile ./aliases.json);
      extraConfig = builtins.fromJSON (builtins.readFile ./extraConfig.json);
      ignores = lib.splitString "\n" (builtins.readFile ./.gitignore_global);
      userEmail = "36393714+nobv@users.noreply.github.com";
      userName = "nobv";
    };
  };

}


