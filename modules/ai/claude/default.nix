{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.ai.claude;
in
{
  options.modules.ai.claude = {
    enable = mkEnableOption "Claude AI assistant desktop app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "claude" ];
    };

    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "claude-code"
      ];

    environment.systemPackages = with pkgs; [
      claude-code
    ];
  };
}
