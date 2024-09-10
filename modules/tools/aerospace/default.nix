{ config, pkgs, lib, ... }:

{
  home.file.".config/aerospace/aerospace.toml" = {
    source = ./aerospace.toml;
  };
}
