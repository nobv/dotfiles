{
  # Application
  chrome = "open -a Google Chrome";

  # bat
  ## use bat instead of cat
  cat = "bat";

  # Change directory
  ".." = "cd ..";
  "..." = "cd ../..";
  "...." = "cd ../../..";
  "....." = "cd ../../../..";
  "......" = "cd ../../../../..";

  # logseq = "cd ~/Library/Mobile\\ Documents//iCloud~com~logseq~logseq/Documents/logseq";
  logseq = "cd ~/Google\\ Drive/My\\ Drive/me/notes/logseq/log";
  dots = "cd ~/.dotfiles";

  # cp
  cp = "cp -i";

  # docker
  d = "docker";

  dprune = "docker system prune --all --volumes --force && docker builder prune --all --force";

  # docker compose
  dc = "docker compose";
  dcps = "dc ps";
  dcdown = "dc down";

  # exa
  ## use exa instead of ls
  l = "exa --git --icons -a";
  ll = "exa --long --header --git --icons -a";
  ls = "exa";

  # exec
  reload = "exec $SHELL -l";

  # kubernetes
  k = "kubectl";
  kx = "kubectx";
  kn = "kubens";

  # nix
  nix-repl = "nix repl '<nixpkgs>'";

  # mv
  mv = "mv -i";

  # peco
  g = "REPO=$(ghq list | sort -u | peco);for GHQ_ROOT in $(ghq root -all);do [ -d $GHQ_ROOT/$REPO ] && cd $GHQ_ROOT/$REPO;done";
  app = ''
    open "$(ls ~/Applications | peco | awk '{print $3}')"
  '';

  # procs
  ## use procs instead of ps
  ps = "procs";

  # rm
  rm = "rm -i";
  rmrf = "rm -rf";

  # terraform
  tfa = "terraform apply";
  tfi = "teffaform init";
  tfp = "terraform plan";

  # terragrunt
  tg = "terragrunt";
}

