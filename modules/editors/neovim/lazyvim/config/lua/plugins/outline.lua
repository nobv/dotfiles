-- Keyboard-navigable heading/symbol outline panel.
return {
  {
    "hedyhli/outline.nvim",
    cmd = { "Outline", "OutlineOpen" },
    keys = {
      { "<leader>o", "<cmd>Outline<cr>", desc = "Toggle outline" },
    },
    opts = {
      outline_window = { width = 30, auto_close = true },
      symbol_folding = { autofold_depth = 1 },
    },
  },
}
