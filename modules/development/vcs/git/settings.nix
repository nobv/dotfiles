{
  user = {
    email = "36393714+nobv@users.noreply.github.com";
    name = "nobv";
  };

  color = {
    "ui" = "auto";
  };

  core = {
    "editor" = "vim";
    "ignorecase" = false;
  };

  ghq = {
    root = [ "~/Desk/repos" ];
  };

  push = {
    default = "current";
    autoSetupRemote = true;
  };

  init = {
    defaultBranch = "main";
  };

  url = {
    "git@github.com:" = {
      insteadOf = "https://github.com/";
    };
  };
}
