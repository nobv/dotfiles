{ config, lib, pkgs, userName, overlays, ... }@inputs:

{
  environment = {
    systemPackages = with pkgs; [
      Morgen
      ThingsHelper
    ];

    darwinConfig = ./default.nix;
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs = {
    overlays = overlays;
  };

  services = {
    nix-daemon.enable = true;
  };

  system = {
    stateVersion = 4;

    defaults = {
      dock = {
        autohide = true;
        orientation = "left";
      };

      trackpad = { Clicking = true; };

      NSGlobalDomain = {
        "com.apple.trackpad.scaling" = 3.0;
        "com.apple.mouse.tapBehavior" = 1;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog

}
