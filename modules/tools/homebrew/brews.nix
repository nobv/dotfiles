{ pkgs, ... }: {
  homebrew = {
    taps = [ ];

    brews = [
      "graphviz"
      "mdbook"
      "mkcert"
      "pre-commit"
    ];
  };
}
