-- core/mediator.lua
-- Mediator パターンによる司令塔
-- コマンドの登録、ディスパッチ、エラーハンドリングを担当

local M = {
  handlers = {},
  log = hs.logger.new("mediator", "info")
}

-- コマンドハンドラを登録
-- @param command string コマンド名 (例: "input.ime.flash")
-- @param handler function ハンドラ関数
function M.register(command, handler)
  if type(command) ~= "string" then
    M.log:e("register: command must be string, got " .. type(command))
    hs.alert.show("Mediator: Invalid command type")
    return false
  end
  
  if type(handler) ~= "function" then
    M.log:e("register: handler must be function, got " .. type(handler))
    hs.alert.show("Mediator: Invalid handler type")
    return false
  end
  
  M.handlers[command] = handler
  M.log:d("registered command: " .. command)
  return true
end

-- コマンドをディスパッチ
-- @param command string コマンド名
-- @param payload table ペイロード (nilの場合は空テーブルを使用)
function M.dispatch(command, payload)
  if type(command) ~= "string" then
    M.log:e("dispatch: command must be string, got " .. type(command))
    hs.alert.show("Mediator: Invalid command type")
    return false
  end
  
  local handler = M.handlers[command]
  if not handler then
    M.log:e("dispatch: no handler for command: " .. command)
    hs.alert.show("No handler: " .. command)
    return false
  end
  
  -- payloadが指定されていない場合は空テーブルを使用
  payload = payload or {}
  if type(payload) ~= "table" then
    M.log:e("dispatch: payload must be table, got " .. type(payload))
    hs.alert.show("Mediator: Invalid payload type")
    return false
  end
  
  -- 例外安全でハンドラを実行
  local success, result = xpcall(function()
    return handler(payload)
  end, function(err)
    return debug.traceback("Handler error: " .. tostring(err))
  end)
  
  if not success then
    M.log:e("error in command '" .. command .. "': " .. tostring(result))
    hs.alert.show("Error in: " .. command)
    return false
  end
  
  M.log:d("successfully executed: " .. command)
  return true, result
end

-- 登録されているコマンド一覧を取得
-- @return table コマンド一覧
function M.listCommands()
  local commands = {}
  for cmd, _ in pairs(M.handlers) do
    table.insert(commands, cmd)
  end
  table.sort(commands)
  return commands
end

-- デバッグ用：登録されているコマンドをアラート表示
function M.showCommands()
  local commands = M.listCommands()
  local message = "Registered commands:\n" .. table.concat(commands, "\n")
  hs.alert.show(message, 3)
end

return M