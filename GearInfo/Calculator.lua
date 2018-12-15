function get_tp_per_hit()
	-- tp_per_hit = {melee = 0, range = 0}
	local tp_per_hit = determine_Base_tp_hit()
	local tp_per_hit_zanshin = 0
	local Job_STP = determine_stp()
	local Return_table = T{}
	local buff = Buffs_inform['Store TP']
	
	local jp_tp_bonus = 0
	local jp = player.job_points[player.main_job:lower()]['jp_spent']
		
	for k, v in pairs(Gifts[player.main_job]['Gifts']) do
		if k <= jp then
			for i, j in pairs(v) do
				if i == 'Store TP Effect' then
					jp_tp_bonus = jp_tp_bonus + j
				end
			end
		end
	end
	
	--log("base delay =" ..base_delay.. ' | tp_per_hit :' .. tp_per_hit .. ' | Job_traits :'.. Job_STP )
	if player.main_job == 'SAM' then
		
		--log('Main job is SAM Job points TP bonus value:' .. jp_tp_bonus)
		if Gear_info['Store TP'] ~= nil then
			local zanshin = tp_per_hit.melee + (3 * player.merits.ikishoten)
			--log('ikishoten merits = '.. player.merits.ikishoten .. ' STP merits: ' ..player.merits.store_tp_effect  )
			--log('zanshin = tp_per_hit + 3 x merits + jp bonus : ' .. zanshin)
			local merit_STP = (player.merits.store_tp_effect * 2)
			tp_per_hit_zanshin =  math.floor(zanshin * (100 + Gear_info['Store TP'] + Job_STP + merit_STP + jp_tp_bonus + buff) / 100 )
			--log('zanshin tp return = ' ..global_tp_hit_zanshin .. ' where gear STP = ' ..  Gear_info['Store TP'])
			tp_per_hit.melee = math.floor(tp_per_hit.melee * (100 + Gear_info['Store TP'] + merit_STP + jp_tp_bonus + Job_STP + buff) / 100 )
			tp_per_hit.range = math.floor(tp_per_hit.range * (100 + Gear_info['Store TP'] + merit_STP + jp_tp_bonus + Job_STP + buff) / 100 )
		end
	else
		if Gear_info['Store TP'] ~= nil then
			tp_per_hit.melee = math.floor(tp_per_hit.melee * (100 + Gear_info['Store TP'] + jp_tp_bonus + Job_STP + buff) / 100 )
			tp_per_hit.range = math.floor(tp_per_hit.range * (100 + Gear_info['Store TP'] + jp_tp_bonus + Job_STP + buff) / 100 )
			tp_per_hit_zanshin = 0
		end
	end
	Return_table = {tp_per_hit_melee = tp_per_hit.melee, tp_per_hit_zanshin = tp_per_hit_zanshin, tp_per_hit_range = tp_per_hit.range }
	return Return_table
end

