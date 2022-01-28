{ pkgs, ... }: {
  homebrew = {
    taps = [
      "homebrew/core"

      "d12frosted/emacs-plus"
    ];

    brews = [
      # emacs-plus dependencies
      "m4"
      "autoconf"
      "bdw-gc"
      "ca-certificates"
      "libpng"
      "freetype"
      "fontconfig"
      "gdbm"
      "gettext"
      "libffi"
      "mpdecimal"
      "openssl@1.1"
      "pcre"
      "readline"
      "sqlite"
      "xz"
      "python@3.9"
      "glib"
      "pkg-config"
      "libpthread-stubs"
      "xorgproto"
      "libxau"
      "libxdmcp"
      "libxcb"
      "libx11"
      "libxext"
      "libxrender"
      "lzo"
      "pixman"
      "cairo"
      "fribidi"
      "jpeg"
      "libtiff"
      "gdk-pixbuf"
      "gmp"
      "gnu-sed"
      "libtool"
      "libunistring"
      "guile"
      "libevent"
      "libidn2"
      "libnghttp2"
      "libtasn1"
      "nettle"
      "p11-kit"
      "unbound"
      "gnutls"
      "gobject-introspection"
      "graphite2"
      "icu4c"
      "harfbuzz"
      "jansson"
      "pango"
      "librsvg"
      "little-cms2"
      "texinfo"
    ];

    extraConfig = ''
      # `brew install emacs-plus@28 --with-modern-purple-flat-icon`, `brew link emacs-plus`
      brew "emacs-plus@28", args:["with-modern-purple-flat-icon"], link: true
    '';
  };
}
