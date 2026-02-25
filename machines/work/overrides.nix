{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  system.defaults = {
    dock = {
      orientation = "right";
    };
  };


  security = {
    pam = {
      services = {
        sudo_local = {
          watchIdAuth = false;
        };
      };
    };
  };

}
