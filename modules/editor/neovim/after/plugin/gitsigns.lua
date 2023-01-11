local state, gitsigns = pcall(require, "gitsigns")
if (not state) then
  print("gitsigns not found.")
  return
end


gitsigns.setup {
    current_line_blame = true,
}

-- Change color
-- https://github.com/lewis6991/gitsigns.nvim/wiki/FAQ#how-do-i-change-the-color-of-x
vim.api.nvim_set_hl(0, 'GitsignsCurrentLineBlame', { fg = 'DimGray',})
