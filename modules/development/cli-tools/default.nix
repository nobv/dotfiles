{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./bat
    ./eza
    ./fd
    ./fzf
    ./gnused
    ./jq
    ./mo
    ./navi
    ./parallel
    ./peco
    ./procs
    ./ripgrep
    ./tree
  ];
}
