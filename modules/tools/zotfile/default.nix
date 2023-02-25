{ config, pkgs, lib, ... }:
let
  version = "5.1.2";
in
{
  home.file."zotfile" = {
    target = "src/src/github.com/jlegewie/zotfile/zotfile-${version}-fx.xpi";
    source = builtins.fetchurl "https://github.com/jlegewie/zotfile/releases/download/v${version}/zotfile-${version}-fx.xpi";
  };
}
