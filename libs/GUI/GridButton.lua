_meta = _meta or {}
_meta.GridButton = {}
_meta.GridButton.__class = 'grid button'
_meta.GridButton.__methods = {}

function GridButton(args)
	local gb = {}
	gb._track = {}
	gb._track._class = 'grid button'
	
	gb._track._x = args.x
	gb._track._y = args.y
	gb._track._var = args.var
	gb._track._state = args.var.value
	gb._track._icons = args.icons
	gb._track._pressed = false
	gb._track._suppress = false
	gb._track._update_command = args.command
	gb._track._disabled = args.disabled or false
	gb._track._overlay = args.overlay
	gb._track._show_overlay = false
	gb._track._on_click = args.on_click
	gb._track._direction = args.direction or 'west'
	
	return setmetatable(gb, _meta.GridButton)
end

_meta.GridButton.__methods['draw'] = function(gb)
	local self = tostring(gb)
	-- draw the button
	windower.prim.create(self)
	windower.prim.set_visibility(self, true)
	windower.prim.set_position(self, gb._track._x, gb._track._y)
	windower.prim.set_texture(self, GUI.complete_filepath('icon_button.png'))
	windower.prim.set_fit_to_texture(self, true)
	-- blue square to darken the button when pressed
	local press = '%s press':format(self)
	windower.prim.create(press)
	windower.prim.set_visibility(press, false)
	windower.prim.set_position(press, gb._track._x + 3, gb._track._y + 3)
	windower.prim.set_color(press, 100, 0, 0, 127)
	windower.prim.set_size(press, 36, 36)
	-- draw the icons
	for i, col in ipairs(gb._track._icons) do
		for j, icon in ipairs(col) do
			local name = '%s %s':format(self, icon.value)
			windower.prim.create(name)
			windower.prim.set_visibility(name, false)
			windower.prim.set_position(name, gb._track._x + 5, gb._track._y + 5)
			windower.prim.set_texture(name, GUI.complete_filepath(icon.img))
			windower.prim.set_fit_to_texture(name, true)
		end
	end	
	-- display the icon that is currently active
	windower.prim.set_visibility('%s %s':format(self, gb._track._var.value), true)
	
	-- draw overlay
	if gb._track._overlay then
		local overlay = '%s overlay':format(self)
		windower.prim.create(overlay)
		windower.prim.set_visibility(overlay, false)
		windower.prim.set_position(overlay, gb._track._x + 5, gb._track._y + 5)
		windower.prim.set_texture(overlay, GUI.complete_filepath(gb._track._overlay.img))
		windower.prim.set_fit_to_texture(overlay, true)
	end
	
	-- palette align functions are found in IconButton.lua.
	local direction = gb._track._direction
	local palette_x = {
		west=gb._track._x - 40 * #gb._track._icons - 14,
		east=gb._track._x + 54,
		north=GUI.palette_x_align(gb._track._x, #gb._track._icons),
		south=GUI.palette_x_align(gb._track._x, #gb._track._icons)
	}
	local rows = table.max(table.map(gb._track._icons, function(x) return #x end))
	local palette_y = {
		west=GUI.palette_y_align(gb._track._y, rows),
		east=GUI.palette_y_align(gb._track._y, rows),
		north=gb._track._y - 40 * rows - 14, 
		south=gb._track._y + 54
	}
	gb._track._iconGrid = IconGrid{
		x		= palette_x[direction],
		y		= palette_y[direction],
		var		= gb._track._var,
		icons	= gb._track._icons,
		button	= gb
	}
	gb._track._iconGrid:draw()
	
	GUI.register_mouse_listener(gb)
	GUI.register_update_object(gb)
end

_meta.GridButton.__methods['new icons'] = function(gb, icons, var)
	local self = tostring(gb)
	gb._track._var = var or gb._track._var
	
	-- Move the icongrid
	local direction = gb._track._direction
	local palette_x = {
		west=gb._track._x - 40 * #gb._track._icons - 14,
		east=gb._track._x + 54,
		north=GUI.palette_x_align(gb._track._x, #gb._track._icons),
		south=GUI.palette_x_align(gb._track._x, #gb._track._icons)
	}
	local rows = table.max(table.map(gb._track._icons, function(x) return #x end))
	local palette_y = {
		west=GUI.palette_y_align(gb._track._y, rows),
		east=GUI.palette_y_align(gb._track._y, rows),
		north=gb._track._y - 40 * rows - 14, 
		south=gb._track._y + 54
	}
	gb._track._iconGrid._tarck._x = palette_x[direction]
	gb._track._iconGrid._track._y = palette_y[direction]
	
	-- delete old icons
	for i, col in ipairs(gb._track._icons) do
		for j, icon in ipairs(col) do
			local name = '%s %s':format(self, icon.value)
			windower.prim.delete(name)
		end
	end
	
	-- Pass new icons to the grid
	gb._track._iconGrid:new_icons(icons, var)
	gb._track._icons = icons
	
	-- Draw new icons
	for i, col in ipairs(gb._track._icons) do
		for j, icon in ipairs(col) do
			local name = '%s %s':format(self, icon.value)
			windower.prim.create(name)
			windower.prim.set_visibility(name, false)
			windower.prim.set_position(name, gb._track._x + 5, gb._track._y + 5)
			windower.prim.set_texture(name, GUI.complete_filepath(icon.img))
			windower.prim.set_fit_to_texture(name, true)
		end
	end	
	
	-- will gb._track._var.value be in scope here?  It would in python
	if not gb._track._icons:map(function(col) return table.with(col, 'value', gb._track._var.value) and true or false end):contains(true) then
		gb._track._var:set(gb._track._icons[1][1].value)
	end
	windower.prim.set_visibility('%s %s':format(self, gb._track._var.value), true)
end

_meta.GridButton.__methods['on_mouse'] = function(gb, type, x, y, delta, blocked)
	-- give our mouse input to the IconGrid first
	if gb._track._iconGrid:on_mouse(type, x, y, delta, blocked) then
		return true
	end
	if gb._track._disabled then return end
	if type == 1 then
		if x > gb._track._x and x < gb._track._x + 42 and y > gb._track._y and y < gb._track._y + 42 then
			if gb._track._overlay and gb._track._overlay.hide_on_click and gb._track._show_overlay then
				gb:hideoverlay()
			end
			if gb._track._on_click then
				gb._track._on_click()
			end
			if gb._track._pressed then
				return true
			else
				gb:press()
				return true
			end
		end
	elseif type == 2 then
		if x > gb._track._x and x < gb._track._x + 42 and y > gb._track._y and y < gb._track._y + 42 then
			return true
		end
	end
end

_meta.GridButton.__methods['hide'] = function(gb)
	if gb._track._iconGrid.shown then
		gb._track._iconGrid:hide() -- close this if it's open
	end
	windower.prim.set_visibility(tostring(gb), false) -- hide the frame
	windower.prim.set_visibility('%s press':format(tostring(gb)), false) -- hide the blue box
	for i, col in ipairs(gb._track._icons) do
		for j, icon in ipairs(col) do
			windower.prim.set_visibility('%s %s':format(tostring(gb), icon.value), false) -- hide all the icons
		end
	end 
	if gb._track._overlay then
		gb:hideoverlay()
	end	
end

_meta.GridButton.__methods['show'] = function(gb)
	local self = tostring(gb)
	windower.prim.set_visibility(self, true)
	gb._track._pressed = false
	windower.prim.set_visibility('%s %s':format(self, gb._track._var.value), true)
end

_meta.GridButton.__methods['showoverlay'] = function(gb)
	windower.prim.set_visibility('%s overlay':format(tostring(gb)), true)
	gb._track._show_overlay = true
end

_meta.GridButton.__methods['hideoverlay'] = function(gb)
	windower.prim.set_visibility('%s overlay':format(tostring(gb)), false)
	gb._track._show_overlay = false
end

_meta.GridButton.__methods['disable'] = function(gb)
	gb._track._disabled = true
end

_meta.GridButton.__methods['enable'] = function(gb)
	gb._track._disabled = false
end

_meta.GridButton.__methods['press'] = function(gb)
	gb._track._pressed = true
	windower.prim.set_visibility('%s press':format(tostring(gb)), true)
	gb._track._iconGrid:show()
end

_meta.GridButton.__methods['unpress'] = function(gb)
	gb._track._pressed = false
	windower.prim.set_visibility('%s press':format(tostring(gb)), false)
	gb._track._iconGrid:hide()
end

_meta.GridButton.__methods['select'] = function(gb)
	if gb._track._disabled then return end
	if gb._track._var.value ~= gb._track._state then
		for i, col in ipairs(gb._track._icons) do
			for j, icon in ipairs(col) do
				windower.prim.set_visibility('%s %s':format(tostring(gb), icon.value),
				icon.value == gb._track._var.value)
			end
		end
		gb._track._state = gb._track._var.value
		if type(gb._track._update_command) == 'string' then
			windower.send_command(gb._track._update_command)
		elseif type(gb._track._update_command) == 'function' then
			gb._track._update_command()
		end
	end
end

_meta.GridButton.__methods['update'] = function(gb)
	if gb._track._disabled then return end
	if gb._track._var.value ~= gb._track._state then
		for i, col in ipairs(gb._track._icons) do
			for j, icon in ipairs(col) do
				windower.prim.set_visibility('%s %s':format(tostring(gb), icon.value),
				icon.value == gb._track._var.value)
			end
		end
		gb._track._state = gb._track._var.value
	end
end

_meta.GridButton.__methods['undraw'] = function(gb)
	local self = tostring(gb)
	windower.prim.delete(self)
	windower.prim.delete('%s press':format(self))
	for i, col in ipairs(gb._track._icons)do 
		for j, icon in ipairs(col) do
			windower.prim.delete('%s %s':format(self, icon.value))
		end
	end
	if gb._track._overlay then
		windower.prim.delete('%s overlay':format(self))
	end
	gb._track._iconGrid:undraw()
	GUI.unregister_mouse_listener(gb)
	GUI.unregister_update_object(gb)
end

_meta.GridButton.__index = function(gb, k)
    if type(k) == 'string' then
        local lk = k:lower()
		
		if lk == 'disabled' then
			return gb._track._disabled
		end
		
		if lk == 'command' then
			return gb._track._update_command
		end
		
		return _meta.GridButton.__methods[lk]
    end
end

