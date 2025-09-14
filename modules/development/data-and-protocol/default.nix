{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./dbeaver-community
    ./httpie
    ./k6
    ./mkcert
    ./pgformatter
    ./postman
  ];
}
