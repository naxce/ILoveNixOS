-- Dachshund variant of looknfeel.lua. Not required by hyprland.lua yet --
-- once the switcher exists, swapping the `require("looknfeel")` line (or
-- overwriting looknfeel.lua) will make this active.

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 2,

        col = {
            active_border   = "rgb(c9702f)",
            inactive_border = "rgb(3d2418)",
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.94,

        shadow = {
            enabled      = true,
            range        = 18,
            render_power = 3,
            color        = "rgba(0a060390)",
            offset       = { 0, 4 },
        },

        blur = {
            enabled          = true,
            size             = 6,
            passes           = 3,
            new_optimizations = true,
            ignore_opacity   = true,
            xray             = false,
            contrast         = 1.0,
            brightness       = 0.9,
            noise            = 0.02,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
        smart_resizing = true,
        force_split    = 2,
    },

    master = {
        new_status = "master",
        mfact      = 0.55,
    },

    misc = {
        disable_hyprland_logo       = true,
        disable_splash_rendering    = true,
        force_default_wallpaper     = 0,
        background_color            = "rgb(1c120c)",
        animate_manual_resizes      = true,
        animate_mouse_windowdragging = true,
        enable_swallow              = false,
        focus_on_activate           = true,
        vrr                         = 1,
        key_press_enables_dpms      = true,
        mouse_move_enables_dpms     = true,
    },

    cursor = {
        no_hardware_cursors = true,
        inactive_timeout    = 0,
    },
})

hl.curve("expo",     { type = "bezier", points = { { 0.16, 1 },   { 0.3, 1 }    } })
hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("linear",   { type = "bezier", points = { { 0, 0 },      { 1, 1 }      } })

hl.animation({ leaf = "windows",          enabled = true, speed = 3, bezier = "expo",   style = "popin 82%" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 3, bezier = "expo",   style = "popin 82%" })
hl.animation({ leaf = "border",           enabled = true, speed = 6, bezier = "linear" })
hl.animation({ leaf = "fade",             enabled = true, speed = 3, bezier = "expo" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 4, bezier = "expo",   style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "expo",   style = "slidevert" })
hl.animation({ leaf = "layers",           enabled = true, speed = 3, bezier = "expo",   style = "popin 80%" })
