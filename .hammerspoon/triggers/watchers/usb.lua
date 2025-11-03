-- triggers/watchers/usb.lua
-- USB監視トリガー

local mediator = require("core.mediator")
local log = hs.logger.new("usb", "info")

-- デバウンス付きの整合実行
local usbChangeTimer

local function reconcileAfter(delay, reason)
  delay = delay or 0.3
  reason = reason or "unknown"
  
  if usbChangeTimer then 
    usbChangeTimer:stop() 
  end
  
  usbChangeTimer = hs.timer.doAfter(delay, function()
    log:i("usb reconcile triggered: " .. reason)
    
    -- 即時の整合
    mediator.dispatch("input.profile.reconcile")
    
    -- 追い判定（BT が遅れて立ち上がるケースの保険）
    hs.timer.doAfter(1.2, function()
      log:d("usb delayed reconcile: " .. reason)
      mediator.dispatch("input.profile.reconcile")
    end)
  end)
end

-- USB機器変更の処理
local function handleUSB(dev)
  -- Naya Create Left の監視
  if dev.vendorID == 14289 and dev.productID == 100 and dev.productName == "Naya Create Left" then
    if dev.eventType == "added" then
      log:i("Naya USB added")
      reconcileAfter(0.1, "naya-usb-added")
    elseif dev.eventType == "removed" then
      log:i("Naya USB removed")  
      reconcileAfter(0.3, "naya-usb-removed")
    end
  else
    -- その他のUSB機器でも軽く整合
    log:d("other USB device changed: " .. (dev.productName or "unknown"))
    -- reconcileAfter(0.3, "other-usb-change")
  end
end

-- 既存のusbWatcherを停止（もしあれば）
if usbWatcher then 
  usbWatcher:stop() 
  usbWatcher = nil 
end

-- USB監視開始
usbWatcher = hs.usb.watcher.new(handleUSB)
usbWatcher:start()

log:i("USB watcher started (reconcile mode)")