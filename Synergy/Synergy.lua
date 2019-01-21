--[[Copyright © 2016, Sebastien Gomez
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of <addon name> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Hugh Broome BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]--

_addon.name     = 'Synergy'
_addon.author   = 'Colway'
_addon.version  = '1.0.0'
_addon.commands = {'syn'}

require('tables')
require('strings')
require('luau')
require('pack')
require('lists')
require('logger')
require('sets')
images = require('images')
files = require('files')
packets = require('packets')
require('chat')
res = require('resources')
require('lists')
config = require('config')
require('Helper_functions')
require('Packet_injection')
require('info')

activate_synergy_part_one = false
activate_synergy_part_two = false
activated_by_command_re_refewell = false
activated_by_command = false
firstrun = true
in_synergy = false
block_commands = false
print_once = false
trade = false
recepie_aquired = false
saved_prims = {}
saved_bg = {}
saved_texts = {}
target = {}
actual_chars = {}
leak = ''
fix = ''
overload = false

drag_and_drop = false
mouse_safety = false
is_shift_modified = false
re_fewell_prim_deleted = false
activated_by_party = false
clicked = false

player = windower.ffxi.get_player()

if not windower.dir_exists(windower.addon_path..'data/') then
	windower.create_dir(windower.addon_path..'data/')
end

if not windower.file_exists(windower.addon_path..'data/'..player.name..'_data.lua') then
	
	defaults = {}
	defaults.display = {}
	defaults.display.pos = {}
	defaults.display.pos.x = 0
	defaults.display.pos.y = 0
		
	local f = io.open(windower.addon_path..'data/'..player.name..'_data.lua','w+')
	f:write('return ' .. T(defaults):tovstring())
	f:close()
end

function load_settings()
	
	local f = io.open(windower.addon_path..'data/'..player.name..'_data.lua','r')
	local t = f:read("*all")
	t = assert(loadstring(t))()
	f:close()
	
	return t
	
end

function save_settings()
	
	local f = io.open(windower.addon_path..'data/'..player.name..'_data.lua','w+')
	f:write('return ' .. T(settings):tovstring())
	f:close()
	
end

local initialized = false

function initialize()
	if not windower.ffxi.get_info().logged_in then 
		return 
	end
	
	settings = load_settings()
	
	create_background('back',settings.display.pos.x,settings.display.pos.y)
	
	local x = saved_bg['back'].position.pos_x + 100
	for k, v in ipairs(positions) do
		create_prim(v.element, windower.addon_path..'textures/'..v.element.. '.bmp', false)
		set_prim_position(v.element, x, (saved_bg['back'].position.pos_y + 110))
		x = x + 50
		--set_text_position(v.element, v.x, (v.y + 50))
	end
	
	create_prim('thwack', windower.addon_path..'textures/thwack.bmp', false)
	set_prim_position('thwack', (saved_bg['back'].position.pos_x + 100), (saved_bg['back'].position.pos_y + 10))
	create_prim('repair_furnace', windower.addon_path..'textures/repair_furnace.bmp', false)
	set_prim_position('repair_furnace', (saved_bg['back'].position.pos_x + 150), (saved_bg['back'].position.pos_y + 10))
	create_prim('recycle', windower.addon_path..'textures/recycle.bmp', false)
	set_prim_position('recycle', (saved_bg['back'].position.pos_x + 200), (saved_bg['back'].position.pos_y + 10))
	create_prim('end', windower.addon_path..'textures/end.bmp', false)
	set_prim_position('end', (saved_bg['back'].position.pos_x + 450), (saved_bg['back'].position.pos_y + 10))
	
	create_prim('pressure', windower.addon_path..'textures/pressure.bmp', false)
	set_prim_position('pressure', (saved_bg['back'].position.pos_x + 100), (saved_bg['back'].position.pos_y + 260))
	create_prim('safety_lever', windower.addon_path..'textures/safety_lever.bmp', false)
	set_prim_position('safety_lever', (saved_bg['back'].position.pos_x + 200), (saved_bg['back'].position.pos_y + 260))
	
	create_prim('smock', windower.addon_path..'textures/smock.bmp', false)
	set_prim_position('smock', (saved_bg['back'].position.pos_x + 300), (saved_bg['back'].position.pos_y + 10))
	
	for k, v in ipairs(positions) do
		create_text('current_'..v.element, 0, false)
		set_text_position('current_'..v.element, (saved_prims[v.element].position.pos_x + 8 ), (saved_prims[v.element].position.pos_y + 52))
		create_text('needed_'..v.element, 0, false)
		set_text_position('needed_'..v.element, (saved_prims[v.element].position.pos_x + 8 ), (saved_prims[v.element].position.pos_y + 90))
		create_text('fewell_'..v.element, 99, false)
		set_text_position('fewell_'..v.element, (saved_prims[v.element].position.pos_x + 8 ), (saved_prims[v.element].position.pos_y - 40))
		--set_text_position(v.element, v.x, (v.y + 50))
	end
	create_text('fewell', 'Fewell', false)
	set_text_position('fewell', (saved_bg['back'].position.pos_x + 10), (saved_bg['back'].position.pos_y + 70))
	create_text('current', 'Current', false)
	set_text_position('current', (saved_bg['back'].position.pos_x + 10), (saved_texts['current_fire'].position.pos_y - 2))
	create_text('needed', 'Needed', false)
	set_text_position('needed', (saved_bg['back'].position.pos_x + 10), (saved_texts['current'].position.pos_y + 37))	
	create_text('pressure', 0, false)
	set_text_position('pressure', (saved_prims['pressure'].position.pos_x + 55), (saved_prims['pressure'].position.pos_y + 10))
	create_text('safety_lever', 0, false)
	set_text_position('safety_lever', (saved_prims['safety_lever'].position.pos_x + 55), (saved_prims['safety_lever'].position.pos_y + 10))
	
	windower.prim.create('HP_bar_BG')
	windower.prim.set_texture('HP_bar_BG', windower.addon_path..'textures/Bar_BG.png')
	windower.prim.set_visibility('HP_bar_BG', false)
	windower.prim.set_size('HP_bar_BG', 50, 50)
	windower.prim.set_fit_to_texture('HP_bar_BG', true)
	windower.prim.set_position('HP_bar_BG', (saved_bg['back'].position.pos_x + 100), (saved_texts['needed'].position.pos_y + 35))
	set_prim_color('HP_bar_BG', 150, 50, 50, 50)
	
	windower.prim.create('HP_bar_FG')
	windower.prim.set_texture('HP_bar_FG', windower.addon_path..'textures/Bar_FG.png')
	windower.prim.set_visibility('HP_bar_FG', false)
	windower.prim.set_size('HP_bar_FG', 398, 7)
	windower.prim.set_fit_to_texture('HP_bar_FG', false)
	windower.prim.set_position('HP_bar_FG', (saved_bg['back'].position.pos_x + 101), (saved_texts['needed'].position.pos_y + 36))
	create_prim('re-fewell', windower.addon_path..'textures/re-fewell.bmp', false)
	set_prim_position('re-fewell', (saved_bg['back'].position.pos_x + 350), (saved_bg['back'].position.pos_y + 10))
	create_text('HP', 'HP%', false)
	set_text_position('HP', (saved_bg['back'].position.pos_x + 25), (saved_texts['needed'].position.pos_y + 24))
end

windower.register_event('load', function()
	initialize()
end)

local fps = 1
local command_fps = 0
local array_fps = 0
local first_check = false
Synergy_Engineer_id = false
local near_Engineer = false

windower.register_event('prerender',function()
	if in_synergy then
		if fps == 1 then
			if target["Target Index"] then
				hpp = windower.ffxi.get_mob_by_index(target["Target Index"]).hpp
				size = 398/100 * hpp
				windower.prim.set_size('HP_bar_FG', size, 7)
			else
				size = 398/100 * 0
				windower.prim.set_size('HP_bar_FG', size, 7)
			end
		end
		if leak ~= '' then
			for k, v in pairs(saved_prims) do
				if k == leak then
					if fps < 15 then
						set_prim_color(fix, 255, 255, 128, 0)
					else
						set_prim_color(fix, 255, 255, 255, 255)
					end
				end	
			end
		else
			set_prim_color(fix, 255, 255, 255, 255)
		end
		if command_fps > 35 then
			block_commands = false
		end
		if overload then
			if fps < 15 then
				set_prim_color('back', 150, 255, 0, 0)
			else
				set_prim_color('back', 150, 50, 50, 50)
			end
		else
			set_prim_color('back', 150, 50, 50, 50)
		end
		command_fps = command_fps + 1
		fps = fps + 1
		if fps > 30 then
			fps = 1
		end
	end
	
	if near_Engineer == false and in_synergy == false and Synergy_Engineer_id == false then
		if fps == 1 and Synergy_Engineer_id == false then
			for k,v in pairs(windower.ffxi.get_mob_array()) do
				if v.distance:sqrt() < 6 and v.name == 'Synergy Engineer' then
					Synergy_Engineer_id = v.id	
				end
			end
		end
		inject_0x10f()
		if Synergy_Engineer_id and fps == 1 then
			local distance = windower.ffxi.get_mob_by_id(Synergy_Engineer_id).distance
			-- turn distance into yalms to match the distance addon
			distance = distance:sqrt()
			if distance > 0 and distance < 6 and first_check == false then
				near_Engineer = true
				settings = load_settings()
				
				set_bg_visibility('back', true)
				local x = saved_bg['back'].position.pos_x + 100
				for k, v in ipairs(positions) do
					set_prim_visibility(v.element, true)
				end
				set_text_visibility('fewell', true)
				for k, v in ipairs(positions) do
					set_text_visibility('fewell_'..v.element, true)
				end
				set_prim_visibility('re-fewell', true)
				first_check = true
			end
		end
		fps = fps + 1
		if fps > 60 then
			fps = 1
		end
	elseif near_Engineer == true and in_synergy == false and Synergy_Engineer_id then
		local distance = windower.ffxi.get_mob_by_id(Synergy_Engineer_id).distance
		distance = distance:sqrt()
		if distance > 6 and fps == 1 then
			hide_all()
			Synergy_Engineer_id = false
			near_Engineer = false
 			first_check = false
		end
		fps = fps + 1
		if fps > 30 then
			fps = 1
		end
	end
end)


windower.register_event('mouse', function(type, x, y, delta, blocked)
    if blocked then
        return
    end
	
	for k, v in pairs(saved_prims) do
		if is_hovering(k,x,y) and k ~= 'back' and saved_prims[k].visibility then
			set_prim_color(k, 150, 200, 200, 200)
		elseif k ~= 'back' then
			set_prim_color(k, 255, 255, 255, 255)
		end
	end
-- dragged
	if type == 0 then
		if drag_and_drop then
			selector_pos_x = (x - drag_and_drop.pos_x)
			selector_pos_y = (y - drag_and_drop.pos_y)
			set_bg_position('back',selector_pos_x,selector_pos_y)
			--windower.prim.set_position('back',selector_pos_x,selector_pos_y)
			update_all_positions()
		end
     -- Mouse left click
	elseif type == 1 then
		if in_synergy then
			--table.vprint(meta)
			for k, v in pairs(saved_prims) do
				if is_hovering(k,x,y) and saved_prims[k].visibility then
					if k ~= 'back' and block_commands == false and k ~= 're-fewell' then
						set_prim_color(k, 100, 250, 0, 0)
						if k == 'fire' then
							--log('clicked ' ..k)
							clicked = true
							activated_by_command = true
							fire()
						elseif k == 'ice' then
							clicked = true
							--log('clicked ' ..k)
							activated_by_command = true
							ice()
						elseif k == 'wind' then
							clicked = true
							--log('clicked ' ..k)
							activated_by_command = true
							wind()	
						elseif k == 'earth' then
							clicked = true
							--log('clicked ' ..k)
							activated_by_command = true
							earth()
						elseif k == 'thunder' then
							clicked = true
							--log('clicked ' ..k)
							activated_by_command = true
							thunder()
						elseif k == 'water' then
							clicked = true
							--log('clicked ' ..k)
							activated_by_command = true
							water()
						elseif k == 'light' then
							clicked = true
							--log('clicked ' ..k)
							activated_by_command = true
							light()
						elseif k == 'dark' then
							clicked = true
							--log('clicked ' ..k)
							activated_by_command = true
							dark()
						
						-- Furnace Functions
						
						elseif k == 'thwack' then
							--log('clicked ' ..k)
							activated_by_command = true
							thwack()
						elseif k == 'pressure' then
							--log('clicked ' ..k)
							clicked = true
							activated_by_command = true
							pressure()
						elseif k == 'safety_lever' then
							--log('clicked ' ..k)
							clicked = true
							activated_by_command = true
							safety_lever()
						elseif k == 'repair_furnace' then
							--log('clicked ' ..k)
							activated_by_command = true
							repair_furnace()
						elseif k == 'recycle' then
							--log('clicked ' ..k)
							activated_by_command = true
							recycle()
						elseif k == 'end' then
							--log('clicked ' ..k)
							if activated_by_party == true then
								windower.send_ipc_message('synergy_finish')
							else
								activated_by_command = true
								end_it()
							end
						end
						block_commands = true
						command_fps = 0
					end
					return true
				end
			end
		elseif near_Engineer == true then
			for k, v in pairs(saved_prims) do
				if is_hovering(k,x,y) and saved_prims[k].visibility then
					if k ~= 'back' then
						set_prim_color(k, 100, 250, 0, 0)
						if k == 're-fewell' then
							inject_0x10f()
							activated_by_command_re_refewell = true
							poke_engineer()
							return true
						end
						return true
					end
				end
			end
		elseif near_Engineer == false then
			for k, v in pairs(saved_prims) do
				if is_hovering(k,x,y) and saved_prims[k].visibility then
					if k ~= 'back' then
						set_prim_color(k, 100, 250, 0, 0)
						if k == 're-fewell' then
							inject_0x10f()
							return true
						end
						return true
					end
				end
			end
		end
		if is_shift_modified and is_hovering_bg(x,y) and saved_bg['back'].visibility then
			mouse_safety = true
			drag_and_drop = {pos_x= (x - saved_bg['back'].position.pos_x ),pos_y = (y - saved_bg['back'].position.pos_y)}
			return true
		end
	elseif type == 2 then
		if drag_and_drop then
			drag_and_drop = {pos_x= (x - saved_bg['back'].position.pos_x ),pos_y = (y - saved_bg['back'].position.pos_y)}
			settings.display.pos.x = (x - drag_and_drop.pos_x)
			settings.display.pos.y = (y - drag_and_drop.pos_y)
			save_settings()
			drag_and_drop = false
        end
		for k, v in pairs(saved_prims) do
			if is_hovering(k,x,y) then
				return true
			end
		end
		if mouse_safety then
            mouse_safety = false
            return true
        end
	elseif type == 5 then
        if mouse_safety then
            mouse_safety = false
            return true
        end
    end
end)

windower.register_event('keyboard', function(dik, down, flags, blocked)
    if dik == 42 and not bit.is_set(flags, 6) then
        is_shift_modified = down
    end
end)

function bit.is_set(val, pos) -- Credit: Arcon
    return bit.band(val, 2^(pos - 1)) > 0
end

windower.register_event('incoming text', function(old,new,color)
	-- if string.find(new,'Difficulty:') and trade == true then
		-- -- _,_,el1,val1,el2,val2,el3,val3,el4,val4,el5,val5,el6,val6,el7,val7,el8,val8 = string.find(new,'Difficulty:%s(%c+)(%d+)%s(%c+)(%d+)%s(%c+)(%d+)%s(%c+)(%d+)%s(%c+)(%d+)%s(%c+)(%d+)%s(%c+)(%d+)%s(%c+)(%d+)')
		-- -- el1 = string.hex(el1)
		-- -- log(el1.. ' '..val1)
		-- -- str = string.gsub(new, '\n', ' ')
		-- -- str = string.split(new,'Difficulty:')
		-- --'[ !"#$%%&]'
		-- --'[1f-26]'
		-- --log(str)
		-- -- local words = {}
		-- _,_,ele,val = string.find(new, "%s([ !\"#$%%&]+)(%d+)")
		-- log(ele..' | '..val)
		-- -- for ele,val in string.gfind(new, "%s(%c%c)(%d%d)") do
			-- -- log(ele..' | '..val)
			-- -- --table.insert(words, ele, val)
		-- -- end
		-- --table.vprint(words)
	-- end
	if string.find(new,'Difficulty:') and trade == true then
		str = string.gsub(new, '\n', ' ')
		str = string.split(new,'Difficulty:')

		chars = string.psplit(str[2],'[+-]?%d+')
		local actual_chars = {}
		
		for k, v in pairs(chars) do
			if k ~= 'n' then
				local s = string.gsub(v, '^?%s', '')
				if s ~= '' then
					s = string.hex(s)
					s = string.gsub(s, '^%d+', '')
					if string.startswith(s, 'EF') then
						table.insert(actual_chars, s)
					end
				end
			end
		end
		
		n = table.length(actual_chars)
		local start = 0
		local ends = 1
		for i = 1, n do
			start, ends = str[2]:find('[+-]?%d+',ends)
			actual_chars[i] = {actual_chars[i], str[2]:sub(start, ends)}
			ends = ends + 1
		end
		recepie_aquired = true
		local recepie_table = {}
		recepie_table.fire = 0
		recepie_table.ice = 0
		recepie_table.wind = 0
		recepie_table.earth = 0
		recepie_table.thunder = 0
		recepie_table.water = 0
		recepie_table.light = 0
		recepie_table.dark = 0
		
		for k, v in pairs(actual_chars) do
			if v[1] == 'EF1F' then
				set_text('needed_fire', v[2])
				recepie_table.fire = v[2]
			elseif v[1] == 'EF20' then
				set_text('needed_ice', v[2])
				recepie_table.ice = v[2]
			elseif v[1] == 'EF21' then
				set_text('needed_wind', v[2])
				recepie_table.wind = v[2]
			elseif v[1] == 'EF22' then
				set_text('needed_earth', v[2])
				recepie_table.earth = v[2]
			elseif v[1] == 'EF23' then
				set_text('needed_thunder', v[2])
				recepie_table.thunder = v[2]
			elseif v[1] == 'EF24' then
				set_text('needed_water', v[2])
				recepie_table.water = v[2]
			elseif v[1] == 'EF25' then
				set_text('needed_light', v[2])
				recepie_table.light = v[2]
			elseif v[1] == 'EF26' then
				set_text('needed_dark', v[2])
				recepie_table.dark = v[2]
			end				
		end
		
		local construct_message = recepie_table.fire .. ' ' .. recepie_table.ice .. ' ' .. recepie_table.wind .. ' ' .. recepie_table.earth .. ' ' .. recepie_table.thunder .. ' ' .. recepie_table.water .. ' ' .. recepie_table.light .. ' ' .. recepie_table.dark
		
		--log(construct_message)
		windower.send_ipc_message('synergy_recepie ' ..construct_message )
	end
	-- if string.find(new,'elemental power has begun leaking from the furnace.') then
	-- end
	
	if string.find(new,'Internal pressure:') then
		local _,_,pressure = string.find(new,'Internal pressure: (%d+) Pz/Im')
		local _,_,ratio = string.find(new,'Impurity ratio: (%d+)%%')
		set_text('pressure', pressure) 
		set_text('safety_lever', ratio)
		windower.send_ipc_message('synergy_data '.. pressure .. ' ' .. ratio)
	end
	
	if string.find(new,'elemental power is no longer leaking') then
		leak = ''
		fix = ''
	end
	if string.find(new,'The synergy furnace is currently in use by') then
		--log('party member using furnace')
		_,_,name = string.find(new,'The synergy furnace is currently in use by (%a+).')
		for k, v in pairs(windower.ffxi.get_party()) do
			if string.find(k, 'p%d+') then
				if v.name:lower() == name:lower() then
					id = v.mob.id
					for mob_id,table_value in pairs(windower.ffxi.get_mob_array()) do
						if table_value.distance:sqrt() < 6 and table_value.name == 'Synergy Furnace' then
							activated_by_party = true
						end
					end
				end
			end
		end
	end
	if string.find(new,'You now have claim over the synergy furnace.') then
		set_prim_visibility('re-fewell', false)
	end
	if string.find(new,'Your claim over the synergy furnace has expired.') then
		if activated_by_party == true then
			hide_end_synergy()
			target = {}
			for k, v in pairs(positions) do
				set_text('current_'..v.element, 00)
				set_text('needed_'..v.element, 00)
			end
			set_text('pressure', 00) 
			set_text('safety_lever', 00)
			in_synergy = false
			first_check = false
			near_Engineer = false 
			Synergy_Engineer_id = false
			activated_by_party = false
		end
	end
	if string.find(new,'Your claim to the synergy furnace has been relinquished.') then
		if activated_by_party == true then
			hide_end_synergy()
			target = {}
			for k, v in pairs(positions) do
				set_text('current_'..v.element, 00)
				set_text('needed_'..v.element, 00)
			end
			set_text('pressure', 00) 
			set_text('safety_lever', 00)
			in_synergy = false
			first_check = false
			near_Engineer = false 
			Synergy_Engineer_id = false
			activated_by_party = false
		end
	end
	-- if string.find(new,'You give the synergy furnace a measured thwack!') then
		-- overload = false
	-- end
	-- if string.find(new,'elemental power has overloaded') then
		-- overload = false
	-- end
end)

windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
	
	if id == 0x034 then
		if in_synergy == true and activated_by_command == true then
			--log('packet 0x034')
			create_0x05B(target['Target id'], target["Target Index"], 147, 						target["Zone id"], true, target["Menu ID"], 0, 0)
			create_0x05B(target['Target id'], target["Target Index"], 143, 						target["Zone id"], true, target["Menu ID"], 0, 0)
			create_0x05B(target['Target id'], target["Target Index"], 143, 						target["Zone id"], true, target["Menu ID"], 0, 0)
			create_0x05B(target['Target id'], target["Target Index"], target['Option Index'], 	target["Zone id"], true, target["Menu ID"], 0, 0)
			create_0x05B(target['Target id'], target["Target Index"], 143, 						target["Zone id"], true, target["Menu ID"], 0, 0)
			create_0x05B(target['Target id'], target["Target Index"], 0, 						target["Zone id"], false, target["Menu ID"], 0, 0)			
			activated_by_command = false
			return true
		end
		if in_synergy == false and activated_by_command_re_refewell == true then
			local id = Synergy_Engineer_id
			local index = windower.ffxi.get_mob_by_id(Synergy_Engineer_id).index
			local zone = windower.ffxi.get_info().zone
			create_0x05B(id, index, 3, zone, true, 11001, 0, 0)
			create_0x05B(id, index, 8, zone, false, 11001, 0, 0)
			activated_by_command_re_refewell = false
			inject_0x10f()
			return true
		end
	end
	-- if id == 0x02a and in_synergy == true then 
		-- local packet = packets.parse('incoming', data)
		-- if packet['Message ID'] == 32842 then
			-- set_text('pressure', packet['Param 2']) 
			-- set_text('safety_lever', packet['Param 1'])
			-- windower.send_ipc_message('synergy_data '.. packet['Param 2'] .. ' ' .. packet['Param 1'])
		-- end
	-- end
	if id == 0x05c and in_synergy == true then
		if data:byte(33) == 0 and data:byte(18) ~= 0 and data:byte(19) ~= 0 and data:byte(20) ~= 0 then
			
			set_text('current_fire', 		(data:byte(5) -100	))
			set_text('current_ice', 		(data:byte(7) -100	))
			set_text('current_wind', 		(data:byte(9) -100	))
			set_text('current_earth', 		(data:byte(11) -100	))
			set_text('current_thunder', 	(data:byte(13) -100	))
			set_text('current_water', 		(data:byte(15) -100	))
			set_text('current_light', 		(data:byte(17) -100	))
			set_text('current_dark', 		(data:byte(19) -100	))
			windower.send_ipc_message('synergy_current ' .. tostring(data:byte(5) -100	) .. ' ' .. tostring(data:byte(7) -100	) .. ' ' .. tostring(data:byte(9) -100	) .. ' ' .. tostring(data:byte(11) -100) .. ' ' .. tostring(data:byte(13) -100	) .. ' ' .. tostring(data:byte(15) -100) .. ' ' .. tostring(data:byte(17) -100	) .. ' ' .. tostring(data:byte(19) -100	)	)
		-- elseif data:byte(33) == 0 and data:byte(18) ~= 0 and data:byte(19) ~= 0 and data:byte(20) ~= 0 and recepie_aquired == false then	
			
			-- set_text('needed_fire', 		(data:byte(6) -100	))
			-- set_text('needed_ice', 			(data:byte(8) -100	))
			-- set_text('needed_wind', 		(data:byte(10) -100	))
			-- set_text('needed_earth', 		(data:byte(12) -100	))
			-- set_text('needed_thunder', 		(data:byte(14) -100	))
			-- set_text('needed_water', 		(data:byte(16) -100	))
			-- set_text('needed_light', 		(data:byte(18) -100	))
			-- set_text('needed_dark', 		(data:byte(20) -100	))
			
		elseif data:byte(6) == 0 and data:byte(7) == 0 and data:byte(8) == 0 and data:byte(33) < 100 then
			-- fewell levels
			set_text('fewell_fire', 	(data:byte(5)%128))
			set_text('fewell_ice', 		(data:byte(9)%128))
			set_text('fewell_wind', 	(data:byte(13)%128))
			set_text('fewell_earth', 	(data:byte(17)%128))
			set_text('fewell_thunder', 	(data:byte(21)%128))
			set_text('fewell_water', 	(data:byte(25)%128))
			set_text('fewell_light', 	(data:byte(29)%128))
			set_text('fewell_dark', 	(data:byte(33)%128))
			windower.send_ipc_message('synergy_fewell ' .. tostring(data:byte(5)%128) .. ' ' .. tostring(data:byte(9)%128) .. ' ' .. tostring(data:byte(13)%128) .. ' ' .. tostring(data:byte(17)%128) .. ' ' .. tostring(data:byte(21)%128) .. ' ' .. tostring(data:byte(25)%128) .. ' ' .. tostring(data:byte(29)%128) .. ' ' .. tostring(data:byte(33)%128)	)
		end
	end
	if id == 0x038 then
		local packet = packets.parse('incoming', data)
		value = packet['Type']
		
		-- this is a toggle, same packet received for start leak and finish leak
		if value == 'ef81' then
			leak = 'fire' 
			fix = 'ice' 
		elseif value == 'ef82' then
			leak = 'ice' 
			fix = 'wind' 
		elseif value == 'ef83' then
			leak = 'wind' 
			fix = 'earth'
		elseif value == 'ef84' then 
				leak = 'earth' 
				fix = 'thunde' 
		elseif value == 'ef85' then 
				leak = 'thunde' 
				fix = 'water'
		elseif value == 'ef86' then
				leak = 'water' 
				fix = 'fire'
		elseif value == 'ef87' then 
				leak = 'light' 
				fix = 'dark' 
		elseif value == 'ef88' then 
				leak = 'dark' 
				fix = 'light'		
		-- feed animation ef91 -> ef98
		end
	end
	if id == 0x028 then
		local packet = packets.parse('incoming', data)
		if packet['Category'] == 7 and packet['Actor'] == target['Target id'] then
			-- Param = packet['Target 1 Action 1 Param']
			-- log(Param)
			-- fire  = 2490
			-- ice = 2491
			-- wind = 2492
			if overload == false then
				overload = true
			else
				overload = false
			end
		elseif packet['Category'] == 3 and packet['Actor'] == target['Target id'] then
			overload = false
		elseif packet['Category'] == 11 and packet['Actor'] == target['Target id'] then
			overload = false
		end
		--table.vprint(packet)
	end
	if id == 0x04f and in_synergy == true then
		hide_end_synergy()
		target = {}
		for k, v in pairs(positions) do
			set_text('current_'..v.element, 00)
			set_text('needed_'..v.element, 00)
		end
		set_text('pressure', 00) 
		set_text('safety_lever', 00)
		in_synergy = false
		first_check = false
		near_Engineer = false 
		Synergy_Engineer_id = false
		activated_by_party = false
		windower.send_ipc_message('synergy_end')
	end
	if id == 0x113 then
		local packet = packets.parse('incoming', data)
		set_text('fewell_fire', 	packet['Syngery Fewell (Fire)'])      
		set_text('fewell_ice', 		packet['Syngery Fewell (Ice)'])       
		set_text('fewell_wind', 	packet['Syngery Fewell (Wind)'])      
		set_text('fewell_earth', 	packet['Syngery Fewell (Earth)'])     
		set_text('fewell_thunder', 	packet['Syngery Fewell (Lightning)']) 
		set_text('fewell_water', 	packet['Syngery Fewell (Water)'])     
		set_text('fewell_light', 	packet['Syngery Fewell (Light)'])     
		set_text('fewell_dark', 	packet['Syngery Fewell (Dark)'])      
	end

end)

