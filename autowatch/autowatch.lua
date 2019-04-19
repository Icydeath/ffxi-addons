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

-- Future: Find a successful event to trigger unbusy() for casting and abilities. (Action Complete packet most likely)
-- Added trading if set to slave (for cells)
-- Correct the issue where trading multiple times for displacers if more than 1 stack exists.
-- Fixed: Corrected issue with 'falls to the ground' from DoT.			- 8.30.2018
-- Fixed: Added in Displacer usage per fight.												- 8.4.2018
-- Fixed: Pyxis delay for large parties/alliances 									- 7.30.2018
-- Fixed: Build pet ID's into party list for detection of mob death - 7.28.2018

_addon.name = 'AutoWatch'
_addon.author = 'Langly'
_addon.version = '1.10'
_addon.date = '10.11.2018'
_addon.commands = {'autowatch', 'aw'}

packets = require('packets')
pack = require('pack')
config = require('config')
files = require('files')
res = require('resources')
texts = require('texts')
extdata = require('extdata')
require('coroutine')
require('tables')
require('strings')
require('logger')
require('sets')

----------------------------------------------------------------
-- Globals
----------------------------------------------------------------
-- Text Setup
defaults = {}
defaults.display = {}
defaults.display.pos = {}
defaults.display.pos.x = 0
defaults.display.pos.y = 0
defaults.display.bg = {}
defaults.display.bg.red = 0
defaults.display.bg.green = 0
defaults.display.bg.blue = 0
defaults.display.bg.alpha = 150
defaults.display.text = {}
defaults.display.text.font = 'Arial'
defaults.display.text.red = 255
defaults.display.text.green = 255
defaults.display.text.blue = 255
defaults.display.text.alpha = 255
defaults.display.text.size = 9

settings = config.load(defaults)
settings:save()

text_box = texts.new(settings.display, settings)
info = {}

-- Character
Player = windower.ffxi.get_player()
info.player_target = 'None'
info.player_displacer = 0
info.player_name = Player.name
info.player_hpp = 0
info.player_mpp = 0
info.player_tp = 0
info.player_x = 0
info.player_y = 0
info.player_z = 0
info.busy = false
info.status = 'None'
info.once = T{}
info.limbo2_time = 0
info.stones = 0

info.settings = {}
info.settings.target = 'None'
info.settings.master = true
info.settings.slave = false
info.settings.leech = false
info.settings.actions = T{}
info.settings.trusts = T{}
info.settings.should_engage = true
info.settings.displacer = 0
info.settings.rubicund = 0
info.settings.cells = false

----------------------------------------------------------------
-- Automation Params
----------------------------------------------------------------
switch = false
busy = false
command_delay = 0
target = {}
runtarget = {}
pyxis_delay = 0
use_displacers = 0

windower.register_event('load', function()
	initialize()
	profile = files.new(Player.name..'_'..Player.main_job..'.lua')
	notice('Welcome to AutoWatch, type //aw help for a list of commands.')
	if profile:exists() then
		notice('Using configurations specified in: '..Player.name..'_'..Player.main_job..'.lua')
	else
		notice('Generated configuration file.')
		profile:write('return ' .. T(info.settings):tovstring())
	end
	info.settings = require(Player.name..'_'..Player.main_job)
end)

function initialize(text, settings)
	local infobox = L{}
	infobox:append(' Character:  ${player_name|None}              Status:  ${status|None}')
	infobox:append(' Vitals >    HPP:  ${player_hpp|0}   MPP:  ${player_mpp|0}   TP:  ${player_tp|0}')
	infobox:append(' Position > X:  ${player_x|0}   Y:  ${player_y|0}   Z:  ${player_z|0}')
	infobox:append(' Busy:  ${busy|false}     Target:  ${player_target|None}')
	infobox:append(' -------------------------------------------------------------        ')
	infobox:append(' AutoWatch:  ${switch|Off}   Use Displacers:  ${displacers|0}   Voidstones:  ${stones|0}')

  text_box:clear()
  text_box:append(infobox:concat('\n'))
end

