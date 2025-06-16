{ config, pkgs, lib, ... }:

let
  machineConfig = {
    username = "";
    # timezone = "Asia/Tokyo";
    # locale = "ja_JP.UTF-8";
    # primaryDisplay = "external";
    # workProfile = true;
  };
  username = machineConfig.username;
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = {
      home = {
        username = username;
        homeDirectory = "/Users/${username}";
        stateVersion = "23.05";
      };

      programs.home-manager.enable = true;
    };
  };
}
