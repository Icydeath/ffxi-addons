buff_info = {h_spikes = false }

function check_buffs()
	
	-- check party members for pet (luopan) and if they have a geo bubble cast recently as they dont appear instantly
	for k, v in pairs(member_table) do
		if v.pet and v.pet.incoming then
			if v.mob.pet_index and v.geo and v.geo.id then
				--notice('pet found: '..v.mob.pet_index)
				member_table[k].pet['pet index'] = v.mob.pet_index
				member_table[k].pet.incoming = false
			end
		elseif v.pet and v.pet.incoming == false then
			if not v.mob.pet_index and v.geo and v.geo.id and v.pet['pet index'] then
				--notice('pet lost: '..v.name..' '..member_table[k].pet['pet index'])
				member_table[k].pet['pet index'] = nil
				member_table[k].geo = {}
			end
		end
	end
	
	local duplicate_id = {}
	local Ionis_zones = S{256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,281,282,283,284,285,}
	local marches = {417, 419, 420}
	marches[417] = 126
	marches[419] = 107
	marches[420] = 163
	local total_haste = 0
	local song_found = false
	local song_found2 = false
	
	for index, buff in pairs(_ExtraData.player.buff_details) do
		--print(buff.name, buff['full_name'] or '')
		local this_buff = _ExtraData.player.buff_details[index]
		if buff.id == 1 then -- weakness
			this_buff['ma_haste'] = -1024
		end
		if buff.id == 13 then -- slow or slow2
			this_buff['ma_haste'] = -300
		end
		if buff.id == 565 then -- indi-slow or geo-slow
			this_buff['ma_haste'] = -204
		end
		if buff.id == 194 then -- elegy
			this_buff['ma_haste'] = -512
		end
		if buff.id == 68 then -- Warcry
			if this_buff.value then
				this_buff["Attack perc"] = this_buff.value
				--log('buff: '..this_buff.id..' effect: '..this_buff.effect..' value: '..this_buff.value)
			end
		end
		if buff.id == 56 then -- Berserk %/1024
			this_buff['Defence perc'] = -256
			if player.main_job:upper() == 'WAR' then
				if player.main_job_level < 50 then
					this_buff["Attack perc"] = 256
				elseif player.main_job_level > 49 and player.main_job_level < 60 then
					this_buff["Attack perc"] = 276 -- add 20 for every 10 levels, equivalent to 2%
				elseif player.main_job_level > 59 and player.main_job_level < 70 then
					this_buff["Attack perc"] = 296
				elseif player.main_job_level > 69 and player.main_job_level < 80 then
					this_buff["Attack perc"] = 316
				elseif player.main_job_level > 79 and player.main_job_level < 90 then
					this_buff["Attack perc"] = 336
				elseif player.main_job_level > 89 then
					this_buff["Attack perc"] = 356
				end
			else
				this_buff["Attack perc"] = 256
			end
			-- Conquerror buffs
			-- 18971, 18991, 19060, 19080, 19612, 19710, 19819, 19948, 20837, 20838, 21757, 
			-- 18971 does not augment berserk
			if player.equipment.main.id == 18991 then
				-- lvl 75
				this_buff["Attack perc"] = this_buff["Attack perc"] + 52
				this_buff['Defence perc'] = this_buff['Defence perc'] -52
				this_buff["Critical hit rate"] = 52
			elseif player.equipment.main.id == 19060 then
				-- lvl 80 berserk II
				this_buff["Attack perc"] = this_buff["Attack perc"] + 62
				this_buff['Defence perc'] = this_buff['Defence perc'] -62
				this_buff["Critical hit rate"] = 72
			elseif player.equipment.main.id == 19080 then
				-- lvl 85 berserk III
				this_buff["Attack perc"] = this_buff["Attack perc"] + 72
				this_buff['Defence perc'] = this_buff['Defence perc'] -72
				this_buff["Critical hit rate"] = 93
			elseif player.equipment.main.id == 19612 or player.equipment.main.id == 19710 then
				-- lvl 90 and lvl 95 berserk IV
				this_buff["Attack perc"] = this_buff["Attack perc"] + 82
				this_buff['Defence perc'] = this_buff['Defence perc'] -82
				this_buff["Critical hit rate"] = 113
			elseif L{19819, 19948, 20837, 20838, 21757}:contains(player.equipment.main.id) then
				-- lvl 99 berserk V
				this_buff["Attack perc"] = this_buff["Attack perc"] + 88
				this_buff['Defence perc'] = this_buff['Defence perc'] -88
				this_buff["Critical hit rate"] = 144
			end
		end
		if buff.id == 57 then -- Defender %/1024
			this_buff['Attack perc'] = -256
			if player.main_job:upper() == 'WAR' then
				if player.main_job_level < 50 then
					this_buff['Defence perc'] = 256
				elseif player.main_job_level > 49 and player.main_job_level < 60 then
					this_buff['Defence perc'] = 276 -- add 20 for every 10 levels, equivalent to 2%
				elseif player.main_job_level > 59 and player.main_job_level < 70 then
					this_buff['Defence perc'] = 296
				elseif player.main_job_level > 69 and player.main_job_level < 80 then
					this_buff['Defence perc'] = 316
				elseif player.main_job_level > 79 and player.main_job_level < 90 then
					this_buff['Defence perc'] = 336
				elseif player.main_job_level > 89 then
					this_buff['Defence perc'] = 356
				end
			else
				this_buff['Defence perc'] = 256
			end
		end
		if buff.id == 58 then -- Aggressor
			this_buff['Accuracy'] = 25
			this_buff['Evasion'] = -25
			if player.main_job:lower() == 'war' then
				this_buff['Ranged Accuracy'] = player['merits']['aggressive_aim'] * 4
				-- Warrior's Lorica nq, +1, +2, Agoge Lorica nq, +1, +2, +3
				-- all these chests lower the evasion penatly by 10 while worn
				local body_list = L{15087, 14500,  10670, 26800, 26801, 23130, 23465}
				if body_list:contains(player.equipment['body'].id) then
					this_buff['Evasion'] = -15
				end
			end
			if this_buff.value and this_buff.effect == 'AGI' then
				this_buff['AGI'] = this_buff.value
			end
		end
		if buff.id == 460 then -- blood rage %/1024
			this_buff["Critical hit rate"] = 205
		end
		if buff.id == 419 then -- composure
			this_buff['Accuracy'] = math.floor(((24 * player.main_job_level) + 74) / 49 ) + player.job_points['rdm']['composure_effect']
		end
		if buff.id == 512 and Ionis_zones:contains(windower.ffxi.get_info().zone) then -- ionis
			this_buff['g_haste'] = 30
			this_buff['Accuracy'] = 20
			this_buff['Ranged Accuracy'] = 20
		end
		if buff.id == 64 then -- last resort
			if player.main_job:upper() == 'DRK' and player.main_job_level == 99 then
				this_buff['ja_haste'] = math.ceil(((player.merits.desperate_blows * 2) + 15)/100*1024)
			elseif player.main_job:upper() == 'DRK' and player.main_job_level < 99 and player.main_job_level > 75 then
				this_buff['ja_haste'] = math.ceil(((player.merits.desperate_blows * 2) + 5)/100*1024)
			elseif player.main_job:upper() == 'DRK' and player.main_job_level < 75 then
				this_buff['ja_haste'] = 52
			elseif player.sub_job and player.sub_job == 'DRK' then
				this_buff['ja_haste'] = 52
			end
		elseif buff.id == 353 then -- Hasso
			this_buff['ja_haste'] = 103
			this_buff['Accuracy'] = 10
			if player.main_job:upper() == 'SAM' then
				local str = math.floor(player.main_job_level / 7)
				if str > 14 then str =14 end
				this_buff['STR'] = str
			end
			if player.sub_job:upper() == 'SAM' then
				local str = math.floor(player.sub_job_level / 7)
				if str > 14 then str =14 end
				this_buff['STR'] = str
			end
			if player.equipment.hands.en:lower() == "wakido kote" then	
				this_buff['ja_haste'] = this_buff['ja_haste'] + 10
			elseif player.equipment.hands.en:lower() == "wakido kote +1" then	
				this_buff['ja_haste'] = this_buff['ja_haste'] + 20
			elseif player.equipment.hands.en:lower() == "wakido kote +2" then	
				this_buff['ja_haste'] = this_buff['ja_haste'] + 30
			elseif player.equipment.hands.en:lower() == "wakido kote +3" then	
				this_buff['ja_haste'] = this_buff['ja_haste'] + 40
			end
			if player.equipment.legs.en:lower() == "unkai haidate +1" then	
				this_buff['ja_haste'] = this_buff['ja_haste'] + 15
			elseif player.equipment.legs.en:lower() == "unkai haidate +2" then	
				this_buff['ja_haste'] = this_buff['ja_haste'] + 25
			elseif player.equipment.legs.en:lower() == "kasuga haidate" then	
				this_buff['ja_haste'] = this_buff['ja_haste'] + 25
			elseif player.equipment.legs.en:lower() == "kasuga haidate +1" then	
				this_buff['ja_haste'] = this_buff['ja_haste'] + 30
			end
			if player.equipment.feet.en:lower() == "wakido sune. +2" then	
				this_buff['ja_haste'] = this_buff['ja_haste'] + 10
			elseif player.equipment.feet.en:lower() == "wakido sune. +3" then	
				this_buff['ja_haste'] = this_buff['ja_haste'] + 20
			end
		elseif buff.id == 604 then -- mighty guard
			this_buff['ma_haste'] = 150
		elseif buff.id == 228 then -- Embrava max 266 @ 500 Enhancing magic skill
			this_buff['ma_haste'] = 260
		elseif buff.id == 33 then -- haste 
			if buff.full_name == "Haste II" then
				this_buff['ma_haste'] = 307
			elseif buff.full_name == "Erratic Flutter" then
				this_buff['ma_haste'] = 307
			elseif buff.full_name == "Hastega II" then
				this_buff['ma_haste'] = 307
			elseif buff.full_name == 'Refueling' then
				this_buff['ma_haste'] = 102
			else
				this_buff['ma_haste'] = 150
			end
		elseif buff.id == 227 then -- ninja spell
			this_buff['Store TP'] = 10
		end
		
		local trust_names = L{"Cornelia", 'Kupofried', 'Brygid', 'KuyinHathdenna', 'Moogle', 'Sakura', 'StarSibyl'}
		
		for member_name, v in pairs(member_table) do
			if trust_names:contains(member_name) and v.mob.distance:sqrt() < 12.5 then
				if v.indi and v.indi.id and v.indi.id and v.indi.id == 817 and Geo_Spells[v.indi.id].buff.id == buff.id and duplicate_id and not table.containskey(duplicate_id, v.indi.id) then -- cornelia
					this_buff['ma_haste'] = 204
					this_buff['Accuracy'] = 30
					this_buff['Ranged Accuracy'] = 30
					duplicate_id[v.indi.id] = true
					break
				elseif v.indi and v.indi.id and v.indi.id == 818  and Geo_Spells[v.indi.id].buff.id == buff.id and duplicate_id and not table.containskey(duplicate_id, v.indi.id) then-- kupofried
					this_buff['Experience Bonus'] = 10
					duplicate_id[v.indi.id] = true
					break
				elseif v.indi and v.indi.id and v.indi.id ==  819  and Geo_Spells[v.indi.id].buff.id == buff.id and duplicate_id and not table.containskey(duplicate_id, v.indi.id) then -- Brygid
					this_buff['DEF'] = 99
					this_buff["Magic Def. Bonus"] = 5
					duplicate_id[v.indi.id] = true
					break
				elseif v.indi and v.indi.id and v.indi.id == 820  and Geo_Spells[v.indi.id].buff.id == buff.id and duplicate_id and not table.containskey(duplicate_id, v.indi.id) then --Kuyin Hathdenna
					this_buff['Accuracy'] = 25
					this_buff['Ranged Accuracy'] = 25
					duplicate_id[v.indi.id] = true
					break
				elseif v.indi and v.indi.id and v.indi.id == 821  and Geo_Spells[v.indi.id].buff.id == buff.id and duplicate_id and not table.containskey(duplicate_id, v.indi.id) then -- Moogle
					this_buff['Refresh'] = 3
					duplicate_id[v.indi.id] = true
					break
				elseif v.indi and v.indi.id and v.indi.id == 822  and Geo_Spells[v.indi.id].buff.id == buff.id and duplicate_id and not table.containskey(duplicate_id, v.indi.id) then -- Sakura
					this_buff['Regen'] = 6
					duplicate_id[v.indi.id] = true
					break
				elseif v.indi and v.indi.id and v.indi.id == 823  and Geo_Spells[v.indi.id].buff.id == buff.id and duplicate_id and not table.containskey(duplicate_id, v.indi.id) then -- Star Sibyl
					this_buff["Magic Atk. Bonus"] = 19
					duplicate_id[v.indi.id] = true
					break
				end
			elseif v.mob.distance:sqrt() < 6.5 and v.indi and v.indi.id  and Geo_Spells[v.indi.id].buff.id == buff.id and duplicate_id and not table.containskey(duplicate_id, v.indi.id) then 
				local boost = 0
				-- check if caster is recipient to add gemancy + bonus, else its an entrust and no boost is applied
				if table.containskey(settings.Geos, member_name:lower()) and v.indi.caster == member_name then
					if settings.Geos[member_name:lower()] then 
						boost = settings.Geos[member_name:lower()]
					else 
						boost = manual_GEO_bonus
					end
					boost = boost * Geo_Spells[v.indi.id]['Geomancy x']
				end
				if v.indi.caster == 'Sylvie(UC)' then
					if Geo_Spells[v.indi.id].en == "Indi-Fury" then 
						this_buff["Attack"] = 384
					elseif Geo_Spells[v.indi.id].en == "Indi-Precision" then 
						this_buff['Accuracy'] = 56
						this_buff['Ranged Accuracy'] = 56
					elseif Geo_Spells[v.indi.id].en == "Indi-Haste" then this_buff['ma_haste'] = 294
					elseif Geo_Spells[v.indi.id].en == "Indi-Refresh" then this_buff['Refresh'] = 5
					elseif Geo_Spells[v.indi.id].en == "Indi-Regen" then this_buff['Regen'] = 30
					elseif Geo_Spells[v.indi.id].en == "Indi-Acumen" then this_buff["Magic Atk. Bonus"] = 41
					elseif Geo_Spells[v.indi.id].en == "Indi-Focus" then this_buff["Magic Accuracy"] = 55
					end
				else
					for i=1, 3 do
						if Geo_Spells[v.indi.id].effect[i] then
							this_buff[Geo_Spells[v.indi.id].effect[i]] = math.floor((Geo_Spells[v.indi.id]["900 skill"] + boost) * v.indi.boost) -- and multiply by bolster
							duplicate_id[v.indi.id] = true
						end
					end
				end
			end
			if v.geo and v.geo.id and v.mob and v.mob.pet_index and windower.ffxi.get_mob_by_index(v.mob.pet_index).distance:sqrt() < 6 and Geo_Spells[v.geo.id].buff.id == buff.id then
				local boost = 0
				if table.containskey(settings.Geos, member_name:lower()) then
					if settings.Geos[member_name:lower()] then 
						boost = settings.Geos[member_name:lower()]
					else 
						boost = manual_GEO_bonus
					end
					boost = boost * Geo_Spells[v.geo.id]['Geomancy x']
				end
				for i=1, 2 do
					if Geo_Spells[v.geo.id].effect[i] then
						this_buff[Geo_Spells[v.geo.id].effect[i]] = math.floor((Geo_Spells[v.geo.id]["900 skill"] + boost) * v.geo.boost) -- and multiply by bolster / EA/ BoG
					end
				end
				break
			end
		end
		
		-- Cor Rolls
		for Job_abil_id, Roll_info in pairs(Cor_Rolls) do
			if buff['full_name'] and  Roll_info.en == buff['full_name']  then
				for i = 1, 2 do
					if this_buff.value and this_buff.value[i] then
						if Roll_info.en == "Companion's Roll" and i == 1 then
							this_buff["Pet: Regen"] = tonumber(this_buff.value[i])
						elseif Roll_info.en == "Companion's Roll" and i == 2 then
							this_buff["Pet: Regain"] = tonumber(this_buff.value[i])
						elseif Roll_info.en == "Hunter's Roll" and i == 1 then
							this_buff["Accuracy"] = tonumber(this_buff.value[i])
							this_buff["Ranged Accuracy"] = tonumber(this_buff.value[i])
						elseif Roll_info.en == "Chaos Roll" and i == 1 then
							this_buff["Attack perc"] = tonumber(this_buff.value[i])
						else
							this_buff[this_buff.effect] = tonumber(this_buff.value[i])
						end
					end
				end
			end
		end
			
		-- Bard Songs
		local temp = {}
		for Song_id, Song_table in pairs(Bard_Songs) do
			if buff['full_name'] and Song_table.en == buff['full_name']  then
				--if Song_table.en == buff['full_name'] then
					local potency = 0
					local All_songs = 0
					local bonus = 0
					local effects = ''
					local msg = ''
					local Minne = 0
					local	Minuet = 0
					local	Madrigal = 0
					local Empy_bonus = 0
					
					if table.containskey(settings.Bards, buff.Caster) then
						All_songs = settings.Bards[buff.Caster]['song_bonus']['all_songs']
					else
						All_songs = manual_bard_duration_bonus
					end

					if table.containskey(buff, 'Marcato') and buff.Marcato == true then 
						potency = 0.5
						msg = msg .. ' Marcato'
					end
					if table.containskey(buff, 'SV') and buff.SV == true then 
						potency = 1
						msg = msg .. ' SV'
					end
					if buff.full_name == "Honor March" then
						local int = 0
						 if settings.Bards[buff.Caster] and settings.Bards[buff.Caster]['gjallarhorn'] then 
							int =  4 
						else 
							int =  0 
						end 
						if settings.Bards[buff.Caster] then
							All_songs = settings.Bards[buff.Caster]['song_bonus']['all_songs']  + settings.Bards[buff.Caster]['song_bonus'][buff.name:lower()] - int
						end
						bonus = {}
						for i = 1, 4 do
							if Song_table.effect[i] and Song_table["Bard Bonus"][All_songs][i] then
								temp[Song_table.effect[i]] = Song_table["Bard Bonus"][All_songs][i] + (Song_table["Bard Bonus"][All_songs][i] * potency )
								bonus[i] = Song_table.effect[i] .. ' '.. string.format("%+d", Song_table["Bard Bonus"][All_songs][i] + (Song_table["Bard Bonus"][All_songs][i] * potency ) )
							end
						end
						bonus = table.concat(bonus, ", ")
						potency = potency + (All_songs / 10)+ 1
						temp['potency'] = potency
						temp['All_songs'] = All_songs
					else
						if settings.Bards[buff.Caster] then
							All_songs = settings.Bards[buff.Caster]['song_bonus']['all_songs']  + settings.Bards[buff.Caster]['song_bonus'][buff.name:lower()]
							if settings.Bards[buff.Caster]['merits'][buff.name:lower()] then
								if settings.Bards[buff.Caster]['jp'][buff.name:lower()] then
									temp[Song_table.effect[1]] = Song_table["Bard Bonus"][All_songs] + settings.Bards[buff.Caster]['merits'][buff.name:lower()] + settings.Bards[buff.Caster]['jp'][buff.name:lower()] + (Song_table["Bard Bonus"][All_songs] * potency )
								else
									temp[Song_table.effect[1]] = Song_table["Bard Bonus"][All_songs] + settings.Bards[buff.Caster]['merits'][buff.name:lower()] + (Song_table["Bard Bonus"][All_songs] * potency )
								end
							else
								temp[Song_table.effect[1]] = Song_table["Bard Bonus"][All_songs] + (Song_table["Bard Bonus"][All_songs] * potency )
							end
							if settings.Bards[buff.Caster]['merits'][buff.name:lower()] then
								if settings.Bards[buff.Caster]['jp'][buff.name:lower()] then
									bonus = string.format("%+d", Song_table["Bard Bonus"][All_songs] + settings.Bards[buff.Caster]['merits'][buff.name:lower()] + settings.Bards[buff.Caster]['jp'][buff.name:lower()] + (Song_table["Bard Bonus"][All_songs] * potency ))
								else
									bonus = string.format("%+d", Song_table["Bard Bonus"][All_songs] + settings.Bards[buff.Caster]['merits'][buff.name:lower()] + (Song_table["Bard Bonus"][All_songs] * potency ))
								end
							else
								bonus = string.format("%+d", Song_table["Bard Bonus"][All_songs] + (Song_table["Bard Bonus"][All_songs] * potency ))
							end
							potency = potency + (All_songs / 10)+ 1
							temp['potency'] = potency
							temp['All_songs'] = All_songs
							effects = Song_table.effect[1]
						else
							temp[Song_table.effect[1]] = Song_table["Bard Bonus"][All_songs] + (Song_table["Bard Bonus"][All_songs] * potency )
							bonus = string.format("%+d", Song_table["Bard Bonus"][All_songs] + (Song_table["Bard Bonus"][All_songs] * potency ))
							potency = potency + (All_songs / 10)+ 1
							temp['potency'] = potency
							temp['All_songs'] = All_songs
							effects = Song_table.effect[1]
						end
					end
					if Song_table.element == 7 then
						for i = 1, 7 do
							if temp[ele_to_stat[Song_table.element].en[i]] and settings.Bards[buff.Caster] then
								temp[ele_to_stat[Song_table.element].en[i]] = temp[ele_to_stat[Song_table.element].en[i]] + settings.Bards[buff.Caster]['emperean_armor_bonus']
							else
								temp[ele_to_stat[Song_table.element].en[i]] = 0
							end
						end
					else
						if temp[ele_to_stat[Song_table.element].en] and settings.Bards[buff.Caster] then
							if settings.Bards[buff.Caster]['emperean_armor_bonus'] > 2 then
								temp[ele_to_stat[Song_table.element].en] = temp[ele_to_stat[Song_table.element].en] + settings.Bards[buff.Caster]['emperean_armor_bonus'] -1
							else 
								temp[ele_to_stat[Song_table.element].en] = temp[ele_to_stat[Song_table.element].en] 
							end
						else
							if settings.Bards[buff.Caster] then
								if settings.Bards[buff.Caster]['emperean_armor_bonus'] > 2 then
									temp[ele_to_stat[Song_table.element].en] = settings.Bards[buff.Caster]['emperean_armor_bonus'] -1
								else
									temp[ele_to_stat[Song_table.element].en] = 0
								end
							else
								temp[ele_to_stat[Song_table.element].en] = 0
							end
						end
					end
					if not this_buff['reported'] then
						notice('① ' .. buff.Caster:ucfirst() .. ' → "'..buff.full_name ..'": '.. effects .. ' '..bonus..', '..ele_to_stat[Song_table.element].en..'+'..temp[ele_to_stat[Song_table.element].en]..', Potency = ' .. potency .. ', Song bonus +' .. temp['All_songs']  .. msg)
						this_buff['reported'] = true
					end
				break
				--end
			end
		end
		
		for k,v in pairs(temp) do
			this_buff[k] = v
		end
		
	end
	-- if check_it then
		-- table.vprint(_ExtraData.player.buff_details)
	-- end
