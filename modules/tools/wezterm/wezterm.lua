-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()


-- color scheme
config.color_scheme = 'Dracula (Official)'

-- font
config.font = wezterm.font 'Hasklig'
config.font_size = 14.5

-- window
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.8


return config
