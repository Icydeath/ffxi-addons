_addon.author   = 'Erupt, modified by icy'
_addon.version  = '2.06'
_addon.commands = {'Azi'}

require 'logger'
require 'strings'
require('coroutine')
packets = require('packets')
res = require('resources')
config = require('config')

--Defaults
nexttime = os.clock()
delay = 0
busy = false
inside = false
running = false
fighting = false
waiting = false
tp = false
affi = false
pause = 'on'

--[[
	This script is a little different from the Quetz script.  You will need to set your home point
	in Qufim Island in order for this to work.  This acts as the Dimentional Teleport ring here.
]]

--Set your trusts here, and under trustx_short put the name as it appears in the party list or when they speak in party chat

-- Default Settings
default = {
	azi_x = -11.00,
	azi_y = 37.50,
	teleport_ring = "Warp Ring",
	start_fight_commands = 'gs c set AutoBuffMode On;gs c set AutoWSMode On',
	end_fight_commands = 'gs c set AutoBuffMode Off;gs c set AutoWSMode Off',
	trust1 = 'Koru-Moru',
	trust1_short = 'Koru Moru',
	trust2 = 'Selh\'teus',
	trust2_short = 'Selh\'teus',
	trust3 = 'Qultada',
	trust3_short = 'Qultada',
	trust4 = 'Apururu (UC)',
	trust4_short = 'Apururu',
	trust5 = 'Ulmia',
	trust5_short = 'Ulmia',
}
settings = config.load(default)

windower.register_event('prerender', function()
	local curtime = os.clock()
	local waste = math.random()
	if nexttime + delay <= curtime then
		nexttime = curtime
		delay = 0.2
		local player = windower.ffxi.get_player()
		local me = windower.ffxi.get_mob_by_target('me')
		local info = windower.ffxi.get_info()
		local zone = res.zones[info.zone].name
		
		if pause == 'on' then return end
		
		if zone == 'Qufim Island' then	--If we're in the areas with the crags, enter escha
			enterZitah()
		elseif zone == 'Escha - Zi\'Tah' then	--If we're in escha, check if we're inside the arena already
			affi = windower.ffxi.get_mob_by_name('Affi')
			if me and me.x < -100 then		--Check coordinates to see if we're inside since distance is fucky when using warp packets
				inside = false
			else
				inside = true
			end
			if not inside then								--If not inside, enter the arena
				enterArena()
			elseif inside then
				if player.status == 1 or player.in_combat then		--If we're in combat, engage and fight it
					waiting = true
					fight()
				elseif not waiting then										--Move into position when inside the arena and get ready to fight
					windower.send_command('setkey escape down;wait 1;setkey escape up')
					moveToLocation()
				elseif waiting then
					fight()
				end
			end
		end
	end
end)

function getEquippedItem(slot_name)
	local inventory = windower.ffxi.get_items()
	local equipment = inventory['equipment'];
	local item_id = windower.ffxi.get_items(equipment[string.format('%s_bag', slot_name)], equipment[slot_name]).id
	return res.items:with('id', item_id).en
end

function summonTrust()		--Return the name of your trusts that may have died/aren't in your party currently
	local player = windower.ffxi.get_player()
	local party = windower.ffxi.get_party()
	if party.p1 and party.party1_leader ~= player.id then 
		return false -- we are not leader so return false
	end
	if party.p5 then -- party is full so return false
		return false
	end
	
	local spellrecasts = windower.ffxi.get_spell_recasts()
	local checkt1 = false
	local checkt2 = false
	local checkt3 = false
	local checkt4 = false
	local checkt5 = false
	
	
	for i, v in pairs(party) do
		if string.match(i, 'p[0-5]') and v.mob and (v.mob.name == settings.trust1 or v.mob.name == settings.trust1_short) then
			checkt1 = true
		elseif string.match(i, 'p[0-5]') and v.mob and (v.mob.name == settings.trust2 or v.mob.name == settings.trust2_short) then
			checkt2 = true
		elseif string.match(i, 'p[0-5]') and v.mob and (v.mob.name == settings.trust3 or v.mob.name == settings.trust3_short) then
			checkt3 = true
		elseif string.match(i, 'p[0-5]') and v.mob and (v.mob.name == settings.trust4 or v.mob.name == settings.trust4_short) then
			checkt4 = true
		elseif string.match(i, 'p[0-5]') and v.mob and (v.mob.name == settings.trust5 or v.mob.name == settings.trust5_short) then
			checkt5 = true
		end
	end
	
	if settings.trust1 ~= '' and spellrecasts[res.spells:with('en', settings.trust1).recast_id] == 0 and not checkt1 then
		return settings.trust1
	elseif settings.trust2 ~= '' and spellrecasts[res.spells:with('en', settings.trust2).recast_id] == 0 and not checkt2 then
		return settings.trust2
	elseif settings.trust3 ~= '' and spellrecasts[res.spells:with('en', settings.trust3).recast_id] == 0 and not checkt3 then
		return settings.trust3
	elseif settings.trust4 ~= '' and spellrecasts[res.spells:with('en', settings.trust4).recast_id] == 0 and not checkt4 then
		return settings.trust4
	elseif settings.trust5 ~= '' and spellrecasts[res.spells:with('en', settings.trust5).recast_id] == 0 and not checkt5 then
		return settings.trust5
	else
		return false
	end
