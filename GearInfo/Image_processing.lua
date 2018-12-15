local dragged

math.randomseed(os.clock())

imageColors = L{'red','blue','green','dark-blue','grey','light-green','orange','pink','purple','yellow'}

--[[ui scaling shrinks display 
	x_res = 1920
	y_res = 1080
	ui_x_res = 1476
	ui_y_res = 830
	settings = ui scale 1.3
	ui_x_res = x_res / ui scale 
]]--
-- image / icon Block Class
ImageBlock = {
	x = 0,
	y = 0,
	width = 228,
	height = 42,
	alpha = 255,
	red = 255,
	green = 255,
	blue = 255,
	visible = true,
	draggable = false,
	fit = true,

	New = function(order, image_type, image_color, text1, text2)
		local o = {}
		for k, v in pairs(ImageBlock) do
			o[k] = v
		end
		local order_exists = false
		if table.length(sections) > 0 then
			if sections[image_type] and image_type == 'background' then
				return error('can only have 1 background!')
			elseif image_type == 'background' then 
				order = 0 
			end
			if sections[image_type] and image_type == 'logo' then
				return error('can only have 1 logo!')
			elseif image_type == 'logo' then 
				order = 1
			end
			if image_type == 'block' and table.length(sections.block) > 0 then
				for k, v in pairs(sections.block)  do
					if sections[image_type][k] and sections[image_type][k].order == order then
						order_exists = true
					end
				end
				if order_exists == false then
					o.order = order
				else
					return error('order magnitude ' .. order .. ' is already assigned!')
				end
			elseif image_type == 'block' and table.length(sections.block) == 0 then
				o.order = order
			end
		end
		
		if image_type == 'background' then
			o.width = 228
			o.height = 42
			o.image_path = ''
			o.dragable = true
			o.alpha = 255
			o.red = 0
			o.green = 0 
			o.blue = 0
			o.image_path = ''
			o.type = image_type
			o.color = image_color
			o.name = (_addon and _addon.name or 'image') .. '_gensym_' .. tostring(t):sub(8) .. '_%.8x':format(16^8 * math.random()):sub(3)
			o.x = settings.display.pos.x
			o.y = settings.display.pos.y
		elseif image_type == 'logo' then
			o.width = 228
			o.height = 42
			o.type = image_type
			o.color = image_color
			o.image_path = windower.addon_path..'textures/'.. image_type ..'.png'
			o.name = (_addon and _addon.name or 'image') .. '_gensym_' .. tostring(t):sub(8) .. '_%.8x':format(16^8 * math.random()):sub(3)
			o.x = sections.background:position_x()
			o.y = sections.background:position_y()
			
		elseif image_type == 'block' then
			if imageColors:contains(image_color) then
				o.width = 57
				o.height = 42
				o.type = image_type
				o.color = image_color
				o.image_path = windower.addon_path..'textures/'..image_color ..'.png'
				o.name = (_addon and _addon.name or 'image') .. '_gensym_' .. tostring(t):sub(8) .. '_%.8x':format(16^8 * math.random()):sub(3)
				o.x, o.y = get_position(o)
				o.text = {}
				
	
				o.text[1] = {name = 'text1'..o.name, text = text1, offset_x = 3 , offset_y = 3}
				
				windower.text.create(o.text[1].name)
				windower.text.set_text(o.text[1].name, o.text[1].text)
				--windower.text.set_color(o.text[1].name, 255, 0, 0, 0)
				windower.text.set_color(o.text[1].name, 255, 150,150,235)
				windower.text.set_font_size(o.text[1].name, 9)
				windower.text.set_visibility(o.text[1].name, true)
				windower.text.set_font(o.text[1].name,'Tahoma') --'Verdana'
				windower.text.set_stroke_width(o.text[1].name, 0)
				windower.text.set_stroke_color(o.text[1].name, 255, 0, 0, 0)
				--windower.text.set_stroke_color(o.text[1].name, 255, 247,243,195)
				windower.text.set_location(o.text[1].name, o.text[1].offset_x + o.x, o.text[1].offset_y + o.y)
				windower.text.set_bold(o.text[1].name, true)
				
				--print(windower.text.get_extents(o.text[1].name))
				
				o.text[2] = {name = 'text2'..o.name, text = text2, offset_x = 3 , offset_y = 20}
				
				windower.text.create(o.text[2].name)
				windower.text.set_text(o.text[2].name, o.text[2].text)
				windower.text.set_bold(o.text[2].name, false)
				windower.text.set_color(o.text[2].name, 255, 255, 255, 255)
				windower.text.set_font_size(o.text[2].name, 12)
				windower.text.set_visibility(o.text[2].name, true)
				windower.text.set_font(o.text[2].name,'Tahoma') --'Verdana'
				windower.text.set_stroke_width(o.text[2].name, 0)
				windower.text.set_stroke_color(o.text[2].name, 255, 0, 0, 0)
				windower.text.set_location(o.text[2].name, o.text[2].offset_x + o.x, o.text[2].offset_y + o.y)
				
			else
				return error('Wrong color type')
			end
		else
			return error('Wrong image type!')
		end

		windower.prim.create(o.name)
		windower.prim.set_color(o.name, o.alpha, o.red, o.green, o.blue)
		windower.prim.set_texture(o.name, o.image_path)
		windower.prim.set_fit_to_texture(o.name, o.fit)
		windower.prim.set_size(o.name, o.width, o.height)
		windower.prim.set_visibility(o.name, o.visible)
		windower.prim.set_position(o.name, o.x, o.y)
		
		return o
	end,
	
	-- Makes the primitive visible
	show = function(self)
		windower.prim.set_visibility(self.name, true)
		self.visible = true
	end,

	-- Makes the primitive invisible
	hide = function(self)
		windower.prim.set_visibility(self.name, false)
		self.visible = false
	end,
	
	-- Returns whether or not the image object is visible
	visible = function(self, visible)
		if visible == nil then
			return self.visible
		end
		windower.prim.set_visibility(self.name, visible)
	end,
	
	position = function(self, new_x, new_y)
		if new_x == nil then
			return self.x, self.y
		end
		self.x = new_x
		self.y = new_y
		windower.prim.set_position(self.name, new_x, new_y)
		if self.type == 'block' then
			windower.text.set_location(self.text[1].name, new_x + self.text[1].offset_x , new_y + self.text[1].offset_y)
			windower.text.set_location(self.text[2].name, new_x + self.text[2].offset_x , new_y + self.text[2].offset_y)
		end
	end,
	
	position_x = function(self, new_x)
		if new_x == nil then
			return self.x
		end
		self:position(new_x, self.y)
		if self.type == 'block' then
			windower.text.set_location(self.text[1].name, new_x + self.text[1].offset_x , self.y + self.text[1].offset_y)
			windower.text.set_location(self.text[2].name, new_x + self.text[2].offset_x , self.y + self.text[2].offset_y)
		end
	end,
	
	position_y = function(self, new_y)
		if new_y == nil then
			return self.y
		end
		self:position(self.x, new_y)
		if self.type == 'block' then
			windower.text.set_location(self.text[1].name, self.x + self.text[1].offset_x , new_y + self.text[1].offset_y)
			windower.text.set_location(self.text[2].name, self.x + self.text[2].offset_x , new_y + self.text[2].offset_y)
		end
	end,
	
	image_size = function(self, width, height)
		if width == nil then
			return self.width, self.height
		end

		windower.prim.set_size(self.name, width, height)
		self.width = width
		self.height = height
	end,
	
	image_width = function(self, width)
		if width == nil then
			return self.width
		end

		self:size(width, self.height)
	end,
	
	image_height = function(self, height)
		if height == nil then
			return self.height
		end

		self:size(self.width, height)
	end,
	
	get_extents = function(self)
		
		local ext_x = self.x + self.width
		local ext_y = self.y + self.height

		return ext_x, ext_y
	end,
	
	hover = function(self, mouse_x, mouse_y)
		if not self:visible() then
			return false
		end
		
		local x_bool = false
		local y_bool = false
		local pos_x, pos_y = self:position()
		local off_x, off_y = self:get_extents()
		
		if mouse_x >= pos_x and mouse_x <= (pos_x + self.width) then
			x_bool = true
			--log('x hit ' .. tostring(x_bool))
		end
		if mouse_y > pos_y and mouse_y < (pos_y + self.height) then
			y_bool = true
			--log('y hit ' .. tostring(y_bool))
		end
		if x_bool == true and y_bool == true then
			return true
		else
			return false
		end
		
	end,
	
	draggable = function(self, drag)
		if drag == nil then
			return self.draggable
		end

		self.draggable = drag
	end,
	
	image_color = function(self, red, green, blue)
		if red == nil then
			return self.red, self.green, self.blue
		end

		windower.prim.set_color(self.name, self.alpha, red, green, blue)
		self.red = red
		self.green = green
		self.blue = blue
	end,
	
	image_alpha = function(self, alpha)
		if alpha == nil then
			return self.alpha
		end

		windower.prim.set_color(self.name, alpha, self.red, self.green, self.blue)
		self.alpha = alpha
	end,
	
	pos_diff = function (self, t)
		local self_x, self_y = self:position()
		local bg_x, bg_y = t:position()
		
		return self_x - bg_x , self_y - bg_y
	end,
	
	delete = function(self)
		windower.prim.delete(self.name)
		for k, v in pairs(sections) do
			if k ~= 'block' then
				if v.name == self.name then
					sections[k] = nil
					check_positions()
				end
			else
				for i, j in pairs(v) do
					if j.name == self.name then	
						--notice('Delete '..k..' of color '..j.color.. '  '..j.name)
						windower.text.delete(self.text[1].name)
						windower.text.delete(self.text[2].name)
						sections[k][i] = nil
						check_positions()
					end
				end
			end
		end
	end,
	
}

