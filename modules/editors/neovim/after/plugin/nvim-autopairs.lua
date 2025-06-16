local status, autopairs = pcall(require, "nvim-autopairs")
if (not status) then
  print("nvim-autopairs not found.")
  return
end

autopairs.setup {}
