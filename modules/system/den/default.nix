{
  config,
  lib,
  username,
  inputs,
  ...
}:

with lib;

let
  cfg = config.modules.system.den;
in
{
  options.modules.system.den = {
    enable = mkEnableOption "Den, the desk-metaphor context switcher";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      imports = [ inputs.den.homeManagerModules.default ];
      programs.den.enable = true;
    };
  };
}
