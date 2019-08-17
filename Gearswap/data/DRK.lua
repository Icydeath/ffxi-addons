-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

-- Initialization function for this job file.
function get_sets()
    -- Load and initialize the include file.
    include('Sel-Include.lua')
end

    -- Setup vars that are user-independent.
function job_setup()

    state.Buff.Souleater = buffactive.Souleater or false
    state.Buff['Dark Seal'] = buffactive['Dark Seal'] or false
	state.Buff['Nether Void'] = buffactive['Nether Void'] or false
    state.Buff['Aftermath'] = buffactive['Aftermath'] or false
    state.Buff['Aftermath: Lv.3'] = buffactive['Aftermath: Lv.3'] or false
    state.Buff.Hasso = buffactive.Hasso or false
    state.Buff.Seigan = buffactive.Seigan or false
	state.Stance = M{['description']='Stance','Hasso','Seigan','None'}
	state.DrainSwapWeaponMode = M{'Never','300','1000','Always'}
	
	autows = 'Resolution'
	autofood = 'Soy Ramen'
	
	update_melee_groups()

	init_job_states({"Capacity","AutoRuneMode","AutoTrustMode","AutoWSMode","AutoShadowMode","AutoFoodMode","AutoNukeMode","AutoStunMode","AutoDefenseMode","AutoBuffMode",},{"AutoSambaMode","Weapons","OffenseMode","WeaponskillMode","Stance","IdleMode","Passive","RuneElement","DrainSwapWeaponMode","CastingMode","TreasureMode",})
end
	
-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
	
function job_precast(spell, spellMap, eventArgs)

	if spell.type == 'WeaponSkill' and state.AutoBuffMode.value then
		local abil_recasts = windower.ffxi.get_ability_recasts()
		if spell.english == 'Entropy' and not buffactive['Sekkanoki'] and abil_recasts[95] < latency then
			eventArgs.cancel = true
			windower.chat.input('/ja "Consume Mana" <me>')
			windower.chat.input:schedule(1,'/ws "Entropy" <t>')
			return
		elseif player.sub_job == 'SAM' and not buffactive['Consume Mana'] and player.tp > 1850 and abil_recasts[140] < latency then
			eventArgs.cancel = true
			windower.chat.input('/ja "Sekkanoki" <me>')
			windower.chat.input:schedule(1,'/ws "'..spell.english..'" '..spell.target.raw..'')
			return
		elseif player.sub_job == 'SAM' and abil_recasts[134] < latency then
			eventArgs.cancel = true
			windower.chat.input('/ja "Meditate" <me>')
			windower.chat.input:schedule(1,'/ws "'..spell.english..'" '..spell.target.raw..'')
			return
		end
	end

end

function job_aftercast(spell, spellMap, eventArgs)
    if not spell.interrupted then
		if (spell.english == 'Drain II' or spell.english == 'Drain III') and state.DrainSwapWeaponMode.value ~= 'Never' then
			if player.equipment.main and sets.DrainWeapon and player.equipment.main == sets.DrainWeapon.main and player.equipment.main ~= sets.weapons[state.Weapons.value].main then
				handle_weapons()
			end
        elseif state.UseCustomTimers.value and (spell.english == 'Sleep' or spell.english == 'Sleepga') then
            send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 60 down spells/00220.png')
        elseif spell.skill == 'Elemental Magic' and state.MagicBurstMode.value == 'Single' then
            state.MagicBurstMode:reset()
			if state.DisplayMode.value then update_job_states()	end
        end
    end
end

-- Modify the default idle set after it was constructed.
function job_customize_idle_set(idleSet)
    if player.mpp < 51 and (state.IdleMode.value == 'Normal' or state.IdleMode.value == 'Sphere') and state.DefenseMode.value == 'None' then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end

    return idleSet
end

-- Modify the default melee set after it was constructed.
function job_customize_melee_set(meleeSet)
    if state.Buff.Souleater and state.DefenseMode.current == 'None' then
        meleeSet = set_combine(meleeSet, sets.buff.Souleater)
    end

    return meleeSet
end

function job_customize_defense_set(defenseSet)
    return defenseSet
end

