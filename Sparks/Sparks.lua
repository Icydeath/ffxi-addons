--[[
Copyright © 2018, Langly of Quetzalcoatl
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of React nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Langly BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

--[[
    Thank you to Brax and Sammeh for your work on the earlier version.
	2.14.2021 - updated spark NPC's index
--]]

_addon.name = 'Sparks'
_addon.author = 'Langly'
_addon.version = '1.1'
_addon.date = '10.1.2018'
_addon.commands = {'sparks'}

require('tables')
require('logger')
packets = require('packets')
db = require('map')
--res_items = require('resources').items

valid_spark_zones = T{
	[311] = {npc="Eternal Flame", menu=5081}, -- Western Adoulin
	[230] = {npc="Rolandienne", menu=995}, -- Southern San d'Oria -- 342
	[177] = {npc="Isakoth", menu=26}, -- Bastok Markets
	[251] = {npc="Fhelm Jobeizat", menu=850}, -- Windurst Woods
}
valid_eschan_zones = T{
	[288] = {npc="Affi", menu=9701},  -- Escha Zitah
	[289] = {npc="Dremi", menu=9701},  -- Escha RuAun
	[291] = {npc="Shiftrix", menu=9701},  -- Reisenjima
}
item = ''
current_sparks = 0
purchase_queue = T{}
col = {}
current_temp_items = T{}
missing_temp_items = T{}
all_temp_items = T{}
current_ki = T{}
missing_ki = T{}

windower.register_event('load', function()
    find_all_temp_items()
	get_spark_update()
end)

function help()
	notice('Sparks command examples:')
	notice(' == SPARKS NPC ==')
	notice(' //sparks buy {item}  -  buys the item you specify.')
	notice(' //sparks buyall {item}  -  buys the item you specify until you run out of sparks or inv.')
	notice(' == ESCHA NPC ==')
	notice(' //sparks buyki {item}  -  buys the escha KI you specify.')
	notice(' //sparks buyallki  -  buys all available escha KI\'s.')
	notice(' //sparks listki  -  lists missing escha KI\'s.')
	notice(' //sparks buyalltemps  -  buys all available escha temp items (except brew).')
	notice(' //sparks listtemps  -  lists missing escha temp items.')
	notice(' == OTHER ==')
	notice(' //sparks fail  -  attempts to fix soft-locks.')
	notice(' //sparks help|?  -  shows this list of commands.')
end

windower.register_event('addon command', function (command, ...)
	command = command and command:lower()
	local args = T{...}
	item = table.concat(args,' '):lower()
	
	if command == 'help' or command == '?' then
		help()
		return
	end
	
	if command == 'buy' then
        notice('Buying 1 '..item..'.')
        purchase_queue[1] = build_item(item)
        return
	end

	if command == 'buyall' then
		col = build_item(item)
		local purchasable = math.floor(current_sparks/col.Cost)
		
        if purchasable == 0 then
            notice('You do not have enough sparks.')
            return
        end
        
		if col then 
			local free_space = count_inv()
			local tobuy = 0
			
			if purchasable > free_space then
				notice("You have "..free_space.." free slots, buying "..item.. " until full.")
				tobuy = free_space
			else
				notice('Spending '..current_sparks..' sparks to purchase: '..purchasable..' '..item..'s.')
				tobuy = purchasable
			end
			
			for i=1,tobuy do
				table.append(purchase_queue, col)
			end
		end
		return
	end

    if command == 'buyki' then
        local currentzone = windower.ffxi.get_info()['zone']
		if currentzone == 291 or currentzone == 289 or currentzone == 288 then
            col = build_item(item)
            if col then
                table.append(purchase_queue, col)
            end
        end
    end
    
    if command == 'buyallki' then
        local currentzone = windower.ffxi.get_info()['zone']
        local missing = 0
		if currentzone == 291 or currentzone == 289 or currentzone == 288 then
            find_missing_ki()
            for countmissing,countitems in pairs(missing_ki) do
                missing = missing + 1
            end
            warning('Missing '..missing..' KIs.')
            if missing ~= 0 then
                for key,val in pairs(missing_ki) do
                    local col = build_item(val)
                    if col then
                        table.append(purchase_queue, col)
                    end
                end
            end
        end
    end
    
    if command == 'buyalltemps' then
		local currentzone = windower.ffxi.get_info()['zone']
		if currentzone == 291 or currentzone == 289 or currentzone == 288 then 
			find_current_temp_items()
			find_missing_temp_items()
			local missing = 0
			for countmissing,countitems in pairs(missing_temp_items) do
			    missing = missing +1
			end
			warning('Number of Missing Items: '..missing)
            
            if missing ~= 0 then
                
                for key,val in pairs(missing_temp_items) do
                    local col = build_item(val.Name)
                    if col then
                        table.append(purchase_queue, col)
                    end
                end
            end
        else 
		  warning('You are not in a Gaes Fete Area')
		end
		return
    end
    
	if command == 'listtemp' then
		local currentzone = windower.ffxi.get_info()['zone']
		if currentzone == 291 or currentzone == 289 or currentzone == 288 then 
			find_current_temp_items()
			find_missing_temp_items()
			local missing = 0
			for countmissing,countitems in pairs(missing_temp_items) do
			    missing = missing +1
			end
			warning('Number of Missing Items: '..missing)
		else 
			warning('You are not in a Gaes Fete Area')
		end
		return
	end
    
	if command == 'listki' then
		find_missing_ki()
        warning('Listing missing KIs.')
        for id,ki in pairs(missing_ki) do
            warning("Missing KI:"..ki)
        end
	end
    
    if command == 'find' then
		table.vprint(build_item(item))
		return
	end
    
    if command == 'test' then
        table.vprint(col)
        table.vprint(purchase_queue)
    end
    
    if command == 'fail' then
        exit_sparks()
    end
end)

windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
	if id == 0x034 or id == 0x032 then
        if purchase_queue and #purchase_queue > 0 then
            determine_interaction(purchase_queue[1])
            return true
        end
	end

	if id == 0x110 then -- Update Current Sparks via 110
		local header, value1, value2, Unity1, Unity2, Unknown = data:unpack('II')
		current_sparks = value1
	end
end)

windower.register_event('prerender', function()
	if table.length(purchase_queue) > 0 then
		send_timer = os.clock() - local_timer
        if send_timer >= 4 then
            notice('Timed out.')
            exit_sparks()
            local_timer = os.clock()
            return
        end
		if send_timer >= 1.6 then
            purchase_item(purchase_queue[1])
			local_timer = os.clock()
		end
	else
		local_timer = os.clock()
	end
end)

function determine_interaction(obj)
    local index = purchase_queue:find(obj)
    
    if #purchase_queue == 1 then
        notice('Sparks Buying Finished.')
    end
    
    if index then
        table.remove(purchase_queue, index)
    end
    
    sparks_packet(obj)
end

function count_inv()
	local playerinv = windower.ffxi.get_items().inventory
	return playerinv.max - playerinv.count
end

function purchase_item(obj)
    local zone = windower.ffxi.get_info()['zone']
    local distance = windower.ffxi.get_mob_by_id(obj.Target).distance:sqrt()
    
    if distance > 6 then
        warning('Too far from NPC, cancelling.')
        purchase_queue = T{}
        return
    end
    
    if valid_eschan_zones[zone] and obj['enl'] then
        notice("Buying "..obj['enl']..'.')
    else
        if #purchase_queue % 5 == 0 then
            notice('Buying #'..#purchase_queue..'.')
        end
    end
    poke_npc(obj['Target'],obj['Target Index'])
end

function build_item(item)
	local zone = windower.ffxi.get_info()['zone']
	local target_index,target_id,distance
	local result = {}
    local distance = 50
    
	if valid_spark_zones[zone] then
		for i,v in pairs(get_marray()) do
			if v['name'] == windower.ffxi.get_player().name then
				result['me'] = v.id
			elseif v['name'] == valid_spark_zones[zone].npc then
				target_index = v['index']
				target_id = v['id']
				npc_name = v['name']
				result['Menu ID'] = valid_spark_zones[zone].menu
				distance = windower.ffxi.get_mob_by_id(target_id).distance
			end
		end

		if math.sqrt(distance)<6 then
			local iitem = fetch_db(item)
			if iitem then
				result['Target'] = target_id
				result['Option Index'] = iitem['Option']
				result['_unknown1'] = iitem['Index']
				result['Target Index'] = target_index
				result['Zone'] = zone
				result['Cost'] = iitem['Cost']
                result['enl'] = iitem['Name']:lower()
			end
		else
            warning("Too far from NPC.")
            return nil
		end
    elseif valid_eschan_zones[zone] then
		for i,v in pairs(get_marray()) do
			if v['name'] == windower.ffxi.get_player().name then
				result['me'] = v.id
			elseif v['name'] == valid_eschan_zones[zone].npc then
				target_index = v['index']
				target_id = v['id']
				npc_name = v['name']
				result['Menu ID'] = valid_eschan_zones[zone].menu
				distance = windower.ffxi.get_mob_by_id(target_id).distance
			end
		end
		if math.sqrt(distance)<6 then
			local iitem = fetch_db(item)
			if iitem then
				result['Target'] = target_id
				result['Option Index'] = iitem['Option']
				result['_unknown1'] = iitem['Index']
				result['Target Index'] = target_index
				result['Zone'] = zone
				result['Cost'] = iitem['Cost']
                result['enl'] = iitem['Name']:lower()
			end
            if iitem.TempItem and iitem.TempItem == 1 then
                result['temp_flag'] = 1
            end
		else
            warning("Too far from NPC.")
            return nil
		end
	else
        warning("Not in a zone with valid NPC.")
        return nil
	end
	if result['Zone'] == nil then result = nil end
	return result
end

function fetch_db(item)
	for i,v in pairs(db) do
		if string.lower(v.Name) == string.lower(item) then
			return v
		end
	end
end

function get_spark_update()
	local packet = packets.new('outgoing', 0x117, {["_unknown2"]=0})
	packets.inject(packet)
end

function poke_npc(npc,target_index)
	if npc and target_index then
		local packet = packets.new('outgoing', 0x01A, {
        ["Target"]=npc,
        ["Target Index"]=target_index,
        ["Category"]=0,
        ["Param"]=0,
        ["_unknown1"]=0})
		packets.inject(packet)
	end
end

function sparks_packet(obj)
    local zone = windower.ffxi.get_info().zone
    local menuid = 0
    if valid_eschan_zones[zone] then
        menuid = valid_eschan_zones[zone].menu
    else
        menuid = valid_spark_zones[zone].menu
    end

    if valid_spark_zones[zone] then
        local packet = packets.new('outgoing', 0x05B)
        packet["Target"] = obj['Target']
        packet["Option Index"]=obj["Option Index"]
        packet["_unknown1"]=obj["_unknown1"]
        packet["Target Index"]=obj["Target Index"]
        packet["Automated Message"]=true
        packet["_unknown2"]=0
        packet["Zone"]=zone
        packet["Menu ID"]=menuid
        packets.inject(packet)
        
        local packet = packets.new('outgoing', 0x05B)
        packet["Target"] = obj['Target']
        packet["Option Index"]=0
        packet["_unknown1"]=16384
        packet["Target Index"]=obj["Target Index"]
        packet["Automated Message"]=false
        packet["_unknown2"]=0
        packet["Zone"]=zone
        packet["Menu ID"]=menuid
        packets.inject(packet)
    end
    
    if valid_eschan_zones[zone] then
        local packet = packets.new('outgoing', 0x05B)
        packet["Target"] = obj['Target']
        packet["Option Index"]=obj["Option Index"]
        packet["_unknown1"]=obj["_unknown1"]
        packet["Target Index"]=obj["Target Index"]
        packet["Automated Message"]=true
        packet["_unknown2"]=0
        packet["Zone"]=zone
        packet["Menu ID"]=menuid
        packets.inject(packet)
        
        local packet = packets.new('outgoing', 0x05B)
        packet["Target"] = obj['Target']
        if obj['temp_flag'] and obj['temp_flag'] == 1 then
            packet["Option Index"]= 3
        else
            packet["Option Index"]= 14
        end
        packet["_unknown1"]=obj["_unknown1"]
        packet["Target Index"]=obj["Target Index"]
        packet["Automated Message"]=true
        packet["_unknown2"]=0
        packet["Zone"]=zone
        packet["Menu ID"]=menuid
        packets.inject(packet)

        local packet = packets.new('outgoing', 0x05B)
        packet["Target"]=obj['Target']
        packet["Option Index"]=0
        packet["_unknown1"]=obj['_unknown1']
        packet["Target Index"]=obj['Target Index']
        packet["Automated Message"]=false
        packet["_unknown2"]=0
        packet["Zone"]=obj['Zone']
        packet["Menu ID"]=obj['Menu ID']
        packets.inject(packet)
    end
    
    local packet = packets.new('outgoing', 0x016, {["Target Index"]=obj['me'],})
	packets.inject(packet)
end

function exit_sparks()
    local zone = windower.ffxi.get_info()['zone']
    local menuid = valid_spark_zones[zone].menu
    local me = 0
    local target_index = 0
    local target_id = 0
	if valid_spark_zones[zone] then
		for i,v in pairs(get_marray()) do
            if v['name'] == valid_spark_zones[zone].npc then
				target_index = v['index']
				target_id = v['id']
            elseif v['name'] == windower.ffxi.get_player().name then
                me = v['index']
            end
        end
    end

    local packet = packets.new('outgoing', 0x05B)
    packet["Target"] = target_id
    packet["Option Index"]=0
    packet["_unknown1"]=16384
    packet["Target Index"]=target_index
    packet["Automated Message"]=false
    packet["_unknown2"]=0
    packet["Zone"]=zone
    packet["Menu ID"]=menuid
    packets.inject(packet)

    local packet = packets.new('outgoing', 0x016, {["Target Index"]=me,})
    packets.inject(packet)
end

function get_marray(--[[optional]]name)
	local marray = windower.ffxi.get_mob_array()
	local target_name = name or nil
	local new_marray = T{}
	
	for i,v in pairs(marray) do
		if v.id == 0 or v.index == 0 then
			marray[i] = nil
		end
	end
	
	-- If passed a target name, strip those that do not match
	if target_name then
		for i,v in pairs(marray) do
			if v.name ~= target_name then
				marray[i] = nil
			end
		end
	end
	
	for i,v in pairs(marray) do 
		new_marray[#new_marray + 1] = windower.ffxi.get_mob_by_index(i)
	end
	return new_marray
end

function find_missing_ki()
	missing_ki = T{}
	found_mollifier = 0
	found_radialens = 0
	found_tribulens = 0
	local keyitems = windower.ffxi.get_key_items()
	for id,ki in pairs(keyitems) do
		if ki == 3032 then
			found_mollifier = 1
		elseif ki == 3031 then
			found_radialens = 1
		elseif ki == 2894 then
			found_tribulens = 1
		end
	end
	if found_mollifier == 0 then
		missing_ki[#missing_ki+1] = "mollifier"
	end
	if found_tribulens == 0 then
		missing_ki[#missing_ki+1] = "tribulens"
	end
	if found_radialens == 0 then
		missing_ki[#missing_ki+1] = "radialens"
	end
end

function find_missing_temp_items()
    missing_temp_items = T{}
	for key,val in pairs(all_temp_items) do
		itemmatch = 0
		for k,v in pairs(current_temp_items) do
			if val.Name:lower() == v.Name:lower() then
				itemmatch = 1
			end
		end
		if itemmatch == 0 then
			missing_temp_items[key] = val
		end
	end
end

function find_current_temp_items()
	current_temp_items = T{}
	local tempitems = windower.ffxi.get_items().temporary
	for key,val in pairs(tempitems) do
		if key ~= 'max' and key ~= 'count' and key ~= 'enabled' then
			for k,v in pairs(val) do
				if k == 'id' and v ~= 0 then 
					current_temp_items[v] = db[v]
				end
			end
		end
	end
end

function find_all_temp_items()
	for i,v in pairs(db) do
		if v.TempItem == 1 then
			all_temp_items[i] = v
		end
	end
end
