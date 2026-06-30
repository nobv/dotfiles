-- Auto-continue list bullets / numbers on <CR> and o/O in markdown.
return {
  {
    "dkarter/bullets.vim",
    ft = { "markdown", "text", "gitcommit" },
    init = function()
      vim.g.bullets_enabled_file_types = { "markdown", "text", "gitcommit" }
      -- Renumber ordered lists, but keep mappings minimal to avoid clashing
      -- with blink.cmp's <CR> (which only intercepts <CR> while the menu is open).
      vim.g.bullets_set_mappings = 1
      vim.g.bullets_outline_levels = { "num", "abc", "std-" }
    end,
  },
}
