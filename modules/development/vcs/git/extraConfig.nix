{
  color = {
    "ui" = "auto";
  };

  core = {
    "editor" = "vim";
    "ignorecase" = false;
  };

  ghq = {
    root = [ "~/src" ];
  };

  push = {
    default = "current";
    autoSetupRemote = true;
  };

  init = {
    defaultBranch = "main";
  };
}
