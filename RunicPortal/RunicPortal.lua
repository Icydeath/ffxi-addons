--[[
TODOs:
	- after zoning into Nyzul, auto select the floor you wish to reach and port to floor 1.	
]]
_addon.name = 'RunicPortal'
_addon.author = 'Icy'
_addon.commands = {'rp', 'runicportal'}
_addon.version = '0.0.12'

--[[
COMMANDS
	Warping 			> //rp [all]
	Get Sanction 		> //rp [all] sanction (change the default bonus in the settings.xml - regen, refresh, food)
	Get Tag 			> //rp [all] tag
	Get Orders 			> //rp [all] nni
	Get Armband 		> //rp armband
	Open Box 			> //rp box (if you didn't want to use the autobox feature you can use this cmd)
	1F jump 			> //rp small
	Big floor jump	 	> //rp big
	Smart floor jump	> //rp smart (see settings.xml)
	Exit Nyzul 			> //rp exit
	Toggle Auto Boxing 	> //rp autobox
	Total boxes 		> //rp count
	Check KI 			> //rp check
	Reload 				> //rp reload
	Debug Mode 			> //rp debug
	Always Show 		> //rp alwaysshow
	Nyzul HUD  			> //rp hud
	Help 				> //rp help
 
SHORT COMMANDS
 Warping > //rp [a]
 Get Sanction > //rp [a] san
 Get Tag > //rp [a] t
 Get Orders > //rp [a] n
 Get Armband > //rp ab
 1F jump > //rp s
 Big jump > //rp b
 Smart jump > //rp sj
 Exit Nyzul > //rp e
 
MACRO FORM
 Warping > /con rp [all]
 Get Sanction > /con rp [all] san
 Get Tag > /con rp [all] tag
 Get Orders > /con rp [all] nni
 Get Armband > /con rp armband
 1F jump > /con rp small   or for sending to alt  /con send AltsName rp small
 Big jump > /con rp big   or for sending to alt  /con send AltsName rp big
 Smart jump > /con rp smart   or for sending to alt  /con send AltsName rp smart
 Exit Nyzul > /con rp exit   or for sending to alt  /con send AltsName rp exit
]]

require('tables')
require('strings')
require('sets')
require('pack')
require('coroutine')
require('logger')
texts = require('texts')
config = require('config')
packets = require('packets')
res = require('resources')
nms = require('nms')

--[[ SETTINGS ]]
default = {
	autobox = false,
	default_packet_wait_timeout = 5,
	box_despawn_wait = 15,
	lamp_activation_delay = 3,
	sanction_option = 'regen',
	show_nyzul_display = false,
	always_show_display = false,
	debug_mode = false,
	monitor_delay = 1.5,
	running_total = 0,
	smart_jump_to_bosses = true, -- will single jump when within [smart_jump_to_bosses_within] floors of a boss floor
	smart_jump_to_bosses_within = 2,
	smart_jump_farm = false,
	smart_jump_farm_range = { minfloor=40, maxfloor=60 }, -- will single floor jump within these ranges.
	text = {text={size=10}},
}
settings = config.load(default)


--[[ VALIDATION LISTS ]]
valid_zones = {
	[50] = "Aht Urhgan Whitegate", 
	[52] = "Bhaflau Thickets",
	[54] = "Arrapago Reef",
	[61] = "Mount Zhayolm",
	[72] = "Alzadaal Undersea Ruins",
	[77] = "Nyzul Isle",
	[79] = "Caedarva Mire",
}
valid_npcs = {
	rp = S{'Runic Portal'},
	tag = S{'Rytaal'},
	nni = S{'Sorrowful Sage'},
	rot = S{'Rune of Transfer'},
	lamp = S{'Runic Lamp'},
	ab = S{'Shahayl','Nareema','Daswil','Waudeen','Nahshib','Meyaada'},
	box = S{'Armoury Crate'},
	sanction = S{'Asrahd'},
}
valid_sanction_types = {
	["regen"] = '16',
	["refresh"] = '32',
	["food"] = '48',
}
boss_floors = {20,40,60,80,100}

--[[ FLAGS & TRACKING]]
monitor = false
interacting = false

send_all_delay = 0.8
nexttime = os.clock()

pkt = {}
lastpkt = {}
examined_crates = {}
crates_to_remove = {}
total_boxes_poked = 0
cur_zone = windower.ffxi.get_info().zone
cur_floor = 0

