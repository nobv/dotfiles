{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.trivy;
in
{
  options.modules.tools.trivy = {
    enable = mkEnableOption "Trivy vulnerability scanner";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # https://github.com/aquasecurity/trivy
      trivy
    ];
  };
}
