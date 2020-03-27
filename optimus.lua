local wibox         = require("wibox")
local awful         = require("awful")
local beautiful     = require("beautiful")
local gears         = require("gears")

local optimus = {}
local function worker(args)
    local args = args or {}

    widgets_table = {}

    -- Settings
    local display_image = "/usr/share/icons/Arc/devices/symbolic/video-display-symbolic.svg"
    local font          = args.font or beautiful.font
    local widget 	= args.widget == nil and wibox.layout.fixed.horizontal() or args.widget == false and nil or args.widget
    local timeout       = args.timeout or 5
    local onclick       = ""
    local optimus_output = ""

    local optimus_icon = wibox.widget {
        {
            id = "icon",
            image = display_image,
            resize = false,
            widget = wibox.widget.imagebox,
        },
        layout = wibox.container.margin(_, _, _, 3),
        set_image = function(self, path)
            self.icon.image = path
        end
    }

    optimus_icon:set_image(display_image)

    local optimus_text = wibox.widget.textbox()
    optimus_text.font = font
    optimus_text:set_text("")

    local function optimus_update()
	awful.spawn.easy_async("optimus-manager --print-mode", function(stdout, stderr, reason, exit_code)
          optimus_output = tostring( stdout )
        end)
        
        if string.find(optimus_output, "nvidia") then
            optimus_output = "  NVIDIA"
            onclick = terminal .. " -e \"optimus-manager --switch intel\""
        elseif string.find(optimus_output, "intel") then
            optimus_output = "  INTEL"
            onclick = terminal .. " -e \"optimus-manager --switch nvidia\""
        elseif string.find(optimus_output, "hybrid") then
            optimus_output = "  HYBRID"
        end
        optimus_text:set_text(optimus_output)
        optimus:attach(widget,{onclick = onclick})
    end

    optimus_update()
    local timer = gears.timer.start_new( timeout, function () optimus_update()
      return true end )

    widgets_table["imagebox"]	= optimus_icon
    widgets_table["textbox"]	= optimus_text
    if widget then
	    widget:add(optimus_icon)
		widget:add(optimus_text)
    end

    return widget or widgets_table
end

function optimus:attach(widget, args)
    local args = args or {}
    local onclick = args.onclick
    -- Bind onclick event function
    if onclick then
	    widget:buttons(awful.util.table.join(
	    awful.button({}, 1, function() awful.util.spawn(onclick) end)
	    ))
    end
    return widget
end

return setmetatable(optimus, {__call = function(_,...) return worker(...) end})