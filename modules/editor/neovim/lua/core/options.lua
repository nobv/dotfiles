-- disable for nvim-tree.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1


vim.cmd([[
    packloadall
    silent! helptags ALL
]])

local opt = vim.opt


-- line numbers
opt.number = true
opt.relativenumber = true

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- line wrapping
opt.wrap = false

-- search settings
opt.ignorecase = true
opt.smartcase = true

-- cursor line
opt.cursorline = true

-- appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace
opt.backspace = "indent,eol,start"

-- clipboard
opt.clipboard:append("unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true

opt.iskeyword:append("-")

-- fold
opt.foldmethod = "indent"

-- fonts
opt.guifont = { "Hasklig", ":h16" }

-- backup
opt.backup = false
opt.writebackup = false

opt.updatetime = 300

-- noswapfile
opt.swapfile = false
