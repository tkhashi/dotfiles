-- triggers/hotkey.lua
-- 手動ホットキートリガー

-- luacheck: globals hs

local mediator = require("core.mediator")
local log = hs.logger.new("hotkey", "info")

-- 手動リロード: Ctrl+Alt+Cmd+R
-- hs.reload() は即座に Lua ステートを破棄するため、それ以降のコードは実行されない
-- リロード後の reconcile は init.lua の起動時整合 (doAfter(1.0)) が担う
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  log:i("manual reload triggered")
  hs.reload()
end)

-- プロファイル手動切り替え: Ctrl+Alt+Cmd+P
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "P", function()
  log:i("manual profile reconcile triggered")
  mediator.dispatch("input.profile.reconcile")
end)

log:i("hotkey triggers registered")