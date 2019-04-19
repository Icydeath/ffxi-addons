
function on_action(action)

	-- 1. Melee attack
	-- 2. Finish ranged attack
	-- 3. Finish weapon skill
	-- 4. Finish spell casting
	-- 5. Finish item use
	-- 6. Use job ability
	-- 7. Begin weapon skill or TP move
	-- 8. Begin spell casting or interrupt casting
	-- 9. Begin item use or interrupt usage
	-- 10. Unknown – Probably was intended to be the “readies” messages for JAs, which was unnecessary because they are instant.
	-- 11. Finish TP move
	-- 12. Begin ranged attack
	-- 13. Pet completes ability/WS
	-- 14. Unblinkable job ability
	-- 15. Some RUN job abilities
	
	-- Must verify that all potential actors exist, if using windower.ffxi.get_mob_by_####### after zoning,
	-- then it will return nil as the mob structure does not exist yet,
	-- so we use currently saved mob structures with our party list to aquire relevent information
	
	if action == nil then return end
	local actor = {}
	for index, m_table in pairs(member_table) do
		if member_table[index].id == action.actor_id then
			actor = member_table[index].mob
			break
		end
	end
	if actor == nil then return end
	
	local spells_to_watch = S{'Marcato', 'Soul Voice', 
											'Bolster','Ecliptic Attrition','Blaze of Glory',
											'Haste', 'Haste II', 'Hastega', 'Hastega II', "Erratic Flutter", 'Refueling', 
											'Honor March', 'Victory March', 'Advancing March',
											"Mage's Ballad", "Mage's Ballad II", "Mage's Ballad III",
											'Valor Minuet', 'Valor Minuet I', 'Valor Minuet II', 'Valor Minuet IV', 'Valor Minuet V',
											'Sword Madrigal', 'Blade Madrigal',
											"Army's Paeon", "Army's Paeon II", "Army's Paeon III", "Army's Paeon IV", "Army's Paeon V", "Army's Paeon VI",
											"Knight's Minne", "Knight's Minne II", "Knight's Minne III", "Knight's Minne IV", "Knight's Minne V",
											"Hunter's Prelude", "Archer's Prelude",
											'Sheepfoe Mambo', 'Dragonfoe Mambo',
											'Sinewy Etude', 'Dextrous Etude', 'Vivacious Etude', 'Quick Etude', 'Learned Etude', 'Spirited Etude', 'Enchanting Etude', 
											'Herculean Etude', 'Uncanny Etude', 'Vital Etude', 'Swift Etude', 'Sage Etude', 'Logical Etude', 'Bewitching Etude', 
											"Indi-Regen","Indi-Refresh", "Indi-Haste", "Indi-STR", "Indi-DEX", "Indi-VIT","Indi-AGI", "Indi-INT", "Indi-MND", "Indi-CHR", "Indi-Fury", "Indi-Barrier", "Indi-Acumen", 
											"Indi-Fend", "Indi-Precision", "Indi-Voidance",	"Indi-Focus", "Indi-Attunement",
											"Geo-Regen", "Geo-Refresh", "Geo-Haste", "Geo-STR", "Geo-DEX", "Geo-VIT", "Geo-AGI", "Geo-INT", "Geo-MND", "Geo-CHR", "Geo-Fury", "Geo-Barrier", "Geo-Acumen",	
											"Geo-Fend", "Geo-Precision","Geo-Voidance","Geo-Focus", "Geo-Attunement",
											--'Slow','Slow II','Slowga','Slowga II',
											}
	-- check for haste spikes from haste samba
	if action.actor_id == player.id and action.category == 1 then
		if action.targets[1].actions[1].reaction == 8 then
			if action.targets[1].actions[1].add_effect_animation == 23 then
				--add_to_chat(122, 'haste spikes')
				if buff_info.h_spikes ~= true then
					buff_info.h_spikes = true
				end
			elseif action.targets[1].actions[1].add_effect_animation ~= 23 then
				if buff_info.h_spikes == true then
					buff_info.h_spikes = false
				end
			end
		end
	end
	
	-- Cor Job abilities
	-- check for cor rolls
	if action.category == 6 and (table.containskey(Cor_Rolls, action.param) or action.param == 123) and ((actor.is_npc and actor.charmed) or not actor.is_npc) then
		--notice('Step 1: ' .. action.param .. ' ' .. res.job_abilities:with('id', action.param).en)
		for index, target in pairs(action.targets) do
			if type(target) == "table" then
				--notice('Step 2')
				if target.id == player.id then
					--notice('Step 3')
					for index, m_table in pairs(member_table) do
						if member_table[index].id == action.actor_id then
							--notice('Step 4')
							local rollID = action.param
							local rollNum = action.targets[1].actions[1].param
							local buff_potency = {}
							local Roll_bonus = 0
							-- check if we know the COR from the settings file for boost to phantom roll
							if table.containskey(settings.Cors, member_table[index].name:lower()) then
								Roll_bonus = settings.Cors[member_table[index].name:lower()]
							else
								Roll_bonus = manual_COR_bonus
							end
							
							if Crooked_cards.name == Cor_Rolls[rollID].en or Crooked_cards.name == '' and Crooked_cards.bool then
								Crooked_cards = {name = Cor_Rolls[rollID].en, bool = false}
							else
								Crooked_cards = {name = '', bool = false}
							end
							
							local cc_bonus = 1
								
							if Crooked_cards.name == Cor_Rolls[rollID].en then
								cc_bonus = 1.2
							end
							if rollNum == 12 and Cor_Rolls[rollID].bust  ~= "?" then
								buff_potency[1] = Cor_Rolls[rollID].bust * cc_bonus
							elseif Cor_Rolls[rollID].roll[rollNum] ~= "?" then
								if rollID == 304 then
									local hpval = (Cor_Rolls[rollID].roll[rollNum][1] + (Cor_Rolls[rollID]["roll+1"][1] * Roll_bonus)) * cc_bonus
									local tpval = (Cor_Rolls[rollID].roll[rollNum][2] + (Cor_Rolls[rollID]["roll+1"][2] * Roll_bonus)) * cc_bonus
									buff_potency = {hpval, tpval,}
								else
									buff_potency = {(Cor_Rolls[rollID].roll[rollNum] + (Cor_Rolls[rollID]["roll+1"] * Roll_bonus)) * cc_bonus,}
								end
							else
								buff_potency = {'?'}
							end

							for k, v in pairs(member_table) do																
								if Cor_Rolls[rollID]['bonus']['Main job'] == v['Main job'] and v['Main job'] ~= 'NON'  then
									buff_potency[1] = buff_potency[1] + Cor_Rolls[rollID]['bonus'].effect
									--print('entred 2')
									break
								elseif Cor_Rolls[rollID]['bonus']['Main job'] == 'NON' then
									-- if action.actor_id == player.id then
										-- local slot = Cor_Rolls[rollID]['bonus'].equipment.slot
										-- if slot ~= '' then
											-- if player.equipment[slot].id then
												-- if Cor_Rolls[rollID]['bonus'].equipment.id:contains(player.equipment[slot].id) then
													-- buff_potency = buff_potency + Cor_Rolls[rollID]['bonus'].effect
													-- break
												-- end
											-- end
										-- end
									-- else
										-- assume others use emperean equipment for boosting said rolls							
										if rollID == 304 then
											buff_potency[1] = buff_potency[1] + Cor_Rolls[rollID]['bonus'].effect
											buff_potency[2] = buff_potency[2] + Cor_Rolls[rollID]['bonus'].effect
										else
											--print('entred 1')
											if buff_potency[1] ~= '?' then
												buff_potency[1] = buff_potency[1] + Cor_Rolls[rollID]['bonus'].effect
											end
										end
										break
									--end
								end
							end
							
							member_table[index] = {id = member_table[index].id, name = member_table[index].name, mob = member_table[index].mob,  Last_Spell = Cor_Rolls[rollID].en, 
																	effect = Cor_Rolls[rollID].effect, value = buff_potency, 
																	['Main job']=member_table[index]['Main job'], ['Main job level']=member_table[index]['Main job level'],
																	['Sub job']=member_table[index]['Sub job'], ['Sub job level']=member_table[index]['Sub job level'], 
																	buffs=member_table[index].buffs, indi=member_table[index].indi, geo=member_table[index].geo, pet=member_table[index].pet}
																	
							for i, buff in pairs(_ExtraData.player.buff_details) do
								-- need to update buff list if its a double up and force a check_buffs() as the buff table does not change with a double up neither does the buff duration
								if buff.id == res.buffs:with('english', Cor_Rolls[rollID].en).id then
									_ExtraData.player.buff_details[i].value = buff_potency
									_ExtraData.player.buff_details[i].Last_Spell = Cor_Rolls[rollID].en
									_ExtraData.player.buff_details[i].effect = Cor_Rolls[rollID].effect
									check_buffs()
									break
								end
							end
							
							local partyColour = {
								p0 = string.char(0x1E, 247),
								p1 = string.char(0x1F, 204),
								p2 = string.char(0x1E, 156),
								p3 = string.char(0x1E, 238),
								p4 = string.char(0x1E, 5),
								p5 = string.char(0x1E, 6)
							}
							
							local party = windower.ffxi.get_party()
							rollMembers = {}
							for partyMem in pairs(party) do
								for effectedTarget = 1, #action.targets do
									--if mob is nil then the party member is not in zone, will fire an error.
									if type(party[partyMem]) == 'table' and party[partyMem].mob and action.targets[effectedTarget].id == party[partyMem].mob.id then   
										rollMembers[effectedTarget] = partyColour[partyMem] .. party[partyMem].name .. chat.controls.reset
									end
								end
							end
							local membersHit = table.concat(rollMembers, ', ')
							local amountHit =  '[' .. #rollMembers .. '] ' or ''
							local luckChat = ''
							local isLucky = false
							if rollNum == Cor_Rolls[rollID].lucky or rollNum == 11 then 
								isLucky = true
								luckChat = string.char(31,158).." (Lucky!)"
							end
							
							if rollNum == 12 and #rollMembers > 0 then
								for k, v in pairs(buff_potency) do
									if type (buff_potency[k]) == 'number' then
										buff_potency[k] = string.format("%+d", buff_potency[k])
									end
								end
								
								buff_potency = table.concat(buff_potency, ", ")
								
								if Crooked_cards.name == Cor_Rolls[rollID].en then
									buff_potency = buff_potency .. ' \"Crooked Cards\"'
								end
								if settings.player.show_COR_messages then
									windower.add_to_chat(1, string.char(31,167)..amountHit..'Bust! '..chat.controls.reset..chars.implies..' '..membersHit..' '..chars.implies..' (\"'..Cor_Rolls[rollID].effect..'\" '.. buff_potency..')')
								end
							else
								for k, v in pairs(buff_potency) do
									if type (buff_potency[k]) == 'number' then
										buff_potency[k] = string.format("%+d", buff_potency[k])
									end
								end
								
								buff_potency = table.concat(buff_potency, ", ")
								
								if Crooked_cards.name == Cor_Rolls[rollID].en then
									buff_potency = buff_potency .. ' \"Crooked Cards\"'
								end
								if settings.player.show_COR_messages then
									windower.add_to_chat(1, string.char(31,167)..amountHit..chat.controls.reset..membersHit..chat.controls.reset..' '..chars.implies..' '..Cor_Rolls[rollID].en..' '..chars['circle' .. rollNum]..luckChat..string.char(31,13)..' (\"'..Cor_Rolls[rollID].effect..'\" '..buff_potency..')')
								end
							end
						break
						end
					end
				end
			end
		end
	-- Job ability use "General"
	elseif action.category == 6 and ((actor.is_npc and actor.charmed) or not actor.is_npc) then
		--notice('Step 1: ' .. action.param .. ' ' .. res.job_abilities:with('id', action.param).en)
		for index, target in pairs(action.targets) do
			if type(target) == "table" then
				-- Crooked Cards
				if action.param == 392 then
					Crooked_cards = {name = '', bool = true}
				end
				-- Ecliptic Atrition
				if action.param == 347 then 
					for index, m_table in pairs(member_table) do
						if m_table.mob.pet_index and windower.ffxi.get_mob_by_index(m_table.mob.pet_index).name == 'Luopan' and m_table.id == action.actor_id then
							if member_table[index].geo.boost ~= 2 then
								if member_table[index].geo.boost == nil then 
									member_table[index].geo.boost = 1 
								end
								member_table[index].geo = {id = member_table[index].geo.id, caster = member_table[index].geo.caster, boost = (member_table[index].geo.boost + 0.25) }
							end
						end
					end
				end
				
				-- Aggressor
				if action.param == 34 and action.actor_id == player.id  then
					for index, m_table in pairs(member_table) do
						-- check if actor is in the party
						if member_table[index].id == action.actor_id and action.actor_id == player.id then
					
							
							-- Warrior's Lorica +2, Agoge Lorica nq, +1, +2, +3
							-- These chests boost AGI when agressor is activated on agressive aim merrits
							local body_list = L{10670, 26800, 26801, 23130, 23465}
							if body_list:contains(player.equipment['body'].id) then
								if player.equipment['body']["augments"][3] == "Enhances \"Aggressive Aim\" effect" then
									agi_boost = player['merits']['aggressive_aim'] * 3
								end
							end
						
									
							member_table[index] = {id = member_table[index].id, name = member_table[index].name, mob = member_table[index].mob,  Last_Spell = 'Aggressor', 
																	effect = "AGI", value = agi_boost, 
																	['Main job']=member_table[index]['Main job'], ['Main job level']=member_table[index]['Main job level'],
																	['Sub job']=member_table[index]['Sub job'], ['Sub job level']=member_table[index]['Sub job level'], 
																	buffs=member_table[index].buffs, indi=member_table[index].indi, geo=member_table[index].geo, pet=member_table[index].pet}	
							break
						end
					end
				end
					
				
				-- Warcry
				if action.param == 32 then
					for index, m_table in pairs(member_table) do
						-- check if actor is in the party
						if member_table[index].id == action.actor_id then
							-- ['Main job']=0,['Sub job']=0
							local level = 0
							if member_table[index]['Main job'] == 'WAR' then
								level = member_table[index]['Main job level']
							elseif member_table[index]['Sub job'] == 'WAR' then
								level = member_table[index]['Sub job level']
							end
							local att_boost = math.floor((level / 4) + 4.75) / 256
							-- must make value as n/1024 for calculation later
							att_boost = att_boost  * 1024
							
							member_table[index] = {id = member_table[index].id, name = member_table[index].name, mob = member_table[index].mob,  Last_Spell = 'Warcry', 
																	effect = "Attack perc", value = att_boost, 
																	['Main job']=member_table[index]['Main job'], ['Main job level']=member_table[index]['Main job level'],
																	['Sub job']=member_table[index]['Sub job'], ['Sub job level']=member_table[index]['Sub job level'], 
																	buffs=member_table[index].buffs, indi=member_table[index].indi, geo=member_table[index].geo, pet=member_table[index].pet}	
							break			
						end
					end
				end
			end
		end
	end
	
	
	if action.category == 7 and ((actor.is_npc and actor.charmed) or not actor.is_npc) then
		for index, target in pairs(action.targets) do
			if type(target) == "table" then
				local job_abil = res.job_abilities:with('id', target.actions[1].param)
				 -- Garuda is doing Hastega / II, need to check who garuda belongs to
				for index, m_table in pairs(member_table) do
					if member_table[index].id == target.id then
						Pet_belongs_to = index
						break
					end
				end
			end
		end		
	end
	--pet abilities
	if action.category == 13 and ((actor.is_npc and actor.charmed) or not actor.is_npc) and (action.param < 781 and action.param > 15 )then
		--table.vprint(action)
		local job_abil = res.job_abilities:with('id', action.param)
		if spells_to_watch:contains(job_abil.en) then -- Garuda Hastega / II
			for index, target in pairs(action.targets) do
				if type(target) == "table" then
					if target.id == player.id then
						if Pet_belongs_to then
							member_table[Pet_belongs_to].Last_Spell = job_abil.en
							Pet_belongs_to = nil
						end
					end
				end
			end
		end
	end
	if action.category == 4 and ((actor.is_npc and actor.charmed) or not actor.is_npc) and (action.param < 879 and action.param > 0 ) then
		local spell = res.spells:with('id', action.param)
		for index, target in pairs(action.targets) do
			if type(target) == "table" then
				--if target.id == player.id then
					if spells_to_watch:contains(spell.en) then
						for index, m_table in pairs(member_table) do
							if member_table[index].id == action.actor_id then
								member_table[index].Last_Spell = spell.en
							end
							--Indi spells, must associate person with indi
							if table.containskey(Geo_Spells, spell.id) and member_table[index].id == action.actor_id and spell.en:contains('Indi-') then
								-- check for indi enhancing buffs if the caster is also the recipient
								local boost = 1
								if target.id == action.actor_id then
									-- if caster has buff then add bonus
									if member_table[index].bolster then
										notice('Bolster detected, Boosting '..spell.en)
										boost = 2
									end
									member_table[index].indi = {id = spell.id, caster = windower.ffxi.get_mob_by_id(action.actor_id).name, boost = boost}
									break
								else
									member_table[index].indi = {id = spell.id, caster = windower.ffxi.get_mob_by_id(action.actor_id).name, boost = boost}
									break
								end			
							end
							--Geo spells, must associate person with geo
							if table.containskey(Geo_Spells, spell.id) and member_table[index].id == action.actor_id and spell.en:contains('Geo-') then
								local boost = 1
									-- if caster has buff then add bonus
								if member_table[index].BoG then -- blaze of glory
									--notice('BoG detected, Boosting '..spell.en)
									boost = boost + 0.5
									member_table[index].BoG = nil
								end
								if member_table[index].bolster then
									--notice('Bolster detected, Boosting '..spell.en)
									boost = 2
								end
								member_table[index].geo = {id = spell.id, caster = windower.ffxi.get_mob_by_id(action.actor_id).name, boost = boost}
								member_table[index].pet = {incoming = true, }
								--table.vprint(member_table[index].geo)
								--notice(index .. '  ' .. member_table[index].geo.id)
								break
							end
						end
					end
				--end
			end
		end
	end
end

windower.register_event('action', function(act)
	if windower.ffxi.get_info().logged_in then
		on_action(act)
	end
end)

function check_player_movement(player)
	if player.position == nul then
		player.position = T{} 
		player.position = {x = 0, y = 0, x = 0} 
	end
	if windower.ffxi.get_mob_by_index(player.index) ~= null then
        current_pos_x = windower.ffxi.get_mob_by_index(player.index).x
        current_pos_y = windower.ffxi.get_mob_by_index(player.index).y
		current_pos_z = windower.ffxi.get_mob_by_index(player.index).z
		if player.position.x ~= current_pos_x and player.position.y ~= current_pos_y then
			player.is_moving = true
		else
			player.is_moving = false
		end
		player.position.x = current_pos_x
		player.position.y = current_pos_y
		player.position.z = current_pos_z
	end
	
	return player.is_moving
end