

function create_prim(name, path, bool)
	windower.prim.create(name)
	windower.prim.set_texture(name, path)
	windower.prim.set_visibility(name, bool)
	windower.prim.set_size(name, 50, 50)
	windower.prim.set_fit_to_texture(name, true)
	saved_prims[name] = {}
	saved_prims[name].path = path
	saved_prims[name].visibility = bool
	saved_prims[name].size = {}
	saved_prims[name].size.width = 50
	saved_prims[name].size.height = 50
end

function set_prim_position(name, x, y)
	windower.prim.set_position(name, x, y)
	saved_prims[name].position = {}
	saved_prims[name].position.pos_x = x
	saved_prims[name].position.pos_y = y
end

function set_bg_position(name, x, y)
	windower.prim.set_position(name, x, y)
	saved_bg[name].position = {}
	saved_bg[name].position.pos_x = x
	saved_bg[name].position.pos_y = y
end

function set_prim_visibility(name, bool)
	windower.prim.set_visibility(name, bool)
	saved_prims[name].visibility = bool
end

function set_bg_visibility(name, bool)
	windower.prim.set_visibility(name, bool)
	saved_bg[name].visibility = bool
end

function set_prim_color(name, a, r, g, b)
	windower.prim.set_color(name, a, r, g, b)
end

function create_background(name,x,y)
	windower.prim.create(name)
	windower.prim.set_size(name, 510, 320)
	windower.prim.set_position(name, x, y)
	windower.prim.set_color(name, 150, 50, 50, 50)
	windower.prim.set_visibility(name, false)
	windower.prim.set_texture(name, windower.addon_path..'textures/back.bmp')
	saved_bg[name] = {}
	saved_bg[name].visibility = false
	saved_bg[name].size = {}
	saved_bg[name].size.width = 510
	saved_bg[name].size.height = 370
	saved_bg[name].position = {}
	saved_bg[name].position.pos_x = x
	saved_bg[name].position.pos_y = y
	saved_bg[name].color = {}
	saved_bg[name].color.alpha = 150
	saved_bg[name].color.red = 50
	saved_bg[name].color.green = 50
	saved_bg[name].color.blue = 50
	saved_bg[name].dragable = true

end

function is_hovering(name,x,y)
	local x_bool = false
	local y_bool = false
	
	if x > saved_prims[name].position.pos_x and x < (saved_prims[name].position.pos_x + saved_prims[name].size.width) then
		x_bool = true
		--log('x hit ' .. tostring(x_bool))
	end
	if y > saved_prims[name].position.pos_y and y < (saved_prims[name].position.pos_y + saved_prims[name].size.height) then
		y_bool = true
		--log('y hit ' .. tostring(y_bool))
	end
	if x_bool == true and y_bool == true then
		return true
	else
		return false
	end
end

function is_hovering_bg(x,y)
	local x_bool = false
	local y_bool = false
	
	if x > saved_bg['back'].position.pos_x and x < (saved_bg['back'].position.pos_x + saved_bg['back'].size.width) then
		x_bool = true
		--log('x hit ' .. tostring(x_bool))
	end
	if y > saved_bg['back'].position.pos_y and y < (saved_bg['back'].position.pos_y + saved_bg['back'].size.height) then
		y_bool = true
		--log('y hit ' .. tostring(y_bool))
	end
	if x_bool == true and y_bool == true then
		return true
	else
		return false
	end
end

function create_text(name, str, bool)
	windower.text.create(name)
	--windower.text.set_text(name, tostring(str))
	windower.text.set_bg_color(name, 0, 0, 0,0)	
	windower.text.set_bg_visibility(name, bool)
	windower.text.set_bold(name, true)
	windower.text.set_color(name, 255, 255, 255,50)
	windower.text.set_font_size(name, 15)
	windower.text.set_visibility(name, bool)
	windower.text.set_font(name, 'Lucida Console')
	windower.text.set_bg_border_size(name, 5)
	saved_texts[name] = {}
	saved_texts[name].background = {}
	saved_texts[name].background.color = {}
	saved_texts[name].background.color.alpha = 0
	saved_texts[name].background.color.red = 0
	saved_texts[name].background.color.green = 0
	saved_texts[name].background.color.blue = 0
	saved_texts[name].background.visibility = bool
	saved_texts[name].text = {}
	saved_texts[name].text.font = 'Lucida Console'
	saved_texts[name].text.font_size = 15	
	saved_texts[name].text.color = {}
	saved_texts[name].text.color.alpha = 255
	saved_texts[name].text.color.red = 255
	saved_texts[name].text.color.green = 255
	saved_texts[name].text.color.blue = 50
	saved_texts[name].text.visibility = bool
	--saved_texts[name].text.string = str
	
	if type(str) == 'number' then
		set_text(name, str)
	else
		windower.text.set_text(name, str)
		saved_texts[name].text.string = str
	end
	
end

function set_text_visibility(name, bool)
	windower.text.set_visibility(name, bool)
	windower.text.set_bg_visibility(name, bool)
	saved_texts[name].text.visibility = bool
end

