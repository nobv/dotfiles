local status, neotest = pcall(require, "neotest")
if (not status) then
  print("neotest not found.")
  return
end

local neotest_ns = vim.api.nvim_create_namespace("neotest")
vim.diagnostic.config({
  virtual_text = {
    format = function(diagnostic)
      local message =
          diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
      return message
    end,
  },
}, neotest_ns)

neotest.setup({
  adapters = {
    require("neotest-python")({
      dap = { justMyCode = false },
      args = { "--log-level", "DEBUG" },
    }),
    require("neotest-plenary"),
    require("neotest-rust"),
    require("neotest-go")({
      experimental = {
        test_table = true,
      },
    }),
    require("neotest-haskell"),
  }
})
