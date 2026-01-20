{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.infrastructure.terraform;
in
{
  options.modules.development.infrastructure.terraform = {
    enable = mkEnableOption "Terraform infrastructure as code";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      tenv # https://github.com/tofuutils/tenv
      terraform-ls
    ];
  };
}
