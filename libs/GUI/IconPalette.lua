_meta = _meta or {}
_meta.IconPalette = {}
_meta.IconPalette.__class = 'icon_palette'
_meta.IconPalette.__methods = {}

function IconPalette(args)
    local ip = {}
    ip._track = {}
    ip._track._class = 'icon palette'
	
	--local args = {...}
	ip._track._x = args.x
	ip._track._y = args.y
	ip._track._var = args.var
	ip._track._icons = args.icons -- icons={ {img = 'filepath', value = 'Rostam/Kaja'} }
	ip._track._button = args.button
	ip._track._shown = false
	ip._track._event = nil
	ip._track._click = false
	ip._track._tt_shown = false -- true when tooltip is displayed
	--ip._track._block_click = false
	
    return setmetatable(ip, _meta.IconPalette)
end

_meta.IconPalette.__methods['draw'] = function(ip)
	local self = tostring(ip)
	--
	for i, pos in ipairs{'top','mid','bot'} do
		name = '%s %s':format(self,pos)
		windower.prim.create(name)
		windower.prim.set_visibility(name, false)
		windower.prim.set_texture(name, GUI.complete_filepath('icon_palette_%s.png':format(pos)))	
		windower.prim.set_fit_to_texture(name, true)
	end
	
	--windower.prim.create('%s mid':format(self))
	--windower.prim.set_visibility('%s mid':format(self),false)
	
	
	windower.prim.set_position('%s top':format(self), ip._track._x, ip._track._y)		-- position the top and middle segments
	windower.prim.set_position('%s mid':format(self), ip._track._x, ip._track._y + 3)
	
	local icon_count = #ip._track._icons
	
	windower.prim.set_repeat('%s mid':format(self), 1, 10 * icon_count - 1) 	-- expand middle segment
	windower.prim.set_fit_to_texture('%s mid':format(self), false)
	windower.prim.set_size('%s mid':format(self), 42, 40 * icon_count - 4)
	
	
	
	
	windower.prim.set_position('%s bot':format(self), ip._track._x, ip._track._y - 1 + 40 * icon_count) -- position bottom segment
	
	for ind, icon in ipairs(ip._track._icons) do
		name = '%s %s':format(self,ind)
		windower.prim.create(name)
		windower.prim.set_visibility(name, false)
		windower.prim.set_texture(name, GUI.complete_filepath(icon.img)) -- looks in data/graphics for icon.img
		windower.prim.set_fit_to_texture(name, true)
		windower.prim.set_position(name, ip._track._x + 5, ip._track._y + 5 + (ind - 1) * 40)
	end
	
	local tooltip = '%s tooltip':format(self)
	windower.text.create(tooltip)
	
	windower.text.set_font(tooltip, 'Helvetica')
	windower.text.set_stroke_color(tooltip, 127, 18, 97, 136)
	windower.text.set_stroke_width(tooltip, 1)
	windower.text.set_color(tooltip, 255, 253, 252, 250)
	windower.text.set_font_size(tooltip, 10)
	windower.text.set_visibility(tooltip, false)
	
	--ip._track._event = GUI.register_mouse_listener(ip)
	--GUI.register_mouse_listener(ip)
end

_meta.IconPalette.__methods['new_icons'] = function(ip, icons, var)
	local self = tostring(ip)
	ip._track._var = var or ip._track._var
	for ind, icon in ipairs(ip._track._icons) do
		name = '%s %s':format(self,ind)
		windower.prim.delete(name)
	end
	
	ip._track._icons = icons
	
	for i, pos in ipairs{'top','mid','bot'} do
		name = '%s %s':format(self,pos)
		windower.prim.set_visibility(name, false)
		--windower.prim.set_texture(name, GUI.complete_filepath('icon_palette_%s.png':format(pos)))	
		--windower.prim.set_fit_to_texture(name, true)
	end	
	
	windower.prim.set_position('%s top':format(self), ip._track._x, ip._track._y)		-- position the top and middle segments
	windower.prim.set_position('%s mid':format(self), ip._track._x, ip._track._y + 3)
	
	local icon_count = #ip._track._icons
	
	windower.prim.set_repeat('%s mid':format(self), 1, 10 * icon_count - 1) 	-- expand middle segment
	windower.prim.set_fit_to_texture('%s mid':format(self), false)
	windower.prim.set_size('%s mid':format(self), 42, 40 * icon_count - 4)	
	
	windower.prim.set_position('%s bot':format(self), ip._track._x, ip._track._y - 1 + 40 * icon_count) -- position bottom segment
	
	for ind, icon in ipairs(ip._track._icons) do
		name = '%s %s':format(self,ind)
		windower.prim.create(name)
		windower.prim.set_visibility(name, false)
		windower.prim.set_texture(name, GUI.complete_filepath(icon.img)) -- looks in data/graphics for icon.img
		windower.prim.set_fit_to_texture(name, true)
		windower.prim.set_position(name, ip._track._x + 5, ip._track._y + 5 + (ind - 1) * 40)
	end
