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
    ./openspec
    ./parallel
    ./peco
    ./procs
    ./ripgrep
    ./tree
  ];
}
