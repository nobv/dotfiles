{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # https://github.com/aquasecurity/trivy
    trivy
  ];
}
