local wezterm = require 'wezterm'
local act = wezterm.action

local M = {}

M.leader = { key = "t", mods = "CTRL", timeout_milliseconds = 1000 }
M.keys = {
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = '&', mods = 'LEADER|SHIFT', action = act.CloseCurrentTab { confirm = true } },
  { key = 'w', mods = 'LEADER', action = act.ShowTabNavigator },
  { key = ',', mods = 'LEADER', action = act.PromptInputLine {
    description = 'Enter new tab name',
    action = wezterm.action_callback(function(window, pane, line)
      if line then
        window:active_tab():set_title(line)
      end
    end),
  }},
  { key = '1', mods = 'LEADER', action = act.ActivateTab(0) },
  { key = '2', mods = 'LEADER', action = act.ActivateTab(1) },
  { key = '3', mods = 'LEADER', action = act.ActivateTab(2) },
  { key = '4', mods = 'LEADER', action = act.ActivateTab(3) },
  { key = '5', mods = 'LEADER', action = act.ActivateTab(4) },
  { key = '6', mods = 'LEADER', action = act.ActivateTab(5) },
  { key = '7', mods = 'LEADER', action = act.ActivateTab(6) },
  { key = '8', mods = 'LEADER', action = act.ActivateTab(7) },
  { key = '9', mods = 'LEADER', action = act.ActivateTab(8) },

  { key = '%', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '|', mods = 'LEADER|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'o', mods = 'LEADER', action = act.ActivatePaneDirection 'Next' },
  { key = ';', mods = 'LEADER', action = act.ActivatePaneDirection 'Prev' },
  { key = 'LeftArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
  { key = '{', mods = 'LEADER|SHIFT', action = act.RotatePanes 'CounterClockwise' },
  { key = '}', mods = 'LEADER|SHIFT', action = act.RotatePanes 'Clockwise' },
  { key = 'Space', mods = 'LEADER', action = act.RotatePanes 'Clockwise' },

  { key = 'H', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'J', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Down', 5 } },
  { key = 'K', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Up', 5 } },
  { key = 'L', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },

  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
  { key = ']', mods = 'LEADER', action = act.PasteFrom 'Clipboard' },

  { key = '/', mods = 'LEADER', action = act.Search 'CurrentSelectionOrEmptyString' },
  { key = 's', mods = 'LEADER', action = act.QuickSelect },
  { key = 'u', mods = 'LEADER', action = act.QuickSelectArgs {
    label = 'open url',
    patterns = { 'https?://\\S+' },
    action = wezterm.action_callback(function(window, pane)
      local url = window:get_selection_text_for_pane(pane)
      wezterm.open_with(url)
    end),
  }},

  { key = 'd', mods = 'LEADER', action = act.QuitApplication },
  { key = ':', mods = 'LEADER|SHIFT', action = act.ActivateCommandPalette },
  { key = 'r', mods = 'LEADER', action = act.ReloadConfiguration },
  { key = 't', mods = 'LEADER|CTRL', action = act.SendKey { key = 't', mods = 'CTRL' } },
}

M.key_tables = {
  copy_mode = {
    { key = 'h', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
    { key = 'j', mods = 'NONE', action = act.CopyMode 'MoveDown' },
    { key = 'k', mods = 'NONE', action = act.CopyMode 'MoveUp' },
    { key = 'l', mods = 'NONE', action = act.CopyMode 'MoveRight' },
    { key = 'LeftArrow', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
    { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'MoveDown' },
    { key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'MoveUp' },
    { key = 'RightArrow', mods = 'NONE', action = act.CopyMode 'MoveRight' },

    { key = 'w', mods = 'NONE', action = act.CopyMode 'MoveForwardWord' },
    { key = 'b', mods = 'NONE', action = act.CopyMode 'MoveBackwardWord' },
    { key = 'e', mods = 'NONE', action = act.CopyMode 'MoveForwardWordEnd' },

    { key = '0', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLine' },
    { key = '$', mods = 'SHIFT', action = act.CopyMode 'MoveToEndOfLineContent' },
    { key = '^', mods = 'SHIFT', action = act.CopyMode 'MoveToStartOfLineContent' },

    { key = 'g', mods = 'NONE', action = act.CopyMode 'MoveToScrollbackTop' },
    { key = 'G', mods = 'SHIFT', action = act.CopyMode 'MoveToScrollbackBottom' },
    { key = 'u', mods = 'CTRL', action = act.CopyMode 'PageUp' },
    { key = 'd', mods = 'CTRL', action = act.CopyMode 'PageDown' },

    { key = 'v', mods = 'NONE', action = act.CopyMode { SetSelectionMode = 'Cell' } },
    { key = 'V', mods = 'SHIFT', action = act.CopyMode { SetSelectionMode = 'Line' } },
    { key = 'v', mods = 'CTRL', action = act.CopyMode { SetSelectionMode = 'Block' } },

    { key = 'y', mods = 'NONE', action = act.Multiple {
      { CopyTo = 'ClipboardAndPrimarySelection' },
      { CopyMode = 'Close' },
    }},

    { key = 'q', mods = 'NONE', action = act.CopyMode 'Close' },
    { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },

    { key = '/', mods = 'NONE', action = act.Search 'CurrentSelectionOrEmptyString' },
    { key = 'n', mods = 'NONE', action = act.CopyMode 'NextMatch' },
    { key = 'N', mods = 'SHIFT', action = act.CopyMode 'PriorMatch' },
  },
}

function M.apply(config)
  config.leader = M.leader
  config.keys = M.keys
  config.key_tables = M.key_tables
end

return M