end

function calculate_total_haste()
	Buffs_inform = {	['delay'] = 0,['damage'] = 0,
								['HP'] = 0,['MP'] = 0,
								['STR'] = 0,['DEX'] = 0,['VIT'] = 0,['AGI'] = 0,['INT'] = 0,['MND'] = 0,['CHR'] = 0,
								['Accuracy'] = 0, ['Ranged Accuracy'] = 0, 
								['Attack'] = 0, ['Attack perc'] = 0,
								['Evasion'] = 0,['DEF'] = 0,['Defence perc'] = 0,
								['Magic Accuracy'] = 0, ['Magic Atk. Bonus'] = 0,
								['Magic Evasion'] = 0,['Magic Def. Bonus'] = 0,
								['g_haste']=0,['ma_haste'] = 0,['ja_haste'] = 0,
								['PDT'] = 0,['MDT'] = 0,['BDT'] = 0,['DT'] = 0,['MDT2'] = 0,['PDT2'] = 0,
								['Store TP'] = 0,['Dual Wield'] = 0 ,['Fast Cast'] = 0 ,['Martial Arts'] = 0,
								["Double Attack"] = 0,["Tripple Attack"] = 0,['Quadruple Attack'] = 0,["Critical hit rate"] = 0,["Critical hit damage"] = 0,["Subtle Blow"] = 0,
								}
	
	local DNC_main_in_party = false
	
	for k, v in pairs(member_table) do
		if v['Main job'] == 'DNC' then DNC_main_in_party = true end
	end
	
	if buff_info.h_spikes and windower.ffxi.get_player().status == 1 then
		if dancer_main then
			Buffs_inform.ja_haste = Buffs_inform.ja_haste + 101
		elseif DNC_main_in_party then
			Buffs_inform.ja_haste = Buffs_inform.ja_haste + 101
		else
			Buffs_inform.ja_haste = Buffs_inform.ja_haste + 51
		end
	else
		Buffs_inform.ja_haste = 0
		buff_info.h_spikes = false
	end
	
--	local temp_buffs = table.copy(_ExtraData.player.buff_details)

	for k, v in pairs(_ExtraData.player.buff_details) do
		for index, value in pairs(v) do
			if Buffs_inform[index] then
				Buffs_inform[index] = Buffs_inform[index] + value
			end
		end
	end
	
	return Buffs_inform
end