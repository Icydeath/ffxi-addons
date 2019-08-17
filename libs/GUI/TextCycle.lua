_meta = _meta or {}
_meta.TextCycle = {}
_meta.TextCycle.__class = 'text_cycle'
_meta.TextCycle.__methods = {}

function TextCycle(args) -- constructs the object, but does not initialize it
	local tc = {}
	tc._track = {}
	tc._track._class = 'text cycle'

	tc._track._x = args.x
	tc._track._y = args.y
	tc._track._var = args.var -- should be a 'Mode' object
	
	tc._track._widths = {}
	
	tc._track._leftarrow = {}
	tc._track._rightarrow = {}
	
	tc._track._minwidth = args.width or 0
	
	tc._track._drawn = false
	
	tc._track._align = args.align:lower() or 'left'
	
	tc._track._mouse_id = nil
	tc._track._update_id = nil
	
	tc._track._update_command = args.command
	
	tc._track._disabled = args.disabled
	tc._track._start_hidden = args.start_hidden
	
	return setmetatable(tc, _meta.TextCycle)	
end

_meta.TextCycle.__methods['draw'] = function(tc) -- Finishes initialization and draws the graphics
	local self = tostring(tc)
	
	--draw the arrows
	local left = '%s left':format(self)
	local right = '%s right':format(self)
	
	windower.prim.create(left)
	windower.prim.create(right)
	windower.prim.set_texture(left, GUI.complete_filepath('Left Arrow.png'))
	windower.prim.set_texture(right, GUI.complete_filepath('Right Arrow.png'))
	windower.prim.set_fit_to_texture(left, true)
	windower.prim.set_fit_to_texture(right, true)
	
	local desc = '%s desc':format(self)
	windower.text.create(desc)
	windower.text.set_font(desc, 'Helvetica')
	windower.text.set_stroke_color(desc, 127, 18, 97, 136)
	windower.text.set_stroke_width(desc, 1)
	windower.text.set_color(desc, 255, 253, 252, 250)
	windower.text.set_font_size(desc, 10)
	
	--windower.text.set_location(desc, pt._track._x, pt._track._y)
	windower.text.set_text(desc, tc._track._var.description)
	windower.text.set_visibility(self, true)
	
	for i, v in ipairs(tc._track._var) do
		local name = '%s %i':format(self, i)
		windower.text.create(name)
		windower.text.set_font(name, 'Helvetica')
		windower.text.set_stroke_color(name, 127, 18, 97, 136)
		windower.text.set_stroke_width(name, 1)
		windower.text.set_color(name, 255, 253, 252, 250)
		windower.text.set_font_size(name, 10)
		windower.text.set_text(name, v)
	end
	
	--tc._track._update_id = GUI.register_update_object(tc)
	GUI.register_update_object(tc)
	
end

_meta.TextCycle.__methods['hide'] = function(tc)
	self = tostring(tc)
	windower.text.set_visibility('%s desc':format(self), false)
	windower.prim.set_visibility('%s left':format(self), false)
	windower.prim.set_visibility('%s right':format(self), false)
	for i, v in ipairs(tc._track._var) do
		windower.text.set_visibility('%s %i':format(self, i), false)
	end
end

_meta.TextCycle.__methods['show'] = function(tc)
	self = tostring(tc)
	windower.text.set_visibility('%s desc':format(self), true)
	windower.prim.set_visibility('%s left':format(self), true)
	windower.prim.set_visibility('%s right':format(self), true)	
	for i, v in ipairs(tc._track._var) do
		windower.text.set_visibility('%s %i':format(self, i), i == tc._track._var._track._current)
	end
end

_meta.TextCycle.__methods['disable'] = function(tc)
	tc._track._disabled = true
end

_meta.TextCycle.__methods['enable'] = function(tc)
	tc._track._disabled = false
end

