{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./fork
    ./git
    ./github
    ./pre-commit
  ];
}
