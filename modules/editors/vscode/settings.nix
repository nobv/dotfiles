{
  # https://code.visualstudio.com/docs/getstarted/settings

  # TextEditor
  "editor.renderWhitespace" = "all";

  # Font
  "editor.fontSize" = 14;
  "editor.fontFamily" = "Hasklig, Menlo, Monaco, 'Courier New', monospace";
  "editor.fontLigatures" = true;

  # Formatting
  "editor.formatOnSave" = true;

  # Minimap
  "editor.minimap.enabled" = false;

  # Suggestions (https://code.visualstudio.com/docs/editor/intellisense)
  "editor.suggestSelection" = "recentlyUsedByPrefix";
  "editor.acceptSuggestionOnEnter" = "off";
  "editor.suggest.localityBonus" = true;

  # Files
  "files.autoSave" = "afterDelay";
  "files.insertFinalNewline" = true;

  # Workbench
  # Appearance
  "workbench.colorTheme" = "Spacemacs - dark";

  # Features
  # Explorer
  "explorer.confirmDragAndDrop" = false;
  "explorer.confirmDelete" = false;

  # Remote Containers
  "remote.localPortHost" = "allInterfaces";

  # Extensions
  # Vim
  "vim.easymotion" = true;
  "vim.useSystemClipboard" = true;
  "vim.normalModeKeyBindingsNonRecursive" = [
    {
      "before" = [
        "<space>"
      ];
      "commands" = [
        "vspacecode.space"
      ];
    }

    {
      "before" = [
        ","
      ];
      "commands" = [
        "vspacecode.space"
        {
          "command" = "whichkey.triggerKey";
          "args" = "m";
        }
      ];
    }
  ];

  # NixIDE
  "nix.enableLanguageServer" = true;

  # Remote Containers
  "remote.containers.dockerComposePath" = "docker compose";

}
