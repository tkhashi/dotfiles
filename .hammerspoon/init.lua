-- ===== init.lua保存時に自動リロード =====
local function reloadConfig(files)
    local doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
local myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")

-- == init.lua手動リロード ==
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)
hs.alert.show("Config loaded")

-- ===== IME切替インジケータ（ alert + メニューバー ） =====

local alertStyle = {
  textSize = 28,
  radius = 10,
  strokeWidth = 1,
  strokeColor = { white = 0, alpha = 0.6 },
  fillColor = { white = 0, alpha = 0.75 },
  textColor = { white = 1, alpha = 1 },
  atScreenEdge = 2,  -- 0:上, 1:右, 2:下, 3:左
  fadeInDuration = 0.05,
  fadeOutDuration = 0.2,
  padding = 10,
}

local imeMenubar = hs.menubar.new(true)

-- 現在の入力ソースからラベルを決める
local function imeLabel()
  local sourceId = hs.keycodes.currentSourceID() or ""
  local method   = hs.keycodes.currentMethod()
  local layout   = hs.keycodes.currentLayout() or ""

  -- --- Google日本語入力の詳細判定 ---
  -- 代表的なSourceID例:
  --   com.google.inputmethod.Japanese.base   => ひらがな（あ）
  --   com.google.inputmethod.Japanese.Roman  => Google IME内の英数（A）
  --   ※バージョンにより末尾が異なる場合もあるため Roman を部分一致で判定
  if sourceId:match("^com%.google%.inputmethod%.Japanese") then
    if sourceId:match("Roman") then
      return "A"     -- Google IMEの英数
    else
      return "あ"     -- Google IMEのかな
    end
  end

  -- --- それ以外のIME/レイアウト（Kotoeri/ATOK等）は大まかに判定 ---
  -- methodが非nilならIME系（かな）とみなす
  if method ~= nil then
    return "あ"
  end

  -- レイアウトが英字系（U.S./ABC/JIS英数など）の場合は英数
  -- 代表例: "U.S.", "ABC", "British", "Australian" など
  if layout:match("ABC") or layout:match("U%.S%.") or layout:match("British") or layout == "" then
    return "A"
  end

  -- その他はざっくり
  return "A"
end

local function flashIME()
  local label = imeLabel()
  hs.alert.closeAll(0.0)
  hs.alert.show(label, alertStyle, hs.screen.mainScreen(), 0.5)
  if imeMenubar then imeMenubar:setTitle(label) end
end

if imeMenubar then imeMenubar:setTitle(imeLabel()) end

hs.keycodes.inputSourceChanged(function()
  flashIME()
end)

local function imeTest()
  flashIME()
end

-- ===== ここまで =====


-- ===== USB接続に応じて Karabiner プロファイルを切り替える =====

-- === Karabiner設定 ===
local KARABINER_CLI = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

-- プロファイル名を変数として定義（将来拡張用）
local PROFILE_LAPTOP = "Laptop"
local PROFILE_NAYA   = "Naya Create"
local PROFILE_UHK    = "UHK"

-- 接続時に切り替えるプロファイル
local PROFILE_ON_CONNECT    = PROFILE_NAYA
-- 取り外し時に戻すデフォルト
local PROFILE_ON_DISCONNECT = PROFILE_LAPTOP

-- === 共通関数 ===
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

-- === USB監視 ===
if usbWatcher then usbWatcher:stop(); local usbWatcher = nil end

-- Naya Create Left 検出ルール
local function handleUSB(dev)
  if dev.vendorID == 14289 and dev.productID == 100 and dev.productName == "Naya Create Left" then
    if dev.eventType == "added" then
      selectKarabinerProfile(PROFILE_ON_CONNECT)
    elseif dev.eventType == "removed" then
      selectKarabinerProfile(PROFILE_ON_DISCONNECT)
    end
  end
end

local usbWatcher = hs.usb.watcher.new(handleUSB)
usbWatcher:start()

hs.alert.show("USB watcher for Naya Create started", 0.6)

-- 手動テスト
local function usbKarabinerTest()
  handleUSB({
    eventType = "added",
    vendorID = 14289,
    productID = 100,
    productName = "Naya Create Left",
  })
end


-- ===== STEP 3: blueutil --paired(JSON)でBT接続→Karabiner切替 =====

-- 監視対象（確定値）
local TARGET_ADDR = "e7-b6-78-48-3f-a6"   -- ダッシュ小文字
local TARGET_NAME = "Naya Create"         -- 念のため名前も保持

-- Karabiner CLI とプロファイル
local KARABINER_CLI = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
local PROFILE_LAPTOP = "Laptop"
local PROFILE_NAYA   = "Naya Create"
local PROFILE_UHK    = "UHK"              -- 将来拡張用
local PROFILE_ON_CONNECT    = PROFILE_NAYA
local PROFILE_ON_DISCONNECT = PROFILE_LAPTOP

-- ログ・ユーティリティ
local function log(fmt, ...) hs.printf("[BT→KARA] " .. fmt, ...) end
local function dashLower(s) return (s or ""):lower():gsub(":", "-"):gsub("%.", "-") end

