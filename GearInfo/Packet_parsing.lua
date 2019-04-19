
-- function get_packet_data()
		
	-- data = windower.packets.last_incoming(0x062)
	-- if data == nil then
        -- return
    -- end
	-- packet = packets.parse('incoming', data)
	
	-- -- packet is capitalised 'Great Katana Level'
	-- -- player skill = 'great_katana'
	-- if player.skill == nil then
		-- player.skill = player.skills
	-- end

	-- for k,v in pairs(packet) do
		-- --notice(k .. ' = ' ..tostring(v)) 
		-- for i,j in pairs(skills_from_resources) do
			-- if k == j.en ..' Level' and v ~= nil and player.skill[string.gsub(j.en:lower(), ' ', '_')] ~= nil then
				-- if player.skill[string.gsub(j.en:lower(), ' ', '_')] > v then
					-- if count == 0 then 
						-- --log(k .. ' = ' ..v) 
						-- count = count + 1 
					-- end
					-- player.skill[string.gsub(j.en:lower(), ' ', '_')] = v
				-- end
			-- end
		-- end
	-- end
-- end

parse = {
    i={}, -- Incoming packets
    o={}  -- Outgoing packets, currently none are really parsed for information
    }
	
parse.i[0x00A] = function (data)
	-- player.stats = {
		-- STR = data:unpack('H',0xCD), 
		-- DEX = data:unpack('H',0xCF), 
		-- VIT = data:unpack('H',0xD1), 
		-- AGI = data:unpack('H',0xD3), 
		-- INT = data:unpack('H',0xD5), 
		-- MND = data:unpack('H',0xD7), 
		-- CHR = data:unpack('H',0xD9) 
	-- }
	-- notice('Player stat update | agi = '..player.stats.DEX)
	blank_0x063_v9_inc = true
end
	
parse.i[0x061] = function (data)	
	player.stats = {
		STR = data:unpack('H',0x15), 
		DEX = data:unpack('H',0x17), 
		VIT = data:unpack('H',0x19), 
		AGI = data:unpack('H',0x1B), 
		INT = data:unpack('H',0x1D), 
		MND = data:unpack('H',0x1F), 
		CHR = data:unpack('H',0x21) 
	} 
	--notice('Player stat update | agi = '..player.stats.AGI)
end

parse.i[0x062] = function (data)
    for i = 1,0x71,2 do
        local skill = data:unpack('H',i + 0x82)%32768
        local current_skill = res.skills[math.floor(i/2)+1]
        if current_skill then
            player.skills[to_windower_api(current_skill.english)] = skill
        end
    end
	get_player_skill_in_gear(check_equipped())
	--notice('Skill packet update')
end

