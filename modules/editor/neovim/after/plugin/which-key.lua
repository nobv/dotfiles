local status, which_key = pcall(require, "which-key")
if (not status) then
  print("whichKey not found.")
  return
end


which_key.setup {}
