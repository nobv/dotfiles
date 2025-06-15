{ config, pkgs, lib, username, ... }:

{
  # System configuration
  system.stateVersion = 4;
  
  # Enable homebrew
  homebrew.enable = true;

  # User configuration
  users.users.${username} = {
    name = username;
    home = /Users/${username};
  };
}