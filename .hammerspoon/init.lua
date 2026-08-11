------------------------------------------------------------
-- Hammerspoon init.lua 
-- リアーキテクティング済み: Mediator + Triggers + Repositories
-- 詳細なアーキテクチャについては ARCHITECTURE.md を参照
------------------------------------------------------------

-- luacheck: globals hs

-- 💡 新アーキテクチャのinit.luaの役割：
-- 1. コマンド群の register() を列挙（何ができるか一覧）
-- 2. トリガ群の require() を列挙（何で起こすか一覧）  
-- 3. 初期メッセージ/起動時整合のトリガ

------------------------------------------------------------
-- === フェーズ1: コマンド登録（何ができるか一覧） ===
------------------------------------------------------------

-- IME表示・Karabinerプロファイル関連
require("commands.input").register()

------------------------------------------------------------
-- === フェーズ2: トリガー起動（何で起こすか一覧） ===
------------------------------------------------------------

-- 自動リロード（.luaファイル変更監視）
require("triggers.path")

-- 手動ホットキー（Ctrl+Alt+Cmd+R: リロード + プロファイル整合）
require("triggers.hotkey")

-- USB監視（Naya Create Left 接続/切断）
require("triggers.watchers.usb")

-- 電源監視（復帰/アンロック時）
require("triggers.watchers.power")

------------------------------------------------------------
-- === フェーズ3: 初期化処理 ===
------------------------------------------------------------

-- IME変更時のトリガー設定（既存機能の維持）
hs.keycodes.inputSourceChanged(function()
  local mediator = require("core.mediator")
  mediator.dispatch("input.ime.flash")
end)

-- 起動完了メッセージ
hs.alert.show("Hammerspoon ready", 1.0)

-- 起動時のプロファイル整合（既存機能の維持）
-- reload直後はBlueutil呼び出しが安定するまで一瞬ラグが出ることがあるため、
-- power.lua と同様に複数回リトライする
local STARTUP_RECONCILE_DELAYS = { 1.0, 2.5, 5 } -- 秒（起動/reloadからの経過時間）
for i, delay in ipairs(STARTUP_RECONCILE_DELAYS) do
  hs.timer.doAfter(delay, function()
    local mediator = require("core.mediator")
    mediator.dispatch("input.profile.reconcile")
  end)
end