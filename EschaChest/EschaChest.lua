_addon.name = 'EschaChest'
_addon.author = 'Icy'
_addon.commands = {'eschachest','ec'}
_addon.version = '1.0.0'

require('tables')
require('strings')
require('sets')
require('pack')
require('coroutine')
require('chat')
packets = require('packets')
res_items = require('resources').items

-- set this to false if you don't want it to automatically open the boxes when it reads the msg in the chat log.
auto_open = true 

-- To manually trigger the addon use the below commands:
-- //ec   [OR]   //ec echest

-- List of brown box escha items can be found here: https://ffxiclopedia.fandom.com/wiki/Emblazoned_Reliquary
--	[ID] = 'Item Name' (Easiest way to find an items ID is to search for it using FFXIAH.com and you'll see its ID in the URL)
-- *** NOTE: I don't have logic to handle R/E items! Avoid obtaining those! ***
get_items = {
	[9130] = 'Eschite Ore',
	--[6391] = 'Silt Pouch',
	[6392] = 'Bead Pouch',
	[9076] = 'Gravewood Log',
	[9078] = 'Ashweed',
	[722] = 'Divine Log',
	[9201] = 'Bamboo Shoots'
}

--[[
  If you deal with a lot of lag and it's trying to open the chest before it's 
   loaded, you can try increasing this value to get it to work. 
  The default is 1, any value lower it seems to go to fast for the server. 
--]]
seconds_to_wait = 1.3

-------------------------------------------------------------------------------------------
-- Don't mess with the below variables unless you know what you are doing :D
-------------------------------------------------------------------------------------------
pkt = {}
lastpkt = {}

slots = { 5, 7 }
valid_zones = {
	[288] = "Escha - Zi'Tah", 
	[289] = "Escha - Ru'Aun", 
	[291] = "Reisinjima"
}
valid_npcs = {
	echest = S{'Emblazoned Reliquary'},
}

num_items_obtained = 0
items_to_obtain = 0
items_in_box = 0
zone_id = nil

function escape()
    coroutine.sleep(1)    
	message('Escaping menu...')
	windower.send_command('setkey escape down')
	coroutine.sleep(.2)
	windower.send_command('setkey escape up')
	
	
	if items_in_box == 1 and num_items_obtained == 1 then -- Box should disappear because we obtained the only item in it
		message('Box is now empty.')
	else
		message('Checking remaining items...')
		coroutine.sleep(1)
		send_poke_command()
	end
end

windower.register_event('addon command', function(...)
    local command = {...}
	local argval = 'echest'
	
	if #command ~= 0 then
		if command[1]:lower() == 'reset' then
			reset_me()
			return
		elseif command[1]:lower() == 'zone' then
			local zone = windower.ffxi.get_info()['zone']
			message('Zone ID: '..zone)
			if valid_zones[zone] then message(' ^ Is a valid zone: '..valid_zones[zone]) else message(' ^ IS NOT a valid zone') end
			return
		else
			argval = command[1]
		end
	end
	
	pkt = validate_npc(argval)
	if pkt then
		poke_npc(pkt['Target'], pkt['Target Index'])
	else
		message('Error: Box did not fully load or the box was out of range. Increasing the seconds_to_wait value may help with this issue.')
	end
end)

function validate_npc(npc_type)
	local result = {}
	local zone = windower.ffxi.get_info()['zone']
	
	if valid_zones[zone] then
		result['Zone'] = zone
		for i,v in pairs(windower.ffxi.get_mob_array()) do
			if v['name'] == windower.ffxi.get_player().name then
				result['me'] = i
			elseif v.valid_target and (valid_npcs[npc_type]:contains(v['name']) or (npc_type == v['name'])) and math.sqrt(v.distance) < 6 then
				result['Target Index'] = i
				result['Target'] = v['id']
			end
		end
	end
	
	if not result['Zone'] or not result['Target'] or not result['Target Index'] then
		result = nil
	end

	return result
end

function poke_npc(npc, target_index)
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

function reset_me()
		local packet = packets.new('outgoing', 0x05B)
		packet["Target"]=lastpkt['Target']
		packet["Option Index"]=lastpkt['Option Index']
		packet["_unknown1"]="16384"
		packet["Target Index"]=lastpkt['Target Index']
		packet["Automated Message"]=false
		packet["_unknown2"]=0
		packet["Zone"]=lastpkt['Zone']
		packet["Menu ID"]=lastpkt['Menu ID']
		packets.inject(packet)
end

function message(msg)
    windower.add_to_chat(200,'[EschaChest] '..tostring(msg)..'')
end

windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
	if id == 0x034 or id == 0x032 then
		local p = packets.parse('incoming',data)
		--windower.add_to_chat(10,'Menu Found:'..p['Menu ID'])
		
		if pkt and (p['Menu ID'] == 9250 or p['Menu ID'] == 9251 or p['Menu ID'] == 9252) then
		
			items_in_box = 0
			items_to_obtain = 0
			num_items_obtained = 0
			
			local destroyed_box = false
			local menu_option = 0
			
			local packet = packets.new('outgoing', 0x05B)
			pkt['Menu ID'] = p['Menu ID']
			if pkt['Menu ID'] == 9251 then -- Brown Chest
			
				for i = 1, #slots do
					local item = p['Menu Parameters']:unpack('H', slots[i])
					local option = i+1
					
					local item_name = ''
					if res_items[item] ~= nil then
						item_name = tostring(res_items[item].en)
						items_in_box = items_in_box + 1
					end
					windower.add_to_chat(10,'  Option '..option..': [ '..item..' ] '..item_name)
					
					if get_items[item] then
						items_to_obtain = items_to_obtain + 1
						menu_option = option
					end
				end
				
				if items_to_obtain ~= 0 then
					-- Option Index for items always = 1, unless we are destroying the box.
					pkt['Option Index'] = 1
					
					-- _unknown1 for the first item(option 2) = 0, second item(option 3) = 1
					local unknown1 = 0
					if menu_option == 3 then 
						unknown1 = 1 
					end
					
					pkt['_unknown1'] = unknown1
					
					-- send packet to obtain the item
					packet["Target"]=pkt['Target']
					packet["Option Index"]=pkt['Option Index']
					packet["_unknown1"]=pkt['_unknown1']
					packet["Target Index"]=pkt['Target Index']
					packet["Automated Message"]=true
					packet["_unknown2"]=0
					packet["Zone"]=pkt['Zone']
					packet["Menu ID"]=pkt['Menu ID']
					packets.inject(packet)
					
					-- send update packet
					packet = packets.new('outgoing', 0x016, {["Target Index"]=pkt['me'],})
					packets.inject(packet)
					
					num_items_obtained = num_items_obtained +1
				else 
					-- No items to obtain, destroy the box.
					message('No wanted items found in box. Destroying [Brown] box...')
					
					-- send destroy box option
					packet["Target"]=pkt['Target']
					packet["Option Index"]=3
					packet["_unknown1"]=0
					packet["Target Index"]=pkt['Target Index']
					packet["Automated Message"]=true
					packet["_unknown2"]=0
					packet["Zone"]=pkt['Zone']
					packet["Menu ID"]=pkt['Menu ID']
					packets.inject(packet)
					
					-- send 2nd packet 
					packet["Target"]=pkt['Target']
					packet["Option Index"]=3
					packet["_unknown1"]=0
					packet["Target Index"]=pkt['Target Index']
					packet["Automated Message"]=false
					packet["_unknown2"]=0
					packet["Zone"]=pkt['Zone']
					packet["Menu ID"]=pkt['Menu ID']
					packets.inject(packet)
					
					destroyed_box = true
				end
				
				--windower.add_to_chat(10,'    items_in_box: '..items_in_box..' | items_to_obtain: '..items_to_obtain..' | num_items_obtained: '..num_items_obtained)
								
			else -- Blue/Gold
				message('Destroying [Blue/Gold] box...')
				
				-- send destroy box option
				packet["Target"]=pkt['Target']
				packet["Option Index"]=3
				packet["_unknown1"]=0
				packet["Target Index"]=pkt['Target Index']
				packet["Automated Message"]=true
				packet["_unknown2"]=0
				packet["Zone"]=pkt['Zone']
				packet["Menu ID"]=pkt['Menu ID']
				packets.inject(packet)
				
				-- send 2nd packet 
				packet["Target"]=pkt['Target']
				packet["Option Index"]=3
				packet["_unknown1"]=0
				packet["Target Index"]=pkt['Target Index']
				packet["Automated Message"]=false
				packet["_unknown2"]=0
				packet["Zone"]=pkt['Zone']
				packet["Menu ID"]=pkt['Menu ID']
				packets.inject(packet)
				
				destroyed_box = true
			end
			
			-- send update packet
			packet = packets.new('outgoing', 0x016, {["Target Index"]=pkt['me'],})
			packets.inject(packet)
			
			-- Keep track of the last packet we used so we can reset it if need be.
			lastpkt = pkt
			
			-- Clear out the global packet
			pkt = {} 
			
			if destroyed_box then
				destroyed_box = false
				return true	
			else
				coroutine.schedule(escape, 1)
			end
			
		end
	end 
end)

function send_poke_command()
	windower.send_command('ec echest')
end

windower.register_event('incoming text', function(original, modified, original_mode, modified_mode, blocked)
    -- TODO: Better solution would be to identify the incoming packet of the msg saying the chest spawned.
	if not valid_zones[zone_id] then return end
	if not auto_open then return end
	if blocked or original == '' then return end
	
	formatted = original:strip_format()
	if string.find(formatted,"The monster was concealing a treasure chest!") then
		coroutine.schedule(send_poke_command, seconds_to_wait)
	end
end)

windower.register_event('load', function()	
	zone_id = windower.ffxi.get_info()['zone']
end)

windower.register_event('zone change',function(new,old)
	zone_id = new
end)