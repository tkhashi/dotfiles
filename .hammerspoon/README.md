# Hammerspoon Configuration

このリポジトリはHammerspoonの設定ファイルです。構造化アーキテクチャに基づく保守性・拡張性の高い設計を採用しています。

## 🏗️ アーキテクチャ概要

### 設計原則

- **Mediator パターン**: 中央司令塔による一元管理
- **Command パターン**: `領域.動詞` 形式でのコマンド定義
- **Repository パターン**: 外部CLI(blueutil/karabiner_cli)の薄いラッパー
- **Trigger 分離**: イベント起点とビジネスロジックの分離

### ディレクトリ構成

```
~/.hammerspoon/
├─ init.lua                  # エントリーポイント：登録と起動のみ
├─ core/
│  ├─ mediator.lua           # 司令塔（register/dispatch + エラーハンドリング）
│  └─ log.lua                # ログ設定とユーティリティ
├─ commands/
│  └─ input.lua              # IME表示/Karabiner関連のコマンド
├─ triggers/
│  ├─ path.lua               # 自動リロード
│  ├─ hotkey.lua             # 手動ホットキー
│  └─ watchers/
│     ├─ usb.lua             # USB監視
│     └─ power.lua           # 復帰時処理
└─ repositories/
   ├─ shell.lua              # 汎用シェル操作
   ├─ blueutil.lua           # Bluetooth操作
   └─ karabiner.lua          # Karabiner CLI操作
```

## 🚀 機能

### IME（日本語入力）サポート
- **リアルタイム表示**: IME切替時にアラート表示（「あ」「A」）
- **メニューバー表示**: 現在のIME状態をメニューバーに表示
- **スタイル調整**: カスタマイズ可能なアラートスタイル

### Karabiner-Elements 自動プロファイル切替
- **USB接続**: Naya Create Left キーボード接続/切断を自動検知
- **Bluetooth**: Naya Create キーボードのBluetooth接続状態を監視
- **優先順位**: UHK > Naya(USB) > Naya(BT) > Laptop の順で自動選択
- **復帰時対応**: スリープ復帰・画面アンロック時に自動で状態確認・切替

### 自動リロード
- **ファイル監視**: `.lua`ファイルの変更を検知して自動リロード
- **手動リロード**: `Ctrl+Alt+Cmd+R` でいつでも手動リロード可能

## ⌨️ ホットキー

| キー | 機能 |
|------|------|
| `Ctrl+Alt+Cmd+R` | 手動リロード |
| `Ctrl+Alt+Cmd+W` | 手動プロファイル整合実行 |

## 📋 利用可能なコマンド

新しいアーキテクチャでは、全ての機能がコマンドとして登録されています：

```lua
-- IME表示
mediator.dispatch("input.ime.flash")

-- Karabinerプロファイル選択
mediator.dispatch("input.karabiner.select", { profile = "Laptop" })
mediator.dispatch("input.karabiner.select", { profile = "Naya Create" })
mediator.dispatch("input.karabiner.select", { profile = "UHK" })

-- 統合プロファイル整合（USB/BT状態から自動選択）
mediator.dispatch("input.profile.reconcile")
```

## 🔧 設定

### 依存関係

- **Karabiner-Elements**: キーボードカスタマイズ
- **blueutil**: Bluetooth状態取得 (`brew install blueutil`)

### 対象デバイス

現在設定されているキーボード：

- **Naya Create Left** (USB): vendorID=14289, productID=100
- **Naya Create** (Bluetooth): MAC アドレス e7-b6-78-48-3f-a6
- **UHK**: 追加設定が必要（`commands/input.lua`の`UHK_USB_MATCHERS`）

### カスタマイズ

新しいデバイスやコマンドを追加する場合：

1. **新しいコマンド**: `commands/` 配下に新ファイル作成
2. **新しいトリガー**: `triggers/` 配下に新ファイル作成
3. **外部CLI連携**: `repositories/` 配下に新ファイル作成
4. **登録**: `init.lua`で`require().register()`を追加

## 🛠️ 開発・デバッグ

### デバッグコマンド

```lua
-- 登録されているコマンド一覧
hs.inspect(require("core.mediator").handlers)

-- コマンド実行テスト
require("core.mediator").dispatch("input.profile.reconcile")

-- 登録済みコマンド表示
require("core.mediator").showCommands()
```

### ログ確認

各モジュールでカテゴリ別ログを出力：

- **mediator**: コマンド実行・エラー
- **usb**: USB接続/切断イベント  
- **power**: 電源復帰イベント
- **karabiner**: プロファイル切替
- **blueutil**: Bluetooth状態
- **input**: IME・プロファイル整合

### エラーハンドリング

- 全てのコマンド実行で`xpcall`による例外安全性
- エラー時は`hs.alert.show`で即座に可視化
- 外部CLI不在時は`hs.notify`で通知

## 📝 設計思想

### なぜこのアーキテクチャなのか

1. **理解しやすさ**: 起点（何が起こすか）と処理（何をするか）が追いやすい
2. **変更容易性**: トリガや外部CLIを差し替えても、コマンドの呼び出し規約は固定
3. **堅牢性**: 例外時にアラート・ログが必ず出る
4. **小さく始めて拡張可能**: 領域ごとにファイル追加でスケール

### EventBusを使わない理由

- 1人開発＋中小規模では、イベントの発行先が分散すると"糸"を見失いやすい
- 中央（Mediator）に"何を呼ぶか"を集めておく方が、**後日読み返しやすい**

## 🔄 移行履歴

このアーキテクチャは、既存のモノリシックな`init.lua`から段階的にリアーキテクティングしたものです：

- **Before**: 500行超の単一ファイル
- **After**: 機能別に分割された構造化設計
- **互換性**: 既存の全機能を維持

## 📄 ライセンス

MIT License

## 🤝 コントリビューション

1. 新機能は該当する`commands/`、`triggers/`、`repositories/`に追加
2. `init.lua`で登録を忘れずに
3. エラーハンドリングを適切に実装
4. コマンド命名規則（`領域.動詞`）に従う