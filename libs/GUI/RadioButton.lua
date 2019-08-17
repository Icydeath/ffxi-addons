_meta = _meta or {}
_meta.RadioButton = {}
_meta.RadioButton.__class = 'radiobutton'
_meta.RadioButton.__methods = {}

function RadioButton(args)
	local rb = {}
	rb._track = {}
	rb._track._class = 'radiobutton'
	rb._track._x = args.x
	rb._track._y = args.y
	rb._track._var = args.var
	rb._track._value = args.value -- which state of the var this button represents
	rb._track._group = args.group
	rb._track._callback = args.callback
	rb._track._state = rb._track._var.value == rb._track._value
	rb._track._lock = T{}
	rb._track._shown = args.shown ~= nil and args.shown or true
	
	rb._track._click = false
	
	return setmetatable(rb, _meta.RadioButton)
end

_meta.RadioButton.__methods['draw'] = function(rb)
	local self = tostring(rb)
	
	local name = '%s box':format(self)
	windower.prim.create(name)
	windower.prim.set_texture(name, GUI.complete_filepath('RadioButton.png'))
	windower.prim.set_fit_to_texture(name, true)
	windower.prim.set_position(name, rb._track._x, rb._track._y)
	windower.prim.set_visibility(name, rb._track._shown)
	
	name = '%s press':format(self)
	windower.prim.create(name)
	windower.prim.set_color(name, 100, 0, 0, 127)
	windower.prim.set_size(name, 16, 16)
	windower.prim.set_position(name, rb._track._x + 3, rb._track._y + 3)
	windower.prim.set_visibility(name, rb._track._shown and rb._track._state)

	name = '%s check':format(self)
	windower.prim.create(name)
	windower.prim.set_texture(name, GUI.complete_filepath('Checkmark.png'))
	windower.prim.set_fit_to_texture(name, true)
	windower.prim.set_position(name, rb._track._x, rb._track._y)
	windower.prim.set_visibility(name, rb._track._shown and rb._track._state)
	
	GUI.register_mouse_listener(rb)
	GUI.subscribe_signals(rb, rb.receive_signal:apply(rb))
end

_meta.RadioButton.__methods['on_mouse'] = function(rb, type, x, y, delta, blocked)
	if not rb._track._lock:empty() then
		return
	end
	x = x - rb._track._x
	y = y - rb._track._y
	if x >= 0 and x < 22 and y >= 0 and y < 22 then
		if type == 1 then
			if not rb._track._state then
				rb._track._var:set(rb._track._value)
				GUI.send_signal(rb, 'radiobutton', rb.group)
				rb._track._state = true
				rb:update()
			end
			rb._track._click = true
			return true
		elseif type == 2 and rb._track._click then
			rb._track._click = false
			return true
		end
	end	
end

_meta.RadioButton.__methods['receive_signal'] = function(rb, sender, signal, ...)
	if signal == 'radiobutton' then
		if {...}[1] == rb.group then
			rb:update()
		end
	
	-- block/unblock mouse events
	elseif signal == 'lock' then
		rb._track._lock[sender] = {...}[1] or nil
	end
end

_meta.RadioButton.__methods['update'] = function(rb)
	if rb._track._var.value ~= rb._track._value then
		rb._track._state = false
	end
	windower.prim.set_visibility('%s press':format(tostring(rb)), rb._track._state)
	windower.prim.set_visibility('%s check':format(tostring(rb)), rb._track._state)
end

_meta.RadioButton.__index = function(rb, k)
    if type(k) == 'string' then
        local lk = k:lower()
		
		if lk == 'group' then
			return rb._track._group
		else
			return _meta.RadioButton.__methods[lk]
		end
    end
end