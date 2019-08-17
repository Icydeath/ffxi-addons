_meta = _meta or {}
_meta.FunctionButton = {}
_meta.FunctionButton.__class = 'function_button'
_meta.FunctionButton.__methods = {}

function FunctionButton(args) -- constructs the object, but does not initialize it
	local fb = {}
	fb._track = {}
	fb._track._class = 'function button'

	fb._track._x = args.x
	fb._track._y = args.y
	fb._track._icon = args.icon
	fb._track._mouse_event = nil
	fb._track._update_event = nil
	fb._track._suppress = false
	--fb._track._startPressed = args.startPressed
	fb._track._update_command = args.command
	fb._track._pressed = false	
	fb._track._disabled = args.disabled
	fb._track._shown = true
	
	return setmetatable(fb, _meta.FunctionButton)	
end

_meta.FunctionButton.__methods['draw'] = function(fb) -- Finishes initialization and draws the graphics
	local self = tostring(fb)
	-- draw the button
	windower.prim.create(self)
	windower.prim.set_visibility(self, true)
	windower.prim.set_position(self, fb._track._x, fb._track._y)
	windower.prim.set_texture(self, GUI.complete_filepath('icon_button.png'))
	windower.prim.set_fit_to_texture(self, true)
	-- blue square to darken the button when pressed
	local press = '%s press':format(self)
	windower.prim.create(press)
	windower.prim.set_visibility(press, false) -- start pressed if var is true or inverted var is false
	windower.prim.set_position(press, fb._track._x + 3, fb._track._y + 3)
	windower.prim.set_color(press, 100, 0, 0, 127)
	windower.prim.set_size(press, 36, 36)

	-- draw the pressed and unpressed icons
	local name = '%s Icon':format(self)
	windower.prim.create(name)
	windower.prim.set_visibility(name, true)
	windower.prim.set_position(name, fb._track._x + 5, fb._track._y + 5)
	windower.prim.set_texture(name, GUI.complete_filepath(fb._track._icon))
	windower.prim.set_fit_to_texture(name, true)
	
	-- display the icon that is currently active
	--windower.prim.set_visibility('%s %s':format(self, ('Down' and fb._track._startPressed) or 'Up'), fb._track._var ~= fb._track._invert)
	--fb._track._mouse_event = GUI.register_mouse_listener(fb)
	GUI.register_mouse_listener(fb)
end

_meta.FunctionButton.__methods['on_mouse'] = function(fb, t, x, y, delta, blocked)
	if fb._track._disabled then return end
	if t == 1 then
		if fb._track._suppress then
			fb._track._suppress = false
			return true
		end
		if x > fb._track._x and x < fb._track._x + 42 and y > fb._track._y and y < fb._track._y + 42 then
			fb:press()
			return true
		end
	elseif t == 2 then
		if fb._track._pressed then
			if x > fb._track._x and x < fb._track._x + 42 and y > fb._track._y and y < fb._track._y + 42 then
				if type(fb._track._update_command) == 'function' then
					fb._track._update_command()
				elseif type(fb._track._update_command) == 'string' then
					windower.send_command(fb._track._update_command)
				end
			end
			fb:unpress()
			return true
		end
		if x > fb._track._x and x < fb._track._x + 42 and y > fb._track._y and y < fb._track._y + 42 then
			return true
		end
	end
end

_meta.FunctionButton.__methods['press'] = function(fb)
	-- visually depress the button
	fb._track._pressed = true
	windower.prim.set_visibility('%s press':format(tostring(fb)), true)
end

_meta.FunctionButton.__methods['unpress'] = function(fb)
	fb._track._pressed = false
	windower.prim.set_visibility('%s press':format(tostring(fb)), false)
	
end

_meta.FunctionButton.__methods['hide'] = function(fb)
	windower.prim.set_visibility(tostring(fb), false) -- hide the frame
	windower.prim.set_visibility('%s press':format(tostring(fb)), false) -- hide the blue box
	windower.prim.set_visibility('%s %s':format(tostring(fb), fb._track._icon), false) -- hide the icon
	--[[if fb._track._overlay then
		fb:hideoverlay()
	end]]
end

_meta.FunctionButton.__methods['show'] = function(fb)
	windower.prim.set_visibility(tostring(fb), true)
	fb._track._pressed = false -- unpress the button
	windower.prim.set_visibility('%s %s':format(tostring(fb),fb._track._icon),true)
end

--[[_meta.FunctionButton.__methods['showoverlay'] = function(fb)
	windower.prim.set_visibility('%s overlay':format(tostring(fb)), true)
	fb._track._show_overlay = true
end

_meta.FunctionButton.__methods['hideoverlay'] = function(fb)
	windower.prim.set_visibility('%s overlay':format(tostring(fb)), false)
	fb._track._show_overlay = false
end]]

_meta.FunctionButton.__methods['disable'] = function(fb)
	fb._track._disabled = true
end

_meta.FunctionButton.__methods['enable'] = function(fb)
	fb._track._disabled = false
end

_meta.FunctionButton.__methods['undraw'] = function(fb)
	local self = tostring(fb)

	windower.prim.delete(self)
	windower.prim.delete('%s press':format(self))
	windower.prim.delete('%s Icon':format(self))

	--GUI.unregister_mouse_listener(fb._track._mouse_event)
	GUI.unregister_mouse_listener(fb)
end

_meta.FunctionButton.__index = function(fb, k)
    if type(k) == 'string' then
        local lk = k:lower()
		
		return _meta.FunctionButton.__methods[lk]
    end
end