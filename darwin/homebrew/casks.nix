{ pkgs, ... }: {
  homebrew = {
    taps = [
      "homebrew/cask"
      "homebrew/cask-drivers"
      "homebrew/cask-fonts"
    ];
    casks = [
      "alfred"
      "discord"
      "docker"
      "firefox"
      "flux"
      "font-hasklig"
      "fork"
      "google-chrome"
      "google-japanese-ime"
      "iterm2"
      "kensingtonworks"
      "logseq"
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
