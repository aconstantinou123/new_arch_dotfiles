local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local widget = {}

local function worker(args)

    local args = args or {}

    local image = args.image
    local command = args.command

    local button = awful.widget.button({
        image = image,
    })
    button:buttons(gears.table.join(
        button:buttons(),
        awful.button({}, 1, nil, function ()
            awful.spawn({command})
        end)
    ))
    
    return button
end

return setmetatable(widget, { __call = function(_, ...) return worker(...) end })
