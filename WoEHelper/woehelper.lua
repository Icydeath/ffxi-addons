_addon.name = 'WoE Helper'
_addon.author = 'Icy'
_addon.commands = {'woe', 'woehelper'}
_addon.version = '0.0.1'

require('tables')
require('strings')
require('sets')
require('pack')
require('coroutine')
packets = require('packets')
res = require('resources')

valid_zones = {
	[182] = "Walk of Echoes", 
}
valid_npcs = {
	tag = S{'Echo Disseminator'},
	vc = S{'Veridical Conflux #01', 'Veridical Conflux #02', 'Veridical Conflux #03', 'Veridical Conflux #04', 'Veridical Conflux #05', 'Veridical Conflux #06',
		   'Veridical Conflux #07', 'Veridical Conflux #08', 'Veridical Conflux #09', 'Veridical Conflux #10', 'Veridical Conflux #11', 'Veridical Conflux #12',
		   'Veridical Conflux #13', 'Veridical Conflux #14', 'Veridical Conflux #15'},
	tc = S{'Treasure Coffer'}
}
owned_kis = {}

pkt = {}
lastpkt = {}
interacting = false
send_all_delay = 0.8

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
            return (k - 1) * send_all_delay
        end
    end
end

function get_key_items()
	local ki_check = windower.ffxi.get_key_items()
	if table.getn(ki_check) > table.getn(owned_kis) or table.getn(owned_kis) == 0 then --player loading or new KI obtained
		owned_kis = windower.ffxi.get_key_items()
	end
end

-- Returns all key items under the "Temporary Key Items" category
function get_kis_from_resources()
	local woe_kis = {}
	
	for _, ki in pairs(res.key_items) do
		if ki.category == "Temporary Key Items" then
			if string.match(ki.en, "Kupofried's medallion") then
				table.insert(woe_kis, ki.en)
			end
		end
	end

	return woe_kis
end

function has_kupofried_medallion()
	get_key_items()
	
	for _, ki_id in pairs(owned_kis) do --cycle over all KIs owned
		if res.key_items[ki_id] == nil then
			print('Unknown key item ID', ki_id)
		else
			for _, woe_ki in pairs(get_kis_from_resources()) do
				if res.key_items[ki_id].en == woe_ki then
					return true
				end
			end
		end
    end
	
	return false
end

windower.register_event('addon command', function(...)
    local command = {...}
	if #command ~= 0 then
		if command[1] == 'all' or command[1] == 'a' or command[1] == '@all' then
			if command[2] then 
				if command[2] == 'tag' or command[2] == 'ki' or command[2] == 't' then -- example //woe all t
					handle_tag(true)
					return
				elseif command[2] == 'enter' or command[2] == 'vc' or command[2] == 'e' then -- example //woe all enter
					handle_enter(true)
					return
				elseif command[2] == 'coffer' or command[2] == 'chest' or command[2] == 'tc' or command[2] == 'c' then -- example //woe all tc
					handle_chest(true)
					return
				end
			end
			
			handle_tag(true) --example //woe all
			return
		elseif command[1] == 'tag' or command[1] == 'ki' or command[1] == 't' then -- example //woe t
			handle_tag(false)
			return
		elseif command[1] == 'enter' or command[1] == 'vc' or command[1] == 'e' then -- example //woe vc
			handle_enter(false)
			return
		elseif command[1] == 'chest' or command[1] == 'coffer' or command[1] == 'tc' or command[1] == 'c' then -- example //woe tc
			handle_chest(false)
			return
		elseif command[1] == 'reset' then
			reset_me()
			return
		elseif command[1] == 'help' or command[1] == 'h' then
			print_help()
			return
		end
	end
		
	handle_tag(false) -- example //woe
end)

function print_help()
	message('   === COMMANDS ===')
	message('Get KI: //woe [all] ki')
	message('Enter Conflux: //woe [all] enter')
	message('Open Coffer: //woe [all] coffer')
end

