{ config, pkgs, lib, ... }:

{
  # System configuration
  system.stateVersion = 4;
  
  # Enable homebrew
  homebrew.enable = true;

  # User configuration
  users.users.nobv = {
    name = "nobv";
    home = /Users/nobv;
  };
}