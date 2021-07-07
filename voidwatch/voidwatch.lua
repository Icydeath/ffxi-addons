_addon.name     = 'voidwatch'
_addon.author   = 'Dabidobido'
_addon.version  = '0.8.12'
_addon.commands = {'vw'}

-- copied lots of code from https://github.com/Muddshuvel/Voidwatch/blob/master/voidwatch.lua

require('logger')
require('coroutine')
packets = require('packets')
res = require('resources')
config = require('config')

interact_distance_square = 5*5

local default_settings = {
	["displacers"] = 5,
	["cobalt"] = 1,
	["rubicund"] = 1,
	["autoloop"] = false,
	["autosell"] = false,
	["autows"] = false,
	["autowstp"] = 1000,
	["WS"] = "Evisceration",
	["scdelay"] = 3,
	["converttocell"] = false,
	["warpwhendone"] = false,
	["trustset"] = "botulus",
	["refreshtrusts"] = true,
}

local settings = config.load(default_settings)

local bags = {
    'inventory',
    'safe',
    'safe2',
    'storage',
    'locker',
    'satchel',
    'sack',
    'case',
    'wardrobe',
    'wardrobe2',
    'wardrobe3',
    'wardrobe4',
}

local pulse_items = {
    [18457] = 'Murasamemaru',
    [18542] = 'Aytanri',
    [18904] = 'Ephemeron',
    [19144] = 'Coruscanti',
    [19145] = 'Asteria',
    [19174] = 'Borealis',
    [19794] = 'Delphinius',
}

local cells = {
    ['Cobalt Cell'] = 3434,
    ['Rubicund Cell'] = 3435,
    ['Phase Displacer'] = 3853,
}

local phase_cell_options = {
	[1] = 17,
	[2] = 33,
	[3] = 49,
	[4] = 65,
 	[5] = 81,
}

local voidwatch_officers = {
	[235] = { option_index = 2, cobalt_unknown1 = 769, rubicund_unknown1 = 770 },
}

local voidwatch_mobs = T{
	"Ig-Alima", "Botulus Rex", "Aello", "Uptala", "Qilin", "Bismarck", "Morta", "Kaggen", "Akvan", "Pil"
}

local mob_stun_moves = {
	["Ig-Alima"] = T{ "Oblivion's Mantle", "Dread Spikes" },
}

local skillchain_opener = T{ "Ayame" }

-- state vars
local wait_for_adrick_0x34 = false
local wait_for_box_0x34 = false
local wait_for_officer_0x34 = false
local wait_for_rift_0x34 = false
local wait_for_box_spawn = false
local wait_for_rift_spawn = false
local wait_for_boss_spawn = false
local use_cleric = false
local started = false
local running = false
local interrupted = false
local buying_cobalt = false
local buying_rubicund = false
local number_to_buy = 0
local sc_opener = nil
local wait_for_sc = nil

local function leader()
    local self = windower.ffxi.get_player()
    local party = windower.ffxi.get_party()
    return (party.alliance_leader == self.id) or ((party.party1_leader == self.id) and (not party.alliance_leader)) or (not party.party1_leader)
end

local function get_mob_by_name(name)
    local mobs = windower.ffxi.get_mob_array()
    for i, mob in pairs(mobs) do
        if (mob.name == name) and (math.sqrt(mob.distance) < 6) then
            return mob
        end
    end
end

local function poke_thing(thing)
    local npc = get_mob_by_name(thing)
    if npc and npc.distance <= interact_distance_square then
        local p = packets.new('outgoing', 0x1a, {
            ['Target'] = npc.id,
            ['Target Index'] = npc.index,
        })
        packets.inject(p)
    end
end

local function poke_rift()
	local npc = get_mob_by_name('Planar Rift')
	if npc and npc.distance <= interact_distance_square then
		log('poke rift')
		wait_for_rift_0x34 = true
		poke_thing('Planar Rift')
	end
