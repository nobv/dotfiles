{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.gcp;
in
{
  options.modules.development.gcp = {
    enable = mkEnableOption "Google Cloud Platform SDK";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
        google-cloud-sdk.components.cloud_sql_proxy
      ])
    ];
  };
}