function select_enter_option()
	coroutine.sleep(3)
	windower.send_command('setkey down down')
	coroutine.sleep(.2)
	windower.send_command('setkey down up')
	
	coroutine.sleep(.4)
	windower.send_command('setkey down down')
	coroutine.sleep(.2)
	windower.send_command('setkey down up')
	
	coroutine.sleep(.4)
	windower.send_command('setkey enter down')
	coroutine.sleep(.2)
	windower.send_command('setkey enter up')
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

function handle_enter(all)
	if all == true then
		windower.send_ipc_message('vc')

		local delay = get_delay()
		handle_enter:schedule(delay, false)
		return
	end
	
	pkt = validate_npc('vc')
	if pkt then
		interacting = true
		poke_npc(pkt['Target'], pkt['Target Index'])
		select_enter_option()
		interacting = false
	end
end

function handle_chest(all)
	if all == true then
		windower.send_ipc_message('tc')

		local delay = get_delay()
		handle_chest:schedule(delay, false)
		return
	end
	
	pkt = validate_npc('tc')
	if pkt then
		interacting = true
		poke_npc(pkt['Target'], pkt['Target Index'])
		interacting = false
	end
end

function handle_tag(all)
	if all == true then
		windower.send_ipc_message('tag')

		local delay = get_delay()
		handle_tag:schedule(delay, false)
		return
	end
	
	pkt = validate_npc('tag')
	if pkt then
		interacting = true
		poke_npc(pkt['Target'], pkt['Target Index'])
	end
end

function poke_npc(id, index)
	if id and index then
		--debug("poke npc: "..tostring(id)..' '..tostring(index))
		local packet = packets.new('outgoing', 0x01A, {
			["Target"]=id,
			["Target Index"]=index,
			["Category"]=0,
			["Param"]=0,
			["_unknown1"]=0})
		packets.inject(packet)
	end
end

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
	elseif npc_type == 'tag' and has_kupofried_medallion() then
		result = nil
		message('Already have KI.')
	end
	
	return result
end

function message(msg)
    windower.add_to_chat(8, '['.._addon.name..'] '..tostring(msg))
end

windower.register_event('load', function()
	print_help()
end)

-- handle ipc message
windower.register_event('ipc message', function(msg) 
	local delay = get_delay()
	
	--message('received ipc: '..msg..'. executing in '..tostring(delay)..'s.')
	
	if msg == 'vc' then
		handle_enter:schedule(delay, false)
	elseif msg == 'tc' then
		handle_chest:schedule(delay, false)
	elseif msg == 'tag' then
		handle_tag:schedule(delay, false)
	end
end)

windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
	if id == 0x034 or id == 0x032 then
		
		local p = packets.parse('incoming',data)
		if pkt and interacting then
			pkt['Menu ID'] = p['Menu ID']
			if p['Menu ID'] == 1600 then -- Echo Disseminator: for tag
				pkt["Option Index"] = 8
			end
			
			if pkt["Option Index"] then
				-- tag
				if p['Menu ID'] == 1600 and pkt["Option Index"] == 8 then
					local packet = packets.new('outgoing', 0x05B)
					packet["Target"]=pkt["Target"]
					packet["Option Index"]=pkt["Option Index"]
					packet["_unknown1"]=0
					packet["Target Index"]=pkt["Target Index"]
					packet["Automated Message"]=true
					packet["_unknown2"]=0
					packet["Zone"]=pkt['Zone']
					packet["Menu ID"]=pkt['Menu ID']
					packets.inject(packet)
					
					-- close menu after packet is sent
					local packet = packets.new('outgoing', 0x05B)
					packet["Target"]=pkt["Target"]
					packet["Option Index"]=0
					packet["_unknown1"]=16384
					packet["Target Index"]=pkt["Target Index"]
					packet["Automated Message"]=false
					packet["_unknown2"]=0
					packet["Zone"]=pkt['Zone']
					packet["Menu ID"]=pkt['Menu ID']
					packets.inject(packet)
					
					lastpkt = pkt
					pkt = {}
					interacting = false
					return true
				end
			end
		end
		
	end
end)