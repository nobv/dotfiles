{ config, pkgs, lib, ... }:

{
  vimPlugins = with pkgs.vimPlugins; [
    # Tools
    ## Navigation
    telescope-nvim # https://github.com/nvim-telescope/telescope.nvim
    telescope-file-browser-nvim # https://github.com/nvim-telescope/telescope-file-browser.nvim
    vim-easymotion # https://github.com/easymotion/vim-easymotion/
    nvim-tree-lua # https://github.com/nvim-tree/nvim-tree.lua
    which-key-nvim # https://github.com/folke/which-key.nvim
    ##Git
    gitsigns-nvim # https://github.com/lewis6991/gitsigns.nvim
    plenary-nvim # https://github.com/nvim-lua/plenary.nvim
    neogit # https://github.com/TimUntersberger/neogit

    # Languages
    vim-nix # https://github.com/LnL7/vim-nix
    purescript-vim # https://github.com/purescript-contrib/purescript-vim
    dhall-vim # https://github.com/vmchale/dhall-vim
    ## LSP
    coc-pyright # https://github.com/fannheyward/coc-pyright

    # UI
    dracula-vim # https://github.com/dracula/vim/
    dracula-nvim # https://github.com/Mofiqul/dracula.nvim/
    lualine-nvim # https://github.com/nvim-lualine/lualine.nvim
    nvim-web-devicons # https://github.com/nvim-tree/nvim-web-devicons/
    nvim-colorizer-lua # https://github.com/norcalli/nvim-colorizer.lua
    indent-blankline-nvim # https://github.com/lukas-reineke/indent-blankline.nvim
    # nvim-treesitter # https://github.com/nvim-treesitter/nvim-treesitter


    # Editing
    twilight-nvim # https://github.com/folke/twilight.nvim
    comment-nvim # https://github.com/numToStr/Comment.nvim
    nvim-autopairs # https://github.com/windwp/nvim-autopairs/

    # Buffer
    bufferline-nvim # https://github.com/akinsho/bufferline.nvim/
  ];

  # tree-sitter-grammars = with pkgs.tree-sitter-grammars; [
  #   tree-sitter-lua # https://github.com/MunifTanjim/tree-sitter-lua
  #   tree-sitter-go
  #   tree-sitter-nix
  #   tree-sitter-python
  # ];
}
