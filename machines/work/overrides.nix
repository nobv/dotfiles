{ config
, pkgs
, lib
, username
, ...
}:
{
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
