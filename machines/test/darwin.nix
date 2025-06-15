{ config, pkgs, lib, ... }:

let
  machineConfig = {
    username = "nobv";
    # timezone = "Asia/Tokyo";
    # locale = "ja_JP.UTF-8";
    # testMode = true;
  };
  username = machineConfig.username;
in
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
