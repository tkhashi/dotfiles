-- repositories/karabiner.lua
-- Karabiner-Elements CLI操作の薄いラッパー

-- luacheck: globals hs

local M = {}
local shell = require("repositories.shell")
local log = hs.logger.new("karabiner", "info")

-- Karabiner CLI のパス
local KARABINER_CLI = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

-- プロファイル定数
M.PROFILES = {
  LAPTOP = "Laptop",
  NAYA = "Naya Create", 
  UHK = "UHK"
}

-- Karabiner CLIの存在確認
-- @return boolean 存在するかどうか
function M.isAvailable()
  return shell.fileExists(KARABINER_CLI)
end

-- プロファイルを選択
-- @param profileName string プロファイル名
-- @param callback function(success) コールバック関数（省略可）
-- @return boolean 同期実行時の成功状態
function M.selectProfile(profileName, callback)
  if type(profileName) ~= "string" then
    log:e("selectProfile: profileName must be string, got " .. type(profileName))
    if callback then callback(false) end
    return false
  end
  
  if not M.isAvailable() then
    local msg = "karabiner_cli not found: " .. KARABINER_CLI
    log:e(msg)
    hs.notify.new({
      title = "Karabiner",
      informativeText = msg
    }):send()
    if callback then callback(false) end
    return false
  end
  
  local command = string.format("%q --select-profile %q", KARABINER_CLI, profileName)
  log:i("selecting profile: " .. profileName)
  
  if callback and type(callback) == "function" then
    -- 非同期実行
    shell.execute(command, function(output, success, exitCode)
      if success then
        log:i("profile selected: " .. profileName)
        hs.alert.show("Karabiner → " .. profileName, 0.8)
      else
        log:e("failed to select profile: " .. profileName .. " (exit: " .. exitCode .. ")")
        hs.alert.show("Karabiner error: " .. profileName)
      end
      callback(success)
    end)
  else
    -- 同期実行
    local output, success, exitCode = shell.execute(command)
    if success then
      log:i("profile selected: " .. profileName)
      hs.alert.show("Karabiner → " .. profileName, 0.8)
    else
      log:e("failed to select profile: " .. profileName .. " (exit: " .. exitCode .. ")")
      hs.alert.show("Karabiner error: " .. profileName)
    end
    return success
  end
end

-- 現在のプロファイルを取得
-- @param callback function(profileName) コールバック関数（省略可）
-- @return string 同期実行時のプロファイル名
function M.getCurrentProfile(callback)
  if not M.isAvailable() then
    log:e("karabiner_cli not available")
    if callback then callback(nil) end
    return nil
  end
  
  local command = string.format("%q --show-current-profile-name", KARABINER_CLI)
  
  if callback and type(callback) == "function" then
    -- 非同期実行
    shell.execute(command, function(output, success, exitCode)
      local profile = success and output:gsub("%s+$", "") or nil
      log:d("current profile: " .. (profile or "unknown"))
      callback(profile)
    end)
  else
    -- 同期実行
    local output, success, exitCode = shell.execute(command)
    local profile = success and output:gsub("%s+$", "") or nil
    log:d("current profile: " .. (profile or "unknown"))
    return profile
  end
end

return M