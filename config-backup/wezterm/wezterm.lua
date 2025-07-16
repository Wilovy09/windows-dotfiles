local wezterm = require("wezterm")

return {
  font = wezterm.font_with_fallback({ "JetBrains Mono", "FiraCode", "Noto Color Emoji" }),
  font_size = 11.5,
  harfbuzz_features = { "calt", "clig", "liga" },
  window_padding = { left = 5, right = 5, top = 5, bottom = 5 },
  window_background_opacity = 0.90,
  line_height = 1.0,
  enable_tab_bar = true,
  hide_tab_bar_if_only_one_tab = true,
  color_scheme = 'Gruvbox dark, hard (base16)',
  default_prog = { "nu.exe" },
  keys = {
    { key = "Enter", mods = "CTRL|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "\\", mods = "CTRL|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "w", mods = "CTRL", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
  },
}