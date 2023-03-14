local status, nvim_tree = pcall(require, "nvim-tree")
if (not status) then
  print("nvim-tree not found.")
  return
end


nvim_tree.setup {}
