{ config, lib, pkgs, ... }:

{
  home = {

    # file = { };

    packages = with pkgs; [
      procs
    ];

  };
}
