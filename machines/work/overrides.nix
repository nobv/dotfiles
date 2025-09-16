{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  # Work machine-specific overrides
  system.defaults = {
    dock = {
      orientation = "bottom"; # Bottom dock for work productivity
    };

    NSGlobalDomain = {
      # Work productivity settings - keep animations enabled
      NSAutomaticWindowAnimationsEnabled = true;
    };
  };
}