end

function isBuffActive(id)
	local self = windower.ffxi.get_player()
	for k,v in pairs( self.buffs ) do
		if (v == id) then -- check for buff
			return true
		end	
	end
	return false
end

function enterZitah()			--Take the Undulating Confluence
	local me = windower.ffxi.get_mob_by_target('me')
	tp = windower.ffxi.get_mob_by_name('Undulating Confluence')
	if tp and math.sqrt(tp.distance) > 6 and not running then
		log('Entering Escha - Zi\'Tah')
		windower.ffxi.run(tp.x - me.x, tp.y - me.y)
		running = true
	elseif tp and math.sqrt(tp.distance) <= 6 then
		windower.ffxi.run(false)
		running = false
		local p = packets.new('outgoing', 0x01A, {
            ['Target'] = tp.id,
            ['Target Index'] = tp.index,
        })
        packets.inject(p)
		busy = true
		inside = true
	end
end

function enterArena()
	local me = windower.ffxi.get_mob_by_target('me')
	affi = windower.ffxi.get_mob_by_name('Affi')
	if affi and math.sqrt(affi.distance) > 3 and not running then		-- we need to run to affi
		log('Entering Escha - Zi\'Tah')
		windower.ffxi.run(affi.x - me.x, affi.y - me.y)
		running = true
	elseif affi and math.sqrt(affi.distance) <= 3 then
		windower.ffxi.run(false)
		running = false
        local p = packets.new('outgoing', 0x01A, {
            ['Target'] = affi.id,
            ['Target Index'] = affi.index,
        })
		busy = true
		packets.inject(p)
		
		windower.send_command('setkey escape down;wait 0.5;setkey escape up')	--sometimes the menu gets stuck open when getting elvorseal, this hits escape to fix it
		delay = 5
    end
end

function randomFloat(min, max)
    return min + math.random() * (max - min);
end

function findWaitPosition()
	wait_x = settings.azi_x + math.random(0.10,1.5)
	wait_y = settings.azi_y + math.random(0.10,1.5)
end

findWaitPosition()

function moveToLocation()
	local me = windower.ffxi.get_mob_by_target('me')
	if isBuffActive(603) then
		windower.send_command('setkey escape down;wait 1;setkey escape up')							--To escape out of the menu with affi
		if math.abs(wait_x - me.x) > 2 and math.abs(wait_y - me.y) > 2 and not waiting then		--Run to location
			windower.ffxi.run(wait_x - me.x, wait_y - me.y)
		elseif math.abs(wait_x - me.x) <= 2 and math.abs(wait_y - me.y) <= 2 and not waiting then		--We're here, so stop
			windower.ffxi.run(false)
			waiting = true
			delay = 3
			findWaitPosition()
		end
	else
		fight()
	end
end

function fight()
	local azi = windower.ffxi.get_mob_by_name('Azi Dahaka')
	local player = windower.ffxi.get_player()
	local party = windower.ffxi.get_party()
	local partymembers = party.p5 or false
	if isBuffActive(603) then	
		if azi.hpp > 0 then
			fighting = true
		else
			fighting = false
		end
		if waiting and player.status == 0 then										--Summon trusts while waiting
			if summonTrust() ~= false and not isBuffActive(6) and not isBuffActive(2) then
				windower.send_command('input /ma "'..summonTrust()..'" <me>')
			end
			delay = 3
		end

		if player.status == 0 and isBuffActive(603) and fighting then			--If not engaged then engage
			engagenaga = packets.new('outgoing', 0x01A, {
				['Target'] = azi.id,
				['Target Index'] = azi.index,
				['Category'] = 0x02,
			})
			packets.inject(engagenaga)
			delay = 1
		elseif math.sqrt(azi.distance) > 7 and player.status == 1 and fighting then		--Turn and run to azi
			local target = windower.ffxi.get_mob_by_index(player.target_index or 0)
			local self_vector = windower.ffxi.get_mob_by_index(player.index or 0)
			local angle = (math.atan2((target.y - self_vector.y), (target.x - self_vector.x))*180/math.pi)*-1
			windower.ffxi.turn((angle):radian())
			windower.ffxi.run(true)
		elseif math.sqrt(azi.distance) <= 7 and player.status == 1 and fighting and not partymembers then		--Summon trusts when they die
			windower.ffxi.run(false)
			if summonTrust() ~= false and not isBuffActive(6) and not isBuffActive(2) then
				windower.send_command('input /ma "'..summonTrust()..'" <me>')
			end
			delay = 3
		end
	elseif not isBuffActive(603) and not isBuffActive(2) then			--If our elvorseal is gone, try to take a raise if we're dead, or release if we don't have one. teleport ring out
		windower.ffxi.run(false)
		if player.status > 1 then
			delay = 30
			windower.send_command('wait 10;setkey enter down;wait 1;setkey enter up;wait 3;setkey left down;wait 1;setkey left up;wait 3;setkey enter down;wait 1;setkey enter up')
		else
			if getEquippedItem('right_ring') ~= settings.teleport_ring then
				windower.send_command('gs disable ring2;wait 3;input /equip ring2 "'..settings.teleport_ring..'"')
			else
				windower.send_command('wait 3;input /item "'..settings.teleport_ring..'" <me>;wait 3;gs enable ring2')
			end
			delay = 30
		end
	end