end

local function poke_officer()
	local npc = get_mob_by_name('Voidwatch Officer')
	if npc and npc.distance <= interact_distance_square then
		log('poke officer')
		wait_for_officer_0x34 = true
		poke_thing('Voidwatch Officer')
	end
end

local function poke_ardrick()
	local npc = get_mob_by_name('Ardrick')
	if npc and npc.distance <= interact_distance_square then
		log('poke_ardrick')
		wait_for_adrick_0x34 = true
		poke_thing('Ardrick')
	end
end

local function poke_box()
	local npc = get_mob_by_name('Riftworn Pyxis')
	if npc and npc.distance <= interact_distance_square then
		log('poke_box')
		wait_for_box_0x34 = true
		poke_thing('Riftworn Pyxis')
	end
end

local function leader()
    local self = windower.ffxi.get_player()
    local party = windower.ffxi.get_party()
    return (party.alliance_leader == self.id) or ((party.party1_leader == self.id) and (not party.alliance_leader)) or (not party.party1_leader)
end

local function reset(new_id, old_id)
	wait_for_adrick_0x34 = false
	wait_for_box_0x34 = false
	wait_for_officer_0x34 = false
	wait_for_rift_0x34 = false
	wait_for_box_spawn = false
	wait_for_rift_spawn = false
	wait_for_boss_spawn = false
	use_cleric = false
	started = false
	running = false
	interrupted = false
	buying_cobalt = false
	buying_rubicund = false
	number_to_buy = 0
	sc_opener = nil
	wait_for_sc = nil
end

local function trade_cells()
    log('trade cells')
	use_cleric = false
    local npc = get_mob_by_name('Planar Rift')
    if npc and npc.distance <= interact_distance_square then
        local trade = packets.new('outgoing', 0x36, {
            ['Target'] = npc.id,
            ['Target Index'] = npc.index,
        })
        local remaining = {
            cobalt = settings["cobalt"],
            rubicund = settings["rubicund"],
            phase = settings["displacers"],
        }
        local idx = 1
        local n = 0
        local inventory = windower.ffxi.get_items(0)
        for index = 1, inventory.max do
            if (remaining.cobalt > 0) and (inventory[index].id == cells['Cobalt Cell']) then
				if (inventory[index].count >= remaining.cobalt) then
					trade['Item Index %d':format(idx)] = index
					trade['Item Count %d':format(idx)] = 1
					idx = idx + 1
					remaining.cobalt = 0
					n = n + 1
				end
            elseif (remaining.rubicund > 0) and (inventory[index].id == cells['Rubicund Cell']) then
				if (inventory[index].count >= remaining.rubicund) then
					trade['Item Index %d':format(idx)] = index
					trade['Item Count %d':format(idx)] = 1
					idx = idx + 1
					remaining.rubicund = 0
					n = n + 1
				end
            elseif (remaining.phase > 0) and (inventory[index].id == cells['Phase Displacer']) then
                local count = 0
                if (inventory[index].count >= remaining.phase) then
                    count = remaining.phase
                end
                trade['Item Index %d':format(idx)] = index
                trade['Item Count %d':format(idx)] = count
                idx = idx + 1
                remaining.phase = remaining.phase - count
                n = n + count
            end
        end
		if n ~= settings['cobalt'] + settings['rubicund'] + settings['displacers'] then
			log("not enough cells/displacers")
			reset()
			if settings['warpwhendone'] then windower.send_command('input /item "Instant Warp" <me>') end
			return
		end
        trade['Number of Items'] = n
        packets.inject(trade)
		if leader() then
			coroutine.schedule(poke_rift, 1.5)
		end
    end
end

local function sparky_purge()
	log("sparky purge")
	windower.send_command('input //sparky purge')
end