--[[ FIX INVALID SETTINGS IF THEY EXIST ]]
if settings.monitor_delay and tonumber(settings.monitor_delay) then del = tonumber(settings.monitor_delay) else del = 2 end

if not valid_sanction_types[settings.sanction_option] then
	message('Invalid value for "sanction_option" - Reverting it back to "regen". Valid entries are: regen, refresh, food')
    settings.sanction_option = 'regen'
	settings:save()
end

if settings.default_packet_wait_timeout < 1 then
    settings.default_packet_wait_timeout = 1
end

display_box = function()
    local str
    str = ' RunicPortal ' .. _addon.version .. '\n'
	str = str..'-------------------------\n'
	str = str..' Sanction: '..settings.sanction_option..' \n'
	str = str..' Autobox: '..tostring(settings.autobox)..' \n'
	str = str..' Monitoring: '..tostring(monitor)..' \n'
	str = str..'-------------------------\n'
	local sj_within = settings.smart_jump_to_bosses and ' ('..settings.smart_jump_to_bosses_within..')' or ''
	str = str..' Smart Jump to Bosses: '..tostring(settings.smart_jump_to_bosses)..sj_within..' \n'
	str = str..' Smart Jump Farm Min: '..settings.smart_jump_farm_range.minfloor..(settings.smart_jump_farm and ' (ON)' or ' (OFF)')..' \n'
	str = str..' Smart Jump Farm Max: '..settings.smart_jump_farm_range.maxfloor..' \n'
	str = str..'-------------------------\n'
	str = str..' Boxes Opened: ' .. tostring(total_boxes_poked) .. ' \n'
	str = str..' Running Total: ' .. tostring(settings.running_total) .. ' \n'
	
    if monitor and settings.debug_mode then
		str = str..'-------------------------\n'
		str = str..' Examined Crates \n'
		
		if examined_crates then
			for bid,bidx in pairs(examined_crates) do
				str = str .. tostring(bid) .. ' (' .. tostring(bidx) .. ') \n'
			end
		end
		
		str = str..' Boxes to be removed \n'
		if crates_to_remove then
			local ntime = os.clock()
			for rid,rtime in pairs(crates_to_remove) do
				local tr = rtime - ntime 
				str = str .. tostring(rid) .. ' in ' .. string.format("%.1f", tr) .. '\n'
			end
		end	
	end
	
    return str
end
box_status = texts.new(display_box(),settings.text,settings)

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

function has_keyitem(ki_type)
	if not ki_type then 
		ki_type = 'assault' 
	end
	
	local result = false
	local res_keyitems = res.key_items
	local owned_kis = windower.ffxi.get_key_items()
	
	for _, ki_id in pairs(owned_kis) do --cycle over all owned KIs
		local ki = res_keyitems[ki_id]
		if ki then
			if ki.category == "Temporary Key Items" then
				if ki_type == 'tag' and string.match(ki.en, "I.D. tag") then
					result = true
					break
				elseif ki_type == 'armband' and string.match(ki.en, "Assault armband") then
					result = true
					break
				elseif ki_type == 'assault' and string.match(ki.en, "Assault orders") then
					result = true
					break
				end
			end
		end
    end
	
	res_keyitems = nil
	owned_kis = nil
	return result
end

