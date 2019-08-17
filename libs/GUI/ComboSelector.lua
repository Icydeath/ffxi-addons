_meta = _meta or {}
_meta.ComboSelector = {}
_meta.ComboSelector.class = 'comboselector'
_meta.ComboSelector.__methods = {}

function ComboSelector(args)
	local cs = {}
	cs._track = {}
	cs._track._class = 'comboselector'
	
	cs._track._x = args.x
	cs._track._y = args.y
	cs._track._options = args.options
	cs._track._selected = args.default or 1
	cs._track._width = args.width
	cs._track._size = args.size
	cs._track._mouseover = 0
	cs._track._callback = args.callback
	
	cs._track._background = args.background or {130, 89, 84, 114}
	cs._track._soft_highlight = args.soft_highlight or {130, 60, 60, 160}
	cs._track._highlight = args.highlight or {130, 40, 40, 240}

	if args.size < #args.options then
		cs._track._scroll = true
	end
	cs._track._scroll_pos = 0
	
	return setmetatable(cs, _meta.ComboSelector)
end

_meta.ComboSelector.__methods['draw'] = function(cs)
	local self = tostring(cs)
	for i = 1, cs._track._size do
		local name = '%s %s text':format(self, i)
		windower.text.create(name)
		windower.text.set_font(name, 'Helvetica')
		windower.text.set_color(name, 255,253, 252, 250)
		windower.text.set_stroke_color(name, 170, 89, 84, 114)
		windower.text.set_stroke_width(name, 4)
		windower.text.set_location(name, cs._track._x + 2, cs._track._y + 17 * (i - 1))
		windower.text.set_font_size(name, 10)
		windower.text.set_visibility(name, false)
		local name = '%s background %s':format(self, i)
		windower.prim.create(name)
		windower.prim.set_position(name, cs._track._x, cs._track._y + 17 * (i - 1))
		windower.prim.set_size(name, cs._track._width - (cs._track._scroll and 11 or 0), 17)
		windower.prim.set_visibility(name, false)
	end
	cs:update_visible()
	if cs._track._scroll then
		cs._track._scrollbar = ScrollBar{
			x=cs._track._x + cs._track._width - (cs._track._scroll and 11 or 0),
			y=cs._track._y,
			height=cs._track._size * 17, -- multiply by height of each entry
			displaypercent=cs._track._size / #cs._track._options,
			callback=cs.scroll:apply(cs),
			interval= 1 / (#cs._track._options - cs._track._size ) -- 1 / number of distinct positions
		}
		cs._track._scrollbar:draw()
	end
	
	--for testing only
	--GUI.register_mouse_listener(cs)
end

-- Called by the scrollbar
_meta.ComboSelector.__methods['scroll'] = function(cs, scroll)
	-- linnear transformation from scrollbar to the index of the top element to display
	cs._track._scroll_pos = math.floor(scroll * (#cs._track._options - cs._track._size))
	cs:update_visible()
end

_meta.ComboSelector.__methods['show'] = function(cs)
	local self = tostring(cs)
	for i = 1, cs._track._size do
		local name = '%s %s text':format(self, i)
		windower.text.set_visibility(name, true)
		local name = '%s background %s':format(self, i)
		windower.prim.set_visibility(name, true)
	end
	if cs._track._scroll then
		cs._track._scrollbar:show()
	end
	cs._track._shown = true
	cs:update_visible()
end

_meta.ComboSelector.__methods['hide'] = function(cs)
	local self = tostring(cs)
	for i = 1, cs._track._size do
		local name = '%s %s text':format(self, i)
		windower.text.set_visibility(name, false)
		local name = '%s background %s':format(self, i)
		windower.prim.set_visibility(name, false)
	end
	if cs._track._scroll then
		cs._track._scrollbar:hide()
	end
	cs._track._shown = false
end

_meta.ComboSelector.__methods['resize'] = function(cs, newsize)
	local self = tostring(cs)
	-- expand menu
	if newsize > cs._track._size then
		for i = cs._track._size + 1, newsize do
			local name = '%s %s text':format(self, i)
			windower.text.create(name)
			windower.text.set_font(name, 'Helvetica')
			windower.text.set_color(name, 255,253, 252, 250)
			windower.text.set_stroke_color(name, 170, 89, 84, 114)
			windower.text.set_stroke_width(name, 4)
			windower.text.set_location(name, cs._track._x + 2, cs._track._y + 17 * (i - 1))
			windower.text.set_font_size(name, 10)
			windower.text.set_visibility(name, false)
			local name = '%s background %s':format(self, i)
			windower.prim.create(name)
			windower.prim.set_position(name, cs._track._x, cs._track._y + 17 * (i - 1))
			windower.prim.set_size(name, cs._track._width - (cs._track._scroll and 11 or 0), 17)
			windower.prim.set_visibility(name, false)
		end
	elseif newsize < cs._track._size then
		for i = cs._track._size, newsize + 1, -1 do
			windower.text.delete('%s %s text':format(self, i))
			windower.prim.delete('%s background %s':format(self, i))
		end
	end
	
	cs._track._size = newsize
	if (cs._track._size < #cs._track._options) ~= (cs._track._scroll or false) then
		cs._track._scroll = ((cs._track._size < #cs._track._options) ~= (cs._track._scroll or false))
		for i = 1, cs._track._size do
			windower.prim.set_size('%s background %s':format(self, i), cs._track._width - (cs._track._scroll and 11 or 0), 17)
		end
		if cs._track._scroll then
			cs._track._scrollbar = ScrollBar{
				x=cs._track._x + cs._track._width - (cs._track._scroll and 11 or 0),
				y=cs._track._y,
				height=newsize * 17, -- multiply by height of each entry
				displaypercent=newsize / #cs._track._options,
				callback=cs.scroll:apply(cs),
				interval= 1 / (#cs._track._options - newsize ) -- 1 / number of distinct positions
			}
			cs._track._scrollbar:draw()
		end
	elseif cs._track._scroll then -- scrollbar already existed, adjust its size
	end
end

_meta.ComboSelector.__methods['update_visible'] = function(cs)
	local self = tostring(cs)
	--[[for i, v in ipairs(cs._track._options) do
		windower.text.set_location(
			'%s %s text':format(self, i), 
			cs._track._x, 
			cs._track._y - 12 * (cs._track._scroll_pos - i + 1))
		windower.text.set_visibility(
			'%s %s text':format(self, i),
			i - cs._track._scroll_pos >= 0 and i - cs._track._scroll_pos < cs._track._size)
	end]]
	for i = 1, cs._track._size do
		local selected = cs._track._selected == cs._track._scroll_pos + i
		windower.prim.set_color(
			'%s background %s':format(self, i),
			table.unpack((selected and cs._track._highlight) or 
				(cs._track._mouseover == i and cs._track._soft_highlight) or
			cs._track._background))
		windower.text.set_text(
			'%s %s text':format(self, i),
			#cs._track._options >= i and cs._track._options[cs._track._scroll_pos + i] or ''
		)
	end
end

_meta.ComboSelector.__methods['on_mouse'] = function(cs, type, x, y, delta, blocked)
	if not cs._track._shown then
		return
	end
	-- Transform coordinates
	x = x - cs._track._x
	y = y - cs._track._y
	if x >= 0 and x < cs._track._width and y >= 0 and y < cs._track._size * 17 then
		if type == 10 and cs._track._scroll then
			if delta > 0 then
				cs._track._scrollbar:scroll_up()
			elseif delta < 0 then
				cs._track._scrollbar:scroll_down()
			end
		elseif x < cs._track._width - (cs._track._scroll and 11 or 0) then
			-- event isn't in the scroll bar
			if type == 0 then
				local old = cs._track._mouseover
				cs._track._mouseover = math.floor(y / 17 + 1)
				if cs._track._mouseover ~= old then
					cs:update_visible()
				end				
			elseif type == 1 then
				cs._track._click = true
				return true
			elseif type == 2 and cs._track._click then
				cs._track._click = false
				local selected = math.floor(y / 17 + 1 + cs._track._scroll_pos)
				cs._track._selected = selected
				cs._track._callback(selected)
				cs:hide()
				return true
			end
		else -- event is located on the scrollbar
			if type == 1 then
				return true
			elseif type == 2 and cs._track._click then
				cs._track._click = false
				return true
			end
		end
	elseif type == 2 and cs._track._click then
		cs._track._click = false
		return true
	end
	
end

_meta.ComboSelector.__index = function(cs, k)
    if type(k) == 'string' then
        local lk = k:lower()		
		return _meta.ComboSelector.__methods[lk]
    end
end