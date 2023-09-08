{ pkgs, ... }: {
  imports = [
    ./brews.nix
    ./casks.nix
    ./mas.nix
  ];

  homebrew = {
    brewPrefix = "/opt/homebrew/bin";
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    global = {
      brewfile = true;
      lockfiles = true;
    };

  };
}
