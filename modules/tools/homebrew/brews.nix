{ pkgs, ... }: {
  homebrew = {
    taps = [
      "FelixKratz/formulae"
    ];

    brews = [
      "blueutil"
      "graphviz"
      "mdbook"
      "mkcert"
      "pre-commit"
      {
        name = "sketchybar";
        # start_service = true;
      }
    ];
  };
}
