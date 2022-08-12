{ config, pkgs, lib, ... }:
let
  config = import ./config.nix;
in
{
  home = {
    file = {
      "config" = {
        target = ".config/peco/config.json";
        text = builtins.toJSON config;
      };
    };
    packages = with pkgs; [
      peco
    ];
  };
}
