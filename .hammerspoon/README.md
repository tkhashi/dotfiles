# Hammerspoon Configuration

このリポジトリは構造化アーキテクチャに基づくHammerspoon設定です。保守性・拡張性を重視した設計で、簡単にカスタマイズできます。

## 🚀 機能

### IME（日本語入力）サポート
- **リアルタイム表示**: IME切替時にアラート表示（「あ」「A」）
- **メニューバー表示**: 現在のIME状態をメニューバーに表示

### Karabiner-Elements 自動プロファイル切替
- **USB/Bluetooth監視**: キーボード接続状態を自動検知
- **優先順位制御**: UHK > Naya(USB) > Naya(BT) > Laptop の順で自動選択
- **復帰時対応**: スリープ復帰・画面アンロック時に自動で状態確認・切替
- **対応キーボード**: 
  - UHK 60 v2 (Ultimate Gadget Laboratories)
  - Naya Create (USB/Bluetooth)

### 自動リロード
- **ファイル監視**: `.lua`ファイルの変更を検知して自動リロード

## ⌨️ ホットキー

| キー | 機能 |
|------|------|
| `Ctrl+Alt+Cmd+R` | 手動リロード + プロファイル整合実行 |

## ⚙️ 設定・カスタマイズ

### 依存関係のインストール

```bash
# Bluetooth状態取得用
brew install blueutil

# Karabiner-Elements（公式サイトからインストール）
# https://karabiner-elements.pqrs.org/
```

### 新しいUSBデバイスの追加

USB監視対象を追加するには `commands/input.lua` を編集：

```lua
-- UHKキーボードの例（現在対応済み）
local UHK_USB_MATCHERS = {
  { vendorID = 14248, productID = 3 }  -- UHK 60 v2 (Ultimate Gadget Laboratories)
}

-- 新しいデバイスを追加
local CUSTOM_DEVICE_MATCHERS = {
  { vendorID = 1234, productID = 5678 }   -- あなたのデバイス
}
```

**vendorID/productIDの調べ方**:
```lua
-- Hammerspoonコンソールで実行
hs.inspect(hs.usb.attachedDevices())
```

### 新しいBluetoothデバイスの追加

`repositories/blueutil.lua` を編集：

```lua
-- 対象デバイス設定
M.TARGET = {
  ADDR = "your-device-mac-address",  -- xx:xx:xx:xx:xx:xx 形式
  NAME = "Your Device Name"
}
```

**MACアドレスの調べ方**:
```bash
blueutil --paired --format json
```

### 新しいKarabinerプロファイルの追加

KarabinerElement側でプロファイル名を`repositories/karabiner.lua`のプロファイル名と一致させる
`repositories/karabiner.lua`を編集：

```lua
M.PROFILES = {
  LAPTOP = "Laptop",
  NAYA = "Naya Create",
  UHK = "UHK",
  CUSTOM = "Your Custom Profile"  -- 追加
}
```

`commands/input.lua` の優先順位ロジックも更新：

```lua
-- 優先順位を変更
if customDeviceUSB then
  selectedProfile = karabiner.PROFILES.CUSTOM
elseif uhkUSB then
  selectedProfile = karabiner.PROFILES.UHK
-- ... 以下既存の順序
```

## 🔧 高度なカスタマイズ

### 新しいホットキーの追加

`triggers/hotkey.lua` を編集：

```lua
-- 新しいホットキーを追加
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "T", function()
  log:i("custom hotkey triggered")
  mediator.dispatch("your.custom.command")
end)
```

### 新しいファイル監視の追加

新しいwatcherを作成 `triggers/watchers/custom.lua`：

```lua
local mediator = require("core.mediator")
local log = hs.logger.new("custom", "info")

-- ファイル・ディレクトリ監視
local function onPathChange(files)
  for _, file in pairs(files) do
    if file:match("特定のパターン") then
      mediator.dispatch("your.command", { file = file })
    end
  end
end

local watcher = hs.pathwatcher.new("/path/to/watch", onPathChange)
watcher:start()
log:i("custom path watcher started")
```

`init.lua` で読み込み：

```lua
require("triggers.watchers.custom")
```

### 新しいコマンドの追加

新しいコマンドファイル `commands/window.lua` を作成：

```lua
local M = {}
local mediator = require("core.mediator")
local log = hs.logger.new("window", "info")

-- ウィンドウを左半分に配置
local function snapLeft(payload)
  local win = hs.window.focusedWindow()
  if win then
    local screen = win:screen()
    local frame = screen:frame()
    win:setFrame({
      x = frame.x,
      y = frame.y,
      w = frame.w / 2,
      h = frame.h
    })
    log:i("window snapped to left")
  end
end

function M.register()
  mediator.register("window.snap.left", snapLeft)
  log:i("window commands registered")
end

return M
```

`init.lua` で登録：

```lua
require("commands.window").register()
```

### 新しい外部CLI連携の追加

新しいrepository `repositories/custom-cli.lua` を作成：

```lua
local M = {}
local shell = require("repositories.shell")
local log = hs.logger.new("custom-cli", "info")

-- CLIコマンドのパス
local CLI_PATH = "/usr/local/bin/your-cli"

function M.isAvailable()
  return shell.fileExists(CLI_PATH)
end

function M.executeAction(args)
  if not M.isAvailable() then
    log:e("CLI not found: " .. CLI_PATH)
    return false
  end
  
  local command = string.format("%q %s", CLI_PATH, args)
  local output, success = shell.execute(command)
  
  if success then
    log:i("CLI executed successfully")
  else
    log:e("CLI execution failed")
  end
  
  return success, output
end

return M
```

## � デバッグ・トラブルシューティング

### ログの確認

Hammerspoonコンソール（メニューバー → Console）で確認：

```lua
-- 登録されているコマンド一覧
hs.inspect(require("core.mediator").handlers)

-- 特定のコマンドを手動実行
require("core.mediator").dispatch("input.profile.reconcile")

-- 登録済みコマンド表示（アラート）
require("core.mediator").showCommands()
```

### よくある問題

1. **コマンドが見つからない**
   - `init.lua`で`require().register()`の呼び出しを確認
   - コマンド名のスペルチェック

2. **外部CLIが動かない**
   - パスの確認: `hs.fs.attributes("/path/to/cli")`
   - 権限の確認: `ls -la /path/to/cli`

3. **USBデバイスが認識されない**
   - `hs.inspect(hs.usb.attachedDevices())` で実際のvendorID/productIDを確認
   - デバイス名（productName）もチェック

4. **Bluetoothデバイスが認識されない**
   - `blueutil --paired --format json` でMACアドレスを確認
   - ペアリング状態を確認

### 設定のリセット

問題が解決しない場合：

```lua
-- Hammerspoonコンソールで実行
hs.reload()  -- 設定リロード
hs.relaunch()  -- Hammerspoon再起動
```

## � ファイル構造

```
~/.hammerspoon/
├─ README.md                 # このファイル
├─ ARCHITECTURE.md          # アーキテクチャ詳細
├─ init.lua                  # エントリーポイント
├─ core/                     # 基盤システム
├─ commands/                 # ビジネスロジック
├─ triggers/                 # イベント起点
├─ repositories/            # 外部連携
└─ Spoons/                  # Hammerspoon標準
```

詳細なアーキテクチャについては [ARCHITECTURE.md](./ARCHITECTURE.md) をご覧ください。

## 📄 ライセンス

MIT License