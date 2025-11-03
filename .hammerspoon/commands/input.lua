-- commands/input.lua
-- IME表示・Karabinerプロファイル関連のコマンド

local M = {}
local mediator = require("core.mediator")
local karabiner = require("repositories.karabiner")
local blueutil = require("repositories.blueutil")
local log = hs.logger.new("input", "info")

-- IME表示スタイル（既存設定を移植）
local alertStyle = {
  textSize = 28,
  radius = 10,
  strokeWidth = 1,
  strokeColor = { white = 0, alpha = 0.6 },
  fillColor = { white = 0, alpha = 0.75 },
  textColor = { white = 1, alpha = 1 },
  atScreenEdge = 2,
  fadeInDuration = 0.05,
  fadeOutDuration = 0.2,
  padding = 10,
}

-- IMEメニューバー
local imeMenubar = hs.menubar.new(true)

-- USB監視用設定
local UHK_USB_MATCHERS = {
  -- UHKの vendorID/productID をここに追記（例: { vendorID = 7504, productID = 24864 }）
}

local NAYA_USB_MATCHER = { vendorID = 14289, productID = 100 }

---
--- ユーティリティ関数
---

-- IMEの現在の状態ラベルを取得
local function getIMELabel()
  local sourceId = hs.keycodes.currentSourceID() or ""
  local method   = hs.keycodes.currentMethod()
  local layout   = hs.keycodes.currentLayout() or ""

  if sourceId:match("^com%.google%.inputmethod%.Japanese") then
    if sourceId:match("Roman") then
      return "A"
    else
      return "あ"
    end
  end

  if method ~= nil then return "あ" end
  if layout:match("ABC") or layout:match("U%.S%.") or layout:match("British") or layout == "" then
    return "A"
  end
  return "A"
end

-- USB機器一覧を取得
local function listAttachedUSB()
  local ok, devs = pcall(hs.usb.attachedDevices)
  if ok and type(devs) == "table" then return devs end
  return {}
end

-- 指定されたUSB機器が接続されているか確認
local function usbHasAny(matchers)
  if not matchers or #matchers == 0 then return false end
  for _, dev in ipairs(listAttachedUSB()) do
    for _, m in ipairs(matchers) do
      if dev.vendorID == m.vendorID and dev.productID == m.productID then
        return true
      end
    end
  end
  return false
end

-- Naya USB が接続されているか確認
local function isNayaUsbPresent()
  return usbHasAny({ NAYA_USB_MATCHER })
end

---
--- コマンド実装
---

-- IME状態をアラート・メニューバーに表示
-- @param payload table 未使用
local function imeFlash(payload)
  local label = getIMELabel()
  hs.alert.closeAll(0.0)
  hs.alert.show(label, alertStyle, hs.screen.mainScreen(), 0.5)
  if imeMenubar then 
    imeMenubar:setTitle(label) 
  end
  log:d("IME flash: " .. label)
end

-- Karabinerプロファイルを選択
-- @param payload table { profile: string }
local function karabinerSelect(payload)
  local profile = payload.profile
  if not profile then
    log:e("karabinerSelect: profile not specified")
    hs.alert.show("Error: profile not specified")
    return
  end
  
  log:i("selecting karabiner profile: " .. profile)
  karabiner.selectProfile(profile)
end

-- USB/BT状態から適切なプロファイルを自動選択
-- @param payload table 未使用
local function profileReconcile(payload)
  log:i("starting profile reconcile")
  
  -- 少し待ってから状態確認（デバイス状態の安定化を待つ）
  hs.timer.doAfter(0.6, function()
    local uhkUSB  = usbHasAny(UHK_USB_MATCHERS)
    local nayaUSB = isNayaUsbPresent()
    local nayaBT  = blueutil.isTargetConnected()

    log:i(string.format("device state - UHK USB: %s, Naya USB: %s, Naya BT: %s",
      tostring(uhkUSB), tostring(nayaUSB), tostring(nayaBT)))

    -- 優先順位: UHK > Naya(USB) > Naya(BT) > Laptop
    local selectedProfile
    if uhkUSB then
      selectedProfile = karabiner.PROFILES.UHK
    elseif nayaUSB then
      selectedProfile = karabiner.PROFILES.NAYA
    elseif nayaBT then
      selectedProfile = karabiner.PROFILES.NAYA
    else
      selectedProfile = karabiner.PROFILES.LAPTOP
    end

    log:i("reconciled profile: " .. selectedProfile)
    karabiner.selectProfile(selectedProfile)
  end)
end

---
--- 初期化とコマンド登録
---

-- IMEメニューバーの初期化
local function initIMEMenubar()
  if imeMenubar then 
    imeMenubar:setTitle(getIMELabel()) 
  end
end

-- コマンドをMediatorに登録
function M.register()
  mediator.register("input.ime.flash", imeFlash)
  mediator.register("input.karabiner.select", karabinerSelect)
  mediator.register("input.profile.reconcile", profileReconcile)
  
  -- IMEメニューバー初期化
  initIMEMenubar()
  
  log:i("input commands registered")
end

return M