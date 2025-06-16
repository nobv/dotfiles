local status, _ = pcall(require, "nvim-treesitter")
if (not status) then
  print("nvim-treesitter not found.")
  return
end

local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
ts_update()


require "nvim-treesitter.configs".setup {
  sync_install = false,
  highlight = {
    enable = true,
  },
}
