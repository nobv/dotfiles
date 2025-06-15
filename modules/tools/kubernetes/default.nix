{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.kubernetes;
in
{
  options.modules.tools.kubernetes = {
    enable = mkEnableOption "Kubernetes development and management tools";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        kind
        kubectl
        kubectx
        kustomize
        stern
        sonobuoy
        kube-capacity
      ];
    };
  };
}
