local state, nvim_tree = pcall(require, "nvim-tree")
if (not state) then
  print("nvim-tree not found.")
  return
end


nvim_tree.setup {}
