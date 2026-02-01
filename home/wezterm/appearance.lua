local wezterm = require 'wezterm'

local appearance = {}

function appearance.apply(config)
  config.font_dirs = { "@MESLO_FONT_DIR@" }
  config.font = wezterm.font("MesloLGS NF", { weight = "Regular" })
  config.font_size = 13.0
  config.color_scheme = "3024 Night"
  config.font_rasterizer = "FreeType"
  config.freetype_load_target = "Normal"
  config.freetype_render_target = "Normal"
  config.window_background_opacity = 0.8
end

return appearance
