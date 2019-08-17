_meta = _meta or {}
_meta.PopupSlider = {}
_meta.PopupSlider.__class = 'popup slider'
_meta.PopupSlider.__methods = {}

function PopupSlider(args) -- constructs the object, but does not initialize it
	local ps = {}
	ps._track = {}
	ps._track._class = 'popup slider'

	ps._track._x = args.x
	ps._track._y = args.y
	ps._track._height = args.height
	ps._track._var = args.var -- String
	
	ps._track._min = args.min
	ps._track._max = args.max
	
	-- height - (2 * spacing + 2(endcaps) + 3(handle))
	ps._track._track_length = args.height - 39
	--ps._track._track_length = args.height - 19 -- this is not the actual length of the track in pixels, but the number of positions the handle can be in
	
	ps._track._increment = args.increment or ((args.max - args.min) / ps._track._track_length)
	
	
	ps._track._button = args.button --or {['_track']={}}
	ps._track._click = false
	ps._track._drag = false
	
	ps._track._mouse_event = nil
	ps._track._update_event = nil
	
	--ps._track._suppress = false
	ps._track._update_command = args.command -- string or function

	return setmetatable(ps, _meta.PopupSlider)	
end

_meta.PopupSlider.__methods['draw'] = function(ps)
	ps._track._handle = ps:calc_handle()
	
	local self = tostring(ps)
	--
	for i, pos in ipairs{'top','mid','bot'} do
		name = '%s %s':format(self,pos)
		windower.prim.create(name)
		windower.prim.set_visibility(name, false)
		windower.prim.set_texture(name, GUI.complete_filepath('icon_palette_%s.png':format(pos)))	
		windower.prim.set_fit_to_texture(name, true)
	end

	-- Draw the box
	windower.prim.set_position('%s top':format(self), ps._track._x, ps._track._y)		-- position the top and middle segments
	windower.prim.set_position('%s mid':format(self), ps._track._x, ps._track._y + 3)
	
	windower.prim.set_repeat('%s mid':format(self), 1, math.floor((ps._track._height - 6) / 4)) 	-- expand middle segment
	windower.prim.set_fit_to_texture('%s mid':format(self), false)
	windower.prim.set_size('%s mid':format(self), 42, ps._track._height - 6)
	
	windower.prim.set_position('%s bot':format(self), ps._track._x, ps._track._y + ps._track._height - 3) -- position bottom segment
	
	-- Draw the track
	local name = '%s track top':format(self)
	windower.prim.create(name)
	windower.prim.set_visibility(name, false)
	windower.prim.set_texture(name, GUI.complete_filepath('Track_cap.png'))
	windower.prim.set_fit_to_texture(name, true)
	windower.prim.set_position(name, ps._track._x + 19, ps._track._y + 16)
	
	name = '%s track mid':format(self)
	windower.prim.create(name)
	windower.prim.set_visibility(name, false)
	windower.prim.set_texture(name, GUI.complete_filepath('Track_mid.png'))
	windower.prim.set_repeat(name, 1,  ps._track._track_length + 5)
	windower.prim.set_fit_to_texture(name, false)
	windower.prim.set_size(name, 3, ps._track._track_length + 5)
	windower.prim.set_position(name, ps._track._x + 19, ps._track._y + 17)
	
	name = '%s track bot':format(self)
	windower.prim.create(name)
	windower.prim.set_visibility(name, false)
	windower.prim.set_texture(name, GUI.complete_filepath('Track_cap.png'))
	windower.prim.set_fit_to_texture(name, true)
	windower.prim.set_position(name, ps._track._x + 19, ps._track._y + 17 + ps._track._track_length + 5) -- y + distance to the top of track + size of track + extra for handle

	-- Draw the handle
	name = '%s handle':format(self)
	windower.prim.create(name)
	windower.prim.set_visibility(name, false)
	windower.prim.set_texture(name, GUI.complete_filepath('Slider.png'))
	windower.prim.set_fit_to_texture(name, true)
	windower.prim.set_position(name, ps._track._x + 15, ps._track._y + 17 + ps._track._handle) -- y + distance to top of track + handle position
	
	-- Draw the header
	name = '%s header':format(self)
	windower.text.create(name)
	windower.text.set_font(name, 'Helvetica')
	windower.text.set_font_size(name, 9)
	windower.text.set_color(name, 255, 242, 242, 242)
	windower.text.set_text(name, tostring(ps._track._max))
	windower.text.set_visibility(name, false)
	windower.text.set_location(name, ps._track._x + 6, ps._track._y + 3)
	--windower.text.set_stroke_color(name, 255, 220, 220, 220)
	--windower.text.set_stroke_width(name, 0)
	windower.text.set_bold(name, false)
	
	-- Draw the footer
	name = '%s footer':format(self)
	windower.text.create(name)
	windower.text.set_font(name, 'Helvetica')
	windower.text.set_font_size(name, 9)
	windower.text.set_color(name, 255, 242, 242, 242)
	windower.text.set_text(name, tostring(ps._track._min))
	windower.text.set_visibility(name, false)
	windower.text.set_location(name, ps._track._x + 6, ps._track._y + 22 + ps._track._track_length)
	--windower.text.set_stroke_color(name, 255, 220, 220, 220)
	--windower.text.set_stroke_width(name, 0)
	windower.text.set_bold(name, false)
	
	--ps._track._event = GUI.register_mouse_listener(ps)
	--GUI.register_mouse_listener(ps)
