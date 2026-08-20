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
    ./git-surgeon
    ./github
    ./pre-commit
    ./workmux
    ./worktrunk
  ];
}
