# Hammerspoon リアーキテクティング計画

## 概要

既存のモノリシックな`init.lua`をARCHITECTURE.mdに従って段階的にリアーキテクティングし、Mediator + Triggers + Repositories パターンに移行する。

## 目標アーキテクチャ

```
~/.hammerspoon/
├─ init.lua                  # 最小限：登録と起動の並びだけ
├─ core/
│  ├─ mediator.lua           # 司令塔（register/dispatch + エラーハンドリング）
│  └─ log.lua                # ログ設定（任意）
├─ commands/
│  └─ input.lua              # IME表示/Karabiner関連のコマンド
├─ triggers/
│  ├─ hotkey.lua             # ホットキー→コマンド
│  ├─ path.lua               # 自動リロード
│  └─ watchers/
│     ├─ usb.lua             # hs.usb.watcher
│     └─ power.lua           # hs.caffeinate.watcher（復帰/アンロック）
└─ repositories/
   ├─ shell.lua
   ├─ blueutil.lua
   └─ karabiner.lua
```

## 段階的実装計画

### フェーズ1: 基盤となるコア実装
**目標**: Mediatorパターンの基盤を構築

- [x] `core/mediator.lua` の実装
  - コマンド登録・ディスパッチ機能
  - エラーハンドリングとアラート表示
  - xpcallを使った例外安全性
- [x] `core/log.lua` の実装（オプション）
  - 構造化ログ設定

**完了基準**: 基本的なコマンド登録・実行・エラーハンドリングが動作する

### フェーズ2: Repositoryレイヤー実装
**目標**: 外部CLIの薄いラッパーを作成

- [x] `repositories/shell.lua`
  - 汎用シェルコマンド実行
- [x] `repositories/karabiner.lua`
  - karabiner_cli操作
  - プロファイル選択
- [x] `repositories/blueutil.lua`
  - Bluetooth状態取得
  - デバイス接続確認

**完了基準**: 各外部CLIが正常に呼び出せる

### フェーズ3: Commandsレイヤー実装
**目標**: 既存の処理ロジックをコマンド形式に変換

- [x] `commands/input.lua`
  - `input.ime.flash` : IME状態表示
  - `input.karabiner.select` : プロファイル選択
  - `input.profile.reconcile` : USB/BT状態からの自動プロファイル選択

**完了基準**: 既存のIME・Karabiner機能がコマンド経由で動作する

### フェーズ4: Triggersレイヤー実装
**目標**: イベント起点をMediatorに接続

- [x] `triggers/path.lua` : 自動リロード
- [x] `triggers/hotkey.lua` : 手動ホットキー
- [x] `triggers/watchers/usb.lua` : USB監視
- [x] `triggers/watchers/power.lua` : 復帰時処理

**完了基準**: 全てのトリガーがMediator経由でコマンドを呼び出す

### フェーズ5: init.luaの新アーキテクチャ移行
**目標**: 新しいinit.luaに完全移行

- [x] 新しい`init.lua`の実装
  - コマンド登録の列挙
  - トリガー起動の列挙
  - 初期化メッセージ
- [x] 既存機能の動作確認

**完了基準**: 新アーキテクチャで全機能が動作し、既存init.luaを置換できる

### フェーズ6: テストと検証
**目標**: 品質保証と最終調整

- [ ] 全機能のテスト
  - 自動リロード
  - IME表示
  - USB/BT監視とプロファイル切替
  - 復帰時処理
  - 手動ホットキー
- [ ] エラーハンドリングの確認
- [ ] パフォーマンスの確認
- [ ] ドキュメント更新

**完了基準**: 全ての機能が安定して動作し、エラー時の通知も正常

## コマンド命名規則

`<領域>.<動詞>` を基本形にします：

- `input.ime.flash` : IME状態をAlert/メニューバー表示
- `input.karabiner.select` : `{ profile: "Laptop" | "Naya Create" | "UHK" }`
- `input.profile.reconcile` : USB/BT状態から適切なプロファイルへ切替

## 移行戦略

1. **段階的置換**: 各フェーズで既存機能を壊さずに新しい仕組みを追加
2. **並行実行**: 新旧システムを一時的に並行実行してテスト
3. **最小限の変更**: 各フェーズで動作確認しながら進める
4. **即座の rollback**: 問題があれば即座に既存init.luaに戻せる準備

## 進捗管理

- [x] フェーズ1: 基盤となるコア実装
- [x] フェーズ2: Repositoryレイヤー実装  
- [x] フェーズ3: Commandsレイヤー実装
- [x] フェーズ4: Triggersレイヤー実装
- [x] フェーズ5: init.luaの新アーキテクチャ移行
- [ ] フェーズ6: テストと検証

## リスク管理

- **設定ファイル破損**: 既存init.luaをバックアップ保持
- **機能停止**: 各フェーズで動作確認を徹底
- **パフォーマンス劣化**: メモリ使用量とCPU使用率を監視
- **外部依存関係**: blueutil/karabiner_cliの存在確認を強化