-- Run after the general precast() is done.
function job_post_precast(spell, spellMap, eventArgs)
	
	if spell.type == 'WeaponSkill' then

		local WSset = standardize_set(get_precast_set(spell, spellMap))
		local wsacc = check_ws_acc()
		
		if (WSset.ear1 == "Moonshade Earring" or WSset.ear2 == "Moonshade Earring") then
			-- Replace Moonshade Earring if we're at cap TP
			if get_effective_player_tp(spell, WSset) > 3200 then
				if wsacc:contains('Acc') and not buffactive['Sneak Attack'] and sets.AccMaxTP then
					local AccMaxTPset = standardize_set(sets.AccMaxTP)

					if (AccMaxTPset.ear1:startswith("Lugra Earring") or AccMaxTPset.ear2:startswith("Lugra Earring")) and not classes.DuskToDawn and sets.AccDayMaxTPWSEars then
						equip(sets.AccDayMaxTPWSEars[spell.english] or sets.AccDayMaxTPWSEars)
					else
						equip(sets.AccMaxTP[spell.english] or sets.AccMaxTP)
					end
				elseif sets.MaxTP then
					local MaxTPset = standardize_set(sets.MaxTP)
					if (MaxTPset.ear1:startswith("Lugra Earring") or MaxTPset.ear2:startswith("Lugra Earring")) and not classes.DuskToDawn and sets.DayMaxTPWSEars then
						equip(sets.DayMaxTPWSEars[spell.english] or sets.DayMaxTPWSEars)
					else
						equip(sets.MaxTP[spell.english] or sets.MaxTP)
					end
				else
				end
			else
				if wsacc:contains('Acc') and not buffactive['Sneak Attack'] and (WSset.ear1:startswith("Lugra Earring") or WSset.ear2:startswith("Lugra Earring")) and not classes.DuskToDawn and sets.AccDayWSEars then
					equip(sets.AccDayWSEars[spell.english] or sets.AccDayWSEars)
				elseif (WSset.ear1:startswith("Lugra Earring") or WSset.ear2:startswith("Lugra Earring")) and not classes.DuskToDawn and sets.DayWSEars then
					equip(sets.DayWSEars[spell.english] or sets.DayWSEars)
				end
			end
			
			if state.Buff.Souleater then   
					equip(sets.buff.Souleater)
			end
		end
	end
end

function job_post_midcast(spell, spellMap, eventArgs)
    if spell.skill == 'Elemental Magic' and default_spell_map ~= 'ElementalEnfeeble' and spell.english ~= 'Impact' then
        if state.MagicBurstMode.value ~= 'Off' then equip(sets.MagicBurst) end
		if spell.element == world.weather_element or spell.element == world.day_element then
			if state.CastingMode.value == 'Fodder' then
				if spell.element == world.day_element then
					if item_available('Zodiac Ring') then
						sets.ZodiacRing = {ring2="Zodiac Ring"}
						equip(sets.ZodiacRing)
					end
				end
			end
		end
		
		if spell.element and sets.element[spell.element] then
			equip(sets.element[spell.element])
		end
	elseif spell.skill == 'Dark Magic' then
		if state.Buff['Nether Void'] and sets.buff['Nether Void'] and spell.english:startswith('Absorb') then
			equip(sets.buff['Nether Void'])
		end
		if state.Buff['Dark Seal'] and sets.buff['Dark Seal'] and (spell.english:startswith('Absorb') or spell.english == 'Dread Spikes' or spell.english == 'Drain II' or spell.english == 'Drain III') then
			equip(sets.buff['Dark Seal'])
		end
		if (spell.english == 'Drain II' or spell.english == 'Drain III') and state.DrainSwapWeaponMode.value ~= 'Never' then
			if sets.DrainWeapon and (state.DrainSwapWeaponMode.value == 'Always' or tonumber(state.DrainSwapWeaponMode.value) > player.tp) then
				enable('main','sub','range','ammo')
				equip(sets.DrainWeapon)
			end
		end
    end
end

function job_tick()
	if check_hasso() then return true end
	if check_buff() then return true end
	if check_buffup() then return true end
	return false
end

function job_update(cmdParams, eventArgs)
    update_melee_groups()
	
	if player.sub_job ~= 'SAM' and state.Stance.value ~= "None" then
		state.Stance:set("None")
		update_job_states()
	end
end

function job_buff_change(buff, gain)
	update_melee_groups()
end
	
