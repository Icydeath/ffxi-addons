_meta = _meta or {}
_meta.TextTable = {}
_meta.TextTable.__class = 'text table'
_meta.TextTable.__methods = {}

function TextTable(args)
	local tt = {}
	tt._track = {}
	tt._track._class = 'text table'
	
	tt._track._x = args.x
	tt._track._y = args.y
	
	tt._track._height = args.height or #args.var
	tt._track._auto_height = args.auto_height
	tt._track._width = args.width -- in cells
	tt._track._columns = args.columns -- not an optional argument
	tt._track._rows = args.rows or GUI.range(1, tt._track._height)
	tt._track._auto_update = args.auto_update
	
	tt._track._var = args.var -- a table
	
	tt._track._font = args.font or 'Helvetica'
	tt._track._font_size = args.font_size or 10
	tt._track._color = args.color or {255,253,252,250}
	tt._track._stroke_color = args.stroke_color or {127, 18, 97, 136}
	tt._track._bold = args.bold or false
	tt._track._stroke = args.stroke == nil and true or args.stroke
	tt._track._stroke_width = args.stroke_width or 1
	tt._track._pad_x = args.pad_x or 3
	tt._track._pad_y = args.pad_y or 3
	
	tt._track._default_style = {
		font = tt._track._font,
		font_size = tt._track._font_size,
		color = tt._track._color,
		bold = tt._track._bold,
		stroke = tt._track._stroke,
		stroke_width = tt._track._stroke_width,
		stroke_color = tt._track._stroke_color,
		align = 'left'
	}
	
	tt._track._col_size_override = args.col_size_override -- table with key being column number and value being forced width
	tt._track._row_size_override = args.row_size_override
	
	tt._track._table = {}
	tt._track._col_widths = {}
	tt._track._row_heights = {}
	tt._track._col_x = {}
	tt._track._row_y = {}
	
	tt._track._col_style = {}
	tt._track._row_style = {}
	
	tt._track._framecounter = 0
	
	return setmetatable(tt, _meta.TextTable)
end

_meta.TextTable.__methods['draw'] = function(tt)
	self = tostring(tt)
	for rowindex, rowkey in ipairs(tt._track._rows) do
		tt._track._table[rowindex] = {}
		for colindex, colkey in ipairs(tt._track._columns) do
			-- var[rowkey][colkey] accesses the data to display in the cell
			tt._track._table[rowindex][colindex] = {}			-- initialize the cell.  We probably want to do something with it
			tt._track._table[rowindex][colindex].style = table.copy(tt._track._default_style, false)	-- font stuff for this cell.  There's per-cell formatting	
			tt._track._table[rowindex][colindex].extents = {w=0,h=0}
			
			local textname = '%s %d %d':format(self, rowindex, colindex) -- name of text object
			windower.text.create(textname) -- Create the text object
			GUI.styletext(textname, tt._track._table[rowindex][colindex].style)
			windower.text.set_visibility(textname, true)
			
		end
	end
	
	tt:redraw()
	--tt._track._auto_update = tt._track._auto_update == true and GUI.register_update_object(tt)
	if tt._track._auto_update then
		GUI.register_update_object(tt)
	end
end

_meta.TextTable.__methods['style_cell'] = function(tt, column, row, style)
	local newstyle = GUI.layerstyle(tt._track._table[row][column].style, style)
	tt._track._table[row][column].style = newstyle
	if tt._track._auto_update then
		GUI.styletext('%s %d %d':format(tostring(tt), row, column), newstyle)
	end
end

_meta.TextTable.__methods['style_row'] = function(tt, row, style)
	tt._track._row_style[row] = GUI.layerstyle(tt._track._row_style[row] or style, style)  --style
	for colindex, colkey in ipairs(tt._track._columns) do
		local newstyle = GUI.layerstyle(tt._track._table[row][colindex].style, style)
		tt._track._table[row][colindex].style = newstyle
		if tt._track._auto_update then
			GUI.styletext('%s %d %d':format(tostring(tt), row, colindex), newstyle)
		end
	end
end

_meta.TextTable.__methods['style_column'] = function(tt, col, style)
	--tt._track._col_style[col] = style -- 
	tt._track._col_style[col] = GUI.layerstyle(tt._track._col_style[col] or style, style)
	for rowindex, rowkey in ipairs(tt._track._rows) do
		local newstyle = GUI.layerstyle(tt._track._table[rowindex][col].style, style)
		tt._track._table[rowindex][col].style = newstyle
		if tt._track._auto_update then
			GUI.styletext('%s %d %d':format(tostring(tt), rowindex, col), newstyle)
		end
	end
end

