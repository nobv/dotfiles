{ config, pkgs, lib, username, ... }:
{
  # Common Home Manager configuration shared across all machines
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = {
      home = {
        username = username;
        homeDirectory = "/Users/${username}";
        stateVersion = "25.05";
      };

      programs.home-manager.enable = true;
    };
  };
}