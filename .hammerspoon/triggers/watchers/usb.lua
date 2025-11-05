-- triggers/watchers/usb.lua
-- USB監視トリガー

-- luacheck: globals hs usbWatcher

local mediator = require("core.mediator")
local log = hs.logger.new("usb", "info")  -- デバッグレベルを本番用に戻す

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

-- 監視対象デバイス設定
local MONITORED_DEVICES = {
  {vid = 14289, pid = 100, name = "Naya Create Left", type = "naya", productName = "Naya Create Left"},
  {vid = 14248, pid = 3, name = "UHK 60 v2", type = "uhk"}
}

-- USB機器変更の処理
local function handleUSB(dev)
  -- 監視対象デバイスかチェック
  for _, device in ipairs(MONITORED_DEVICES) do
    local isMatch = dev.vendorID == device.vid and dev.productID == device.pid
    -- productNameが指定されている場合は名前もチェック
    if device.productName then
      isMatch = isMatch and dev.productName == device.productName
    end
    
    if isMatch then
      if dev.eventType == "added" then
        log:i(device.name .. " USB added")
        reconcileAfter(0.1, device.type .. "-usb-added")
      elseif dev.eventType == "removed" then
        log:i(device.name .. " USB removed")  
        reconcileAfter(0.3, device.type .. "-usb-removed")
      end
      return -- マッチしたので他のデバイスはチェック不要
    end
  end
  
  -- 監視対象外デバイスは軽くログ出力のみ
  log:d("other USB device changed: " .. (dev.productName or "unknown"))
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