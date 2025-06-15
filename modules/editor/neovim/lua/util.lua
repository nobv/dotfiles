local M = {}

function M.keyset(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

function M.to_camel_case(str)
  return str:gsub("_(%w)", string.upper):gsub("(%w)(%w*)", function(first, rest)
    return first:upper() .. rest:lower()
  end)
end

return M
