-- Infinite 2D workspace canvas.
--
-- Workspaces named "canvas_<x>_<y>" form a boundless grid you can pan across
-- in any of the 4 directions, forever. Stepping onto a cell that doesn't
-- exist yet creates it on the fly, exactly like any other named Hyprland
-- workspace; stepping away from an empty one lets Hyprland clean it back up
-- automatically. Nothing here reads or writes any state file - the current
-- cell is always derived live from whichever workspace is actually focused,
-- so it can never drift out of sync.
--
-- Windows opened on a cell start out floating, so a cell behaves like a
-- free-form board rather than a tiling workspace. Attaching windows to each
-- other (SUPER+ALT+G, or `g` in canvas mode) drops them into a Hyprland
-- group, which is what actually tiles them together.
--
-- Everything is reachable two ways: a direct chord from anywhere, or canvas
-- mode (SUPER+ALT+C), which is a submap where single keys drive the canvas
-- and a live HUD shows where you are. Press ? in the mode for the key list.
--
-- This is entirely additive: it lives alongside the normal 1-10 workspaces
-- in monitors.lua/binds.lua and never touches them.

local mainMod   = "SUPER"
local canvasMod = mainMod .. " + ALT"

local CANVAS_PREFIX = "canvas_"
local TERMINAL      = "kitty"

-- Hyprland's cursor zoom only ever magnifies. Factors below 1.0 are accepted
-- by the config but clamped away by the renderer (0.5 renders identically to
-- 1.0), so zooming out bottoms out at "fit" and the overview picker is what
-- covers seeing the whole canvas at once.
local ZOOM_MIN  = 1.0
local ZOOM_MAX  = 4.0
local ZOOM_STEP = 0.25

local HUD_MODE_TIMEOUT = 60000 -- canvas mode: HUD stays up while you work
local HUD_FLASH_TIMEOUT = 1100 -- direct chords: brief toast

-- Hyprland tweens zoomFactor natively, so stepping the target value is all we
-- have to do - no timer loop needed to make it smooth.
hl.curve("canvasZoom", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "canvasZoom" })

-- Attaching is Hyprland's own group mechanic rather than anything scripted
-- here, because the compositor does it properly: drag_into_group lets you
-- drop one window onto another to tile them together (SUPER + left-drag),
-- and auto_group makes the next window opened onto a cell join the group
-- you are focused on instead of landing beside it.
hl.config({
    group = {
        drag_into_group = true,
        auto_group      = true,
    },
})

--------------------------------------------------------------------------
-- Theme
--------------------------------------------------------------------------

