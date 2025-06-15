{ config, pkgs, lib, username, ... }:

{
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

      nixpkgs.config = {
        allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ ];
        allowUnsupportedSystem = true;
      };
    };
  };
}
