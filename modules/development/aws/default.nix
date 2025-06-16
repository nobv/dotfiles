{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.aws;
in
{
  options.modules.tools.aws = {
    enable = mkEnableOption "AWS CLI tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      awscli2
    ];
  };
}