function determine_Base_tp_hit()
	
	--Weapon_Delay = T{melee_delay = 0, sub = false, ranged_delay = 0, range = false, ammo = false}
	
	local total_dw = 0
	local weapons = determine_Weapon_Delay()
	local DW = determine_DW()
	
	if Gear_info['Dual Wield'] ~= nil and DW ~= nil then
		total_dw = Gear_info['Dual Wield'] + DW
	end
	
	local base_delay = {melee = 0, range = 0}
	if weapons.sub then
		base_delay.melee = math.floor((weapons.melee_delay * (1 - (total_dw/100 ))) / 2)
		base_delay.range = weapons.ranged_delay
	else
		base_delay.melee = weapons.melee_delay
		base_delay.range = weapons.ranged_delay
	end
	--print('base delay: ' .. base_delay ..' | weapon: ' ..determine_Weapon_Delay() .. ' | DW: ' .. total_dw )
	local tp_per_hit = {melee = 0, range = 0}
	
	for k,v in pairs(base_delay) do
		if base_delay[k] < 181 and base_delay[k] > 0 then
			tp_per_hit[k] = 61 + ((base_delay[k] -180) * 63 / 360)
		elseif base_delay[k] > 180 and base_delay[k] < 541 then
			tp_per_hit[k] = 61 + ((base_delay[k] -180) * 88 / 360)
		elseif base_delay[k] > 540 and base_delay[k] < 631 then
			tp_per_hit[k] = 149 + ((base_delay[k] - 540) * 20 / 360)
		elseif base_delay[k] > 630 and base_delay[k] < 721 then
			tp_per_hit[k] = 154 + ((base_delay[k] - 630) * 28 / 360)
		elseif base_delay[k] > 720 and base_delay[k] < 901 then
			tp_per_hit[k] = 161 + ((base_delay[k] - 720) * 24 / 360)
		elseif base_delay[k] > 900 then
			tp_per_hit[k] = 173 + ((base_delay[k] - 900) * 28 / 360)
		else	
			tp_per_hit[k] = 0
		end
		--log('tp_per_hit.'..k..': ' .. tp_per_hit[k])
		tp_per_hit[k] = math.floor(tp_per_hit[k])
	end
	
	return tp_per_hit
end

function determine_stp()

	local sub_job_tp = 0
	local main_job_tp = 0
	local player_has_sj = false
	
	if player.sub_job then
		player_has_sj = true
	end
	
	--log('player_has_sj ' .. tostring(player_has_sj))
	if player_has_sj == true then
		if player.sub_job == 'SAM' and player.sub_job_level < 10  then 
			sub_job_tp = 0
		elseif player.sub_job == 'SAM' and player.sub_job_level < 30 and  player.sub_job_level > 9 then 
			sub_job_tp = 10
		elseif player.sub_job == 'SAM' and player.sub_job_level < 50 and  player.sub_job_level > 31 then 
			sub_job_tp = 15
			--log('sub_job_tp = 15')
		end
	end
	
	if player.main_job == 'BLU' then
		-- here we look up job points spent on blue for the DW bonus
		local jp_boost = 0
		local jp = player.job_points['blu']['jp_spent']
		
		local jp_boost = 0
		if jp < 100 then
			jp_boost = 0
		elseif jp >= 100 and jp < 1200 then
			jp_boost = 1
		elseif jp >= 1200 then
			jp_boost = 2
		end
		
		local spells_set = T(windower.ffxi.get_mjob_data().spells):filter(function(id) return id ~= 512 end):map(function(id) return id end)
		local spell_value = 0
		for key, spell_id in pairs(spells_set) do
			if Blu_spells[spell_id].trait == 'Store TP' then
				spell_value = spell_value + Blu_spells[spell_id]['points']
			end
		end
		
		if spell_value > 0 then
			spell_value  = math.floor(spell_value / 8) + jp_boost
		else
			spell_value = 0
		end
		
		--the we determine the actuall % value of DW equipped via blu spells 
		if spell_value== 0 then main_job_tp = 0
		elseif spell_value== 1 then main_job_tp = 10
		elseif spell_value== 2 then main_job_tp = 15
		elseif spell_value== 3 then main_job_tp = 20
		elseif spell_value== 4 then main_job_tp = 25
		elseif spell_value== 5 then main_job_tp = 30
		end
		--add_to_chat(122, '[Sub dw: ' .. sub_job_dw .. '] [Main dw: ' .. main_job_dw .. ']')
	elseif player.main_job == 'SAM' then
		--log('entered job traits function')
		main_job_tp = 0
		if player.main_job_level < 10  then main_job_tp = 0
		elseif player.main_job_level < 30 and  player.main_job_level > 9 then main_job_tp = 10
		elseif player.main_job_level < 50 and  player.main_job_level > 31 then main_job_tp = 15
		elseif player.main_job_level < 70 and  player.main_job_level > 51 then main_job_tp = 20
		elseif player.main_job_level < 90 and  player.main_job_level > 71 then main_job_tp = 25
		elseif player.main_job_level < 100 and  player.main_job_level > 91 then main_job_tp = 30
		end
		
	end
	
	-- if the sub job DW is higher return that instead of blue mage spell DW
	if sub_job_tp > main_job_tp then
		--log(sub_job_tp .. ' sub_job_tp')
		return sub_job_tp
	else
		--log(main_job_tp .. ' main_job_tp')
		return main_job_tp
	end
