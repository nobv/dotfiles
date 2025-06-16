local status, lf = pcall(require, "lf")
if (not status) then
  print("lf not found.")
  return
end


lf.setup {}