end

windower.register_event('outgoing chunk',function(id,data,modified,injected,blocked)
	local player = windower.ffxi.get_player()
	local me = windower.ffxi.get_mob_by_target('me')
	local zone_id = windower.ffxi.get_info().zone
	local zone_name = res.zones[zone_id].name
	if id == 0x05B or id == 0x05C then
		if busy == true and portnow == true and isBuffActive(603) then		--Warp to the arena
			local port = packets.new('outgoing', 0x05C, {
				["X"] = -27.000001907349,
				["Z"] = 0,
				["Y"] = 34.5,
				["Target ID"] = affi.id,
				["_unknown1"] = 12,
				["Zone"] = zone_id,
				["Menu ID"] = 9701,
				["Target Index"] = affi.index,
				["_unknown3"] = 1,
			})
			packets.inject(port)
			busy = false
			portnow = false
			local packet = packets.new('outgoing', 0x016, {
				["Target Index"]=me.index,
			})
			packets.inject(packet)
			delay = 10
		end
	end
end)

windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
	local player = windower.ffxi.get_player()
	local me = windower.ffxi.get_mob_by_target('me')
	local zone_id = windower.ffxi.get_info().zone
	local menu_id = 65
	if id == 0x034 or id == 0x032 then
		if busy == true then
			local parse = packets.parse('incoming', data)
			local npc_id = parse['NPC']
			if tp and npc_id == tp.id then		--Undulating Confluence
				local port = packets.new('outgoing', 0x05B, {
					["Target"] = tp.id,
					["Option Index"] = 0,
					["_unknown1"] = 0,
					["Target Index"] = tp.index,
					["Automated Message"] = true,
					["_unknown2"] = 0,
					["Zone"] = zone_id,
					["Menu ID"] = menu_id
				})
				packets.inject(port)
				
				local port = packets.new('outgoing', 0x05B, {
					["Target"] = tp.id,
					["Option Index"] = 1,
					["_unknown1"] = 0,
					["Target Index"] = tp.index,
					["Automated Message"] = false,
					["_unknown2"] = 0,
					["Zone"] = zone_id,
					["Menu ID"] = menu_id
				})
				packets.inject(port)
				delay = 10
				busy = false
			elseif affi and npc_id == affi.id then	--affi
				if not isBuffActive(603) then
					local elvorseal = packets.new('outgoing', 0x05B, {
						["Target"] = affi.id,
						["Option Index"] = 10,
						["_unknown1"] = 0,
						["Target Index"] = affi.index,
						["Automated Message"] = true,
						["_unknown2"] = 0,
						["Zone"] = zone_id,
						["Menu ID"] = 9701
					})
					packets.inject(elvorseal)
				end
				local elvorseal = packets.new('outgoing', 0x05B, {
					["Target"] = affi.id,
					["Option Index"] = 11,
					["_unknown1"] = 16384,
					["Target Index"] = affi.index,
					["Automated Message"] = true,
					["_unknown2"] = 0,
					["Zone"] = zone_id,
					["Menu ID"] = 9701
				})
				
				packets.inject(elvorseal)
				portnow = true
			end
		end
	elseif id == 0x036 and not isBuffActive(603) then
		local parse = packets.parse('incoming', data)
		local npc_id = parse['Actor']
		local message_id = parse['Message ID']
		if affi and npc_id == affi.id and message_id == 6407 then
			windower.send_command('setkey escape down;wait 1;setkey escape up')
			delay = 300
		end
	end
end)

--Zone change timers
windower.register_event('zone change', function(new, old)
	local zone = res.zones[new].name
	if zone == 'Escha - Zi\'Tah' then
		delay = 20
	elseif zone == 'Qufim Island' then
		log('Don\'t forget to set your HP here!!!')
		delay = 15
		inside = false
		running = false
		fighting = false
		waiting = false
	else
		delay = 15
	end
end)

windower.register_event('addon command', function(...)
    local command = {...}
	if command[1] == 'stop' or command[1] == 'off' then
		pause = 'on'
		log('Stopping Azi')
    elseif command[1] == 'start' or command[1] == 'on' then
		pause = 'off'
		log('Starting Azi')
	end
end)