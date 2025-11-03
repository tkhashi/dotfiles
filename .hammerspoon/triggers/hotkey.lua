-- triggers/hotkey.lua
-- 手動ホットキートリガー

local mediator = require("core.mediator")
local log = hs.logger.new("hotkey", "info")

-- 手動リロード: Ctrl+Alt+Cmd+R
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  log:i("manual reload triggered")
  hs.reload()
end)

-- 手動プロファイル整合: Ctrl+Alt+Cmd+W
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "W", function()
  log:i("manual profile reconcile triggered")
  mediator.dispatch("input.profile.reconcile")
end)

log:i("hotkey triggers registered")