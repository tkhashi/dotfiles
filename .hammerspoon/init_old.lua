------------------------------------------------------------
-- Hammerspoon init.lua (最終統合版)
--  - 自動リロード / 手動リロード
--  - IMEインジケータ
--  - USB/Bluetooth 状態に応じた Karabiner プロファイル自動切替
--  - 復帰時/リロード時 も自動判定
------------------------------------------------------------

------------------------------------------------------------
-- ===== init.lua保存時に自動リロード =====
------------------------------------------------------------
local function reloadConfig(files)
  local doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == ".lua" then doReload = true end
  end
  if doReload then hs.reload() end
end

local myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

-- == 手動リロード ==
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)
hs.alert.show("Config loaded")

------------------------------------------------------------
-- ===== IME切替インジケータ（ alert + メニューバー ） =====
------------------------------------------------------------
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

local imeMenubar = hs.menubar.new(true)

local function imeLabel()
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

local function flashIME()
  local label = imeLabel()
  hs.alert.closeAll(0.0)
  hs.alert.show(label, alertStyle, hs.screen.mainScreen(), 0.5)
  if imeMenubar then imeMenubar:setTitle(label) end
end

if imeMenubar then imeMenubar:setTitle(imeLabel()) end
hs.keycodes.inputSourceChanged(function() flashIME() end)

------------------------------------------------------------
-- ===== Karabiner設定 =====
------------------------------------------------------------
local KARABINER_CLI = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

local PROFILE_LAPTOP = "Laptop"
local PROFILE_NAYA   = "Naya Create"
local PROFILE_UHK    = "UHK"

------------------------------------------------------------
-- ===== Karabiner プロファイル切替 共通関数 =====
------------------------------------------------------------
local function selectKarabinerProfile(profileName)
  if not hs.fs.attributes(KARABINER_CLI) then
    hs.notify.new({
      title = "Karabiner",
      informativeText = "karabiner_cli が見つかりません: " .. KARABINER_CLI
    }):send()
    return
  end
  hs.task.new(KARABINER_CLI, nil, {"--select-profile", profileName}):start()
  hs.alert.show("Karabiner → " .. profileName, 0.8)
end

------------------------------------------------------------
-- ===== USB監視（修正版：直接切替しないで一元判定へ委譲）=====
------------------------------------------------------------

-- 既存の usbWatcher を止めて差し替え
if usbWatcher then usbWatcher:stop(); usbWatcher = nil end

-- デバウンス付きの整合実行（onWake を呼ぶ）
local usbChangeTimer
local function reconcileAfter(delay, reason)
  delay = delay or 0.3
  if usbChangeTimer then usbChangeTimer:stop() end
  usbChangeTimer = hs.timer.doAfter(delay, function()
    hs.printf("[USB] reconcile (%s)", reason or "?")
    -- 即時の整合
    if type(onWake) == "function" then onWake() end
    -- 追い判定（BT が遅れて立ち上がるケースの保険）
    hs.timer.doAfter(1.2, function()
      if type(onWake) == "function" then onWake() end
    end)
  end)
end

-- Naya Create Left だけを監視して、追加/削除をトリガに「整合」だけ行う
local function handleUSB(dev)
  if dev.vendorID == 14289 and dev.productID == 100 and dev.productName == "Naya Create Left" then
    if dev.eventType == "added" then
      hs.printf("[USB] Naya USB added -> reconcile")
      reconcileAfter(0.1, "naya-usb-added")
    elseif dev.eventType == "removed" then
      hs.printf("[USB] Naya USB removed -> reconcile")
      reconcileAfter(0.3, "naya-usb-removed")
    end
  else
    -- 他のUSB機器でも整合したい場合はここで呼んでもOK
    -- reconcileAfter(0.3, "other-usb-change")
  end
end

usbWatcher = hs.usb.watcher.new(handleUSB)
usbWatcher:start()
hs.alert.show("USB watcher (reconcile mode) started", 0.6)