function check_these_buffs(x, y)
	
	local new_buffs = table.copy(x)
	local old_buffs = table.copy(y)
	
	if new_buffs == nil then 
		return
	end
	if old_buffs == nil then 
		return
	end

	--local buffs_to_ignore = T{"Level Restriction", "Battlefield", "Vorseal", "Elvorseal", "Voidwatcher", "Colure Active", "Ensphere", "encumbrance", "impairment", "Omerta", "debilitation", 
	-- 										"Pathos", "Avatar's Favor", "Avoidance Down"}
	local buffs_to_ignore = T{143, 254, 602, 603, 475, 612, 476, 259, 261, 262, 263, 264, 431, 572}
	
	for n, new in pairs(new_buffs) do
		new_buffs[n].matched = nil
		for i, old in pairs(old_buffs) do
			if new.id == old.id and not old.matched and not buffs_to_ignore:contains(new.id) and not buffs_to_ignore:contains(old.id) then
				new_buffs[n].matched = true
				old_buffs[i].matched = true
				new_buffs[n].time_diff = new.time - old.time
				if debug_mode then notice(new_buffs[n].name..' time difference ' ..new_buffs[n].time_diff) end
				break
			end			
		end
	end
	
	local all_matched = false
	
	for n, new in pairs(new_buffs) do
		if new.matched then
			all_matched = true
		else
			new_buffs[n].not_matched = true
			new_buffs[n].time_diff = 0
			all_matched = false
		end
	end
	
	local matched_time_Diff = 0
	local time_match = false
	local max_l = table.length(new_buffs)
	local increment = 0	
	local no_match_increment = 0
	
	--if max_l ~= nil then
		for i = 1 , max_l do
			for j = 1 , max_l do 
				if i ~= j then
					if new_buffs[i] and new_buffs[j] then
						if not buffs_to_ignore:contains(new_buffs[i].id) and not buffs_to_ignore:contains(new_buffs[j].id) then
							if debug_mode then print(new_buffs[j].name .. ' matched #1') end
							if new_buffs[i].matched and new_buffs[j].matched then
								if debug_mode then print(new_buffs[j].name .. ' matched #2') end
								if math.abs(new_buffs[i].time_diff - new_buffs[j].time_diff) <= 1 then
									matched_time_Diff = matched_time_Diff + new_buffs[i].time_diff
									increment = increment + 1
									time_match = true
									if debug_mode then print(new_buffs[j].name .. ' matched #3') end
								else
									if new_buffs[i].time_diff - new_buffs[j].time_diff < -1 and not buffs_to_ignore:contains(new_buffs[i].id) and not buffs_to_ignore:contains(new_buffs[j].id) then
										new_buffs[j].not_matched = true
										if debug_mode then print(new_buffs[j].name .. ' not matched <') end
									elseif new_buffs[i].time_diff - new_buffs[j].time_diff > 1 and not buffs_to_ignore:contains(new_buffs[i].id) and not buffs_to_ignore:contains(new_buffs[j].id) then
										new_buffs[i].not_matched = true
										if debug_mode then print(new_buffs[i].name .. ' not matched >') end
									end
									time_match = false
								end
							end
						end
					end
				end
			end
		end
	-- else
		-- time_match = true
	--end
	for i = 1 , max_l do
		if new_buffs[i] then
			if new_buffs[i].not_matched and not buffs_to_ignore:contains(new_buffs[i].id) then
				no_match_increment = no_match_increment + 1
				time_match = false
				if debug_mode then print(new_buffs[i].name .. ' not matched') end
			end
		end
	end
	
	if time_match then
		if debug_mode then print('All times matched') end
		-- all buffs have matched and time increases are all the same, assume a buff dropped or there was a time shift to all buffs
		for n,new in pairs(new_buffs) do
			for i,old in pairs(_ExtraData.player.buff_details) do
				if old.id == new.id and not buffs_to_ignore:contains(new.id) and not buffs_to_ignore:contains(old.id) and not old.time_added and not new.time_added then
					if debug_mode then print(new_buffs[n].name .. ' increased time by ' .. new_buffs[n].time_diff) end
					_ExtraData.player.buff_details[i].time = _ExtraData.player.buff_details[i].time + new_buffs[n].time_diff
					_ExtraData.player.buff_details[i].time_added = true
					new_buffs[n].time_added = true
					break
				end
			end
		end	
	else
		if no_match_increment < 2 and (table.length(new_buffs) - no_match_increment) > 1 then
			-- all buffs have matched and time increases are all the same EXEPT 1, 
			-- assume we changed a floor or used a waypoint and all the old buffs had a time shift
			if debug_mode then print('1 new unmatched buff') end
			for n,new in pairs(new_buffs) do
				for i,old in pairs(_ExtraData.player.buff_details) do
					if old.id == new.id and not new.not_matched and not buffs_to_ignore:contains(new.id) and not buffs_to_ignore:contains(old.id) and not old.time_added and not new.time_added then
						if debug_mode then print(new_buffs[n].name .. ' increased time by ' .. new_buffs[n].time_diff) end
						_ExtraData.player.buff_details[i].time = _ExtraData.player.buff_details[i].time + new_buffs[n].time_diff
						_ExtraData.player.buff_details[i].time_added = true
						new_buffs[n].time_added = true
						break
					end
				end
			end
		else
			if debug_mode then print('no match') end
			-- nothing has matched, even if there was a time delay, there was too many discrepencies
		end
	end
	
	for n, new in pairs(_ExtraData.player.buff_details) do
		_ExtraData.player.buff_details[n].time_added = nil
	end
end

