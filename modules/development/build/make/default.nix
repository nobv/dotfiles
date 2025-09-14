{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.build.make;
in
{
  options.modules.development.build.make = {
    enable = mkEnableOption "CMake build system";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cmake
    ];
  };
}
