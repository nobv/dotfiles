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
    ./gh-dash
    ./git
    ./github
    ./pre-commit
    ./workmux
    ./worktrunk
  ];
}