windower.register_event('outgoing chunk',function(id,data,modified,injected,blocked)
	
	if id == 0x036 then
		trade = true
		--log('packet 0x036 sent')
		local packet = packets.parse('outgoing', data)
		if windower.ffxi.get_mob_name(packet['Target']) == "Synergy Furnace" then
			if activate_synergy_part_one == false then
				activate_synergy_part_one = true
			end	
		end
	elseif id == 0x05b and activate_synergy_part_one == true then
		--log('packet 0x05b sent')
		local packet = packets.parse('outgoing', data)
		if packet['Option Index'] == 150 then
			if activate_synergy_part_two == false then
				activate_synergy_part_two = true
				target['Target id'] = packet['Target']
				target["Target Index"] = packet['Target Index']
				target["Zone id"] = packet['Zone']
				target["Menu ID"] = (packet['Menu ID'] - 3)
				windower.send_ipc_message('synergy_info ' .. target['Target id'] .. ' ' ..target["Target Index"].. ' ' .. target["Zone id"] .. ' ' ..target["Menu ID"] )
				--log('synergy activated. target id: '.. target['Target id'] .. ' index: ' .. target["Target Index"] .. ' zone: ' .. target["Zone id"] .. ' menu id: ' .. target["Menu ID"] )
				activate_synergy_part_one = false
				activate_synergy_part_two = false
				in_synergy = true
				trade = false
				if saved_prims['re-fewell'].visibility == true then
					set_prim_visibility('re-fewell', false)
				end
				make_synergy_visible()
				inject_0x10f()
			end	
		end
	end
end)