parse.i[0x063] = function (data)
	if data:byte(0x05) == 0x09 and blank_0x063_v9_inc then
        -- After zoning, players receive a blank 0x063 v9 packet
        -- (because their buff line is temporarily empty)
        -- So this flag is set in 0x00A 
        blank_0x063_v9_inc = false
        -- However, players can also reload gearswap and fail to get a 0x063 v9 packet from
        -- windower.packets.last_incoming, which leaves them without buff information but with a
        -- informative 0x063 v9 packet coming next. So this step checks confirms the packet is
        -- empty before returning
        if data:sub(0x49,0xC8) == string.char(0):rep(128) then
            return
        end
    end
    if data:byte(0x05) == 0x09 then
		
        local newbuffs = {}
        for i=1,32 do
            local buff_id = data:unpack('H',i*2+7)
            if buff_id ~= 255 and buff_id ~= 0 then -- 255 is used for "no buff"
				local t = data:unpack('I',i*4+0x45)/60+501079520+1009810800
                --local t = data:unpack('I',i*4+0x45)/60+1439307535
				newbuffs[i] = setmetatable({
                    name=res.buffs[buff_id].name,
                    buff=res.buffs[buff_id],
                    id = buff_id,
                    time = t,
					date=os.date('*t',t),
                    },
                    {__index=function(t,k)
                        if k and k=='duration' then
                            return rawget(t,'time')-os.time()
                        else
                            return rawget(t,k)
                        end
                    end})     
            end
        end
		
        if seen_0x063_type9 then
			
			check_these_buffs(newbuffs, _ExtraData.player.buff_details)
			-- table.vprint(_ExtraData.player.buff_details)
			
            -- Look for exact matches
            for n,new in pairs(newbuffs) do
                newbuffs[n].matched_exactly = nil
                for i,old in pairs(_ExtraData.player.buff_details) do
                    -- Find unchanged buffs
                    if old.id == new.id and math.abs(old.time-new.time) < 1 and not old.matched_exactly then
						if debug_mode and (newbuffs[n].name == 'Haste' or newbuffs[n].name == 'March') then
							notice('Exact match '..newbuffs[n].name..' ' ..old.time .. ' - ' .. new.time .. ' = ' .. math.abs(old.time-new.time) )
						end
						local temp_time = newbuffs[n].time
						local temp_date = newbuffs[n].date
						table.reassign(newbuffs[n],_ExtraData.player.buff_details[i])
                        newbuffs[n].matched_exactly = true
                        _ExtraData.player.buff_details[i].matched_exactly = true
						newbuffs[n].time = temp_time
						newbuffs[n].date = temp_date
						for Character_name, Character_table in pairs(member_table) do
							if table.containskey(Character_table, "Last_Spell") and Character_table.Last_Spell ~= '' and Character_table.value ~= 0 and Character_table.effect ~= '' then
								if newbuffs[n].name == Character_table.Last_Spell then
									newbuffs[n].full_name = Character_table.Last_Spell
									newbuffs[n].Caster = Character_name:lower()
									newbuffs[n].effect = Character_table.effect
									newbuffs[n].value = Character_table.value
									member_table[Character_name].Last_Spell = ''
									member_table[Character_name].effect = ''
									member_table[Character_name].value = 0
									break
								end
							end
						end
                        break
                    end
                end
            end

            -- Look for time-independent matches, which are assumedly a spell overwriting itself
            for n,new in pairs(newbuffs) do
                newbuffs[n].matched_imprecisely = nil
                if not new.matched_exactly then
                    for i,old in pairs(_ExtraData.player.buff_details) do
                        -- Buffs can be overwritten
                        if old.id == new.id and not (old.matched_exactly or old.matched_imprecisely) then
							if debug_mode and (newbuffs[n].name == 'Haste' or newbuffs[n].name == 'March') then
								notice('Overwrite '..newbuffs[n].name..' ' ..old.time .. ' - ' .. new.time .. ' = ' .. math.abs(old.time-new.time) )
							end
                            newbuffs[n].matched_imprecisely = true
                            _ExtraData.player.buff_details[i].matched_imprecisely = true
							_ExtraData.player.buff_details[i]['reported'] = false
							newbuffs[n]['reported'] = false
                            break
                        end
                    end
                end
            end
			local Buff_association = {
					Haste = {'Haste', 'Haste II', 'Hastega', 'Hastega II', "Erratic Flutter", 'Refueling'},
					March = {'Honor March', 'Victory March', 'Advancing March'},
					Ballad = {"Mage's Ballad", "Mage's Ballad II", "Mage's Ballad III",},
					Minuet = {'Valor Minuet', 'Valor Minuet I', 'Valor Minuet II', 'Valor Minuet IV', 'Valor Minuet V',},
					Madrigal = {'Sword Madrigal', 'Blade Madrigal',},
					Paeon = {"Army's Paeon", "Army's Paeon II", "Army's Paeon III", "Army's Paeon IV", "Army's Paeon V", "Army's Paeon VI",},
					Minne = {"Knight's Minne", "Knight's Minne II", "Knight's Minne III", "Knight's Minne IV", "Knight's Minne V",},
					Prelude = {"Hunter's Prelude", "Archer's Prelude",},
					Mambo = {'Sheepfoe Mambo', 'Dragonfoe Mambo',},
					Mazurka = {'Raptor Mazurka', 'Chocobo Mazurka',},
					Etude = {'Sinewy Etude', 'Dextrous Etude', 'Vivacious Etude', 'Quick Etude', 'Learned Etude', 'Spirited Etude', 'Enchanting Etude', 
									'Herculean Etude', 'Uncanny Etude', 'Vital Etude', 'Swift Etude', 'Sage Etude', 'Logical Etude', 'Bewitching Etude', },
					Carol = {'Fire Carol', 'Ice Carol', 'Wind Carol', 'Earth Carol', 'Lightning Carol', 'Water Carol', 'Light Carol', 'Dark Carol',
									'Fire Carol II', 'Ice Carol II', 'Wind Carol II', 'Earth Carol II', 'Lightning Carol II', 'Water Carol II', 'Light Carol II', 'Dark Carol II',},
					--Slow = {'Slow','Slow II','Slowga','Slowga II',},
				}
			
			for n,new in pairs(newbuffs) do
                if new.matched_exactly then
                    newbuffs[n].matched_exactly = nil
                elseif new.matched_imprecisely then
                    newbuffs[n].matched_imprecisely = nil
                    -- Matched a previous buff, but the time didn't jive so it's assumed
                    -- that it was overwritten with the same status effect
					for Character_name, Character_table in pairs(member_table) do
						if table.containskey(Character_table, "Last_Spell") and Character_table.Last_Spell ~= '' and table.containskey(Buff_association, newbuffs[n].name) then
							if table.contains(Buff_association[newbuffs[n].name] , Character_table.Last_Spell ) or newbuffs[n].name == Character_table.Last_Spell then
								newbuffs[n].full_name = Character_table.Last_Spell
								newbuffs[n].Caster = Character_name:lower()
								if table.containskey(Character_table, 'SV') and Character_table.SV then
									newbuffs[n].SV = Character_table.SV
								end
								local spell = res.spells:with('en', newbuffs[n].full_name)
								if table.containskey(Character_table, 'Marcato') and Character_table.Marcato and spell.type == 'BardSong' then
									newbuffs[n].Marcato = Character_table.Marcato
									member_table[Character_name].Marcato = false									
								end
								member_table[Character_name].Last_Spell = ''
								break
							end
						elseif table.containskey(Character_table, "Last_Spell") and Character_table.Last_Spell ~= '' and Character_table.value ~= 0 and Character_table.effect ~= '' then
							if newbuffs[n].name == Character_table.Last_Spell then
								newbuffs[n].full_name = Character_table.Last_Spell
								newbuffs[n].Caster = Character_name:lower()
								newbuffs[n].effect = Character_table.effect
								newbuffs[n].value = Character_table.value
								member_table[Character_name].Last_Spell = ''
								member_table[Character_name].effect = ''
								member_table[Character_name].value = 0
							end
						end
					end
                else
                    -- Not matched, so it's assumed the buff is new
					for Character_name, Character_table in pairs(member_table) do
						if table.containskey(Character_table, "Last_Spell") and Character_table.Last_Spell ~= '' and table.containskey(Buff_association, newbuffs[n].name) then
							if table.contains(Buff_association[newbuffs[n].name] , Character_table.Last_Spell ) or newbuffs[n].name == Character_table.Last_Spell then
								newbuffs[n].full_name = Character_table.Last_Spell
								newbuffs[n].Caster = Character_name:lower()
								if table.containskey(Character_table, 'SV') and Character_table.SV then
									newbuffs[n].SV = Character_table.SV
								end
								local spell = res.spells:with('en', newbuffs[n].full_name)
								if table.containskey(Character_table, 'Marcato') and Character_table.Marcato and spell.type == 'BardSong' then
									newbuffs[n].Marcato = Character_table.Marcato
									member_table[Character_name].Marcato = false									
								end
								member_table[Character_name].Last_Spell = ''
								break
							end
						elseif table.containskey(Character_table, "Last_Spell") and Character_table.Last_Spell ~= '' and Character_table.value ~= 0 and Character_table.effect ~= '' then
							if newbuffs[n].name == Character_table.Last_Spell then
								newbuffs[n].full_name = Character_table.Last_Spell
								newbuffs[n].Caster = Character_name:lower()
								newbuffs[n].effect = Character_table.effect
								newbuffs[n].value = Character_table.value
								member_table[Character_name].Last_Spell = ''
								member_table[Character_name].effect = ''
								member_table[Character_name].value = 0
							elseif newbuffs[n].name == 'Bust' then
								newbuffs[n].full_name = Character_table.Last_Spell
								newbuffs[n].Caster = Character_name:lower()
								newbuffs[n].effect = Character_table.effect
								newbuffs[n].value = Character_table.value
								member_table[Character_name].Last_Spell = ''
								member_table[Character_name].effect = ''
								member_table[Character_name].value = 0
							end
						end
					end
					if newbuffs[n].name == 'Marcato' then
						member_table[player.name].Marcato = true
					end
					if newbuffs[n].name == "Soul Voice" then
						member_table[player.name].SV = true
					end
					if newbuffs[n].name == "Blaze of Glory" then
						member_table[player.name].BoG = true
					end
					if newbuffs[n].name == "Bolster" then
						member_table[player.name].Bolster = true
					end
                end
            end
            
			for n,new in pairs(newbuffs) do
				if not table.containskey(newbuffs[n], "full_name") then
					newbuffs[n].full_name = newbuffs[n].name
				end
			end	
			
            for i,old in pairs(_ExtraData.player.buff_details) do
                if not (old.matched_exactly or old.matched_imprecisely) then
                    -- Old status was not matched to any new status, so it's assumed it was lost
					local spell = res.spells:with('en', old.full_name)
					-- for k, v in pairs(member_table) do
						-- if v.geo and v.geo.id and Geo_Spells[v.geo.id].buff.id == old.id and not v.mob.pet_index then
							-- member_table[k].geo = {}
							-- --notice('wipped geo')
						-- end
					-- end
					
					if spell then
						if spell.type == 'BardSong' then
							notice('Lost '..spell.en)
						end
					end
					if old.full_name == 'Marcato' then member_table[windower.ffxi.get_mob_by_id(player.id).name].Marcato = false end
					if old.full_name == 'Soul Voice' then member_table[windower.ffxi.get_mob_by_id(player.id).name].SV = false end
					if old.full_name == "Blaze of Glory" then member_table[windower.ffxi.get_mob_by_id(player.id).name].BoG = nil end
					if old.full_name == "Bolster" then member_table[windower.ffxi.get_mob_by_id(player.id).name].Bolster = nil end
					if not res.buffs[old.id] then
                        error('GearInfo: No known status for buff id #'..tostring(old.id))
                    end
                end
            end
        end
        
        table.reassign(_ExtraData.player.buff_details,newbuffs)
        for i=1,32 do
			player.buffs[i] = (newbuffs[i] and newbuffs[i].id) or nil
			
        end
		for index, buff in pairs(_ExtraData.player.buff_details) do
			if buff.name == "March" then
				if table.containskey(buff, "full_name") then
					--log('buff name = "' .. buff.full_name .. '" : ' .. buff.total_duration)
				end
			end
			if table.containskey(buff, "full_name") then
				--log('buff name = "' .. buff.full_name .. '" : ' .. buff.total_duration)
			end
		end
		--table.vprint(_ExtraData.player.buff_details)
		--table.vprint(member_table[player.name])
        -- Cannot reliably recall this packet using last_incoming on load because there
        -- are 9 version of it and you only get the last one. Hence, this flag:
		seen_0x063_type9 = true
		--check_buffs()
    end
