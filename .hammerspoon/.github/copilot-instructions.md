# Copilot Instructions for Hammerspoon Refactoring

## プロジェクト概要

Hammerspoonの設定を段階的にリアーキテクティング中。ARCHITECTURE.mdで定義されたMediator + Triggers + Repositories パターンに移行する。

## 現在の状況

- **進行中**: 段階的リアーキテクティング（REFACTORING_PLAN.md参照）
- **目標**: モノリシックinit.luaから構造化アーキテクチャへの移行
- **重要**: 既存機能を壊さず段階的に実装

## アーキテクチャ原則

### 設計パターン
1. **Mediator パターン**: 中央司令塔による一元管理
2. **Command パターン**: `領域.動詞` 形式でのコマンド定義
3. **Repository パターン**: 外部CLI(blueutil/karabiner_cli)の薄いラッパー
4. **Trigger 分離**: イベント起点とビジネスロジックの分離

### 命名規則
- コマンド: `<領域>.<動詞>` (例: `input.ime.flash`, `input.profile.reconcile`)
- 引数: テーブル1個に固定 `mediator.dispatch("command", { ...payload })`
- ファイル: 機能別に分割（`commands/`, `triggers/`, `repositories/`）

### エラーハンドリング
- 失敗は必ず可視化（`hs.alert.show`）
- 例外は`xpcall`でキャッチしてログ出力
- 外部CLI不在時は`hs.notify`で通知

## 実装ガイドライン

### コード作成時
1. **既存機能を壊さない**: 新機能追加時は既存コードとの互換性を保つ
2. **段階的移行**: 一度に全てを変更せず、フェーズ毎に確認
3. **エラーハンドリング**: 全ての外部呼び出しにエラー処理を追加
4. **ログ**: 重要な状態変化は必ずログ出力

### ファイル構成ルール
```
~/.hammerspoon/
├─ init.lua                  # 登録・起動のみ（最小限）
├─ core/mediator.lua         # 司令塔
├─ commands/*.lua            # ビジネスロジック
├─ triggers/*.lua            # イベント起点
├─ repositories/*.lua        # 外部CLI操作
└─ ARCHITECTURE.md           # 設計思想（変更禁止）
```

### 移行戦略
1. **バックアップ**: init.luaは必ずバックアップを取る
2. **並行テスト**: 新旧システムを並行実行してテスト
3. **段階確認**: 各フェーズで動作確認してから次へ
4. **ロールバック準備**: 問題時は即座に戻せる準備

## 重要な外部依存

- **karabiner_cli**: `/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli`
- **blueutil**: `/opt/homebrew/bin/blueutil` or `/usr/local/bin/blueutil`
- **Hammerspoon API**: hs.usb, hs.caffeinate, hs.keycodes etc.

## 既存機能の要件

### IME表示機能
- Alert表示（0.5秒）+ メニューバー更新
- 日本語入力状態を「あ」「A」で表示
- `hs.keycodes.inputSourceChanged` で自動実行

### Karabinerプロファイル自動切替
- USB監視: Naya Create Left の接続/切断
- Bluetooth監視: Naya Create (e7-b6-78-48-3f-a6) の接続状態
- 復帰時: スリープ復帰/画面アンロック時の状態確認
- 優先順位: UHK > Naya(USB) > Naya(BT) > Laptop

### 監視・リロード機能
- ファイル監視: .luaファイル変更で自動リロード
- 手動: Ctrl+Alt+Cmd+R でリロード
- 手動テスト: Ctrl+Alt+Cmd+W で整合実行

## 禁止事項

- EventBus パターンの導入（設計方針に反する）
- 既存init.luaの完全削除（バックアップとして保持）
- 外部依存の無謀な追加
- グローバル変数の乱用

## デバッグ・トラブルシューティング

### 確認コマンド
- `hs.inspect(mediator.handlers)` : 登録コマンド一覧
- `hs.logger.new("category").d("message")` : カテゴリ別ログ
- `hs.alert.show("test")` : 表示テスト

### よくある問題
1. **コマンド未登録**: register()の呼び出し忘れ
2. **引数型不一致**: payloadがテーブルでない
3. **外部CLI不在**: パス確認とエラーハンドリング
4. **タイミング**: USB/BT監視のデバウンス設定

## 現在の実装状況

フェーズ6（テストと検証）に入っています。既存の全機能が新アーキテクチャで動作することを確認し、品質を保証する段階です。

---

*このファイルは段階的リファクタリングの指針です。ARCHITECTURE.mdと併せて参照してください。*