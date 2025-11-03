# Hammerspoon アーキテクチャ設計

## 設計原則

このHammerspoon設定は、保守性・拡張性・理解しやすさを重視した構造化アーキテクチャを採用しています。

### 基本パターン

1. **Mediator パターン**: 中央司令塔による一元管理
2. **Command パターン**: `領域.動詞` 形式でのコマンド定義
3. **Repository パターン**: 外部CLI(blueutil/karabiner_cli)の薄いラッパー
4. **Trigger 分離**: イベント起点とビジネスロジックの分離

### 核となる設計思想

- **理解しやすさ**: 起点（何が起こすか）と処理（何をするか）が追いやすい
- **変更容易性**: トリガや外部CLIを差し替えても、コマンドの呼び出し規約は固定
- **堅牢性**: 例外時にアラート・ログが必ず出る
- **小さく始めて拡張可能**: 領域ごとにファイル追加でスケール

## アーキテクチャ図

```
Trigger (Hotkey/Watcher/Timer)
  └─ mediator.dispatch("領域.動詞", { ...payload })
        └─ Command（登録済みハンドラ）
              └─ Repository（必要に応じて外部CLI実行）
```

## レイヤー構成

### 1. Core レイヤー (`core/`)

**mediator.lua**: 司令塔
- コマンド登録: `mediator.register(command, handler)`
- コマンド実行: `mediator.dispatch(command, payload)`
- エラーハンドリング: `xpcall`による例外安全性
- 可視化: エラー時は`hs.alert.show`で即座に通知

**log.lua**: ログシステム
- カテゴリ別ログレベル設定
- 構造化ログ出力

### 2. Commands レイヤー (`commands/`)

ビジネスロジックの実装。各コマンドは以下の規約に従う：

```lua
-- コマンド命名: "領域.動詞"
mediator.register("input.ime.flash", function(payload)
  -- 実装
end)
```

**input.lua**: IME・Karabiner関連
- `input.ime.flash`: IME状態表示
- `input.karabiner.select`: プロファイル選択
- `input.profile.reconcile`: 統合プロファイル整合

### 3. Triggers レイヤー (`triggers/`)

イベント起点の実装。Mediatorにコマンドをディスパッチする役割のみ。

**path.lua**: ファイル監視
- `.lua`ファイル変更で自動リロード

**hotkey.lua**: ホットキー
- `Ctrl+Alt+Cmd+R`: リロード + プロファイル整合

**watchers/**: 各種監視
- `usb.lua`: USB機器接続/切断
- `power.lua`: 電源復帰・画面アンロック

### 4. Repositories レイヤー (`repositories/`)

外部システムとの薄い連携層。

**shell.lua**: 汎用シェル実行
- 同期・非同期実行サポート
- コマンド存在確認

**karabiner.lua**: Karabiner-Elements CLI
- プロファイル選択
- 現在プロファイル取得

**blueutil.lua**: Bluetooth操作
- デバイス一覧取得
- 接続状態確認

## 命名規則

### コマンド名
- 形式: `<領域>.<動詞>`
- 例: `input.ime.flash`, `input.karabiner.select`, `input.profile.reconcile`

### 引数
- 全て**テーブル1個**に統一
- 例: `mediator.dispatch("input.karabiner.select", { profile = "Laptop" })`

### ファイル名
- `commands/`: 機能領域名（例: `input.lua`, `window.lua`）
- `triggers/`: 起点種別名（例: `hotkey.lua`, `watchers/usb.lua`）
- `repositories/`: 連携先名（例: `karabiner.lua`, `blueutil.lua`）

## エラーハンドリング戦略

### 原則
1. **失敗は目に見える**: `hs.alert.show`による即座な可視化
2. **痕跡は残す**: カテゴリ別ログで後から追跡可能
3. **静かな失敗は作らない**: 例外は必ずキャッチして通知

### 実装
```lua
-- Mediator内での例外安全実行
local success, result = xpcall(function()
  return handler(payload)
end, function(err)
  return debug.traceback("Handler error: " .. tostring(err))
end)

if not success then
  M.log:e("error in command '" .. command .. "': " .. tostring(result))
  hs.alert.show("Error in: " .. command)
  return false
end
```

### 外部CLI不在時
```lua
if not shell.fileExists(KARABINER_CLI) then
  hs.notify.new({
    title = "Karabiner",
    informativeText = "karabiner_cli が見つかりません"
  }):send()
  return false
end
```

## 拡張方法

### 新しいコマンドの追加

1. `commands/` に新ファイル作成 または 既存ファイルに追加
2. Mediatorに登録
3. `init.lua` で `require().register()` 呼び出し

```lua
-- commands/example.lua
local M = {}
local mediator = require("core.mediator")

local function doSomething(payload)
  -- 実装
end

function M.register()
  mediator.register("example.do", doSomething)
end

return M
```

### 新しいトリガーの追加

1. `triggers/` に新ファイル作成
2. 適切なイベントでMediatorにディスパッチ
3. `init.lua` で `require()` 呼び出し

```lua
-- triggers/example.lua
local mediator = require("core.mediator")

-- イベント監視設定
some_watcher = hs.some.watcher.new(function(event)
  mediator.dispatch("example.do", { event = event })
end)
some_watcher:start()
```

### 新しいRepository の追加

1. `repositories/` に新ファイル作成
2. 外部システムとの薄い連携層を実装
3. Commands から利用

```lua
-- repositories/example.lua
local M = {}
local shell = require("repositories.shell")

function M.executeCommand(args)
  return shell.execute("example-cli " .. args)
end

return M
```

## なぜEventBusを使わないのか

- **1人開発＋中小規模**: イベントの発行先が分散すると"糸"を見失いやすい
- **中央集権の利点**: Mediatorに"何を呼ぶか"を集める方が後日読み返しやすい
- **デバッグ容易性**: 単一の司令塔なので実行フローが追いやすい

## 今後の拡張パターン

### 規模が増えた場合
- 領域ごとにミニMediatorを切り出し（例: `core/mediators/input.lua`）
- CommandとRepositoryをさらに細分化

### 通知が増えた場合
- UIトーストやログのような**副作用の薄い通知**のみ軽量Pub/Sub導入可
- ただし、必須ではない

### パフォーマンスが問題になった場合
- 非同期処理の拡充
- 遅延実行・デバウンスの強化
- メモリ使用量の最適化

## 移行履歴

このアーキテクチャは、既存の500行超のモノリシックな`init.lua`から段階的にリアーキテクティングしたものです：

1. **フェーズ1**: 基盤コア実装（Mediator + Log）
2. **フェーズ2**: Repository実装（外部CLI連携）
3. **フェーズ3**: Commands実装（ビジネスロジック）
4. **フェーズ4**: Triggers実装（イベント起点）
5. **フェーズ5**: init.lua移行（新アーキテクチャ適用）
6. **フェーズ6**: テスト・検証・クリーンアップ

全ての既存機能を維持しながら、保守性・拡張性を大幅に向上させることに成功しました。