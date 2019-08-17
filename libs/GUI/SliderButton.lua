_meta = _meta or {}
_meta.SliderButton = {}
_meta.SliderButton.__class = 'slider_button'
_meta.SliderButton.__methods = {}

function SliderButton(args) -- constructs the object, but does not initialize it
	local sb = {}
	sb._track = {}
	sb._track._class = 'slider button'

	sb._track._x = args.x
	sb._track._y = args.y
	sb._track._height = args.height
	sb._track._var = args.var
	sb._track._min = args.min
	sb._track._max = args.max
	sb._track._increment = args.increment
	
	sb._track._icon = args.icon
	
	sb._track._mouse_event = nil
	sb._track._update_event = nil
	sb._track._pressed = false
	sb._track._suppress = false
	sb._track._update_command = args.command -- string or function
	sb._track._disabled = args.disabled or false
	sb._track._overlay = args.overlay --{img=filepath, hide_on_click = true}
	sb._track._show_overlay = false
	sb._track._direction = args.direction or 'west'
	--sb._track._on_click = args.on_click
	return setmetatable(sb, _meta.SliderButton)	
end

_meta.SliderButton.__methods['draw'] = function(sb) -- Finishes initialization and draws the graphics
	local self = tostring(sb)
	-- draw the button
	windower.prim.create(self)
	windower.prim.set_visibility(self, true)
	windower.prim.set_position(self, sb._track._x, sb._track._y)
	windower.prim.set_texture(self, GUI.complete_filepath('icon_button.png'))
	windower.prim.set_fit_to_texture(self, true)
	-- blue square to darken the button when pressed
	local press = '%s press':format(self)
	windower.prim.create(press)
	windower.prim.set_visibility(press, false)
	windower.prim.set_position(press, sb._track._x + 3, sb._track._y + 3)
	windower.prim.set_color(press, 100, 0, 0, 127)
	windower.prim.set_size(press, 36, 36)
	-- draw the icon
	
	if sb._track._icon then
		local icon = '%s icon':format(self)
		windower.prim.create(icon)
		windower.prim.set_visibility(icon, true)
		windower.prim.set_position(icon, sb._track._x + 5, sb._track._y + 5)
		windower.prim.set_texture(icon, GUI.complete_filepath(sb._track._icon))
		windower.prim.set_fit_to_texture(icon, true)
	end
	
	-- draw overlay
	if sb._track._overlay then
		local overlay = '%s overlay':format(self)
		windower.prim.create(overlay)
		windower.prim.set_visibility(overlay, false)
		windower.prim.set_position(overlay, sb._track._x + 5, sb._track._y + 5)
		windower.prim.set_texture(overlay, GUI.complete_filepath(sb._track._overlay.img))
		windower.prim.set_fit_to_texture(overlay, true)
	end
	
	local text = '%s text':format(self)
	windower.text.create(text)
	windower.text.set_font(text, 'Helvetica')
	windower.text.set_font_size(text, 10)
	windower.text.set_color(text, 255, 253, 252, 250)
	windower.text.set_text(text, _G[sb._track._var])
	windower.text.set_visibility(text, true)
	windower.text.set_location(text, sb._track._x + 5, sb._track._y + 6)
	windower.text.set_bold(text, true)
	windower.text.set_stroke_color(text, 255, 0, 0, 0)
	windower.text.set_stroke_width(text, 1)
	
	-- Initialize and draw the PopupSlider
	local direction = sb._track._direction
	local palette_x = {
		west=sb._track._x - 54,
		east=sb._track._x + 54,
		north=sb._track._x,
		south=sb._track._x
	}
	local palette_y = {
		west=slider_y_align(sb._track._y, sb._track._height),
		east=slider_y_align(sb._track._y, sb._track._height),
		north=sb._track._y - sb._track._height - 12, -- y - height - 12 for padding
		south=sb._track._y + 54
	}
	
	sb._track._popupSlider = PopupSlider{
		x		= palette_x[direction], --sb._track._x - 54,
		y		= palette_y[direction], --slider_y_align(sb._track._y, sb._track._height),
		var		= sb._track._var,
		height 	= sb._track._height,
		button	= sb,
		min		= sb._track._min,
		max		= sb._track._max,
		increment=sb._track._increment,
		}
	sb._track._popupSlider:draw()
	
	--sb._track._mouse_event = GUI.register_mouse_listener(sb)
	--sb._track._update_event = GUI.register_update_object(sb)
	GUI.register_mouse_listener(sb)
	GUI.register_update_object(sb)
	
end

_meta.SliderButton.__methods['on_mouse'] = function(sb, type, x, y, delta, blocked)
	if sb._track._popupSlider:on_mouse(type, x, y, delta, blocked) then
		return true
	end
	if sb._track._disabled then return end
	if type == 1 then
		--[[if sb._track._suppress then
			sb._track._suppress = false
			return true
		end]]
		if x > sb._track._x and x < sb._track._x + 42 and y > sb._track._y and y < sb._track._y + 42 then
			if sb._track._overlay and sb._track._overlay.hide_on_click and sb._track._show_overlay then
				sb:hideoverlay()
			end
			if sb._track._on_click then
				sb._track._on_click()
			end
			if sb._track._pressed then
				--sb:unpress()
				return true
			else
				sb:press()
				return true
			end
		end
	elseif type == 2 then
		if x > sb._track._x and x < sb._track._x + 42 and y > sb._track._y and y < sb._track._y + 42 then
			return true
		end
	end
