{ lib, system, ... }:
let
  pkgs = import <nixpkgs> {
    # inherit system;
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "webstorm"
        "rust-rover"
      ];
    };
  };
in
{
  home.packages = with pkgs.jetbrains; [
    webstorm
    rust-rover
  ];
}
