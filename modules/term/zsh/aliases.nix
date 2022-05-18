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
  logseq = "cd ~/Library/Mobile\\ Documents//iCloud~com~logseq~logseq/Documents/logseq";

  # cp
  cp = "cp -i";

  # docker
  dc = "docker compose";

  # exa
  ## use exa instead of ls
  l = "exa --git --icons -a";
  ll = "exa --long --header --git --icons -a";
  ls = "exa";

  # exec
  reload = "exec $SHELL -l";

  # kubernetes
  k = "kubectl";

  # nix
  nix-repl = "nix repl '<nixpkgs>'";

  # mv
  mv = "mv -i";

  # peco
  g = "REPO=$(ghq list | sort -u | peco);for GHQ_ROOT in $(ghq root -all);do [ -d $GHQ_ROOT/$REPO ] && cd $GHQ_ROOT/$REPO;done";

  # procs
  ## use procs instead of ps
  ps = "procs";

  # rm
  rm = "rm -i";
  rmrf = "rm -rf";

  # gsed
  # use gsed instead of sed
  sed = "gsed";

  # terraform
  tfa = "terraform apply";
  tfi = "teffaform init";
  tfp = "terraform plan";

  # terragrunt
  tg = "terragrunt";
}
