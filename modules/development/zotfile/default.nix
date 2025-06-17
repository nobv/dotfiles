{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.modules.development.zotfile;
  version = "5.1.2";
in
{
  options.modules.development.zotfile = {
    enable = mkEnableOption "Enable Zotfile extension";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.home.file."zotfile" = {
      target = "src/src/github.com/jlegewie/zotfile/zotfile-${version}-fx.xpi";
      source = builtins.fetchurl {
        url = "https://github.com/jlegewie/zotfile/releases/download/v${version}/zotfile-${version}-fx.xpi";
        sha256 = "19v07nzz1wip02d0ssm6sw2vzyxki4railsdg0xb5ib0lcp5aqmy";
      };
    };
  };
}
