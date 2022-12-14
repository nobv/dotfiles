{ config, pkgs, lib, ... }:

{
  plugins = with pkgs.vimPlugins; [
    # Tools
    telescope-nvim # https://github.com/nvim-telescope/telescope.nvim
    vim-easymotion # https://github.com/easymotion/vim-easymotion/

    # Languages
    vim-nix # https://github.com/LnL7/vim-nix
    purescript-vim # https://github.com/purescript-contrib/purescript-vim

    ## coc
    coc-pyright # https://github.com/fannheyward/coc-pyright
    coc-lists # https://github.com/neoclide/coc-lists

    # UI
    dracula-vim # https://github.com/dracula/vim/
    dracula-nvim # https://github.com/Mofiqul/dracula.nvim/
  ];
}
