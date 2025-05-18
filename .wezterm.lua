-- ~/.wezterm.lua
local wezterm = require 'wezterm'

return {
  -- Set the color scheme
  -- color_scheme = 'iTerm2 Tango Dark',

  -- Keybindings
  keys = {
    -- Toggle fullscreen with CMD+Enter
    {
      key = "Enter",
      mods = "CMD",
      action = wezterm.action.ToggleFullScreen,
    },
    -- Disable toggling fullscreen with ALT+Enter (for aider)
    {
      key = "Enter",
      mods = "ALT",
      action = "DisableDefaultAssignment",
    },
    -- Toggle tab bar visibility with CMD+SHIFT+t
    {
      key = "t",
      mods = "CMD|SHIFT",
      action = wezterm.action_callback(function(window, _)
        -- Toggle tab bar visibility
        local overrides = window:get_config_overrides() or {}
        overrides.enable_tab_bar = not overrides.enable_tab_bar
        window:set_config_overrides(overrides)
      end),
    },
    -- For Macs
    {
      key = "3",
      mods = "ALT",
      action = wezterm.action { SendString = "#" },
    },
  },

  -- Optionally enable the tab bar visibility by default
  enable_tab_bar = true, -- Default: true; set to false if you want it hidden
}
