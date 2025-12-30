-- ~/.wezterm.lua
local wezterm = require 'wezterm'

-- Track last active pane per tab for pane switching
local last_active_by_tab = {}

-- Event handler to track the last active pane when tabs change
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  if tab.is_active and not last_active_by_tab[tab.tab_id] then
    last_active_by_tab[tab.tab_id] = tab.active_pane.pane_id
  end
end)

-- Event handler for toggling to the last active pane
wezterm.on("activate-last-pane", function(window, pane)
  if pane:tab() then
    local tabid = pane:tab():tab_id()
    local lastpaneid = last_active_by_tab[tabid]
    local curpaneid = pane:pane_id()
    for _, p in pairs(pane:tab():panes()) do
      local paneid = p:pane_id()
      if paneid == lastpaneid then
        p:activate()
        last_active_by_tab[tabid] = curpaneid
      end
    end
  end
end)

return {
  -- Font settings
  -- font = wezterm.font("JetBrains Mono"),
  -- font_size = 12,

  -- Set the color scheme
  -- color_scheme = 'iTerm2 Tango Dark',
  -- color_scheme = 'Gruvbox Dark (Gogh)',

  -- Window settings
  enable_tab_bar = true, -- Show tab bar by default
  window_decorations = "INTEGRATED_BUTTONS|RESIZE", -- Place window controls in tab bar
  window_padding = {
    left = 2,
    right = 2,
    top = 0,
    bottom = 0,
  },

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
    -- Send '#' with ALT+3 (for UK/EU Mac keyboards where # requires ALT)
    {
      key = "3",
      mods = "ALT",
      action = wezterm.action { SendString = "#" },
    },
    -- Pane selection with numbers (tmux-like)
    {
      key = '9',
      mods = 'CTRL',
      action = wezterm.action.PaneSelect {
        alphabet = '1234567890',
      },
    },
    -- Swap panes
    {
      key = '0',
      mods = 'CTRL',
      action = wezterm.action.PaneSelect {
        mode = 'SwapWithActive',
      },
    },
    -- Toggle to last active pane
    {
      key = ';',
      mods = 'CTRL',
      action = wezterm.action { EmitEvent = "activate-last-pane" },
    },
  },
}
