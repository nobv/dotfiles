{ config, pkgs, lib, ... }:

{
  # Work machine-specific Darwin system configuration
  environment = {
    systemPackages = with pkgs; [ ];
  };

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ ];
      allowUnsupportedSystem = true;
    };

    overlays =
      let path = ../../overlays; in
      with builtins;
      map (n: import (path + ("/" + n)))
        (filter
          (n: match ".*\\.nix" n != null ||
            pathExists (path + ("/" + n + "/default.nix")))
          (attrNames (readDir path)));
  };

  system = {
    primaryUser = "nobv";
    defaults = {
      dock = {
        autohide = true;
        orientation = "bottom";  # Bottom dock for work
      };

      trackpad = { Clicking = true; };

      NSGlobalDomain = {
        "com.apple.trackpad.scaling" = 3.0;
        "com.apple.mouse.tapBehavior" = 1;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        # Work productivity settings
        NSAutomaticWindowAnimationsEnabled = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    stateVersion = 6;
  };

  users.users.nobv.home = "/Users/nobv";
}