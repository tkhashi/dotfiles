-- triggers/hotkey.lua
-- 手動ホットキートリガー

-- luacheck: globals hs

local mediator = require("core.mediator")
local log = hs.logger.new("hotkey", "info")

-- 手動リロード: Ctrl+Alt+Cmd+R
-- 手動プロファイル整合: Ctrl+Alt+Cmd+R
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  log:i("manual reload triggered")
  hs.reload()
  log:i("manual profile reconcile triggered")
  mediator.dispatch("input.profile.reconcile")
end)

log:i("hotkey triggers registered")