end

_meta.IconPalette.__methods['show'] = function(ip)
	local self = tostring(ip)
	ip._track._shown = true
	for i, pos in ipairs{'top','mid','bot'} do
		windower.prim.set_visibility('%s %s':format(self,pos), true)	
	end
	
	for ind, icon in ipairs(ip._track._icons) do
		windower.prim.set_visibility('%s %s':format(self,ind), true)
	end
	--ip._track._event = GUI.register_mouse_listener(ip) -- start listening for mouse events
end

_meta.IconPalette.__methods['hide'] = function(ip)
	local self = tostring(ip)
	ip._track._shown = false
	--ip._track._button._track._suppress = true
	
	for i, pos in ipairs{'top','mid','bot'} do
		windower.prim.set_visibility('%s %s':format(self,pos), false)	
	end
	
	for ind, icon in ipairs(ip._track._icons) do
		windower.prim.set_visibility('%s %s':format(self,ind), false)
	end
	
	windower.text.set_visibility('%s tooltip':format(self), false)
	--GUI.unregister_mouse_listener(ip._track._event)
end

_meta.IconPalette.__methods['on_mouse'] = function(ip, type, x, y, delta, blocked)
	if not (ip.shown or ip._track._click) then return end	
	if type == 2 then
		ip._track._click = false
		blocked = true
		return true
	elseif type == 1 then -- left click down
		-- figure out of the click is in our window
		-- if so, figure out what icon
		-- set the variable to the value for that icon
		-- block the click and ip:hide()
		-- if no icon, but in window, block the click and do nothing
		if x > ip._track._x and x < ip._track._x + 42 and y > ip._track._y and y < ip._track._y + 2 + 40 * #ip._track._icons then -- click is inside our window
			if x > ip._track._x + 5 and x < ip._track._x + 37 then -- within x bounds for icons
				for ind, icon in ipairs(ip._track._icons) do
					if y > ip._track._y + 5 + 40 * (ind - 1) and y < ip._track._y + 37 + 40 * (ind - 1) then
						ip._track._var:set(icon.value)	-- var is a mode from Modes.lua
						--print('select %s':format(icon.value))
						ip._track._button:select()
						ip._track._button:unpress()
						--ip:hide()
						ip._track._click = true
						blocked = true
						return true
					end
				end
				return true -- click was either handled, or should do nothing.  Either way, block the click
			else
				return true -- click is in window, but not on an icon.  Block the click
			end
		else
			ip._track._button:unpress()
			--ip:hide()
			ip._track._click = true
			blocked = true
			return true
		end
	else -- tooltip stuff
		if x > ip._track._x and x < ip._track._x + 42 and y > ip._track._y and y < ip._track._y + 2 + 40 * #ip._track._icons then -- click is inside our window
			if not ip._track._hover then
				ip._track._hover = os.clock() + 1
			end
			if os.clock() > ip._track._hover then -- if we've hovered long enough to show a tooltip
				if x > ip._track._x + 5 and x < ip._track._x + 37 then -- within x bounds for icons
					for ind, icon in ipairs(ip._track._icons) do
						if y > ip._track._y + 5 + 40 * (ind - 1) and y < ip._track._y + 37 + 40 * (ind - 1) then
							if icon.tooltip and ip._track._tt_shown ~= ind then
								windower.text.set_location('%s tooltip':format(tostring(ip)), x, y)
								windower.text.set_text('%s tooltip':format(tostring(ip)), icon.tooltip)
								windower.text.set_visibility('%s tooltip':format(tostring(ip)), true)
								ip._track._tt_shown = ind
							end
						end
					end
				end
			end
		elseif ip._track._hover then
			ip._track._hover = nil
			ip._track._tt_shown = false
			windower.text.set_visibility('%s tooltip':format(tostring(ip)), false)
		end
	end
end

_meta.IconPalette.__methods['undraw'] = function(ip)
	local self = tostring(ip)
	windower.prim.delete('%s top':format(self))
	windower.prim.delete('%s mid':format(self))
	windower.prim.delete('%s bot':format(self))
	for ind, icon in ipairs(ip._track._icons) do
		windower.prim.delete('%s %s':format(self,ind))
	end
	windower.text.delete('%s tooltip':format(self))
	--GUI.unregister_mouse_listener(ip._track._event)
	--GUI.unregister_mouse_listener(ip)
end

_meta.IconPalette.__index = function(ip, k)
    if type(k) == 'string' then
        local lk = k:lower()
		
		if lk == 'shown' then
			return ip._track._shown
		else
			return _meta.IconPalette.__methods[lk]
		end
		
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