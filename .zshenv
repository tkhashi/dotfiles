. "$HOME/.cargo/env"

# --- gh アカウント自動切替 ---
# 目的: ディレクトリ（=読み込まれる git config）に応じて gh のアカウントを自動で使い分ける。
#       `gh auth switch` のグローバル状態は変更しない（複数ターミナルでも干渉しない）。
#
# 前提:
#   - ~/.gitconfig の includeIf "gitdir:..." でディレクトリ別に config を読み込んでいる
#       ~/Documents/work/**   -> ~/.gitconfig_company（gh.user = KazuhiroTakahashiAQ）
#       ~/Documents/github/** -> ~/.gitconfig_private（gh.user = tkhashi）
#     各ファイルの [gh] セクションに `user = <GitHubアカウント名>` を書く。
#     gitdir 条件は git リポジトリ内でのみ有効。リポジトリ外や管理外ディレクトリでは
#     gh.user が空になり、従来どおり gh の active アカウントで動く。
#   - 両アカウントとも `gh auth login` 済み（`gh auth status` で確認）
#   - gh 2.40 以降（`gh auth token --user` が必要）
#   - GH_TOKEN が設定済みの場合はそれを優先し、この切替は行わない
#
# .zshenv に置く理由:
#   .zshrc は対話シェルでしか読まれない。Claude Code など非対話の `zsh -c` からも
#   この関数を効かせるため、全 zsh 起動で読まれる .zshenv に置く。
#   重い処理は書かないこと（全シェル起動のコストになる）。
#
# 管理: ~/.zshenv は dotfiles/.zshenv へのシンボリックリンク。
#   ln -s ~/Documents/github/dotfiles/.zshenv ~/.zshenv
gh() {
  local u
  if [ -z "$GH_TOKEN" ]; then u=$(git config gh.user 2>/dev/null); fi
  if [ -n "$u" ]; then
    GH_TOKEN=$(command gh auth token --user "$u") command gh "$@"
  else
    command gh "$@"
  fi
}