end

function convert_date(time_1, time_2)
	local seconds = time_2.sec - time_1.sec
	local minuits = time_2.min - time_1.min
	local hours = time_2.hour - time_1.hour
	
	return ((hours * 60 * 60) + (minuits * 60) + seconds)
	
end


function update_party()
	
	local old = member_table
	local new = {}
	
	member_table = {}
	
	local party = windower.ffxi.get_party()

    local key_indices = {'p0', 'p1', 'p2', 'p3', 'p4', 'p5',}
   
    for k = 1, 6 do
        local member = party[key_indices[k]]
        if member and member.mob then
			new[member.mob.name] = {id = member.mob.id , name = member.mob.name, Last_Spell = '' , effect ='', value = 0, mob = member.mob, ['Main job']=0,['Main job level']=0,['Sub job']=0,['Sub job level']=0,buffs={}, indi={}, geo={}, pet={incoming = false,},}
        end
	end
	
	for new_name, new_member in pairs(new) do
		for old_name, old_member in pairs(old) do
			if old_name == new_name then
				new[old_name] = {id = old_member.id , name = old_member.name, Last_Spell = old_member.Last_Spell , effect = old_member.effect, value = old_member.value, 
												mob = new_member.mob, ['Main job'] = old_member['Main job'], ['Main job level'] = old_member['Main job level'], ['Sub job'] = old_member['Sub job'], ['Sub job level'] = old_member['Sub job level'], 
												buffs=old_member.buffs, indi=old_member.indi, geo=old_member.geo, pet=old_member.pet, }
				if old[old_name].Marcato then new[old_name].Marcato = true end
				if old[old_name].SV then new[old_name].SV = true end
				if old[old_name].BoG then new[old_name].BoG = true end	
				if old[old_name].bolster then new[old_name].bolster = true end
				if old_name == 'Cornelia' and old[old_name]['mob'] and old[old_name]['mob']['charmed'] then
					new[old_name].indi = {id=817, caster=party[key_indices[1]].mob.name, boost = 1}
				elseif old_name == 'Kupofried' and old[old_name]['mob'] and old[old_name]['mob']['charmed'] then
					new[old_name].indi = {id=818, caster=party[key_indices[1]].mob.name, boost = 1}
				elseif old_name == 'Brygid' and old[old_name]['mob'] and old[old_name]['mob']['charmed'] then
					new[old_name].indi = {id=819, caster=party[key_indices[1]].mob.name, boost = 1}
				elseif old_name == 'KuyinHathdenna' and old[old_name]['mob'] and old[old_name]['mob']['charmed'] then
					new[old_name].indi = {id=820, caster=party[key_indices[1]].mob.name, boost = 1}
				elseif old_name == 'Moogle' and old[old_name]['mob'] and old[old_name]['mob']['charmed'] then
					new[old_name].indi = {id=821, caster=party[key_indices[1]].mob.name, boost = 1}
				elseif old_name == 'Sakura' and old[old_name]['mob'] and old[old_name]['mob']['charmed'] then
					new[old_name].indi = {id=822, caster=party[key_indices[1]].mob.name, boost = 1}
				elseif old_name == 'StarSibyl' and old[old_name]['mob'] and old[old_name]['mob']['charmed'] then
					new[old_name].indi = {id=823, caster=party[key_indices[1]].mob.name, boost = 1}
				end
			end
		end
	end
	
	for new_name, new_member in pairs(new) do
		if new_member.id == player.id then
			new[new_name]['Main job'] = player.main_job
			new[new_name]['Main job level'] = player.main_job_level
			if new[new_name]['Sub job'] then
				new[new_name]['Sub job'] = player.sub_job
				new[new_name]['Sub job level'] = player.sub_job_level
			else
				new[new_name]['Sub job'] ='NON'
			end
		elseif party_from_packet[new_member.id] and new_member.id ~= player.id then
			new[new_name]['Main job'] = res.jobs:with('id', party_from_packet[new_member.id]['Main job']).ens
			new[new_name]['Main job level'] = party_from_packet[new_member.id]['Main job level']
			new[new_name]['Sub job'] = res.jobs:with('id', party_from_packet[new_member.id]['Sub job']).ens
			new[new_name]['Sub job level'] = party_from_packet[new_member.id]['Sub job level']
			if new_name == 'Cornelia' and new[new_name]['mob'] and new[new_name]['mob']['charmed'] then
				new[new_name].indi = {id=817, caster=party[key_indices[1]].mob.name, boost = 1}
			elseif new_name == 'Kupofried' and new[new_name]['mob'] and new[new_name]['mob']['charmed'] then
				new[new_name].indi = {id=818, caster=party[key_indices[1]].mob.name, boost = 1}
			elseif new_name == 'Brygid' and new[new_name]['mob'] and new[new_name]['mob']['charmed'] then
				new[new_name].indi = {id=819, caster=party[key_indices[1]].mob.name, boost = 1}
			elseif new_name == 'KuyinHathdenna' and new[new_name]['mob'] and new[new_name]['mob']['charmed'] then
				new[new_name].indi = {id=820, caster=party[key_indices[1]].mob.name, boost = 1}
			elseif new_name == 'Moogle' and new[new_name]['mob'] and new[new_name]['mob']['charmed'] then
				new[new_name].indi = {id=821, caster=party[key_indices[1]].mob.name, boost = 1}
			elseif new_name == 'Sakura' and new[new_name]['mob'] and new[new_name]['mob']['charmed'] then
				new[new_name].indi = {id=822, caster=party[key_indices[1]].mob.name, boost = 1}
			elseif new_name== 'StarSibyl' and new[new_name]['mob'] and new[new_name]['mob']['charmed'] then
				new[new_name].indi = {id=823, caster=party[key_indices[1]].mob.name, boost = 1}
			end
		end
	end
	
	member_table = new
	
