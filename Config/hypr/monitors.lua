hl.monitor({
    output   = "desc:eDP-1",
    disabled = true,
})

hl.monitor({
    output   = "DP-6",
    mode     = "2560x1440@200",
    position = "1920x0",
    scale    = 1,
    vrr      = 0,
})

hl.monitor({
    output   = "DP-5",
    mode     = "1920x1080@180",
    position = "0x500",
    scale    = 1,
    vrr      = 0,
})

--[[
hl.monitor({
    output   = "HDMI-A-2",
    mode     = "1920x1080@60",
    position = "4480x0",
    scale    = 1,
    mirror   = "DP-5",
})
]]

for i = 1, 5 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor   = "DP-6",
        default   = i == 1,
    })
end

for i = 6, 10 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor   = "DP-5",
        default   = i == 6,
    })
end