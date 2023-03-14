local status, neogit = pcall(require, "Comment")
if (not status) then
  print("Comment.nvim not found.")
  return
end


require('Comment').setup()
