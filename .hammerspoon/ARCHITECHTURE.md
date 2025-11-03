# Hammerspoon Architecture (Mediator + Triggers + Repositories)

このドキュメントは、既存の `init.lua` を**見通しよく保ち、日が空いても“糸”をすぐ辿れる**ことを目的にしたアーキテクチャを定義します。メンテナは1名、規模は中小を想定し、**EventBus は採用しません**。中心は「**Mediator（司令塔）**」です。

---

## 目的 / 非機能要件

* **理解しやすさ**：起点（何が起こすか）と処理（何をするか）が1枚で追える。
* **変更容易性**：トリガや外部CLIを差し替えても、コマンドの呼び出し規約は固定。
* **堅牢性**：例外時にアラート・ログが必ず出る。
* **小さく始めて拡張可能**：領域ごとにファイル追加でスケール。

---

## 用語

* **Mediator**: コマンドの登録とディスパッチだけを担う司令塔。
* **Command**: 実処理の本体（ユースケース）。`mediator.register("領域.動詞", fn)` で登録。
* **Trigger**: 起こす側（Hotkey/Watcher/Timer/Pathwatcherなど）。**呼び出し元を「event」とは呼ばず**、本ドキュメントでは **Trigger** と呼ぶ。
* **Repository**: 外部コマンドやOS機能への薄いラッパ（`blueutil`/`karabiner_cli`/shell）。

---

## ディレクトリ構成

```
~/.hammerspoon/
├─ init.lua                  # 最小限：登録と起動の並びだけ
├─ core/
│  ├─ mediator.lua           # 司令塔（register/dispatch + エラーハンドリング）
│  └─ log.lua                # ログ設定（任意）
├─ commands/                 # “する側” 実処理
│  ├─ input.lua              # IME表示/キーボード/Karabiner関連のコマンド
│  ├─ app.lua                # アプリ起動/切替
│  ├─ window.lua             # ウィンドウ配置
│  └─ net.lua                # ネットワーク/BT 等（blueutil 連携）
├─ triggers/                 # “起こす側” 起点の集約
│  ├─ hotkey.lua             # ホットキー→コマンド
│  └─ watchers/
│     ├─ app.lua             # hs.application.watcher
│     ├─ usb.lua             # hs.usb.watcher
│     ├─ bt.lua              # BT状態ポーリング/整合（必要なら）
│     ├─ power.lua           # hs.caffeinate.watcher（復帰/アンロック）
│     └─ path.lua            # hs.pathwatcher（自動リロード）
└─ repositories/             # 外部CLIの薄いラッパ
   ├─ shell.lua
   ├─ blueutil.lua
   └─ karabiner.lua
```

---

## コマンド命名規則

`<領域>.<動詞>` を基本形にします。

* 例: `input.ime.flash`, `input.karabiner.select`, `net.bt.set`, `app.toggle`, `window.snap`
* **引数はテーブル1個**に固定：`mediator.dispatch("net.bt.set", { on=true })`

---

## リクエスト・フロー（標準）

```
Trigger (Hotkey/Watcher/Timer)
  └─ mediator.dispatch("領域.動詞", { ...payload })
        └─ Command（登録済みハンドラ）
              └─ Repository（必要に応じて外部CLI実行）
```

---

## `init.lua` の役割（最小主義）

* **やることは3つだけ**

  1. コマンド群の `register()` を列挙（＝できること一覧）
  2. トリガ群の `require()` を列挙（＝何で起こすか一覧）
  3. 初期メッセージ/起動時整合のトリガ（必要に応じて）

例：

```lua
-- init.lua（イメージ）
require("commands.input").register()
require("commands.app").register()
require("commands.net").register()
-- ここまでで“何ができるか”が一望

require("triggers.path")       -- 自動リロード
require("triggers.hotkey")     -- 手動トグル/ショートカット
require("triggers.watchers.usb")
require("triggers.watchers.power")
-- ここまでで“何で起こすか”が一望

hs.alert.show("Hammerspoon ready")
```

---

## 既存 `init.lua` からのマッピング

| 現在の機能                    | 新アーキテクチャでの配置                                                  | コマンド/トリガ名の例                                                  |
| ------------------------ | ------------------------------------------------------------- | ------------------------------------------------------------ |
| 自動/手動リロード                | `triggers/path.lua`・`triggers/hotkey.lua`                     | `Ctrl+Alt+Cmd+R` は `hs.reload()` 直叩きでOK                      |
| IMEインジケータ                | `commands/input.lua` に実装                                      | `input.ime.flash` （メニューバー更新も含む）                              |
| Karabinerプロファイル切替        | `commands/input.lua` + `repositories/karabiner.lua`           | `input.karabiner.select { profile=... }`                     |
| USB監視→整合                 | `triggers/watchers/usb.lua`                                   | 起点：`onChange → mediator.dispatch("input.profile.reconcile")` |
| Bluetooth監視/取得（blueutil） | `repositories/blueutil.lua` +（必要なら）`triggers/watchers/bt.lua` | `net.bt.isConnected()` など（Repositoryの関数）                     |
| 復帰/リロード時判定（onWake）       | `triggers/watchers/power.lua` + `commands/input.lua`          | `input.profile.reconcile`                                    |
| 手動テスト（W）                 | `triggers/hotkey.lua`                                         | `Ctrl+Alt+Cmd+W → input.profile.reconcile`                   |

> `onWake` のような“整合関数”は Command 側に置き、**`input.profile.reconcile`** などのコマンド名に統一します。

---

