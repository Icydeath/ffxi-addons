_meta = _meta or {}
_meta.IconButton = {}
_meta.IconButton.__class = 'icon_button'
_meta.IconButton.__methods = {}

function IconButton(args) -- constructs the object, but does not initialize it
	local ib = {}
	ib._track = {}
	ib._track._class = 'icon button'

	ib._track._x = args.x
	ib._track._y = args.y
	ib._track._var = args.var
	ib._track._state = args.var.value
	ib._track._icons = args.icons
	ib._track._mouse_event = nil
	ib._track._update_event = nil
	ib._track._pressed = false
	ib._track._suppress = false
	ib._track._update_command = args.command -- string or function
	ib._track._disabled = args.disabled or false
	ib._track._overlay = args.overlay --{img=filepath, hide_on_click = true}
	ib._track._show_overlay = false
	ib._track._on_click = args.on_click
	ib._track._direction = args.direction or 'west'
	
	return setmetatable(ib, _meta.IconButton)	
end

_meta.IconButton.__methods['draw'] = function(ib) -- Finishes initialization and draws the graphics
	local self = tostring(ib)
	-- draw the button
	windower.prim.create(self)
	windower.prim.set_visibility(self, true)
	windower.prim.set_position(self, ib._track._x, ib._track._y)
	windower.prim.set_texture(self, GUI.complete_filepath('icon_button.png'))
	windower.prim.set_fit_to_texture(self, true)
	-- blue square to darken the button when pressed
	local press = '%s press':format(self)
	windower.prim.create(press)
	windower.prim.set_visibility(press, false)
	windower.prim.set_position(press, ib._track._x + 3, ib._track._y + 3)
	windower.prim.set_color(press, 100, 0, 0, 127)
	windower.prim.set_size(press, 36, 36)
	-- draw the icons
	for ind, icon in ipairs(ib._track._icons) do
		local name = '%s %s':format(self, icon.value)
		windower.prim.create(name)
		windower.prim.set_visibility(name, false)
		windower.prim.set_position(name, ib._track._x + 5, ib._track._y + 5)
		windower.prim.set_texture(name, GUI.complete_filepath(icon.img))
		windower.prim.set_fit_to_texture(name, true)
	end	
	-- display the icon that is currently active
	windower.prim.set_visibility('%s %s':format(self, ib._track._var.value), true)
	
	-- draw overlay
	if ib._track._overlay then
		local overlay = '%s overlay':format(self)
		windower.prim.create(overlay)
		windower.prim.set_visibility(overlay, false)
		windower.prim.set_position(overlay, ib._track._x + 5, ib._track._y + 5)
		windower.prim.set_texture(overlay, GUI.complete_filepath(ib._track._overlay.img))
		windower.prim.set_fit_to_texture(overlay, true)
	end
	
	-- Initialize and draw the IconPalette
	local direction = ib._track._direction
	local palette_x = {
		west=ib._track._x - 54,
		east=ib._track._x + 54,
		north=ib._track._x,
		south=ib._track._x
	}
	local palette_y = {
		west=GUI.palette_y_align(ib._track._y, #ib._track._icons),
		east=GUI.palette_y_align(ib._track._y, #ib._track._icons),
		north=ib._track._y - 40 * #ib._track._icons - 14, -- y - height - 12 for padding
		south=ib._track._y + 54
	}
	
	ib._track._iconPalette = IconPalette{
		x		= palette_x[direction],--ib._track._x - 54,
		y		= palette_y[direction],--GUI.palette_y_align(ib._track._y, #ib._track._icons),
		var		= ib._track._var,
		icons	= ib._track._icons,
		button	= ib
		}
	ib._track._iconPalette:draw()
	--ib._track._mouse_event = GUI.register_mouse_listener(ib)
	--ib._track._update_event = GUI.register_update_object(ib)
	GUI.register_mouse_listener(ib)
	GUI.register_update_object(ib)
end

_meta.IconButton.__methods['new_icons'] = function(ib, icons, var)
	local self = tostring(ib)
	ib._track._var = var or ib._track._var
	
	-- Move the palette if necessary
	local direction = ib._track._direction
	local palette_x = {
		west=ib._track._x - 54,
		east=ib._track._x + 54,
		north=ib._track._x,
		south=ib._track._x
	}
	local palette_y = {
		west=GUI.palette_y_align(ib._track._y, #icons),
		east=GUI.palette_y_align(ib._track._y, #icons),
		north=ib._track._y - 40 * #icons - 14,
		south=ib._track._y + 54
	}
	ib._track._iconPalette._track._x = palette_x[direction]
	ib._track._iconPalette._track._y = palette_y[direction]
	
	-- delete the old icons
	for ind, icon in ipairs(ib._track._icons) do
		local name = '%s %s':format(self, icon.value)
		windower.prim.delete(name)
	end	
	-- give the new icons to the palette
	ib._track._iconPalette:new_icons(icons, var)
	ib._track._icons = icons
	-- draw the new icons
	for ind, icon in ipairs(ib._track._icons) do
		local name = '%s %s':format(self, icon.value)
		windower.prim.create(name)
		windower.prim.set_visibility(name, false)
		windower.prim.set_position(name, ib._track._x + 5, ib._track._y + 5)
		windower.prim.set_texture(name, GUI.complete_filepath(icon.img))
		windower.prim.set_fit_to_texture(name, true)
	end
	-- display the icon that is currently active
	--[[if not table.with(ib._track._icons, 'value', ib._track._var.value) then
		ib._track._var:set(ib._track._icons[1].value)
	end]]
	if table.with(ib._track._icons, 'value', ib._track._var.value) then
		windower.prim.set_visibility('%s %s':format(self, ib._track._var.value), true)
	end
end

_meta.IconButton.__methods['on_mouse'] = function(ib, type, x, y, delta, blocked)
	if ib._track._iconPalette:on_mouse(type, x, y, delta, blocked) then
		return true
	end
	if ib._track._disabled then return end
	if type == 1 then
		--[[if ib._track._suppress then
			ib._track._suppress = false
			return true
		--end]]
		if x > ib._track._x and x < ib._track._x + 42 and y > ib._track._y and y < ib._track._y + 42 then
			if ib._track._overlay and ib._track._overlay.hide_on_click and ib._track._show_overlay then
				ib:hideoverlay()
			end
			if ib._track._on_click then
				ib._track._on_click()
			end
			if ib._track._pressed then
				--ib:unpress()
				return true
			else
				ib:press()
				return true
			end
		end
	elseif type == 2 then
		if x > ib._track._x and x < ib._track._x + 42 and y > ib._track._y and y < ib._track._y + 42 then
			return true
		end
	end
	
	--return blocked
end

_meta.IconButton.__methods['hide'] = function(ib)
	if ib._track._iconPalette.shown then
		ib._track._iconPalette:hide() -- close this if it's open
	end
	windower.prim.set_visibility(tostring(ib), false) -- hide the frame
	windower.prim.set_visibility('%s press':format(tostring(ib)), false) -- hide the blue box
	for ind, icon in ipairs(ib._track._icons) do
		windower.prim.set_visibility('%s %s':format(tostring(ib), icon.value), false) -- hide all the icons
	end -- hide your husbands too
	if ib._track._overlay then
		ib:hideoverlay()
	end
end

_meta.IconButton.__methods['show'] = function(ib)
	windower.prim.set_visibility(tostring(ib), true)
	ib._track._pressed = false -- unpress the button
	for ind, icon in ipairs(ib._track._icons) do
		windower.prim.set_visibility('%s %s':format(tostring(ib),icon.value), icon.value == ib._track._var.value)
	end
end

_meta.IconButton.__methods['showoverlay'] = function(ib)
	windower.prim.set_visibility('%s overlay':format(tostring(ib)), true)
	ib._track._show_overlay = true
end

_meta.IconButton.__methods['hideoverlay'] = function(ib)
	windower.prim.set_visibility('%s overlay':format(tostring(ib)), false)
	ib._track._show_overlay = false
end

_meta.IconButton.__methods['disable'] = function(ib)
	ib._track._disabled = true
	--ib:hide()
end

_meta.IconButton.__methods['enable'] = function(ib)
	ib._track._disabled = false
	--ib:show()
end

_meta.IconButton.__methods['press'] = function(ib)
	-- visually depress the button
	ib._track._pressed = true
	windower.prim.set_visibility('%s press':format(tostring(ib)), true)
	ib._track._iconPalette:show()
end

_meta.IconButton.__methods['unpress'] = function(ib)
	ib._track._pressed = false
	windower.prim.set_visibility('%s press':format(tostring(ib)), false)
	ib._track._iconPalette:hide()
end

_meta.IconButton.__methods['select'] = function(ib)
	if ib._track._disabled then return end
	if ib._track._var.value ~= ib._track._state then
		for ind, icon in ipairs(ib._track._icons) do
			if icon.value == ib._track._var.value then
				windower.prim.set_visibility('%s %s':format(tostring(ib),icon.value), true)
			else
				windower.prim.set_visibility('%s %s':format(tostring(ib),icon.value), false)
			end
		end
		ib._track._state = ib._track._var.value
		if type(ib._track._update_command) == 'string' then
			windower.send_command(ib._track._update_command)
		elseif type(ib._track._update_command) == 'function' then
			ib._track._update_command()
		end
	end
end

_meta.IconButton.__methods['update'] = function(ib)
	if ib._track._disabled then return end
	if ib._track._var.value ~= ib._track._state then
		for ind, icon in ipairs(ib._track._icons) do
			if icon.value == ib._track._var.value then
				windower.prim.set_visibility('%s %s':format(tostring(ib),icon.value), true)
			else
				windower.prim.set_visibility('%s %s':format(tostring(ib),icon.value), false)
			end
		end
		ib._track._state = ib._track._var.value
	end
end

_meta.IconButton.__methods['undraw'] = function(ib)
	local self = tostring(ib)
	windower.prim.delete(self)
	windower.prim.delete('%s press':format(self))
	for ind, icon in ipairs(ib._track._icons) do
		windower.prim.delete('%s %s':format(self, icon.value))
	end
	if ib._track._overlay then
		windower.prim.delete('%s overlay':format(self))
	end
	ib._track._iconPalette:undraw()
	GUI.unregister_mouse_listener(ib)--._track._mouse_event)
	GUI.unregister_update_object(ib)--._track._update_event)	
end

function GUI.palette_y_align(y, size)
	y_size = 40 * size + 2
	if y - y_size/2 + 21 < GUI.bound.y.lower then
		return GUI.bound.y.lower
	elseif y + y_size/2 + 21 > GUI.bound.y.upper then
		return GUI.bound.y.upper - y_size
	else
		return y - y_size/2 + 21
	end
end

function GUI.palette_x_align(x, size) -- Will be used when horizontal palettes are implemented
	x_size = 40 * size + 2
	if x - x_size/2 + 21 < GUI.bound.x.lower then
		return GUI.bound.y.lower
	elseif x + x_size/2 + 21 > GUI.bound.x.upper then
		return GUI.bound.x.upper - y_size
	else
		return x - x_size/2 + 21
	end
end

_meta.IconButton.__index = function(ib, k)
    if type(k) == 'string' then
        local lk = k:lower()
		
		if lk == 'disabled' then
			return ib._track._disabled
		end
		
		if lk == 'command' then
			return ib._track._update_command
		end
		
		return _meta.IconButton.__methods[lk]
		
		
        --[[if lk == 'current' then
            return m[m._track._current]
        elseif lk == 'value' then
            if m._track._type == 'boolean' then
                return m._track._current
            else
                return m[m._track._current]
            end
        elseif lk == 'has_value' then
            return _meta.M.__methods.f_has_value(m)
        elseif lk == 'default' then
            if m._track._type == 'boolean' then
                return m._track._default
            else
                return m[m._track._default]
            end
        elseif lk == 'description' then
            return m._track._description
        elseif lk == 'index' then
            return m._track._current
        elseif m._track[lk] then
            return m._track[lk]
        elseif m._track['_'..lk] then
            return m._track['_'..lk]
        else
            return _meta.M.__methods[lk]
        end]]
    end
end