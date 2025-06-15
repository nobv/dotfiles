local status, colorizer = pcall(require, "colorizer")
if (not status) then
  print("nvim-colorizer not found.")
  return
end

colorizer.setup({
  user_default_options = {
    tailwind = true,
  }
})
