{ config, pkgs, lib, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.nobv = {
      home = {
        username = "nobv";
        homeDirectory = "/Users/nobv";
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
