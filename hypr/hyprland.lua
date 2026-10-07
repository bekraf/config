-- Hyprland config, ported from hyprland.conf (hyprlang) for Hyprland 0.56.2.
-- Docs: https://wiki.hypr.land/Configuring/Start/
-- API reference for this exact build: /usr/share/hypr/stubs/hl.meta.lua
--
-- NOTE: while this file exists it is loaded INSTEAD of hyprland.conf, and that
-- choice is made once at startup. To roll back: rename this file and restart.

------------------
---- MONITORS ----
------------------

-- New display who this?
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Home
hl.monitor({ output = "desc:AU Optronics 0x31A6", mode = "1920x1200@60.01", position = "0x0", scale = 1 })
hl.monitor({ output = "desc:Philips Consumer Electronics Company PHL 499P9 AU02440002348", mode = "5120x1440@29.98Hz", position = "-5120x0", scale = 1 })

-- Flex desk next to Humbert
hl.monitor({ output = "desc:LG Electronics LG HDR 4K 0x00079C46", mode = "2560x1440@59.95Hz", position = "1920x0", scale = 1 })
hl.monitor({ output = "desc:LG Electronics LG HDR 4K 0x00079C33", mode = "3840x2160@60.00", position = "4480x0", scale = 1 })

-- Carbonara
hl.monitor({ output = "desc:Dell Inc. DELL P2419HC CPYNJ73", mode = "1920x1080@60.00", position = "-3840x0", scale = 1 })
hl.monitor({ output = "desc:Dell Inc. DELL P2419HC 85ZNJ73", mode = "1920x1080@60.00", position = "-1920x0", scale = 1 })

-- Back to fishbowl?
hl.monitor({ output = "desc:Dell Inc. DELL P2419HC 1WXNJ73", mode = "1920x1080@60.00", position = "1920x0", scale = 1 })
hl.monitor({ output = "desc:Dell Inc. DELL P2419HC 1DQNJ73", mode = "1920x1080@60.00", position = "3840x0", scale = 1 })

-- Desk back to the fish bowl and facing best desk
hl.monitor({ output = "desc:LG Electronics LG HDR 4K 0x000C9D85", mode = "3840x2160@60.00", position = "1920x0", scale = 1 })
hl.monitor({ output = "desc:LG Electronics LG HDR 4K 0x000C9D89", mode = "3840x2160@60.00", position = "5760x0", scale = 1 })


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "terminator"
local fileManager = "nemo"
local menu        = "wofi --show drun"


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- Lua does NOT expand $VARS the way hyprlang did: os.getenv() is required here,
-- otherwise the literal string "$XDG_RUNTIME_DIR/..." gets exported.
local runtimeDir = os.getenv("XDG_RUNTIME_DIR")
if runtimeDir then
    hl.env("SSH_AUTH_SOCK", runtimeDir .. "/ssh-agent.socket")
end

hl.env("XCURSOR_SIZE", "30")
hl.env("HYPRCURSOR_SIZE", "30")

local home = os.getenv("HOME")
if home then
    hl.env("XDG_DATA_DIRS", "/usr/local/share:/usr/share:" .. home .. "/.local/share")
end


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    -- Under a Lua config `hyprctl dispatch` takes a Lua expression, so the old
    -- `hyprctl dispatch dpms off` form no longer works here.
    hl.exec_cmd([[swayidle -w timeout 1800 "hyprctl dispatch 'hl.dsp.dpms({ action = \"off\" })'" resume "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'"]])
end)


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 10,
        gaps_out = 30,

        border_size = 5,

        col = {
            active_border   = { colors = { "rgba(fc4903ee)", "rgba(fca903ee)" } },
            inactive_border = { colors = { "rgba(4f2f00ee)", "rgba(4f3700ee)" }, angle = 45 },
        },

        resize_on_border = false,
        allow_tearing    = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,

            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1.0} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1} } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})


----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 1, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.device({
    name        = "epic-mouse-v1",
    -- sensitivity = -0.5,
    sensitivity = -1,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("nemo"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("claude"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("firefox"))
-- hl.bind(mainMod .. " + Z", hl.dsp.layout("togglesplit")) -- switcheroo
-- hl.bind(mainMod .. " + A", hl.dsp.layout("swapsplit"))   -- switcheroo
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("spotify-launcher"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd('signal-desktop --password-store="gnome-libsecret"'))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("vscodium"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Y", hl.dsp.window.fullscreen_state({ internal = -1, client = 2 })) -- Equivalent to the old fakefullscreen

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9] (silently)
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + C",      hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + L",      hl.dsp.exec_cmd("swaylock -c 89380F --key-hl-color 234990 --line-color 234990 --ring-color f7f9fd  --layout-bg-color f7f9fd  --inside-color 89380F"))

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + S",     hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging.
-- `mouse = true` is kept to match the upstream example, but in 0.56.2 the bind
-- opts parser never reads it (it is a leftover from hyprlang's `bindm`); the
-- mouse behaviour comes from the drag/resize dispatchers themselves.
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"),                           { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"),                           { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Ignore maximize requests from apps.
-- hl.window_rule({
--     name  = "suppress-maximize-events",
--     match = { class = ".*" },
--     suppress_event = "maximize",
-- })

-- Fix some dragging issues with XWayland
-- hl.window_rule({
--     name  = "fix-xwayland-drags",
--     match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
--     no_focus = true,
-- })

-- hl.window_rule({
--     name  = "maximize-firefox-fullscreen",
--     match = { class = "^(firefox)$", fullscreen = true },
--     fullscreen_state = "1 1",
-- })
