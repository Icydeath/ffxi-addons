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
    Thank you to Erupt for your work on the first iteration using the old Sparks framework.
--]]

_addon.name = 'Ambuloot'
_addon.author = 'Langly'
_addon.version = '1.1'
_addon.date = '11.15.2019'
_addon.commands = {'ambuloot','ambu'}

require('tables')
require('logger')
packets = require('packets')
db = require('map')

valid_zones = {	
    [249] = {npc="Gorpa-Masorpa", menu=386, id=0, index=0}	
}

gorpa_info = {
    ['npc'] = "Gorpa-Masorpa",
    ['menu'] = 386,
    ['zone'] = 249,
    ['id'] = 0,
    ['index'] = 0,
}
char_info = {
    ['index'] = 0,
    ['current_hallmarks'] = 0,
    ['total_hallmarks'] = 0,
    ['current_gallantry'] = 0,
}
purchase_queue = T{}
item = ''
col = {}
purchasing = false
local_timer = os.clock()

windower.register_event('addon command', function (command, page, amount, ...)
	command = command and command:lower()
    if command == 'test' then
        log(tostring(purchasing))
        log(#purchase_queue)
    end
    if command == 'help' or command == 'h' or command == nil then
        notice('Command Structure: //ambu buy <hallmarks|gallantry> <amount> <item>')
        notice('   Item can be partially or exactly matched ex: Alexandrite or Alex')
        notice('   After each monthly ambuscade update, the gallantry menu changes.')
        notice('   Please modify the MAP.lua file to reflect the new rewards every update.')
        warning('This lua will send requests for item amounts you may not be eligible to purchase.')
        warning('You will receive no items for your request and I take no responsibility for the fate of your character.')
        return
    end
    
    local page = page and page:lower()
    if (page ~= 'hallmarks' and page ~= 'gallantry') then notice('Poorly formatted command, check help first.') return end
    
    local amount = tonumber(amount)
    if amount == nil then 
        notice('Your amount field looks suspect. Hint, use numbers.')
        return
    end

    local args = T{...}
	local item = table.concat(args,' '):lower()

    if command == 'buy' then
        log('Updating currencies...')
        coroutine.sleep(2)
        if item and page and amount then

            local constructed_item = build_item(item, page)
            if constructed_item then
                local total_cost = constructed_item.Cost*amount
                local temp_currency = 0
                local free_space = count_inv()
                local total_space = math.ceil(amount/constructed_item.Stack)
                local stack_value = (256 * constructed_item.Stack + constructed_item["Index"])
                local remainder = (256 * (math.floor(amount%constructed_item.Stack)) + constructed_item["Index"])
                local test_table = T{}
                
                if page == 'hallmarks' then
                    temp_currency = char_info.current_hallmarks
                elseif page == 'gallantry' then
                    temp_currency = char_info.current_gallantry
                end

                if temp_currency < total_cost then warning("You don't have enough hallmarks/gallantry for this size of purchase.") return end
                if free_space < total_space then warning("You don't have enough available inventory space for this size of purchase.") return end

                purchasing = true
                for i = amount,0,-constructed_item.Stack do
                    
                    purchase_queue[#purchase_queue +1] = {}
                    purchase_queue[#purchase_queue]['me'] = constructed_item.me
                    purchase_queue[#purchase_queue]["Name"] = constructed_item.Name
                    purchase_queue[#purchase_queue]["Target"] = constructed_item.Target
                    purchase_queue[#purchase_queue]["Stack"] = constructed_item.Stack
                    purchase_queue[#purchase_queue]["_unknown1"] = stack_value
                    purchase_queue[#purchase_queue]["Target Index"] = constructed_item["Target Index"]
                    purchase_queue[#purchase_queue]["Option Index"] = constructed_item["Option Index"]
                    purchase_queue[#purchase_queue]["Menu ID"] = constructed_item["Menu ID"]
                    purchase_queue[#purchase_queue]["Index"] = constructed_item.Index
                    purchase_queue[#purchase_queue]["Zone"] = constructed_item.Zone
                    purchase_queue[#purchase_queue]["Cost"] = constructed_item.Cost
                end
                purchase_queue[#purchase_queue]["_unknown1"] = remainder
                
                log("Buying "..amount.." of "..constructed_item.Name.." in "..#purchase_queue.." transaction(s).")
                --table.vprint(test_table)
                return
            end
        end
	end
end)

windower.register_event('load', function()
    prompt_currency_update()
end)

windower.register_event('prerender', function()
	if table.length(purchase_queue) > 0 and purchasing == true then
		send_timer = os.clock() - local_timer
        if send_timer >= 4.8 then
            notice('Timed out.')
            exit_ambuscade()
            local_timer = os.clock()
            return
        end
		if send_timer >= 2 then
            purchase_item(purchase_queue[1])
			local_timer = os.clock()
		end
	else
        local_timer = os.clock()
	end
end)

windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
	if (id == 0x034 or id == 0x032) and purchasing == true then
        if purchase_queue and #purchase_queue > 0 then
            determine_interaction(purchase_queue[1])
            return true
        end
        return true
	end

	if id == 0x118 then -- Currency2 Packet Information
        local p = packets.parse('incoming',data)
        char_info['current_hallmarks'] = p['Hallmarks']
        char_info['total_hallmarks'] = p['Total Hallmarks']
        char_info['current_gallantry'] = p['Badges of Gallantry']
	end
end)

function determine_interaction(obj)
    local index = purchase_queue:find(obj)

    if index then
        table.remove(purchase_queue, index)
    end

    if not purchase_queue[1] then
        notice('Ambuloot Buying Finished.')
        purchasing = false
    end
    ambuscade_packet(obj)
end

function ambuscade_packet(obj)
    local menu_id = gorpa_info.menu
    local zone = gorpa_info.zone

    local packet = packets.new('outgoing', 0x05B)
    packet["Target"]=gorpa_info.id
    if obj['Option Index'] == 6 then
        packet["Option Index"]=1
    elseif obj['Option Index'] == 10 then
        packet["Option Index"]=8
    else
        packet["Option Index"]=0
    end
    packet["_unknown1"]=0
    packet["Target Index"]=gorpa_info.index
    packet["Automated Message"]=true
    packet["_unknown2"]=0
    packet["Zone"]=gorpa_info.zone
    packet["Menu ID"]=gorpa_info.menu
    packets.inject(packet)

    local packet = packets.new('outgoing', 0x05B)
    packet["Target"]=gorpa_info.id
    packet["Option Index"]=obj['Option Index']
    packet["_unknown1"]=obj._unknown1
    packet["Target Index"]=gorpa_info.index
    packet["Automated Message"]=true
    packet["_unknown2"]=0
    packet["Zone"]=gorpa_info.zone
    packet["Menu ID"]=gorpa_info.menu
    packets.inject(packet)

    local packet = packets.new('outgoing', 0x05B)
    packet["Target"]=gorpa_info.id
    if obj['Option Index'] == 6 then
        packet["Option Index"]=1
    elseif obj['Option Index'] == 10 then
        packet["Option Index"]=8
    else
        packet["Option Index"]=0
    end
    packet["_unknown1"]=obj._unknown1
    packet["Target Index"]=gorpa_info.index
    packet["Automated Message"]=true
    packet["_unknown2"]=0
    packet["Zone"]=gorpa_info.zone
    packet["Menu ID"]=gorpa_info.menu
    packets.inject(packet)

    local packet = packets.new('outgoing', 0x05B)
    packet["Target"]=gorpa_info.id
    packet["Option Index"]=0
    packet["_unknown1"]=16384
    packet["Target Index"]=gorpa_info.index
    packet["Automated Message"]=false
    packet["_unknown2"]=0
    packet["Zone"]=gorpa_info.zone
    packet["Menu ID"]=gorpa_info.menu
    packets.inject(packet)
end

function build_item(item, page)
	local zone = windower.ffxi.get_info()['zone']
	local target_index,target_id,distance
	local result = T{}
    local distance = 50
    
	if zone == gorpa_info.zone then
		for i,v in pairs(get_marray()) do
			if v['name'] == windower.ffxi.get_player().name then
				result['me'] = v.id
			elseif v['name'] == gorpa_info.npc then
                gorpa_info.id = v['id']
                gorpa_info.index = v['index']
				target_index = v['index']
				target_id = v['id']
				npc_name = v['name']
				result['Menu ID'] = gorpa_info.menu
				distance = windower.ffxi.get_mob_by_id(target_id).distance
			end
		end

		if math.sqrt(distance)<6 then
			local iitem = fetch_db(item, page)
			if iitem then
				result['Target'] = target_id
				result['Option Index'] = iitem['Option']
				result['Index'] = iitem['Index']
                result['_unknown1'] = 0
				result['Target Index'] = target_index
				result['Zone'] = zone
				result['Cost'] = iitem['Cost']
                result['Name'] = iitem['Name']:lower()
                result['Stack'] = iitem['Stack']
			end
		else
            warning("Get closer to Gorpa, please.")
            return nil
		end
	else
        warning("Are you... not in Mhaura?")
        return nil
	end
	if result['Zone'] == nil then result = nil end
	return result
end

function fetch_db(item, page)
	for i,v in pairs(db[page]) do
		if string.lower(v.Name) == string.lower(item) then
			return v
		end
        if string.find(string.lower(v.Name), item) then
            return v
        end
	end
end

function purchase_item(obj)
    local zone = windower.ffxi.get_info()['zone']
    local distance = windower.ffxi.get_mob_by_id(obj.Target).distance:sqrt()
    
    if distance > 6 then
        warning('Too far from NPC, cancelling.')
        purchase_queue = T{}
        return
    end
    
    if gorpa_info.zone and obj['Name'] then
        notice("Buying "..obj['Name']..'.')
    else
        --if #purchase_queue % 5 == 0 then
        --    notice('Buying #'..#purchase_queue..'.')
        --end
    end
    poke_npc(obj['Target'],obj['Target Index'])
end

function prompt_currency_update()
	local packet = packets.new('outgoing', 0x115, {["_unknown2"]=0})
	packets.inject(packet)
end

function poke_npc(id, index)
	if id and index then
		local packet = packets.new('outgoing', 0x01A, {
			["Target"]=id,
			["Target Index"]=index,
			["Category"]=0,
			["Param"]=0,
			["_unknown1"]=0})
		packets.inject(packet)
	end
end

function exit_ambuscade()
    local packet = packets.new('outgoing', 0x05B)
    packet["Target"]=gorpa_info.id
    packet["Option Index"]=0
    packet["_unknown1"]=16384
    packet["Target Index"]=gorpa_info.index
    packet["Automated Message"]=false
    packet["_unknown2"]=0
    packet["Zone"]=gorpa_info.zone
    packet["Menu ID"]=gorpa_info.menu
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

function count_inv()
	local playerinv = windower.ffxi.get_items().inventory
	return playerinv.max - playerinv.count
end