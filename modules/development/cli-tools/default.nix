{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./bat
    ./dyff
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
