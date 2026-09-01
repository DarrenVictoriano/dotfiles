-- This file owns the complete keymap. Omarchy supplies commands and helpers,
-- but its default binding modules are disabled in hyprland.lua.

-- Redeclared from default/hypr/bindings/clipboard.lua.
-- Send a CTRL chord without the held SUPER modifier leaking into it.
local function send_shortcut_once(mods, key)
	return function()
		hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))
		hl.timer(function()
			hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
		end, { timeout = 50, type = "oneshot" })
	end
end

local function active_window_is_terminal()
	local window = hl.get_active_window()
	if not window then
		return false
	end

	local tags = window.tags
	if type(tags) == "string" then
		return tags:gsub("%*$", "") == "terminal"
	end

	for _, tag in ipairs(tags) do
		if tag:gsub("%*$", "") == "terminal" then
			return true
		end
	end

	return false
end

local function universal_clipboard_shortcut(default_mods, default_key, terminal_mods, terminal_key)
	return function()
		if active_window_is_terminal() then
			send_shortcut_once(terminal_mods, terminal_key)()
		else
			send_shortcut_once(default_mods, default_key)()
		end
	end
end

-- Redeclared from default/hypr/bindings/utilities.lua.
-- o.bind("SUPER + SHIFT + J", "Apps menu", "omarchy-menu toggle apps")
o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle")
o.bind("SUPER + K", "Keybindings", "omarchy-menu-keybindings")

-- Redeclared from default/hypr/bindings/clipboard.lua.
o.bind("SUPER + C", "Universal copy", universal_clipboard_shortcut("CTRL", "C", "CTRL", "Insert"))
o.bind("SUPER + V", "Universal paste", universal_clipboard_shortcut("CTRL", "V", "SHIFT", "Insert"))
o.bind("SUPER + X", "Universal cut", send_shortcut_once("CTRL", "X"))

-- Redeclared from default/hypr/bindings/applications.lua.
o.bind("SUPER + ALT + RETURN", "Tmux", { omarchy = "terminal-tmux" })

-- Redeclared from default/hypr/bindings/utilities.lua.
o.bind("SUPER + comma", "Dismiss last notification", "omarchy-shell notifications dismissOne")
o.bind("SUPER + SHIFT + comma", "Dismiss all notifications", "omarchy-shell notifications dismissAll")
o.bind_toggle("SUPER + CTRL + comma", "Toggle silencing notifications", "notification-silencing")
o.bind("SUPER + ALT + comma", "Invoke last notification", "omarchy-shell notifications invokeLast")
o.bind("SUPER + SHIFT + ALT + comma", "Open notification history", "omarchy-shell notifications showHistory")

o.bind_toggle("SUPER + SHIFT + SPACE", "Toggle top bar", "bar")
o.bind_toggle("SUPER + CTRL + I", "Toggle locking on idle", "idle")
o.bind_toggle("SUPER + CTRL + N", "Toggle nightlight", "nightlight")
o.bind("SUPER + CTRL + H", "Hardware menu", "omarchy-menu toggle hardware")
o.bind("SUPER + CTRL + SPACE", "Background switcher", "omarchy-menu toggle background")
o.bind("SUPER + CTRL + ALT + R", "Show reminders", "omarchy-reminder show")
o.bind("SUPER + CTRL + ALT + W", "Toggle weather", "omarchy-notification-weather")

o.bind("SUPER + CTRL + Z", "Zoom in", function()
	local zoom = hl.get_config("cursor.zoom_factor") or 1
	hl.config({ cursor = { zoom_factor = zoom + 1 } })
end)
o.bind("SUPER + CTRL + ALT + Z", "Reset zoom", function()
	hl.config({ cursor = { zoom_factor = 1 } })
end)

