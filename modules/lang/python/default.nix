{ config, lib, pkgs, ... }:

let cfg = config.my.modules.python;
in
{
  options.my.modules.python = { enable = mkEnableOption "Whether to enable python"; };

  config = with lib;
    mkIf cfg.enable {
      home-manager.users.${config.my.username}.home.packages = [
        (pkgs.python38.withPackages (ps:
          with ps; [
            pip
            ipython
            black
            isort
            setuptools
            pylint
            matplotlib
            nose
            # poetry
            pytest
            pyflakes
            pylsp-mypy
            # virtualenv
            # virtualenvwrapper
          ]))
      ];
    };
}
