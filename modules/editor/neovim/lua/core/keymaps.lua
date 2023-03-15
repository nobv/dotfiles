-- leader key
vim.g.mapleader = " "


local keyset = require("../util").keyset

-- insert mode
keyset("i", "jk", "<ESC>") -- exit insert mode with jk


-- -- normal mode
-- keyset("n", "<leader>nh", ":noh<CR>") -- clear search highlight
-- keyset("n", "x", '"_x"') -- don't copy by x
-- keyset("n", "<leader>+", "<C-a>") -- increment
-- keyset("n", "<leader>-", "<C-x>") -- decrement
--
--
