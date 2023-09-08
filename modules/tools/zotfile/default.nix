{ config, pkgs, lib, ... }:
let
  version = "5.1.2";
in
{
  home.file."zotfile" = {
    target = "src/src/github.com/jlegewie/zotfile/zotfile-${version}-fx.xpi";
    source = builtins.fetchurl {
      url = "https://github.com/jlegewie/zotfile/releases/download/v${version}/zotfile-${version}-fx.xpi";
      sha256 = "19v07nzz1wip02d0ssm6sw2vzyxki4railsdg0xb5ib0lcp5aqmy";
    };
  };
}