-- 追加：Bluetooth電源ON/OFFを取る
local function isBluetoothPowerOn()
  if not BLUEUTIL then return true end -- 取れない時は「ON扱い」
  local out, ok, rc = hs.execute(string.format("%q --power 2>&1", BLUEUTIL))
  -- 例: "1" / "0" / "on"/"off"
  return tostring(out):match("1") or tostring(out):match("on")
end

-- blueutil 検出
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

-- コマンド実行（stderrも取る）
local function sh(cmd)
  local out, ok, _, rc = hs.execute(cmd .. " 2>&1")
  return out or "", ok, rc or -1
end

-- Karabiner プロファイル切替
local function selectKarabinerProfile(name)
  if not hs.fs.attributes(KARABINER_CLI) then
    log("karabiner_cli not found: %s", KARABINER_CLI)
    hs.alert.show("karabiner_cli が見つかりません", 0.8)
    return
  end
  log("Karabiner → %s", name)
  hs.task.new(KARABINER_CLI, function(code, out, err)
    log("karabiner_cli exit=%s", tostring(code))
    if (out or "") ~= "" then log("stdout: %s", out) end
    if (err or "") ~= "" then log("stderr: %s", err) end
  end, {"--select-profile", name}):start()
  hs.alert.show("Karabiner → " .. name, 0.6)
end

-- 接続判定：--paired の JSON（最優先）→ テキスト（フォールバック）
local function isTargetConnected()
  if not BLUEUTIL then
    BLUEUTIL = findBlueutil()
    if not BLUEUTIL then
      log("blueutil not found. brew install blueutil")
      return false
    end
  end

  -- A) JSON
  local out, ok, rc = sh(string.format("%q --paired --format json", BLUEUTIL))
  if out and out:match("^%s*%[") then
    local okj, list = pcall(hs.json.decode, out)
    if okj and type(list) == "table" then
      for _, dev in ipairs(list) do
        local addr = dashLower(dev.address or "")
        local connected = (dev.connected == 1 or dev.connected == true)
        if addr == TARGET_ADDR then return connected end
      end
      return false
    end
  end

  -- B) テキスト（JSON非対応時）
  local txt = (sh(string.format("%q --paired", BLUEUTIL))) and select(1, sh(string.format("%q --paired", BLUEUTIL))) or ""
  local curAddr, curConn
local last = nil
local function poll()
  local now = isTargetConnected()
  if last == nil then
    last = now
    log("初期状態 connected=%s (target=%s/%s)", tostring(now), TARGET_NAME, TARGET_ADDR)
    return
  end
  if now ~= last then
    log("状態変化: %s -> %s", tostring(last), tostring(now))
    last = now
    if now then
      selectKarabinerProfile(PROFILE_ON_CONNECT)
    else
      selectKarabinerProfile(PROFILE_ON_DISCONNECT)
    end
  end
end

  for line in (txt or ""):gmatch("[^\r\n]+") do
    local a = line:match("^address:%s*(%S+)")
    if a then curAddr = dashLower(a); curConn = nil end
    local c = line:match("^%s*connected:%s*(%S+)")
    if c then
      curConn = (c == "1" or c == "yes" or c == "true")
      if curAddr and curAddr == TARGET_ADDR then return curConn end
    end
  end
  return false
end

-- 状態監視
-- 置き換え：状態監視ループ（最初の数行を置き換え）
local last = nil
local function poll()
  -- 電源OFFなら強制的に未接続扱いにして Laptop へ戻す
  if not isBluetoothPowerOn() then
    if last ~= false then
      last = false
      hs.printf("[BT→KARA] Bluetooth power OFF -> force Laptop")
      selectKarabinerProfile(PROFILE_ON_DISCONNECT) -- = Laptop
    end
    return
  end

  -- 通常の接続判定（JSONベース）
  local now = isTargetConnected()
  if last == nil then
    last = now
    hs.printf("[BT→KARA] 初期状態 connected=%s", tostring(now))
    return
  end
  if now ~= last then
    hs.printf("[BT→KARA] 状態変化: %s -> %s", tostring(last), tostring(now))
    last = now
    if now then
      selectKarabinerProfile(PROFILE_ON_CONNECT)     -- = Naya Create
    else
      selectKarabinerProfile(PROFILE_ON_DISCONNECT)  -- = Laptop
    end
  end
end


-- タイマー起動（2秒ごと）＋ 起動直後に一回
local t = hs.timer.doEvery(2, poll)
hs.timer.doAfter(0.2, poll)
hs.alert.show("BT→Karabiner (json判定) started", 0.5)

-- スリープ復帰/ロック解除での取りこぼし防止
local wakeWatcher = hs.caffeinate.watcher.new(function(ev)
  if ev == hs.caffeinate.watcher.systemDidWake or ev == hs.caffeinate.watcher.screensDidUnlock then
    hs.timer.doAfter(0.5, poll)
  end
end)
wakeWatcher:start()
