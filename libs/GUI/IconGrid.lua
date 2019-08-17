_meta = _meta or {}
_meta.IconGrid = {}
_meta.IconGrid.__class = 'icon_grid'
_meta.IconGrid.__methods = {}

function IconGrid(args)
	local ig = {}
	ig._track = {}
	ig._track._class = 'icon grid'
	
	ig._track._x = args.x
	ig._track._y = args.y
	ig._track._var = args.var
	ig._track._icons = args.icons
	ig._track._button = args.button
	ig._track._shown = false
	ig._track._event = nil
	ig._track._click = false
	ig._track._tt_shown = false
	
	ig._track._cols = #args.icons
	ig._track._rows = T(ig._track._icons):map(function(x) return #x end):max()
	
	return setmetatable(ig, _meta.IconGrid)	
end

_meta.IconGrid.__methods['draw'] = function(ig)
	local self = tostring(ig)
	
	for y, ypos in ipairs{'top', 'mid', 'bot'} do
		for x, xpos in ipairs{'left', 'mid', 'right'} do
			name = '%s %s %s':format(self, ypos, xpos)
			windower.prim.create(name)
			windower.prim.set_visibility(name, false)
			windower.prim.set_texture(name, GUI.complete_filepath('icon_grid_%s_%s.png':format(ypos, xpos)))
			windower.prim.set_fit_to_texture(name, true)
		end
	end
	
	windower.prim.set_position('%s top left':format(self), ig._track._x, ig._track._y)
	
	windower.prim.set_position('%s top mid':format(self), ig._track._x + 3, ig._track._y)
	windower.prim.set_repeat('%s top mid':format(self), ig._track._cols * 40 - 4, 1)
	windower.prim.set_fit_to_texture('%s top mid':format(self), false)
	windower.prim.set_size('%s top mid':format(self), ig._track._cols * 40 - 4, 3)
	
	windower.prim.set_position('%s top right':format(self), ig._track._x + 3 + ig._track._cols * 40 - 4, ig._track._y)
	
	windower.prim.set_position('%s mid left':format(self), ig._track._x, ig._track._y + 3)	
	windower.prim.set_repeat('%s mid left':format(self), 1, ig._track._rows * 40 - 4)
	windower.prim.set_fit_to_texture('%s mid left':format(self), false)
	windower.prim.set_size('%s mid left':format(self), 3, ig._track._rows * 40 - 4)
	
	windower.prim.set_position('%s mid mid':format(self), ig._track._x + 3, ig._track._y +3)
	windower.prim.set_repeat('%s mid mid':format(self), ig._track._cols * 10 - 1, ig._track._rows * 10 - 1)
	windower.prim.set_fit_to_texture('%s mid mid':format(self), false)
	windower.prim.set_size('%s mid mid':format(self), ig._track._cols * 40 - 4, ig._track._rows * 40 - 4)
	
	windower.prim.set_position('%s mid right':format(self), ig._track._x + 3 + ig._track._cols * 40 - 4, ig._track._y +3)
	windower.prim.set_repeat('%s mid right':format(self), 1, ig._track._rows * 40 - 4)
	windower.prim.set_fit_to_texture('%s mid right':format(self), false)
	windower.prim.set_size('%s mid right':format(self), 3, ig._track._rows * 40 - 4)
	
	windower.prim.set_position('%s bot left':format(self), ig._track._x, ig._track._y + 3 + ig._track._rows * 40 - 4)
	
	windower.prim.set_position('%s bot mid':format(self), ig._track._x + 3, ig._track._y + 3 + ig._track._rows * 40 - 4)
	windower.prim.set_repeat('%s bot mid':format(self), ig._track._cols * 40 - 4, 1)
	windower.prim.set_fit_to_texture('%s bot mid':format(self), false)
	windower.prim.set_size('%s bot mid':format(self), ig._track._cols * 40 - 4, 3)
	
	windower.prim.set_position('%s bot right':format(self), ig._track._x + 3 + ig._track._cols * 40 - 4, ig._track._y + 3 + ig._track._rows * 40 - 4)
	
	for i, col in ipairs(ig._track._icons) do
		for j, icon in ipairs(col) do
			name = '%s %s %s':format(self, j, i)
			windower.prim.create(name)
			windower.prim.set_visibility(name, false)
			windower.prim.set_texture(name, GUI.complete_filepath(icon.img))
			windower.prim.set_fit_to_texture(name, true)
			windower.prim.set_position(name, ig._track._x + 5 + (i - 1) * 40, ig._track._y + 5 + (j - 1) * 40)
		end
	end
	
	local tooltip = '%s tooltip':format(self)
	windower.text.create(tooltip)
	windower.text.set_font(tooltip, 'Helvetica')
	windower.text.set_stroke_color(tooltip, 127, 18, 97, 136)
	windower.text.set_stroke_width(tooltip, 1)
	windower.text.set_color(tooltip, 255, 253, 252, 250)
	windower.text.set_font_size(tooltip, 10)
	windower.text.set_visibility(tooltip, false)
end

_meta.IconGrid.__methods['new_icons'] = function(ig, icons, var)
	local self = tostring(ig)
	ig._track._var = var or ig._track._var
	-- Delete the old icons
	for i, col in ipairs(ig._track._icons) do
		for j, icon in ipairs(col) do
			name = '%s %s %s':format(self, j, i)
			windower.prim.delete(name, false)
		end
	end
	
	local old_cols = ig._track._cols
	ig._track._icons = icons
	
	ig._track._cols = #icons
	ig._track._rows = T(icons):map(function(x) return #x end):max()
	
	-- Hide the box
	for y, ypos in ipairs{'top', 'mid', 'bot'} do
		for x, xpos in ipairs{'left', 'mid', 'right'} do
			name = '%s %s %s':format(self, ypos, xpos)
			windower.prim.set_visibility(name, false)
		end
	end
	
	-- Change the box size
	-- TODO need to windower.prim.set_size some of these too
	windower.prim.set_position('%s top left':format(self), ig._track._x, ig._track._y)
	
	windower.prim.set_position('%s top mid':format(self), ig._track._x + 3, ig._track._y)
	windower.prim.set_repeat('%s top mid':format(self), ig._track._cols * 40 - 4, 1)
	windower.prim.set_size('%s top mid':format(self), ig._track._cols * 40 - 4, 3)
	
	windower.prim.set_position('%s top right':format(self), ig._track._x + 4 + ig._track._cols * 40 - 4, ig._track._y)
	
	windower.prim.set_position('%s mid left':format(self), ig._track._x, ig._track._y + 3)
	windower.prim.set_repeat('%s mid left':format(self), 1, ig._track._rows * 40 - 4)
	windower.prim.set_size('%s mid left':format(self), 3, ig._track._rows * 40 - 4)
	
	windower.prim.set_position('%s mid mid':format(self), ig._track._x + 3, ig._track._y +3)
	windower.prim.set_repeat('%s mid mid':format(self), ig._track._cols * 10 - 1, ig._track._rows * 10 - 1)
	windower.prim.set_size('%s mid mid':format(self), ig._track._cols * 40 - 4, ig._track._rows * 40 - 4)
	
	windower.prim.set_position('%s mid right':format(self), ig._track._x + 3 + ig._track._cols * 40 - 4, it._track._y +3)
	windower.prim.set_repeat('%s mid right':format(self), 1, ig._track._rows * 40 - 4)
	windower.prim.set_size('%s mid right':format(self), 3, ig._track._rows * 40 - 4)
	
	windower.prim.set_position('%s bot left':format(self), ig._track._x, ig._track._y + 3 + ig._track._rows * 40 - 4)
	
	windower.prim.set_position('%s bot mid':format(self), ig._track._x + 3, ig._track._y + 3 + ig._track._rows * 40 - 4)
	windower.prim.set_repeat('%s bot mid':format(self), ig._track._cols * 40 - 4, 1)
	windower.prim.set_size('%s bot mid':format(self), ig._track._cols * 40 - 4, 3)
	
	windower.prim.set_position('%s bot right':format(self), ig._track._x + 3 + ig._track._cols * 40 - 4, ig._track._y + 3 + ig._track._rows * 40 - 4)
	
	for i, col in ipairs(ig._track._icons) do
		for j, icon in ipairs(col) do
			name = '%s %s %s':format(self, j, i)
			windower.prim.create(name)
			windower.prim.set_visibility(name, false)
			windower.prim.set_texture(name, GUI.complete_filepath(icon.img))
			windower.prim.set_fit_to_texture(name, true)
			windower.prim.set_position(name, ig._track._x + 5 + (i - 1) * 40, ig._track._y + 5 + (j - 1) * 40)
		end
	end
end

_meta.IconGrid.__methods['show'] = function(ig)
	local self = tostring(ig)
	ig._track._shown = true
	-- show the box
	for y, ypos in ipairs{'top', 'mid', 'bot'} do
		for x, xpos in ipairs{'left', 'mid', 'right'} do
			name = '%s %s %s':format(self, ypos, xpos)
			windower.prim.set_visibility(name, true)
		end
	end
	-- show the icons
	for i, col in ipairs(ig._track._icons) do
		for j, icon in ipairs(col) do
			name = '%s %s %s':format(self, j, i)
			windower.prim.set_visibility(name, true)
		end
	end
end

_meta.IconGrid.__methods['hide'] = function(ig)
	local self = tostring(ig)
	ig._track._shown = false
	-- hide the box
	for y, ypos in ipairs{'top', 'mid', 'bot'} do
		for x, xpos in ipairs{'left', 'mid', 'right'} do
			name = '%s %s %s':format(self, ypos, xpos)
			windower.prim.set_visibility(name, false)
		end
	end
	-- hide the icons
	for i, col in ipairs(ig._track._icons) do
		for j, icon in ipairs(col) do
			name = '%s %s %s':format(self, j, i)
			windower.prim.set_visibility(name, false)
		end
	end
	-- hide the tooltip
	windower.text.set_visibility('%s tooltip':format(self), false)
end

_meta.IconGrid.__methods['on_mouse'] = function(ig, type, x, y, delta, blocked)
	if not (ig.shown or ig._track._click) then return end
	if type == 2 then
		ig._track._click = false
		blocked = true
		return true
	elseif type == 1 then
		if x > ig._track._x and x < ig._track._x + 2 + 40 * ig._track._cols and y > ig._track._y and y < ig._track._y + 2 + 40 * ig._track._rows then
			for i, col in ipairs(ig._track._icons) do
				for j, icon in ipairs(col) do
					if x > ig._track._x + 5 + 40 * (i - 1) and x < ig._track._x + 37 + 40 * (i - 1) then
						if y > ig._track._y + 5 + 40 * (j - 1) and y < ig._track._y + 37 + 40 * (j - 1) then
							ig._track._var:set(icon.value)
							ig._track._button:select()
							ig._track._button:unpress()
							ig._track._click = true
							blocked = true
							return true
						end
					end
				end
			end
			return true
		else
			ig._track._button:unpress()
			ig._track._click = true
			blocked = true
			return true
		end
	else
		if x > ig._track._x and x < ig._track._x + 2 + 40 * ig._track._cols and y > ig._track._y and y < ig._track._y + 2 + 40 * ig._track._rows then
			if not ig._track._hover then
				ig._track._hover = os.clock() + 1
			end
			if os.clock() > ig._track._hover then
				for i, col in ipairs(ig._track._icons) do
					for j, icon in ipairs(col) do
						if x > ig._track._x + 5 + 40 * (i - 1) and x < ig._track._x + 37 + 40 * (i - 1) then
							if y > ig._track._y + 5 + 40 * (j - 1) and y < ig._track._y + 37 + 40 * (j - 1) then
								if icon.tooltip and ig._track._tt_shown ~= 100 * i + j then
									local name = '%s tooltip':format(tostring(ig))
									windower.text.set_location(name, x, y)
									windower.text.set_text(name, icon.tooltip)
									windower.text.set_visibility(name, true)
									ig._track._tt_shown = 100 * i + j
								end
							end
						end
					end
				end
			end
		elseif ig._track._hover then
			ig._track._hover = nil
			ig._track._tt_shown = false
			windower.text.set_visibility('%s tooltip':format(tostring(ig)), false)
		end
	end
end

_meta.IconGrid.__methods['undraw'] = function(ig)
	local self = tostring(ig)
	for y, ypos in ipairs{'top', 'mid', 'bot'} do
		for x, xpos in ipairs{'left', 'mid', 'right'} do
			name = '%s %s %s':format(self, ypos, xpos)
			windower.prim.delete(name)
		end
	end
	for i, col in ipairs(ig._track._icons) do
		for j, icon in ipairs(col) do
			name = '%s %s %s':format(self, j, i)
			windower.prim.delete(name)
		end
	end
	windower.text.delete('%s tooltip':format(self))
end

_meta.IconGrid.__index = function(ig, k)
	    if type(k) == 'string' then
        local lk = k:lower()
		
		if lk == 'shown' then
			return ig._track._shown
		else
			return _meta.IconGrid.__methods[lk]
		end
    end
end

