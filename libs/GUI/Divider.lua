_meta = _meta or {}
_meta.Divider = {}
_meta.Divider.__class = 'divider'
_meta.Divider.__methods = {}

function Divider(args)
	local d = {}
	d._track = {}
	d._track._class = 'divider'
	
	d._track._x = args.x
	d._track._y = args.y
	d._track._size = args.size
	
	return setmetatable(d, _meta.Divider)
end

_meta.Divider.__methods['draw'] = function(d)
	local self = tostring(d)
	
	local left = '%s left':format(self)
	windower.prim.create(left)
	windower.prim.set_position(left, d._track._x, d._track._y)
	windower.prim.set_texture(left, GUI.complete_filepath('Divider_left.png'))
	windower.prim.set_fit_to_texture(left, true)
	windower.prim.set_visibility(left, true)
	
	local mid = '%s mid':format(self)
	windower.prim.create(mid)
	windower.prim.set_position(mid, d._track._x + 16, d._track._y)
	windower.prim.set_texture(mid, GUI.complete_filepath('Divider_mid.png'))
	windower.prim.set_repeat(mid, d._track._size - 32, 1)
	windower.prim.set_fit_to_texture(mid, false)
	windower.prim.set_size(mid, d._track._size - 32, 3)
	windower.prim.set_visibility(mid, true)
	
	local right = '%s right':format(self)
	windower.prim.create(right)
	windower.prim.set_position(right, d._track._x + d._track._size - 16, d._track._y)
	windower.prim.set_texture(right, GUI.complete_filepath('Divider_right.png'))
	windower.prim.set_fit_to_texture(right, true)
	windower.prim.set_visibility(right, true)
end

_meta.Divider.__methods['undraw'] = function(d)
	local self = tostring(d)
	windower.prim.delete('%s left':format(self))
	windower.prim.delete('%s mid':format(self))
	windower.prim.delete('%s right':format(self))
end

_meta.Divider.__index = function(d, k)
	if type(k) == 'string' then
		local lk = k:lower()
		
		return _meta.Divider.__methods[lk]
	end
end