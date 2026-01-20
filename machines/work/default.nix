{ config
, pkgs
, lib
, ...
}:

{
  imports = [
    ../darwin.nix # Common Darwin configuration
    ../home.nix # Common Home Manager configuration
    ./overrides.nix # Work machine-specific overrides
  ];

  # Enable modules using actual directory structure paths
  modules = {
    ai = {
      chatgpt.enable = false;
      claude.enable = false;
      gemini.enable = true;
      perplexity.enable = false;
    };

    browsers = {
      arc.enable = false;
      chrome.enable = true;
      firefox.enable = true;
      microsoft-edge.enable = false;
    };

    checkers.enable = true;

    design = {
      figma.enable = true;
    };

    # Development tools
    development = {
      build = {
        aqua.enable = true;
        direnv.enable = true;
        go-task.enable = true;
        make.enable = false;
      };
      cli-tools = {
        bat.enable = true;
        eza.enable = true;
        fd.enable = true;
        fzf.enable = true;
        gnused.enable = true;
        jq.enable = true;
        navi.enable = true;
        parallel.enable = true;
        peco.enable = true;
        procs.enable = true;
        ripgrep.enable = true;
        tree.enable = true;
      };
      data-and-protocol = {
        dbeaver-community.enable = true;
        httpie.enable = false;
        k6.enable = true;
        mkcert.enable = true;
        pgformatter.enable = true;
        postman.enable = false;
      };

      infrastructure = {
        aws.enable = false;
        docker.enable = true;
        gcp.enable = true;
        kubernetes.enable = true;
        sops.enable = true;
        terraform.enable = true;
      };

      vcs = {
        fork.enable = true;
        git.enable = true;
        github.enable = true;
        pre-commit.enable = true;
      };
    };

    editors = {
      jetbrains.enable = true;
      neovim.enable = true;
      typora.enable = true;
      vscode.enable = true;
    };

    # Programming languages
    languages = {
      c.enable = false;
      deno.enable = false;
      dhall.enable = false;
      go.enable = true;
      haskell.enable = false;
      lua.enable = true;
      nodejs.enable = true;
      nix.enable = true;
      protobuf.enable = true;
      purescript.enable = false;
      python.enable = true;
      rust.enable = true;
      shellscript.enable = true;
    };

    productivity = {
      capacities.enable = true;
      heptabase.enable = true;
      mdbook.enable = false;
      obsidian.enable = true;
      raycast.enable = true;
      zotero.enable = true;
    };

    security = {
      "1password".enable = true;
      trivy.enable = true;
    };

    # System tools
    system = {
      aerospace.enable = true;
      flashspace.enable = true;
      fonts.enable = true;
      homebrew.enable = true;
      multipass.enable = true;
    };

    # Terminal configuration
    terminal = {
      lf.enable = true;
      starship.enable = true;
      tmux.enable = true;
      wezterm.enable = true;
      zsh.enable = true;
      iTerm2.enable = false;
      ghostty.enable = true;
    };

    # Utilities
    utilities = {
      battery.enable = true;
      deskpad.enable = true;
      flux.enable = true;
      google-japanese-ime.enable = true;
      jordanbaird-ice.enable = true;
      karabiner-elements.enable = true;
      logi-options-plus.enable = true;
      meetingbar.enable = true;
    };
  };
}
