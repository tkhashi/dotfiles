# CLAUDE.md

このディレクトリで作業する際のガイド。

## このプロジェクトについて

Hammerspoonの設定。Mediatorパターンを中心にした構造化アーキテクチャを採用している。詳細は `ARCHITECTURE.md` を参照。

- `core/`: Mediator・ログなど基盤
- `commands/`: ビジネスロジック(`領域.動詞` 形式で登録)
- `triggers/`: イベント起点(ホットキー・ファイル監視・USB/電源監視など)。Mediatorへのdispatchのみ行う
- `repositories/`: 外部CLI(karabiner_cli, blueutil等)の薄いラッパー

## 設計判断・バグ修正の記録(ADR)

`docs/adr/` に Architecture Decision Record を残す。

**以下に該当する変更を行った場合は、必ず ADR を追加すること:**

- バグ修正のうち、原因調査を要したもの(単純なtypo修正等は対象外)
- 既存の挙動やトレードオフを伴う設計判断の変更
- 「なぜそうしたか」を後から追えるようにしておく価値がある変更

作成手順・テンプレート・命名規則は `docs/adr/README.md` を参照。新規ADR作成後は同README内の一覧にもリンクを追加する。

**バグ修正のADRは、ユーザーによる実機での動作確認が完了してから記載する。** 修正直後・未検証の段階では書かない(詳細は `docs/adr/README.md` の「記載タイミング」参照)。

単純な設定値変更・typo修正・フォーマット調整のみの場合はADR不要。
