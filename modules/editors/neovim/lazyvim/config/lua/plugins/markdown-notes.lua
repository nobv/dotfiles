-- Re-enable render-markdown checkboxes.
-- LazyVim's markdown extra sets `checkbox.enabled = false`, so `- [ ]` / `- [x]`
-- show as raw text. This override renders them as icons.
-- Remove this file to revert.
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      checkbox = { enabled = true },
      heading = {
        -- LazyVim empties icons and turns off the sign; restore the per-level icons.
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        -- sign = true, -- uncomment to also show the heading glyph in the sign column
      },
    },
  },
}
