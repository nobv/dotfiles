{ config, pkgs, lib, ... }:
{
  home = {
    packages = with pkgs; [
      kind
      kubectl
      kubectx
      kustomize
    ];
  };
}