windower.register_event('ipc message',function (msg)
		if msg:find('synergy_info') then
			local broken = msg:split(' ')
			target['Target id'] = tonumber(broken[2])
			target["Target Index"] = tonumber(broken[3])
			target["Zone id"] = tonumber(broken[4])
			target["Menu ID"] = tonumber(broken[5])
			in_synergy = true
			if saved_prims['re-fewell'].visibility == true then
				set_prim_visibility('re-fewell', false)
			end
			make_synergy_visible()
		end
		if msg:find('synergy_recepie') then
			local broken = msg:split(' ')
			set_text('needed_fire', 		tonumber(broken[2]))
			set_text('needed_ice', 			tonumber(broken[3]))
			set_text('needed_wind', 		tonumber(broken[4]))
			set_text('needed_earth', 		tonumber(broken[5]))
			set_text('needed_thunder', 		tonumber(broken[6]))
			set_text('needed_water', 		tonumber(broken[7]))
			set_text('needed_light', 		tonumber(broken[8]))
			set_text('needed_dark', 		tonumber(broken[9]))
		end
		if msg:find('synergy_current') then
			local broken = msg:split(' ')
			set_text('current_fire', 		tonumber(broken[2]))
			set_text('current_ice', 		tonumber(broken[3]))
			set_text('current_wind', 		tonumber(broken[4]))
			set_text('current_earth', 		tonumber(broken[5]))
			set_text('current_thunder', 	tonumber(broken[6]))
			set_text('current_water', 		tonumber(broken[7]))
			set_text('current_light', 		tonumber(broken[8]))
			set_text('current_dark', 		tonumber(broken[9]))
		end
		if msg:find('synergy_fewell') then
			local broken = msg:split(' ')
			set_text('fewell_fire', 		tonumber(broken[2]))
			set_text('fewell_ice', 			tonumber(broken[3]))
			set_text('fewell_wind', 		tonumber(broken[4]))
			set_text('fewell_earth', 		tonumber(broken[5]))
			set_text('fewell_thunder', 		tonumber(broken[6]))
			set_text('fewell_water', 		tonumber(broken[7]))
			set_text('fewell_light', 		tonumber(broken[8]))
			set_text('fewell_dark', 		tonumber(broken[9]))
		end
		if msg:find('synergy_end') then
			hide_end_synergy()
			target = {}
			for k, v in pairs(positions) do
				set_text('current_'..v.element, 00)
				set_text('needed_'..v.element, 00)
			end
			set_text('pressure', 00) 
			set_text('safety_lever', 00)
			in_synergy = false
			first_check = false
			near_Engineer = false 
			Synergy_Engineer_id = false
			activated_by_party = false
		end
		if msg:find('synergy_data') then
			local broken = msg:split(' ')
			set_text('pressure', tonumber(broken[2])) 
			set_text('safety_lever', tonumber(broken[3]))
		end
		if msg:find('synergy_finish') then
			activated_by_command = true
			end_it()
		end
end)















