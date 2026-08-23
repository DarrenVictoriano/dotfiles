-- Keep Omarchy defaults unless the legacy keymap explicitly removes a chord.
local removed_bindings = {
  "ALT + A",
  "ALT + D",
  "ALT + F",
  "ALT + F11",
  "ALT + H",
  "ALT + J",
  "ALT + K",
  "ALT + L",
  "ALT + M",
  "ALT + PRINT",
  "ALT + S",
  "ALT + SHIFT + A",
  "ALT + SHIFT + D",
  "ALT + SHIFT + F",
  "ALT + SHIFT + H",
  "ALT + SHIFT + J",
  "ALT + SHIFT + K",
  "ALT + SHIFT + L",
  "ALT + SHIFT + S",
  "ALT + SHIFT + TAB",
  "ALT + TAB",
  "CTRL + ALT + DELETE",
  "CTRL + F1",
  "CTRL + F2",
  "CTRL + SHIFT + F2",
  "CTRL ALT + TAB",
  "PRINT",
  "SHIFT + F11",
  "SHIFT + PRINT",
  "SHIFT CTRL ALT + TAB",
  "SUPER + A",
  "SUPER + ALT + DOWN",
  "SUPER + ALT + F",
  "SUPER + ALT + G",
  "SUPER + ALT + H",
  "SUPER + ALT + I",
  "SUPER + ALT + J",
  "SUPER + ALT + K",
  "SUPER + ALT + L",
  "SUPER + ALT + LEFT",
  "SUPER + ALT + O",
  "SUPER + ALT + RIGHT",
  "SUPER + ALT + S",
  "SUPER + ALT + SHIFT + F",
  "SUPER + ALT + SHIFT + H",
  "SUPER + ALT + SHIFT + J",
  "SUPER + ALT + SHIFT + K",
  "SUPER + ALT + SHIFT + L",
  "SUPER + ALT + SHIFT + S",
  "SUPER + ALT + SHIFT + semicolon",
  "SUPER + ALT + SHIFT + T",
  "SUPER + ALT + SHIFT + TAB",
  "SUPER + ALT + SPACE",
  "SUPER + ALT + TAB",
  "SUPER + ALT + U",
  "SUPER + ALT + UP",
  "SUPER + ALT + W",
  "SUPER + ALT + mouse_down",
  "SUPER + ALT + mouse_up",
  "SUPER + ALT + semicolon",
  "SUPER + BACKSPACE",
  "SUPER + CTRL + A",
  "SUPER + CTRL + ALT + B",
  "SUPER + CTRL + ALT + T",
  "SUPER + CTRL + B",
  "SUPER + CTRL + E",
  "SUPER + CTRL + L",
  "SUPER + CTRL + LEFT",
  "SUPER + CTRL + RIGHT",
  "SUPER + CTRL + T",
  "SUPER + CTRL + TAB",
  "SUPER + CTRL + V",
  "SUPER + CTRL + W",
  "SUPER + CTRL + mouse:272",
  "SUPER + CTRL + mouse:273",
  "SUPER + D",
  "SUPER + DOWN",
  "SUPER + E",
  "SUPER + ESCAPE",
  "SUPER + F",
  "SUPER + G",
  "SUPER + Home",
  "SUPER + J",
  "SUPER + L",
  "SUPER + LEFT",
  "SUPER + N",
  "SUPER + O",
  "SUPER + P",
  "SUPER + PRINT",
  "SUPER + Q",
  "SUPER + R",
  "SUPER + RETURN",
  "SUPER + RIGHT",
  "SUPER + S",
  "SUPER + SHIFT + 4",
  "SUPER + SHIFT + 5",
  "SUPER + SHIFT + 6",
  "SUPER + SHIFT + 8",
  "SUPER + SHIFT + A",
  "SUPER + SHIFT + ALT + DOWN",
  "SUPER + SHIFT + ALT + LEFT",
  "SUPER + SHIFT + ALT + RIGHT",
  "SUPER + SHIFT + ALT + UP",
  "SUPER + SHIFT + B",
  "SUPER + SHIFT + BACKSPACE",
  "SUPER + SHIFT + C",
  "SUPER + SHIFT + CTRL + SPACE",
  "SUPER + SHIFT + D",
  "SUPER + SHIFT + DOWN",
  "SUPER + SHIFT + E",
  "SUPER + SHIFT + F",
  "SUPER + SHIFT + J",
  "SUPER + SHIFT + LEFT",
  "SUPER + SHIFT + Q",
  "SUPER + SHIFT + RIGHT",
  "SUPER + SHIFT + TAB",
  "SUPER + SHIFT + UP",
  "SUPER + SHIFT + V",
  "SUPER + SHIFT + W",
  "SUPER + SHIFT + code:20",
  "SUPER + SHIFT + code:21",
  "SUPER + SLASH",
  "SUPER + T",
  "SUPER + TAB",
  "SUPER + UP",
  "SUPER + W",
  "SUPER + Y",
  "SUPER + Z",
  "SUPER + code:20",
  "SUPER + code:21",
  "SUPER + mouse:272",
  "SUPER + mouse:273",
  "SUPER + mouse_down",
  "SUPER + mouse_up",
  "SUPER ALT + BRACKETLEFT",
  "SUPER ALT + BRACKETRIGHT",
  "SUPER ALT + EQUAL",
  "SUPER ALT + Home",
  "SUPER ALT + MINUS",
  "SUPER ALT + SLASH",
  "SUPER CTRL + 1",
  "SUPER CTRL + 2",
  "SUPER CTRL + 3",
  "SUPER CTRL + 4",
  "SUPER CTRL + 5",
  "SUPER CTRL + 6",
  "SUPER CTRL + 7",
  "SUPER CTRL + 8",
  "SUPER CTRL + 9",
  "SUPER CTRL + BACKSPACE",
  "SUPER CTRL + C",
  "SUPER CTRL + D",
  "SUPER CTRL + Delete",
  "SUPER CTRL + EQUAL",
  "SUPER CTRL + F",
  "SUPER CTRL + K",
  "SUPER CTRL + MINUS",
  "SUPER CTRL + O",
  "SUPER CTRL + P",
  "SUPER CTRL + PERIOD",
  "SUPER CTRL + PRINT",
  "SUPER CTRL + Q",
  "SUPER CTRL + R ",
  "SUPER CTRL + RETURN",
  "SUPER CTRL + S",
  "SUPER CTRL ALT + D",
  "SUPER CTRL ALT + Delete",
  "SUPER SHIFT + G",
  "SUPER SHIFT + M",
  "SUPER SHIFT + N",
  "SUPER SHIFT + O",
  "SUPER SHIFT + P",
  "SUPER SHIFT + S",
  "SUPER SHIFT + SLASH",
  "SUPER SHIFT + X",
  "SUPER SHIFT + Y",
  "SUPER SHIFT ALT + A",
  "SUPER SHIFT ALT + B",
  "SUPER SHIFT ALT + E",
  "SUPER SHIFT ALT + EQUAL",
  "SUPER SHIFT ALT + G",
  "SUPER SHIFT ALT + M",
  "SUPER SHIFT ALT + MINUS",
  "SUPER SHIFT ALT + X",
  "SUPER SHIFT CTRL + A",
  "SUPER SHIFT CTRL + G",
  "SUPER SHIFT CTRL + MINUS",
  "SUPER SHIFT CTRL + R ",
}