text_box:register_event('reload', initialize)
----------------------------------------------------------------
-- Commands
----------------------------------------------------------------
windower.register_event('addon command', function (command, ...)
	command = command and command:lower()
	local args = T{...}
	
	if command == "help" then
		notice('AutoWatch will smite a VW target ad infinitum.')
		notice('Provided you have stones available to pop the NM.')
		notice('Commands: ')
		notice('	//aw target <name> will set your target.')
		notice('	//aw start will engage the bot and begin work.')
		notice('	//aw stop will disengage the bot and let you resume control.')
		notice('	//aw slave will toggle the bot between active and passive behavior.')
		notice('	//aw engage will engage the target.')
		notice('	//aw action will add actions to your master/slave lists.')
		notice('		//Example: //aw action "Tachi: Fudo" tp 1000')
		notice('		//Example: //aw action "Erratic Flutter" absent Haste')
		notice('		//Example: //aw action "Ramuh" absent pet')
		notice('		//Example: //aw action Berserk ready')
		notice('Please start the bot near the Planar Rift you wish to use.')
		return
	end

	if command == "target" then
		if args[1] then
			info.settings.target = args[1]
			notice('Target: '..args[1]..'.')
		end
		update_configuration()
		return
	end

	if command == "start" then
		if info.settings.target == nil then
			warning('AutoWatch must have a target to operate.')
			return
		end
		notice('Starting AutoWatch.')
		switch = true
		if info.status == 'None' and info.settings.master then
			info.status = 'Build Party'
		else
            info.status = 'Trade Cells'
        end
		
		windower.add_to_chat(207, "Checking Voidstones...")
		local packet = packets.new('outgoing', 0x10F)
		packets.inject(packet)
		
		return
	end
	
	if command == "stop" then
		notice('Stopping AutoWatch.')
		switch = false
		return
	end
	
	if command == 'slave' then
		if slave then
			info.settings.slave = false
			notice('Slave Mode: Off')
		else
			info.settings.slave = true
			info.settings.master = false
			info.settings.leech = false
			notice('Slave Mode: On')
		end
		update_configuration()
		return
	end
	
	if command == 'leech' then
		if leech then
			info.settings.leech = false
			notice('Leech Mode: Off')
		else
			info.settings.leech = true
			info.settings.slave = false
			info.settings.master = false
			info.settings.should_engage = false
			notice('Leech Mode: On')
		end
		update_configuration()
		return
	end
	
	if command == 'master' then
		if master then
			info.settings.master = false
			notice('Master Mode: Off')
		else
			info.settings.master = true
			info.settings.slave = false
			info.settings.leech = false
			notice('Master Mode: On')
		end
		update_configuration()
		return
	end

	if command == "displacer" then
		local n = tonumber(args[1])
		if n then
			notice('Using displacers: '..n..' per fight.')
			info.settings.displacer = n
			update_configuration()
			return
		end
	end
    
 	if command == "rubicund" then
		local n = tonumber(args[1])
		if n and n <= 1 then
			notice('Using Rubicund Cells: '..n..' per fight.')
			info.settings.rubicund = n
			update_configuration()
			return
		else
           		notice('Rubicund can only be 0 or 1.')
		end
	end
	
	if command == 'engage' then
		if args[1] then
			info.settings.should_engage = args[1]
			notice('This character is set to engage the target: '..args[1]..'.')
		else
			if info.settings.should_engage then
				info.settings.should_engage = false
				notice('Should engage target: Off')
			else
				info.settings.should_engage = true
				notice('Should engage target: On')
			end
		end
		update_configuration()
		return
	end
	
	if command == "status" then
		info.status = args[1]
		return
	end
	
	if command == "action" then
		add_action(args)
		update_configuration()
		return
	end
	
	if command == 'list' then
		listrules()
		return
	end
	
	if command == 'test' then
		update_configuration()
	end
	
	if command == 'yiss' or command == 'snap' or command == 'shucks' then
		notice('Blorb.')
		send_cmd('input /dance4 motion')
	end
	
	if command == 'shit' then
		send_cmd('input /s Hnggg')
	end
	
	if command == 'trust' then
		manage_trusts(args)
		update_configuration()
		return
	end
	
end)

----------------------------------------------------------------
-- Events
----------------------------------------------------------------
windower.register_event('outgoing chunk', function(id, data)
	if id == 0x015 then
		local p = packets.parse('outgoing', data)
		info.player_h = p["Rotation"]
	end
end)

