{ pkgs, ... }: {
  homebrew = {
    taps = [ ];

    brews = [
      "mdbook"
      "pre-commit"
    ];
  };
}
