{ config, pkgs, lib, ... }:
let
  stable = import <nixpkgs-stable> { };
  stablePkgs = with stable.vimPlugins; [ ];
in
{
  vimPlugins = with pkgs.vimPlugins; [
    # Tools
    ## Navigation
    telescope-nvim # https://github.com/nvim-telescope/telescope.nvim
    telescope-file-browser-nvim # https://github.com/nvim-telescope/telescope-file-browser.nvim
    vim-easymotion # https://github.com/easymotion/vim-easymotion/
    nvim-tree-lua # https://github.com/nvim-tree/nvim-tree.lua
    which-key-nvim # https://github.com/folke/which-key.nvim
    {
      plugin = pkgs.vimUtils.buildVimPluginFrom2Nix {
        name = "lf-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "lmburns";
          repo = "lf.nvim";
          rev = "master";
          hash = "sha256-ys3kgXtgaE5OGyNYZ2PuqM9FDGjxfIjRgXBUDBVIjUM=";
        };
      };

    }
    toggleterm-nvim # https://github.com/akinsho/toggleterm.nvim/

    ##Git
    gitsigns-nvim # https://github.com/lewis6991/gitsigns.nvim
    plenary-nvim # https://github.com/nvim-lua/plenary.nvim
    neogit # https://github.com/TimUntersberger/neogit
    undotree # https://github.com/mbbill/undotree
    lazygit-nvim # https://github.com/kdheepak/lazygit.nvim/

    # Languages
    vim-nix # https://github.com/LnL7/vim-nix
    purescript-vim # https://github.com/purescript-contrib/purescript-vim
    dhall-vim # https://github.com/vmchale/dhall-vim
    neodev-nvim # https://github.com/folke/neodev.nvim

    ## LSP 
    nvim-lspconfig # https://github.com/neovim/nvim-lspconfig/
    mason-nvim # https://github.com/williamboman/mason.nvim/
    mason-lspconfig-nvim # https://github.com/williamboman/mason-lspconfig.nvim
    lspsaga-nvim # https://github.com/nvimdev/lspsaga.nvim/

    nvim-cmp # https://github.com/hrsh7th/nvim-cmp/
    cmp-nvim-lsp # https://github.com/hrsh7th/cmp-nvim-lsp
    cmp-buffer # https://github.com/hrsh7th/cmp-buffer/
    cmp-path # https://github.com/hrsh7th/cmp-path/
    luasnip # https://github.com/l3mon4d3/luasnip/
    cmp_luasnip # https://github.com/saadparwaiz1/cmp_luasnip/
    null-ls-nvim # https://github.com/jose-elias-alvarez/null-ls.nvim/
    lspkind-nvim # https://github.com/onsails/lspkind.nvim/
    {
      plugin = pkgs.vimUtils.buildVimPluginFrom2Nix {
        name = "fidget-nvim";
        src = pkgs.fetchurl {
          url = "https://github.com/j-hui/fidget.nvim/archive/refs/tags/legacy.tar.gz";
          hash = "sha256-piJgAosA2LoF3gaF1EvcgTDYlkBmT5dKlSrTp0yG+vg=";
        };
      };
    }
    # fidget-nvim # https://github.com/j-hui/fidget.nvim/

    # Dap
    nvim-dap # https://github.com/mfussenegger/nvim-dap/
    nvim-dap-ui # https://github.com/rcarriga/nvim-dap-ui/
    nvim-dap-python # https://github.com/mfussenegger/nvim-dap-python/


    # UI
    dracula-nvim # https://github.com/Mofiqul/dracula.nvim/
    lualine-nvim # https://github.com/nvim-lualine/lualine.nvim
    nvim-web-devicons # https://github.com/nvim-tree/nvim-web-devicons/
    nvim-colorizer-lua # https://github.com/nvchad/nvim-colorizer.lua/
    indent-blankline-nvim # https://github.com/lukas-reineke/indent-blankline.nvim

    # see: https://nixos.org/manual/nixpkgs/unstable/#vim:~:text=for%20some%20plugins-,Treesitter,-By%20default
    nvim-treesitter.withAllGrammars # https://github.com/nvim-treesitter/nvim-treesitter


    # Editing
    twilight-nvim # https://github.com/folke/twilight.nvim
    comment-nvim # https://github.com/numToStr/Comment.nvim
    nvim-ts-context-commentstring # https://github.com/joosepalviste/nvim-ts-context-commentstring/
    nvim-autopairs # https://github.com/windwp/nvim-autopairs/
    nvim-ts-autotag # https://github.com/windwp/nvim-ts-autotag

    # Buffer
    bufferline-nvim # https://github.com/akinsho/bufferline.nvim/

    # Tests
    FixCursorHold-nvim # https://github.com/antoinemadec/FixCursorHold.nvim/
    neotest # https://github.com/nvim-neotest/neotest
    neotest-plenary # https://github.com/nvim-neotest/neotest-plenary/
    neotest-python # https://github.com/nvim-neotest/neotest-python/
    neotest-rust # https://github.com/rouge8/neotest-rust/
    neotest-go # https://github.com/nvim-neotest/neotest-go/
    neotest-haskell # https://github.com/MrcJkb/neotest-haskell/
    {
      plugin = pkgs.vimUtils.buildVimPluginFrom2Nix {
        name = "neotest-vim-test";
        # https://github.com/nvim-neotest/neotest-vim-test
        src = pkgs.fetchFromGitHub {
          owner = "nvim-neotest";
          repo = "neotest-vim-test";
          rev = "master";
          hash = "sha256-fFm5Yt2Sus5jLSapHUtLlDkBWPLLKfWsj2NSXD8NPYo=";
        };
      };
    }
    vim-test # https://github.com/vim-test/vim-test/

    # Other
    vim-tmux-navigator # https://github.com/christoomey/vim-tmux-navigator/
    # copilot-vim # https://github.com/github/copilot.vim/
  ] ++ stablePkgs;
}
