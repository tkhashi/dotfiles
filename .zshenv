. "$HOME/.cargo/env"

# git の gh.user に応じて gh のアカウントを自動選択（GH_TOKEN 明示時はそれを優先）
gh() {
  local u
  if [ -z "$GH_TOKEN" ]; then u=$(git config gh.user 2>/dev/null); fi
  if [ -n "$u" ]; then
    GH_TOKEN=$(command gh auth token --user "$u") command gh "$@"
  else
    command gh "$@"
  fi
}