end

-- party update packet
	
parse.i[0x0DD] = function (data)

	-- {ctype='unsigned int',      label='ID',                 fn=id},             -- 04
    -- {ctype='unsigned int',      label='HP'},                                    -- 08
    -- {ctype='unsigned int',      label='MP'},                                    -- 0C
    -- {ctype='unsigned int',      label='TP',                 fn=percent},        -- 10
    -- {ctype='unsigned short',    label='Flags',              fn=bin+{2}},        -- 14
    -- {ctype='unsigned short',    label='_unknown1'},                             -- 16
    -- {ctype='unsigned short',    label='Index',              fn=index},          -- 18
    -- {ctype='unsigned short',    label='_unknown2'},                             -- 1A
    -- {ctype='unsigned char',     label='_unknown3'},                             -- 1C
    -- {ctype='unsigned char',     label='HP%',                fn=percent},        -- 1D
    -- {ctype='unsigned char',     label='MP%',                fn=percent},        -- 1E
    -- {ctype='unsigned char',     label='_unknown4'},                             -- 1F
    -- {ctype='unsigned short',    label='Zone',               fn=zone},           -- 20
    -- {ctype='unsigned char',     label='Main job',           fn=job},            -- 22
    -- {ctype='unsigned char',     label='Main job level'},                        -- 23
    -- {ctype='unsigned char',     label='Sub job',            fn=job},            -- 24
    -- {ctype='unsigned char',     label='Sub job level'},                         -- 25
    -- {ctype='char*',             label='Name'},                                  -- 26
	
	local packet = packets.parse('incoming', data)
	party_from_packet[packet['ID']] = {id = packet['ID'] , name = packet['Name'], ['Main job'] = packet['Main job'], ['Main job level'] = packet['Main job level'], ['Sub job'] = packet['Sub job'], ['Sub job level'] = packet['Sub job level'],} 
	--table.vprint(packet)
	-- ['Main job level'] = packet['Main job level'], ['Sub job level'] = packet['Sub job level']}
