local status, null_ls = pcall(require, "null-ls")
if (not status) then
  print("null_ls not found.")
  return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions

local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })
local event = "BufWritePre" -- or "BufWritePost"
local async = event == "BufWritePost"

null_ls.setup({
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.keymap.set("n", "<Leader>f", function()
        vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
      end, { buffer = bufnr, desc = "[lsp] format" })

      -- format on save
      vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
      vim.api.nvim_create_autocmd(event, {
        buffer = bufnr,
        group = group,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr, async = async })
        end,
        desc = "[lsp] format on save",
      })
    end

    if client.supports_method("textDocument/rangeFormatting") then
      vim.keymap.set("x", "<Leader>f", function()
        vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
      end, { buffer = bufnr, desc = "[lsp] format" })
    end
  end,
  sources = {
    -- Python
    formatting.black,
    formatting.isort,
    diagnostics.mypy,
    -- "javascript",
    -- "javascriptreact",
    -- "typescript",
    -- "typescriptreact",
    -- "vue",
    -- "css",
    -- "scss",
    -- "less",
    -- "html",
    -- "json",
    -- "jsonc",
    -- "yaml",
    -- "markdown",
    -- "markdown.mdx",
    -- "graphql",
    -- "handlebars"
    formatting.prettier,
    diagnostics.eslint,
    code_actions.eslint
  },

})