-- Redeclared from default/hypr/bindings/media.lua.
o.bind("XF86AudioRaiseVolume", "Volume up", "omarchy-audio-output-volume raise", { locked = true, repeating = true })
o.bind("XF86AudioLowerVolume", "Volume down", "omarchy-audio-output-volume lower", { locked = true, repeating = true })
o.bind("XF86AudioMute", "Mute", "omarchy-audio-output-volume mute-toggle", { locked = true })
o.bind("XF86AudioMicMute", "Mute microphone", "omarchy-audio-input-mute", { locked = true })
o.bind("XF86MonBrightnessUp", "Brightness up", "omarchy-brightness-display +5%", { locked = true, repeating = true })
o.bind(
	"XF86MonBrightnessDown",
	"Brightness down",
	"omarchy-brightness-display 5%-",
	{ locked = true, repeating = true }
)
o.bind(
	"XF86KbdBrightnessUp",
	"Keyboard brightness up",
	"omarchy-brightness-keyboard up",
	{ locked = true, repeating = true }
)
o.bind(
	"XF86KbdBrightnessDown",
	"Keyboard brightness down",
	"omarchy-brightness-keyboard down",
	{ locked = true, repeating = true }
)
o.bind("XF86KbdLightOnOff", "Keyboard backlight cycle", "omarchy-brightness-keyboard cycle", { locked = true })
o.bind_toggle("XF86TouchpadToggle", "Toggle touchpad", "touchpad", { locked = true })
o.bind("XF86TouchpadOn", "Enable touchpad", "omarchy-toggle-touchpad on", { locked = true })
o.bind("XF86TouchpadOff", "Disable touchpad", "omarchy-toggle-touchpad off", { locked = true })
o.bind("XF86AudioNext", "Next track", "omarchy-shell media next", { locked = true })
o.bind("XF86AudioPause", "Pause", "omarchy-shell media playPause", { locked = true })
o.bind("XF86AudioPlay", "Play", "omarchy-shell media playPause", { locked = true })
o.bind("XF86AudioPrev", "Previous track", "omarchy-shell media previous", { locked = true })
o.bind("XF86Eject", "Eject media", "eject", { locked = true })

-- Redeclared from default/hypr/bindings/utilities.lua.
o.bind("XF86Calculator", "Calculator", "omacalc")
o.bind("XF86PowerOff", "Power menu", "omarchy-menu toggle system", { locked = true })

-- Preserve system behavior from default/hypr/bindings/utilities.lua.
o.bind("switch:on:Lid Switch", nil, "omarchy-system-lid-close", { locked = true })
o.bind("switch:off:Lid Switch", nil, "omarchy-hyprland-monitor-clamshell", { locked = true })

local selection_layers = 0
local selection_binds = {}

hl.on("layer.opened", function(layer)
	if layer.namespace == "selection" then
		selection_layers = selection_layers + 1
		if selection_layers == 1 then
			selection_binds = {
				hl.bind(
					"RETURN",
					hl.dsp.exec_cmd("omarchy-capture-region --take-window"),
					{ description = "Capture highlighted window" }
				),
				hl.bind(
					"CTRL + RETURN",
					hl.dsp.exec_cmd("omarchy-capture-region --take-fullscreen"),
					{ description = "Capture entire screen" }
				),
				hl.bind(
					"TAB",
					hl.dsp.exec_cmd("omarchy-capture-region --select-window next"),
					{ description = "Select next window to capture" }
				),
				hl.bind(
					"CTRL + TAB",
					hl.dsp.exec_cmd("omarchy-capture-region --select-window prev"),
					{ description = "Select previous window to capture" }
				),
			}
			for _, direction in ipairs({ "left", "right", "up", "down" }) do
				table.insert(
					selection_binds,
					hl.bind(
						direction:upper(),
						hl.dsp.exec_cmd("omarchy-capture-region --select-window " .. direction),
						{ description = "Select window to capture" }
					)
				)
			end
		end
	end
end)

hl.on("layer.closed", function(layer)
	if layer.namespace == "selection" and selection_layers > 0 then
		selection_layers = selection_layers - 1
		if selection_layers == 0 then
			for _, keybind in ipairs(selection_binds) do
				keybind:unbind()
			end
			selection_binds = {}
		end
	end
end)

