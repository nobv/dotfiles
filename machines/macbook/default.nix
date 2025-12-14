{ config
, pkgs
, lib
, ...
}:

{
  imports = [
    ../darwin.nix # Common Darwin configuration
    ../home.nix # Common Home Manager configuration
    ./overrides.nix # MacBook-specific overrides
  ];

  # Enable modules using actual directory structure paths
  modules = {
    ai = {
      chatgpt.enable = true;
      claude.enable = true;
      gemini.enable = true;
      perplexity.enable = true;
      poe.enable = false;
    };

    browsers = {
      arc.enable = true;
      chrome.enable = true;
      firefox.enable = true;
      microsoft-edge.enable = true;
    };

    checkers.enable = true;

    communication = {
      beeper.enable = false;
      deepl.enable = true;
      discord.enable = true;
      line.enable = true;
      messenger.enable = true;
      readdle-spark.enable = true;
      slack.enable = true;
      telegram.enable = true;
      zoom.enable = true;
    };

    design = {
      blender.enable = true;
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
        terraform.enable = false;
      };

      vcs = {
        fork.enable = true;
        git.enable = true;
        github.enable = true;
        pre-commit.enable = true;
      };
    };

    editors = {
      cursor.enable = false;
      emacs.enable = false;
      jetbrains.enable = true;
      neovim.enable = true;
      typora.enable = true;
      vim.enable = false;
      vscode.enable = true;
      xcode.enable = true;
    };

    # Programming languages
    languages = {
      c.enable = false;
      deno.enable = true;
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

    media = {
      ffmpeg.enable = false;
      graphviz.enable = false;
      imagemagic.enable = false;
      yt-dlp.enable = true;
    };

    productivity = {
      #      amphetamine.enable = false;
      affine.enable = true;
      anki.enable = true;
      capacities.enable = true;
      clickup.enable = true;
      daisydisk.enable = true;
      day-one.enable = false;
      drafts.enable = true;
      fantastical.enable = false;
      heptabase.enable = true;
      japanese-dictionary.enable = true;
      kindle.enable = true;
      linear-linear.enable = true;
      logseq.enable = true;
      mdbook.enable = false;
      miro.enable = true;
      notion.enable = false;
      obsidian.enable = true;
      post-it.enable = true;
      raycast.enable = true;
      streaks.enable = false;
      things3.enable = true;
      zotero.enable = true;
    };

    security = {
      "1password".enable = true;
      trivy.enable = true;
      wireguard.enable = true;
      wireshark.enable = true;
    };

    # System tools
    system = {
      aerospace.enable = true;
      blueutil.enable = true;
      flashspace.enable = true;
      fonts.enable = true;
      homebrew.enable = true;
      multipass.enable = true;
      sketchybar.enable = true;
      utm.enable = true;
    };

    # Terminal configuration
    terminal = {
      iTerm2.enable = false;
      lf.enable = true;
      starship.enable = true;
      tmux.enable = true;
      wezterm.enable = true;
      zsh.enable = true;
    };

    # Utilities
    utilities = {
      appcleaner.enable = true;
      battery.enable = true;
      deskpad.enable = true;
      flux.enable = true;
      google-drive.enable = true;
      google-japanese-ime.enable = true;
      istat-menus.enable = true;
      jordanbaird-ice.enable = true;
      karabiner-elements.enable = true;
      leader-key.enable = false;
      logi-options-plus.enable = true;
      meetingbar.enable = true;
      mos.enable = true;
      spotify.enable = true;
      textsniper.enable = true;
      the-unarchiver.enable = true;
      yoink.enable = true;
      zappy.enable = true;
    };
  };
}
