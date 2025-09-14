{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  # Mac Mini-specific overrides
  system.defaults = {
    dock = {
      autohide = false; # Show dock on desktop setup
      orientation = "left";
    };

    NSGlobalDomain = {
      # Desktop optimizations - enable animations for better UX
      NSAutomaticWindowAnimationsEnabled = true;
    };
  };
}