windower.register_event('prerender', function()
	update_info_panel()
	test_limbo2_time()
    if busy == true then windower.ffxi.run(false) end
	
	if switch == true and busy == false then
		update_status_based_on_role()
		
		if info.status == 'Waiting for Pop' then
			return
		end
		
		if info.settings.master or info.settings.rubicund > 0 then
			if info.status == 'Build Party' and busy == false and info.settings.master then
				gather_trusts()
			end
			
			if info.status == 'Trade Cells' and busy == false then
                if info.settings.displacer > 0 or info.settings.rubicund > 0 then
					local rift = pick_nearest(get_marray('Planar Rift'))
					if rift[1].valid_target then
						face_target(rift[1].id)
						if distance(rift[1].x,rift[1].y) < 6 then
							notice('Trading displacers to Rift.')
							
                            local rubicund_left = info.settings.rubicund
                            local displacer_left = info.settings.displacer
                            local trade_packet = packets.new('outgoing', 0x36, {
                                ['Target'] = rift[1].id,
                                ['Target Index'] = rift[1].index,})
                            local inventory = windower.ffxi.get_items(0)
                            local idx = 1
                            for index=1,inventory.max do
                                if inventory[index].id == 3853 and phase_displacers_available() > 0 and displacer_left > 0 then
                                    trade_packet['Item Index %d':format(idx)] = index
                                    if phase_displacers_available() > info.settings.displacer then
                                        trade_packet['Item Count %d':format(idx)] = info.settings.displacer
                                        displacer_left = displacer_left - info.settings.displacer
                                    else
                                        trade_packet['Item Count %d':format(idx)] = phase_displacers_available()
                                        displacer_left = displacer_left - phase_displacers_available()
                                    end
                                    idx = idx + 1
                                elseif inventory[index].id == 3435 and rubicund_available() > 0 and rubicund_left > 0 then
                                    trade_packet['Item Index %d':format(idx)] = index
                                    trade_packet['Item Count %d':format(idx)] = 1
                                    idx = idx + 1
                                    rubicund_left = rubicund_left - 1
                                end
                            end
                            trade_packet['Number of Items'] = idx
                            packets.inject(trade_packet)
                            use_displacers = info.settings.displacer

							busy = true
							info.status = 'Attempting Pop'
							coroutine.schedule(unbusy, 1)
							return
						else
							runto(rift[1])
						end
					end
                    return
				end
                
				if info.settings.displacer == 0 then
					info.status = 'Attempting Pop'
					return
				end
			end
			
			--if info.status == 'Attempting Pop' then
			if info.status == 'Attempting Pop' and info.stones > 0 then
				local rift = pick_nearest(get_marray('Planar Rift'))
				if rift[1].valid_target then
					face_target(rift[1].id)
					if distance(rift[1].x,rift[1].y) < 6 then
						notice('Injecting 0x01A on Rift.')
						poke_npc(rift[1].id, rift[1].index)
						info.status = 'Limbo'
						busy = true
						coroutine.schedule(unbusy, 3)
						return
					else
						runto(rift[1])
					end
				end
				return
			end
		end

		if (not info.settings.leech) then
			local player = windower.ffxi.get_player()
			locate_target()
			
			if info.status == 'Combat' then
					if info.settings.should_engage == true then 
						if player.status ~= 1 and target.id then
							local mob = windower.ffxi.get_mob_by_id(target.id)
							if mob.valid_target then
								attack(target.id,target.index)
							end
							return
						end
					end

				if player.status == 1 or info.settings.slave then
					if player.target_locked then
						send_cmd('input /lockon')
					end
					if info.settings.should_engage == true then
                        if busy == true then windower.ffxi.run(false) return end
						face_target(target.id)
						check_distance(target.id)
					end
					test_actions()
					return
				end
			end
		end

		if info.status == 'Pyxis' and busy == false then
			local pyxis = pick_nearest(get_marray('Riftworn Pyxis'))
			
			if pyxis[1].valid_target then
				notice('Found valid Pyxis.')
				face_target(pyxis[1].id)
				if distance(pyxis[1].x,pyxis[1].y) < 6 then
					notice('Injecting 0x01A on Pyxis after delay.')
					if info.stones > 0 then
						info.stones = info.stones - 1
					end
					info.status = 'Limbo2'
					info.limbo2_time = os.time()
					coroutine.schedule(poke_pyxis, determine_pyxis_delay())
				else
					notice('Closing in on Pyxis.')
					runto(pyxis[1])
				end
			end
		end
    end
end)

windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
if switch then
		if id == 0x113 then -- 275 Currency Info
			local packet = packets.parse("incoming", data)
			local voidstones = packet['Voidstones']
			windower.add_to_chat(207, 'Voidstones Remaining: '..voidstones)
			info.stones = voidstones
		end
	
		if id == 0x29 then	-- Mob died
			local p = packets.parse('incoming',data)
			local target_id = p['Target'] --data:unpack('I',0x09)
			local player_id = p['Actor'] 
			local message_id = p['Message'] --data:unpack('H',0x19)%32768

			-- 6 == actor defeats target
			if message_id == 6 and windower.ffxi.get_mob_by_id(target_id).name == info.settings.target then
				local party_table = windower.ffxi.get_party()
				local party_ids = T{}

				for _,member in pairs(party_table) do
					if type(member) == 'table' and member.mob then
						party_ids:append(member.mob.id)
					end
				end

				for i,v in pairs(party_ids) do
					local pet_idx = windower.ffxi.get_mob_by_id(v).pet_index or nil
					if pet_idx then
						party_ids:append(windower.ffxi.get_mob_by_index(pet_idx).id)
					end
				end

				if player_id == windower.ffxi.get_player().id or party_ids:contains(player_id) then
					notice('Killed by '..windower.ffxi.get_mob_by_id(player_id).name..'.')
					table.clear(target)
					windower.ffxi.run(false)
					busy = true
					info.status = 'Pyxis'
					coroutine.schedule(unbusy, 2)
				end
			end

			-- 20 == target falls to the ground
			if message_id == 20 and windower.ffxi.get_mob_by_id(target_id).name == info.settings.target then
				notice('Killed by dot.')
				table.clear(target)
				windower.ffxi.run(false)
				busy = true
				info.status = 'Pyxis'
				coroutine.schedule(unbusy, 2)
			end
		end

		if id == 0x034 then
			local p = packets.parse('incoming',data)
		
			if windower.ffxi.get_mob_by_id(p.NPC).name == 'Planar Rift' and info.status == 'Limbo' then
				local disp_option = {[0] = 0x01, [1] = 0x11, [2] = 0x21, [3] = 0x31, [4] = 0x41, [5] = 0x51}
				notice('Received 0x034 from Rift. Blocking menu.')
				notice('Popping VW nm.')
				vwpop(p["NPC"],p["NPC Index"],p["Zone"],p["Menu ID"],disp_option[use_displacers])
				use_displacers = 0
				info.status = 'Combat'
			end
			
			if windower.ffxi.get_mob_by_id(p.NPC).name == 'Riftworn Pyxis' and info.status == 'Limbo2' then
				local rare_item = false
				local total_items = 0
				local rare_items = 0
				local pickup = T{}
				local pulsable = T{[18457] = 'Murasamemaru',[18542] = 'Aytanri',[18904] = 'Ephemeron',[19144] = 'Coruscanti',[19145] = 'Asteria',[19174] = 'Borealis',[19794] = 'Delphinius',}
				local option_index = nil
				local pulse = nil
				
				notice('Received 0x034 from Pyxis. Blocking menu.')
				
				for i=1,8 do
					local itm = p['Menu Parameters']:unpack('I', 1 + (i - 1)*4)
					if not (itm == 0) then
						if rare(itm) and have_item(itm) then
							rare_item = true
							rare_items = rare_items +1
						end
						
						if pulsable[itm] and have_item(itm) then
							pickup.item = itm
							pulse = 1
						end
						total_items = total_items + 1
					end
					if itm == 5910 then
						send_cmd('input /echo Woohoo~!')
					end
				end
				
				if pickup.index then
					--Send the packet to pickup the pulsed item.
					pyxis(p["NPC"],p["NPC Index"],p["Zone"],p["Menu ID"],pickup.item,1)
					busy = true
					notice('Pulsing item. Will re-enter menu.')
					coroutine.schedule(unbusy, 2)
					info.status = 'Pyxis'
					info.limbo2_time = 0
				else
					if rare_items == total_items then
						notice('Relinquishing remainder of rare items.')
						pyxis(p["NPC"],p["NPC Index"],p["Zone"],p["Menu ID"],9,0)
						notice('Attempting Pop.')
						info.status = 'Trade Cells'
						info.limbo2_time = 0
					else
						if rare_item then
							notice('Would obtain all but need to re-enter to relinquish remainder of rare items.')
							notice('Obtaining all Spoils.')
							busy = true
							pyxis(p["NPC"],p["NPC Index"],p["Zone"],p["Menu ID"],10,0)
							coroutine.schedule(unbusy, 2)
							info.status = 'Pyxis'
							info.limbo2_time = 0
						else
							notice('Obtaining all Spoils.')
							busy = true
							pyxis(p["NPC"],p["NPC Index"],p["Zone"],p["Menu ID"],10,0)
							coroutine.schedule(unbusy, 2)
							notice('Attempting Pop.')
							info.status = 'Trade Cells'
							info.limbo2_time = 0
						end
					end
				end
			end
			return true
		end
	end
