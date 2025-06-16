{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.terraform;
in
{
  options.modules.tools.terraform = {
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
