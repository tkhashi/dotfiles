local wezterm = require("wezterm")
local act = wezterm.action

--STATUS BAR --------------------------------------------------------
local HEADER_HOST = { Foreground = { Color = "#75b1a9" }, Text = "" }
local HEADER_CWD = { Foreground = { Color = "#92aac7" }, Text = "" }
local HEADER_DATE = { Foreground = { Color = "#ffccac" }, Text = "" }
local HEADER_TIME = { Foreground = { Color = "#bcbabe" }, Text = "" }
local HEADER_BATTERY = { Foreground = { Color = "#dfe166" }, Text = "" }
local DEFAULT_FG = { Color = "#9a9eab" }
local DEFAULT_BG = { Color = "#333333" }
local SPACE_1 = " "
local SPACE_3 = "   "
local function AddElement(elems, header, str)
	table.insert(elems, { Foreground = header.Foreground })
	table.insert(elems, { Background = DEFAULT_BG })
	table.insert(elems, { Text = header.Text .. SPACE_1 })

	table.insert(elems, { Foreground = DEFAULT_FG })
	table.insert(elems, { Background = DEFAULT_BG })
	table.insert(elems, { Text = str .. SPACE_3 })
end

local function GetHostAndCwd(elems, pane)
	local uri = pane:get_current_working_dir()

	if not uri then
		return
	end

	local cwd_uri = uri:sub(8)
	local slash = cwd_uri:find("/")

	if not slash then
		return
	end

	local host = cwd_uri:sub(1, slash - 1)
	local dot = host:find("[.]")

	AddElement(elems, HEADER_HOST, dot and host:sub(1, dot - 1) or host)
	AddElement(elems, HEADER_CWD, cwd_uri:sub(slash))
end

local function GetDate(elems)
	AddElement(elems, HEADER_DATE, wezterm.strftime("%a %b %-d"))
end

local function GetTime(elems)
	AddElement(elems, HEADER_TIME, wezterm.strftime("%H:%M"))
end

local function GetBattery(elems, window)
	if not window:get_dimensions().is_full_screen then
		return
	end

	for _, b in ipairs(wezterm.battery_info()) do
		AddElement(elems, HEADER_BATTERY, string.format("%.0f%%", b.state_of_charge * 100))
	end
end

local function RightUpdate(window, pane)
	local elems = {}
	GetHostAndCwd(elems, pane)
	GetDate(elems)
	GetBattery(elems, window)
	GetTime(elems)
	window:set_right_status(wezterm.format(elems))
end

wezterm.on("update-status", function(window, pane)
	RightUpdate(window, pane)
end)
----------------------------------------------------------

