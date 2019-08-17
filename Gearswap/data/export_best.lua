--Copyright (c) 2013~2016, tinyn
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-- largely ripped from gearswap\export.lua and checkparam.lua

--[[

install to your "windower\addons\GearSwap\data" directory
lua reload gearswap
gs load export_best
gs c export_best all

]]--

require 'logger'
--require 'strings'
res = require 'resources'
extdata = require 'extdata'

local DEBUG=false

local stat_list = L{
'dmg', 'str', 'dex', 'vit', 'agi', 'int', 'mnd', 'chr', 'def', 'hp', 'mp',

'accuracy', 
'attack', 
'critical hit damage',
'critical hit rate',
'dual wield',
'enmity',
'enmity__negative',
'evasion', 
'haste',

'double attack',
'triple attack',
'quadruple attack',
'martial arts',

'skillchain bonus', 
'store tp', 
'subtle blow',
'weapon skill damage',

'damage taken',
'physical damage taken',
'magic damage taken',
'phalanx',
'inquartata',

'ranged accuracy',
'rapid shot',
'snapshot',

'magic accuracy',
'magic accuracy skill',
'magic attack bonus', 
'magic burst damage',
'magic burst damage ii',
'magic critical hit rate',
'magic damage',
'magic defense bonus',
'magic evasion',
'fast cast',
'spell interruption rate down',

'conserve mp',
'cure potency',
'cure potency ii',
'potency of cure effects received',
'cure spellcasting time',
'healing magic casting time',
'elemental magic casting time',
'enhancing magic effect duration',
'enfeebling magic effect',
'spikes spell damage',
'divine benison',

'song effect duration',
'song spellcasting time',

'blood pact delay',
'blood pact delay ii',
'blood pact damage',
'avatar perpetuation cost',


'hp recovered while healing',
'mp recovered while healing',
'refresh',
'regen',
'regain',

'gilfinder',
'mug',
'steal',
'treasure hunter',

'hand-to-hand skill',
'dagger skill',
'sword skill',
'great sword skill',
'katana skill',
'great katana skill',
'axe skill',
'great axe skill',
'scythe skill',
'polearm skill',
'club skill',
'staff skill',
'archery skill',
'marksmanship skill',
'throwing skill',
'guarding skill',
'evasion skill',
'shield skill',
'parrying skill',


'dark magic skill',
'divine magic skill',
'healing magic skill',
'enhancing magic skill',
'enfeebling magic skill',
'elemental magic skill',
'summoning skill',
'blue magic skill',
'singing skill',
'string instrument skill',
'wind instrument skill',
'ninjutsu',
'geomancy skill',
'handbell skill',

'experience point bonus',
'capacity point bonus',

}

function self_command(command)
	--print('export_best: self_command: '..command)
    local commandArgs = command
    if #commandArgs:split(' ') >= 2 then
        commandArgs = T(commandArgs:split(' '))
    end
	if commandArgs[1] ~= 'export_best' then
		return
	end
	--print('export_best: self_command: '..command)
    export_best(commandArgs)
end

