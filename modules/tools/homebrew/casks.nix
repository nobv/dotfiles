{ pkgs, ... }: {
  homebrew = {
    taps = [
      "homebrew/cask"
      "homebrew/cask-drivers"
      "homebrew/cask-fonts"
    ];
    casks = [
      "1password"
      "asana"
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
      "iterm2"
      "karabiner-elements"
      "kensingtonworks"
      "krisp"
      "logseq"
      "notion"
      "obsidian"
      "postman"
      "rambox"
      "raycast"
      "slack"
      "spotify"
      "visual-studio-code"
      "workflowy"
      "zappy"
      "zoom"
      # "alfred"
      # "fluid"
      # "gyazo"
    ];

  };
}
