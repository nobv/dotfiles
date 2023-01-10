local state, which_key = pcall(require, "which-key")
if (not state) then
  print("whichKey not found.")
  return
end


which_key.setup {}