-- Tint the HUD with the palette the control center currently has active, so
-- the canvas matches the rest of the desktop instead of hardcoding one look.
local ACCENTS = {
    noir      = "rgb(ffffff)",
    dachshund = "rgb(a85c32)",
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

--------------------------------------------------------------------------
-- Where am I
--------------------------------------------------------------------------

-- Reads the currently focused workspace and returns its (x, y) canvas
-- coordinate. Falls back to the origin (0, 0) when the active workspace
-- isn't a canvas cell at all - e.g. you're on workspace "1" - so every
-- canvas bind is always safe to press from anywhere.
local function current_coords()
    local ws = hl.get_active_workspace()
    if ws and ws.name then
        local x, y = ws.name:match("^" .. CANVAS_PREFIX .. "(%-?%d+)_(%-?%d+)$")
        if x then
            return tonumber(x), tonumber(y)
        end
    end
    return 0, 0
end

local function on_canvas()
    local ws = hl.get_active_workspace()
    return ws ~= nil
        and ws.name ~= nil
        and ws.name:match("^" .. CANVAS_PREFIX .. "%-?%d+_%-?%d+$") ~= nil
end

local function cell_name(x, y)
    return CANVAS_PREFIX .. x .. "_" .. y
end

-- Dispatchers need the "name:" selector, not the bare workspace name. A bare
-- name is read as a workspace id and a cell that doesn't exist yet is simply
-- rejected ("Bad workspace"), which is what silently stopped panning from
-- ever opening a new cell. With the prefix, stepping onto an empty cell
-- creates it, which is the whole point of the grid being boundless.
local function cell_selector(x, y)
    return "name:" .. cell_name(x, y)
end

--------------------------------------------------------------------------
-- Zoom
--------------------------------------------------------------------------

-- Read the live value rather than tracking our own copy, for the same reason
-- the coordinates are derived live: a cached number can drift, this can't.
local function get_zoom()
    local ok, value = pcall(hl.get_config, "cursor.zoom_factor")
    if ok and type(value) == "number" and value > 0 then
        return value
    end
    return ZOOM_MIN
end

local function set_zoom(z)
    if z < ZOOM_MIN then
        z = ZOOM_MIN
    elseif z > ZOOM_MAX then
        z = ZOOM_MAX
    end
    z = math.floor(z * 100 + 0.5) / 100
    pcall(hl.config, { cursor = { zoom_factor = z } })
    return z
end

--------------------------------------------------------------------------
-- HUD
--------------------------------------------------------------------------

-- One long-lived notification we keep re-texting, so panning around in canvas
-- mode updates a single readout instead of stacking up a pile of toasts.
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

local function zoom_label(z)
    if z <= ZOOM_MIN then
        return "fit"
    end
    return string.format("%.2gx", z)
end

-- The one readout everything funnels through: where you are, how far in you
-- are zoomed, and how much is on this cell.
local function status(prefix, timeout)
    local x, y = current_coords()
    local windows = 0
    local ok, list = pcall(hl.get_workspace_windows, cell_selector(x, y))
    if ok and type(list) == "table" then
        windows = #list
    end

    local text = string.format(
        "%s   cell %d, %d    zoom %s    %d window%s",
        prefix, x, y, zoom_label(get_zoom()), windows, windows == 1 and "" or "s"
    )
    hud_show(text, timeout or HUD_FLASH_TIMEOUT)
end

--------------------------------------------------------------------------
-- Actions
--------------------------------------------------------------------------

local function in_mode()
    return hl.get_current_submap() == "canvas"
end

local function hud_timeout()
    return in_mode() and HUD_MODE_TIMEOUT or HUD_FLASH_TIMEOUT
end

-- mode: "pan" moves focus only, "carry" drags the active window along,
-- "throw" sends the window over without following it.
local function step(dx, dy, mode)
    return function()
        local x, y = current_coords()
        local target = cell_selector(x + dx, y + dy)

        if mode == "carry" then
            hl.dispatch(hl.dsp.window.move({ workspace = target, follow = true }))
        elseif mode == "throw" then
            hl.dispatch(hl.dsp.window.move({ workspace = target, follow = false }))
        else
            hl.dispatch(hl.dsp.focus({ workspace = target }))
        end

        status(mode == "throw" and "Sent" or "Canvas", hud_timeout())
    end
end

local function go_home()
    hl.dispatch(hl.dsp.focus({ workspace = cell_selector(0, 0) }))
    status("Home", hud_timeout())
end

local function zoom_by(delta)
    return function()
        set_zoom(get_zoom() + delta)
        status("Canvas", hud_timeout())
    end
end

local function zoom_reset()
    set_zoom(ZOOM_MIN)
    status("Canvas", hud_timeout())
end

-- Attaching: a Hyprland group is what turns loose floating windows into a
-- tiled/tabbed stack, so "attach" and "group" are the same gesture here. A
-- floating window has to be tiled first or it just floats on top of the group.
local function toggle_attach()
    local win = hl.get_active_window()
    if win and win.floating then
        pcall(hl.dispatch, hl.dsp.window.float({ action = "off" }))
    end
    pcall(hl.dispatch, hl.dsp.group.toggle())

    local grouped = false
    local ok, current = pcall(hl.get_active_window)
    if ok and current and current.group then
        grouped = true
    end
    status(grouped and "Attached" or "Detached", hud_timeout())
end

local function toggle_float()
    pcall(hl.dispatch, hl.dsp.window.float({ action = "toggle" }))
    local win = hl.get_active_window()
    status((win and win.floating) and "Floating" or "Tiled", hud_timeout())
end

local function overview()
    hl.dispatch(hl.dsp.exec_cmd(os.getenv("HOME") .. "/NixOS/Scripts/canvas-overview.sh"))
end

--------------------------------------------------------------------------
-- A cell is a floating board
--------------------------------------------------------------------------

-- Keybinds and submaps are rebuilt from scratch on a config reload, but event
-- subscriptions are not, so drop the previous load's before subscribing again
-- or every `hyprctl reload` would stack another copy of these handlers.
if _G.__canvas_subscriptions then
    for _, sub in ipairs(_G.__canvas_subscriptions) do
        pcall(function()
            sub:remove()
        end)
    end
end
_G.__canvas_subscriptions = {}

-- Windows that open on a canvas cell start floating, which is what makes it a
-- canvas rather than just another tiling workspace. Grouped windows are left
-- alone: being in a group is the whole point of having attached them.
--
-- This checks the workspace the new window actually landed on, not the one
-- you happen to be looking at, so a window opened onto a cell in the
-- background (`silent` window rules, a cell you threw something to) still
-- floats the way it would have if you were standing there.
table.insert(_G.__canvas_subscriptions, hl.on("window.open", function(opened)
    pcall(function()
        -- The event hands us the window as userdata, not a table, so take it
        -- as-is rather than type-checking it into the fallback path.
        local win = opened or hl.get_active_window()
        if not win or win.floating or win.group then
            return
        end
        local ws = win.workspace
        if not (ws and ws.name and ws.name:match("^" .. CANVAS_PREFIX .. "%-?%d+_%-?%d+$")) then
            return
        end
        hl.dispatch(hl.dsp.window.float({
            action = "on",
            window = "address:" .. tostring(win.address),
        }))
    end)
end))

--------------------------------------------------------------------------
-- Direct chords - work from anywhere, no mode needed
--------------------------------------------------------------------------

local directions = {
    { key = "left",  dx = -1, dy = 0, },
    { key = "right", dx = 1,  dy = 0, },
    { key = "up",    dx = 0,  dy = -1, },
    { key = "down",  dx = 0,  dy = 1, },
}

for _, d in ipairs(directions) do
    hl.bind(canvasMod .. " + " .. d.key, step(d.dx, d.dy, "pan"),
        { description = "Canvas: pan " .. d.key })
    hl.bind(canvasMod .. " + SHIFT + " .. d.key, step(d.dx, d.dy, "carry"),
        { description = "Canvas: pan " .. d.key .. " with the window" })
    hl.bind(canvasMod .. " + CTRL + " .. d.key, step(d.dx, d.dy, "throw"),
        { description = "Canvas: send the window " .. d.key .. ", stay here" })
end

hl.bind(canvasMod .. " + Home", go_home, { description = "Canvas: home cell" })
hl.bind(canvasMod .. " + G", toggle_attach, { description = "Canvas: attach/detach window" })
hl.bind(canvasMod .. " + O", overview, { description = "Canvas: overview" })
hl.bind(canvasMod .. " + equal", zoom_by(ZOOM_STEP), { description = "Canvas: zoom in", repeating = true })
hl.bind(canvasMod .. " + minus", zoom_by(-ZOOM_STEP), { description = "Canvas: zoom out", repeating = true })
hl.bind(canvasMod .. " + 0", zoom_reset, { description = "Canvas: reset zoom" })

--------------------------------------------------------------------------
-- Canvas mode - single-key control
--------------------------------------------------------------------------

local HELP = table.concat({
    "Canvas mode",
    "",
    "arrows / hjkl      pan",
    "SHIFT + move       pan, carrying the window",
    "CTRL + move        send the window over, stay",
    "",
    "+ / -              zoom in / out        0   fit",
    "g                  attach / detach      f   float / tile",
    "TAB / SHIFT+TAB    cycle in the group",
    "",
    "drag a window onto another with SUPER",
    "to attach them into one tiled stack",
    "",
    "o overview     c home     RETURN terminal",
    "?  this help   ESC or q   leave canvas mode",
}, "\n")

local function enter_mode()
    hl.dispatch(hl.dsp.submap("canvas"))
    status("Canvas mode   ? for keys", HUD_MODE_TIMEOUT)
end

local function leave_mode()
    hl.dispatch(hl.dsp.submap("reset"))
    hud_hide()
end

hl.define_submap("canvas", function()
    local keys = {
        { keys = { "left", "H" },  dx = -1, dy = 0, },
        { keys = { "right", "L" }, dx = 1,  dy = 0, },
        { keys = { "up", "K" },    dx = 0,  dy = -1, },
        { keys = { "down", "J" },  dx = 0,  dy = 1, },
    }

    for _, d in ipairs(keys) do
        for _, key in ipairs(d.keys) do
            hl.bind(key, step(d.dx, d.dy, "pan"), { repeating = true })
            hl.bind("SHIFT + " .. key, step(d.dx, d.dy, "carry"), { repeating = true })
            hl.bind("CTRL + " .. key, step(d.dx, d.dy, "throw"))
        end
    end

    hl.bind("equal", zoom_by(ZOOM_STEP), { repeating = true })
    hl.bind("plus", zoom_by(ZOOM_STEP), { repeating = true })
    hl.bind("minus", zoom_by(-ZOOM_STEP), { repeating = true })
    hl.bind("0", zoom_reset)

    hl.bind("G", toggle_attach)
    hl.bind("F", toggle_float)
    hl.bind("Tab", hl.dsp.group.next())
    hl.bind("SHIFT + Tab", hl.dsp.group.prev())

    hl.bind("C", go_home)
    hl.bind("O", function()
        overview()
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

hl.bind(canvasMod .. " + C", enter_mode, { description = "Canvas: enter canvas mode" })

-- Leaving the canvas entirely shouldn't strand you in a mode whose keys no
-- longer do anything useful, and shouldn't leave the screen magnified either.
table.insert(_G.__canvas_subscriptions, hl.on("workspace.active", function()
    pcall(function()
        if on_canvas() then
            return
        end
        if in_mode() then
            leave_mode()
        end
        if get_zoom() > ZOOM_MIN then
            set_zoom(ZOOM_MIN)
        end
    end)
end))
