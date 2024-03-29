{
  add-untracked = "ls-files --others --exclude-standard | xargs git add";
  dv = "difftool --tool=vimdiff --no-prompt";
  lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
  lga = "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
  modified = "ls-files --modified";
  untracked = "ls-files --others --exclude-standard";
}