function print_help()
	message('COMMANDS\n'..
	[[
		 Warping 			> //rp [all]
		 Get Sanction 		> //rp [all] sanction (change the default bonus in the settings.xml - regen, refresh, food)
		 Get Tag 			> //rp [all] tag
		 Get Orders 		> //rp [all] nni
		 Get Armband 		> //rp armband
		 Open Box 			> //rp box (if you didn't want to use the autobox feature you can use this cmd)
		 1F jump 			> //rp small
		 Big floor jump 	> //rp big
		 Smart jump			> //rp smart [farm_min_floor farm_max_floor] | [farm_min farm_max within_boss]
		 Exit Nyzul 		> //rp exit
		 Toggle Auto Boxing > //rp autobox
		 Total boxes 		> //rp count
		 Check KI 			> //rp check
		 Reload 			> //rp reload
		 Debug Mode 		> //rp debug
		 Always Show 		> //rp alwaysshow
		 Nyzul HUD  		> //rp hud
		 Help 				> //rp help]])
end

windower.register_event('addon command', function(...)
    local command = {...}
	if #command ~= 0 then
		if command[1] == 'shownms' then
			for i,v in pairs(nms) do
				message(v)
			end
			return
			
		elseif command[1] == 'help' or command[1] == 'h' then
			print_help()
			return
		
		elseif command[1] == 'count' or command[1] == 'cnt' then
			message('Current/Previous boxes opened: ' .. tostring(total_boxes_poked))
			message('Running total of boxes opened: ' .. tostring(settings.running_total))
			return
			
		elseif command[1] == 'debug' or command[1] == 'dm' then
			settings.debug_mode = not settings.debug_mode
			settings:save()
			box_status:text(display_box())
			message('Debug mode: '..tostring(settings.debug_mode))
			return
		
		elseif command[1] == 'hud' or command[1] == 'display' or command[1] == 'snd' or command[1] == 'show' then
			settings.show_nyzul_display = not settings.show_nyzul_display
			settings:save()
			if settings.show_nyzul_display then box_status:show() else box_status:hide() end
			box_status:text(display_box())
			return
			
		elseif command[1] == 'check' then
			if has_keyitem('assault') then
				message('You have Assault Orders KI')
				if has_keyitem('armband') then 
					message('You have an armband') 
				else
					message('No armband found...') 
				end
			elseif has_keyitem('tag') then 
				message('You have a Tag')
			else
				message('No Assault Orders KI or I.D. Tag KI found...')
			end
			message('Current/Previous boxes opened: ' .. tostring(total_boxes_poked))
			message('Running total of boxes opened: ' .. tostring(settings.running_total))
			return
			
		elseif command[1] == 'all' or command[1] == 'a' or command[1] == '@all' then
			if command[2] then 
				if command[2] == 'tag' or command[2] == 't' then
					handle_tag(true)
					return
				elseif command[2] == 'nni' or command[2] == 'n' then
					handle_nni(true)
					return
				elseif command[2] == 'sanction' or command[2] == 'san' then
					handle_sanction(true)
					return
				end
			end
			
			handle_warp(true)
			return
			
		elseif command[1] == 'tag' or command[1] == 't' then
			handle_tag(false)
			return
		
		elseif command[1] == 'nni' or command[1] == 'n' then
			handle_nni(false)
			return

		elseif command[1] == 'sanction' or command[1] == 'san' then
			handle_sanction(false)
			return
		
		elseif command[1] == 'armband' or command[1] == 'ab' then
			handle_armband(false)
			return
			
		elseif command[1] == 'box' or command[1] == 'crate' or command[1] == 'chest' then
			if settings.autobox or (command[2] and command[2] == 'clear' or command[2] == 'c') then 
				clear_crates()
				message('Tracked boxes list cleared.')
			end
			handle_box()
			return
		
		elseif command[1] == 'farm' or command[1] == 'f' then
			settings.smart_jump_farm = not settings.smart_jump_farm
			message('Floor farming is now '..(settings.smart_jump_farm and 'enabled.' or 'disabled.'))
			return
			
		elseif command[1] == 'smart' or command[1] == 'sj' then
			if command[2] and tonumber(command[2]) and command[3] and tonumber(command[3]) then -- ie: //rp sj 20 40
				settings.smart_jump_farm_range.minfloor = tonumber(command[2])
				settings.smart_jump_farm_range.maxfloor = tonumber(command[3])
				if command[4] and tonumber(command[4]) then -- ie: //rp sj 20 40 2 or //send AltName rp sj 20 40 2
					settings.smart_jump_to_bosses_within = tonumber(command[4])
					settings.smart_jump_to_bosses = true
				end
			end
			handle_smartjump()
			return
			
		elseif command[1] == 'small' or command[1] == 's' then
			handle_nnijump(5)
			return
		
		elseif command[1] == 'big' or command[1] == 'b' then
			handle_nnijump(6)
			return
		
		elseif command[1] == 'exit' or command[1] == 'e' then
			handle_nnijump(1)
			return
		
		elseif command[1] == 'lamp' or command[1] == 'l' then
			if command[2] then
				if command[2] == 'order' or command[2] == 'o' then
					handle_lamp(2)
				elseif command[2] == 'same' or command[2] == 'st' or command[2] == 's' then
					handle_lamp(1)
				end
			end
			return
		
		elseif command[1] == 'reset' then
			reset_me()
			return
			
		elseif command[1] == 'reload' then
			windower.send_command('lua r runicportal')
			return
			
		elseif command[1] == 'save' then
			settings:save()
			message('Settings saved.')
			return
			
		elseif command[1] == 'autobox' then
			settings.autobox = not settings.autobox
			settings:save()
			box_status:text(display_box())
			--message('Autobox: '..tostring(settings.autobox))
			return
			
		elseif command[1] == 'showalways' or command[1] == 'alwaysshow' or command[1] == 'asd' then
			settings.always_show_display = not settings.always_show_display
			settings:save()
			box_status:text(display_box())
			if settings.always_show_display then box_status:show() else box_status:hide() end
			return
			
		end
	end
	
	handle_warp(false)
end)

function reset_me()
	if lastpkt and lastpkt['Target'] and lastpkt['Target Index'] and lastpkt['Menu ID'] then
		general_release()
		release(lastpkt['Menu ID'])
		
		local packet = packets.new('outgoing', 0x05B)
		packet["Target"]=lastpkt['Target']
		packet["Option Index"]="0"
		packet["_unknown1"]="16384"
		packet["Target Index"]=lastpkt['Target Index']
		packet["Automated Message"]=false
		packet["_unknown2"]=0
		packet["Zone"]=windower.ffxi.get_info()['zone']
		packet["Menu ID"]=lastpkt['Menu ID']
		packets.inject(packet)
	else
		general_release()
	end
	
	pkt = nil
	lastpkt = nil
	interacting = false
	
	message('Should be reset now. Please try again. If still locked, try a second reset.')
end

-- Thanks to Ivaar for these two:
function general_release()
	windower.packets.inject_incoming(0x052, string.char(0,0,0,0,0,0,0,0))
    windower.packets.inject_incoming(0x052, string.char(0,0,0,0,1,0,0,0))
end
function release(menu_id)
    windower.packets.inject_incoming(0x052, 'ICHC':pack(0,2,menu_id,0))
    windower.packets.inject_incoming(0x052, string.char(0,0,0,0,1,0,0,0)) -- likely not needed
end

reenable_autobox = false
function handle_lamp(oindex)	
	pkt = validate_npc('lamp')
	if pkt then
		message("Activating lamp: "..pkt['Target Index'])
		pkt['Option Index'] = oindex -- 2 is for order, 1 is for same time
		if settings.autobox then
			settings.autobox = false
			settings.monitor = false
			reenable_autobox = true
		end
		
		interacting = true
		poke_npc(pkt['Target'], pkt['Target Index'])
	end
end

function handle_nnijump(oindex)	
	pkt = validate_npc('rot')
	if pkt then
		pkt['Option Index'] = oindex -- 5 is small, 6 is big, 1 is exit(note: exit will soft lock if floor not completed)
		if settings.autobox then
			settings.autobox = false
			settings.monitor = false
			reenable_autobox = true
		end
		
		interacting = true
		poke_npc(pkt['Target'], pkt['Target Index'])
	end
end

function handle_smartjump()
	local option_index = 6 -- default to random floor jump
	
	if cur_floor == 100 then
		option_index = 1 -- exit nyzul
		
	elseif cur_floor == 99 then
		option_index = 5 -- 1 floor jump
		
	elseif settings.smart_jump_farm and settings.smart_jump_farm_range and settings.smart_jump_farm_range.minfloor and settings.smart_jump_farm_range.maxfloor
	  and cur_floor >= tonumber(settings.smart_jump_farm_range.minfloor)
	  and cur_floor < tonumber(settings.smart_jump_farm_range.maxfloor) then
		option_index = 5 -- 1 floor jump
		
	elseif settings.smart_jump_to_bosses then
		for i,boss_floor in pairs(boss_floors) do
			if boss_floor > cur_floor then
				local diff = boss_floor - cur_floor
				if diff <= settings.smart_jump_to_bosses_within then
					option_index = 5
				end
			end
		end
	end
	
	handle_nnijump(option_index)
end

function handle_nni(all)
	if all == true then
		windower.send_ipc_message('nni')

		local delay = get_delay()
		handle_nni:schedule(delay, false)
		return
	end
	
	pkt = validate_npc('nni')
	if pkt then
		interacting = true
		poke_npc(pkt['Target'], pkt['Target Index'])
	end
end

function handle_sanction(all)
	if all == true then
		windower.send_ipc_message('sanction')

		local delay = get_delay()
		handle_sanction:schedule(delay, false)
		return
	end
	
	pkt = validate_npc('sanction')
	if pkt then
		interacting = true
		pkt['Option Index'] = tonumber(valid_sanction_types[settings.sanction_option])
		message('Getting '..settings.sanction_option..' sanction from NPC.')
		poke_npc(pkt['Target'], pkt['Target Index'])
	end
end

function handle_armband(all)	
	pkt = validate_npc('ab')
	if pkt then
		interacting = true
		poke_npc(pkt['Target'], pkt['Target Index'])
	end
end

function handle_box()
	pkt = validate_npc('box')
	if pkt then
		interacting = true
		message('Poking box: '..pkt['Target']..' ('..pkt['Target Index']..')')
		
		local now = os.clock()
		examined_crates[pkt['Target']] = pkt['Target Index']
		crates_to_remove[pkt['Target']] = now + settings.box_despawn_wait
		total_boxes_poked = total_boxes_poked + 1
		settings.running_total = settings.running_total + 1
		poke_npc(pkt['Target'], pkt['Target Index'])
	end
end

function remove_crates() 
	local now = os.clock()
	for cid, ctime in pairs(crates_to_remove) do
		if examined_crates[cid] then
			if crates_to_remove[cid] <= now then
				examined_crates[cid] = nil
				crates_to_remove[cid] = nil
				--message('removing crate from list (despawned)')
			end
		else
			crates_to_remove[cid] = nil
		end
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

function handle_warp(all)
	if all == true then
		windower.send_ipc_message('rp')

		local delay = get_delay()
		handle_warp:schedule(delay, false)
		return
	end
	
	pkt = validate_npc('rp')
	if pkt then
		interacting = true
		poke_npc(pkt['Target'], pkt['Target Index'])
	else
		message('The portal is either to far away, or you are not in the correct zone, or you dont have an assault ki')
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
		
		coroutine.sleep(settings.default_packet_wait_timeout)
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
				if npc_type == 'box' and not examined_crates[v['id']] then
					-- 966=brown, 965=blue
					local isbrown = false
					for x,mid in ipairs(v.models) do
						if mid == 966 then
							isbrown = true
						end
					end
					if isbrown then
						result['Target Index'] = i
						result['Target'] = v['id']
					end
				elseif npc_type ~= 'box' then
					result['Target Index'] = i
					result['Target'] = v['id']
				end
			end
		end
	end
	
	if not result['Zone'] or not result['Target'] or not result['Target Index'] then
		result = nil
	elseif zone == 50 then 
		if npc_type == 'nni' or npc_type == 'Sorrowful Sage' then
			if has_keyitem('assault') then
				result = nil
				message('Aborted! You already have assault orders...')
			end
		elseif npc_type == 'tag' or npc_type == 'Rytaal' then
			if has_keyitem('tag') then
				result = nil
				message('Aborted! You already have a tag...')
			end
		end
	elseif zone == 72 then 
		if npc_type == 'ab' or npc_type == 'Shahayl' then
			if has_keyitem('armband') then
				result = nil
				message('Aborted! You already have an armband...')
			end
		end
	end
	
	return result
end

function prerender()
	if not monitor then return end
	
	local curtime = os.clock()
    if nexttime + del <= curtime then
		nexttime = curtime
		remove_crates()
		if settings.autobox then handle_box() end
	end
	
	box_status:text(display_box())
end

function zone_change(new, old)
	clear_crates()
	local zone = new
	if not zone then
		zone = windower.ffxi.get_info().zone
	end
	cur_zone = zone
	
	if cur_zone == 77 then
		total_boxes_poked = 0
		
		monitor = true
		if not user_events then
			user_events = {}
			user_events.prerender = windower.register_event('prerender', prerender)
		end
		
		if settings.show_nyzul_display or settings.always_show_display then
			box_status:show()
		end
	else
		if old and old == 77 then -- if we just came from nyzul
			cur_floor = 0
			settings:save()
			monitor = false
			if user_events then
				for _,event in pairs(user_events) do
					windower.unregister_event(event)
				end
				user_events = nil
			end
			
			if settings.always_show_display then box_status:show() else box_status:hide() end
		end
	end
end

function clear_crates()
	if examined_crates then
		for id,val in pairs(examined_crates) do
			examined_crates[id] = nil
		end
	end

	if crates_to_remove then
		for id,val in pairs(crates_to_remove) do
			crates_to_remove[id] = nil
		end
	end
end

function message(msg)
    windower.add_to_chat(8, '[RunicPortal] '..tostring(msg))
end

-- handle ipc message
windower.register_event('ipc message', function(msg) 
	local delay = get_delay()
	
	--message('received ipc: '..msg..'. executing in '..tostring(delay)..'s.')
	
	if msg == 'tag' then
		handle_tag:schedule(delay, false)
	elseif msg == 'nni' then
		handle_nni:schedule(delay, false)
	elseif msg == 'sanction' then
		handle_sanction:schedule(delay, false)
	elseif msg == 'rp' then
		handle_warp:schedule(delay, false)
	else
		message('Error: unknown ipc command...')
	end
end)

windower.register_event('zone change','load','login', zone_change)
windower.register_event('unload','logout', function()
	settings:save()
end)

option_index_by_menuid = {
	-- Assault Zone to WG
	[109] = 1, -- couple zones share this menu id
	[134] = 1, [131] = 1, -- Caedarva Mire
	
	-- WG to Assault Zone
	[120] = 1, [121] = 1, [122] = 1, [123] = 1, [124] = 1, [125] = 1,
	
	-- Armbands
	[412] = 1, [512] = 1, [209] = 1, [223] = 1, [148] = 1, [149] = 1,
	
	-- Nyzul lamp stuff
	[125] = 1, 
	[118] = 1,
	[117] = 1,
	[268] = 1,
	[278] = 833,
}

windower.register_event('incoming text', function(original, modified, original_mode, modified_mode, blocked)
	if cur_zone == 77 then
		if(windower.wc_match(original, "*Welcome to Floor*")) then
			split_original = original:split(' ')
			local floorNum = split_original[table.getn(split_original)]:split('.')[1]
			cur_floor = floorNum and tonumber(floorNum)
		end
	end
end)

windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
	if id == 0x034 or id == 0x032 then
		local p = packets.parse('incoming',data)
		if p and pkt and interacting then
		
			if settings.autobox and p['Menu ID'] and p['Zone'] and p['Zone'] == 77 and p['Menu ID'] == 95 and p['_unknown1'] == 8 then
				clear_crates() -- clear opened boxes on floor jumps
				-- re-enable autobox. Which was disable it for lamp activations or floor jump.
				if reenable_autobox then
					reenable_autobox = false
					settings.autobox = true
					settings.monitor = true
				end
			else
				pkt['Menu ID'] = p['Menu ID']
				
				if pkt['Menu ID'] ~= 201 and pkt["Option Index"] == nil and option_index_by_menuid[pkt['Menu ID']] then
					pkt["Option Index"] = option_index_by_menuid[pkt['Menu ID']]
				end
				
				if pkt["Option Index"] then
					if pkt['Zone'] == 77 and (pkt['Menu ID'] == 201 or pkt['Menu ID'] == 3) then -- transfer / lamp auto msg.
						local packet = packets.new('outgoing', 0x05B)
						packet["Target"]=pkt["Target"]
						packet["Option Index"]=0
						packet["_unknown1"]=0
						packet["Target Index"]=pkt["Target Index"]
						packet["Automated Message"]=true
						packet["_unknown2"]=0
						packet["Zone"]=pkt['Zone']
						packet["Menu ID"]=pkt['Menu ID']
						packets.inject(packet)
					end	
					
					-- main packet formed by validate_npc
					local packet = packets.new('outgoing', 0x05B)
					packet["Target"]=pkt["Target"]
					packet["Option Index"]=pkt["Option Index"]
					packet["_unknown1"]=0
					packet["Target Index"]=pkt["Target Index"]
					packet["Automated Message"]=false
					packet["_unknown2"]=0
					packet["Zone"]=pkt['Zone']
					packet["Menu ID"]=pkt['Menu ID']
					packets.inject(packet)
					
					if pkt["Option Index"] == 1 and pkt['Menu ID'] == 201 then -- exit nyzul, confirm with 'yes' packet
						local packet = packets.new('outgoing', 0x05B)
						packet["Target"]=pkt["Target"]
						packet["Option Index"]=pkt["Option Index"]
						packet["_unknown1"]=0
						packet["Target Index"]=pkt["Target Index"]
						packet["Automated Message"]=false
						packet["_unknown2"]=0
						packet["Zone"]=pkt['Zone']
						packet["Menu ID"]=pkt['Menu ID']
						packets.inject(packet)
					end
					
					if pkt['Menu ID'] == 268 or pkt['Menu ID'] == 278 or pkt['Menu ID'] == 412 then -- update packet for KI's
						-- send update packet
						packet = packets.new('outgoing', 0x016, {["Target Index"]=pkt['me'],})
						packets.inject(packet)
					end
					
					lastpkt = pkt
					pkt = {}
					interacting = false
					
					return true
				end
			end
			
		end
		
	end
end)