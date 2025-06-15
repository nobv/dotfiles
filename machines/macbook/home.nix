{ config, pkgs, lib, ... }:

let
  machineConfig = {
    username = "nobv";
    # 将来的に追加可能な設定例：
    # timezone = "Asia/Tokyo";
    # locale = "ja_JP.UTF-8";
    # primaryDisplay = "internal";
    # workProfile = false;
  };
  username = machineConfig.username;
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = {
      home = {
        username = username;
        homeDirectory = "/Users/${username}";
        stateVersion = "25.05";
      };

      programs.home-manager.enable = true;
    };
  };
}
