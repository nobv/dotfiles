local state, neogit = pcall(require, "neogit")
if (not state) then
  print("neogit not found.")
  return
end


neogit.setup {}