--ImageBlock.mt.__index = ImageBlock
-- ImageBlock.mt.__newindex = function(self,k,v)
	-- error('cannot change '.. k.. ' to ' .. v.. ' in table ' ..tostring(self))
-- end

-- Handle drag and drop
windower.register_event('mouse', function(type, x, y, delta, blocked)
    if blocked then
        return
    end

    -- Mouse drag
    if type == 0 then
        if dragged then
			update_all(x - dragged.x, y - dragged.y, dragged.image )
			centre_all_text()
            dragged.image:position(x - dragged.x, y - dragged.y)
            return true
        end

    -- Mouse left click
    elseif type == 1 then
		if sections.background.draggable and sections.background:hover(x, y) then
			local pos_x, pos_y =sections.background:position()
			dragged = {image = sections.background, x = x - pos_x, y = y - pos_y}
			return true
		end
    -- Mouse left release
    elseif type == 2 then
        if dragged then
            dragged = nil
			settings.display.pos.x = sections.background:position_x()
			settings.display.pos.y = sections.background:position_y()
			settings:save('all')
            return true
        end
    end

    return false
end)

function update_all(x, y, background)
	local difx, dify = 0, 0
	
	if table.length(sections) > 0 then
		for k, v in pairs(sections) do
			if k ~= 'background' then
				if k == 'logo' then
					difx, dify = sections.logo:pos_diff(background)
					sections.logo:position(difx + x, dify + y)
				elseif k == 'block' then
					for i, j in pairs(v) do
						difx, dify = sections.block[i]:pos_diff(background)
						sections.block[i]:position(difx + x, dify + y)
					end
				end
			end
		end
	end
