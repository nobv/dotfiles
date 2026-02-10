local status, lint = pcall(require, "lint")
if not status then
  print("nvim-lint not found.")
  return
end

if vim.fn.executable("mypy") == 1 then
  lint.linters_by_ft.python = { "mypy" }
end

if vim.fn.executable("biome") == 1 then
  lint.linters_by_ft.javascript = { "biomejs" }
  lint.linters_by_ft.javascriptreact = { "biomejs" }
  lint.linters_by_ft.typescript = { "biomejs" }
  lint.linters_by_ft.typescriptreact = { "biomejs" }
  lint.linters_by_ft.json = { "biomejs" }
  lint.linters_by_ft.jsonc = { "biomejs" }
  lint.linters_by_ft.css = { "biomejs" }
end

vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
  callback = function()
    lint.try_lint()
  end,
})
