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
    ./navi
    ./parallel
    ./peco
    ./procs
    ./ripgrep
    ./tree
  ];
}
