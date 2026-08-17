{
  config,
  pkgs,
  lib,
  ...
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
      apm.enable = true;
      chatgpt.enable = false;
      claude.enable = true;
      claude-code = {
        enable = true;
        # Machine-local settings.json (git-ignored, edited live by Claude Code).
        # Seeded from machines/work/claude-code/settings.json.example.
        settingsSource = "machines/work/claude-code/settings.json";
      };
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
        just.enable = true;
        make.enable = false;
      };
      cli-tools = {
        bat.enable = true;
        eza.enable = true;
        fd.enable = true;
        fzf.enable = true;
        gnused.enable = true;
        herdr.enable = true;
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
        gh-dash.enable = true;
        pre-commit.enable = true;
        difit.enable = true;
        workmux = {
          enable = true;
          sandbox = {
            enable = false;
            cpus = 4;
            memory = "8GiB";
          };
        };
      };
    };

    editors = {
      jetbrains.enable = false;
      neovim = {
        enable = true;
        lazyvim.enable = true;
      };
      typora.enable = true;
      vscode.enable = false;
      zed.enable = true;
    };

    # Programming languages
    languages = {
      bun.enable = true;
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
      capacities.enable = false;
      heptabase.enable = false;
      linear-linear.enable = true;
      mdbook.enable = false;
      obsidian.enable = false;
      raycast.enable = true;
      todoist.enable = true;
      zotero.enable = true;
    };

    security = {
      "1password" = {
        enable = true;
        sshAgent = {
          enable = true;
          keys = [ { item = "GitHub (work)"; } ];
        };
        gitSigning = {
          enable = true;
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILvaDGyNYvnvYfjQJ5adS/wL0eYDZNJdJNaEuPWgkVVC";
        };
      };
      "1password-cli" = {
        enable = true;
        shellPlugins.enable = true;
      };
      ssh.enable = true;
      trivy.enable = true;
    };

    # System tools
    system = {
      aerospace.enable = true;
      den.enable = true;
      flashspace.enable = true;
      fonts.enable = true;
      homebrew.enable = true;
      lima.enable = true;
      multipass.enable = true;
    };

    # Terminal configuration
    terminal = {
      cmux.enable = true;
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
      alt-tab.enable = true;
      battery.enable = true;
      cleanshot.enable = true;
      deskpad.enable = true;
      flux.enable = true;
      google-japanese-ime.enable = true;
      karabiner-elements.enable = true;
      logi-options-plus.enable = true;
      meetingbar.enable = true;
      thaw.enable = true;
      typeless.enable = true;
    };
  };
}
