--[[Copyright © 2016, Hugh Broome, Sebastien Gomez
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

_addon.name     = 'HTMB'
_addon.author   = 'Lygre + Colway'
_addon.version  = '2.0.1'
_addon.commands = {'HTMB'}

require('tables')
require('strings')
require('luau')
require('pack')
require('lists')
require('logger')
require('sets')
files = require('files')
packets = require('packets')
require('chat')
res = require('resources')

require 'Packet_Injection'
require 'Commad_Generation'
require 'Iterator_functions'

-- packets to track
-- pv t i 0x032|0x034|0x055|0x065 o 0x016|0x05b|0x05c
-- pv l f both 0x032 0x034 0x055 0x065 0x016 0x05b 0x05c

function load_zones()

	local f = io.open(windower.addon_path..'data/zone_info.lua','r')
	local t = f:read("*all")
	t = assert(loadstring(t))()
	f:close()
	
	return t
end

function load_KIs()

	local f = io.open(windower.addon_path..'data/ki_info.lua','r')
	local t = f:read("*all")
	t = assert(loadstring(t))()
	f:close()
	
	return t
end

function load_NPCs()

	local f = io.open(windower.addon_path..'data/npc_info.lua','r')
	local t = f:read("*all")
	t = assert(loadstring(t))()
	f:close()
	
	return t
end

function load_HPs()

	local f = io.open(windower.addon_path..'data/HP_info.lua','r')
	local t = f:read("*all")
	t = assert(loadstring(t))()
	f:close()
	
	return t
end

zones = load_zones()
key_items = load_KIs()
npcs = load_NPCs()
HPs = load_HPs()
player = windower.ffxi.get_player()
number_of_merits = 0
current_zone = windower.ffxi.get_info().zone
current_HP_number = 0
pkt = {}
first_poke = false
number_of_attempt = 1
activate_by_addon = false
activate_by_addon_npc = false
activate_by_addon_HP = false
usable_commands = {}
ki_commands = {}
current_ki_id = 0
forced_update = false

windower.register_event('addon command', function(...)

	local args = T{...}
	local cmd = args[1]
	local lcmd = cmd:lower()
	
	if table.length(usable_commands) > 0 then
		for k,v in pairs(usable_commands) do
			if v['command_name']:contains(lcmd) and v['command_name']:contains(args[2]) then
				player = windower.ffxi.get_player()
				current_zone = windower.ffxi.get_info().zone
				pkt = validate()
				log('Checking data for BCNM in zone!')
				number_of_attempt = 1
				activate_by_addon = true
				current_ki_id = v['KI ID']
				poke_warp(current_zone,v['KI ID'])
				
			end
		end
	end
	if table.length(ki_commands) > 0 then 
		local found = false
		for k,v in pairs(ki_commands) do
			if (v['command_name']:contains(args[1]) and v['command_name']:contains(args[2])) or (v['command_name_nickname']:contains(args[1]) and v['command_name_nickname']:contains(args[2])) then
				player = windower.ffxi.get_player()
				current_zone = windower.ffxi.get_info().zone
				pkt = validate()
				log('Checking data for KI NPC in zone!')
				activate_by_addon_npc = true
				current_ki_id = v['KI ID']
				poke_npc(current_zone,v['KI ID'])
				found = true
			end	
		end
		if found == false then
			error('You have entred an incorrect command!')
		end		
	end
	if lcmd == 'force' then
		warning('Force checking ki count AND battlefields in zone')
		current_zone = windower.ffxi.get_info().zone
		forced_update = true
		check_zone_for_battlefield(current_zone)
		local packet = packets.new('outgoing', 0x061, {})
		packets.inject(packet)
		coroutine.sleep(1.5)
		find_missing_kis(current_zone)
	end
	if lcmd == 'crystal' then
		player = windower.ffxi.get_player()
		current_zone = windower.ffxi.get_info().zone
		pkt = validate()
		activate_by_addon_HP = true
		poke_warp_HP(current_zone)
		if args[2] == 'all' then
			coroutine.sleep(1)
			windower.send_command('send @others htmb crystal')
		end
	end
end)

function validate()
	local me
	local result = {}
	for i,v in pairs(windower.ffxi.get_mob_array()) do
		if v['name'] == player.name then
			result['me'] = i
		end
	end
	return result 
end

-- parsing of relevant incoming packets to perform actions
windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
	
	if id == 0x034 or id == 0x032 then  -- original poke i.e. opening entry menu
		if activate_by_addon == true then
		
			log('packet 0x034 received (menu entry packet)')
			local packet = packets.new('outgoing', 0x016, {
				["Target Index"]=pkt['me'],
			})
			packets.inject(packet)
			--if first time poking the door send the assosiated junk 0x016 packets
			if first_poke then
				inject_anomylus_packets(current_zone)
				first_poke = false
			end
			
			-- send menu choice for VD 
			log('Sending first 0x05B packet (menu choice)')
			create_0x05B(current_zone,1,true)
			-- send entry request for BCNM room 1
			log('Sending 0x05C packet (Entry request for BCNM room 1)')
			create_0x05C(zones[current_zone][current_ki_id]['0x05C'][number_of_attempt])
			number_of_attempt = number_of_attempt + 1
			return true
			
		elseif activate_by_addon_npc == true then
		
			log('packet 0x034 received (menu entry packet for ki buying)')
			local packet = packets.new('outgoing', 0x016, {
				["Target Index"]=pkt['me'],
			})
			packets.inject(packet)
			-- itterate through ki id's for the option index associated
			for k, v in pairs(key_items[current_ki_id]) do
				if k ==  "Option Index" then
					if v[2] then
						log('Sending first 0x05B packet (switch page in menu)')
						create_0x05B_ki(current_zone,2,true,current_ki_id)
						log('Sending second 0x05B packet (menu choice)')
						create_0x05B_ki(current_zone,2,false,current_ki_id)
						return true
					else
						log('Sending first 0x05B packet (menu choice)')
						create_0x05B_ki(current_zone,1,false,current_ki_id)
						return true
					end		
				end
			end
		elseif activate_by_addon_HP == true and current_HP_number > 0 then
			-- create_0x05B_HP(zone_number,option_index,message,HP_number,unknown_number)
			log('Sending 1st 0x05B packet')
			create_0x05B_HP(current_zone,1,true,current_HP_number,1)
			log('Sending 2nd 0x05B packet')
			create_0x05B_HP(current_zone,2,true,current_HP_number,2)
			log('Sending 3rd 0x05B packet')
			create_0x05B_HP(current_zone,3,false,current_HP_number,3)
			
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=pkt['me'],
			})
			packets.inject(packet)
			
			pkt = {}
			activate_by_addon_HP = false
			current_HP_number = 0
			return true
		end
		
	elseif id == 0x065 then -- confirmation packet of available BCNM room
		if activate_by_addon == true then
			log('packet 0x065 received (Entry confirmation packet)')
			 -- parse the packet for its data
			local packet = packets.parse('incoming', data)			
			-- if unknow = 1 then room 1 is free, for farvour confirmation we check co-ordinates against ones we sent
			if packet['_unknown1'] == 1 then
				log('Confirmed BCNM room '.. (number_of_attempt - 1) ..' is open, waiting for 0x055 packet')
			else
			-- failed to entre room 1 so we cycle to room 2 then room 3
				log('BCNM Room ' .. (number_of_attempt - 1) .. ' is full. Attempting next BCNM room!')
				if number_of_attempt < 4 then
					create_0x05C(zones[current_zone][current_ki_id]['0x05C'][number_of_attempt])
					number_of_attempt = number_of_attempt + 1
				else
					error('All Rooms are full, sending 0x05B to exit.')
					create_0x05B(current_zone,3,false)
					local packet = packets.new('outgoing', 0x016, {
						["Target Index"]=pkt['me'],
					})
					packets.inject(packet)
					number_of_attempt = 1
					return true
				end
			end
			return true
		end
		
	elseif id == 0x055 then -- change in player KI data confirming entry
		if activate_by_addon == true then
			notice('Confirmed entry to BCNM room ' .. (number_of_attempt - 1) .. ' !')
			create_0x05B(current_zone,2,false)
			local packet = packets.new('outgoing', 0x016, {
				["Target Index"]=pkt['me'],
			})
			packets.inject(packet)
			activate_by_addon = false
			delete_commands()
			number_of_attempt = 1
			pkt = {}
			return true
			
		elseif activate_by_addon_npc == true then
		
			local packet = packets.new('outgoing', 0x016, {
				["Target Index"]=pkt['me'],
			})
			packets.inject(packet)
			
			pkt = {}
			activate_by_addon_npc = false
			notice('KI \"' .. (key_items[current_ki_id]['KI Name']):color(215) .. '\" has been baught!' )
			delete_ki_commands()
			
			coroutine.sleep(3)
			windower.send_command('htmb force')
			return true
			
		end
	elseif id == 0x63 and data:byte(5) == 2 and forced_update == true then
		number_of_merits = data:byte(11)%128
		log('Total merit update. Total: ' .. number_of_merits)
		forced_update = false
	end
end)

-- event to track zone change and reset first time poke
windower.register_event('zone change',function(new_id,old_id)
	if first_poke and current_zone ~= new_id then
		first_poke = false
		activate_by_addon = false
		log('You have left the BCNM Entry area!')
		delete_commands()
	end
	if zones[new_id] then
		log('You have zoned into a BCNM Entry area. Waiting for player data...')
		coroutine.sleep(2)
		log('...')
		coroutine.sleep(2)
		log('...')
		coroutine.sleep(2)
		log('...')
		coroutine.sleep(2)
		log('...')
		coroutine.sleep(2)
		log('...')
		check_zone_for_battlefield(new_id)
	elseif npcs[new_id] then
		log('You have zoned into an area with a KI npc. Waiting for player data...')
		coroutine.sleep(2)
		log('...')
		coroutine.sleep(2)
		log('...')
		coroutine.sleep(2)
		log('...')
		coroutine.sleep(2)
		log('...')
		coroutine.sleep(2)
		log('...')
		forced_update = true
		local packet = packets.new('outgoing', 0x061, {})
		packets.inject(packet)
		coroutine.sleep(1.5)
		notice("Checking for missing KI's!")
		find_missing_kis(new_id)
	else
		delete_commands()
	end
	
end)