_meta.TextCycle.__methods['update'] = function(tc) -- Finishes initialization and draws the graphics
	local self = tostring(tc)
	if tc._track._drawn then
		if tc._track._disabled then return end
		for i, v in ipairs(tc._track._var) do
			windower.text.set_visibility('%s %i':format(self, i), i == tc._track._var._track._current)
		end
		
	else	-- second part of draw, has to be executed at least one frame after TextCycle:draw() 
		
		local desc = '%s desc':format(self)
		local left = '%s left':format(self)
		local right = '%s right':format(self)
	
		local extentx, extenty = windower.text.get_extents(desc)
		if extentx == 0 then return end
		
		local width, height = windower.text.get_extents(desc)
		desc_w = width
		if width < tc._track._minwidth then
			width = tc._track._minwidth
		end
		for i, v in ipairs(tc._track._var) do
			w, h = windower.text.get_extents('%s %i':format(self, i))
			tc._track._widths[i] = w
			if w > width then
				width = w
			end
		end
		
		if tc._track._align == 'right' then
			tc._track._rightarrow = {	-- store coordinates of right arrow to be used for mouse events
				x = tc._track._x - 23,
				y = tc._track._y + 4
			}
			windower.prim.set_position(right, tc._track._rightarrow.x, tc._track._rightarrow.y) -- 5 is a guess for y
			windower.text.set_location(desc, math.floor(tc._track._x - 26 - width/2 - desc_w/2), tc._track._y)
			
			for i, v in ipairs(tc._track._var) do
				windower.text.set_location('%s %i':format(self, i), math.floor(tc._track._x - 26 - width/2 - tc._track._widths[i]/2), tc._track._y + 12) -- 12 is a guess for y
				windower.text.set_visibility('%s %i':format(self, i), i == tc._track._var._track._current)
			end
			
			tc._track._leftarrow = {
				x = tc._track._x - 52 - width,
				y = tc._track._y + 4
			}
			windower.prim.set_position(left, tc._track._leftarrow.x, tc._track._leftarrow.y)
		else
			tc._track._leftarrow = {
				x = tc._track._x,
				y = tc._track._y + 4
			}
			windower.prim.set_position(left, tc._track._leftarrow.x, tc._track._leftarrow.y)
			windower.text.set_location(desc, math.floor(tc._track._x + 26 + width/2 - desc_w/2), tc._track._y)
			
			for i, v in ipairs(tc._track._var) do
				windower.text.set_location('%s %i':format(self, i), math.floor(tc._track._x + 26 + width/2 - tc._track._widths[i]/2), tc._track._y + 12) -- 12 is a guess for y
				windower.text.set_visibility('%s %i':format(self, i), i == tc._track._var._track._current)
			end
			
			tc._track._rightarrow = {
				x = tc._track._x + 29 + width, -- 26 + width + 3 padding
				y = tc._track._y + 4
			}
			windower.prim.set_position(right, tc._track._rightarrow.x, tc._track._rightarrow.y)		
		end
		--tc._track._mouse_id = GUI.register_mouse_listener(tc)
		GUI.register_mouse_listener(tc)
		tc._track._drawn = true
		
		if tc._track._start_hidden then
			tc:hide()
		end
	end
end

_meta.TextCycle.__methods['on_mouse'] = function(tc, clicktype, x, y, delta, blocked)
	if tc._track._disabled then return end
	if clicktype == 1 then
		if x >= tc._track._leftarrow.x and x < tc._track._leftarrow.x + 23 and y >= tc._track._leftarrow.y and y < tc._track._leftarrow.y + 20 then
			tc._track._var:cycleback()
			tc:update()
			if tc._track._update_command then
				if type(tc._track._update_command) == 'string' then
					windower.send_command(tc._track._update_command)
				elseif type(tc._track._update_command) == 'function' then
					tc._track._update_command()
				end
			end
			return true
		elseif x >= tc._track._rightarrow.x and x < tc._track._rightarrow.x + 23 and y >= tc._track._rightarrow.y and y < tc._track._rightarrow.y + 20 then
			tc._track._var:cycle()
			tc:update()
			if tc._track._update_command then
				if type(tc._track._update_command) == 'string' then
					windower.send_command(tc._track._update_command)
				elseif type(tc._track._update_command) == 'function' then
					tc._track._update_command()
				end
			end
			return true
		end
	elseif clicktype == 2 then
		if x >= tc._track._leftarrow.x and x < tc._track._leftarrow.x + 23 and y >= tc._track._leftarrow.y and y < tc._track._leftarrow.y + 20 then
			return true
		elseif x >= tc._track._rightarrow.x and x < tc._track._rightarrow.x + 23 and y >= tc._track._rightarrow.y and y < tc._track._rightarrow.y + 20 then
			return true
		end
	end
end

_meta.TextCycle.__methods['undraw'] = function(tc)
	local self = tostring(tc)
	
	windower.prim.delete('%s left':format(self))
	windower.prim.delete('%s right':format(self))
	
	windower.text.delete('%s desc':format(self))
	
	for i, v in ipairs(tc._track._var) do
		windower.text.delete('%s %i':format(self, i))
	end
	
	--GUI.unregister_update_object(tc._track._update_id)
	--GUI.unregister_mouse_listener(tc._track._mouse_id)
	GUI.unregister_update_object(tc)
	GUI.unregister_mouse_listener(tc)
end

_meta.TextCycle.__index = function(tc, k)
    if type(k) == 'string' then
		
        local lk = k:lower()
		
		return _meta.TextCycle.__methods[lk]
    end
end
