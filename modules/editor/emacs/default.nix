{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.editor.emacs;
in
{
  options.modules.editor.emacs = {
    enable = mkEnableOption "Enable Emacs editor with Chemacs2 profile switcher";
  };

  config = mkIf cfg.enable {
    programs.emacs = {
      enable = true;
    };

    home = {
      packages = with pkgs; [
        # emacs28Packages.lsp-pyright
      ];

      file = {
        # https://github.com/plexus/chemacs2
        # Emacs profile switcher
        "emacs" = {
          recursive = true;
          target = ".emacs.d";
          source = pkgs.fetchFromGitHub {
            owner = "plexus";
            repo = "chemacs2";
            rev = "ef82118824fac2b2363d3171d26acbabe1738326";
            sha256 = "1gg4aa6dxc4k9d78j8mrrhy0mvhqmly7jxby69518xs9njxh00dq";
          };
        };

        ".emacs-profiles.el" = {
          text = builtins.readFile ./.emacs-profiles.el;
        };
      };
    };
  };
}