## 代表的な実装スケッチ

### core/mediator.lua（司令塔・共通）

* `register(command, fn)` / `dispatch(command, payload)`
* 例外時は `hs.alert` と `hs.logger` で可視化。

```lua
local M = { handlers = {}, log = hs.logger.new("mediator", "info") }
function M.register(cmd, fn) M.handlers[cmd] = fn end
function M.dispatch(cmd, payload)
  local h = M.handlers[cmd]
  if not h then M.log.ef("no handler: %s", cmd); hs.alert.show("No handler: "..cmd); return end
  local ok, err = xpcall(function() h(payload or {}) end, debug.traceback)
  if not ok then M.log.ef("error in %s: %s", cmd, err); hs.alert.show("Error: "..cmd) end
end
return M
```

### commands/input.lua（例：IME表示 + Karabiner整合）

```lua
local mediator = require("core.mediator")
local karabiner = require("repositories.karabiner")
local blueutil  = require("repositories.blueutil")
local input = {}

local function imeFlash()
  -- 既存の imeLabel()/alertStyle/menubar ロジックを移植
end

local function profileReconcile()
  -- 既存 onWake() の判定ロジックを移植（UHK/Naya/BT）
  -- karabiner.select(profile) を呼ぶ
end

function input.register()
  mediator.register("input.ime.flash", imeFlash)
  mediator.register("input.profile.reconcile", profileReconcile)
  mediator.register("input.karabiner.select", function(p) karabiner.select(p.profile) end)
end

return input
```

### repositories/karabiner.lua（外部CLIラッパ）

```lua
local K = {}
local BIN = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
function K.select(profile)
  if not hs.fs.attributes(BIN) then
    hs.notify.new({title="Karabiner", informativeText="karabiner_cli が見つかりません"}):send(); return
  end
  hs.task.new(BIN, nil, {"--select-profile", profile}):start()
end
return K
```

### triggers/watchers/power.lua（復帰/アンロック時）

```lua
local mediator = require("core.mediator")
local w = hs.caffeinate.watcher.new(function(ev)
  if ev == hs.caffeinate.watcher.systemDidWake
    or ev == hs.caffeinate.watcher.screensDidWake
    or ev == hs.caffeinate.watcher.screensDidUnlock then
    hs.timer.doAfter(0.5, function() mediator.dispatch("input.profile.reconcile") end)
  end
end)
w:start()
```

### triggers/watchers/usb.lua（USBイベント → デバウンス整合）

```lua
local mediator = require("core.mediator")
local t
local function reconcileAfter(sec)
  if t then t:stop() end
  t = hs.timer.doAfter(sec or 0.3, function()
    mediator.dispatch("input.profile.reconcile")
    hs.timer.doAfter(1.2, function() mediator.dispatch("input.profile.reconcile") end)
  end)
end
local watcher = hs.usb.watcher.new(function(dev)
  -- Naya Create Left など条件を既存実装から転記
  reconcileAfter(0.3)
end)
watcher:start()
```

### triggers/path.lua（自動リロード）

```lua
local function reloadLua(files)
  for _, f in pairs(files) do if f:sub(-4) == ".lua" then hs.reload(); return end end
end
hs.pathwatcher.new(os.getenv("HOME").."/.hammerspoon/", reloadLua):start()
```

### triggers/hotkey.lua（手動）

```lua
local mediator = require("core.mediator")
hs.hotkey.bind({"cmd","alt","ctrl"}, "R", function() hs.reload() end)
hs.hotkey.bind({"ctrl","alt","cmd"}, "W", function() mediator.dispatch("input.profile.reconcile") end)
```

---

## ロギング / アラート方針

* **失敗は目に見える**：`hs.alert.show(...)` を基本。静かな失敗は作らない。
* **痕跡は残す**：`hs.logger` のカテゴリー名を `mediator` / `usb` / `bt` / `karabiner` などに分ける。

---

## テスト・運用

* 手動整合：`Ctrl+Alt+Cmd+W` → `input.profile.reconcile`
* 起動時メッセージ：`hs.alert.show("Hammerspoon ready")`
* 追加手順：

  1. `commands/xxx.lua` に処理を実装し `register()` で Mediator 登録
  2. `init.lua` に `require("commands.xxx").register()` を1行足す
  3. 必要な Trigger を `triggers/` に追加し `init.lua` で `require`

---

## 例外時の扱い

* Mediator 内で `xpcall` してアラート＋ログ。
* Repository で外部CLIが見つからない場合は `hs.notify` and/or `hs.alert` を出す。

---

## なぜ EventBus を使わないか

* 1人開発＋中小規模では、イベントの発行先が分散すると“糸”を見失いやすい。
* 中央（Mediator）に“何を呼ぶか”を集めておく方が、**後日読み返しやすい**。

---

## 今後の拡張

* 規模が増えたら、領域ごとにミニMediatorを切り出す（例：`core/mediators/input.lua`）。
* UIトーストやログのような**副作用の薄い通知**が増えたときのみ、軽量Pub/Subを導入可（必須ではない）。

---

## 付録：コマンド一覧ひな型（README用）

```
- input.ime.flash               : IME状態をAlert/メニューバー表示
- input.karabiner.select        : { profile: "Laptop" | "Naya Create" | "UHK" }
- input.profile.reconcile       : USB/BT状態から適切なプロファイルへ切替
- app.toggle                    : { name: "Activity Monitor" } など
- window.snap                   : { edge: "left" | "right" }
- net.bt.set                    : { on: true|false }
```