end

function determine_Weapon_Delay()
	local Weapon_Delay = T{melee_delay = 480, gear_MA = 0, sub = false, ranged_delay = 0, range = false, ammo = false}
	
	local Base_Delay = 480
	
	if player.equipment.main.skill == "Hand-to-Hand" or player.equipment.main.en == '' then
		
		local MainJ_Base_Delay = 480
		local SubJ_Base_Delay = 480
		
		if player.main_job == 'MNK'  then
			if player.main_job_level == 1 then  MainJ_Base_Delay = 400
			elseif player.main_job_level  > 1 and player.main_job_level  < 31 then MainJ_Base_Delay = 380
			elseif player.main_job_level  > 30 and player.main_job_level  < 46 then MainJ_Base_Delay = 360
			elseif player.main_job_level  > 45 and player.main_job_level  < 61 then MainJ_Base_Delay = 340
			elseif player.main_job_level  > 60 and player.main_job_level  < 75 then MainJ_Base_Delay = 320
			elseif player.main_job_level  > 74 and player.main_job_level  < 82 then MainJ_Base_Delay = 300
			elseif player.main_job_level  > 81 then MainJ_Base_Delay = 280
			end
		end
		
		if player.main_job == 'PUP'  then
			if player.main_job_level > 24  and player.main_job_level  < 50 then  MainJ_Base_Delay = 400
			elseif player.main_job_level  > 49 and player.main_job_level  < 75 then MainJ_Base_Delay = 380
			elseif player.main_job_level  > 74 and player.main_job_level  < 87 then MainJ_Base_Delay = 360
			elseif player.main_job_level  > 86 and player.main_job_level  < 97 then MainJ_Base_Delay = 340
			elseif player.main_job_level  > 96 then MainJ_Base_Delay = 320
			end
		end
		
		if player.sub_job and player.sub_job == 'MNK'  then
			if player.sub_job_level  == 1 then  SubJ_Base_Delay = 400
			elseif player.sub_job_level   > 1 and player.sub_job_level   < 31 then SubJ_Base_Delay = 380
			elseif player.sub_job_level   > 30 and player.sub_job_level   < 46 then SubJ_Base_Delay = 360
			elseif player.sub_job_level   > 45  then SubJ_Base_Delay = 340
			end
		end
		
		if player.sub_job and player.sub_job == 'PUP'  then
			if player.sub_job_level  > 24 then  SubJ_Base_Delay = 400
			end
		end
		
		local jp = player.job_points[player.main_job:lower()]['jp_spent']
		
		for k, v in pairs(Gifts[player.main_job]['Gifts']) do
			if k <= jp then
				for i, j in pairs(v) do
					if i == 'Martial Arts Effect' then
						MainJ_Base_Delay = MainJ_Base_Delay - j
					end
				end
			end
		end
		
		if SubJ_Base_Delay < MainJ_Base_Delay then
			Base_Delay = SubJ_Base_Delay
		else
			Base_Delay = MainJ_Base_Delay
		end
		Weapon_Delay.job_MA = 480 - Base_Delay
		for equip_slot,item in pairs(player.equipment) do
			-- Wrestler's Mantle	Latent Effect (Monk sub job): Hand-to-Hand Delay -10
			if item.id == 13660 and player.sub_job and player.sub_job == 'MNK' then Base_Delay = Base_Delay - 10 end
			-- check all other gear with martial arts
			for MA_id, MA_item in pairs(Martial_Arts_Gear)do
				if item.id == MA_id then
					Base_Delay = Base_Delay - MA_item.delay
					Weapon_Delay.gear_MA = Weapon_Delay.gear_MA + MA_item.delay
				end
			end
		end
		if Base_Delay + player.equipment.main.delay <= 96 then
			Weapon_Delay.melee_delay = 96
		else
			Weapon_Delay.melee_delay = Base_Delay + player.equipment.main.delay
		end
	end
	for k,v in pairs(player.equipment.main) do
		if player.equipment.main.skill ~= "Hand-to-Hand" and player.equipment.main.en ~= '' then
			if k == 'delay' then
				Weapon_Delay.melee_delay = player.equipment.main.delay
			end
		end
	end
	for k,v in pairs(player.equipment.sub) do
		if player.equipment.sub.category == 'Weapon' then
			if k == 'damage' and v > 0 then
				Weapon_Delay.melee_delay = Weapon_Delay.melee_delay + player.equipment.sub.delay
				Weapon_Delay.sub = true
			end	
		end
	end
	for k,v in pairs(player.equipment.range) do
		if k == 'damage' and v > 0 then
			Weapon_Delay.ranged_delay = Weapon_Delay.ranged_delay + player.equipment.range.delay
			Weapon_Delay.range = true
		end		
	end
	for k,v in pairs(player.equipment.ammo) do
		if k == 'damage' and v > 0 then
			Weapon_Delay.ranged_delay = Weapon_Delay.ranged_delay + player.equipment.ammo.delay
			Weapon_Delay.ammo = true
		end		
	end
	--table.vprint(Weapon_Delay)
	-- notice(Weapon_Delay.melee_delay )
	return Weapon_Delay
