# https://github.com/neoclide/coc.nvim
{
  enable = true;

  # https://github.com/neoclide/coc.nvim/wiki/Using-the-configuration-file
  settings = {
    Lua.telemetry.enable = false;

    suggest = {
      noselect = true;
      enablePreview = true;
      enablePreselect = true;
      disableKind = true;
    };

    languageserver = {

      dhall = {
        command = "dhall-lsp-server";
        filetypes = [ "dhall" ];

      };

      dockerfile = {
        command = "docker-languageserver";
        filetypes = [ "dockerifle" ];
        args = [ "--stdio" ];
      };

      lua = {
        command = "lua-lsp";
        filetypes = [ "lua" ];
      };

      nix = {
        command = "rnix-lsp";
        filetypes = [ "nix" ];
      };

      purescript = {
        command = "purescript-language-server";
        args = [ "--stdio" ];
        filetypes = [ "purescript" ];
        "trace.server" = "off";
        rootPatterns = [ "bower.json" "psc-package.json" "spago.dhall" ];
        settings = {
          purescript = {
            addSpagoSources = true;
            addNpmPath = true; # Set to true if using a local purty install for formatting
            formatter = "purs-tidy";
          };
        };
      };

      python = {
        command = "pyright";
        filetypes = [ "python" ];
        settings = {
          pyright = {
            enable = true;
          };
        };
      };

    };
  };
}
