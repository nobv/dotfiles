local status, conform = pcall(require, "conform")
if not status then
  print("conform not found.")
  return
end

conform.setup({
  formatters_by_ft = {
    python = { "isort", "black" },
    javascript = { "biome" },
    javascriptreact = { "biome" },
    typescript = { "biome" },
    typescriptreact = { "biome" },
    json = { "biome" },
    jsonc = { "biome" },
    css = { "biome" },
    nix = { "nixfmt" },
  },
  format_on_save = {
    timeout_ms = 1000,
    lsp_fallback = true,
  },
})

vim.keymap.set({ "n", "x" }, "<Leader>f", function()
  conform.format({ async = false, lsp_fallback = true })
end, { desc = "[format] format buffer" })
