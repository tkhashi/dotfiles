-- repositories/blueutil.lua
-- blueutil CLI操作の薄いラッパー

-- luacheck: globals hs

local M = {}
local shell = require("repositories.shell")
local log = hs.logger.new("blueutil", "info")

-- blueutil のパス候補
local BLUEUTIL_PATHS = {
  "/opt/homebrew/bin/blueutil",
  "/usr/local/bin/blueutil"
}

-- 動的に見つけたblueutil パス
local _blueutil_path = nil

-- 対象デバイス設定
M.TARGET = {
  ADDR = "e7-b6-78-48-3f-a6",
  NAME = "Naya Create"
}

-- blueutil のパスを取得
-- @return string|nil blueutil のパス
local function getBlueutil()
  if _blueutil_path then
    return _blueutil_path
  end
  
  -- 既知のパスから検索
  for _, path in ipairs(BLUEUTIL_PATHS) do
    if shell.fileExists(path) then
      _blueutil_path = path
      log:d("found blueutil at: " .. path)
      return path
    end
  end
  
  -- which コマンドで検索
  local output, success = shell.execute("which blueutil")
  if success and output then
    local path = output:gsub("%s+$", "")
    if path ~= "" and shell.fileExists(path) then
      _blueutil_path = path
      log:d("found blueutil via which: " .. path)
      return path
    end
  end
  
  log:w("blueutil not found")
  return nil
end

-- blueutil の存在確認
-- @return boolean 存在するかどうか
function M.isAvailable()
  return getBlueutil() ~= nil
end

-- MACアドレスを正規化（コロンをダッシュに、小文字に）
-- @param addr string MACアドレス
-- @return string 正規化されたMACアドレス
local function normalizeMacAddr(addr)
  return (addr or ""):lower():gsub(":", "-")
end

-- ペアリング済みデバイス一覧を取得
-- @param callback function(devices) コールバック関数（省略可）
-- @return table 同期実行時のデバイス一覧
function M.getPairedDevices(callback)
  local blueutil = getBlueutil()
  if not blueutil then
    log:e("blueutil not available")
    if callback then callback({}) end
    return {}
  end
  
  local command = string.format("%q --paired --format json", blueutil)
  
  if callback and type(callback) == "function" then
    -- 非同期実行
    shell.execute(command, function(output, success, exitCode)
      local devices = {}
      if success and output and output:match("^%s*%[") then
        local ok, parsed = pcall(hs.json.decode, output)
        if ok and type(parsed) == "table" then
          devices = parsed
        else
          log:e("failed to parse JSON output")
        end
      end
      log:d("found " .. #devices .. " paired devices")
      callback(devices)
    end)
  else
    -- 同期実行
    local output, success, exitCode = shell.execute(command)
    local devices = {}
    if success and output and output:match("^%s*%[") then
      local ok, parsed = pcall(hs.json.decode, output)
      if ok and type(parsed) == "table" then
        devices = parsed
      else
        log:e("failed to parse JSON output")
      end
    end
    log:d("found " .. #devices .. " paired devices")
    return devices
  end
end

-- 特定デバイスの接続状態を確認
-- @param targetAddr string 対象MACアドレス
-- @param callback function(connected) コールバック関数（省略可）
-- @return boolean 同期実行時の接続状態
function M.isDeviceConnected(targetAddr, callback)
  targetAddr = normalizeMacAddr(targetAddr or M.TARGET.ADDR)
  
  if callback and type(callback) == "function" then
    -- 非同期実行
    M.getPairedDevices(function(devices)
      local connected = false
      for _, dev in ipairs(devices) do
        local addr = normalizeMacAddr(dev.address or "")
        if addr == targetAddr then
          connected = (dev.connected == 1 or dev.connected == true)
          break
        end
      end
      log:d("device " .. targetAddr .. " connected: " .. tostring(connected))
      callback(connected)
    end)
  else
    -- 同期実行
    local devices = M.getPairedDevices()
    local connected = false
    for _, dev in ipairs(devices) do
      local addr = normalizeMacAddr(dev.address or "")
      if addr == targetAddr then
        connected = (dev.connected == 1 or dev.connected == true)
        break
      end
    end
    log:d("device " .. targetAddr .. " connected: " .. tostring(connected))
    return connected
  end
end

-- 対象デバイス（Naya Create）の接続状態を確認
-- @param callback function(connected) コールバック関数（省略可）
-- @return boolean 同期実行時の接続状態
function M.isTargetConnected(callback)
  return M.isDeviceConnected(M.TARGET.ADDR, callback)
end

return M