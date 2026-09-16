hl.monitor({
    output   = "desc:eDP-1",
    disabled = true,
})


hl.monitor({
    output   = "DP-3",
    mode     = "2560x1440@200",
    position = "1920x0",
    scale    = 1,
    vrr      = 0,
})


hl.monitor({
    output   = "DP-2",
    mode     = "1920x1080@180",
    position = "0x500",
    scale    = 1,
    vrr      = 0,
})


hl.monitor({
    output   = "HDMI-A-1",
    disabled = true,
    mode     = "1920x1080@60",
    position = "4480x0",
    scale    = 1,
    mirror   = "DP-2",
})


for i = 1, 5 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor   = "DP-3",
        default   = i == 1,
    })
end

hl.window_rule({
    match = {
        class = "^steam_app_239140$",
    },
    workspace = "2 silent",
})

for i = 6, 10 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor   = "DP-2",
        default   = i == 6,
    })
end