function export_best(options)
    local item_list = T{}
    local targinv,all_items,xml,all_sets,use_job_in_filename,use_subjob_in_filename,overwrite_existing,named_file
    if #options > 0 then
        for _,v in ipairs(options) do
            if S{'inventory','inv','i'}:contains(v:lower()) then
                targinv = true
            elseif v:lower() == 'all' then
                all_items = true
            elseif v:lower() == 'mainjob' then
                use_job_in_filename = true
            elseif v:lower() == 'mainsubjob' then
                use_subjob_in_filename = true
            elseif v:lower() == 'overwrite' then
                overwrite_existing = true
            elseif S{'filename','file','f'}:contains(v:lower()) then
                named_file = true
            else
                if named_file then
                    filename = v
                end
            end
        end
    end
	
	local items = windower.ffxi.get_items()
	
    
    local buildmsg = 'Exporting '
    if all_items then
        buildmsg = buildmsg..'all your items'
    elseif targinv then
        buildmsg = buildmsg..'your current inventory'
    end

    buildmsg = buildmsg..' as a lua file.'
    
    if use_job_in_filename then
        buildmsg = buildmsg..' (Naming format: Character_JOB)'
    elseif use_subjob_in_filename then
        buildmsg = buildmsg..' (Naming format: Character_JOB_SUB)'
    elseif named_file then
        buildmsg = buildmsg..' (Named: Character_'..filename..')'
    end
    
    if overwrite_existing then
        buildmsg = buildmsg..' Will overwrite existing files with same name.'
    end
    
    add_to_chat(123,'gearswap:export_best: '..buildmsg)
    
	------------------
    if not windower.dir_exists(windower.addon_path..'data/export') then
        windower.create_dir(windower.addon_path..'data/export')
    end

    if not windower.dir_exists(windower.addon_path..'data/export') then
        windower.create_dir(windower.addon_path..'data/export')
    end

    local path = windower.addon_path..'data/export/'..player.name
    
    if use_job_in_filename then
        path = path..'_'..windower.ffxi.get_player().main_job
    elseif use_subjob_in_filename then
        path = path..'_'..windower.ffxi.get_player().main_job..'_'..windower.ffxi.get_player().sub_job
    elseif named_file then
        path = path..'_'..filename
    else
        path = path..os.date(' %Y-%m-%d %H-%M-%S')
    end
	------------------
    if all_items then
        for i = 0, #res.bags do
            item_list:extend(get_item_list(items[res.bags[i].english:gsub(' ', ''):lower()]))
        end
    elseif targinv then
        --item_list:extend(get_item_list(items.inventory))
    elseif all_sets then
        -- Iterate through user_env.sets and find all the gear.
        item_list,exported = unpack_names({},'L1',user_env.sets,{},{empty=true})
    else
        -- Default to loading the currently worn gear.
    end
    
    if #item_list == 0 then
        --msg.addon_msg(123,'There is nothing to export.')
        return
    else
        local not_empty
        for i,v in pairs(item_list) do
            if v.name ~= empty then
                not_empty = true
                break
            end
        end
        if not not_empty then
            --msg.addon_msg(123,'There is nothing to export.')
            return
        end
	end

	------------------------------------------	

	local slots_list = T{}
	for i,v in pairs(res.slots) do
		local slot = res.slots[i].english:gsub(' ','_'):lower()
		slots_list[v.id] = slot
	end
	slots_list[11] = 'ear1'
	slots_list[12] = 'ear2'
	slots_list[13] = 'ring1'
	slots_list[14] = 'ring2'
	

    local best_for_stats = T{}
	
	local curr_job_name = windower.ffxi.get_player().main_job
	local curr_job = 0
	
	for i,j in pairs(res.jobs) do
		if curr_job_name == j.ens then
			curr_job = j
			break
		end		
	end
	--print(curr_job)


	local seen_stats = T{}

	local can_dw = false

					
	local stat_list_set_name = L{}
	for i,v in ipairs(stat_list) do
		local c = v:gsub(' ','_'):gsub('%.',''):lower()
		stat_list_set_name:append(c)
	end

	for it,v in pairs(item_list) do
		if v.name ~= empty and v.slot ~= 'item' and v.desc then
		
			local t = windower.regex.split(v.desc, '(Reives|Assault|Set|latent effect|weather|in dynamis): ') -- not supported yet				
			local stat_chunks = windower.regex.split(t[1],'(Pet|Avatar|Automaton|Wyvern|Luopan): ')
			local stat_map = T{}

			local stat_prefix = L{nil, 'pet_'}
			for i,v in ipairs(stat_chunks) do
				local tbl = split_text(stat_chunks[i], stat_prefix[i])
				stat_map = stat_map:update(tbl)
				--print(stat_chunks[i])
				--print(tbl)
			end
			seen_stats = seen_stats:update(stat_map)
			if not stat_map:empty() then
				v.base_stats = stat_map
			else
				v.base_stats = nil
			end
					
			if v.augments then 
				stat_map = split_text(v.augments)
				--print(v.augments)
				--print(stat_map)
				if not stat_map:empty() then
					v.aug_stats = stat_map
				else
					v.aug_stats = nil
				end				
				seen_stats = seen_stats:update(stat_map)
			end
		
		end
	end

	for i,v in pairs(stat_list) do
		local orig_stat_name = tostring(v)
		local curr_stat_name = tostring(v)
		local best_for_slot = T{}
		
		local negative_stat = false
		
		--print(curr_stat_name)

		if string.contains(curr_stat_name, '__negative') then
			negative_stat = true
			curr_stat_name = curr_stat_name:gsub('__negative','')
		else
			negative_stat = false
		end

		
		for _,v in pairs(item_list) do
			v.in_use = false
		end
		
		--for _,s in pairs(res.slots) do
		for si=0,res.slots:length()-1,1 do
			local slot_id = res.slots[si].id
			--print(res.slots[si].en)
						
			for it,v in pairs(item_list) do
				
				local can_use = true
				
				if slot_id == 1 and v.category == "Weapon" then
					can_use = can_dw
				end
				
				if can_use and v.name ~= empty and v.slot ~= 'item' and v.desc and v.jobs[curr_job.id] and v.slots[slot_id] and not v.in_use and v.name ~= 'Chocobo Shirt' then
					if DEBUG then
						print(v.name..' : '..v.slot)
					end
						
					local curr_value = 0
					
					if v.base_stats ~= nil and v.base_stats[curr_stat_name] then
						curr_value = curr_value + tonumber(v.base_stats[curr_stat_name])
						--print(curr_value)
					end	
							
					if v.augments then 
						--print(v.augments)
						if v.aug_stats ~= nil and v.aug_stats[curr_stat_name] then
							curr_value = curr_value + tonumber(v.aug_stats[curr_stat_name])
							--print(curr_value)
						end		
					end
						
					if (curr_value > 0 and negative_stat == false) or (curr_value < 0 and negative_stat == true) then
						
						if best_for_slot:containskey(slot_id) and best_for_slot[slot_id] and best_for_slot[slot_id] ~= nil and best_for_slot[slot_id].max_value ~= nil then
							--print(best_for_slot[slot_id].max_value)
							if ((best_for_slot[slot_id].max_value < curr_value and negative_stat == false) or 
							    (best_for_slot[slot_id].max_value > curr_value and negative_stat == true)) then
								best_for_slot[slot_id].item.in_use = false
								v.in_use = true
								local new_max = T{}
								new_max.max_value = curr_value
								new_max.item = v
								best_for_slot[slot_id] = new_max
							end						
						else
							v.in_use = true
							local new_max = T{}
							new_max.max_value = curr_value
							new_max.item = v
							best_for_slot[slot_id] = new_max 
						end
					end -- end curr_value if
				end -- end valid item if	
			end -- end item_list loop
		end -- end slots loop	
		
		if best_for_slot:length() > 0 then
			best_for_stats[orig_stat_name] = best_for_slot
		end
	end 
	-----------------
	
	if DEBUG then
		seen_stats = seen_stats:keyset():sort()
		for i,v in pairs(seen_stats) do
			if not stat_list:contains(v) then
				print(v)
			end
		end
	end
    

	-- Default to exporting in .lua
	if (not overwrite_existing) and windower.file_exists(path..'.lua') then
		path = path..' '..os.clock()
	end

	local f = io.open(path..'.lua','w+')

	for i,v in pairs(stat_list) do
		local curr_stat_name = v
		local best_for_slots = best_for_stats[curr_stat_name]
		if best_for_slots then
			f:write('sets.'..stat_list_set_name[i]..'.exported={\n')
			--for i,s in pairs(res.slots) do
			for i=0,res.slots:length()-1,1 do
				local slot_id = res.slots[i].id
				local curr_slot = slots_list[i]
				local v = best_for_slots[slot_id] 
				if best_for_slots:containskey(slot_id) then
					local v = best_for_slots[slot_id].item
					if v.name ~= empty and v.slot ~= 'item' then
						if DEBUG and v.desc then 
							if v.augments then
								f:write('    '..curr_slot..'={ name="'..v.name..'", augments={'..v.augments..'}, desc="'..v.desc..'"},\n')
							else
								f:write('    '..curr_slot..'={ name="'..v.name..'", desc=\''..v.desc..'\'},\n')
							end
						else
							if v.augments then
								f:write('    '..curr_slot..'={ name="'..v.name..'", augments={'..v.augments..'}},\n')
							else
								f:write('    '..curr_slot..'="'..v.name..'",\n')
							end
						end
					end
				end
			end
			f:write('}\n\n')
		end
	end
    f:close()
	add_to_chat(123,'gearswap:export_best: '..'finished exporting to '..path..'.lua')
