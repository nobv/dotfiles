local status, ts_context_commentstring = pcall(require, "ts_context_commentstring")
if (not status) then
  print("ts_context_commentstring not found.")
  return
end

vim.g.skip_ts_context_commentstring_module = true
ts_context_commentstring.setup {}
