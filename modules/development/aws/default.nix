{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.aws;
in
{
  options.modules.development.aws = {
    enable = mkEnableOption "AWS CLI tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      awscli2
    ];
  };
}