end

function check_positions()
	local x, y = 0, 0
	local max_columns = 4
	local min_rows = 1
	local block_count = table.length(sections.block) + 1
	local grid = {}
	local block_width = 57
	local block_height = 42
	local added = {}
	--notice('----------------------------------------------------------------------')
	local highest_order = 0
	local order_exists = {}
	
	for k, v in pairs(sections.block) do
		if sections.block[k].order > highest_order then
			highest_order = sections.block[k].order
		end
	end
	
	for i = 1, highest_order do
		if sections.block[i] then	
			order_exists[i] = true
		else
			order_exists[i] = false
		end
	end
	
	if block_count > 0 then min_rows = 2 end
	--print( (min_rows + math.floor((block_count - 1) / 4) ))
	for i = 1,  (min_rows + math.floor((block_count - 1) / 4) ) do
		grid[i] = {}
		for j = 1,  4 do
			grid[i][j] = {}
			grid[i][j]['empty'] = true
			grid[i][j]['image'] = {}
			if i == 1 and j < 5 then
				grid[i][j]['empty'] = false
				grid[i][j]['image'] = sections.logo
			end
			if grid[i][j]['empty'] == true then
				for k, v in ipairs(order_exists) do
					if not added[k] and v then
						grid[i][j]['empty'] = false
						grid[i][j]['image'] = sections.block[k]
						sections.block[k]:position_x(((j - 1) * block_width) + sections.background:position_x())
						sections.block[k]:position_y(((i - 1) * block_height) + sections.background:position_y())
						added[k] = true
						break
					end
				end
				-- for k, v in pairs(sections.block) do
					-- if not added[k] then
						-- --log('order = '..v.order)
						-- grid[i][j]['empty'] = false
						-- grid[i][j]['image'] = sections.block[k]
						-- sections.block[k]:position_x(((j - 1) * block_width) + sections.background:position_x())
						-- sections.block[k]:position_y(((i - 1) * block_height) + sections.background:position_y())
						-- added[k] = true
						-- break
					-- end
				-- end
			end
			--notice(i, j, grid[i][j]['empty'] )	
		end
	end
	
	for i = 1,  (min_rows + math.floor((block_count - 1) / 4) ) do
		for j = 1,  4 do
			if grid[i][j]['empty'] == false then
				--notice(i, j, grid[i][j]['empty'], grid[i][j]['image'].type,  grid[i][j]['image'].color)
				sections.background:image_size(228, (i * block_height))
			else
				--notice(i, j, grid[i][j]['empty'] )
			end
		end
	end