end

parse.i[0x076] = function (data)
    -- buff marcato = 231, soul voice = 52 , "Troubadour" = 348 
	local SV = false
	local bolster = false
	local party_buffs = {}
	for  k = 0, 4 do
		if data:unpack('I',k*48+5) == 0 then
            break
        else
			local member_id = data:unpack('I', k*48+5+0)
			party_buffs[member_id] ={}
			local mem_t = {}
			for index, m_table in pairs(member_table) do
				if member_table[index].id == member_id then
					mem_t = member_table[index]
					break
				end
			end
			
			if member_id ~= 0 then
			
				for i = 1, 32 do
					local _buff_id = data:byte(k*48+5+16+i-1) + 256*( math.floor( data:byte(k*48+5+8+ math.floor((i-1)/4)) / 4^((i-1)%4) )%4)
					if _buff_id ~= 255 then
						party_buffs[member_id][i] = _buff_id
					end
					if _buff_id == 231 then 
						mem_t.Marcato = true
					end
					if _buff_id == 569 then 
						mem_t.BoG = true
					end
					if _buff_id == 513 then 
						mem_t.Bolster = true
						bolster = true
					end
					if _buff_id == 52 then 
						mem_t.SV = true
						SV = true
					end
				end
				
				if SV == false then
					mem_t.SV = nil
				end
				if bolster == false then
					mem_t.bolster = nil
				end
			end
			mem_t['buffs'] = {}
			for mem_id, v in pairs(party_buffs) do
				if mem_id == mem_t.id then
					for i = 1, 32 do
						if v[i] then
							mem_t['buffs'][v[i]] = {id = v[i], en = res.buffs:with('id', v[i]).en} --en = res.buffs:with('id', v[i]).en}
						end
					end
				end
			end
			
			-- check if memebr still has colore active, if not delete it
			if mem_t.indi and party_buffs[member_id] then
				if not table.contains(party_buffs[member_id], 612)then
					mem_t.indi = {}
				end
			end
			-- if mem_t.geo and party_buffs[member_id] then
				-- if not mem_t.mob.pet_index then
					-- mem_t.geo = {}
				-- end
			-- end
			
		end
	end
	
	--table.vprint(member_table)
