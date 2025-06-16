{ config, lib, pkgs, ... }:

with lib;

let
  stable = import <nixpkgs-stable> { };
  cfg = config.modules.lang.python;
in
{
  options.modules.lang.python = {
    enable = mkEnableOption "Python programming language development environment";
  };

  config = mkIf cfg.enable {
    # https://github.com/NixOS/nixpkgs/blob/a0dbe47318/doc/languages-frameworks/python.section.md
    environment.systemPackages = with pkgs; [
/*
      python310
      python310Packages.pytest
      python310Packages.isort
      python310Packages.pyflakes
      python310Packages.mypy
      python310Packages.black
*/

      # stable.python310Packages.jupyterlab

      # error: Package 'python3.10-pyopenssl-22.0.0' in /nix/store/iqnx2dai0wzhi5r3savgivg7994icag2-nixpkgs-unstable/nixpkgs-unstable/pkgs/development/python-modules/pyopenssl/default.nix:73 is marked as broken, refusing to evaluate.
      # エラーが解消されたら unstable にしたい
      # unstable.python310Packages.black
      # stable.black
#      pyright

      #   (ps:
      #     with ps; [
      #       pip
      #       ipython
      #       setuptools
      #       pylint
      #       matplotlib
      #       # poetry
      #       pytest
      #       pylsp-mypy
      #       # virtualenv
      #       # virtualenvwrapper
      #     ])
    ];
  };
}
