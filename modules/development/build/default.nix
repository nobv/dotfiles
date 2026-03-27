{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./aqua
    ./direnv
    ./go-task
    ./just
    ./make
  ];
}
