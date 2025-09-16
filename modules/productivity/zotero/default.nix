{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.productivity.zotero;
  zotfile-version = "5.1.2";

in
{
  options.modules.productivity.zotero = {
    enable = mkEnableOption "Zotero reference management software";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "zotero" ];
    };

    /*
      home-manager.users.${username}.home.file."zotfile" = {
             target = "src/github.com/jlegewie/zotfile/zotfile-${zotfile-version}-fx.xpi";
             source = builtins.fetchurl {
               url = "https://github.com/jlegewie/zotfile/releases/download/v${zotfile-version}/zotfile-${zotfile-version}-fx.xpi";
               sha256 = "19v07nzz1wip02d0ssm6sw2vzyxki4railsdg0xb5ib0lcp5aqmy";
             };
           };
    */
  };
}