-- Application bindings.
o.bind("SUPER + RETURN", "Terminal", { omarchy = "terminal" })
o.bind("SUPER + E", "File manager", { launch = "nautilus --new-window" })

-- Panels and activity.
o.bind("SUPER + ALT + SHIFT + T", "Activity", { tui = "btop" })
o.bind("SUPER + SHIFT + B", "Bluetooth", "omarchy-shell shell toggle omarchy.bluetooth")
o.bind("SUPER + SHIFT + W", "WiFi", "omarchy-shell shell toggle omarchy.network")
o.bind("SUPER + SHIFT + A", "Audio controls", "omarchy-shell shell toggle omarchy.audio")
o.bind("SUPER + SHIFT + D", "Display", "omarchy-shell shell toggle omarchy.monitor")
o.bind("SUPER + SHIFT + C", "Codex Usage", "omarchy-shell shell toggle omarchy.agents")

-- Omarchy menu.
-- o.bind("SUPER + SHIFT + J", "Omarchy menu", "omarchy-menu toggle")

-- Move/resize windows with SUPER+CTRL and mouse dragging.
o.bind("SUPER + CTRL + mouse:272", "Move window", hl.dsp.window.drag(), { mouse = true })
o.bind("SUPER + CTRL + mouse:273", "Resize window", hl.dsp.window.resize(), { mouse = true })

-- Close windows.
o.bind("SUPER + Q", "Close active window", hl.dsp.window.close())
o.bind("SUPER + SHIFT + Q", "Close all windows", "omarchy-hyprland-window-close-all")

-- macOS-like bindings.
o.bind("SUPER + W", "Close window", send_shortcut_once("CTRL", "W"))
o.bind("SUPER + T", "New tab", send_shortcut_once("CTRL", "T"))
o.bind("SUPER + SHIFT + T", "Open previously closed tab", send_shortcut_once("CTRL + SHIFT", "T"))
o.bind("SUPER + N", "New window", send_shortcut_once("CTRL", "N"))
o.bind("SUPER + A", "Select all", send_shortcut_once("CTRL", "A"))
o.bind("SUPER + F", "Find", send_shortcut_once("CTRL", "F"))
o.bind("SUPER + Z", "Undo", send_shortcut_once("CTRL", "Z"))
o.bind("SUPER + Y", "Redo", send_shortcut_once("CTRL", "Y"))
o.bind("SUPER + R", "Reload", send_shortcut_once("CTRL", "R"))
o.bind("SUPER + S", "Save", send_shortcut_once("CTRL", "S"))
o.bind("SUPER + D", "Bookmark", send_shortcut_once("CTRL", "D"))
o.bind("SUPER + mouse:272", "Open in new tab", "hyprctl dispatch sendshortcut CTRL mouse:272 active", { mouse = true })
o.bind("SUPER + SHIFT + V", "Clipboard manager", "omarchy-shell shell toggle omarchy.clipboard")
o.bind("SUPER + SHIFT + E", "Emoji picker", "omarchy-shell shell toggle omarchy.emojis")

