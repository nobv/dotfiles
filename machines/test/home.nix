{ config, pkgs, lib, username, ... }:

{
  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = {
      home.stateVersion = "23.05";
    };
  };
}