local status, dracula = pcall(require, "dracula")
if (not status) then
  print("dracula not found.")
  return
end

dracula.setup({
  transparent_bg = true,
})

vim.cmd [[colorscheme dracula]]
