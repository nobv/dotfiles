{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.make;
in
{
  options.modules.tools.make = {
    enable = mkEnableOption "CMake build system";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cmake
    ];
  };
}
