
local mainMod   = "SUPER"
local canvasMod = mainMod .. " + ALT"

local CANVAS_WS   = "canvas"
local CANVAS_SEL  = "name:" .. CANVAS_WS
local TERMINAL    = "kitty"

local PAN_STEP  = 260
local ZOOM_STEP = 1.2
local SCALE_MIN = 0.12
local SCALE_MAX = 3.0
local FIT_PAD   = 70
local MIN_PX    = 60
local CASCADE_STEP = 46
local CASCADE_WRAP = 7

local HUD_MODE_TIMEOUT  = 60000
local HUD_FLASH_TIMEOUT = 1200

local scale = 1.0

hl.config({
    group = {
        drag_into_group = true,
        auto_group      = true,
    },
})

local ACCENTS = {
    noir      = "rgb(ffffff)",
    dachshund = "rgb(c9702f)",
}

local function accent()
    local ok, colour = pcall(function()
        local f = io.open(os.getenv("HOME") .. "/.cache/control-center/theme", "r")
        if not f then
            return nil
        end
        local name = (f:read("l") or ""):gsub("%s", "")
        f:close()
        return ACCENTS[name]
    end)
    return (ok and colour) or ACCENTS.noir
end

local function on_canvas()
    local ws = hl.get_active_workspace()
    return ws ~= nil and ws.name == CANVAS_WS
end