end

_meta.SliderButton.__methods['hide'] = function(sb)
	if sb._track._popupSlider.shown then
		sb._track._popupSlider:hide() -- close this if it's open
	end
	windower.prim.set_visibility(tostring(sb), false) -- hide the frame
	windower.prim.set_visibility('%s press':format(tostring(sb)), false) -- hide the blue box
	for ind, icon in ipairs(sb._track._icons) do
		windower.prim.set_visibility('%s %s':format(tostring(sb), icon.value), false) -- hide all the icons
	end -- hide your husbands too
	if sb._track._overlay then
		sb:hideoverlay()
	end
end

_meta.SliderButton.__methods['show'] = function(sb)
	windower.prim.set_visibility(tostring(sb), true)
	sb._track._pressed = false -- unpress the button
	for ind, icon in ipairs(sb._track._icons) do
		windower.prim.set_visibility('%s %s':format(tostring(sb),icon.value), icon.value == _G[sb._track._var])
	end
end

_meta.SliderButton.__methods['showoverlay'] = function(sb)
	windower.prim.set_visibility('%s overlay':format(tostring(sb)), true)
	sb._track._show_overlay = true
end

_meta.SliderButton.__methods['hideoverlay'] = function(sb)
	windower.prim.set_visibility('%s overlay':format(tostring(sb)), false)
	sb._track._show_overlay = false
end

_meta.SliderButton.__methods['disable'] = function(sb)
	sb._track._disabled = true
	--ib:hide()
end

_meta.SliderButton.__methods['enable'] = function(sb)
	sb._track._disabled = false
	--ib:show()
end

_meta.SliderButton.__methods['press'] = function(sb)
	-- visually depress the button
	sb._track._pressed = true
	windower.prim.set_visibility('%s press':format(tostring(sb)), true)
	sb._track._popupSlider:show()
end

_meta.SliderButton.__methods['unpress'] = function(sb)
	sb._track._pressed = false
	windower.prim.set_visibility('%s press':format(tostring(sb)), false)
	sb._track._popupSlider:hide()
end

_meta.SliderButton.__methods['select'] = function(sb)
	if sb._track._disabled then return end
	if _G[sb._track._var] ~= sb._track._state then
		for ind, icon in ipairs(sb._track._icons) do
			if icon.value == _G[sb._track._var] then
				windower.prim.set_visibility('%s %s':format(tostring(sb),icon.value), true)
			else
				windower.prim.set_visibility('%s %s':format(tostring(sb),icon.value), false)
			end
		end
		if type(sb._track._update_command) == 'string' then
			windower.send_command(sb._track._update_command)
		elseif type(sb._track._update_command) == 'function' then
			sb._track._update_command()
		end
		sb._track._state = _G[sb._track._var]
	end
end

_meta.SliderButton.__methods['update'] = function(sb)
	if sb._track._disabled then return end	
	if _G[sb._track._var] ~= sb._track._state then
		--[[for ind, icon in ipairs(sb._track._icons) do
			if icon.value == _G[sb._track._var] then
				windower.prim.set_visibility('%s %s':format(tostring(sb),icon.value), true)
			else
				windower.prim.set_visibility('%s %s':format(tostring(sb),icon.value), false)
			end
		--end]]
		sb._track._state = _G[sb._track._var]
		windower.text.set_text('%s text':format(tostring(sb)), _G[sb._track._var])
		
		if type(sb._track._update_command) == 'string' then
			windower.send_command(sb._track._update_command)
		elseif type(sb._track._update_command) == 'function' then
			sb._track._update_command()
		end
		--sb._track._popupSlider:update()
	end
end

_meta.SliderButton.__methods['undraw'] = function(sb)
	self = tostring(sb)
	windower.prim.delete(self)
	windower.prim.delete('% press':format(self))
	
	if sb._track._icon then
		windower.prim.delete('%s icon':format(self))
	end
	
	if sb._track._overlay then
		windower.prim.delete('%s overlay':format(self))
	end
	
	windower.text.delete('%s text':format(self))

	sb._track._popupSlider:undraw()
	
	--GUI.unregister_mouse_listener(sb._track._mouse_event)
	--GUI.unregister_update_object(sb._track._update_event)
	GUI.unregister_mouse_listener(sb)
	GUI.unregister_update_object(sb)
end

function slider_y_align(y, size)
	y_size = size
	if y - y_size/2 + 21 < GUI.bound.y.lower then
		return GUI.bound.y.lower
	elseif y + y_size/2 + 21 > GUI.bound.y.upper then
		return GUI.bound.y.upper - y_size
	else
		return y - y_size/2 + 21
	end
end

_meta.SliderButton.__index = function(sb, k)
    if type(k) == 'string' then
        local lk = k:lower()
		
		if lk == 'disabled' then
			return sb._track._disabled
		end
		
		if lk == 'command' then
			return sb._track._update_command
		end
		
		return _meta.SliderButton.__methods[lk]
    end
end