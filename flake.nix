{
  description = "nobv's Dotfiles";

  inputs = {
    # Package sets
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-22.05-darwin";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Environment/system management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Othres
  };

  outputs = inputs@{ self, home-manager, darwin, ... }:
    let
      defaultUserName = "nobv";

      overlays =
        let path = ./overlays; in
        with builtins;
        map (n: import (path + ("/" + n)))
          (filter
            (n: match ".*\\.nix" n != null ||
              pathExists (path + ("/" + n + "/default.nix")))
            (attrNames (readDir path)));


      mkDarwinConfig =
        { system
        , userName ? defaultUserName
        , nixpkgs-stable ? inputs.nixpkgs-stable
        , nixpkgs ? inputs.nixpkgs
        , extraModules ? [ ]
        }:
        darwin.lib.darwinSystem {
          system = system;
          modules = [
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # home-manager.extraSpecialArgs = userName;
              home-manager.users.nobv = import ./machines/macmini2020/home.nix;
            }
          ] ++ extraModules;
          # inputs = { inherit darwin nixpkgs inputs overlays; };
          specialArgs = {
            inherit self inputs nixpkgs darwin nixpkgs-stable overlays userName;
          };
        };

    in
    {
      darwinConfigurations = {
        macmini = mkDarwinConfig {
          system = "aarch64-darwin";
          extraModules = [ ./machines/macmini2020 ];
        };
      };
    };
}