for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  table.insert(removed_bindings, "SUPER + " .. key)
  table.insert(removed_bindings, "SUPER + SHIFT + " .. key)
  table.insert(removed_bindings, "SUPER + SHIFT + ALT + " .. key)
end

for index = 1, 5 do
  table.insert(removed_bindings, "SUPER + ALT + code:" .. tostring(index + 9))
end

for _, keys in ipairs(removed_bindings) do
  hl.unbind(keys)
end

-- Application bindings.
o.bind("SUPER + RETURN", "Terminal", { omarchy = "terminal" })
o.bind("SUPER + E", "File manager", { launch = "nautilus --new-window" })

-- Panels and activity.
o.bind("SUPER + ALT + SHIFT + T", "Activity", { tui = "btop" })
o.bind("SUPER + SHIFT + B", "Bluetooth", "omarchy-shell shell toggle omarchy.bluetooth")
o.bind("SUPER + SHIFT + W", "WiFi", "omarchy-shell shell toggle omarchy.network")
o.bind("SUPER + SHIFT + A", "Audio controls", "omarchy-shell shell toggle omarchy.audio")
o.bind("SUPER + SHIFT + D", "Display", "omarchy-shell shell toggle omarchy.monitor")

-- Omarchy menu.
-- o.bind("SUPER + SHIFT + J", "Omarchy menu", "omarchy-menu toggle")