end

function get_position(this_image)
	local x, y = 0, 0
	local max_columns = 4
	local min_rows = 1
	local block_count = table.length(sections.block) + 1
	local grid = {}
	local block_width = 57
	local block_height = 42
	local order_start = 2
	--notice('----------------------------------------------------------------------')
	local added = {}
	local highest_order = 0
	local order_exists = {}
	-- print(this_image.order)
	for k, v in pairs(sections.block) do
		if sections.block[k].order > highest_order then
			highest_order = sections.block[k].order
		end
	end
	if this_image.order > highest_order then highest_order = this_image.order end
	
	for i = 1, highest_order do
		if sections.block[i] then	
			order_exists[i] = true
		else
			order_exists[i] = false
		end
		if (this_image.order - 1) == i then
			order_exists[i] = true
		end
	end
	--table.vprint(order_exists)
	--table.rekey(order_exists)
	
	if block_count > 0 then min_rows = 2 end
	--print( (min_rows + math.floor((block_count - 1) / 4) ))
	for i = 1,  (min_rows + math.floor((block_count - 1) / 4) ) do
		grid[i] = {}
		for j = 1,  4 do
			grid[i][j] = {}
			grid[i][j]['empty'] = true
			grid[i][j]['image'] = {}
			if i == 1 and j < 5 then
				grid[i][j]['empty'] = false
				grid[i][j]['image'] = sections.logo
			end
			if grid[i][j]['empty'] == true then
				for k, v in ipairs(order_exists) do
					if not added[k] and v and (this_image.order - 1) ~= k then
						grid[i][j]['empty'] = false
						grid[i][j]['image'] = sections.block[k]
						sections.block[k]:position_x(((j - 1) * block_width) + sections.background:position_x())
						sections.block[k]:position_y(((i - 1) * block_height) + sections.background:position_y())
						added[k] = true
						break
					end
					if not added[k] and (this_image.order - 1) == k then
						added[k] = true
						break
					end
				end
			end
			--notice(i, j, grid[i][j]['empty'] )	
		end
	end
	
	-- for i = 1,  (min_rows + math.floor((block_count - 1) / 4) ) do
		-- for j = 1,  4 do
			-- if grid[i][j]['empty'] == false then
				-- notice(i, j, grid[i][j]['empty'], grid[i][j]['image'].type,  grid[i][j]['image'].color)
			-- else
				-- notice(i, j, grid[i][j]['empty'] )
			-- end
		-- end
	-- end
	
	local added_last = false
	
	if this_image then
		for i = 1,  (min_rows + math.floor((block_count - 1) / 4) ) do
			for j = 1,  4 do
				if grid[i][j]['empty'] == true and added_last  == false then
					added_last  = true
					grid[i][j]['empty'] = false
					x = ((j - 1) * block_width) + sections.background:position_x()
					y = ((i - 1) * block_height) + sections.background:position_y()
					--notice(i, j, grid[i][j]['empty'], this_image.type, this_image.color)
				end
				sections.background:image_size(228, (i * block_height))
				--notice(i, j, grid[i][j]['empty'])
			end	
		end
		return x, y
	end
	
end

function centre_all_text()

--print(windower.text.get_extents(sections.block[1].text[1].name))

	for k, v in pairs(sections.block) do
		local width, height = windower.text.get_extents(sections.block[k].text[1].name)
		local width2, height2 = windower.text.get_extents(sections.block[k].text[2].name)
		--x offset = 3
		local centre_of_block = 57 / 2
		local centre_of_text = width / 2
		local centre_of_text2 = width2 / 2
		new_centre =  centre_of_block - centre_of_text
		new_centre2 =  centre_of_block - centre_of_text2
		windower.text.set_location(sections.block[k].text[1].name, new_centre + sections.block[k].x , sections.block[k].text[1].offset_y + sections.block[k].y)
		windower.text.set_location(sections.block[k].text[2].name, new_centre2 + sections.block[k].x , sections.block[k].text[2].offset_y + sections.block[k].y)
	end
end



