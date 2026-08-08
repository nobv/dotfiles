-- Neovim side of christoomey/vim-tmux-navigator: provides the :TmuxNavigate*
-- commands that vim-herdr-navigation's nvim.lua (loaded from
-- config/keymaps.lua) calls at a split edge when inside tmux ($TMUX set and
-- no $HERDR_PANE_ID). Mappings are disabled so vim-herdr-navigation keeps
-- ownership of <C-h/j/k/l> in both multiplexers.
return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
  },
}
