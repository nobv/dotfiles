local status, comment = pcall(require, "Comment")
if (not status) then
  print("Comment.nvim not found.")
  return
end


comment.setup()
