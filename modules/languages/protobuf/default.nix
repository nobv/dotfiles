{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.languages.protobuf;
in
{
  options.modules.languages.protobuf = {
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
