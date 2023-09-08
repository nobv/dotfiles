local status, mason = pcall(require, "mason")
if (not status) then
  print("mason not found.")
  return
end

local status, mason_lspconfig = pcall(require, "mason-lspconfig")
if (not status) then
  print("mason-lspconfig not found.")
  return
end

mason.setup()

mason_lspconfig.setup {
  ensure_installed = {
    -- bash
    "bashls",
    -- Makefile
    "cmake",
    -- dhall
    "dhall_lsp_server",
    -- Docker
    "dockerls",
    "docker_compose_language_service",
    -- Go
    "gopls",
    -- HTML
    "html",
    -- JSON
    "jsonls",
    -- Lua
    "lua_ls",
    -- Nix
    "rnix",
    -- PureScript
    "purescriptls",
    -- Python
    "pyright",
    -- Terraform
    "terraformls",
    -- Rust
    "rust_analyzer",
    -- JS/TS
    "tsserver",
    "vimls",
    "yamlls",
  },
}