-- Window layout controls.
o.bind("SUPER + ALT + SHIFT + F", "Toggle pseudo window", hl.dsp.window.pseudo())
o.bind("ALT + M", "Toggle split", hl.dsp.layout("togglesplit"))
o.bind("ALT + COMMA", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")
o.bind("SUPER + ALT + F", "Pop window out (float & pin)", "omarchy-hyprland-window-pop")
o.bind("SUPER + ALT + O", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
o.bind("SUPER + ALT + W", "Full width", hl.dsp.window.fullscreen({ mode = "maximized" }))
-- o.bind("SUPER + ALT + W", "Tiled full screen", "omarchy-hyprland-window-tiled-fullscreen-toggle")

-- Focus movement.
-- o.bind("ALT + H", "Move focus left", "~/.config/hypr/helpers/smart-move-focus l")
-- o.bind("ALT + L", "Move focus right", "~/.config/hypr/helpers/smart-move-focus r")
-- o.bind("ALT + K", "Move focus up", "~/.config/hypr/helpers/smart-move-focus u")
-- o.bind("ALT + J", "Move focus down", "~/.config/hypr/helpers/smart-move-focus d")
o.bind("ALT + H", "Move focus left", hl.dsp.focus({ direction = "l" }))
o.bind("ALT + L", "Move focus right", hl.dsp.focus({ direction = "r" }))
o.bind("ALT + K", "Move focus up", hl.dsp.focus({ direction = "u" }))
o.bind("ALT + J", "Move focus down", hl.dsp.focus({ direction = "d" }))

-- Workspace movement.
for index, key in ipairs({ "A", "S", "D", "F" }) do
	o.bind("ALT + " .. key, "Switch to workspace " .. key, hl.dsp.focus({ workspace = tostring(index) }))
	o.bind(
		"ALT + SHIFT + " .. key,
		"Move window to workspace " .. key,
		hl.dsp.window.move({ workspace = tostring(index), follow = false })
	)
end

-- Swap windows.
for _, binding in ipairs({
	{ key = "H", direction = "l", label = "left" },
	{ key = "L", direction = "r", label = "right" },
	{ key = "K", direction = "u", label = "up" },
	{ key = "J", direction = "d", label = "down" },
}) do
	o.bind(
		"ALT + SHIFT + " .. binding.key,
		"Swap window " .. binding.label,
		hl.dsp.window.swap({ direction = binding.direction })
	)
end

-- Resize the active window.
for _, binding in ipairs({
	{ key = "H", label = "Expand window left", x = -100, y = 0 },
	{ key = "L", label = "Shrink window left", x = 100, y = 0 },
	{ key = "K", label = "Shrink window up", x = 0, y = -100 },
	{ key = "J", label = "Expand window down", x = 0, y = 100 },
}) do
	o.bind(
		"SUPER + ALT + SHIFT + " .. binding.key,
		binding.label,
		hl.dsp.window.resize({ x = binding.x, y = binding.y, relative = true })
	)
end

-- Capture controls.
o.bind("SUPER + SHIFT + 4", "Screenshot", "omarchy-capture-screenshot")
o.bind("SUPER + SHIFT + 5", "Screenshot (Fullscreen)", "omarchy-capture-screenshot fullscreen")
o.bind("SUPER + SHIFT + 6", "Screen recording", "omarchy-menu toggle trigger.capture.screenrecord")
o.bind("SUPER + SHIFT + 8", "Color picking", "pkill hyprpicker || hyprpicker -a")

-- Window transparency.
o.bind("SUPER + SHIFT + BACKSPACE", "Toggle window transparency", "omarchy-hyprland-window-transparency-toggle")

-- Window groups.
o.bind("SUPER + ALT + semicolon", "Toggle window grouping", hl.dsp.group.toggle())
o.bind(
	"SUPER + ALT + SHIFT + semicolon",
	"Move active window out of group",
	hl.dsp.window.move({ out_of_group = true })
)

for _, binding in ipairs({
	{ key = "H", direction = "l", label = "left" },
	{ key = "L", direction = "r", label = "right" },
	{ key = "K", direction = "u", label = "top" },
	{ key = "J", direction = "d", label = "bottom" },
}) do
	o.bind(
		"SUPER + ALT + " .. binding.key,
		"Move window to group on " .. binding.label,
		hl.dsp.window.move({ into_group = binding.direction })
	)
end

o.bind("SUPER + ALT + U", "Next window in group", hl.dsp.group.next())
o.bind("SUPER + ALT + I", "Previous window in group", hl.dsp.group.prev())

-- Scratchpad.
o.bind("SUPER + ALT + S", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
o.bind(
	"SUPER + ALT + SHIFT + S",
	"Move window to scratchpad",
	hl.dsp.window.move({ workspace = "special:scratchpad", follow = false })
)