function update_all_positions()
	local x = saved_bg['back'].position.pos_x + 100
	for k, v in ipairs(positions) do
		set_prim_position(v.element, x, (saved_bg['back'].position.pos_y + 110))
		x = x + 50
	end
	set_prim_position('thwack', (saved_bg['back'].position.pos_x + 100), (saved_bg['back'].position.pos_y + 10))
	set_prim_position('repair_furnace', (saved_bg['back'].position.pos_x + 150), (saved_bg['back'].position.pos_y + 10))
	set_prim_position('recycle', (saved_bg['back'].position.pos_x + 200), (saved_bg['back'].position.pos_y + 10))
	set_prim_position('end', (saved_bg['back'].position.pos_x + 450), (saved_bg['back'].position.pos_y + 10))
	set_prim_position('pressure', (saved_bg['back'].position.pos_x + 100), (saved_bg['back'].position.pos_y + 260))
	set_prim_position('safety_lever', (saved_bg['back'].position.pos_x + 200), (saved_bg['back'].position.pos_y + 260))	
	set_prim_position('smock', (saved_bg['back'].position.pos_x + 300), (saved_bg['back'].position.pos_y + 10))
	set_prim_position('re-fewell', (saved_bg['back'].position.pos_x + 350), (saved_bg['back'].position.pos_y + 10))
	for k, v in ipairs(positions) do
		set_text_position('current_'..v.element, (saved_prims[v.element].position.pos_x + 8 ), (saved_prims[v.element].position.pos_y + 52))
		set_text_position('needed_'..v.element, (saved_prims[v.element].position.pos_x + 8 ), (saved_prims[v.element].position.pos_y + 90))
		set_text_position('fewell_'..v.element, (saved_prims[v.element].position.pos_x + 8 ), (saved_prims[v.element].position.pos_y - 40))
	end
	set_text_position('fewell', (saved_bg['back'].position.pos_x + 10), (saved_bg['back'].position.pos_y + 70))
	set_text_position('current', (saved_bg['back'].position.pos_x + 10), (saved_texts['current_fire'].position.pos_y - 2))
	set_text_position('needed', (saved_bg['back'].position.pos_x + 10), (saved_texts['current'].position.pos_y + 37))	
	set_text_position('pressure', (saved_prims['pressure'].position.pos_x + 55), (saved_prims['pressure'].position.pos_y + 10))
	set_text_position('safety_lever', (saved_prims['safety_lever'].position.pos_x + 55), (saved_prims['safety_lever'].position.pos_y + 10))
	windower.prim.set_position('HP_bar_BG', (saved_bg['back'].position.pos_x + 100), (saved_texts['needed'].position.pos_y + 35))
	windower.prim.set_position('HP_bar_FG', (saved_bg['back'].position.pos_x + 101), (saved_texts['needed'].position.pos_y + 36))
	set_text_position('HP', (saved_bg['back'].position.pos_x + 25), (saved_texts['needed'].position.pos_y + 24))
	
end

function set_text(name, number)
	local str = tostring(number)
	if string.length(str) == 1 then
		str = string.lpad(str, '0', 2)
	elseif string.length(str) == 2 and string.startswith(str, '-') then
		n = number * (-1)
		n = tostring(n)
		str = string.lpad(n, '0', 2)
		str = '-'..str
	end
	windower.text.set_text(name, str)
	saved_texts[name].text.string = number
end

function set_text_position(name, x,y)
	windower.text.set_location(name, x, y)
	saved_texts[name].position = {}
	saved_texts[name].position.pos_x = x
	saved_texts[name].position.pos_y = y
end

function hide_all()
	for k, v in pairs(saved_prims) do
		set_prim_visibility(k, false)
	end
	for k, v in pairs(saved_texts) do
		set_text_visibility(k, false)
	end
	for k, v in pairs(saved_bg) do
		set_bg_visibility(k, false)
	end
	windower.prim.set_visibility('HP_bar_BG', false)
	windower.prim.set_visibility('HP_bar_FG', false)
end

function hide_end_synergy()
	set_prim_visibility('thwack', false)
	set_prim_visibility('repair_furnace', false)
	set_prim_visibility('recycle', false)
	set_prim_visibility('end', false)
	set_prim_visibility('pressure', false)
	set_prim_visibility('safety_lever', false)
	set_prim_visibility('smock', false)
	
	for k, v in pairs(saved_texts) do
		if k ~= 'fewell' and not k:find('fewell_') then
			set_text_visibility(k, false)
		end
	end
	windower.prim.set_visibility('HP_bar_BG', false)
	windower.prim.set_visibility('HP_bar_FG', false)
end

function make_synergy_visible()

	for k, v in pairs(saved_prims) do
		if k ~= 're-fewell' then
			set_prim_visibility(k, true)
		end
	end
	for k, v in pairs(saved_texts) do
		set_text_visibility(k, true)
	end
	for k, v in pairs(saved_bg) do
		set_bg_visibility(k, true)
	end
	windower.prim.set_visibility('HP_bar_BG', true)
	windower.prim.set_visibility('HP_bar_FG', true)
end