local function canvas_windows()
    local ok, all = pcall(hl.get_windows, { workspace = CANVAS_WS })
    if not ok or type(all) ~= "table" then
        return {}
    end
    local out = {}
    for _, w in ipairs(all) do
        if w.floating then
            out[#out + 1] = w
        end
    end
    return out
end

local function viewport()
    local mon = hl.get_active_monitor()
    if not mon then
        return 0, 0, 1920, 1080
    end
    return mon.x, mon.y, mon.width, mon.height
end

local function transform(fn)
    local windows = canvas_windows()
    for _, w in ipairs(windows) do
        local at, size = w.at, w.size
        local ok, nx, ny, nw, nh = pcall(fn, at.x, at.y, size.x, size.y)
        if ok and nx then
            local addr = "address:" .. tostring(w.address)
            if nw and nh then
                pcall(hl.dispatch, hl.dsp.window.resize({
                    x = math.max(MIN_PX, math.floor(nw + 0.5)),
                    y = math.max(MIN_PX, math.floor(nh + 0.5)),
                    exact = true,
                    window = addr,
                }))
            end
            pcall(hl.dispatch, hl.dsp.window.move({
                x = math.floor(nx + 0.5),
                y = math.floor(ny + 0.5),
                exact = true,
                window = addr,
            }))
        end
    end
    return #windows
end

local hud = nil

local function hud_alive()
    if not hud then
        return false
    end
    local ok, alive = pcall(function()
        return hud:is_alive()
    end)
    return ok and alive
end

local function hud_show(text, timeout)
    if hud_alive() then
        pcall(function()
            hud:set_text(text)
            hud:set_timeout(timeout)
        end)
        return
    end
    local ok, note = pcall(hl.notification.create, {
        text      = text,
        timeout   = timeout,
        color     = accent(),
        font_size = 15,
    })
    hud = ok and note or nil
end

local function hud_hide()
    if hud_alive() then
        pcall(function()
            hud:dismiss()
        end)
    end
    hud = nil
end

local function in_mode()
    return hl.get_current_submap() == "canvas"
end

local function hud_timeout()
    return in_mode() and HUD_MODE_TIMEOUT or HUD_FLASH_TIMEOUT
end

local function status(prefix)
    local n = #canvas_windows()
    hud_show(string.format(
        "%s   zoom %d%%    %d window%s on the canvas",
        prefix, math.floor(scale * 100 + 0.5), n, n == 1 and "" or "s"
    ), hud_timeout())
end

local function do_pan(dx, dy)
    transform(function(x, y)
        return x - dx, y - dy
    end)
end

local function pan(dx, dy)
    return function()
        do_pan(dx, dy)
        status("Canvas")
    end
end

local function zoom_about(factor, px, py)
    local target = scale * factor
    if target < SCALE_MIN or target > SCALE_MAX then
        status("Canvas   limit")
        return
    end
    transform(function(x, y, w, h)
        return px + (x - px) * factor,
            py + (y - py) * factor,
            w * factor,
            h * factor
    end)
    scale = target
end

local function do_zoom(factor)
    local p = hl.get_cursor_pos()
    local mx, my, mw, mh = viewport()
    zoom_about(factor, (p and p.x) or (mx + mw / 2), (p and p.y) or (my + mh / 2))
end

local function zoom(factor)
    return function()
        do_zoom(factor)
        status("Canvas")
    end
end

local function fit()
    local windows = canvas_windows()
    if #windows == 0 then
        status("Canvas   empty")
        return
    end

    local minx, miny = math.huge, math.huge
    local maxx, maxy = -math.huge, -math.huge
    for _, w in ipairs(windows) do
        local a, s = w.at, w.size
        minx = math.min(minx, a.x)
        miny = math.min(miny, a.y)
        maxx = math.max(maxx, a.x + s.x)
        maxy = math.max(maxy, a.y + s.y)
    end

    local mx, my, mw, mh = viewport()
    local availW = mw - FIT_PAD * 2
    local availH = mh - FIT_PAD * 2
    local spanW = math.max(1, maxx - minx)
    local spanH = math.max(1, maxy - miny)

    local factor = math.min(availW / spanW, availH / spanH)
    factor = math.max(SCALE_MIN / scale, math.min(factor, SCALE_MAX / scale))

    transform(function(x, y, w, h)
        return minx + (x - minx) * factor,
            miny + (y - miny) * factor,
            w * factor,
            h * factor
    end)

    local newW, newH = spanW * factor, spanH * factor
    local offX = mx + (mw - newW) / 2 - minx
    local offY = my + (mh - newH) / 2 - miny
    transform(function(x, y)
        return x + offX, y + offY
    end)

    scale = scale * factor
    status("Fit")
end

local function center_on_focused()
    local win = hl.get_active_window()
    if not win or not win.floating then
        status("Canvas")
        return
    end
    local mx, my, mw, mh = viewport()
    local a, s = win.at, win.size
    local dx = (mx + (mw - s.x) / 2) - a.x
    local dy = (my + (mh - s.y) / 2) - a.y
    transform(function(x, y)
        return x + dx, y + dy
    end)
    status("Centred")
end

local function tile_all()
    local windows = canvas_windows()
    if #windows == 0 then
        status("Canvas   empty")
        return
    end

    local mx, my, mw, mh = viewport()
    local cols = math.ceil(math.sqrt(#windows))
    local rows = math.ceil(#windows / cols)
    local gap = 14
    local cellW = (mw - gap * (cols + 1)) / cols
    local cellH = (mh - gap * (rows + 1)) / rows

    for i, w in ipairs(windows) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local addr = "address:" .. tostring(w.address)
        pcall(hl.dispatch, hl.dsp.window.resize({
            x = math.max(MIN_PX, math.floor(cellW)),
            y = math.max(MIN_PX, math.floor(cellH)),
            exact = true,
            window = addr,
        }))
        pcall(hl.dispatch, hl.dsp.window.move({
            x = math.floor(mx + gap + col * (cellW + gap)),
            y = math.floor(my + gap + row * (cellH + gap)),
            exact = true,
            window = addr,
        }))
    end

    scale = 1.0
    status("Tiled")
end

local function open_canvas()
    hl.dispatch(hl.dsp.focus({ workspace = CANVAS_SEL }))
end

local function shove(dx, dy)
    return function()
        local win = hl.get_active_window()
        if not win or not win.floating then
            return
        end
        local a = win.at
        pcall(hl.dispatch, hl.dsp.window.move({
            x = math.floor(a.x + dx),
            y = math.floor(a.y + dy),
            exact = true,
            window = "address:" .. tostring(win.address),
        }))
        status("Moved")
    end
end

local function toggle_attach()
    local win = hl.get_active_window()
    if win and win.floating then
        pcall(hl.dispatch, hl.dsp.window.float({ action = "off" }))
    end
    pcall(hl.dispatch, hl.dsp.group.toggle())
    local now = hl.get_active_window()
    status((now and now.group) and "Attached" or "Detached")
end

local function toggle_float()
    pcall(hl.dispatch, hl.dsp.window.float({ action = "toggle" }))
    local win = hl.get_active_window()
    status((win and win.floating) and "Floating" or "Tiled")
end

if _G.__canvas_subscriptions then
    for _, sub in ipairs(_G.__canvas_subscriptions) do
        pcall(function()
            sub:remove()
        end)
    end
end
_G.__canvas_subscriptions = {}

table.insert(_G.__canvas_subscriptions, hl.on("window.open", function(opened)
    pcall(function()
        local win = opened or hl.get_active_window()
        if not win or win.group then
            return
        end
        local ws = win.workspace
        if not (ws and ws.name == CANVAS_WS) then
            return
        end

        local addr = "address:" .. tostring(win.address)
        local existing = #canvas_windows()
        if not win.floating then
            hl.dispatch(hl.dsp.window.float({ action = "on", window = addr }))
        end

        local fresh = hl.get_window(addr)
        if not fresh then
            return
        end

        if math.abs(scale - 1.0) > 0.01 then
            hl.dispatch(hl.dsp.window.resize({
                x = math.max(MIN_PX, math.floor(fresh.size.x * scale)),
                y = math.max(MIN_PX, math.floor(fresh.size.y * scale)),
                exact = true,
                window = addr,
            }))
            fresh = hl.get_window(addr) or fresh
        end

        if existing > 0 then
            local offset = CASCADE_STEP * ((existing - 1) % CASCADE_WRAP + 1)
            hl.dispatch(hl.dsp.window.move({
                x = math.floor(fresh.at.x + offset),
                y = math.floor(fresh.at.y + offset),
                exact = true,
                window = addr,
            }))
        end
    end)
end))

local directions = {
    { key = "left",  dx = -1, dy = 0 },
    { key = "right", dx = 1,  dy = 0 },
    { key = "up",    dx = 0,  dy = -1 },
    { key = "down",  dx = 0,  dy = 1 },
}

for _, d in ipairs(directions) do
    hl.bind(canvasMod .. " + " .. d.key, pan(d.dx * PAN_STEP, d.dy * PAN_STEP),
        { description = "Canvas: pan " .. d.key, repeating = true })
    hl.bind(canvasMod .. " + SHIFT + " .. d.key, shove(d.dx * PAN_STEP, d.dy * PAN_STEP),
        { description = "Canvas: move the window " .. d.key, repeating = true })
end

hl.bind(canvasMod .. " + C", function()
    open_canvas()
    hl.dispatch(hl.dsp.submap("canvas"))
    status("Canvas mode   ? for keys")
end, { description = "Canvas: open the canvas and enter canvas mode" })

hl.bind(canvasMod .. " + Home", open_canvas, { description = "Canvas: open the canvas" })
hl.bind(canvasMod .. " + 0", fit, { description = "Canvas: zoom to fit everything" })
hl.bind(canvasMod .. " + T", tile_all, { description = "Canvas: tile every window in a grid" })
hl.bind(canvasMod .. " + G", toggle_attach, { description = "Canvas: attach/detach window" })

for _, k in ipairs({ "equal", "plus" }) do
    hl.bind(canvasMod .. " + " .. k, zoom(ZOOM_STEP),
        { description = "Canvas: zoom in", repeating = true })
    hl.bind(canvasMod .. " + SHIFT + " .. k, zoom(ZOOM_STEP),
        { description = "Canvas: zoom in", repeating = true })
end
for _, k in ipairs({ "minus", "underscore" }) do
    hl.bind(canvasMod .. " + " .. k, zoom(1 / ZOOM_STEP),
        { description = "Canvas: zoom out", repeating = true })
    hl.bind(canvasMod .. " + SHIFT + " .. k, zoom(1 / ZOOM_STEP),
        { description = "Canvas: zoom out", repeating = true })
end

hl.bind(canvasMod .. " + mouse_up", zoom(ZOOM_STEP), { description = "Canvas: zoom in" })
hl.bind(canvasMod .. " + mouse_down", zoom(1 / ZOOM_STEP), { description = "Canvas: zoom out" })

local HELP = table.concat({
    "Canvas mode",
    "",
    "arrows / hjkl      pan across the canvas",
    "SHIFT + move       move the focused window instead",
    "",
    "+ / -  or scroll   zoom in / out",
    "0                  zoom to fit everything",
    "t                  tile every window in a grid",
    "c                  centre on the focused window",
    "",
    "g   attach / detach      f   float / tile",
    "TAB cycle in a group     o   jump to a window",
    "",
    "drag a window onto another with SUPER",
    "to attach them into one tiled stack",
    "",
    "RETURN terminal    ? this help    ESC / q  leave",
}, "\n")

local function leave_mode()
    hl.dispatch(hl.dsp.submap("reset"))
    hud_hide()
end

hl.define_submap("canvas", function()
    local keys = {
        { keys = { "left", "H" },  dx = -1, dy = 0 },
        { keys = { "right", "L" }, dx = 1,  dy = 0 },
        { keys = { "up", "K" },    dx = 0,  dy = -1 },
        { keys = { "down", "J" },  dx = 0,  dy = 1 },
    }
    for _, d in ipairs(keys) do
        for _, key in ipairs(d.keys) do
            hl.bind(key, pan(d.dx * PAN_STEP, d.dy * PAN_STEP), { repeating = true })
            hl.bind("SHIFT + " .. key, shove(d.dx * PAN_STEP, d.dy * PAN_STEP), { repeating = true })
        end
    end

    for _, k in ipairs({ "equal", "plus" }) do
        hl.bind(k, zoom(ZOOM_STEP), { repeating = true })
        hl.bind("SHIFT + " .. k, zoom(ZOOM_STEP), { repeating = true })
    end
    for _, k in ipairs({ "minus", "underscore" }) do
        hl.bind(k, zoom(1 / ZOOM_STEP), { repeating = true })
        hl.bind("SHIFT + " .. k, zoom(1 / ZOOM_STEP), { repeating = true })
    end
    hl.bind("mouse_up", zoom(ZOOM_STEP))
    hl.bind("mouse_down", zoom(1 / ZOOM_STEP))

    hl.bind("0", fit)
    hl.bind("T", tile_all)
    hl.bind("C", center_on_focused)
    hl.bind("G", toggle_attach)
    hl.bind("F", toggle_float)
    hl.bind("Tab", hl.dsp.group.next())
    hl.bind("SHIFT + Tab", hl.dsp.group.prev())
    hl.bind("O", function()
        hl.dispatch(hl.dsp.exec_cmd(os.getenv("HOME") .. "/NixOS/Scripts/canvas-overview.sh"))
        leave_mode()
    end)
    hl.bind("Return", hl.dsp.exec_cmd(TERMINAL))

    hl.bind("question", function()
        hud_show(HELP, HUD_MODE_TIMEOUT)
    end)
    hl.bind("slash", function()
        hud_show(HELP, HUD_MODE_TIMEOUT)
    end)

    hl.bind("escape", leave_mode)
    hl.bind("Q", leave_mode)
end)

hl.bind(canvasMod .. " + O", function()
    hl.dispatch(hl.dsp.exec_cmd(os.getenv("HOME") .. "/NixOS/Scripts/canvas-overview.sh"))
end, { description = "Canvas: jump to a window" })

table.insert(_G.__canvas_subscriptions, hl.on("workspace.active", function()
    pcall(function()
        if not on_canvas() and in_mode() then
            leave_mode()
        end
    end)
end))

_G.canvas = {
    pan       = do_pan,
    zoom      = do_zoom,
    fit       = fit,
    tile      = tile_all,
    center    = center_on_focused,
    open      = open_canvas,
    scale     = function() return scale end,
    windows   = canvas_windows,
}