local function start_fight()
	if not interrupted then
		log('start fight')
		local p = packets.new('outgoing', 0x5b, {
				['Target'] = npc_id,
				['Target Index'] = npc_index,
				['Menu ID'] = menu_id,
				['Zone'] = zone,
				['Option Index'] = phase_cell_options[settings["displacers"]],
				['_unknown1'] = 0,
			})
		packets.inject(p)
		local party = windower.ffxi.get_party()
		if skillchain_opener:contains(party.p0.name) then 
			sc_opener = party.p0.mob.id
		elseif skillchain_opener:contains(party.p1.name) then
			sc_opener = party.p1.mob.id
		elseif skillchain_opener:contains(party.p2.name) then
			sc_opener = party.p2.mob.id
		elseif skillchain_opener:contains(party.p3.name) then
			sc_opener = party.p3.mob.id
		elseif skillchain_opener:contains(party.p4.name) then
			sc_opener = party.p4.mob.id
		elseif skillchain_opener:contains(party.p5.name) then
			sc_opener = party.p5.mob.id
		else
			sc_opener = nil
		end
	else
		log('interrupted')
		interrupted = false
	end
end

local function buy_cell()
	log('buying ' .. number_to_buy + 1  .. 'x12 cells')
	local p = packets.new('outgoing', 0x5b, {
            ['Target'] = npc_id,
            ['Target Index'] = npc_index,
			['Menu ID'] = menu_id,
			['Zone'] = zone,
			['Option Index'] = voidwatch_officers[zone].option_index,
			['_unknown1'] = cell_unknown,
		})
	packets.inject(p)
end

local function buy_phase()
	log('buying ' .. number_to_buy .. ' phase displacers')
	local p = packets.new('outgoing', 0x5b, {
            ['Target'] = npc_id,
            ['Target Index'] = npc_index,
			['Menu ID'] = menu_id,
			['Zone'] = zone,
			['Option Index'] = 1
		})
	if number_to_buy > 99 then
		p['_unknown1'] = 99
		number_to_buy = number_to_buy - 99
	else
		p['_unknown1'] = number_to_buy
		number_to_buy = 0
	end
	packets.inject(p)
end

local function parse_menu_data(p)
	npc_id = p['NPC']
	npc_index = p['NPC Index']
	menu_id = p['Menu ID']
	zone = p['Zone']
end

local function get_everything()
	log('get everything')
	wait_for_rift_spawn = true
	local p = packets.new('outgoing', 0x5b, {
            ['Target'] = npc_id,
            ['Target Index'] = npc_index,
			['Menu ID'] = menu_id,
			['Zone'] = zone,
			['Option Index'] = 10,
		})
	packets.inject(p)
	if need_to_relinquish then
		coroutine.schedule(poke_box, 1)
		wait_for_box_0x34 = true
	elseif settings["autosell"] then
		coroutine.schedule(sparky_purge, 1)
	end
	if settings['refreshtrusts'] and windower.ffxi.get_party().party1_count < 6 then
		log('resummon trusts')
		windower.send_command('wait 2; input //tru ' .. settings['trustset'])
	end
end

local function get_pulse(index, convert)
	log('get everything')
	local p = packets.new('outgoing', 0x5b, {
            ['Target'] = npc_id,
            ['Target Index'] = npc_index,
			['Menu ID'] = menu_id,
			['Zone'] = zone,
			['Option Index'] = index 
		})
	if convert then
		p['_unknown1'] = 1
	end
	packets.inject(p)
	coroutine.schedule(poke_box, 1)
end

local function relinquish_everything()
	log('relinquish everything')
	local p = packets.new('outgoing', 0x5b, {
            ['Target'] = npc_id,
            ['Target Index'] = npc_index,
			['Menu ID'] = menu_id,
			['Zone'] = zone,
			['Option Index'] = 9,
		})
	packets.inject(p)
	if settings["autosell"] then
		coroutine.schedule(sparky_purge, 1)
	end
end

local function is_item_rare(id)
    if res.items[id].flags['Rare'] then
        return true
    end
    return false
