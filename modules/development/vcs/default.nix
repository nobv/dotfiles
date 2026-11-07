{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./crit
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
