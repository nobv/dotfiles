{ lib, system, ... }:
let
  pkgs = import <nixpkgs> {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "terraform"
      ];
    };
  };
in
{
  home.packages = with pkgs;
    [
      terraform
      terragrunt
      terraform-ls
    ];


}