------------------------------------------------------------
-- ===== Bluetooth監視 =====
------------------------------------------------------------
local TARGET_ADDR = "e7-b6-78-48-3f-a6"
local TARGET_NAME = "Naya Create"

-- blueutil path 検出
local function findBlueutil()
  local cands = {
    "/opt/homebrew/bin/blueutil",
    "/usr/local/bin/blueutil",
    (hs.execute("/usr/bin/which blueutil") or ""):gsub("%s+$",""),
  }
  for _,p in ipairs(cands) do
    if p and p ~= "" and hs.fs.attributes(p) then return p end
  end
  return nil
end
local BLUEUTIL = findBlueutil()

local function dashLower(s) return (s or ""):lower():gsub(":", "-") end
local function log(fmt, ...) hs.printf("[BT→KARA] " .. fmt, ...) end

local function sh(cmd)
  local out, ok, _, rc = hs.execute(cmd .. " 2>&1")
  return out or "", ok, rc or -1
end

-- Bluetooth状態取得
local function isTargetConnected()
  if not BLUEUTIL then BLUEUTIL = findBlueutil() end
  if not BLUEUTIL then return false end
  local out = select(1, sh(string.format("%q --paired --format json", BLUEUTIL)))
  if out and out:match("^%s*%[") then
    local okj, list = pcall(hs.json.decode, out)
    if okj and type(list) == "table" then
      for _, dev in ipairs(list) do
        local addr = dashLower(dev.address or "")
        local connected = (dev.connected == 1 or dev.connected == true)
        if addr == TARGET_ADDR then return connected end
      end
    end
  end
  return false
end

------------------------------------------------------------
-- ===== 復帰時 / リロード時 処理（onWake）
------------------------------------------------------------
-- USB列挙ヘルパ
local function listAttachedUSB()
  local ok, devs = pcall(hs.usb.attachedDevices)
  if ok and type(devs) == "table" then return devs end
  return {}
end

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

local UHK_USB_MATCHERS = {
  -- UHKの vendorID/productID をここに追記（例: { vendorID = 7504, productID = 24864 }）
}

local function isNayaUsbPresent()
  return usbHasAny({ { vendorID = 14289, productID = 100 } })
end

-- ====== onWake: 復帰/リロード時の接続判定 ======
function onWake()
  hs.timer.doAfter(0.6, function()
    local uhkUSB  = usbHasAny(UHK_USB_MATCHERS)
    local nayaUSB = isNayaUsbPresent()
    local nayaBT  = isTargetConnected()

    hs.printf("[onWake] uhkUSB=%s nayaUSB=%s nayaBT=%s",
      tostring(uhkUSB), tostring(nayaUSB), tostring(nayaBT))

    if uhkUSB then
      selectKarabinerProfile(PROFILE_UHK)
    elseif nayaUSB then
      selectKarabinerProfile(PROFILE_NAYA)
    elseif nayaBT then
      selectKarabinerProfile(PROFILE_NAYA)
    else
      selectKarabinerProfile(PROFILE_LAPTOP)
    end
  end)
end

-- 復帰時トリガー
if wakeWatcher then wakeWatcher:stop() end
wakeWatcher = hs.caffeinate.watcher.new(function(ev)
  if ev == hs.caffeinate.watcher.systemDidWake
     or ev == hs.caffeinate.watcher.screensDidWake
     or ev == hs.caffeinate.watcher.screensDidUnlock then
    hs.timer.doAfter(0.5, function() onWake() end)
  end
end)
wakeWatcher:start()

-- ====== リロード時にも onWake 実行 ======
hs.timer.doAfter(1.0, function()
  hs.printf("[reload] run onWake() after reload")
  onWake()
end)

-- 手動テスト（Ctrl+Alt+Cmd+W）
hs.hotkey.bind({"ctrl","alt","cmd"}, "W", function()
  hs.printf("[manual] run onWake()")
  onWake()
end)

------------------------------------------------------------
-- 終了メッセージ
------------------------------------------------------------
hs.alert.show("Karabiner auto-switch active", 0.8)
