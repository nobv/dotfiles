local status, telescope = pcall(require, "telescope")
if (not status) then 
  return 
end

local keyset = require("util").keyset

telescope.setup{}

local telescope_builtin = require('telescope.builtin')
keyset('n', '<leader>f', 
  function()
    telescope_builtin.find_files({
      no_ignore = false,
      hidden = true
    })
  end)
keyset('n', '<leader>g', telescope_builtin.live_grep)
keyset('n', '<leader>b', telescope_builtin.buffers)
keyset('n', '<leader>h', telescope_builtin.help_tags)

-- Extensions
telescope.load_extension("file_browser")
keyset("n", "<Space><Space>", function()
  telescope.extensions.file_browser.file_browser({
    path = "%:p:h",
    respect_gitignore = false,
    hidden = true,
  })
end)

