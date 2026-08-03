-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Seamless <C-h/j/k/l> between Neovim splits and herdr panes
-- (vim-herdr-navigation); falls back to tmux / plain wincmd outside herdr.
local herdr_nav = vim.fn.stdpath("data") .. "/lazy/vim-herdr-navigation/editor/nvim.lua"
if (vim.uv or vim.loop).fs_stat(herdr_nav) then
  dofile(herdr_nav)
end