_meta.TextTable.__methods['style_all'] = function(tt, style)
	-- merge any column specific styles
	for colindex, colkey in ipairs(tt._track._columns) do
		if tt._track._col_style[colindex] then
			for k, v in pairs(tt._track._col_style[colindex].style) do
				if style[k] then -- if the new style needs to overwrite this
					tt._track._col_style[colindex].style[k] = style[k]
				end
			end
			-- if the column style is completely overwritten by the new style, get rid of it
			if T(tt._track._col_style[colindex].style):equals(style) then
				tt._track._col_style[colindex] = nil
			end
		end
	end
	-- do the same for rows as we did columns
	for rowindex, rowkey in ipairs(tt._track._rows) do
		if tt._track._row_style[rowindex] then
			for k, v in pairs(tt._track._row_style[rowindex].style) do
				if style[k] then
					tt._track._row_style[rowindex].style[k] = style[k]
				end
			end
			if T(tt._track._row_style[rowindex].style):equals(style) then
				tt._track._row_style[rowindex] = nil
			end
		end
	end
	-- Now we actually change the cells styles
	for rowindex, rowkey in ipairs(tt._track._rows) do
		for colindex, colkey in ipairs(tt._track._columns) do
			local newstyle = GUI.layerstyle(tt._track._table[rowindex][columnindex].style, style)
			tt._track._table[rowindex][columnindex].style = newstyle
			if tt._track._auto_update then
				GUI.styletext('%s %d %d':format(tostring(tt), row, column), newstyle)
			end
		end
	end	
end

_meta.TextTable.__methods['align_column'] = function(tt, column, align) -- set the alignment for every cell in a column number
	tt:style_column(column, {align=align})
end

_meta.TextTable.__methods['refresh_style'] = function(tt)
	for rowindex, rowkey in ipairs(tt._track._rows) do
		for colindex, colkey in ipairs(tt._track._columns) do
			GUI.styletext('%s %d %d':format(tostring(tt), rowindex, colindex), tt._track._table[rowindex][colindex].style)
		end
	end
end

_meta.TextTable.__methods['refresh_values'] = function(tt) -- update the values in every cell

	for rowindex, rowkey in ipairs(tt._track._rows) do
		for colindex, colkey in ipairs(tt._track._columns) do
			local value = tt._track._var[rowkey][colkey]
			-- value is either a static thing to be displayed, or a function that returns the thing to be displayed
			value = type(value) == 'function' and value({row=rowindex, col=colindex, column=colindex}) or value or ''
			-- Now value is the string that will be displayed
			tt._track._table[rowindex][colindex].value = value
			windower.text.set_text('%s %d %d':format(tostring(tt), rowindex, colindex), value)
		end
	end
end

_meta.TextTable.__methods['recalculate_cell_sizes'] = function(tt) -- recalculate the width and height of every cell
	local row_heights = {}
	local col_widths = {}
	for rowindex, rowkey in ipairs(tt._track._rows) do
		for colindex, colkey in ipairs(tt._track._columns) do
			local w, h = windower.text.get_extents('%s %d %d':format(tostring(tt), rowindex, colindex))
			tt._track._table[rowindex][colindex].extents = { --each cell tracks its own size.  Don't know why, but it might come in handy
				w = w,
				h = h
			}
			-- calculate the width and height of each row
			if h >= (row_heights[rowindex] or 0) then -- is this the tallest cell in the row?
				row_heights[rowindex] = h
			end
			if w >= (col_widths[colindex] or 0) then -- is this the widest cell in our column?
				col_widths[colindex] = w
			end
		end
	end
	tt._track._row_heights = row_heights
	tt._track._col_widths = col_widths
	
	if tt._row_size_override then
		for rowindex, size in ipairs(tt._row_size_override) do -- override automatic sizes with user-specified sizes
			tt._track._row_heights[rowindex] = size
		end
	end
	if tt._col_size_override then
		for colindex, size in ipairs(tt._col_size_override) do
			tt._track._col_widths[colindex] = size
		end
	end
	
	-- now calculate the x coord for each col, and y coord for each row
	local y = tt._track._y -- Calculate the y coord for each row
	for rowindex, rowkey in ipairs(tt._track._rows) do
		tt._track._row_y[rowindex] = y
		--print(rowindex, tt._track._row_heights[row_index])
		y = y + tt._track._row_heights[rowindex] + tt._track._pad_y
	end
	
	local x = tt._track._x -- now do the same for the columns
	for colindex, colkey in ipairs(tt._track._columns) do
		tt._track._col_x[colindex] = x
		x = x + tt._track._col_widths[colindex] + tt._track._pad_x
	end
	-- the sizes and positions of all cells are now calculated
end

