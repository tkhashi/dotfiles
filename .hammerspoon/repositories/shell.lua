-- repositories/shell.lua
-- 汎用シェルコマンド実行の薄いラッパー

local M = {}
local log = hs.logger.new("shell", "info")

-- シェルコマンドを実行
-- @param command string 実行するコマンド
-- @param callback function(output, success, exitCode) コールバック関数（省略可）
-- @return string, boolean, number output, success, exitCode (callbackが指定されていない場合)
function M.execute(command, callback)
  if type(command) ~= "string" then
    log:e("execute: command must be string, got " .. type(command))
    if callback then callback("", false, -1) end
    return "", false, -1
  end
  
  log:d("executing: " .. command)
  
  if callback and type(callback) == "function" then
    -- 非同期実行
    hs.task.new("/bin/sh", function(exitCode, stdOut, stdErr)
      local output = (stdOut or "") .. (stdErr or "")
      local success = exitCode == 0
      log:d("async result: success=" .. tostring(success) .. ", exit=" .. exitCode)
      callback(output, success, exitCode)
    end, {"-c", command}):start()
  else
    -- 同期実行
    local output, success, _, exitCode = hs.execute(command .. " 2>&1")
    log:d("sync result: success=" .. tostring(success) .. ", exit=" .. (exitCode or -1))
    return output or "", success, exitCode or -1
  end
end

-- コマンドの存在確認
-- @param commandName string コマンド名
-- @return boolean 存在するかどうか
function M.commandExists(commandName)
  local output, success = M.execute("which " .. commandName .. " >/dev/null 2>&1")
  return success
end

-- ファイルの存在確認
-- @param path string ファイルパス
-- @return boolean 存在するかどうか
function M.fileExists(path)
  return hs.fs.attributes(path) ~= nil
end

return M