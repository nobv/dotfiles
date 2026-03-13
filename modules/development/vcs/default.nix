{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./difit
    ./fork
    ./git
    ./github
    ./pre-commit
    ./workmux
  ];
}
