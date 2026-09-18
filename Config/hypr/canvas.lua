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
-- This is entirely additive: it lives alongside the normal 1-10 workspaces
-- in monitors.lua/binds.lua and never touches them.

local mainMod   = "SUPER"
local canvasMod = mainMod .. " + ALT"

local CANVAS_PREFIX = "canvas_"

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

local function cell_name(x, y)
    return CANVAS_PREFIX .. x .. "_" .. y
end

-- Small on-screen toast so panning isn't flying blind. Wrapped in pcall so
-- a notification-API mismatch never breaks the actual pan/move above it.
local function notify(x, y)
    pcall(function()
        hl.notification.create({
            text    = "Canvas   " .. x .. ", " .. y,
            timeout = 900,
        })
    end)
end

-- Pan focus only; the window you're looking at stays where it is.
local function pan(dx, dy)
    return function()
        local x, y   = current_coords()
        local nx, ny = x + dx, y + dy
        hl.dispatch(hl.dsp.focus({ workspace = cell_name(nx, ny) }))
        notify(nx, ny)
    end
end

-- Pan and bring the active window along for the ride.
local function pan_with_window(dx, dy)
    return function()
        local x, y   = current_coords()
        local nx, ny = x + dx, y + dy
        hl.dispatch(hl.dsp.window.move({ workspace = cell_name(nx, ny), follow = true }))
        notify(nx, ny)
    end
end

local function go_home()
    hl.dispatch(hl.dsp.focus({ workspace = cell_name(0, 0) }))
    notify(0, 0)
end

local directions = {
    left  = { dx = -1, dy = 0  },
    right = { dx = 1,  dy = 0  },
    up    = { dx = 0,  dy = -1 },
    down  = { dx = 0,  dy = 1  },
}

for key, d in pairs(directions) do
    hl.bind(canvasMod .. " + " .. key, pan(d.dx, d.dy))
    hl.bind(canvasMod .. " + SHIFT + " .. key, pan_with_window(d.dx, d.dy))
end

hl.bind(canvasMod .. " + C", go_home)

-- To send a window off to an adjacent cell WITHOUT following it there,
-- add a third tier the same way binds.lua does for resize, e.g.:
--
-- hl.bind(canvasMod .. " + CTRL + " .. key, function()
--     local x, y   = current_coords()
--     local nx, ny = x + d.dx, y + d.dy
--     hl.dispatch(hl.dsp.window.move({ workspace = cell_name(nx, ny), follow = false }))
-- end)
