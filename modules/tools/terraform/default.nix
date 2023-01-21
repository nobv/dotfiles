{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    terraform
    terragrunt
    terraform-ls
  ];
}
