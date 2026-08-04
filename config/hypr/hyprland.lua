-- Hyprland configuration (Lua format, required by Hyprland 0.57+).

hl.monitor({
    output = "eDP-1",
    mode = "2880x1800@120",
    position = "auto",
    scale = 2,
})

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar -c ~/.config/waybar/waybar.conf -s ~/.config/waybar/styles.css")
    -- hl.exec_cmd("$HOME/.config/hypr/scripts/waybar_auto_hide")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("xsettingsd")
    hl.exec_cmd("copyq --start-server")
    hl.exec_cmd("/usr/lib/xfce-polkit/xfce-polkit")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("batsignal -b")
end)

hl.env("XCURSOR_SIZE", "18")
hl.env("GDK_SCALE", "2")
hl.env("QT_STYLE_OVERRIDE", "Breeze")
hl.env("QT_QUICK_CONTROLS_STYLE", "org.kde.desktop")

hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
    general = {
        gaps_in = 5,
        gaps_out = 0,
        border_size = 1,
        col = {
            active_border = "rgba(8a8a8aee)",
            inactive_border = "rgba(595959aa)",
        },
        layout = "dwindle",
        allow_tearing = false,
    },
    decoration = {
        rounding = 10,
        blur = {
            enabled = false,
            size = 3,
            passes = 1,
        },
    },
    animations = {
        enabled = false,
    },
    dwindle = {
        preserve_split = true,
    },
    misc = {
        background_color = "rgb(000000)",
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        vrr = 1,
    },
    xwayland = {
        force_zero_scaling = true,
    },
    gestures = {
        workspace_swipe_invert = false,
    },
})

hl.device({
    name = "snsl0028:00-2c2f:0028-touchpad",
    accel_profile = "adaptive",
    sensitivity = -0.18,
})

hl.curve("myBezier", {
    type = "bezier",
    points = { { 0.05, 0.9 }, { 0.1, 1.05 } },
})

hl.animation({ leaf = "windows", enabled = true, speed = 1, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1, bezier = "default" })

local mainMod = "SUPER"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("alacritty"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

local directions = {
    left = "left",
    right = "right",
    up = "up",
    down = "down",
}

for key, direction in pairs(directions) do
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = direction }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.swap({ direction = direction }))
end

for workspace = 1, 10 do
    local key = workspace % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Grouped / stacked windows.
hl.bind(mainMod .. " + W", hl.dsp.group.toggle())
hl.bind(mainMod .. " + Tab", hl.dsp.group.next())
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.group.prev())
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.move({ into_group = "right" }))
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.move({ into_group = "left" }))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.move({ into_group = "up" }))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.move({ into_group = "down" }))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.window.move({ out_of_group = true }))
hl.bind(mainMod .. " + CTRL + W", hl.dsp.group.lock_active())

local brightnessStep = [[bash -c 'current=$(brightnessctl -c backlight get); maximum=$(brightnessctl -c backlight max); percentage=$(((current * 100 + maximum / 2) / maximum)); target=$((percentage + $1)); ((percentage == 1 && $1 > 0)) && target=10; ((target < 1)) && target=1; brightnessctl -q -c backlight set "${target}%"' --]]

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(brightnessStep .. " 10"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(brightnessStep .. " -10"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +10%"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -10%"))
hl.bind("F12", hl.dsp.exec_cmd("$HOME/Documents/scripts/toggle_waybar.sh"))
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("fuzzel"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("copyq menu"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("brave"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("code"))

hl.window_rule({
    name = "windowrule-1",
    match = { class = "^(xfce-polkit|Xfce-polkit)$" },
    float = true,
    size = { 720, 150 },
    center = true,
    group = "barred",
})

hl.window_rule({
    name = "windowrule-2",
    match = { class = "^(com.github.hluk.copyq)$" },
    float = true,
})

hl.window_rule({
    name = "windowrule-3",
    match = { class = [[^(org\.kde\.kruler)$]] },
    float = true,
    size = { 60, 800 },
})

hl.window_rule({
    name = "bitwarden-browser-extension",
    match = { class = "^brave-nngceckbapebfimnlniiiahkandclblb-.*$" },
    float = true,
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.gesture({
    fingers = 3,
    direction = "down",
    action = function()
        hl.exec_cmd("$HOME/Documents/scripts/show_waybar_temporarily.sh")
    end,
})
