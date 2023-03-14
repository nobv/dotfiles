-- leader key
vim.g.mapleader = " "


local keyset = require("../util").keyset

-- insert mode
keyset("i", "jk", "<ESC>") -- exit insert mode with jk


-- normal mode
keyset("n", "<leader>nh", ":noh<CR>") -- clear search highlight
keyset("n", "x", '"_x"') -- don't copy by x
keyset("n", "<leader>+", "<C-a>") -- increment
keyset("n", "<leader>-", "<C-x>") -- decrement

--window
keyset("n", "<leader>wv", "<C-w>v") -- split window vertically
keyset("n", "<leader>ws", "<C-w>s") -- split window horizontally
keyset("n", "<leader>wx", ":close<CR>") -- close current split window
keyset("n", "<leader>wh", "<C-w><C-h>") -- move to left window
keyset("n", "<leader>wj", "<C-w><C-j>") -- move to bottom window
keyset("n", "<leader>wk", "<C-w><C-k>") -- move to top window
keyset("n", "<leader>wl", "<C-w><C-l>") -- move to right window

-- tab
keyset("n", "<leader>to", ":tabnew<CR>") -- open new tab
keyset("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keyset("n", "<leader>tn", ":tabn<CR>") -- go to next tab
keyset("n", "<leader>tp", ":tabp<CR>") -- go to previous tab


