{ pkgs, ... }: {
  homebrew = {
    taps = [
      "homebrew/cask"
      "homebrew/cask-drivers"
      "homebrew/cask-fonts"
      # "railwaycat/emacsmacport"
    ];

    casks = [
      "1password"
      "clickup"
      "dbeaver-community"
      "discord"
      "docker"
      "figma"
      "firefox"
      "flux"
      "font-hack-nerd-font"
      "font-hasklig"
      "font-roboto"
      "fork"
      "google-chrome"
      "google-drive"
      "google-japanese-ime"
      "httpie"
      "iterm2"
      "karabiner-elements"
      "kensingtonworks"
      "logseq"
      "multipass"
      "obsidian"
      "postman"
      "raycast"
      "readdle-spark"
      "slack"
      "spotify"
      "utm"
      "visual-studio-code"
      "workflowy"
      "zappy"
      "zoom"
      "zotero"
      # "alfred"
      # "asana"
      # "fluid"
      # "gyazo"
      # "krisp"
      # "notion"
      # "rambox"
    ];

    # extraConfig = ''
    #   brew "emacs-mac", args:["with-modules"], link: true
    # '';
  };
}
