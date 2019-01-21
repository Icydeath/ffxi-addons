--[[

Copyright © 2019, Akaden of Asura
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of HomePoint nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sammeh BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]

_addon.name = 'superwarp'

_addon.author = 'Akaden'

_addon.version = '0.9'

_addon.command = 'sw'

require('tables')
require('logger')
require('functions')
packets = require('packets')
require('coroutine')
config = require('config')

maps = {
	['hp'] = require('map/homepoints'),
	['wp'] = require('map/waypoints'),
	['sg'] = require('map/guides'),
}

sub_zone_aliases = {
	['e'] = 'Entrance',
	['ah'] = 'Auction House',
	['auction'] = 'Auction House',
	['mh'] = 'Mog House',
	['mog'] = 'Mog House',
	['house'] = 'Mog House',
	['fs'] = 'Frontier Station',
}

sub_zone_targets = {
	['hp'] = S{'entrance', 'mog house', 'auction house', '1', '2', '3', '4', '5', '6', '7', '8', '9', },
	['wp'] = S{'frontier station', 'platea', 'triumphus', 'pioneers', 'mummers', 'inventors', 'auction house', 'mog house', 'bridge', 'airship', 'docks', 'waterfront', 'peacekeepers', 'scouts', 'statue', 'goddess', 'wharf', 'yahse', 'sverdhried', 'hillock', 'coronal', 'esplanade', 'castle', 'gates', '1', '2', '3', '4', '5', '6', '7', '8', '9', }	
}

warp_list = S{'hp','wp','sg'}

local defaults = {
	debug = false,
	send_all_delay = 0.4,
	max_retries = 6,
	retry_delay = 2,
}

local settings = config.load(defaults)

local state = {
	loop_count = nil,
}

function debug(msg)
	if settings.debug then
		log('debug: '..msg)
	end
end

local function get_delay()
    local self = windower.ffxi.get_player().name
    local members = {}
    for k, v in pairs(windower.ffxi.get_party()) do
        if type(v) == 'table' then
            members[#members + 1] = v.name
        end
    end
    table.sort(members)
    for k, v in pairs(members) do
        if v == self then
            return (k - 1) * settings.send_all_delay
        end
    end
end

--- resolve sub-zone target aliases (ah -> auction house, etc.)
local function resolve_sub_zone_aliases(raw)
	if raw == nil then return nil end
	local raw_lower = raw:lower()

	if sub_zone_aliases[raw_lower] then return sub_zone_aliases[raw_lower] end

	return raw
end

function get_fuzzy_name(name)
	return name:lower():gsub("%s", ""):gsub("%p", "")
end

function get_closest_match(map, needle)
	local fuzzy_needle = get_fuzzy_name(needle)

	local key, score
	for haystack, value in pairs(map) do
		local fuzzy_haystack = get_fuzzy_name(haystack)
		if (fuzzy_needle:length() >= 3 and fuzzy_haystack:contains(fuzzy_needle)) or fuzzy_haystack == fuzzy_needle then
			local cur_score = fuzzy_haystack:length() - fuzzy_needle:length()
			if not key or cur_score < score then
				key = haystack
				score = cur_score
			end
		end
	end
	return key
end

local function resolve_warp_index(map, zone, sub_zone)
	local closest_zone_name = get_closest_match(map, zone)
	if closest_zone_name then
		local zone_map = map[closest_zone_name]
		if type(zone_map) == 'table' then
			if sub_zone ~= nil then
				local closest_sub_zone = get_closest_match(zone_map, sub_zone)
				if closest_sub_zone then
					debug('found warp index: '..closest_zone_name..'/'..closest_sub_zone..' ('..zone_map[closest_sub_zone]..')')
					return zone_map[closest_sub_zone], closest_zone_name..' - '..closest_sub_zone
				else
					log('Found zone ('..closest_zone_name..'), but not sub zone: "'..sub_zone..'"')
					return nil
				end
			else
				for sz, index in pairs(zone_map) do
					debug('Found zone ('..closest_zone_name..'), but no sub-zone listed, using first ('..sz..')')
					return index, closest_zone_name..' - '..sz
				end
			end
		else
			return zone_map, closest_zone_name	
		end
	else
		log('Could not find zone: '..zone)
		return nil
	end
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

local function find_npc(search)
	local target_id = nil
	local target_index = nil
	local distance = nil
	local name = nil
	for i, v in pairs(windower.ffxi.get_mob_array()) do
		local d = windower.ffxi.get_mob_by_index(i).distance
		if (not target_id or d < distance) and string.find(v.name, search) then
			target_index = i
			target_id = v.id
			name = v.name
			distance = d
		end
	end
	return target_id, target_index, distance, name
end

local function reset(quiet)
	if current_activity and last_packet then
		local packet = packets.new('outgoing', 0x05B)
		packet["Target"]=last_packet['Target']
		packet["Option Index"]="0"
		packet["_unknown1"]="16384"
		packet["Target Index"]=last_packet['Target Index']
		packet["Automated Message"]=false
		packet["_unknown2"]=0
		packet["Zone"]=last_packet['Zone']
		packet["Menu ID"]=last_packet['Menu ID']
		packets.inject(packet)
		last_activity = current_activity
		current_activity = nil
		if not quiet then
			log('Should be reset now. Please try again.')
		end
	else
		if not quiet then
			log('No warp scheduled.')
		end
	end
end

local function set_homepoint()
	local id, index, dist, name = find_npc('Home Point')
	if id and index and dist <= 6^2 then
		current_activity = {type='sethp', id=id, index=index, name=name}
		poke_npc(id, index)
	elseif not id then
		log('No homepoint found!')
	elseif distance > 6^2 then
		log('Homepoint found, but too far!')
	end
end

local function loop_warp(fn, ...)
	if state.loop_count == nil then 
		state.loop_count = settings.max_retries 
	end

	if state.loop_count > 0 then
		fn(...)
		state.loop_count = state.loop_count - 1

		loop_warp:schedule(settings.retry_delay, fn, ...)
	end
end

local function do_homepoint_warp(zone, sub_zone)
	local warp_index, display_name = resolve_warp_index(maps.hp, zone, sub_zone)
	if warp_index then
		local id, index, dist, name = find_npc('Home Point')
		if id and index and dist <= 6^2 then
			reset(true)
			current_activity = {type='hp', id=id, index=index, name=name, hp_index=warp_index}
			poke_npc(id, index)
			log('Warping via Home Point to '..display_name..'.')
		elseif not id then
			log('No homepoint found!')
		elseif dist > 6^2 then
			log('Homepoint found, but too far!')
		end
	else
		state.loop_count = 0
	end
end

local function do_waypoint_warp(zone, sub_zone)
	local warp_index, display_name = resolve_warp_index(maps.wp, zone, sub_zone)
	if warp_index then
		local id, index, dist, name = find_npc('Waypoint')
		if id and index and dist <= 6^2 then
			current_activity = {type='wp', id=id, index=index, name=name, wp_index=warp_index}
			poke_npc(id, index)
			log('Warping via Waypoint to '..display_name..'.')
		elseif not id then
			log('No homepoint found!')
		elseif dist > 6^2 then
			log('Homepoint found, but too far!')
		end
	else
		state.loop_count = 0
	end
end

local function do_guide_warp(zone)
	local warp_index, display_name = resolve_warp_index(maps.sg, zone)
	if warp_index then
		local id, index, dist, name = find_npc('Survival Guide')
		if id and index and dist <= 6^2 then
			current_activity = {type='sg', id=id, index=index, name=name, sg_index=warp_index}
			poke_npc(id, index)
			log('Warping via Survival Guide to '..display_name..'.')
		elseif not id then
			log('No homepoint found!')
		elseif dist > 6^2 then
			log('Homepoint found, but too far!')
		end
	else
		state.loop_count = 0
	end
end

local function handle_warp(warp, args)
	warp = warp:lower()

	-- because I can't stop typing "hp warp X" because I've been trained. 
	if args[1]:lower() == 'warp' or args[1]:lower() == 'w' then args:remove(1) end

	local all = args[1]:lower() == 'all' or args[1]:lower() == 'a' or args[1]:lower() == '@all'
	if all then 
		args:remove(1) 

		debug('sending warp to all.')
		windower.send_ipc_message(warp..' '..args:concat(' '))

		local delay = get_delay()
		handle_warp:schedule(delay, warp, args)
		return
	end

	local sub_zone_target = nil
	if sub_zone_targets[warp] then
		local target_candidate = resolve_sub_zone_aliases(args:last())
		if sub_zone_targets[warp]:contains(target_candidate:lower()) then
			sub_zone_target = target_candidate
			args:remove(args:length())
		end
	end

	state.loop_count = nil
	if warp == 'hp' then
		if args[1]:lower() == 'set' then
			set_homepoint()
		else
			loop_warp(do_homepoint_warp, args:concat(' '), sub_zone_target)
		end
	elseif warp == 'wp' then
		loop_warp(do_waypoint_warp, args:concat(' '), sub_zone_target)
	elseif warp == 'sg' then
		loop_warp(do_guide_warp, args:concat(' '))
	end
end


windower.register_event('addon command', function(...)
    local args = T{...}
    local cmd = args[1]
	args:remove(1)
	for i,v in pairs(args) do args[i]=windower.convert_auto_trans(args[i]) end
	local item = table.concat(args," "):lower()
	if warp_list:contains(cmd) then
		handle_warp(cmd, args)
	elseif cmd == 'reset' then
		reset()	
		if args[1] and args[1]:lower() == 'all' then
			windower.send_ipc_message('reset')
		end
	else
		log("[sw] hp [warp/w] [all/a/@all] zone name [homepoint_number] -- warp to a designated homepoint. \"all\" sends ipc to all local clients.")
		log("[sw] wp [warp/w] [all/a/@all] zone name [waypoint_number] -- warp to a designated waypoint. \"all\" sends ipc to all local clients.")
		log("[sw] sg [warp/w] [all/a/@all] zone name -- warp to a designated survival guide. \"all\" sends ipc to all local clients.")
	end
end)

-- handle direct hp/wp/sg commands
windower.register_event('unhandled command', function(cmd, ...)
    local args = T{...}
	for i,v in pairs(args) do args[i]=windower.convert_auto_trans(args[i]) end
    if warp_list:contains(cmd:lower()) then
		handle_warp(cmd, args)
    end
end)

-- handle ipc message
windower.register_event('ipc message', function(msg) 
	local args = msg:split(' ')
	local cmd = args[1]
	args:remove(1)
	if cmd == 'reset' then
		reset()
	elseif warp_list:contains(cmd) then
		local delay = get_delay()
		debug('received ipc: '..msg..'. executing in '..tostring(delay)..'s.')
		handle_warp:schedule(delay, cmd, args)
	end
end)

-- Handle menu interraction. 
windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
	if id == 0x034 or id == 0x032 then
		local p = packets.parse('incoming',data)
		
		if current_activity then
			local packet = packets.new('outgoing', 0x05B)

			if current_activity.type == 'sethp' then
				local zone = windower.ffxi.get_info()['zone']

				-- menu change
				packet["Target"] = current_activity.id
				packet["Target Index"] = current_activity.index
				packet["Zone"] = zone
				packet["Menu ID"] = p['Menu ID']

				packet["Option Index"] = 8
				packet["_unknown1"] = 0
				packet["Automated Message"] = true
				packet["_unknown2"] = 0
				packets.inject(packet)
				
				-- select "set HP"
				packet["Target"] = current_activity.id
				packet["Target Index"] = current_activity.index
				packet["Zone"] = zone
				packet["Menu ID"] = p['Menu ID']

				packet["Option Index"] = 1
				packet["_unknown1"] = 0
				packet["Automated Message"] = false
				packet["_unknown2"] = 0
				packets.inject(packet)

				last_packet = packet
				last_activity = current_activity
				state.loop_count = 0
				current_activity = nil
				return true
			elseif current_activity.type == 'hp' then
				local zone = windower.ffxi.get_info()['zone']

				-- menu change
				packet["Target"] = current_activity.id
				packet["Target Index"] = current_activity.index
				packet["Zone"] = zone
				packet["Menu ID"] = p['Menu ID']

				packet["Option Index"] = 8
				packet["_unknown1"] = 0
				packet["Automated Message"] = true
				packet["_unknown2"] = 0
				packets.inject(packet)

				-- menu change
				packet["Target"] = current_activity.id
				packet["Target Index"] = current_activity.index
				packet["Zone"] = zone
				packet["Menu ID"] = p['Menu ID']

				packet["Option Index"] = 2
				packet["_unknown1"] = 0
				packet["Automated Message"] = true
				packet["_unknown2"] = 0
				packets.inject(packet)
			
				-- request warp
				packet["Target"] = current_activity.id
				packet["Target Index"] = current_activity.index
				packet["Zone"] = zone
				packet["Menu ID"] = p['Menu ID']

				packet["Option Index"] = 2
				packet["_unknown1"] = current_activity.hp_index
				packet["Automated Message"] = false
				packet["_unknown2"] = 0
				packets.inject(packet)

				last_packet = packet
				last_activity = current_activity
				state.loop_count = 0
				current_activity = nil
				return true
			elseif current_activity.type == 'wp' then
				local zone = windower.ffxi.get_info()['zone']

				-- menu change
				packet["Target"] = current_activity.id
				packet["Target Index"] = current_activity.index
				packet["Zone"] = zone
				packet["Menu ID"] = p['Menu ID']

				packet["Option Index"] = current_activity.wp_index
				packet["_unknown1"] = 0
				packet["Automated Message"] = true
				packet["_unknown2"] = 0
				packets.inject(packet)
			
				-- request warp
				packet["Target"] = current_activity.id
				packet["Target Index"] = current_activity.index
				packet["Zone"] = zone
				packet["Menu ID"] = p['Menu ID']

				packet["Option Index"] = current_activity.wp_index
				packet["_unknown1"] = 0
				packet["Automated Message"] = false
				packet["_unknown2"] = 0
				packets.inject(packet)

				last_packet = packet
				last_activity = current_activity
				state.loop_count = 0
				current_activity = nil
				return true
			elseif current_activity.type == 'sg' then
				local zone = windower.ffxi.get_info()['zone']

				-- menu change
				packet["Target"] = current_activity.id
				packet["Target Index"] = current_activity.index
				packet["Zone"] = zone
				packet["Menu ID"] = p['Menu ID']

				packet["Option Index"] = 8
				packet["_unknown1"] = 0
				packet["Automated Message"] = true
				packet["_unknown2"] = 0
				packets.inject(packet)

				-- menu change
				packet["Target"] = current_activity.id
				packet["Target Index"] = current_activity.index
				packet["Zone"] = zone
				packet["Menu ID"] = p['Menu ID']

				packet["Option Index"] = 1
				packet["_unknown1"] = current_activity.sg_index
				packet["Automated Message"] = true
				packet["_unknown2"] = 0
				packets.inject(packet)
			
				-- request warp
				packet["Target"] = current_activity.id
				packet["Target Index"] = current_activity.index
				packet["Zone"] = zone
				packet["Menu ID"] = p['Menu ID']

				packet["Option Index"] = 1
				packet["_unknown1"] = current_activity.sg_index
				packet["Automated Message"] = false
				packet["_unknown2"] = 0
				packets.inject(packet)

				last_packet = packet
				last_activity = current_activity
				state.loop_count = 0
				current_activity = nil
				return true
			end
		end
	end
end)