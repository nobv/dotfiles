-- Use the Nix-provided `nil` (declared in the lazyvim module) as the nix LSP,
-- instead of letting Mason build it from source via cargo. `mason = false`
-- tells LazyVim not to manage/install nil_ls via Mason and to set it up
-- directly against the `nil` binary on PATH.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = {
          mason = false,
          -- Without this, nil prompts "Some flake inputs are not
          -- available. Fetch them now?" on every file open inside a flake
          -- (e.g. this repo) whose inputs aren't in the local Nix store.
          -- autoArchive runs `nix flake archive` for us instead of asking.
          settings = {
            ["nil"] = {
              nix = {
                flake = {
                  autoArchive = true,
                },
              },
            },
          },
        },
      },
    },
  },
}
