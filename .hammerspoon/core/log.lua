-- core/log.lua
-- ログ設定とユーティリティ

-- luacheck: globals hs

local M = {}

-- カテゴリ別ログレベル設定
local logLevels = {
  mediator = "info",
  usb = "info", 
  bt = "info",
  karabiner = "info",
  ime = "debug",
  power = "info"
}

-- ログレベルの設定
-- @param category string カテゴリ名
-- @param level string ログレベル ("verbose", "debug", "info", "warning", "error", "nothing")
function M.setLevel(category, level)
  logLevels[category] = level
  local logger = hs.logger.new(category)
  logger:setLogLevel(level)
end

-- カテゴリ別ロガーを取得
-- @param category string カテゴリ名
-- @return hs.logger ロガーインスタンス
function M.get(category)
  local level = logLevels[category] or "info"
  local logger = hs.logger.new(category, level)
  return logger
end

-- 全ログレベルを初期化
function M.init()
  for category, level in pairs(logLevels) do
    M.setLevel(category, level)
  end
end

return M