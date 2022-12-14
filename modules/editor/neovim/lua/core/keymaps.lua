-- leader key
vim.g.mapleader = " "


local function keymap(mode, lhs, rhs, opts)
  local options = { noremap=true, silent=true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end


-- insert mode
keymap("i", "jk", "<ESC>") -- exit insert mode with jk


-- normal mode
keymap("n", "<leader>nh", ":hohl<CR>") -- clear search highlight
keymap("n", "x", '"_x"') -- don't copy by x
keymap("n", "<leader>+", "<C-a>") -- increment
keymap("n", "<leader>-", "<C-x>") -- decrement

--window
keymap("n", "<leader>wv", "<C-w>v") -- split window vertically
keymap("n", "<leader>ws", "<C-w>s") -- split window horizontally
keymap("n", "<leader>wx", ":close<CR>") -- close current split window
keymap("n", "<leader>wh", "<C-w><C-h>") -- move to left window
keymap("n", "<leader>wj", "<C-w><C-j>") -- move to bottom window
keymap("n", "<leader>wk", "<C-w><C-k>") -- move to top window
keymap("n", "<leader>wl", "<C-w><C-l>") -- move to right window

-- tab
keymap("n", "<leader>to", ":tabnew<CR>") -- open new tab
keymap("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap("n", "<leader>tn", ":tabn<CR>") -- go to next tab
keymap("n", "<leader>tp", ":tabp<CR>") -- go to previous tab

-- telescope
local telescope_builtin = require('telescope.builtin')
keymap('n', '<leader>f', telescope_builtin.find_files)
keymap('n', '<leader>g', telescope_builtin.live_grep)
keymap('n', '<leader>b', telescope_builtin.buffers)
keymap('n', '<leader>h', telescope_builtin.help_tags)

