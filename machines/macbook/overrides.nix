{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  # MacBook-specific overrides
  system.defaults = {
    dock = {
      orientation = "left";
      # MacBook optimization - faster autohide for battery life
      autohide-time-modifier = 0.5;
    };

    NSGlobalDomain = {
      # MacBook optimization - disable animations for battery life
      NSAutomaticWindowAnimationsEnabled = false;
    };
  };
}