end

function determine_DW()

	local sub_job_dw = 0
	local main_job_dw = 0
	local player_has_sj = false
	local jp_dw_bonus = 0
	
	if player.sub_job then
		if player.sub_job == 'DNC' then sub_job_dw = 15
		elseif player.sub_job == 'NIN' then sub_job_dw = 25
		end
	end
	
	local jp = player.job_points[player.main_job:lower()]['jp_spent']
		
	for k, v in pairs(Gifts[player.main_job]['Gifts']) do
		if k <= jp then
			for i, j in pairs(v) do
				if i == 'Dual Wield Effect' then
					jp_dw_bonus = jp_dw_bonus + j
				end
			end
		end
	end
	
	if player.main_job == 'BLU' then
		-- here we look up job points spent on blue for the DW bonus
		local jp_boost = 0
		if jp < 100 then
			jp_boost = 0
		elseif jp >= 100 and jp < 1200 then
			jp_boost = 1
		elseif jp >= 1200 then
			jp_boost = 2
		end
		
		local spells_set = T(windower.ffxi.get_mjob_data().spells):filter(function(id) return id ~= 512 end):map(function(id) return id end)
		local spell_value = 0
		for key, spell_id in pairs(spells_set) do
			if Blu_spells[spell_id].trait == 'Dual Wield' then
				spell_value = spell_value + Blu_spells[spell_id]['points']
			end
		end
		
		if spell_value > 0 then
			spell_value  = math.floor(spell_value / 8) + jp_boost
		else
			spell_value = 0
		end
		
		--the we determine the actuall % value of DW equipped via blu spells 
		if spell_value == 0 then main_job_dw = 0
		elseif spell_value == 1 then main_job_dw = 10
		elseif spell_value == 2 then main_job_dw = 15
		elseif spell_value == 3 then main_job_dw = 25
		elseif spell_value == 4 then main_job_dw = 30
		elseif spell_value == 5 then main_job_dw = 35
		elseif spell_value == 6 then main_job_dw = 40
		end
		
	elseif player.main_job == 'NIN' then
		if player.main_job_level < 10 and  player.main_job_level > 0 then main_job_dw = 0
		elseif player.main_job_level < 25 and  player.main_job_level > 9 then main_job_dw = 10
		elseif player.main_job_level < 45 and  player.main_job_level > 24 then main_job_dw = 15
		elseif player.main_job_level < 65 and  player.main_job_level > 44 then main_job_dw = 25
		elseif player.main_job_level < 85 and  player.main_job_level > 64 then main_job_dw = 30
		elseif player.main_job_level < 100 and  player.main_job_level > 84 then main_job_dw = 35
		end
		
	elseif player.main_job == 'DNC' then
		if 	   player.main_job_level < 20 and  player.main_job_level > 0 then main_job_dw = 0
		elseif player.main_job_level < 40 and  player.main_job_level > 19 then main_job_dw = 10
		elseif player.main_job_level < 60 and  player.main_job_level > 39 then main_job_dw = 15
		elseif player.main_job_level < 80 and  player.main_job_level > 59 then main_job_dw = 25
		elseif player.main_job_level < 100 and  player.main_job_level > 79 then main_job_dw = 30
		end
		
	elseif player.main_job == 'THF' then
		if 	   player.main_job_level < 83 and  player.main_job_level > 0 then main_job_dw = 0
		elseif player.main_job_level < 90 and  player.main_job_level > 82 then main_job_dw = 10
		elseif player.main_job_level < 98 and  player.main_job_level > 89 then main_job_dw = 15
		elseif player.main_job_level < 100 and  player.main_job_level > 97 then main_job_dw = 25
		end
	end
	
	--notice( '[Sub dw: ' .. sub_job_dw .. '] [Main dw: ' .. main_job_dw .. ']')
	main_job_dw = main_job_dw + jp_dw_bonus
	-- if the sub job DW is higher return that instead of blue mage spell DW
	if sub_job_dw > main_job_dw then
		return sub_job_dw
	else
		return main_job_dw
	end
