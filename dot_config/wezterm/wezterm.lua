-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()
config.automatically_reload_config = true

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.font_size = 20
config.font = wezterm.font_with_fallback({
	{ family = "Calex Code JP" },
})
config.use_ime = true
config.window_decorations = "RESIZE"

config.window_frame = {
	inactive_titlebar_bg = "none",
	active_titlebar_bg = "none",

	border_left_width = "8px",
	border_right_width = "8px",
	border_top_height = "8px",
	border_bottom_height = "8px",

	border_left_color = "#ec775c",
	border_right_color = "#ec775c",
	border_top_color = "#ec775c",
	border_bottom_color = "#ec775c",

	font_size = 20.0,
	font = wezterm.font({ family = "Calex Code JP", weight = "Bold" }),
}

config.window_background_gradient = {
	colors = { "#1F2428" },
}

config.window_background_opacity = 0.7
config.macos_window_background_blur = 10

config.show_new_tab_button_in_tab_bar = false

-- only for nightly builds
config.show_close_tab_button_in_tabs = false

-- Load theme
local theme = require("themes.github-dark")
config.colors = theme

-- Tab bar configuration
config.colors.tab_bar = {
	inactive_tab_edge = "none",
}

local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_left_half_circle_thick
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_right_half_circle_thick

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = "#22272e"
	local foreground = "#e1e4e8"
	local edge_background = "none"

	if tab.is_active then
		background = "#ec775c"
		foreground = "#e1e4e8"
	end

	local edge_foreground = background

	-- Get tab index
	local tab_index = 0
	for i, t in ipairs(tabs) do
		if t.tab_id == tab.tab_id then
			tab_index = i
			break
		end
	end

	-- Set tab title (use tab title if set, otherwise use tab index)
	local title = ""
	if tab.tab_title and tab.tab_title ~= "" then
		title = "  " .. wezterm.truncate_right(tab.tab_title, max_width - 1) .. "  "
	else
		title = "  " .. tostring(tab_index) .. "  "
	end

	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

wezterm.on("gui-startup", function()
	local screen = wezterm.gui.screens().main
	local ratio = 0.7

	local width = screen.width * ratio
	local height = screen.height * ratio

	local x = (screen.width - width) / 2
	local y = (screen.height - height) / 2

	local gui_window = window:gui_window()

	if gui_window then
		gui_window:set_inner_size(width, height)
		gui_window:set_position(x, y)
	end
end)

-- Key bindings for tab title editing
config.keys = {
	{
		key = "e",
		mods = "CMD",
		action = wezterm.action.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Text = "Tab title:" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					-- Set tab title
					local tab = window:mux_window():active_tab()
					tab:set_title(line)
				end
			end),
		}),
	},
}

-- and finally, return the configuration to wezterm
return config