local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.default_cwd = "C:/Users/pupod/work"
config.window_background_opacity = 0.9
-- config.default_prog = { 'C:/Program Files/Git/bin/bash.exe', '-i', '-l' }
config.window_close_confirmation = "NeverPrompt"
config.cursor_blink_rate = 800
config.color_scheme = "BlulocoDark"
config.default_cursor_style = "BlinkingBar"
config.font_size = 10.0
config.adjust_window_size_when_changing_font_size = false
config.enable_scroll_bar = true
config.window_decorations = "RESIZE"
config.key_tables = {
	search_mode = {
		{ key = "Enter", mods = "NONE", action = act.CopyMode("PriorMatch") },
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
		{ key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
		{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
		{ key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
		{
			key = "PageUp",
			mods = "NONE",
			action = act.CopyMode("PriorMatchPage"),
		},
		{
			key = "PageDown",
			mods = "NONE",
			action = act.CopyMode("NextMatchPage"),
		},
		{ key = "UpArrow", mods = "NONE", action = act.CopyMode("PriorMatch") },
		{
			key = "DownArrow",
			mods = "NONE",
			action = act.CopyMode("NextMatch"),
		},
	},
	copy_mode = {
		-- go search mode
		{
			key = "/",
			mods = "NONE",
			action = {
				Multiple = {
					wezterm.action({ CopyMode = "ClearPattern" }),
					wezterm.action({ Search = { CaseSensitiveString = "" } }),
				},
			},
		},
		{ key = "n", mods = "NONE", action = wezterm.action({ CopyMode = "NextMatch" }) },
		{ key = "N", mods = "SHIFT", action = wezterm.action({ CopyMode = "PriorMatch" }) },
		{
			key = "Enter",
			mods = "NONE",
			action = act.CopyMode("MoveToStartOfNextLine"),
		},
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{
			key = "Space",
			mods = "NONE",
			action = act.CopyMode({ SetSelectionMode = "Cell" }),
		},
		{
			key = "$",
			mods = "NONE",
			action = act.CopyMode("MoveToEndOfLineContent"),
		},
		{
			key = "$",
			mods = "SHIFT",
			action = act.CopyMode("MoveToEndOfLineContent"),
		},
		{ key = ",", mods = "NONE", action = act.CopyMode("JumpReverse") },
		{
			key = "0",
			mods = "NONE",
			action = act.CopyMode("MoveToStartOfLine"),
		},
		{ key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
		{
			key = "F",
			mods = "NONE",
			action = act.CopyMode({ JumpBackward = { prev_char = false } }),
		},
		{
			key = "F",
			mods = "SHIFT",
			action = act.CopyMode({ JumpBackward = { prev_char = false } }),
		},
		{
			key = "G",
			mods = "NONE",
			action = act.CopyMode("MoveToScrollbackBottom"),
		},
		{
			key = "G",
			mods = "SHIFT",
			action = act.CopyMode("MoveToScrollbackBottom"),
		},
		{
			key = "H",
			mods = "NONE",
			action = act.CopyMode("MoveToViewportTop"),
		},
		{
			key = "H",
			mods = "SHIFT",
			action = act.CopyMode("MoveToViewportTop"),
		},
		{
			key = "L",
			mods = "NONE",
			action = act.CopyMode("MoveToViewportBottom"),
		},
		{
			key = "L",
			mods = "SHIFT",
			action = act.CopyMode("MoveToViewportBottom"),
		},
		{
			key = "M",
			mods = "NONE",
			action = act.CopyMode("MoveToViewportMiddle"),
		},
		{
			key = "M",
			mods = "SHIFT",
			action = act.CopyMode("MoveToViewportMiddle"),
		},
		{
			key = "O",
			mods = "NONE",
			action = act.CopyMode("MoveToSelectionOtherEndHoriz"),
		},
		{
			key = "O",
			mods = "SHIFT",
			action = act.CopyMode("MoveToSelectionOtherEndHoriz"),
		},
		{
			key = "T",
			mods = "NONE",
			action = act.CopyMode({ JumpBackward = { prev_char = true } }),
		},
		{
			key = "T",
			mods = "SHIFT",
			action = act.CopyMode({ JumpBackward = { prev_char = true } }),
		},
		{
			key = "V",
			mods = "NONE",
			action = act.CopyMode({ SetSelectionMode = "Line" }),
		},
		{
			key = "V",
			mods = "SHIFT",
			action = act.CopyMode({ SetSelectionMode = "Line" }),
		},
		{
			key = "^",
			mods = "NONE",
			action = act.CopyMode("MoveToStartOfLineContent"),
		},
		{
			key = "^",
			mods = "SHIFT",
			action = act.CopyMode("MoveToStartOfLineContent"),
		},
		{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
		{ key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
		{ key = "c", mods = "CTRL", action = act.CopyMode("Close") },
		{
			key = "f",
			mods = "NONE",
			action = act.CopyMode({ JumpForward = { prev_char = false } }),
		},
		{ key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
		{ key = "g", mods = "CTRL", action = act.CopyMode("Close") },
		{ key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
		{
			key = "o",
			mods = "NONE",
			action = act.CopyMode("MoveToSelectionOtherEnd"),
		},
		{ key = "q", mods = "NONE", action = act.CopyMode("Close") },
		{
			key = "t",
			mods = "NONE",
			action = act.CopyMode({ JumpForward = { prev_char = true } }),
		},
		{
			key = "v",
			mods = "NONE",
			action = act.CopyMode({ SetSelectionMode = "Cell" }),
		},
		{
			key = "v",
			mods = "CTRL",
			action = act.CopyMode({ SetSelectionMode = "Block" }),
		},
		{ key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
		{ key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
		{
			key = "y",
			mods = "NONE",
			action = act.Multiple({
				{ CopyTo = "ClipboardAndPrimarySelection" },
				{ CopyMode = "Close" },
			}),
		},
		{ key = "PageUp", mods = "NONE", action = act.CopyMode("PageUp") },
		{ key = "PageDown", mods = "NONE", action = act.CopyMode("PageDown") },
		{ key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{
			key = "RightArrow",
			mods = "NONE",
			action = act.CopyMode("MoveRight"),
		},
		{ key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
	},
}

return config