_meta.TextTable.__methods['resize'] = function(tt)
	if tt._track._height ~= #tt._track._var then -- if the number of rows we're set to display no longer matches the number of rows we have
		self = tostring(tt)	
		local newheight = #tt._track._var
		local rowrange = math.max(newheight, tt._track._height)
		for rowindex, rowkey in ipairs(GUI.range(1, rowrange)) do
			if not tt._track._table[rowindex] then
				tt._track._table[rowindex] = {}
			end
			if rowindex > newheight then -- delete items outside the new range
				if not tt._track._table[rowindex] then
					tt._track._table[rowindex] = {}
				end
				for colindex, colkey in ipairs(tt._track._columns) do
					windower.text.delete('%s %d %d':format(self, rowindex, colindex))
					tt._track._table[rowindex][colindex] = nil
				end
			elseif not tt._track._table[rowindex][1] then -- we need to create new cells
				for colindex, colkey in ipairs(tt._track._columns) do
					tt._track._table[rowindex][colindex] = {}	-- initialize the cell.
					cellstyle = tt._track._default_style
					if tt._track._col_style[colindex] then
						cellstyle = GUI.layerstyle(cellstyle, tt._track._col_style[colindex])
					end
					if tt._track._row_style[rowindex] then
						cellstyle = GUI.layerstyle(cellstyle, tt._track._row_style[rowindex])
					end

					tt._track._table[rowindex][colindex].style = cellstyle
					tt._track._table[rowindex][colindex].extents = {w=0,h=0}
					
					local textname = '%s %d %d':format(self, rowindex, colindex) -- name of text object
					windower.text.create(textname) -- Create the text object
					GUI.styletext(textname, tt._track._table[rowindex][colindex].style)
					windower.text.set_visibility(textname, true)
				end
			end
		end
	
		tt._track._height = #tt._track._var
		tt._track._rows = GUI.range(1, tt._track._height)
	end
end

_meta.TextTable.__methods['redraw'] = function(tt)
	tt:resize()
	tt:refresh_values()
	--tt:refresh_style()
	
	GUI.subscribe_postrender(tt)
end

_meta.TextTable.__methods['update'] = _meta.TextTable.__methods['redraw']

_meta.TextTable.__methods['postrender'] = function(tt)
	--print('debug postrender')
	tt:recalculate_cell_sizes()
	for rowindex, rowkey in ipairs(tt._track._rows) do
		for colindex, colkey in ipairs(tt._track._columns) do
			local cell = tt._track._table[rowindex][colindex]
			windower.text.set_location('%s %d %d':format(tostring(tt), rowindex, colindex), tt._track._col_x[colindex] + (cell.style.align == 'right' and tt._track._col_widths[colindex] or 0), tt._track._row_y[rowindex])
		end
	end
	if tt._track._framecounter == 2 then
		GUI.unsubscribe_postrender(tt)
		tt._track._framecounter = 0
		return
	end
	tt._track._framecounter = tt._track._framecounter + 1
end

_meta.TextTable.__methods['undraw'] = function(tt)
	for rowindex, rowkey in ipairs(tt._track._rows) do
		for colindex, colkey in ipairs(tt._track._columns) do
			windower.text.delete('%s %d %d':format(tostring(tt), rowindex, colindex))
		end
	end
	if tt._track._auto_update then
		--GUI.unregister_update_object(tt._track._auto_update)
		GUI.unregister_update_object(tt)
	end
	GUI.unsubscribe_postrender(tt)
end

function GUI.styletext(textname, style)
	windower.text.set_font(textname, style.font)
	windower.text.set_font_size(textname, style.font_size)
	windower.text.set_color(textname, table.unpack(style.color))
	windower.text.set_bold(textname, style.bold)
	if style.stroke then
		windower.text.set_stroke_color(textname, table.unpack(style.stroke_color))
	else
		windower.text.set_stroke_color(textname, 0, 0, 0, 0)
	end
	windower.text.set_stroke_width(textname, style.stroke_width)
	windower.text.set_right_justified(textname, style.align == 'right')
end

function GUI.layerstyle(bottom, top)
	local n = {}
	for i, v in ipairs({'font', 'font_size', 'color', 'bold', 'stroke', 'stroke_width', 'stroke_color', 'align'}) do
		n[v] = top[v] or bottom[v]
	end
	return n
end

function GUI.range(min, max)
	local l = {}
	local i = 1
	for v=min, max do
		l[i] = v
		i = i + 1
	end
	return l
end

_meta.TextTable.__index = function(tt, k)
	if type(k) == 'string' then
		local lk = k:lower()
		return _meta.TextTable.__methods[lk]
	elseif type(k) == 'number' then
		return tt._track._table[k]
	end
end
