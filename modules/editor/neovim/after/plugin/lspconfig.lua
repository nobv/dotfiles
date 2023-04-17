local status, lspconfig = pcall(require, "lspconfig")
if (not status) then
  print("lspconfig not found.")
  return
end

local status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if (not status) then
  print("cmp_nvim_lsp not found.")
  return
end

local status, lspsaga = pcall(require, "lspsaga")
if (not status) then
  print("lspsaga not found.")
end
lspsaga.setup({})


local status, fidget = pcall(require, "fidget")
if (not status) then
  print("fidget not found.")
end
fidget.setup {}

local lsp_capabilities = cmp_nvim_lsp.default_capabilities()

local get_servers = require('mason-lspconfig').get_installed_servers

for _, servername in ipairs(get_servers()) do
  lspconfig[servername].setup {
    capabilities = lsp_capabilities,
  }
end

-- format on save
-- https://github.com/neovim/nvim-lspconfig/issues/1792#issuecomment-1352782205
vim.api.nvim_create_autocmd("BufWritePre", {
  buffer = buffer,
  callback = function()
    vim.lsp.buf.format { async = false }
  end
})


local to_camel_case = require("util").to_camel_case

local signs = {
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = '»'
}

for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. to_camel_case(type)
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end
