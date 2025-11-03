-- triggers/hotkey.lua
-- 手動ホットキートリガー

-- luacheck: globals hs

local mediator = require("core.mediator")
local log = hs.logger.new("hotkey", "info")

-- 手動リロード + プロファイル整合: Ctrl+Alt+Cmd+R
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  log:i("manual reload and profile reconcile triggered")
  hs.reload()
  -- リロード後に少し待ってからプロファイル整合を実行
  hs.timer.doAfter(0.5, function()
    mediator.dispatch("input.profile.reconcile")
  end)
end)

log:i("hotkey triggers registered")