end

function get_total_haste()
	local gear_haste = 0
	local magic_haste = 0
	local ja_haste = 0
	local total = 0
	
	if (Gear_info['Haste'] + manual_ghaste) > 256 then
		gear_haste = 256
	else
		gear_haste = Gear_info['Haste'] + manual_ghaste
	end
	if (Buffs_inform.ma_haste + manual_mhaste) > 448 then
		magic_haste = 448
	else
		magic_haste = Buffs_inform.ma_haste + manual_mhaste
	end
	if (Buffs_inform.ja_haste + manual_jahaste)> 256 then
		ja_haste = 256
	else
		ja_haste = Buffs_inform.ja_haste + manual_jahaste
	end
	total = gear_haste + magic_haste + ja_haste
	
	return total
end

function dual_wield_needed()
	local DW_needed = 0
	local Weapon_Delay = determine_Weapon_Delay()
	local total_delay = Weapon_Delay.melee_delay
	local total_haste = get_total_haste()
	
	if total_haste > 819 then total_haste = 819 end
		
	if player.equipment.main.delay > 0 and Weapon_Delay.sub then	
		DW_needed = math.ceil(  (1- (0.2 / (  (1024 - total_haste)  / 1024) ) )* 100 - determine_DW() )
	end
	
	return DW_needed
end

function martial_arts_needed()
	local MA_needed = 0
	local WD = determine_Weapon_Delay()
	local Weapon_Delay = player.equipment.main.delay
	local total_delay = WD.melee_delay
	local total_haste = get_total_haste()
	local job_MA = WD.job_MA or 0
	local total_gear_MA = WD.gear_MA or 0
	local total_MA = job_MA + total_gear_MA
	
	if total_haste > 819 then total_haste = 819 end
		
	if player.equipment.main.skill == "Hand-to-Hand" or player.equipment.main.en == '' then
		local Delay = 480 + Weapon_Delay
		MA_needed = math.ceil(Delay - ((Delay * 20) / ( (  (1024 - total_haste)  / 1024 * 100)      ))) - total_MA
	end
	
	return total_gear_MA, MA_needed
end