end

-- pet tracking packet, doesnt work for my use
-- parse.i[0x067] = function (data)
	-- local packet = packets.parse('incoming', data)
	-- --table.vprint(packet)
	-- for k, v in pairs(member_table) do
		-- if v.mob and v.mob.pet_index then
			-- notice(packet['Pet Index'] .. ' '..v.mob.pet_index.. ' '..v.mob.name)
		-- end
	-- end
	-- if packet['Owner Index'] ~= 0 then
	-- --table.vprint(packet)
		-- if member_table[windower.ffxi.get_mob_by_index(packet['Owner Index']).name] then
			-- --notice(windower.ffxi.get_mob_by_index(packet['Owner Index']).name )
			-- if packet['Current HP%'] == 0 and packet['Pet Index'] == 0 and member_table[windower.ffxi.get_mob_by_index(packet['Owner Index']).name].geo then
				-- member_table[windower.ffxi.get_mob_by_index(packet['Owner Index']).name].geo = {}
				-- notice(windower.ffxi.get_mob_by_index(packet['Owner Index']).name .. '\'s pet died')
			-- end
		-- end
	-- end
-- end

-- pet tracking packet, only works for the player, not party members
-- parse.i[0x068] = function (data)
	-- local packet = packets.parse('incoming', data)
	-- -- table.vprint(packet)
	-- if member_table[windower.ffxi.get_mob_by_id(packet['Owner ID']).name] then
		-- if packet['Current HP%'] == 0 and packet['Pet Index'] == 0 and member_table[windower.ffxi.get_mob_by_id(packet['Owner ID']).name].geo then
			-- if member_table[windower.ffxi.get_mob_by_id(packet['Owner ID']).name].geo.caster == windower.ffxi.get_mob_by_id(packet['Owner ID']).name then
				-- member_table[windower.ffxi.get_mob_by_id(packet['Owner ID']).name].geo = {}
				-- --notice(windower.ffxi.get_mob_by_id(packet['Owner ID']).name .. '\'s pet died')
			-- end
		-- end
	-- end
-- end

-- parse.i[0x05B] = function (data)
	-- local packet = packets.parse('incoming', data)
	-- table.vprint(packet)
-- end

-- spawn / despawn packet (not usefull for pet tracking)
-- parse.i[0x038] = function (data)
	-- local packet = packets.parse('incoming', data)
	-- if packet.Type == 'deru' then
		-- notice(packet['Mob Index'])
	-- end
	-- if packet.Type == 'kesu' then
		-- notice(packet['Mob Index'])
	-- end
-- end


-- Party list request (4 byte packet)
-- fields.outgoing[0x078] = L{
-- }

function initialize_packet_parsing()
    for i,v in pairs(parse.i) do
        local lastpacket = windower.packets.last_incoming(i)
        if lastpacket then
            v(lastpacket)
        end
		if i == 0x63 and lastpacket and lastpacket:byte(5) ~= 9 then
            -- Not receiving an accurate buff line on load because the wrong 0x063 packet was sent last
            
        end
    end
end