{ pkgs, ... }: {
  homebrew = {
    taps = [
      "homebrew/cask"
      "homebrew/cask-drivers"
      "homebrew/cask-fonts"
    ];
    casks = [
      "alfred"
      "asana"
      "discord"
      "docker"
      "figma"
      "firefox"
      "flux"
      "font-hasklig"
      "font-hack-nerd-font"
      "font-roboto"
      "fork"
      "google-chrome"
      "google-drive"
      "google-japanese-ime"
      # "gyazo"
      "iterm2"
      "kensingtonworks"
      "logseq"
      "notion"
      "postman"
      "raycast"
      "slack"
      "spotify"
      "visual-studio-code"
      "workflowy"
      "zappy"
      "zoom"
      # "fluid"
    ];

  };
}