end)

windower.register_event('job change', function()
	send_cmd('lua r autowatch')
end)
----------------------------------------------------------------
-- Builders
----------------------------------------------------------------
function update_info_panel()
	if windower.ffxi.get_player() then
		local player = windower.ffxi.get_player()
		local position = windower.ffxi.get_mob_by_index(player.index) or {x=0,y=0,z=0}
		info.player_name = player.name
		info.player_status = res.statuses[player.status].en
		info.player_hpp = player.vitals.hpp
		info.player_mpp = player.vitals.mpp
		info.player_tp = player.vitals.tp
		info.player_target = info.settings.target
		info.player_x = string.format('%.2f', tostring(position.x or 0))
		info.player_y = string.format('%.2f', tostring(position.y or 0))
		info.player_z = string.format('%.2f', tostring(position.z or 0))
		info.busy = busy
		info.switch = switch
		info.displacers = info.settings.displacer
		
		text_box:update(info)
		text_box:show()
	end
end

function commaformat(number) -- Prettys up some numbers for human consumption
   return string.format("%d", number):reverse():gsub( "(%d%d%d)" , "%1," ):reverse():gsub("^,","")
end

function add_action(args)
	local abil_name = args[1] or nil
	local abil_prefix = 'none'
	local abil_condition = args[2] or nil
	local abil_modifier = args[3] or nil
	local allowed_conditions = T{'absent','tp','ready'}
	local abil_count = table.getn(info.settings.actions) + 1
	
	if abil_name then
		local action = res.spells:with('en',abil_name) or res.job_abilities:with('en',abil_name) or res.weapon_skills:with('en',abil_name) or args[1]
		if action and args[2] == 'raw' and args[3] then
			info.settings.actions[abil_count] = {}
			info.settings.actions[abil_count].action = action
			info.settings.actions[abil_count].prefix = ''
			info.settings.actions[abil_count].condition = 'raw'
			info.settings.actions[abil_count].modifier = args[3] -- Must be tied to a recast like 'Monster'
			notice('Adding raw command tied to ability timer '..args[3]..'.')
			return
		end
		if action == nil or args[2] == nil then
			warning('AutoWatch cannot find action: '..abil_name..'. Or you did not specify a condition.')
			return
		else
			abil_name = action.name
			abil_prefix = action.prefix
			
			if table.find(allowed_conditions, args[2]) then
				if abil_condition == 'tp' then
					if tonumber(args[3]) < 1000 then
						abil_modifier = 1000
					end
				elseif abil_condition == 'absent' then
					if args[3] == nil then
						warning('The absent condition requires a specified status paired with this condition. Ex: //aw action "Erratic Flutter" absent Haste')
						return
					end
				elseif abil_condition == 'ready' then
					abil_modifier = ''
				end
			else
				warning('Unrecognized condition specified: '..args[2]..'. Please use an allowed condition. (absent, tp, ready)')
				return
			end
			

			
			info.settings.actions[abil_count] = {}
			info.settings.actions[abil_count].action = abil_name
			info.settings.actions[abil_count].prefix = abil_prefix
			info.settings.actions[abil_count].condition = abil_condition
			info.settings.actions[abil_count].modifier = abil_modifier
			notice('Successfully added action '..abil_name..' when '..abil_condition..' '..abil_modifier..'.')
		end
	end
end

function update_configuration()
	profile:write('return ' .. T(info.settings):tovstring())
end