end

local function have_item(id)
    local items = windower.ffxi.get_items()
    for k, v in pairs(bags) do
        for index = 1, items["max_%s":format(v)] do
            if items[v][index].id == id then
                return true
            end
        end
    end
    return false
end

local function have_temp_item(id)
	local items = windower.ffxi.get_items()
	if items.enabled_temporary then end
	for i = 1, items.temporary.count do
		if items.temporary[i].id == id then
			return true
		end
	end
	return false
end

local function face_target()
	local target = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().target_index or 0)
	local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
	if target then
		local angle = (math.atan2((target.y - self_vector.y), (target.x - self_vector.x))*180/math.pi)*-1
		windower.ffxi.turn((angle):radian())
	end
end

local function parse_incoming(id, data)
	if started then
		if id == 0x34 then
			if wait_for_rift_0x34 then
				interrupted = false
				wait_for_rift_0x34 = false
				wait_for_boss_spawn = true
				local p = packets.parse('incoming', data)
				parse_menu_data(p)
				coroutine.schedule(start_fight, 0.1)
				return true
			elseif wait_for_box_0x34 then
				wait_for_box_0x34 = false
				local p = packets.parse('incoming', data)
				if need_to_relinquish then
					need_to_relinquish = false
					parse_menu_data(p)
					coroutine.schedule(relinquish_everything, 0.2)
					return true
				end
				local got_pulse = false
				for i = 1, 8 do
					local item = p['Menu Parameters']:unpack('I', 1 + (i - 1)*4)
					if not (item == 0) then
						if pulse_items[item] then
							log("got pulse")
							got_pulse = true
							parse_menu_data(p)
							get_pulse(i, settings['converttocell'] or have_item(item))
							return true
						elseif is_item_rare(item) and have_item(item) then
							need_to_relinquish = true
						end
					end
				end
				if not got_pulse then
					parse_menu_data(p)
					coroutine.schedule(get_everything, 1)
					return true
				end
			end
		elseif id == 0x38 and wait_for_box_spawn then
			local p = packets.parse('incoming', data)
			local mob = windower.ffxi.get_mob_by_id(p['Mob'])
			if mob and (mob.name == 'Riftworn Pyxis') then
				if p['Type'] == 'deru' then
					wait_for_sc = nil
					wait_for_box_spawn = false
					coroutine.schedule(poke_box, 2)
				end
			end
		elseif id == 0x5b then
			local p = packets.parse('incoming', data)
			local mob = windower.ffxi.get_mob_by_index(p['Index'])
			if mob and voidwatch_mobs:contains(mob.name) then
				log("mob spawn")
				wait_for_boss_spawn = false
				wait_for_rift_spawn = false
				wait_for_box_spawn = true
				windower.send_command('wait 1; input /target <bt>; wait 0.2; input /attack on')
				coroutine.schedule(face_target, 1.5)
			end
		elseif id == 0xe then
			if settings["autoloop"] and wait_for_rift_spawn then
				local p = packets.parse('incoming', data)
				local npc = windower.ffxi.get_mob_by_id(p['NPC'])
				if npc and npc.name == 'Planar Rift' and npc.distance <= interact_distance_square then
					wait_for_rift_spawn = false
					log('rift spawn')
					coroutine.schedule(trade_cells, 1)
				end
			end
		elseif id == 0x2a then
			local p = packets.parse('incoming', data)
			if p['Message ID'] == 40285 then
				-- param 1 + param 2 = blue, param 3 + param 4 = red
			end
		elseif id == 0x52 then
			local p = packets.parse('incoming', data)
			if p['Type'] == 2 and (wait_for_boss_spawn or wait_for_rift_0x34) then
				interrupted = true
				coroutine.schedule(poke_rift, 0.1)
			end
		end
	end
	if id == 0x34 then
		if wait_for_officer_0x34 then
			wait_for_officer_0x34 = false
			local p = packets.parse('incoming', data)
			parse_menu_data(p)
			if voidwatch_officers[zone] then
				number_to_buy = number_to_buy - 1
				if buying_cobalt then
					if number_to_buy == 0 then buying_cobalt = false end
					cell_unknown = voidwatch_officers[zone].cobalt_unknown1
				elseif buying_rubicund then
					if number_to_buy == 0 then buying_rubicund = false end
					cell_unknown = voidwatch_officers[zone].rubicund_unknown1
				else
					cell_unknown = nil
				end
				if cell_unknown then
					coroutine.schedule(buy_cell, 0.1)
					return true
				else
					log("Didn't set buying_cobalt or buying_rubicund")
				end
			else
				log("No info for voidwatch officer in zone " .. zone)
			end
		elseif wait_for_adrick_0x34 then
			wait_for_adrick_0x34 = false
			local p = packets.parse('incoming', data)
			parse_menu_data(p)
			coroutine.schedule(buy_phase, 0.1)
			return true
		end
	end
