{ config, pkgs, lib, ... }:

{
  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.nobv = {
      home.stateVersion = "23.05";
    };
  };
}