function test_actions()
	local actions = info.settings.actions
	local mob = windower.ffxi.get_mob_by_id(target.id)
	local player = windower.ffxi.get_player()
	

	for i,v in ipairs(actions) do
		if v.condition == 'tp' then
			if tonumber(player.vitals.tp) >= tonumber(v.modifier) and distance(mob.x,mob.y) < 3 then
				busy = true
				send_cmd('input '..v.prefix..' '..v.action)
				coroutine.schedule(unbusy, 3)
			end
		else
			--Determine Recast Eligibility
			local action = res.spells:with('en',v.action) or res.job_abilities:with('en',v.action) or res.weapon_skills:with('en',v.action)
			local ability_recast = 0
			local charges = 0
			if v.prefix == "/jobability" then
				ability_recast = windower.ffxi.get_ability_recasts()[res.job_abilities[res.job_abilities:with('en',v.action).id].recast_id]
			elseif v.prefix == "/magic" or v.prefix == "/ninjutsu" or v.prefix == "/song" then
				ability_recast = windower.ffxi.get_spell_recasts()[res.spells[res.spells:with('en',v.action).id].recast_id]
			elseif v.prefix == "/pet" then
				local ability = res.job_abilities[action.id]
				if ability.type == "BloodPactRage" then
						ability_recast = windower.ffxi.get_ability_recasts()[173]
				elseif ability.type == "BloodPactWard" then
						ability_recast = windower.ffxi.get_ability_recasts()[174]
				end
			end
			if v.condition == 'raw' and v.modifier == "Monster" then
				ability_recast = windower.ffxi.get_ability_recasts()[102]
				charges = math.floor(((15 * 3) - ability_recast) / 15)
			end

			if v.condition == 'absent' then
				if v.modifier:lower() == 'pet' then
					local pet = windower.ffxi.get_mob_by_target('pet') or nil
					if pet == nil then
						busy = true
						send_cmd('input '..v.prefix..' "'..v.action..'"')
						coroutine.schedule(unbusy, 4)
					end
				end
				if (not has_buff(v.modifier)) and ability_recast == 0 and v.modifier ~= 'pet' then
					busy = true
					send_cmd('input '..v.prefix..' '..v.action)
					if v.prefix == "/magic" or v.prefix == "/ninjutsu" or v.prefix == "/song" then
						-- Fix this, to detect when my status is not casting rather than a blanket 5 seconds.
						coroutine.schedule(unbusy, 5)
					else
						coroutine.schedule(unbusy, 3)
					end
				end
			elseif v.condition == 'ready' then
				if ability_recast == 0 then
					if v.prefix == "/pet" then
						busy = true
						send_cmd('input '..v.prefix..' "'..v.action..'" <bt>')
						coroutine.schedule(unbusy, 3)
					end
					busy = true
					send_cmd('input '..v.prefix..' '..v.action)
					coroutine.schedule(unbusy, 3)
				end
			elseif v.condition == 'raw' and v.modifier == 'Monster' then
				if charges > 0 then
					busy = true
					send_cmd(v.action)
					coroutine.schedule(unbusy, 3)
				end
			end
		end
	end
end

function listrules()
	if info.settings.actions then
		notice('Actions for current file are as listed: ')
		for i,v in pairs(info.settings.actions) do
			notice('Use '..v.action..' when '..v.condition..' '..v.modifier..'.')
		end
	else
		notice('No actions found in current file.')
	end
end
----------------------------------------------------------------
-- Asserts
----------------------------------------------------------------

function headingto(x,y)
	local x = x - windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id).x
	local y = y - windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id).y
	local h = math.atan2(x,y)
	return h - 1.5708
end

function inventory_space()
	local inventory = windower.ffxi.get_bag_info(0)
	local free = inventory.max - inventory.count
	return free
end

function distance(x, y)
	local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
	local dx = x - self_vector.x
	local dy = y - self_vector.y
	return math.sqrt(dx*dx + dy*dy)
end

function in_party(name)
	local name = name or 'None'
	local party = windower.ffxi.get_party()
	
	for _,v in pairs(party) do
		if type(v) == 'table' then
			if v.name == name then
				return true
			end
		end
	end
	return false
end

function inventory_space()
	local inventory = windower.ffxi.get_bag_info(0)
	local free = inventory.max - inventory.count
	return free
end

function check_claim(id)
	local id = id or 0
	local player_id = windower.ffxi.get_player().id
	local mob = windower.ffxi.get_mob_by_id(id)
	local party_table = windower.ffxi.get_party()
	local party_ids = T{}
	
	for _,member in pairs(party_table) do
		if type(member) == 'table' and member.mob then
			party_ids:append(member.mob.id)
		end
	end
	
	for i,v in pairs(party_ids) do
		local pet_idx = windower.ffxi.get_mob_by_id(v).pet_index or nil
		if pet_idx then
			party_ids:append(windower.ffxi.get_mob_by_index(pet_idx).id)
		end
	end
	
	if party_ids:contains(mob.claim_id) then
		return true
	end
	return false
end

