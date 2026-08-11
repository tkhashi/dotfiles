-- triggers/watchers/power.lua
-- 電源復帰時のトリガー

-- luacheck: globals hs wakeWatcher

local mediator = require("core.mediator")
local log = hs.logger.new("power", "info")

-- 復帰時の処理
-- Bluetooth機器の再接続はmacOS側で数秒〜十数秒かかることがあるため、
-- 打ち切りを早めず複数回にわたってプロファイル整合を試みる
local RECONCILE_DELAYS = { 0.5, 2, 4, 7, 11, 15 } -- 秒（wakeイベントからの経過時間）

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

  for i, delay in ipairs(RECONCILE_DELAYS) do
    hs.timer.doAfter(delay, function()
      log:i(string.format("power event reconcile attempt %d/%d (+%.1fs)", i, #RECONCILE_DELAYS, delay))
      mediator.dispatch("input.profile.reconcile")
    end)
  end
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