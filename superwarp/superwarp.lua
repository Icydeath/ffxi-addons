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
    * Neither the name of Superwarp nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]

_addon.name = 'superwarp'

_addon.author = 'Akaden'

_addon.version = '0.95'

_addon.commands = {'sw','superwarp'}

require('tables')
require('logger')
require('functions')
packets = require('packets')
require('coroutine')
config = require('config')

maps = require('map/maps')

warp_list = T{}
for k, map in pairs(maps) do
	warp_list:append(map.short_name)
end

sub_zone_aliases = {
	['e'] = 'Entrance',
	['ah'] = 'Auction House',
	['auction'] = 'Auction House',
	['mh'] = 'Mog House',
	['mog'] = 'Mog House',
	['house'] = 'Mog House',
	['fs'] = 'Frontier Station',
	['ed'] = 'Enigmatic Device',
}

local defaults = {
	debug = false,
	send_all_delay = 0.4,
	max_retries = 6,
	retry_delay = 2,
	enable_same_zone_teleport = true,
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
	if type(raw) == 'number' then return raw end
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

local function resolve_warp(map_name, zone, sub_zone)
	local closest_zone_name = get_closest_match(maps[map_name], zone)
	if closest_zone_name then
		local zone_map = maps[map_name][closest_zone_name]
		if type(zone_map) == 'table' and not (zone_map.index or zone_map.shortcut) then
			if sub_zone ~= nil then
				local closest_sub_zone_name = get_closest_match(zone_map, sub_zone)
				local sub_zone_map = zone_map[closest_sub_zone_name]
				if sub_zone_map then
					if sub_zone_map.shortcut then
						if zone_map[sub_zone_map.shortcut] and type(zone_map[sub_zone_map.shortcut]) == 'table' then
							debug('found shortcut: '..sub_zone_map.shortcut)
							sub_zone_map = zone_map[sub_zone_map.shortcut]
						end
					end
					if sub_zone_map.index then
						debug('found warp index: '..closest_zone_name..'/'..closest_sub_zone_name..' ('..sub_zone_map.index..')')
						return sub_zone_map, closest_zone_name..' - '..closest_sub_zone_name
					else
						log("Found closest sub-zone, but index is not specified.")
						return nil
					end
				else
					log('Found zone ('..closest_zone_name..'), but not sub zone: "'..sub_zone..'"')
					return nil
				end
			else
				if settings.favorites and settings.favorites[map_name] then
					for fz, fsz in pairs(settings.favorites[map_name]) do
						if get_fuzzy_name(fz) == get_fuzzy_name(closest_zone_name) then
							for sz, sub_zone_map in pairs(zone_map) do
								if sz == tostring(resolve_sub_zone_aliases(fsz)) then
									if sub_zone_map.shortcut then
										if zone_map[sub_zone_map.shortcut] and type(zone_map[sub_zone_map.shortcut]) == 'table' then
											debug ('found shortcut: '..sub_zone_map.shortcut)
											sub_zone_map = zone_map[sub_zone_map.shortcut]
										end
									end
									debug('Found zone ('..closest_zone_name..'), but no sub-zone listed, using favorite ('..sz..')')
									return sub_zone_map, closest_zone_name..' - '..sz.." (F)"
								end
							end
						end
					end
				end
				for sz, sub_zone_map in pairs(zone_map) do
					if sub_zone_map.shortcut then
						if zone_map[sub_zone_map.shortcut] and type(zone_map[sub_zone_map.shortcut]) == 'table' then
							debug ('found shortcut: '..sub_zone_map.shortcut)
							sub_zone_map = zone_map[sub_zone_map.shortcut]
						end
					end
					debug('Found zone ('..closest_zone_name..'), but no sub-zone listed, using first ('..sz..')')
					return sub_zone_map, closest_zone_name..' - '..sz
				end
			end
		else
			debug("Found zone settings. No sub-zones defined.")
			return zone_map, closest_zone_name	
		end
	else
		log('Could not find zone: '..zone)
		return nil
	end
end 

function poke_npc(id, index)
	if id and index then
		debug("poke npc: "..tostring(id)..' '..tostring(index))
		local packet = packets.new('outgoing', 0x01A, {
			["Target"]=id,
			["Target Index"]=index,
			["Category"]=0,
			["Param"]=0,
			["_unknown1"]=0})
		packets.inject(packet)
	end
end

local function distance_sqd(a, b)
	local dx, dy = b.x-a.x, b.y-a.y
	return dy*dy + dx*dx
end

local function find_npc(needles)
	local target_npc = nil
	local distance = nil
	local p = windower.ffxi.get_mob_by_target("me")
	for i, v in pairs(windower.ffxi.get_mob_array()) do
		local d = distance_sqd(windower.ffxi.get_mob_by_index(i), p)
		for i, needle in ipairs(needles) do
			if v.valid_target and (not target_npc or d < distance) and string.find(v.name, needle) then
				target_npc = v
				distance = d
			end
		end
	end
	return target_npc, distance
end

local function reset(quiet)
	local activity = current_activity or last_activity
	if activity then
		if last_packet then
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
		end
		last_activity = activity
		current_activity = nil
		if not quiet then
			log('Should be reset now. Please try again.')
		end
	else
		current_activity = nil
		if not quiet then
			log('No warp scheduled.')
		end
	end
end

local function do_warp(map_name, zone, sub_zone)
	local map = maps[map_name]

	local warp_settings, display_name = resolve_warp(map_name, zone, sub_zone)
	if warp_settings and warp_settings.index then
		local npc, dist = find_npc(map.npc_names.warp)
		if npc and npc.id and npc.index and dist <= 6^2 then
			current_activity = {type=map_name, npc=npc, activity_settings=warp_settings}
			poke_npc(npc.id, npc.index)
			log('Warping via ' .. npc.name .. ' to '..display_name..'.')
		elseif not npc then
			log('No ' .. map.long_name .. ' found!')
		elseif dist > 6^2 then
			log(npc.name .. ' found, but too far!')
		end
	else
		debug("something went wrong")
		state.loop_count = 0
	end
end

local function do_sub_cmd(map_name, sub_cmd)
	local map = maps[map_name]

	local npc, dist = find_npc(map.npc_names[sub_cmd])
	if npc and npc.id and npc.index and dist <= 6^2 then
		current_activity = {type=map_name, sub_cmd=sub_cmd, npc=npc}
		poke_npc(npc.id, npc.index)
	elseif not npc then
		log('No '..map.long_name..' found!')
	elseif distance > 6^2 then
		log(npc.name..' found, but too far!')
	end
end

local function loop_warp(map_name, ...)
	if state.loop_count == nil then 
		state.loop_count = settings.max_retries 
	end

	if state.loop_count > 0 then
		do_warp(map_name, ...)
		state.loop_count = state.loop_count - 1

		loop_warp:schedule(settings.retry_delay, map_name, ...)
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

	for key,map in pairs(maps) do
		if map.short_name == warp then
			local sub_cmd = nil
			if map.sub_commands then
				for sc, fn in pairs(map.sub_commands) do
					if sc:lower() == args[1]:lower() then
						sub_cmd = sc
					end
				end
			end

			if sub_cmd then
				do_sub_cmd(key, sub_cmd)
				return
			else
				local sub_zone_target = nil
				if map.sub_zone_targets then
					local target_candidate = resolve_sub_zone_aliases(args:last())
					if map.sub_zone_targets:contains(target_candidate:lower()) then
						sub_zone_target = target_candidate
						args:remove(args:length())
					end
				end
				state.loop_count = nil
				local zone = windower.ffxi.get_info().zone
				local zone_target = args:concat(' ')
				if map.auto_select_zone and map.auto_select_zone(zone) then
					zone_target = map.auto_select_zone(zone)
				end
				if map.auto_select_sub_zone and map.auto_select_sub_zone(zone) then
					sub_zone_target = map.auto_select_sub_zone(zone)
				end
				loop_warp(key, zone_target, sub_zone_target)
				return
			end
		end
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
	elseif cmd == 'debug' then
		settings.debug = not settings.debug
		log('Debug is now '..tostring(settings.debug))
		settings:save()
	else
		for key, map in pairs(maps) do
			log(map.help_text)
		end
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
			local zone = windower.ffxi.get_info()['zone']
			local map = maps[current_activity.type]
			local built_packets = nil
			if current_activity.sub_cmd then
				debug("building "..current_activity.type.." sub_command packets: "..current_activity.sub_cmd)
				built_packets = map.sub_commands[current_activity.sub_cmd](current_activity.npc, zone, p['Menu ID'], current_activity.activity_settings)
			else
				debug("building "..current_activity.type.." warp packets...")
				built_packets = map.build_warp_packets(current_activity.npc, zone, p['Menu ID'], current_activity.activity_settings, map.move_in_zone and settings.enable_same_zone_teleport)
			end

			if built_packets and type(built_packets) == 'table' then
				for i, packet in ipairs(built_packets) do
					debug("injecting packet "..tostring(i)..' '..(packet.debug_desc or ''))
					packets.inject(packet)
					last_packet = packet
				end

				last_activity = current_activity
				state.loop_count = 0
				current_activity = nil
				return true
			end
		end
	end
end)