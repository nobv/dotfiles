{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {

  buildInputs = [
    pkgs.python310
    pkgs.python310Packages.requests
    pkgs.python310Packages.playwright
    pkgs.python310Packages.beautifulsoup4
  ];

}
