local status, which_key = pcall(require, "which-key")
if (not status) then
  print("whichKey not found.")
  return
end

which_key.register({
  ["<leader>"] = {
    ["<TAB>"] = { ":b#<CR>", "Last buffer" },
    -- ["<TAB>"] = {
    --   name = "+workspace",
    --   n = {":tabn<CR>", "Next tab"},
    --   o = {":tabnew<CR>", "Oepn new tab"},
    --   p = {":tabp<CR>", "Previous tab"},
    --   x = {":tabclose<CR>", "Close current tab"},
    -- },

    b = {
      name = "+buffer",
      b = { ":Telescope buffers<CR>", "Search buffer" },
      d = { ":bd<CR>", "Delete buffer" },
    },

    f = {
      name = "+file",
      f = { ":Telescope file_browser path=%:p:h select_buffer=true<CR>", "Find file" },
      t = {
        name = "NvimTree",
        t = { ":NvimTreeToggle<CR>", "toggle" },
        f = { ":NvimTreeFindFileToggle<CR>", "find file" }
      }
    },

    g = {
      name = "+git",
      g = { ":Neogit<CR>", "Neogit status" },
    },

    h = {
      name = "+help",
      t = { ":Telescope help_tags<CR>", "help tags" },

    },

    p = {
      name = "+project",
      f = { ":Telescope find_files<CR>", "Find file in project" },
    },

    s = {
      name = "+search",
      p = { ":Telescope live_grep<CR>", "Search project" },
      s = { ":Telescope current_buffer_fuzzy_find<CR>", "Swipe" }
    },

    t = {
      name = "+toggle",
      t = { ":Twilight<CR>", "Twilight" },
    },

    w = {
      name = "+window",
      d = { ":close<CR>", "Close current window" },
      h = { "<C-w><C-h>", "Move left" },
      j = { "<C-w><C-j>", "Move bottom" },
      k = { "<C-w><C-k>", "Move top" },
      l = { "<C-w><C-l>", "Move right" },
      s = { "<C-w>s", "Split window below" },
      v = { "<C-w>v", "Split window right" },
    },

  }
})

which_key.setup {}
