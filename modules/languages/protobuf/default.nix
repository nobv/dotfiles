{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.lang.protobuf;
in
{
  options.modules.lang.protobuf = {
    enable = mkEnableOption "Protocol Buffers development tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      protobuf
      buf
      grpcurl
    ];
  };
}
