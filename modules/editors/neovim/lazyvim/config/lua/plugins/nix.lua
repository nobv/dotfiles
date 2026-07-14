-- Use the Nix-provided `nil` (declared in the lazyvim module) as the nix LSP,
-- instead of letting Mason build it from source via cargo. `mason = false`
-- tells LazyVim not to manage/install nil_ls via Mason and to set it up
-- directly against the `nil` binary on PATH.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = { mason = false },
      },
    },
  },
}
