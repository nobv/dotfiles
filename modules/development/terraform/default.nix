{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.terraform;
in
{
  options.modules.development.terraform = {
    enable = mkEnableOption "Terraform infrastructure as code";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      terraform
      terragrunt
      terraform-ls
    ];
  };
}
