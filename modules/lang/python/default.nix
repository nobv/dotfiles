{ config, lib, pkgs, ... }:
let
  unstable = import <nixpkgs-unstable> { };
  stable = import <nixpkgs-stable> { };
in
{
  # https://github.com/NixOS/nixpkgs/blob/a0dbe47318/doc/languages-frameworks/python.section.md
  home.packages = with pkgs; [
    unstable.python310
    unstable.python310Packages.pytest
    unstable.python310Packages.isort
    unstable.python310Packages.nose
    unstable.python310Packages.pyflakes

    # error: Package ‘python3.10-pyopenssl-22.0.0’ in /nix/store/iqnx2dai0wzhi5r3savgivg7994icag2-nixpkgs-unstable/nixpkgs-unstable/pkgs/development/python-modules/pyopenssl/default.nix:73 is marked as broken, refusing to evaluate.
    # エラーが解消されたら unstable にしたい
    # unstable.python310Packages.black
    stable.black

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
}


# let cfg = config.my.modules.python;
# in
# {
#   options.my.modules.python = { enable = mkEnableOption "Whether to enable python"; };

#   config = with lib;
#     mkIf cfg.enable {
#       home-manager.users.${config.my.username}.home.packages = [
#         (pkgs.python38.withPackages (ps:
#           with ps; [
#             pip
#             ipython
#             black
#             isort
#             setuptools
#             pylint
#             matplotlib
#             nose
#             # poetry
#             pytest
#             pyflakes
#             pylsp-mypy
#             # virtualenv
#             # virtualenvwrapper
#           ]))
#       ];
#     };
# }
