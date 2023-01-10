local state, gitsigns = pcall(require, "gitsigns")
if (not state) then
  print("gitsigns not found.")
  return
end


gitsigns.setup {
    current_line_blame = true,
}