function has_buff(buff)
	local buffs = convert_buff_list(windower.ffxi.get_player()['buffs'])
	for _,v in pairs(buffs) do
		if v == buff then
			return true
		end
	end
	return false
end

function convert_buff_list(bufflist)
    local buffarr = {}
    for i,v in pairs(bufflist) do
        if res.buffs[v] then
            buffarr[#buffarr+1] = res.buffs[v].english
        end
    end
    return buffarr
end

function phase_displacers_available()
	local count = 0
	local inventory = windower.ffxi.get_items().inventory
	for index=1,inventory.max do
		if inventory[index].id == 3853 then
			count = inventory[index].count
		end
	end
	return count
end

function rubicund_available()
	local count = 0
	local inventory = windower.ffxi.get_items().inventory
	for index=1,inventory.max do
		if inventory[index].id == 3435 then
			count = inventory[index].count
		end
	end
	return count
end

function locate_target()
	local marray = get_marray(info.settings.target)
	for _,v in pairs(marray) do
		if check_claim(v.id) then
			target.id,target.index = v.id,v.index
		end
	end
end

function get_marray(--[[optional]]name)
	--[[ Format of new Mob Array
		Returns an array of comprehensive mob data. Useful fields below.
		number:
			id, index, claim_id, x, y, z, distance, facing, entity type, target index,
			spawn_type, status, model_scale, heading, model_size, movement_speed,
		string:
			name,
		booleans:
			is_npc, in_alliance, charmed, in_party, valid_target
	--]]
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

function pick_nearest(--[[optional]]mob_table)
	local dist_target = 0
	local closest_key = 0
	local marray = mob_table or get_marray()
	local new_marray = T{}
	
	for k,v in pairs(marray) do
		if dist_target == 0 then
			closest_key = k
			dist_target = math.sqrt(v['distance'])
		elseif math.sqrt(v['distance']) < dist_target then
			closest_key = k
			dist_target = math.sqrt(v['distance'])
		end
	end

	for k,v in pairs(marray) do
		if k == closest_key then
			new_marray[1] = v
		end
	end
	
	return new_marray
end
----------------------------------------------------------------
-- Actors
----------------------------------------------------------------
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

function attack(id, index)
	if id then
		local packet = packets.new('outgoing', 0x01A, {
			["Target"]=id,
			["Target Index"]=index,
			["Category"]=2,
			["Param"]=0,
			["_unknown1"]=0})
		packets.inject(packet)
	end
end

function poke_pyxis()
	local pyxis = pick_nearest(get_marray('Riftworn Pyxis'))
	local id = pyxis[1].id
	local index = pyxis[1].index
	
	local packet = packets.new('outgoing', 0x01A, {
		["Target"]=id,
		["Target Index"]=index,
		["Category"]=0,
		["Param"]=0,
		["_unknown1"]=0})
	packets.inject(packet)
end

function pyxis(id, index, zone, menuid, option_index, pulse)
	local option_index = option_index or 10
	local pulse = pulse or 0
	local packet = packets.new('outgoing', 0x05B, {
	["Target"]=id,
	["Target Index"]=index,
	["_unknown1"]=pulse,
	["Automated Message"]=false,
	["_unknown2"]=0,
	["Option Index"]=option_index,
	["Menu ID"]=menuid,
	["Zone"]=zone})
	packets.inject(packet)
end

-- Uses max displacers by using 0x51 
function vwpop(id, index, zone, menuid, displacer)
	local packet = packets.new('outgoing', 0x05B, {
	["Target"]=id,
	["Target Index"]=index,
	["Option Index"]=displacer,
	["_unknown1"]=0,
	["Automated Message"]=false,
	["_unknown2"]=0,
	["Menu ID"]=menuid,
	["Zone"]=zone})
	packets.inject(packet)
end

function trade_displacers()

end

function unbusy()
	busy = false
end

function manage_trusts(args)
	local cmd = args[1] or nil
	local trust = args[2] or nil
	local trust_list = info.settings.trusts
	local trust_count = table.getn(info.settings.trusts)
	
	if cmd == nil then
		return
	end
	
	if cmd == 'add' then
		if trust_count >= 5 then
			notice('Five trusts already exist in trust table.')
			return
		end
		
		info.settings.trusts[trust_count + 1] = trust
		notice('Adding '..trust..' to your trust table.')
		
	elseif cmd == 'remove' then
		for i,v in pairs(info.settings.trusts) do
			if v == trust then
				table.delete(info.settings.trusts, trust)
				notice('Removing '..trust..' from your trust table.')
			end
		end	
	end
end

function update_status_based_on_role()
	if info.settings.master then
		return
	end
	if info.settings.leech then
		if info.status ~= 'Pyxis' or info.status ~= 'Limbo2' then
			info.status = 'Pyxis'
			return
		end
	end
	if info.settings.slave then
        if info.settings.rubicund > 0 and info.status == 'None' then
            info.status = 'Trade Cells'
        end
        if info.status == 'Trade Cells' and info.settings.rubicund == 0 then
            info.status = 'Waiting for Pop'
        end
        if info.status == 'None' then
            info.status = 'Waiting for Pop'
        end
		if info.status == 'Attempting Pop' or info.status == "Build Party" then
			info.status = 'Waiting for Pop'
		end
		if info.status == 'Waiting for Pop' then
			locate_target()
			if target.id then
				local mob = windower.ffxi.get_mob_by_id(target.id)
				if mob.valid_target and mob.hpp > 0 then
					info.status = 'Combat'
				end
			end
		end
	end
end

function runto(target)
	runtarget.x = target.x
	runtarget.y = target.y
	local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
	local angle = (math.atan2((target.y - self_vector.y), (target.x - self_vector.x))*180/math.pi)*-1
	windower.ffxi.run((angle):radian())
end

function face_target(target)
	local destX = windower.ffxi.get_mob_by_id(target).x
	local destY = windower.ffxi.get_mob_by_id(target).y
	local direction = math.abs(info.player_h - math.deg(headingto(destX,destY)))
	if direction > 10 then
		windower.ffxi.turn(headingto(destX,destY))
	end
end

function gather_trusts()
	local party = windower.ffxi.get_party()
	local trusts = info.settings.trusts
	
	local trust_count = table.length(trusts)
	local n = 0
	for i,v in pairs(trusts) do
		if in_party(v) then
			n = n +1
		end
	end

	if party.party1_count == 6 or n == trust_count then
		notice('At maximum party members - or all trusts specified have been summoned.')
		info.status = 'Trade Cells'
		return
	end
	
	if busy == false then
		for i,v in ipairs(trusts) do
			if not in_party(v) then
				notice(v..' not in party. Summoning.')
				summon_trust(v)
				return
			end
		end
	end
end

function summon_trust(name)
	busy = true
	local name = name or 'None'
	if name == 'Apururu' then
		name = 'apururuuc'
	end
	if name == 'yoran-oran' then
		name = 'yoran-oran uc'
	end
	windower.send_command(name)
	coroutine.schedule(unbusy, 5)
end

function send_cmd(str)
	local cmd = str or nil
	if cmd then
		windower.send_command(cmd)
	end
end

function determine_pyxis_delay()
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
					return (k - 1) * .4 + 1
			end
	end
end

function player_update()
	local packet = packets.new('outgoing', 0x016, {["Target Index"]=windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id).index,})
	packets.inject(packet)
