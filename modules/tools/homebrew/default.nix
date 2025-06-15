{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.homebrew;
  
  # Brew app definitions (no cfg references to avoid circular deps)
  brewAppDefs = {
    blueutil = { package = "blueutil"; };
    graphviz = { package = "graphviz"; };
    mdbook = { package = "mdbook"; };
    mkcert = { package = "mkcert"; };
    pre-commit = { package = "pre-commit"; };
    sketchybar = { package = { name = "sketchybar"; }; tap = "FelixKratz/formulae"; };
  };

  # Cask app definitions (no cfg references to avoid circular deps)
  caskAppDefs = {
    "1password" = { package = "1password"; };
    anki = { package = "anki"; };
    appcleaner = { package = "appcleaner"; };
    arc = { package = "arc"; };
    battery = { package = "battery"; };
    beeper = { package = "beeper"; };
    blender = { package = "blender"; };
    chatgpt = { package = "chatgpt"; };
    claude = { package = "claude"; };
    cursor = { package = "cursor"; };
    dbeaver-community = { package = "dbeaver-community"; };
    deepl = { package = "deepl"; };
    deskpad = { package = "deskpad"; };
    discord = { package = "discord"; };
    docker = { package = "docker"; };
    figma = { package = "figma"; };
    firefox = { package = "firefox"; };
    flashspace = { package = "flashspace"; };
    flux = { package = "flux"; };
    fork = { package = "fork"; };
    google-chrome = { package = "google-chrome"; };
    google-drive = { package = "google-drive"; };
    google-japanese-ime = { package = "google-japanese-ime"; };
    heptabase = { package = "heptabase"; };
    httpie = { package = "httpie"; };
    istat-menus = { package = "istat-menus"; };
    jordanbaird-ice = { package = "jordanbaird-ice"; };
    karabiner-elements = { package = "karabiner-elements"; };
    leader-key = { package = "leader-key"; };
    linear-linear = { package = "linear-linear"; };
    "logi-options+" = { package = "logi-options+"; };
    logseq = { package = "logseq"; };
    microsoft-edge = { package = "microsoft-edge"; };
    miro = { package = "miro"; };
    mos = { package = "mos"; };
    multipass = { package = "multipass"; };
    notion = { package = "notion"; };
    obsidian = { package = "obsidian"; };
    poe = { package = "poe"; };
    postman = { package = "postman"; };
    readdle-spark = { package = "readdle-spark"; };
    slack = { package = "slack"; };
    spotify = { package = "spotify"; };
    typora = { package = "typora"; };
    utm = { package = "utm"; };
    wezterm = { package = "wezterm"; };
    wireshark = { package = "wireshark"; };
    zappy = { package = "zappy"; };
    zoom = { package = "zoom"; };
    zotero = { package = "zotero"; };
  };

  # MAS app definitions (no cfg references to avoid circular deps)
  masAppDefs = {
    amphetamine = { appName = "Amphetamine"; appId = 937984704; };
    daisydisk = { appName = "DaisyDisk"; appId = 411643860; };
    day-one = { appName = "Day One"; appId = 1055511498; };
    drafts = { appName = "Drafts"; appId = 1435957248; };
    fantastical = { appName = "Fantastical"; appId = 975937182; };
    kindle = { appName = "Kindle"; appId = 302584613; };
    line = { appName = "LINE"; appId = 539883307; };
    messenger = { appName = "Messenger"; appId = 1480068668; };
    perplexity = { appName = "Perplexity"; appId = 1875466942; };
    post-it = { appName = "Post-it®"; appId = 1475777828; };
    slack-mas = { appName = "Slack"; appId = 803453959; };
    streaks = { appName = "Streaks"; appId = 963034692; };
    telegram = { appName = "Telegram"; appId = 747648890; };
    textsniper = { appName = "TextSniper"; appId = 1528890965; };
    the-unarchiver = { appName = "The Unarchiver"; appId = 425424353; };
    things3 = { appName = "Things 3"; appId = 904280696; };
    wireguard = { appName = "WireGuard"; appId = 1451685025; };
    xcode = { appName = "Xcode"; appId = 497799835; };
    yoink = { appName = "Yoink"; appId = 457622435; };
    japanese-dictionary = { appName = "辞書 by 物書堂"; appId = 1380563956; };
  };
in
{
  options.modules.tools.homebrew = {
    enable = mkEnableOption "Enable homebrew module";
    
    # Auto-generate brew options from definitions
    brews = listToAttrs (mapAttrsToList (name: _: nameValuePair name (mkEnableOption "Enable ${name} brew")) brewAppDefs);
    
    # Auto-generate cask options from definitions
    casks = listToAttrs (mapAttrsToList (name: _: nameValuePair name (mkEnableOption "Enable ${name} cask")) caskAppDefs);
    
    # Auto-generate MAS app options from definitions
    masApps = listToAttrs (mapAttrsToList (name: def: nameValuePair name (mkEnableOption "Enable ${def.appName} from Mac App Store")) masAppDefs);
  };

  config = mkIf cfg.enable {
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

      # Auto-generate taps from enabled apps
      taps = unique (filter (x: x != null) (
        mapAttrsToList (name: def: if (cfg.brews.${name}.enable or false) && def ? tap then def.tap else null) brewAppDefs ++
        mapAttrsToList (name: def: if (cfg.casks.${name}.enable or false) && def ? tap then def.tap else null) caskAppDefs
      ));

      # Auto-generate brews from enabled apps
      brews = mapAttrsToList (name: def: def.package) (filterAttrs (name: def: cfg.brews.${name}.enable or false) brewAppDefs);

      # Auto-generate casks from enabled apps
      casks = mapAttrsToList (name: def: def.package) (filterAttrs (name: def: cfg.casks.${name}.enable or false) caskAppDefs);

      # Auto-generate MAS apps from enabled apps
      masApps = listToAttrs (mapAttrsToList (name: def: nameValuePair def.appName def.appId) (filterAttrs (name: def: cfg.masApps.${name}.enable or false) masAppDefs));
    };
  };
}