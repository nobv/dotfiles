{ config, pkgs, lib, ... }:

let
  machineConfig = {
    username = "nobv";
    # 将来的に追加可能な設定例：
    # timezone = "Asia/Tokyo";
    # locale = "ja_JP.UTF-8";
    # testMode = true;
  };
  username = machineConfig.username;
in
{
  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = {
      home.stateVersion = "23.05";
    };
  };
}