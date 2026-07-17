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
    # macOS の Resume（再ログイン時にウインドウを再度開く）を無効にする。den は
    # ~/Desk を権威にタイル窓を自分で開閉する（深い休止・on-sit）ため、Resume が
    # 復元した窓が机の workspace に 1 枚でも着地すると on-sit の空机ガードが誤作動し、
    # Chrome・apps・dev.sh のどれも起動しないまま座った状態になる。タブの復元は
    # Chrome プロファイルの「前回開いていたページを開く」が担う（den の README 参照）。
    # nix-darwin の system.defaults.loginwindow はこのキーを持たないため CustomUserPreferences。
    system.defaults.CustomUserPreferences."com.apple.loginwindow".TALLogoutSavesState = false;

    home-manager.users.${username} = {
      imports = [ inputs.den.homeManagerModules.default ];
      programs.den.enable = true;
    };
  };
}
