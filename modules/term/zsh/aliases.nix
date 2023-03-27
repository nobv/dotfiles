{

  # Applications {{{
  chrome = "open -a Google Chrome";
  #  }}}

  # Alternatives {{{
  ## bat (instead of cat)
  cat = "bat";

  ## procs (instead of ps)
  ps = "procs";

  ## exa (instead of ls)
  l = "exa --git --icons -a";
  ll = "exa --long --header --git --icons -a";
  ls = "exa";

  ## }}}

  # Shortcusts {{{

  logseq = "cd ~/src/src/github.com/nobv/logs";
  dots = "cd ~/.dotfiles";
  ide = ". ~/.dotfiles/bin/ide.sh";

  ## cp
  cp = "cp -i";

  ## exec
  reload = "exec $SHELL -l";

  ## mv
  mv = "mv -i";

  ## rm
  rm = "rm -i";
  rmrf = "rm -rf";

  ##  docker {{{
  d = "docker";
  dprune = "docker system prune --all --volumes --force && docker builder prune --all --force";
  ## }}}

  ##  kubernetes {{{
  k = "kubectl";
  kx = "kubectx";
  kn = "kubens";
  ## }}}


  ##  docker compose {{{
  dc = "docker compose";
  dcps = "dc ps";
  dcdown = "dc down";
  ## }}}

  # terraform {{{
  tfa = "terraform apply";
  tfi = "teffaform init";
  tfp = "terraform plan";
  ## }}}

  # terragrunt {{{
  tg = "terragrunt";
  ## }}}
  ## }}}

  # Change directory {{{
  ".." = "cd ..";
  "..." = "cd ../..";
  "...." = "cd ../../..";
  "....." = "cd ../../../..";
  "......" = "cd ../../../../..";
  # }}}

  # peco {{{
  g = "REPO=$(ghq list | sort -u | peco);for GHQ_ROOT in $(ghq root -all);do [ -d $GHQ_ROOT/$REPO ] && cd $GHQ_ROOT/$REPO;done";
  app = ''
    open "$(ls ~/Applications | peco | awk '{print $3}')"
  '';
  # }}}

  # Nix {{{

  ## home-manager
  reloadvim = "home-manager switch && vim";

  ##  nix {{{
  nix-repl = "nix repl '<nixpkgs>'";
  ## }}}

  # }}}

}

# vim: set foldmethod=marker :
