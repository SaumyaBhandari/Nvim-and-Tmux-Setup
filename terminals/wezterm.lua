local wezterm = require("wezterm")

config = wezterm.config_builder()

config = {
	default_cursor_style = "BlinkingBar",
	automatically_reload_config = true,
	window_close_confirmation = "NeverPrompt",
	adjust_window_size_when_changing_font_size = true,
	window_decorations = "RESIZE",
	check_for_updates = false,
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = true,
	font_size = 14,
	font = wezterm.font("Hack Nerd Font", { weight = "Bold" }),
	enable_tab_bar = false,
	window_padding = {
		left = 8,
		right = 8,
		top = 8,
		bottom = 0,
	},
	background = {
		{
			source = {
				File = wezterm.home_dir .. "/.config/nvim/background.jpeg",
			},
			hsb = {
				hue = 1.0,
				saturation = 1.02,
				brightness = 0.15,
			},
			-- attachment = { Parallax = 0.1 },
			width = "100%",
			height = "100%",
		},
		{
			source = {
				Color = "#282c35",
			},
			width = "100%",
			height = "100%",
			opacity = 0.95,
		},
	},
	-- Set default terminal size
	initial_cols = 1000, -- Number of columns
	initial_rows = 660, -- Number of rows

	-- from: https://akos.ma/blog/adopting-wezterm/
	hyperlink_rules = {
		-- Matches: a URL in parens: (URL)
		{
			regex = "\\((\\w+://\\S+)\\)",
			format = "$1",
			highlight = 1,
		},
		-- Matches: a URL in brackets: [URL]
		{
			regex = "\\[(\\w+://\\S+)\\]",
			format = "$1",
			highlight = 1,
		},
		-- Matches: a URL in curly braces: {URL}
		{
			regex = "\\{(\\w+://\\S+)\\}",
			format = "$1",
			highlight = 1,
		},
		-- Matches: a URL in angle brackets: <URL>
		{
			regex = "<(\\w+://\\S+)>",
			format = "$1",
			highlight = 1,
		},
		-- Then handle URLs not wrapped in brackets
		{
			-- Before
			--regex = '\\b\\w+://\\S+[)/a-zA-Z0-9-]+',
			--format = '$0',
			-- After
			regex = "[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)",
			format = "$1",
			highlight = 1,
		},
		-- implicit mailto link
		{
			regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
			format = "mailto:$0",
		},
	},
}

return config
