hl.monitor({
    output   = "desc:eDP-1",
    disabled = true,
})


hl.monitor({
    output   = "desc:LG Electronics LG ULTRAGEAR 507NTZNPC165",
    mode     = "2560x1440@200.013",
    position = "1920x0",
    scale    = 1,
    vrr      = 0,
})


hl.monitor({
    output   = "desc:Microstep MAG 242C",
    mode     = "1920x1080@179.964",
    position = "0x500",
    scale    = 1,
    vrr      = 0,
})


hl.monitor({
    output   = "desc:Philips Consumer Electronics Company PHILIPS FTV 0x01010101",
    disabled = true,
    mode     = "1920x1080@60",
    position = "4480x0",
    scale    = 1,
    mirror   = "desc:Microstep MAG 242C",
})


for i = 1, 5 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor   = "desc:LG Electronics LG ULTRAGEAR 507NTZNPC165",
        default   = i == 1,
    })
end

for i = 6, 10 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor   = "desc:Microstep MAG 242C",
        default   = i == 6,
    })
end