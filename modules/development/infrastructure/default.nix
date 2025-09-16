{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./aws
    ./docker
    ./gcp
    ./kubernetes
    ./sops
    ./terraform
  ];
}
