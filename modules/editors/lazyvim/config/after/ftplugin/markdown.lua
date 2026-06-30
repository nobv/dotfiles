-- Markdown writing comfort + task/heading conveniences (buffer-local).
-- Loaded by Neovim for markdown buffers only.

-- ── Writing comfort ──────────────────────────────────────────────────────
vim.opt_local.wrap = true -- soft-wrap long lines
vim.opt_local.linebreak = true -- wrap at word boundaries, not mid-word
vim.opt_local.breakindent = true -- keep wrapped lines visually indented
vim.opt_local.spell = true
-- Spell-check English, but skip CJK (Japanese) so mixed JP/EN notes are not
-- flagged as misspellings. See :help spell-cjk.
vim.opt_local.spelllang = "en,cjk"
-- conceallevel is managed by render-markdown; don't override it here.

-- Move by visual line when wrapped (so j/k feel natural on long paragraphs).
local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = true, silent = true, desc = desc })
end
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { buffer = true, expr = true, silent = true, desc = "Down (visual line)" })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { buffer = true, expr = true, silent = true, desc = "Up (visual line)" })

-- ── Tasks ────────────────────────────────────────────────────────────────
-- Toggle the checkbox on the current line: - [ ]  <->  - [x]
map("n", "<leader>mt", function()
  local line = vim.api.nvim_get_current_line()
  if line:match("%[ %]") then
    line = line:gsub("%[ %]", "[x]", 1)
  elseif line:match("%[[xX]%]") then
    line = line:gsub("%[[xX]%]", "[ ]", 1)
  else
    return
  end
  vim.api.nvim_set_current_line(line)
end, "Toggle task checkbox")

-- ── Heading navigation ───────────────────────────────────────────────────
-- Jump to the next / previous markdown heading.
map("n", "]]", function()
  vim.fn.search([[^#\+ ]], "W")
end, "Next heading")
map("n", "[[", function()
  vim.fn.search([[^#\+ ]], "bW")
end, "Prev heading")
-- Folds: LazyVim uses treesitter folds, so headings fold automatically
-- (za toggle, zM close all, zR open all).