end

_meta.PopupSlider.__methods['calc_handle'] = function(ps) -- returns the slider position associated with var's current value
	local h = ps._track._track_length
	local vmin = ps._track._min
	local vmax = ps._track._max
	local value = _G[ps._track._var]
	
	return h - ((value - vmin)/(vmax - vmin))
end

_meta.PopupSlider.__methods['slider_value'] = function(ps) -- returns the var value associated with the handle's current position
	local h = ps._track._track_length
	local vmin = ps._track._min
	local vmax = ps._track._max
	local n = ps._track._handle
	local i = ps._track._increment 
	
	local k = (1 - n/h) * (vmax - vmin) + vmin
	
	local m = k%i
	
	return (k - m) + ((m > i/2) and i or 0)
end

_meta.PopupSlider.__methods['show'] = function(ps)
	local self = tostring(ps)
	ps._track._shown = true
	for i, pos in ipairs{'top','mid','bot'} do
		windower.prim.set_visibility('%s %s':format(self, pos), true)
		windower.prim.set_visibility('%s track %s':format(self, pos), true)
	end
	for i, pos in ipairs{'header','footer'} do
		windower.text.set_visibility('%s %s':format(self, pos), true)
	end
	
	windower.prim.set_visibility('%s handle':format(self), true)
end

_meta.PopupSlider.__methods['hide'] = function(ps)
	local self = tostring(ps)
	ps._track._shown = false
	--ps._track._button._track._suppress = true
	for i, pos in ipairs{'top','mid','bot'} do
		windower.prim.set_visibility('%s %s':format(self, pos), false)
		windower.prim.set_visibility('%s track %s':format(self, pos), false)
	end
	for i, pos in ipairs{'header','footer'} do
		windower.text.set_visibility('%s %s':format(self, pos), false)
	end
	
	windower.prim.set_visibility('%s handle':format(self), false)
end

_meta.PopupSlider.__methods['on_mouse'] = function(ps, type, x, y, delta, blocked)
	if not (ps.shown or ps._track._click) then return end
	if ps._track._drag and ps.shown then -- the mouse is currently dragging the handle
		ps._track._handle = y - ps._track._y - 17 -- mouse_y - (top of box + distance to top of track)
		if ps._track._handle > ps._track._track_length then
			ps._track._handle = ps._track._track_length
		elseif ps._track._handle < 0 then
			ps._track._handle = 0
		end
		windower.prim.set_position('%s handle':format(tostring(ps)), ps._track._x + 15, ps._track._y + 17 + ps._track._handle) -- y + distance to top of track + handle position
		_G[ps._track._var] = ps:slider_value()
		ps._track._button:update()
		-- signal ps._track._button to update its value here
	end
	if type == 2 then
		ps._track._click = false
		ps._track._drag = false
		blocked = true
		return true
	elseif type == 1 then -- left click down
		-- figure out of the click is in our window
		-- if so, figure out what icon
		-- set the variable to the value for that icon
		-- block the click and ip:hide()
		-- if no icon, but in window, block the click and do nothing
		if x > ps._track._x and x < ps._track._x + 42 and y > ps._track._y and y < ps._track._y + ps._track._height then -- click is inside our window
			if x > ps._track._x + 5 and x < ps._track._x + 37 then -- within x bounds for icons -- used same bounds as icon pallete for convenience
				ps._track._drag = true
				ps._track._click = true
				blocked = true
				return true
			else
				return true -- click is in window, but not on an icon.  Block the click
			end
		else
			ps._track._button:unpress()
			ps._track._click = true
			blocked = true
			return true
		end			
	end
end

_meta.PopupSlider.__methods['update'] = function(ps)
	ps._track._handle = ps:calc_handle()
	windower.prim.set_position('%s handle':format(tostring(ps)), ps._track._x + 15, ps._track._y + 7 + ps._track._handle) -- y + distance to top of track + handle position
end

_meta.PopupSlider.__methods['undraw'] = function(ps)
	local self = tostring(ps)

	for i, pos in ipairs{'top','mid','bot'} do
		windower.prim.delete('%s %s':format(self,pos))
		windower.prim.delete('%s track %s':format(self, pos))
	end

	windower.prim.delete('%s handle':format(self))
	windower.text.delete('%s header':format(self))
	windower.text.delete('%s footer':format(self))

	--GUI.unregister_mouse_listener(ps._track._event)
	--GUI.unregister_mouse_listener(ps)
end

_meta.PopupSlider.__index = function(sb, k)
    if type(k) == 'string' then
        local lk = k:lower()
		
		if lk == 'shown' then
			return sb._track._shown
		else
			return _meta.PopupSlider.__methods[lk]
		end
    end
end
