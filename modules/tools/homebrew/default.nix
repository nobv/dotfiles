{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.homebrew;
  
  # Brew definitions with options and packages
  brewApps = [
    { name = "blueutil"; option = cfg.brews.blueutil; package = "blueutil"; }
    { name = "graphviz"; option = cfg.brews.graphviz; package = "graphviz"; }
    { name = "mdbook"; option = cfg.brews.mdbook; package = "mdbook"; }
    { name = "mkcert"; option = cfg.brews.mkcert; package = "mkcert"; }
    { name = "pre-commit"; option = cfg.brews.pre-commit; package = "pre-commit"; }
    { name = "sketchybar"; option = cfg.brews.sketchybar; package = { name = "sketchybar"; }; tap = "FelixKratz/formulae"; }
  ];

  # Cask definitions with options and packages
  caskApps = [
    { name = "1password"; option = cfg.casks."1password"; package = "1password"; }
    { name = "anki"; option = cfg.casks.anki; package = "anki"; }
    { name = "appcleaner"; option = cfg.casks.appcleaner; package = "appcleaner"; }
    { name = "arc"; option = cfg.casks.arc; package = "arc"; }
    { name = "battery"; option = cfg.casks.battery; package = "battery"; }
    { name = "beeper"; option = cfg.casks.beeper; package = "beeper"; }
    { name = "blender"; option = cfg.casks.blender; package = "blender"; }
    { name = "chatgpt"; option = cfg.casks.chatgpt; package = "chatgpt"; }
    { name = "claude"; option = cfg.casks.claude; package = "claude"; }
    { name = "cursor"; option = cfg.casks.cursor; package = "cursor"; }
    { name = "dbeaver-community"; option = cfg.casks.dbeaver-community; package = "dbeaver-community"; }
    { name = "deepl"; option = cfg.casks.deepl; package = "deepl"; }
    { name = "deskpad"; option = cfg.casks.deskpad; package = "deskpad"; }
    { name = "discord"; option = cfg.casks.discord; package = "discord"; }
    { name = "docker"; option = cfg.casks.docker; package = "docker"; }
    { name = "figma"; option = cfg.casks.figma; package = "figma"; }
    { name = "firefox"; option = cfg.casks.firefox; package = "firefox"; }
    { name = "flashspace"; option = cfg.casks.flashspace; package = "flashspace"; }
    { name = "flux"; option = cfg.casks.flux; package = "flux"; }
    { name = "fork"; option = cfg.casks.fork; package = "fork"; }
    { name = "google-chrome"; option = cfg.casks.google-chrome; package = "google-chrome"; }
    { name = "google-drive"; option = cfg.casks.google-drive; package = "google-drive"; }
    { name = "google-japanese-ime"; option = cfg.casks.google-japanese-ime; package = "google-japanese-ime"; }
    { name = "heptabase"; option = cfg.casks.heptabase; package = "heptabase"; }
    { name = "httpie"; option = cfg.casks.httpie; package = "httpie"; }
    { name = "istat-menus"; option = cfg.casks.istat-menus; package = "istat-menus"; }
    { name = "jordanbaird-ice"; option = cfg.casks.jordanbaird-ice; package = "jordanbaird-ice"; }
    { name = "karabiner-elements"; option = cfg.casks.karabiner-elements; package = "karabiner-elements"; }
    { name = "leader-key"; option = cfg.casks.leader-key; package = "leader-key"; }
    { name = "linear-linear"; option = cfg.casks.linear-linear; package = "linear-linear"; }
    { name = "logi-options+"; option = cfg.casks."logi-options+"; package = "logi-options+"; }
    { name = "logseq"; option = cfg.casks.logseq; package = "logseq"; }
    { name = "microsoft-edge"; option = cfg.casks.microsoft-edge; package = "microsoft-edge"; }
    { name = "miro"; option = cfg.casks.miro; package = "miro"; }
    { name = "mos"; option = cfg.casks.mos; package = "mos"; }
    { name = "multipass"; option = cfg.casks.multipass; package = "multipass"; }
    { name = "notion"; option = cfg.casks.notion; package = "notion"; }
    { name = "obsidian"; option = cfg.casks.obsidian; package = "obsidian"; }
    { name = "poe"; option = cfg.casks.poe; package = "poe"; }
    { name = "postman"; option = cfg.casks.postman; package = "postman"; }
    { name = "readdle-spark"; option = cfg.casks.readdle-spark; package = "readdle-spark"; }
    { name = "slack"; option = cfg.casks.slack; package = "slack"; }
    { name = "spotify"; option = cfg.casks.spotify; package = "spotify"; }
    { name = "typora"; option = cfg.casks.typora; package = "typora"; }
    { name = "utm"; option = cfg.casks.utm; package = "utm"; }
    { name = "wezterm"; option = cfg.casks.wezterm; package = "wezterm"; }
    { name = "wireshark"; option = cfg.casks.wireshark; package = "wireshark"; }
    { name = "zappy"; option = cfg.casks.zappy; package = "zappy"; }
    { name = "zoom"; option = cfg.casks.zoom; package = "zoom"; }
    { name = "zotero"; option = cfg.casks.zotero; package = "zotero"; }
  ];

  # MAS App definitions with options and IDs
  masApps = [
    { name = "amphetamine"; option = cfg.masApps.amphetamine; appName = "Amphetamine"; appId = 937984704; }
    { name = "daisydisk"; option = cfg.masApps.daisydisk; appName = "DaisyDisk"; appId = 411643860; }
    { name = "day-one"; option = cfg.masApps.day-one; appName = "Day One"; appId = 1055511498; }
    { name = "drafts"; option = cfg.masApps.drafts; appName = "Drafts"; appId = 1435957248; }
    { name = "fantastical"; option = cfg.masApps.fantastical; appName = "Fantastical"; appId = 975937182; }
    { name = "kindle"; option = cfg.masApps.kindle; appName = "Kindle"; appId = 302584613; }
    { name = "line"; option = cfg.masApps.line; appName = "LINE"; appId = 539883307; }
    { name = "messenger"; option = cfg.masApps.messenger; appName = "Messenger"; appId = 1480068668; }
    { name = "perplexity"; option = cfg.masApps.perplexity; appName = "Perplexity"; appId = 1875466942; }
    { name = "post-it"; option = cfg.masApps.post-it; appName = "Post-it®"; appId = 1475777828; }
    { name = "slack-mas"; option = cfg.masApps.slack-mas; appName = "Slack"; appId = 803453959; }
    { name = "streaks"; option = cfg.masApps.streaks; appName = "Streaks"; appId = 963034692; }
    { name = "telegram"; option = cfg.masApps.telegram; appName = "Telegram"; appId = 747648890; }
    { name = "textsniper"; option = cfg.masApps.textsniper; appName = "TextSniper"; appId = 1528890965; }
    { name = "the-unarchiver"; option = cfg.masApps.the-unarchiver; appName = "The Unarchiver"; appId = 425424353; }
    { name = "things3"; option = cfg.masApps.things3; appName = "Things 3"; appId = 904280696; }
    { name = "wireguard"; option = cfg.masApps.wireguard; appName = "WireGuard"; appId = 1451685025; }
    { name = "xcode"; option = cfg.masApps.xcode; appName = "Xcode"; appId = 497799835; }
    { name = "yoink"; option = cfg.masApps.yoink; appName = "Yoink"; appId = 457622435; }
    { name = "japanese-dictionary"; option = cfg.masApps.japanese-dictionary; appName = "辞書 by 物書堂"; appId = 1380563956; }
  ];
in
{
  options.modules.tools.homebrew = {
    enable = mkEnableOption "Enable homebrew module";
    
    # Auto-generate brew options
    brews = listToAttrs (map (app: nameValuePair app.name (mkEnableOption "Enable ${app.name} brew")) brewApps);
    
    # Auto-generate cask options  
    casks = listToAttrs (map (app: nameValuePair app.name (mkEnableOption "Enable ${app.name}")) caskApps);
    
    # Auto-generate MAS app options
    masApps = listToAttrs (map (app: nameValuePair app.name (mkEnableOption "Enable ${app.appName}")) masApps);
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
      taps = unique (filter (x: x != null) (map (app: if app.option && app ? tap then app.tap else null) (brewApps ++ caskApps)));

      # Auto-generate brews from enabled apps
      brews = map (app: app.package) (filter (app: app.option) brewApps);

      # Auto-generate casks from enabled apps
      casks = map (app: app.package) (filter (app: app.option) caskApps);

      # Auto-generate MAS apps from enabled apps
      masApps = listToAttrs (map (app: nameValuePair app.appName app.appId) (filter (app: app.option) masApps));
    };
  };
}
