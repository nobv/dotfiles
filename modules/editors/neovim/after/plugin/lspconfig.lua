local status, _ = pcall(require, "lspconfig")
if (not status) then
  print("nvim-lspconfig not found.")
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

local servers = {
  "bashls",
  "dhall_lsp_server",
  "gopls",
  "html",
  "jsonls",
  "lua_ls",
  "nixd",
  "purescriptls",
  "pyright",
  "terraformls",
  "rust_analyzer",
  "vimls",
  "yamlls",
}

if vim.lsp.config["ts_ls"] ~= nil then
  table.insert(servers, "ts_ls")
elseif vim.lsp.config["tsserver"] ~= nil then
  table.insert(servers, "tsserver")
end

vim.lsp.config("*", {
  capabilities = lsp_capabilities,
})

for _, servername in ipairs(servers) do
  if servername == "nixd" then
    vim.lsp.config("nixd", {
      settings = {
        nixd = {
          formatting = {
            command = { "nixfmt" },
          },
        },
      },
    })
  end

  local ok, err = pcall(vim.lsp.enable, servername)
  if not ok then
    vim.notify(string.format("LSP enable failed for %s: %s", servername, err), vim.log.levels.WARN)
  end
end


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