end

function copy_entry(tab)
    if not tab then return nil end
    local ret = setmetatable(table.reassign({},tab),getmetatable(tab))
    return ret
end

function add_to_chat(col,str)
    if str == '' then return end
    if col == 1 then
        windower.add_to_chat(1,str)
    else
        windower.add_to_chat(1,string.char(0x1F,col%256)..str..string.char(0x1E,0x01))
    end
end


---- Stolen from windower addon checkparam 
integrate = {
    --[[integrate same property.information needed for development. @from20020516]]
    ['quad atk'] = 'quadruple attack',
    ['quad attack'] = 'quadruple attack',
    ['triple atk'] = 'triple attack',
    ['double atk'] = 'double attack',
    ['dblatk'] = 'double attack',
    ['blood pact ability delay'] = 'blood pact delay',
    ['blood pact ability delay ii'] = 'blood pact delay ii',
    ['blood pact ab. del. ii'] = 'blood pact delay ii',
    ['blood pact recast time ii'] = 'blood pact delay ii',
    ['blood pact dmg'] = 'blood pact damage',
    ['enhancing magic duration'] = 'enhancing magic effect duration',
	['enh mag eff dur'] = 'enhancing magic effect duration',
    ['eva'] = 'evasion',
    ['indicolure spell duration'] = 'indicolure effect duration',
	['indi eff dur'] = 'indicolure effect duration',
    ['mag eva'] = 'magic evasion',
    ['magic atk bonus'] = 'magic attack bonus',
    ['magatkbns'] = 'magic attack bonus',
    ['mag atk bonus'] = 'magic attack bonus',
	['magic def bonus'] = 'magic defense bonus',
	['mag def bonus'] = 'magic defense bonus',
    ['mag acc'] = 'magic accuracy',
    ['m acc'] = 'magic accuracy',
    ['r acc'] = 'ranged accuracy',
	['rng acc'] = 'ranged accuracy',
    ['magic burst dmg'] = 'magic burst damage',
    ['mag dmg'] = 'magic damage',
    ['crithit rate'] = 'critical hit rate',
    ['phys dmg taken'] = 'physical damage taken',
}