function update_melee_groups()
    classes.CustomMeleeGroups:clear()
	
    if areas.Adoulin:contains(world.area) and buffactive.Ionis then
		classes.CustomMeleeGroups:append('Adoulin')
    end
	
	if (player.equipment.main == "Liberator" and buffactive['Aftermath: Lv.3']) or ((player.equipment.main == "Apocalypse" or player.equipment.main == "Ragnarok") and state.Buff['Aftermath']) then
			classes.CustomMeleeGroups:append('AM')
	end
	
end

function check_hasso()
	if not (state.Stance.value == 'None' or state.Buff.Hasso or state.Buff.Seigan) and player.sub_job == 'SAM' and player.in_combat then
		
		local abil_recasts = windower.ffxi.get_ability_recasts()
		
		if state.Stance.value == 'Hasso' and abil_recasts[138] < latency then
			windower.chat.input('/ja "Hasso" <me>')
			tickdelay = framerate
			return true
		elseif state.Stance.value == 'Seigan' and abil_recasts[139] < latency then
			windower.chat.input('/ja "Seigan" <me>')
			tickdelay = framerate
			return true
		else
			return false
		end
	end

	return false
end

function check_buff()
	if state.AutoBuffMode.value and not areas.Cities:contains(world.area) then
		local spell_recasts = windower.ffxi.get_spell_recasts()
		for i in pairs(buff_spell_lists['Auto']) do
			if not buffactive[buff_spell_lists['Auto'][i].Buff] and (buff_spell_lists['Auto'][i].When == 'Always' or (buff_spell_lists['Auto'][i].When == 'Combat' and (player.in_combat or being_attacked)) or (buff_spell_lists['Auto'][i].When == 'Engaged' and player.status == 'Engaged') or (buff_spell_lists['Auto'][i].When == 'Idle' and player.status == 'Idle') or (buff_spell_lists['Auto'][i].When == 'OutOfCombat' and not (player.in_combat or being_attacked))) and spell_recasts[buff_spell_lists['Auto'][i].SpellID] < latency and silent_can_use(buff_spell_lists['Auto'][i].SpellID) then
				windower.chat.input('/ma "'..buff_spell_lists['Auto'][i].Name..'" <me>')
				tickdelay = os.clock() + 2
				return true
			end
		end
		
		if player.in_combat then
			local abil_recasts = windower.ffxi.get_ability_recasts()

			if not buffactive['Last Resort'] and abil_recasts[87] < latency then
				windower.chat.input('/ja "Last Resort" <me>')
				tickdelay = os.clock() + 1.8
				return true
			elseif not buffactive['Scarlet Delirium'] and abil_recasts[44] < latency then
				windower.chat.input('/ja "Scarlet Delirium" <me>')
				tickdelay = os.clock() + 1.8
				return true
			elseif player.sub_job == 'WAR' and not buffactive.Berserk and abil_recasts[1] < latency then
				windower.chat.input('/ja "Berserk" <me>')
				tickdelay = os.clock() + 1.8
				return true
			elseif player.sub_job == 'WAR' and not buffactive.Aggressor and abil_recasts[4] < latency then
				windower.chat.input('/ja "Aggressor" <me>')
				tickdelay = os.clock() + 1.8
				return true
			else
				return false
			end
		end
	end
	return false
end

function check_buffup()
	if buffup ~= '' then
		local needsbuff = false
		for i in pairs(buff_spell_lists[buffup]) do
			if not buffactive[buff_spell_lists[buffup][i].Buff] and silent_can_use(buff_spell_lists[buffup][i].SpellID) then
				needsbuff = true
				break
			end
		end
	
		if not needsbuff then
			add_to_chat(217, 'All '..buffup..' buffs are up!')
			buffup = ''
			return false
		end
		
		local spell_recasts = windower.ffxi.get_spell_recasts()
		
		for i in pairs(buff_spell_lists[buffup]) do
			if not buffactive[buff_spell_lists[buffup][i].Buff] and silent_can_use(buff_spell_lists[buffup][i].SpellID) and spell_recasts[buff_spell_lists[buffup][i].SpellID] < latency then
				windower.chat.input('/ma "'..buff_spell_lists[buffup][i].Name..'" <me>')
				tickdelay = os.clock() + 2
				return true
			end
		end
		
		return false
	else
		return false
	end
end

buff_spell_lists = {
	Auto = {	
		{Name='Dread Spikes',Buff='Dread Spikes',SpellID=277,When='Combat'},
	},
	
	Default = {
		{Name='Dread Spikes',Buff='Dread Spikes',SpellID=277,Reapply=false},
	},
}