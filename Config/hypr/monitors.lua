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
    position = "0x250",
    scale    = 1,
    vrr      = 0,
})


hl.monitor({
    output   = "desc:Philips Consumer Electronics Company PHILIPS FTV 0x01010101",
    mode     = "1920x1080@60",
    position = "4480x0",
    scale    = 1,
    mirror   = "desc:Microstep MAG 242C",
})


hl.workspace_rule({
    workspace = "11",
    monitor   = "virtual",
    default   = true,
})


local workspace_ranges = {
    { desc = "LG Electronics LG ULTRAGEAR 507NTZNPC165", first = 1, last = 5 },
    { desc = "Microstep MAG 242C", first = 6, last = 10 },
}

for _, range in ipairs(workspace_ranges) do
    for i = range.first, range.last do
        hl.workspace_rule({
            workspace = tostring(i),
            monitor   = "desc:" .. range.desc,
            default   = i == range.first,
        })
    end
end

local function trim(s)
    return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function show_default_workspaces()
    local monitors = hl.get_monitors()
    local focused = hl.get_active_monitor()
    local home = nil
    for _, m in ipairs(monitors) do
        if focused and m.name == focused.name then
            home = m.name
        end
    end
    for _, range in ipairs(workspace_ranges) do
        for _, m in ipairs(monitors) do
            local ws = m.active_workspace
            if trim(m.description) == range.desc then
                home = home or m.name
                if ws and (ws.id < range.first or ws.id > range.last) then
                    hl.dispatch(hl.dsp.focus({ monitor = m.name }))
                    hl.dispatch(hl.dsp.focus({ workspace = range.first }))
                end
            end
        end
    end
    if home then
        hl.dispatch(hl.dsp.focus({ monitor = home }))
    end
end

if _G.__monitor_subscriptions then
    for _, sub in ipairs(_G.__monitor_subscriptions) do
        pcall(function()
            sub:remove()
        end)
    end
end

_G.__monitor_subscriptions = {}

for _, event in ipairs({ "monitor.added", "monitor.layout_changed" }) do
    table.insert(_G.__monitor_subscriptions, hl.on(event, function()
        pcall(show_default_workspaces)
    end))
end
