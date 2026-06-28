{
  config,
  pkgs,
  lib,
  username,
  machine,
  ...
}:
{
  # Common Darwin system configuration shared across all machines
  environment = {
    systemPackages = with pkgs; [ ];
    variables.DOTFILES_MACHINE = machine;
  };

  # Determinate Nix manages the daemon. Enabling this disables nix-darwin's
  # built-in Nix module (no need for nix.enable = false), pre-enables
  # nix-command/flakes, and runs automatic garbage collection by default.
  determinateNix.enable = true;

  nixpkgs = {

    overlays =
      let
        path = ../overlays;
      in
      with builtins;
      map (n: import (path + ("/" + n))) (
        filter (n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (
          attrNames (readDir path)
        )
      );
  };

  system = {
    primaryUser = username;

    # Default system settings (can be overridden by machine-specific configs)
    defaults = {
      dock = {
        autohide = lib.mkDefault true;
        orientation = lib.mkDefault "bottom";
      };

      trackpad = {
        Clicking = lib.mkDefault true;
      };

      NSGlobalDomain = {
        "com.apple.trackpad.scaling" = lib.mkDefault 3.0;
        "com.apple.mouse.tapBehavior" = lib.mkDefault 1;
        InitialKeyRepeat = lib.mkDefault 15;
        KeyRepeat = lib.mkDefault 2;
        AppleShowAllExtensions = lib.mkDefault true;
        AppleShowAllFiles = lib.mkDefault true;
        NSAutomaticWindowAnimationsEnabled = lib.mkDefault true;
      };
    };

    keyboard = {
      enableKeyMapping = lib.mkDefault true;
      remapCapsLockToControl = lib.mkDefault true;
    };

    stateVersion = 6;
  };

  security = {
    pam = {
      services = {
        sudo_local = {
          # watchIdAuth = lib.mkDefault true;
          touchIdAuth = lib.mkDefault true;
          reattach = true;
        };
      };
    };
  };

  users.users.${username}.home = "/Users/${username}";
}
