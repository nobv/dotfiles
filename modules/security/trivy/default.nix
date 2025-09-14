{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.security.trivy;
in
{
  options.modules.security.trivy = {
    enable = mkEnableOption "Trivy vulnerability scanner";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # https://github.com/aquasecurity/trivy
      trivy
    ];
  };
}
