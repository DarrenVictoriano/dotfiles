-- App placement rules.

-- Nautilus
o.window("org.gnome.Nautilus", {
  float = true,
  center = true,
  size = { 1300, 900 },
})

-- mpv
o.window("mpv", {
  tag = "-floating-window",
  float = true,
  center = true,
  size = { 1300, 900 },
})

-- Workspace A
o.window("^steam_app_.*", { workspace = "1" })

-- Workspace S
o.window("steam", { workspace = "2", tile = true })
o.window("vesktop", { workspace = "2" })
o.window("chrome-discord.com__channels_@me-Default", { workspace = "2" })
o.window("chrome-www.facebook.com__messages_-Default", { workspace = "2" })
o.window("chrome-mail.google.com__mail_u_0_-Default", { workspace = "2" })

-- Workspace D
o.window("com.mitchellh.ghostty", { workspace = "3" })
o.window("chrome-chatgpt.com__-Default", { workspace = "3" })

-- Workspace F
o.window("chromium", { workspace = "4" })
