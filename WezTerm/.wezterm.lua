local wezterm = require 'wezterm'
local act = wezterm.action

return {
  default_cwd = "C:/Users/pupod/work",
  default_prog = { 'C:/Program Files/Git/bin/bash.exe', '-i', '-l' },
  color_scheme = 'BlulocoDark',
  font_size = 10.0,
  adjust_window_size_when_changing_font_size = false,
  enable_scroll_bar = true,

  -- Add serach mode
  -- (lastest main branch is default existing search mode. It's scoop installed it no search mode.)
  key_tables = {
    search_mode = {
      { key = 'Enter', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
      { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close'},
      { key = 'n', mods = 'CTRL', action = act.CopyMode 'NextMatch' },
      { key = 'p', mods = 'CTRL', action = act.CopyMode 'PriorMatch' },
      { key = 'r', mods = 'CTRL', action = act.CopyMode 'CycleMatchType' },
      { key = 'u', mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
      {
        key = 'PageUp',
        mods = 'NONE',
        action = act.CopyMode 'PriorMatchPage',
      },
      {
        key = 'PageDown',
        mods = 'NONE',
        action = act.CopyMode 'NextMatchPage',
      },
      { key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
      {
        key = 'DownArrow',
        mods = 'NONE',
        action = act.CopyMode 'NextMatch',
      },
    },
    copy_mode = {
      -- go search mode
      {key="/", mods="NONE", action={ Multiple={
        wezterm.action{CopyMode='ClearPattern'},
        wezterm.action{Search={CaseSensitiveString=""}}
      }}},
      {key="n", mods="NONE", action=wezterm.action{CopyMode="NextMatch"}},
      {key="N", mods="SHIFT", action=wezterm.action{CopyMode="PriorMatch"}},
      {
        key = 'Enter',
        mods = 'NONE',
        action = act.CopyMode 'MoveToStartOfNextLine',
      },
      { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
      {
        key = 'Space',
        mods = 'NONE',
        action = act.CopyMode { SetSelectionMode = 'Cell' },
      },
      {
        key = '$',
        mods = 'NONE',
        action = act.CopyMode 'MoveToEndOfLineContent',
      },
      {
        key = '$',
        mods = 'SHIFT',
        action = act.CopyMode 'MoveToEndOfLineContent',
      },
      { key = ',', mods = 'NONE', action = act.CopyMode 'JumpReverse' },
      {
        key = '0',
        mods = 'NONE',
        action = act.CopyMode 'MoveToStartOfLine',
      },
      { key = ';', mods = 'NONE', action = act.CopyMode 'JumpAgain' },
      {
        key = 'F',
        mods = 'NONE',
        action = act.CopyMode { JumpBackward = { prev_char = false } },
      },
      {
        key = 'F',
        mods = 'SHIFT',
        action = act.CopyMode { JumpBackward = { prev_char = false } },
      },
      {
        key = 'G',
        mods = 'NONE',
        action = act.CopyMode 'MoveToScrollbackBottom',
      },
      {
        key = 'G',
        mods = 'SHIFT',
        action = act.CopyMode 'MoveToScrollbackBottom',
      },
      {
        key = 'H',
        mods = 'NONE',
        action = act.CopyMode 'MoveToViewportTop',
      },
      {
        key = 'H',
        mods = 'SHIFT',
        action = act.CopyMode 'MoveToViewportTop',
      },
      {
        key = 'L',
        mods = 'NONE',
        action = act.CopyMode 'MoveToViewportBottom',
      },
      {
        key = 'L',
        mods = 'SHIFT',
        action = act.CopyMode 'MoveToViewportBottom',
      },
      {
        key = 'M',
        mods = 'NONE',
        action = act.CopyMode 'MoveToViewportMiddle',
      },
      {
        key = 'M',
        mods = 'SHIFT',
        action = act.CopyMode 'MoveToViewportMiddle',
      },
      {
        key = 'O',
        mods = 'NONE',
        action = act.CopyMode 'MoveToSelectionOtherEndHoriz',
      },
      {
        key = 'O',
        mods = 'SHIFT',
        action = act.CopyMode 'MoveToSelectionOtherEndHoriz',
      },
      {
        key = 'T',
        mods = 'NONE',
        action = act.CopyMode { JumpBackward = { prev_char = true } },
      },
      {
        key = 'T',
        mods = 'SHIFT',
        action = act.CopyMode { JumpBackward = { prev_char = true } },
      },
      {
        key = 'V',
        mods = 'NONE',
        action = act.CopyMode { SetSelectionMode = 'Line' },
      },
      {
        key = 'V',
        mods = 'SHIFT',
        action = act.CopyMode { SetSelectionMode = 'Line' },
      },
      {
        key = '^',
        mods = 'NONE',
        action = act.CopyMode 'MoveToStartOfLineContent',
      },
      {
        key = '^',
        mods = 'SHIFT',
        action = act.CopyMode 'MoveToStartOfLineContent',
      },
      { key = 'b', mods = 'NONE', action = act.CopyMode 'MoveBackwardWord' },
      { key = 'b', mods = 'CTRL', action = act.CopyMode 'PageUp' },
      { key = 'c', mods = 'CTRL', action = act.CopyMode 'Close' },
      {
        key = 'f',
        mods = 'NONE',
        action = act.CopyMode { JumpForward = { prev_char = false } },
      },
      { key = 'f', mods = 'CTRL', action = act.CopyMode 'PageDown' },
      { key = 'g', mods = 'CTRL', action = act.CopyMode 'Close' },
      { key = 'h', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
      { key = 'j', mods = 'NONE', action = act.CopyMode 'MoveDown' },
      { key = 'k', mods = 'NONE', action = act.CopyMode 'MoveUp' },
      { key = 'l', mods = 'NONE', action = act.CopyMode 'MoveRight' },
      {
        key = 'o',
        mods = 'NONE',
        action = act.CopyMode 'MoveToSelectionOtherEnd',
      },
      { key = 'q', mods = 'NONE', action = act.CopyMode 'Close' },
      {
        key = 't',
        mods = 'NONE',
        action = act.CopyMode { JumpForward = { prev_char = true } },
      },
      {
        key = 'v',
        mods = 'NONE',
        action = act.CopyMode { SetSelectionMode = 'Cell' },
      },
      {
        key = 'v',
        mods = 'CTRL',
        action = act.CopyMode { SetSelectionMode = 'Block' },
      },
      { key = 'w', mods = 'NONE', action = act.CopyMode 'MoveForwardWord' },
      { key = 'e', mods = 'NONE', action = act.CopyMode 'MoveForwardWord' },
      {
        key = 'y',
        mods = 'NONE',
        action = act.Multiple {
          { CopyTo = 'ClipboardAndPrimarySelection' },
          { CopyMode = 'Close' },
        },
      },
      { key = 'PageUp', mods = 'NONE', action = act.CopyMode 'PageUp' },
      { key = 'PageDown', mods = 'NONE', action = act.CopyMode 'PageDown' },
      { key = 'LeftArrow', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
      {
        key = 'RightArrow',
        mods = 'NONE',
        action = act.CopyMode 'MoveRight',
      },
      { key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'MoveUp' },
      { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'MoveDown' },
    },
  },
}

