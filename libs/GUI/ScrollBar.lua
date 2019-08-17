_meta = _meta or {}
_meta.ScrollBar = {}
_meta.ScrollBar.__class = 'scrollbar'
_meta.ScrollBar.__methods = {}

require('GUI/orderedPairs')

function ScrollBar(args)
	local sb = {}
	sb._track = {}
	sb._track._class = 'scrollbar'
	sb._track._x = args.x
	sb._track._y = args.y
	sb._track._height = args.height
	sb._track._displaypercent = args.displaypercent
	sb._track._shown = false -- set true for testing
	sb._track._value = 0
	sb._track._callback = args.callback
	sb._track._interval = args.interval -- the amount to scroll when the up/down arrow are clicked
	
	sb._track._click = false
	sb._track._drag = false
	sb._track._dragpoint = sb._track._value
	sb._track._dragreference = sb._track._value
	
	return setmetatable(sb, _meta.ScrollBar)
end

_meta.ScrollBar.__methods['draw'] = function(sb)
	local self = tostring(sb)
	-- iterates alphabetically.  Works entirely by coincidence
	for k, v in orderedPairs(_meta.ScrollBar._elements) do
		name = '%s %s':format(self, k)
		windower.prim.create(name)
		windower.prim.set_visibility(name, v.visible or false) -- set true for testing
		windower.prim.set_texture(name, GUI.complete_filepath(v.img))
		windower.prim.set_position(
			name, 
			sb._track._x + v.x, 
			sb._track._y + v.y + (v.y < 0 and sb._track._height or 0))
		windower.prim.set_fit_to_texture(name, v.fit)
	end
	windower.prim.set_size('%s background':format(self), 11, sb._track._height - 22)
	windower.prim.set_position('%s top':format(self), sb._track._x, sb._track._y + sb._track._value + 11)
	windower.prim.set_size(
		'%s mid':format(self),
		11,
		math.floor((sb._track._height - 22) * sb._track._displaypercent - 2))
	windower.prim.set_position('%s mid':format(self), sb._track._x, sb._track._y + sb._track._value + 12)
	windower.prim.set_position(
		'%s bot':format(self), 
		sb._track._x, 
		sb._track._y + 12 + math.floor((sb._track._height - 22) * sb._track._displaypercent - 2) + sb._track._value)

	GUI.register_mouse_listener(sb)
end

_meta.ScrollBar.__methods['get'] = function(sb)
	-- get % of the bar's total space, scale to the bar's actual travel space.  See fig. 1
	
	return math.min(sb._track._value / (sb._track._height - 22) / (1 - sb._track._displaypercent), 1)
end

-- value is a number between 0 and 1, representing the position of the scrollbar
_meta.ScrollBar.__methods['set'] = function(sb, value)
	if value > 1 - sb._track._displaypercent then
		value = 1 - sb._track._displaypercent
	elseif value < 0 then
		value = 0
	end
	sb._track._value = value * (sb._track._height - 22)
end

_meta.ScrollBar.__methods['scroll_up'] = function(sb)
	local valuepct = sb._track._value / (sb._track._height - 22)
	local scaledvaluepct = valuepct / (1 - sb._track._displaypercent) -- scale so bar's total travel distance is [0,1]
	scaledvaluepct = scaledvaluepct - sb._track._interval
	if scaledvaluepct < 0 then
		scaledvaluepct = 0
	end
	valuepct = scaledvaluepct * (1 - sb._track._displaypercent)
	sb._track._value = valuepct * (sb._track._height - 22)
	sb:update_position()
	sb._track._callback(sb:get())
end

_meta.ScrollBar.__methods['scroll_down'] = function(sb)
	local valuepct = sb._track._value / (sb._track._height - 22)
	local scaledvaluepct = valuepct / (1 - sb._track._displaypercent) -- scale so bar's total travel distance is [0,1]
	scaledvaluepct = scaledvaluepct + sb._track._interval
	if scaledvaluepct > 1 then
		scaledvaluepct = 1
	end
	valuepct = scaledvaluepct * (1 - sb._track._displaypercent)
	sb._track._value = valuepct * (sb._track._height - 22)
	sb:update_position()
	sb._track._callback(sb:get())
