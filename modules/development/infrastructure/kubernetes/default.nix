{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.infrastructure.kubernetes;
in
{
  options.modules.development.infrastructure.kubernetes = {
    enable = mkEnableOption "Kubernetes development and management tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      kind
      kubectl
      kubectx
      kustomize
      stern
      sonobuoy
      kube-capacity
    ];
  };
}
