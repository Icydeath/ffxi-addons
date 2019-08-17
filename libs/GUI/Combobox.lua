_meta = _meta or {}
_meta.Combobox = {}
_meta.Combobox.__class = 'combobox'
_meta.Combobox.__methods = {}

require('tables')

function Combobox(args)
	local cb = {}
	cb._track = {}
	cb._track._class = 'combobox'
	cb._track._x = args.x
	cb._track._y = args.y
	cb._track._var = args.var
	cb._track._width = args.width
	cb._track._size = args.size -- could calculate it using GUI.bounds if not provided
	cb._track._callback = args.callback
	cb._track._state = cb._track._var.value
	cb._track._lock = T{}
	
	cb._track._click = false
	
	return setmetatable(cb, _meta.Combobox)
end

_meta.Combobox.__methods['draw'] = function(cb)
	local self = tostring(cb)
	for i, v in ipairs({'left', 'mid', 'right'}) do
		local name = '%s %s':format(self, v)
		windower.prim.create(name)
		windower.prim.set_texture(name, GUI.complete_filepath('combo_%s.png':format(v)))
		windower.prim.set_fit_to_texture(name, true)
		windower.prim.set_visibility(name, true)
		windower.prim.set_position(name, cb._track._x + {0, 3, cb._track._width - 3}[i], cb._track._y)
	end
	windower.prim.set_fit_to_texture('%s mid':format(self), false)
	windower.prim.set_size('%s mid':format(self), cb._track._width - 6, 22)
	
	local name = '%s text':format(self)
	windower.text.create(name)
	windower.text.set_location(name, cb._track._x + 5, cb._track._y + 3)
	windower.text.set_text(name, cb._track._var.value)
	windower.text.set_font(name, 'Helvetica')
	windower.text.set_color(name, 255,253, 252, 250)
	windower.text.set_font_size(name, 10)
	windower.text.set_visibility(name, true)
	
	cb._track._dropdown = ComboSelector{
		x = cb._track._x + 3,
		y = cb._track._y + 22,
		size = cb._track._size,
		width = cb._track._width - 6,
		options = cb._track._var,
		callback = cb.select:apply(cb)
	}
	cb._track._dropdown:draw()
	
	GUI.register_mouse_listener(cb)
	GUI.subscribe_signals(cb, cb.receive_signal:apply(cb))
	--GUI.register_update_event(cb) -- Possibly manually enable this in constructor.  Shouldn't be on by default.
end

_meta.Combobox.__methods['show'] = function(cb)
	local self = tostring(cb)
	for i, v in ipairs({'left', 'mid', 'right'}) do
		local name = '%s %s':format(self, v)
		windower.prim.set_visibility(name, true)
	end
	windower.text.set_visibility('%s text':format(self), true)
end

_meta.Combobox.__methods['hide'] = function(cb)
	local self = tostring(cb)
	for i, v in ipairs({'left', 'mid', 'right'}) do
		local name = '%s %s':format(self, v)
		windower.prim.set_visibility(name, false)
	end
	windower.text.set_visibility('%s text':format(self), false)
	if cb._track._dropdown._track._shown then
		cb._track._dropdown:hide()
	end
end

_meta.Combobox.__methods['resize'] = function(cb, newsize)
	if cb._track._dropdown._track._shown then
		cb._track._dropdown:hide()
	end
	cb._track._size = newsize
	cb._track._dropdown:resize(newsize)
end

_meta.Combobox.__methods['update'] = function(cb)
	print( cb._track._var.value, cb._track._state)
	if cb._track._var.value ~= cb._track._state then
		cb._track._state = cb._track._var.value
		windower.text.set_text('%s text':format(tostring(cb)), cb._track._var.value)
		cb._track._dropdown._track._selected = cb._track._var._track._current -- What a mess
		if cb._track._callback then
			cb._track._callback(cb._track._var.value)
		end
	end
end

_meta.Combobox.__methods['on_mouse'] = function(cb, type, x, y, delta, blocked)
	if not cb._track._lock:empty() then
		return
	end
	if cb._track._dropdown._track._shown then
		local res = cb._track._dropdown:on_mouse(type, x, y, delta, blocked)
		if res then
			return true
		end
		if type == 1 then
			cb._track._dropdown:hide()
			GUI.send_signal(cb, 'lock', false)
			if x >= 0 and x < cb._track._width and y >= 0 and y < 22 then
				return true
			end
			return
		end
	end
	x = x - cb._track._x
	y = y - cb._track._y
	if x >= 0 and x < cb._track._width and y >= 0 and y < 22 then
		if type == 1 then
			cb._track._click = true
			cb._track._dropdown:show()
			GUI.send_signal(cb, 'lock', true) -- lock any widgets that are listening
			-- Need to rework lock system and use focus system instead to block mouse events handled by focused widgets
			return true
		end
	end
	if type == 2 and cb._track._click then
		cb._track._click = false
		return true
	end
end

_meta.Combobox.__methods['select'] = function(cb, selection)
	local change = cb._track._var ~= cb._track._state -- true if a new value is selected
	cb._track._var:set(cb._track._var[selection])
	cb._track._state = cb._track._var.value
	windower.text.set_text('%s text':format(tostring(cb)), cb._track._var.value)
	if change and cb._track._callback then
		cb._track._callback(cb._track._var.value)
	end
	GUI.send_signal(cb, 'lock', false)
end

_meta.Combobox.__methods['receive_signal'] = function(cb, sender, signal, ...)
	if signal == 'lock' then
		if {...}[1] == true then
			cb._track._lock[sender] = true
		elseif {...}[1] == false then
			cb._track._lock[sender] = nil
		end
	end
end

_meta.Combobox.__index = function(cb, k)
    if type(k) == 'string' then
		
        local lk = k:lower()
		
		return _meta.Combobox.__methods[lk]
    end
end