end

function rare(id)
    if res.items[id].flags['Rare'] then
        return true
    end
    return false
end

function have_item(id)
	local items = windower.ffxi.get_items()
	local bags = {'inventory'}

	for k, v in pairs(bags) do
        for index = 1, items["max_%s":format(v)] do
            if items[v][index].id == id then
                return true
            end
        end
	end
	return false
end

function test_limbo2_time()
	if info.status == 'Limbo2' then
		local now_time = os.time()
		if os.difftime(now_time, info.limbo2_time) >= 6 then
			if info.stones == 0 and info.settings.should_engage == true then
				info.status = 'Waiting for Pop'
			else
				info.status = 'Pyxis'
			end
		end
	end
end

function check_distance(id)
    if busy == true then windower.ffxi.run(false) return end
	local target_id = id or 0
	local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
	local mob = pick_nearest(get_marray(info.settings.target))
    local angle = (math.atan2((mob[1].y - self_vector.y), (mob[1].x - self_vector.x))*180/math.pi)*-1
	local distance = mob[1].distance:sqrt()
	
	if distance > 3 then
        windower.ffxi.run((angle):radian())
	elseif distance < .9 then
		local angle = (math.atan2((mob[1].y - self_vector.y), (mob[1].x - self_vector.x))*180/math.pi)*-1
		windower.ffxi.run((angle+180):radian())
	else
		windower.ffxi.run(false)
	end
end
