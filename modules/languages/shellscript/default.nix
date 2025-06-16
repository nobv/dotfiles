{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.lang.shellscript;
in
{
  options.modules.lang.shellscript = {
    enable = mkEnableOption "Shell script development tools and linters";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bats
      shellcheck
      nodePackages.bash-language-server
    ];
  };
}
