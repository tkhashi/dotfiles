-- triggers/watchers/power.lua
-- 電源復帰時のトリガー

-- luacheck: globals hs wakeWatcher

local mediator = require("core.mediator")
local log = hs.logger.new("power", "info")

-- 復帰時の処理
local function handlePowerEvent(eventType)
  if eventType == hs.caffeinate.watcher.systemDidWake then
    log:i("system did wake")
  elseif eventType == hs.caffeinate.watcher.screensDidWake then
    log:i("screens did wake")
  elseif eventType == hs.caffeinate.watcher.screensDidUnlock then
    log:i("screens did unlock")
  else
    return -- 対象外のイベント
  end
  
  -- 少し遅延してからプロファイル整合を実行
  hs.timer.doAfter(0.5, function()
    log:i("power event reconcile triggered")
    mediator.dispatch("input.profile.reconcile")
  end)
end

-- 既存のwakeWatcherを停止（もしあれば）
if wakeWatcher then 
  wakeWatcher:stop() 
  wakeWatcher = nil 
end

-- 電源監視開始
wakeWatcher = hs.caffeinate.watcher.new(handlePowerEvent)
wakeWatcher:start()

log:i("power watcher started")