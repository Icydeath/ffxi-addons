_meta = _meta or {}
_meta.PassiveText = {}
_meta.PassiveText.__class = 'passive_text'
_meta.PassiveText.__methods = {}

function PassiveText(args, ...) -- constructs the object, but does not initialize it
	local pt = {}
	pt._track = {}
	pt._track._class = 'passive text'

	pt._track._x = args.x
	pt._track._y = args.y
	--pt._track._var = args.var
	--pt._track._text = {...}
	
	pt._track._text = args.text
	pt._track._var = T{...}
	pt._track._font = args.font or 'Helvetica'
	pt._track._font_size = args.font_size or 10
	pt._track._color = args.color or {255,253,252,250}
	pt._track._stroke_color = args.stroke_color or {127, 18, 97, 136}
	pt._track._bold = args.bold or false
	
	pt._track._align = (args.align or 'left'):lower()

	return setmetatable(pt, _meta.PassiveText)	
end

_meta.PassiveText.__methods['draw'] = function(pt) -- Finishes initialization and draws the graphics
	local self = tostring(pt)
	
	windower.text.create(self)
	windower.text.set_font(self, pt._track._font)
	windower.text.set_stroke_color(self, table.unpack(pt._track._stroke_color))--127, 18, 97, 136)
	windower.text.set_stroke_width(self, 1)
	windower.text.set_color(self, table.unpack(pt._track._color))--255, 253, 252, 250)
	windower.text.set_font_size(self, pt._track._font_size)
	windower.text.set_bold(self, pt._track._bold)
	
	windower.text.set_location(self, pt._track._x, pt._track._y)
	windower.text.set_right_justified(self, pt._track._align == 'right')
	--windower.text.set_text(self, 'RH Weaponskill: %s':format(_G[pt._track._var] or 'None'))--pt._track._var or 'None')
	windower.text.set_text(tostring(pt), (pt._track._text or '%s'):format(pt._track._var:map(function(x) 
		if type(x) == 'string' then return _G[x] or 'None' elseif type(x) == 'function' then return x() or 'None' end end):unpack()))--table.foreach(pt._track._var, function(_,x) if type(x) == 'string' then return _G[x] or 'None' elseif type(x) == 'function' then return x() or 'None' end end)))
	windower.text.set_visibility(self, true)
	
	--print(windower.text.get_extents(self))
	--print(windower.text.get_location(self))
	
	--pt._track._event = GUI.register_update_object(pt)
	GUI.register_update_object(pt)
end

_meta.PassiveText.__methods['update'] = function(pt)
	--windower.text.set_text(tostring(pt), 'RH Weaponskill: %s':format(_G[pt._track._var] or 'None'))	
	windower.text.set_text(tostring(pt), (pt._track._text or '%s'):format(table.foreach(pt._track._var, function(_,x) if type(x) == 'string' then return _G[x] or 'None' elseif type(x) == 'function' then return x() or 'None' end end)))
end

_meta.PassiveText.__methods['recolor'] = function(pt, alpha, red, green, blue)
	pt._track._color = {alpha, red, green, blue}
	windower.text.set_color(tostring(pt), alpha, red, green, blue)
end

_meta.PassiveText.__methods['restroke'] = function(pt, alpha, red, green, blue)
	pt._track._stroke_color = {alpha, red, green, blue}
	windower.text.set_stroke_color(tostring(pt), alpha, red, green, blue)
end

_meta.PassiveText.__methods['undraw'] = function(pt)
	windower.text.delete(tostring(pt))

	--GUI.unregister_update_object(pt._track._event)
	GUI.unregister_update_object(pt)
end

_meta.PassiveText.__index = function(pt, k)
    if type(k) == 'string' then
		
        local lk = k:lower()
		
		return _meta.PassiveText.__methods[lk]
    end
end