-- Move/resize windows with SUPER+CTRL and mouse dragging.
o.bind("SUPER + CTRL + mouse:272", "Move window", hl.dsp.window.drag(), { mouse = true })
o.bind("SUPER + CTRL + mouse:273", "Resize window", hl.dsp.window.resize(), { mouse = true })

-- Close windows.
o.bind("SUPER + Q", "Close active window", hl.dsp.window.close())
o.bind("SUPER + SHIFT + Q", "Close all windows", "omarchy-hyprland-window-close-all")

-- Send a CTRL chord without the held SUPER modifier leaking into it.
local function send_shortcut_once(mods, key)
  return function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))
    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
    end, { timeout = 50, type = "oneshot" })
  end
end

-- macOS-like bindings.
o.bind("SUPER + W", "Close window", send_shortcut_once("CTRL", "W"))
o.bind("SUPER + T", "New tab", send_shortcut_once("CTRL", "T"))
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
  o.bind("ALT + SHIFT + " .. key, "Move window to workspace " .. key,
    hl.dsp.window.move({ workspace = tostring(index), follow = false }))
end

-- Swap windows.
for _, binding in ipairs({
  { key = "H", direction = "l", label = "left" },
  { key = "L", direction = "r", label = "right" },
  { key = "K", direction = "u", label = "up" },
  { key = "J", direction = "d", label = "down" },
}) do
  o.bind("ALT + SHIFT + " .. binding.key, "Swap window " .. binding.label,
    hl.dsp.window.swap({ direction = binding.direction }))
end

-- Resize the active window.
for _, binding in ipairs({
  { key = "H", label = "Expand window left", x = -100, y = 0 },
  { key = "L", label = "Shrink window left", x = 100,  y = 0 },
  { key = "K", label = "Shrink window up",   x = 0,    y = -100 },
  { key = "J", label = "Expand window down", x = 0,    y = 100 },
}) do
  o.bind("SUPER + ALT + SHIFT + " .. binding.key, binding.label,
    hl.dsp.window.resize({ x = binding.x, y = binding.y, relative = true }))
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
o.bind("SUPER + ALT + SHIFT + semicolon", "Move active window out of group", hl.dsp.window.move({ out_of_group = true }))

for _, binding in ipairs({
  { key = "H", direction = "l", label = "left" },
  { key = "L", direction = "r", label = "right" },
  { key = "K", direction = "u", label = "top" },
  { key = "J", direction = "d", label = "bottom" },
}) do
  o.bind("SUPER + ALT + " .. binding.key, "Move window to group on " .. binding.label,
    hl.dsp.window.move({ into_group = binding.direction }))
end

o.bind("SUPER + ALT + U", "Next window in group", hl.dsp.group.next())
o.bind("SUPER + ALT + I", "Previous window in group", hl.dsp.group.prev())

-- Scratchpad.
o.bind("SUPER + ALT + S", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
o.bind("SUPER + ALT + SHIFT + S", "Move window to scratchpad",
  hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
