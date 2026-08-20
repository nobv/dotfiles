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
    ./herdr
    ./jq
    ./mo
    ./navi
    ./openspec
    ./parallel
    ./peco
    ./procs
    ./ripgrep
    ./tree
    ./zoxide
  ];
}
