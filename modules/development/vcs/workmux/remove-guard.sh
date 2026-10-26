# Refuses `workmux remove` while the worktree still holds something that
# exists nowhere else. Runs as a pre_remove hook; a non-zero exit aborts the
# removal. Set WORKMUX_REMOVE_GUARD_SKIP=1 to remove anyway.

if [[ "${WORKMUX_REMOVE_GUARD_SKIP:-}" == 1 ]]; then
  exit 0
fi

cd "${WM_WORKTREE_PATH:-$PWD}"
problems=()
indent() { sed "s/^/    /"; }

# tmp/ is gitignored, so it never shows as dirty, yet it goes with the worktree.
if [[ -d tmp ]] && [[ -n "$(find tmp -type f -print -quit)" ]]; then
  msg="tmp/ has files that would be deleted with the worktree"
  common=$(git rev-parse --path-format=absolute --git-common-dir)
  # den keeps per-desk material beside the desk's repos.
  if [[ "$common" =~ ^"$HOME"/Den/([^/]+)/repos/ ]]; then
    msg+=" (move them to $HOME/Den/${BASH_REMATCH[1]}/tickets/)"
  fi
  problems+=("$msg:"$'\n'"$(find tmp -type f | indent)")
fi

status=$(git status --porcelain)
if [[ -n "$status" ]]; then
  problems+=("uncommitted changes:"$'\n'"$(indent <<<"$status")")
fi

branch=$(git branch --show-current)

unpushed=$(git rev-list --count HEAD --not --remotes)
if ((unpushed > 0)); then
  # A squash-merged branch keeps local-only commits once its remote branch is
  # deleted, so a merged PR counts as pushed.
  merged=0
  if [[ -n "$branch" ]]; then
    merged=$(gh pr list --head "$branch" --state merged --json number --jq length 2>/dev/null || echo 0)
  fi
  if ((merged == 0)); then
    problems+=("$unpushed commit(s) not on any remote and no merged PR for '${branch:-HEAD}'")
  fi
fi

if [[ -n "$branch" ]]; then
  stashes=$(git stash list --format='%gd %gs' | grep -F -e "WIP on $branch:" -e "On $branch:" || true)
  if [[ -n "$stashes" ]]; then
    problems+=("stash entries from '$branch':"$'\n'"$(indent <<<"$stashes")")
  fi
fi

if ((${#problems[@]} == 0)); then
  exit 0
fi

{
  echo "workmux remove refused for $PWD:"
  for p in "${problems[@]}"; do
    echo "  - $p"
  done
  echo "Resolve these, or rerun with WORKMUX_REMOVE_GUARD_SKIP=1."
} >&2
exit 1
