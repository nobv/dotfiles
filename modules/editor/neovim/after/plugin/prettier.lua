local status, prettier = pcall(require, "prettier")
if (not status) then
  return
end

prettier.setup({
  bin = "prettier",
  filetypes = {
    "css",
    "graphql",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "less",
    "markdown",
    "scss",
    "typescript",
    "typescriptreact",
    -- "yaml",
  },
  cli_options = {
    -- https://prettier.io/docs/en/cli.html#--config-precedence
    config_precedence = "prefer-file", -- or "cli-override" or "file-override"
    -- I can set Prettire's options if needed. see: https://prettier.io/docs/en/options.html
  },
})