end

_meta.ScrollBar.__methods['constrain_value'] = function(sb)
	if sb._track._value > (1 - sb._track._displaypercent) * (sb._track._height - 22) + 1 then
		sb._track._value = math.floor((1 - sb._track._displaypercent) * (sb._track._height - 22)) + 1
	elseif sb._track._value < 0 then
		sb._track._value = 0
	end
end

_meta.ScrollBar.__methods['hide'] = function(sb)
	for k, _ in pairs(_meta.ScrollBar._elements) do
		windower.prim.set_visibility('%s %s':format(tostring(sb), k), false)
	end
	sb._track._shown = false
end

_meta.ScrollBar.__methods['show'] = function(sb)
	for k, _ in pairs(_meta.ScrollBar._elements) do
		windower.prim.set_visibility('%s %s':format(tostring(sb), k), true)
	end
	sb._track._shown = true
end

_meta.ScrollBar.__methods['update_position'] = function(sb)
	local self = tostring(sb)	
	windower.prim.set_position('%s top':format(self), sb._track._x, sb._track._y + sb._track._value + 11)
	windower.prim.set_position('%s mid':format(self), sb._track._x, sb._track._y + sb._track._value + 12)
	windower.prim.set_position(
		'%s bot':format(self), 
		sb._track._x, 
		sb._track._y + 12 + math.floor((sb._track._height - 22) * sb._track._displaypercent - 2) + sb._track._value)
end

_meta.ScrollBar.__methods['on_mouse'] = function(sb, type, x, y, delta, blocked)
	if not sb._track._shown then
		return
	end
	if type == 1 then
		if x >= sb._track._x and -- in bounds for widget
			x < sb._track._x + 11 and 
			y >= sb._track._y and 
			y < sb._track._height + sb._track._y then
			
			if y < sb._track._y + 11 then
				sb:scroll_up()
			elseif y > sb._track._y + sb._track._height - 11 then
				sb:scroll_down()
			else
				local valuepct = sb._track._value / (sb._track._height - 22)
				local handlesize = math.floor(sb._track._displaypercent * (sb._track._height - 22))
				local y_local = y - sb._track._y - 11
				if y_local >= sb._track._value and y_local < sb._track._value + handlesize then
					sb._track._drag = true
					sb._track._dragpoint = y
					--sb._track._dragreference = sb._track._value + sb._track._y + 11
					sb._track._dragreference = sb._track._value
				else
					sb._track._value = y - sb._track._y - 11
					sb:constrain_value()
					sb._track._callback(sb:get())
					sb:update_position()
				end
			end
			sb._track._click = true
			return true
		end
	elseif type == 2 then
		if sb._track._click or sb._track._drag then
			sb._track._click = false
			sb._track._drag = false
			return true
		end
	elseif sb._track._drag then
		-- see fig. 2
		--sb._track._value = y + sb._track._dragreference - sb._track._dragpoint - sb._track._y - 11
		sb._track._value = y + sb._track._dragreference - sb._track._dragpoint
		sb:constrain_value()
		sb:update_position()
		sb._track._callback(sb:get()) -- tell whatever is listening the new position
	end
end

_meta.ScrollBar._elements = {
	up={
		img='scroll_up.png',
		x=0,
		y=0,
		fit=true,
	},
	down={
		img='scroll_down.png',
		x=0,
		y=-11,
		fit=true,
	},
	background={
		img='scroll_background.png',
		x=0,
		y=11,
		fit=false,
	},
	top={
		img='scroll_cap.png',
		x=0,
		y=11,
		fit=true,
	},
	mid={
		img='scroll_mid.png',
		x=0,
		y=12,
		fit=false,
	},
	bot={
		img='scroll_cap.png',
		x=0,
		y=13,
		fit=true,
	}
}

_meta.ScrollBar.__index = function(sb, k)
    if type(k) == 'string' then
        local lk = k:lower()		
		return _meta.ScrollBar.__methods[lk]
    end
end