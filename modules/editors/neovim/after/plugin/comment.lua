local status, comment = pcall(require, "Comment")
if (not status) then
  print("Comment.nvim not found.")
  return
end


comment.setup({
  pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
})
