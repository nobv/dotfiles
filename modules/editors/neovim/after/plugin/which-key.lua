local status, which_key = pcall(require, "which-key")
if (not status) then
  print("whichKey not found.")
  return
end

which_key.setup({})

which_key.add({
  { "<leader>f", group = "find" },
  { "<leader>g", group = "git" },
  { "<leader>c", group = "code" },
  { "<leader>t", group = "test" },
  { "<leader>o", group = "open" },
  { "<leader>w", group = "window" },
  { "<leader>b", group = "buffer" },
  { "<leader>q", group = "quit" },

  -- Find / File
  { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
  { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
  { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
  { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
  { "<leader>fe", "<cmd>NvimTreeFindFileToggle<CR>", desc = "Explorer" },

  -- Git
  { "<leader>gg", "<cmd>Neogit<CR>", desc = "Neogit" },
  { "<leader>gb", "<cmd>Telescope git_branches<CR>", desc = "Git branches" },
  { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Git commits" },
  { "<leader>gh", "<cmd>Gitsigns preview_hunk<CR>", desc = "Preview hunk" },

  -- Code / LSP
  { "<leader>ca", "<cmd>Lspsaga code_action<CR>", desc = "Code action" },
  { "<leader>cr", "<cmd>Lspsaga rename<CR>", desc = "Rename" },
  { "<leader>cd", "<cmd>Lspsaga peek_definition<CR>", desc = "Definition" },
  {
    "<leader>cf",
    function()
      require("conform").format({ async = false, lsp_fallback = true })
    end,
    desc = "Format buffer",
  },
  { "K", "<cmd>Lspsaga hover_doc ++keep<CR>", desc = "Hover doc" },

  -- Test / Neotest
  { "<leader>tt", function() require("neotest").run.run() end, desc = "Nearest test" },
  { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "File tests" },
  { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Last test" },
  { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test summary" },
  { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Test output" },

  -- Open / Terminal
  { "<leader>ot", "<cmd>ToggleTerm<CR>", desc = "Terminal toggle" },
  { "<leader>of", "<cmd>ToggleTerm direction=float<CR>", desc = "Float terminal" },

  -- Window / Buffer
  { "<leader>wh", "<C-w><C-h>", desc = "Focus left" },
  { "<leader>wj", "<C-w><C-j>", desc = "Focus down" },
  { "<leader>wk", "<C-w><C-k>", desc = "Focus up" },
  { "<leader>wl", "<C-w><C-l>", desc = "Focus right" },
  { "<leader>ws", "<C-w>s", desc = "Split below" },
  { "<leader>wv", "<C-w>v", desc = "Split right" },
  { "<leader>bd", "<cmd>bd<CR>", desc = "Delete buffer" },
  { "<leader>bn", "<cmd>bnext<CR>", desc = "Next buffer" },
  { "<leader>bp", "<cmd>bprevious<CR>", desc = "Previous buffer" },

  -- Quit
  { "<leader>qq", "<cmd>qa<CR>", desc = "Quit all" },
  { "<leader>qw", "<cmd>wqa<CR>", desc = "Save and quit all" },
})
