local status, ibl = pcall(require, "ibl")
if (not status) then
  print("indent_blankline not found.")
  return
end

-- vim.opt.list = true
-- vim.opt.listchars:append "space:⋅"
-- vim.opt.listchars:append "eol:↴"

ibl.setup()
