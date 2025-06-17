{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.make;
in
{
  options.modules.development.make = {
    enable = mkEnableOption "CMake build system";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cmake
    ];
  };
}
