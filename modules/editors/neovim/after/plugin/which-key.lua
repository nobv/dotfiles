local status, which_key = pcall(require, "which-key")
if (not status) then
  print("whichKey not found.")
  return
end

which_key.register({
  g = {
    d = { "<cmd>Lspsaga goto_definition<CR>", "Go to definition" },
    h = { "<cmd>Lspsaga lsp_finder<CR>", "LSP finder" },
    r = {
      name = "Rename",
      e = { "<cmd>Lspsaga rename<CR>", "Rename all occurrene of the entire file" },
      s = { "<cmd>Lspsaga rename ++project<CR>", "Rename all occurrene of the selected files" },
    },
    p = { "<cmd>Lspsaga peek_definition<CR>", "Peak definition" },
    t = { "<cmd>Lspsaga peek_type_definition<CR>", "Peek type definition" }
    -- t = { "<cmd>Lspsaga goto_type_definition<CR>", "Go to type definition" }
  },
  K = { "<cmd>Lspsaga hover_doc ++keep<CR>", "Hover Doc" },
  t = {
    name = "Neotest",
    a = { "<cmd>lua require('neotest').run.attach()<cr>", "Attach" },
    f = { "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", "Run File" },
    F = { "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>", "Debug File" },
    l = { "<cmd>lua require('neotest').run.run_last()<cr>", "Run Last" },
    L = { "<cmd>lua require('neotest').run.run_last({ strategy = 'dap' })<cr>", "Debug Last" },
    n = { "<cmd>lua require('neotest').run.run()<cr>", "Run Nearest" },
    N = { "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", "Debug Nearest" },
    o = { "<cmd>lua require('neotest').output.open({ enter = true })<cr>", "Output" },
    S = { "<cmd>lua require('neotest').run.stop()<cr>", "Stop" },
    s = { "<cmd>lua require('neotest').summary.toggle()<cr>", "Summary" },
  },
  ["<leader>"] = {
    [":"] = { ":Telescope commands<CR>", "List available commands and run" },
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
        -- t = { ":NvimTreeToggle<CR>", "toggle" },
        t = { ":NvimTreeFindFileToggle<CR>", "Find file" }
      }
    },

    g = {
      name = "+git",
      g = { ":Neogit<CR>", "Neogit status" },
      u = { vim.cmd.UndotreeToggle, "undo-tree" }
    },

    h = {
      name = "+help",
      t = { ":Telescope help_tags<CR>", "help tags" },
    },

    l = {
      name = "+lsp",
      a = { "<cmd>Lspsaga code_action<CR>", "Code action" },
      c = {
        name = "+code_lens",
        s = { "<cmd> lua vim.lsp.codelens.refresh()<CR>", "Show code lens" },
        r = { "<cmd>lua vim.lsp.codelens.run()<CR>", "Run code lens" }
      },
      d = {
        name = "+diagnostics",
        b = { "<cmd>Lspsaga show_buf_diagnostics<CR>", "Show buffer diabnostics" },
        c = { "<cmd>Lspsaga show_cursor_diagnostics<CR>", "Show cursor diagnostics" },
        l = { "<cmd>Lspsaga show_line_diagnostics<CR>", "Show line diagnostics" },
        w = { "<cmd>Lspsaga show_workspace_diagnostics<CR>", "Show workspace diagnostics" },
        p = { "<cmd>Lspsaga diagnostic_jump_prev<CR>", "Diagnostics jump previous" },
        n = { "<cmd>Lspsaga diagnostic_jump_next<CR>", "Diagnostics jump next" },
      },
      h = {
        name = "hierarchy",
        i = { "<cmd>Lspsaga incoming_calls<CR>", "Incoming calls" },
        o = { "<cmd>Lspsaga outgoing_calls<CR>", "Outgoing calls" },
      },
      o = { "<cmd>Lspsaga outline<CR>", "Toggle outline" },
    },

    o = {
      name = "+open",
      t = { "<cmd>Lspsaga term_toggle<CR>", "Open floating terminal" },
    },
    p = {
      name = "+project",
      -- f = { ":Telescope find_files find_command=rg,--ignore,--hidden,--files<CR>", "Find file in project" },
      f = { ":Telescope find_files<CR>", "Find file in project" },
    },

    s = {
      name = "+search",
      p = { ":Telescope live_grep<CR>", "Search project" },
      s = { ":Telescope current_buffer_fuzzy_find<CR>", "Swipe" }
    },

    tg = {
      name = "+toggle",
      h = { ":noh<CR>", "Clear search highlight" },
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
      m = { "<C-w>o", "maximize" },
      ["="] = { "<C-w>=", "balance-window" },
    },
  }
})

which_key.setup {}
