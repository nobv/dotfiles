local status, toggleterm = pcall(require, "toggleterm")
if (not status) then
  print("toggleterm not found.")
  return
end


toggleterm.setup {}
