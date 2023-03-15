local status, telescope = pcall(require, "telescope")
if (not status) then
  return
end

-- Extensions
telescope.load_extension("file_browser")
