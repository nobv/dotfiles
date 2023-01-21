# https://github.com/neoclide/coc.nvim
{
  enable = true;

  # https://github.com/neoclide/coc.nvim/wiki/Using-the-configuration-file
  settings = {

    coc = {
      preferences = {
        formatOnSave = true;
        formatOnSaveFiletypes = [
          "go"
          "haskell"
          "javascript"
          "json"
          "nix"
          "python"
          "rust"
          "typescript"
          "yaml"
        ];
      };
    };


    Lua.telemetry.enable = false;

    python = {
      formatting = {
        provider = "black";
        blackPath = "~/.nix-profile/bin/black";
      };
      linting = {
        mypyEnabled = true;
      };
    };

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

      golang = {
        command = "gopls";
        rootPatterns = [ "go.mod" ];
        filetypes = [ "go" ];
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

      rust = {
        command = "rust-analyzer";
        filetypes = [ "rust" ];
        rootPatterns = [ "Cargo.toml" ];
      };

      haskell = {
        command = "haskell-language-server-wrapper";
        args = [ "--lsp" ];
        rootPatterns = [ "*.cabal" "stack.yaml" "cabal.project" "package.yaml" "hie.yaml" ];
        filetypes = [ "haskell" "lhaskell" ];
        settings = {
          haskell = {
            checkParents = "CheckOnSave";
            checkProject = true;
            maxCompletions = 40;
            formattingProvider = "ormolu";
            plugin = {
              stan = { globalOn = true; };
            };
          };
        };
      };

      terraform = {
        command = "terraform-ls";
        args = [ "serve" ];
        filetypes = [ "terraform" "tf" ];
        initializationOptions = { };
      };

    };
  };
}
