for _, class in ipairs({
    "pavucontrol",
    "nm-connection-editor",
    "blueman-manager",
    "org.gnome.Calculator",
    "xdg-desktop-portal-gtk",
    "zenity",
    "swappy",
}) do
    hl.window_rule({
        name  = "float-" .. class,
        match = { class = class },
        float = true,
    })
end

hl.window_rule({
    name     = "hotkeys-menu",
    match    = { class = "hotkeys-menu" },
    float    = true,
    size     = "55% 70%",
    center   = true,
    opacity  = "0.96 0.9",
    rounding = 10,
})

hl.window_rule({
    name  = "picture-in-picture",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin   = true,
    size  = "25% 25%",
    move  = "73% 71%",
})

hl.window_rule({
    name    = "no-anim-minimized",
    match   = { workspace = "special:minimized" },
    no_anim = true,
})

hl.window_rule({
    name    = "opacity-kitty",
    match   = { class = "kitty" },
    opacity = "0.94 0.88",
})

hl.window_rule({
    name     = "opacity-yazi",
    match    = { class = "yazi-fm" },
    opacity  = "0.94 0.88",
    rounding = 10,
})

hl.window_rule({
    name    = "opacity-firefox",
    match   = { class = "firefox" },
    opacity = "0.97 0.9",
})

hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name    = "gamescope-monitor",
    match   = { class = "gamescope" },
    monitor = "DP-6",
})

hl.layer_rule({
    name         = "sylvaris_cc",
    match        = { namespace = "sylvaris-cc" },
    blur         = true,
    ignore_alpha = 0.3,
    animation    = "popin 80%",
})

hl.layer_rule({
    name    = "sylvaris_tp",
    match   = { namespace = "sylvaris-tp" },
    no_anim = true,
})