end

local function ws()
	local command = 'input /ws "' .. settings['WS'] .. '" <t>'
	if wait_for_sc and windower.ffxi.get_player().main_job == "THF" then
		if windower.ffxi.get_ability_recasts()[66] == 0 then
			command = 'input /ja "Trick Attack" <me>; wait 1; input /ws "' .. settings['WS'] .. '" <t>'
		end
	end
	wait_for_sc = nil
	windower.send_command(command)
end

local function do_ws()
	face_target()
	coroutine.schedule(ws, 0.1)
end

local function parse_action(action)
	if started then
		local mob = windower.ffxi.get_mob_by_id(action.actor_id)
		if mob then
			local player = windower.ffxi.get_player()
			if player.in_combat and player.target_index then
				local player_target = windower.ffxi.get_mob_by_index(player.target_index)
				if player_target then
					if settings['autows'] then
						if mob.id == player_target.id and mob_stun_moves[mob.name] and can_stun then
							local need_to_stun = false
							if action.category == 7 and action.param == 24931 then
								need_to_stun = mob_stun_moves[mob.name]:contains(res.monster_abilities[action.targets[1].actions[1].param].name)
							elseif action.category == 8 and action.param == 24931 then
								need_to_stun = mob_stun_moves[mob.name]:contains(res.spells[action.targets[1].actions[1].param].name)
							end
							if need_to_stun then
								windower.send_command("input /ma Stun <t>")
							elseif use_cleric then
								use_cleric = false
								windower.send_command("input /item \"Cleric's Drink\" <me>")
							elseif player.vitals.tp >= settings["autowstp"] then
								do_ws()
							end
						elseif action.actor_id == player.id and action.category == 1 then
							if running then 
								running = false
								windower.ffxi.run(false)
							end
							if mob_stun_moves[player_target.name] and can_stun then
								if player.vitals.tp >= settings["autowstp"] then
									if player_target.hpp >= 80 or player_target.hpp <= 15 then
										do_ws()
									else
										local recasts = windower.ffxi.get_spell_recasts()
										if recasts[252] > 2 then -- ws if stun got recast
											do_ws()
										end
									end
								end
							else
								if use_cleric then
									use_cleric = false
									windower.send_command("input /item \"Cleric's Drink\" <me>")
								elseif wait_for_sc then
									if os.time() > wait_for_sc and player.vitals.tp >= 1000 then
										do_ws()
									end
								elseif player.vitals.tp >= settings["autowstp"] then
									do_ws()
								end
							end
						elseif sc_opener and action.category == 3 
						and action.targets[1].id == player_target.id then -- someone wsed the mob
							if action.targets[1].actions[1].param > 0 then
								if action.actor_id == sc_opener then
									wait_for_sc = os.time() + settings['scdelay']
								else
									wait_for_sc = nil
								end
							end
						end
					end
				end
			else
				for k,v in pairs(action.targets) do
					if v.id == player.id then -- a mob doing anything to player
						if wait_for_box_spawn then
							log('retry attack boss')
							windower.send_command("wait 2; input /attack on")
							break
						end
					end
				end
			end
		end
	end
