{ pkgs, ... }: {
  homebrew = {
    taps = [
      "homebrew/core"
    ];

    brews = [
      "tidy-html5"
    ];
  };
}
