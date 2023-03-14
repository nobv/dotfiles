local status, neogit = pcall(require, "neogit")
if (not status) then
  print("neogit not found.")
  return
end


neogit.setup {}