function split_text(text,arg)
    local tbl = T{}
	for key,value in string.gmatch(text,'/?([%D]-):?([%+%-]?[0-9]+)%%?%s?') do
		--print(key)
		--print(value)
        local key = windower.regex.replace(string.lower(string.trim(key)), '(\\"|\\\'|\\\,|\\\:|\\.|\\s$)','')
        local key = integrate[key] or key
        local key = arg and arg..key or key
        tbl[key] = tonumber(value)+(tbl[key] or 0)
        --if settings.debugmode then
        --    log(id,res.items[id].english,key,value,tbl[key])
        --end
    end
	return tbl
end


function unpack_names(ret_tab,up,tab_level,unpacked_table,exported)
    for i,v in pairs(tab_level) do
        local flag,alt
        if type(v)=='table' and i ~= 'augments' and not ret_tab[tostring(tab_level[i])] then
            ret_tab[tostring(tab_level[i])] = true
            unpacked_table,exported = unpack_names(ret_tab,i,v,unpacked_table,exported)
        elseif i=='name' and type(v) == 'string' then
            alt = up
            flag = true
        elseif type(v) == 'string' and v~='augment' and v~= 'augments' and v~= 'priority' then
            alt = i
            flag = true
        end
        if flag then
            if not exported[v:lower()] then
                unpacked_table[#unpacked_table+1] = {}
                local tempname,tempslot = unlogify_unpacked_name(v)
                unpacked_table[#unpacked_table].name = tempname
                unpacked_table[#unpacked_table].slot = tempslot or alt
                if tab_level.augments then
                    local aug_str = ''
                    for aug_ind,augment in pairs(tab_level.augments) do
                        if augment ~= 'none' then aug_str = aug_str.."'"..augment:gsub("'","\\'").."'," end
                    end
                    if aug_str ~= '' then unpacked_table[#unpacked_table].augments = aug_str end
                end
                if tab_level.augment then
                    local aug_str = unpacked_table[#unpacked_table].augments or ''
                    if tab_level.augment ~= 'none' then aug_str = aug_str.."'"..augment:gsub("'","\\'").."'," end
                    if aug_str ~= '' then unpacked_table[#unpacked_table].augments = aug_str end
                end
                exported[tempname:lower()] = true
                exported[v:lower()] = true
            end
        end
    end
    return unpacked_table,exported
end

function unlogify_unpacked_name(name)
    local slot
    name = name:lower()
    for i,v in pairs(res.items) do
        if type(v) == 'table' then
            if v[language..'_log']:lower() == name then
                name = v[language]
                local potslots = v.slots
                if potslots then potslots = to_windower_api(res.slots[potslots:it()()].english) end
                slot = potslots or 'item'
                break
            elseif v[language]:lower() == name then
                name = v[language]
                local potslots = v.slots
                if potslots then potslots = to_windower_api(res.slots[potslots:it()()].english) end
                slot = potslots or 'item'
                break
            end
        end
    end
    return name,slot
end


function get_item_list(bag)
    local items_in_bag = {}
    -- Load the entire inventory
    for _,v in pairs(bag) do
        if type(v) == 'table' and v.id ~= 0 then
            if res.items[v.id] then
                items_in_bag[#items_in_bag+1] = {}
                items_in_bag[#items_in_bag].name = res.items[v.id][language]
                local potslots,slot = copy_entry(res.items[v.id].slots)
                if potslots then
                    slot = res.slots[potslots:it()()].english:gsub(' ','_'):lower() -- Multi-lingual support requires that we add more languages to slots.lua
                end
				items_in_bag[#items_in_bag].slot = slot or 'item'
				if not xml then
					local augments = extdata.decode(v).augments or {}
					local aug_str = ''
					for aug_ind,augment in pairs(augments) do
						if augment ~= 'none' then aug_str = aug_str.."'"..augment:gsub("'","\\'").."'," end
					end
					if string.len(aug_str) > 0 then
						items_in_bag[#items_in_bag].augments = aug_str
					end
					local desc = res.item_descriptions[v.id]
					if desc and desc.english then
						local filt = string.gsub(desc.english, '\n', ' ')
						filt = string.gsub(filt, "[\192-\255][\128-\191]*", "??")
						items_in_bag[#items_in_bag].desc = filt
					end
					if res.items[v.id].jobs then
						items_in_bag[#items_in_bag].jobs = res.items[v.id].jobs
					end
					if res.items[v.id].slots then
						items_in_bag[#items_in_bag].slots = res.items[v.id].slots
					end
					if res.items[v.id].category then
						items_in_bag[#items_in_bag].category = res.items[v.id].category
					end
				end
			else
                --msg.addon_msg(123,'You possess an item that is not in the resources yet.')
            end
        end
    end
    return items_in_bag
end
