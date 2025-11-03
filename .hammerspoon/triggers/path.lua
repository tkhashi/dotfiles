-- triggers/path.lua
-- 自動リロード機能

-- luacheck: globals hs

local log = hs.logger.new("path", "info")

-- ファイル変更時の処理
local function reloadConfig(files)
  local doReload = false
  for _, file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
      log:i("lua file changed: " .. file)
      break
    end
  end
  
  if doReload then
    log:i("reloading hammerspoon config")
    hs.reload()
  end
end

-- パス監視の開始
local myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
myWatcher:start()

log:i("path watcher started for auto-reload")