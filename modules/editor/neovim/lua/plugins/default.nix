{ config, pkgs, lib, ... }:

{
  plugins = with pkgs.vimPlugins; [
    # Tools
    telescope-nvim # https://github.com/nvim-telescope/telescope.nvim
    telescope-file-browser-nvim # https://github.com/nvim-telescope/telescope-file-browser.nvim

    vim-easymotion # https://github.com/easymotion/vim-easymotion/
    nvim-tree-lua # https://github.com/nvim-tree/nvim-tree.lua
    which-key-nvim # https://github.com/folke/which-key.nvim
    comment-nvim # https://github.com/numToStr/Comment.nvim
    nvim-autopairs # https://github.com/windwp/nvim-autopairs/

    # Languages
    vim-nix # https://github.com/LnL7/vim-nix
    purescript-vim # https://github.com/purescript-contrib/purescript-vim

    ## LSP
    coc-pyright # https://github.com/fannheyward/coc-pyright

    # UI
    dracula-vim # https://github.com/dracula/vim/
    dracula-nvim # https://github.com/Mofiqul/dracula.nvim/
    lualine-nvim # https://github.com/nvim-lualine/lualine.nvim
    nvim-web-devicons # https://github.com/nvim-tree/nvim-web-devicons/

    # Git
    gitsigns-nvim # https://github.com/lewis6991/gitsigns.nvim
    neogit # https://github.com/TimUntersberger/neogit
  ];
}
