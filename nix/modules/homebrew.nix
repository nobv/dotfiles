{ pkgs, ... }: {
  homebrew = {
    brewPrefix = "/opt/homebrew/bin";
    enable = true;
    autoUpdate = true;
    cleanup = "zap";
    global = {
      brewfile = true;
      noLock = true;
    };

    taps = [
      "homebrew/core"
      "homebrew/cask"
      "homebrew/cask-drivers"

      # 
      # "d12frosted/emacs-plus"
    ];

    brews = [
      # # emacs-plus dependencies
      # "m4"
      # "autoconf"
      # "bdw-gc"
      # "ca-certificates"
      # "libpng"
      # "freetype"
      # "fontconfig"
      # "gdbm"
      # "gettext"
      # "libffi"
      # "mpdecimal"
      # "openssl@1.1"
      # "pcre"
      # "readline"
      # "sqlite"
      # "xz"
      # "python@3.9"
      # "glib"
      # "pkg-config"
      # "libpthread-stubs"
      # "xorgproto"
      # "libxau"
      # "libxdmcp"
      # "libxcb"
      # "libx11"
      # "libxext"
      # "libxrender"
      # "lzo"
      # "pixman"
      # "cairo"
      # "fribidi"
      # "jpeg"
      # "libtiff"
      # "gdk-pixbuf"
      # "gmp"
      # "gnu-sed"
      # "libtool"
      # "libunistring"
      # "guile"
      # "libevent"
      # "libidn2"
      # "libnghttp2"
      # "libtasn1"
      # "nettle"
      # "p11-kit"
      # "unbound"
      # "gnutls"
      # "gobject-introspection"
      # "graphite2"
      # "icu4c"
      # "harfbuzz"
      # "jansson"
      # "pango"
      # "librsvg"
      # "little-cms2"
      # "texinfo"
    ];

    casks = [
      "alfred"
      "docker"
      "flux"
      "firefox"
      "fork"
      "google-chrome"
      "google-japanese-ime"
      "iterm2"
      "kensingtonworks"
      "slack"
      "zoom"
      "discord"
      "postman"
      "spotify"
      "logseq"
      "workflowy"
    ];

    # `mas` not working on Monterrey
    masApps = {
      "Amphetamine" = 937984704;
      "Disk Diag" = 672206759;
      "Fuwari" = 1187652334;
      "Highlights" = 1498912833;
      "iThoughtsX" = 720669838;
      "Kindle" = 405399194;
      "LastPass" = 926036361;
      "Magnet" = 441258766;
      "MarginNote 3" = 1423522373;
      "Messenger" = 1480068668;
      "Notability" = 736189492;
      "Reeder" = 1529448980;
      "Slack" = 803453959;
      "Spark" = 1176895641;
      "Taskade" = 1490048917;
      "Telegram" = 747648890;
      "TextSniper" = 1528890965;
      "The Unarchiver" = 425424353;
      "Todoist" = 585829637;

    };

    extraConfig = ''
      # `brew install emacs-plus@28 --with-modern-purple-flat-icon`, `brew link emacs-plus`
      # brew "emacs-plus@28", args:["with-modern-purple-flat-icon"], link: true
    '';
  };
}