end

local function gain_buff(id)
	if started then
		local player = windower.ffxi.get_player()
		if player.in_combat and player.target_index then
			local player_target = windower.ffxi.get_mob_by_index(player.target_index)
			if player_target and mob_stun_moves[player_target.name] then
				if id == 6 then -- silence
					log('using echo drops')
					windower.send_command('input /item "Echo Drops" <me>')
				end
			end
		end
	end
end

local function check_stun()
	local player = windower.ffxi.get_player()
	can_stun = player.sub_job == "BLM" or player.sub_job == "DRK" or player.main_job == "BLM" or player.main_job == "DRK"
end

local function zone_change()
	check_stun()
	reset()
end

local function on_load()
	check_stun()
end

local function parse_action_message(actor_id, target_id, actor_index, target_index, message_id, param_1, param_2, param_3)
	if started then
		if message_id == 5 then -- can't see target
			face_target()
		elseif message_id == 4 or message_id == 78 then -- out of range
			face_target()
			running = true
			windower.ffxi.run(true)
		end
	end
end

local function handle_command(...)
    local args = T{...}
    if args[1] == "t" then
		reset()
		started = true
        trade_cells()
	elseif args[1] == "bc" then
		number_to_buy = 1
		if args[2] then
			number_to_buy = tonumber(args[2])
			if not number_to_buy then number_to_buy = 1 end
		end
		buying_cobalt = true
		for i = 1, number_to_buy do
			coroutine.schedule(poke_officer, (i-1) * 2)
		end		
	elseif args[1] == "br" then
		number_to_buy = 1
		if args[2] then
			number_to_buy = tonumber(args[2])
			if not number_to_buy then number_to_buy = 1 end
		end
		buying_rubicund = true
		for i = 1, number_to_buy do
			coroutine.schedule(poke_officer, (i-1) * 2)
		end
	elseif args[1] == "bp" and args[2] then
		number_to_buy = tonumber(args[2])
		if number_to_buy then
			if number_to_buy > 0 then
				local count = math.ceil(number_to_buy / 99)
				for i = 1, count do
					coroutine.schedule(poke_ardrick, (i - 1) * 2)
				end
			else
				log("Number must be more than 0")
			end
		end
	elseif args[1] == "setp" and args[2] then
		local number = tonumber(args[2])
		if number then
			if number >= 0 and number <= 5 then
				settings["displacers"] = number
				config.save(settings)
				log("Using " .. number .. " of phase displacers each fight.")
			else
				log("Number must be between 0 and 5")
			end
		end
	elseif args[1] == "autosell" then
		settings['autosell'] = not settings['autosell']
		config.save(settings)
		log("Auto Sell changed to " .. tostring(settings['autosell']))
	elseif args[1] == "autoloop" then
		settings['autoloop'] = not settings['autoloop']
		config.save(settings)
		log("Auto Loop changed to " .. tostring(settings['autoloop']))
	elseif args[1] == "autows" then
		settings['autows'] = not settings['autows']
		config.save(settings)
		log("Auto WS changed to " .. tostring(settings['autows']))
	elseif args[1] == "setws" and #args >= 2 then
		local ws_name = ""
		for i = 2, #args do
			ws_name = ws_name .. args[i] .. " "
		end
		ws_name = string.sub(ws_name, 1, #ws_name - 1)
		settings['WS'] = ws_name
		config.save(settings)
		log("WS changed to " .. settings['WS'])
	elseif args[1] == "stop" then
		log('stopping')
		reset()
	elseif args[1] == "converttocell" then
		settings['converttocell'] = not settings['converttocell']
		config.save(settings)
		log("Convert to cell changed to " .. tostring(settings['converttocell']))
	elseif args[1] == "usecleric" then
		use_cleric = have_temp_item(5395)
		log("Using Cleric Drink next opportunity: " .. tostring(use_cleric))
	elseif args[1] == "setc" and args[2] then
		local number = tonumber(args[2])
		if number then
			if number >= 0 and number <= 1 then
				settings["cobalt"] = number
				config.save(settings)
				log("Using " .. number .. " cobalt cell each fight.")
			else
				log("Number must be between 0 and 1")
			end
		end
	elseif args[1] == "setr" and args[2] then
		local number = tonumber(args[2])
		if number then
			if number >= 0 and number <= 1 then
				settings["rubicund"] = number
				config.save(settings)
				log("Using " .. number .. " rubicund cell each fight.")
			else
				log("Number must be between 0 and 1")
			end
		end
	elseif args[1] == "settp" and args[2] then
		local number = tonumber(args[2])
		if number then
			if number >= 1000 and number <= 3000 then
				settings["autowstp"] = number
				config.save(settings)
				log("Auto WS at " .. number .. " TP.")
			else
				log("Number must be between 1000 and 3000")
			end
		end
	elseif args[1] == "warpwhendone" then
		settings['warpwhendone'] = not settings['warpwhendone']
		config.save(settings)
		log("Warp when done changed to " .. tostring(settings['warpwhendone']))
	elseif args[1] == "trustset" and args[2] then
		settings['trustset'] = args[2]
		config.save(settings)
		log("Trust set changed to " .. tostring(settings['trustset']))
	elseif args[1] == "refreshtrusts" then
		settings['refreshtrusts'] = not settings['refreshtrusts']
		config.save(settings)
		log("Refresh trusts changed to " .. tostring(settings['refreshtrusts']))
	elseif args[1] == "scdelay" and args[2] then
		local number = tonumber(args[2])
		if number then
			if number > 1 and number < 10 then
				settings['scdelay'] = number
				config.save(settings)
				log("Skillchain delay changed to " .. tostring(settings['scdelay']))
			else
				log("Number must be between 1 and 10(?)")
			end
		end
    else
        notice('//vw t: trade cells and displacers and start fight')
		notice('//vw bc (number): buy number * 12 cobalt cells from nearby Voidwatch Officer')
		notice('//vw br (number): buy number * 12 rubicund cells from nearby Voidwatch Officer')
		notice('//vw bp (number): buy (number) phase displacers from Ardrick')
		notice('//vw setp (number): set number of phase displacers to use')
		notice('//vw setc (number): set number of cobalt cells to use')
		notice('//vw setr (number): set number of rubicund cells to use')
		notice('//vw autosell: toggles whether to auto sell drops or not. Uses //sparky purge.')
		notice('//vw autoloop: toggles whether to auto loop or not.')
		notice('//vw autows: toggles whether to auto WS or not.')
		notice('//vw converttocell: toggles whether to convert pulse to cells or not.')
		notice('//vw setws: set the WS name to auto WS.')
		notice('//vw settp: set the TP threshold for auto WS.')
		notice('//vw warpwhendone: toggle warping when done. Uses a Scroll of Instant Warp.')
		notice('//vw refreshtrusts: toggles whether to resummon trusts after battle.')
		notice('//vw trustset (name): sets the name of the trust set. Uses Trusts addon to summon trusts.')
		notice('//vw scdelay (number): sets the skillchain delay when a sc_opener is in the party.')
		notice('//vw stop: stops all parsing of incoming packets.')
    end
end

windower.register_event('addon command', handle_command)
windower.register_event('incoming chunk', parse_incoming)
windower.register_event('zone change', zone_change)
windower.register_event('action', parse_action)
windower.register_event('gain buff', gain_buff)
windower.register_event('load', on_load)
windower.register_event('action message', parse_action_message)