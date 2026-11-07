{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./crit
    ./difit
    ./fork
    ./gh-dash
    ./git
    ./git-surgeon
    ./github
    ./pre-commit
    ./workmux
    ./worktrunk
  ];
}
