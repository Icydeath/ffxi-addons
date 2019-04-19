-------------------------------------------------------------------------------------------------------------------
-- General functions for manipulating state values via self-commands.
-- Only handles certain specific states that we've defined, though it
-- allows the user to hook into the cycle command.
-------------------------------------------------------------------------------------------------------------------

-- Routing function for general known self_commands.  Mappings are at the bottom of the file.
-- Handles splitting the provided command line up into discrete words, for the other functions to use.
function self_command(commandArgs)
    local commandArgs = commandArgs
    if type(commandArgs) == 'string' then
        commandArgs = T(commandArgs:split(' '))
        if #commandArgs == 0 then
            return
        end
    end

    -- init a new eventArgs
    local eventArgs = {handled = false}

    -- Allow users to override this code
    if user_job_self_command then
        user_job_self_command(commandArgs, eventArgs)
    end

    -- Allow jobs to override this code
    if not eventArgs.handled and job_self_command then
		job_self_command(commandArgs, eventArgs)
    end
	
    -- Allow jobs to override this code
    if not eventArgs.handled and user_self_command then
        user_self_command(commandArgs, eventArgs)
    end

    if not eventArgs.handled then
        -- Of the original command message passed in, remove the first word from
        -- the list (it will be used to determine which function to call), and
        -- send the remaining words as parameters for the function.
        local handleCmd = (table.remove(commandArgs, 1)):lower()

        if selfCommandMaps[handleCmd] then
            selfCommandMaps[handleCmd](commandArgs)
        end
    end
end


-------------------------------------------------------------------------------------------------------------------
-- Functions for manipulating state vars.
-------------------------------------------------------------------------------------------------------------------

-- Function to set various states to specific values directly.
-- User command format: gs c set [field] [value]
-- If a boolean [field] is used, but not given a [value], it will be set to true.
function handle_set(cmdParams)
    if #cmdParams == 0 then
        add_to_chat(123,'Sel-Libs: Set parameter failure: field not specified.')
        return
    end
    
	local toggleset
	if cmdParams[1]:lower() == 'toggle' then
		toggleset = true
		table.remove(cmdParams, 1)
	end
	
    local state_var = get_state(cmdParams[1])
    
    if state_var then
        local oldVal = state_var.value
        state_var:set(cmdParams[2])
        local newVal = state_var.value
		
		if toggleset and newVal == oldVal and newVal ~= 'Single' then
			handle_reset(cmdParams)
			return
		end
		
        local descrip = state_var.description or cmdParams[1]
        if state_change then
            state_change(descrip, newVal, oldVal)
        end

        local msg = descrip..' is now '..state_var.current
        if state_var == state.DefenseMode and newVal ~= 'None' then
            msg = msg .. ' (' .. state[newVal .. 'DefenseMode'].current .. ')'
        end
        msg = msg .. '.'
        
        add_to_chat(122, msg)
        handle_update({'auto'})
    else
        add_to_chat(123,'Sel-Libs: Set: Unknown field ['..cmdParams[1]..']')
    end

    -- handle string states: CombatForm, CombatWeapon, etc
end

-- Function to reset values to their defaults.
-- User command format: gs c reset [field]
-- Or: gs c reset all
function handle_reset(cmdParams)
    if #cmdParams == 0 then
        if _global.debug_mode then add_to_chat(123,'handle_reset: parameter failure: reset type not specified') end
        return
    end
    
    local state_var = get_state(cmdParams[1])

    local oldVal
    local newVal
    local descrip
    
    if state_var then
        oldVal = state_var.value
        state_var:reset()
        newVal = state_var.value
        
        local descrip = state_var.description or cmdParams[1]
        if state_change then
            state_change(descrip, newVal, oldVal)
        end

        add_to_chat(122,descrip..' is now '..state_var.current..'.')
        handle_update({'auto'})
    elseif cmdParams[1]:lower() == 'all' then
        for k,v in pairs(state) do
            if v._type == 'mode' then
                oldVal = v.value
                v:reset()
                newVal = v.value
                
                descrip = state_var.description
                if descrip and state_change then
                    state_change(descrip, newVal, oldVal)
                end
            end
        end

        if job_reset_state then
            job_reset_state('all')
        end

        if state_change then
            state_change('Reset All')
        end

        add_to_chat(122,"All state vars have been reset.")
        handle_update({'auto'})
    elseif job_reset_state then
        job_reset_state(cmdParams[1])
    else
        add_to_chat(123,'Sel-Libs: Reset: Unknown field ['..cmdParams[1]..']')
    end
end


-- Handle cycling through the options list of a state var.
-- User command format: gs c cycle [field]
function handle_cycle(cmdParams)
    if #cmdParams == 0 then
        add_to_chat(123,'Sel-Libs: Cycle parameter failure: field not specified.')
        return
    end
    
    local state_var = get_state(cmdParams[1])
    
    if state_var then
        local oldVal = state_var.value
        if cmdParams[2] and S{'reverse', 'backwards', 'r'}:contains(cmdParams[2]:lower()) then
            state_var:cycleback()
        else
            state_var:cycle()
        end
        local newVal = state_var.value
        
        local descrip = state_var.description or cmdParams[1]
        if state_change then
            state_change(descrip, newVal, oldVal)
        end

        add_to_chat(122,descrip..' is now '..state_var.current..'.')
        handle_update({'auto'})
    else
        add_to_chat(123,'Sel-Libs: Cycle: Unknown field ['..cmdParams[1]..']')
    end
end


-- Handle cycling backwards through the options list of a state var.
-- User command format: gs c cycleback [field]
function handle_cycleback(cmdParams)
    cmdParams[2] = 'reverse'
    handle_cycle(cmdParams)
end


-- Handle toggling of boolean mode vars.
-- User command format: gs c toggle [field]
function handle_toggle(cmdParams)
    if #cmdParams == 0 then
        add_to_chat(123,'Sel-Libs: Toggle parameter failure: field not specified.')
        return
    end
    
    local state_var = get_state(cmdParams[1])
    
    if state_var then
        local oldVal = state_var.value
        state_var:toggle()
        local newVal = state_var.value
        
        local descrip = state_var.description or cmdParams[1]
        if state_change then
            state_change(descrip, newVal, oldVal)
        end

        add_to_chat(122,descrip..' is now '..state_var.current..'.')
        handle_update({'auto'})
    else
        add_to_chat(123,'Sel-Libs: Toggle: Unknown field ['..cmdParams[1]..']')
    end
end


-- Function to force a boolean field to false.
-- User command format: gs c unset [field]
function handle_unset(cmdParams)
    if #cmdParams == 0 then
        add_to_chat(123,'Sel-Libs: Unset parameter failure: field not specified.')
        return
    end
    
    local state_var = get_state(cmdParams[1])
    
    if state_var then
        local oldVal = state_var.value
        state_var:unset()
        local newVal = state_var.value
        
        local descrip = state_var.description or cmdParams[1]
        if state_change then
            state_change(descrip, newVal, oldVal)
        end

        add_to_chat(122,descrip..' is now '..state_var.current..'.')
        handle_update({'auto'})
    else
        add_to_chat(123,'Sel-Libs: Toggle: Unknown field ['..cmdParams[1]..']')
    end
end

-------------------------------------------------------------------------------------------------------------------

-- User command format: gs c update [option]
-- Where [option] can be 'user' to display current state.
-- Otherwise, generally refreshes current gear used.
function handle_update(cmdParams)
    -- init a new eventArgs
    local eventArgs = {handled = false}

    reset_buff_states()

    -- Allow jobs to override this code
    if job_update then
        job_update(cmdParams, eventArgs)
    end

	if state.AutoSambaMode.value ~= 'Off' and not (player.main_job == 'DNC' or player.sub_job == 'DNC') then
		state.AutoSambaMode:set("Off")
	end
	
    if not eventArgs.handled then
        if handle_equipping_gear then
            handle_equipping_gear(player.status)
        end
    end

    if cmdParams[1] == 'user' then
        display_current_state()
    end
	
	update_job_states()
	update_combat_form()
end


-- showtp: equip the current TP set for examination.
function handle_showtp(cmdParams)
	update_combat_form()

    local msg = 'Showing current TP set: ['.. state.OffenseMode.value
    if state.HybridMode.value ~= 'Normal' then
        msg = msg .. '/' .. state.HybridMode.value
    end
    msg = msg .. ']'

    if #classes.CustomMeleeGroups > 0 then
        msg = msg .. ' ['
        for i = 1,#classes.CustomMeleeGroups do
            msg = msg .. classes.CustomMeleeGroups[i]
            if i < #classes.CustomMeleeGroups then
                msg = msg .. ', '
            end
        end
        msg = msg .. ']'
    end

    add_to_chat(122, msg)
    equip(get_melee_set())
end


-- Minor variation on the GearSwap "gs equip naked" command, that ensures that
-- all slots are enabled before removing gear.
-- Command: "gs c naked"
function handle_naked(cmdParams)
    enable('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
    equip(sets.naked)
end

function handle_weapons(cmdParams)
	local weaponSet
	if type(cmdParams) == 'string' then
		weaponSet = cmdParams
	elseif type(cmdParams) == 'table' then
		weaponSet = cmdParams[1]
	end
	if weaponSet == nil then
		if sets.weapons[state.Weapons.value] then
			equip_weaponset(state.Weapons.value)
		elseif state.Weapons.value == 'None' then
			enable('main','sub','range','ammo')
		end
	elseif weaponSet:lower() == 'default' then
		if (player.sub_job == 'DNC' or player.sub_job == 'NIN') and state.Weapons:contains('DualWeapons') and sets.weapons.DualWeapons then
			if state.Weapons.value ~= 'DualWeapons' then
				state.Weapons:set('DualWeapons')
			end
			equip_weaponset('DualWeapons')
		else
			state.Weapons:reset()
			if sets.weapons[state.Weapons.value] then
				equip_weaponset(state.Weapons.value)
			elseif state.Weapons.value == 'None' then
				enable('main','sub','range','ammo')
			end
		end
	elseif sets.weapons[weaponSet] then
		if state.Weapons:contains(weaponSet) and state.Weapons.value ~= weaponSet then
			state.Weapons:set(weaponSet)
		end
		equip_weaponset(weaponSet)
	elseif weaponSet:lower() == 'none' then
		if state.Weapons:contains('None') then
			enable('main','sub','range','ammo')
			state.Weapons:set('None')
		end
	else
		if sets.weapons[state.Weapons.value] then
			equip_weaponset(state.Weapons.value)
		end
		add_to_chat(123,"Error: A weapons set for ["..weaponSet.."] does not exist.")
	end
	
	if state.DisplayMode.value then update_job_states()	end
end

function equip_weaponset(cmdParams)
	enable('main','sub','range','ammo')
	if sets.weapons[cmdParams] then
		equip(sets.weapons[cmdParams])
	elseif cmdParams ~= 'None' then
		add_to_chat(123,'Error: A weapons set for ['..cmdParams..'] does not exist.')
	end
	if state.Weapons.value ~= 'None' then
		disable('main','sub')
		if sets.weapons[state.Weapons.value] and (sets.weapons[state.Weapons.value].range or sets.weapons[state.Weapons.value].ranged) then
			disable('range')
		end
		if sets.weapons[state.Weapons.value] and sets.weapons[state.Weapons.value].ammo then
			disable('ammo')
		end
	end
end

function handle_showset(cmdParams)
    enable('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
	
	equip_weaponset(state.Weapons.value)

	if cmdParams[1] ~= nil then
		local key_list = parse_set_to_keys(cmdParams)
		local set = get_set_from_keys(key_list)
	
		equip(set)
		disable('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
	else
		handle_update({'auto'})
	end
end

function handle_useitem(cmdParams)
	if cmdParams[1] ~= nil then
		local equipslot = (table.remove(cmdParams, 1)):lower()
		local useitem = table.concat(cmdParams, ' ')
		useItem = true
		if useItemName ~= useitem then
			add_to_chat(217,"Using "..useitem..", /heal to cancel.")
		end
		useItemName = useitem
		useItemSlot = equipslot
	else
		add_to_chat(122,'Syntax error with UseItem command - Use: gs c UseItem equipslot Item Name (Use item for non-equippable items).')
	end
end

function handle_forceequip(cmdParams)
	if cmdParams[1] ~= nil then
		local equipslot = (table.remove(cmdParams, 1)):lower()
		if equipslot == 'set' then
			local slots = T{}
			for slot,item in pairs(sets[cmdParams[1]]) do
				slots:append(slot)
			end
			enable(slots)
			equip(sets[cmdParams[1]])
			disable(slots)
		else
			local gear = table.concat(cmdParams, ' ')
			enable(equipslot)
			equip({[equipslot]=gear})
			disable(equipslot)
		end
	else
		handle_equipping_gear(player.status)
	end
end

function handle_quietdisable(cmdParams)
	if cmdParams[1] == nil or cmdParams[1] == all then
		disable('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
	else
		disable(cmdParams[1])
		handle_update({'auto'})
	end
end

function handle_quietenable(cmdParams)
	if cmdParams[1] == nil or cmdParams[1] == all then
		enable('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
	else
		enable(cmdParams[1])
		handle_update({'auto'})
	end
end

function handle_delayedcast()
	if delayed_cast ~= '' and delayed_target ~= '' then
		windower.send_command(''..delayed_cast..' '..delayed_target..'')
	end
end

function handle_autonuke(cmdParams)
	if #cmdParams == 0 then
		add_to_chat(122,'Your must specify a spell to autonuke with.')
	else
		autonuke = table.concat(cmdParams, ' '):ucfirst()
		add_to_chat(122,'Your autonuke spell is set to '..autonuke..'.')
		if state.DisplayMode.value then update_job_states()	end
	end
end

function handle_buffup(cmdParams)
	if #cmdParams == 0 then
		buffup = 'Default'
	elseif not buff_spell_lists[cmdParams[1]] then
		add_to_chat(123, ''..cmdParams[1]..' is not a buff list!')
		return
	else
		buffup = cmdParams[1]
	end
	
	for i in pairs(buff_spell_lists[buffup]) do
		if buff_spell_lists[buffup][i].Reapply then
			windower.send_command('cancel '..buff_spell_lists[buffup][i].Buff..'')
			tickdelay = os.clock() + 1.65
		end
	end
end

function handle_runeelement()
	windower.chat.input('/ja "'..state.RuneElement.value..'" <me>')
end

function handle_shadows()
	local spell_recasts = windower.ffxi.get_spell_recasts()
	if player.main_job == 'NIN' then
		if has_shadows() < 3 and player.job_points[(res.jobs[player.main_job_id].ens):lower()].jp_spent > 99 and spell_recasts[340] < spell_latency then
			windower.chat.input('/ma "Utsusemi: San" <me>')
			tickdelay = os.clock() + 1.8
			return true
		elseif has_shadows() < 2 and spell_recasts[339] < spell_latency then
			windower.chat.input('/ma "Utsusemi: Ni" <me>')
			tickdelay = os.clock() + 1.8
			return true
		elseif has_shadows() < 2 and spell_recasts[338] < spell_latency then
			windower.chat.input('/ma "Utsusemi: Ichi" <me>')
			tickdelay = os.clock() + 2
			return true
		else
			return false
		end
	elseif player.sub_job == 'NIN' then
		if has_shadows() < 2 and spell_recasts[339] < spell_latency then
			windower.chat.input('/ma "Utsusemi: Ni" <me>')
			tickdelay = os.clock() + 1.8
			return true
		elseif has_shadows() < 2 and spell_recasts[338] < spell_latency then
			windower.chat.input('/ma "Utsusemi: Ichi" <me>')
			tickdelay = os.clock() + 2
			return true
		else
			return false
		end
	elseif not has_shadows() and player.main_job == 'SAM' and windower.ffxi.get_ability_recasts()[133] < latency then
		windower.chat.input('/ja "Third Eye" <me>')
		tickdelay = os.clock() + .7
		return true
	elseif not has_shadows() and silent_can_use(679) and spell_recasts[679] < spell_latency then
		windower.chat.input('/ma "Occultation" <me>')
		tickdelay = os.clock() + 2
		return true
	elseif not has_shadows() and silent_can_use(53) and spell_recasts[53] < spell_latency then
		windower.chat.input('/ma "Blink" <me>')
		tickdelay = os.clock() + 2
		return true
	elseif not has_shadows() and silent_can_use(647) and spell_recasts[647] < spell_latency then
		windower.chat.input('/ma "Zephyr Mantle" <me>')
		tickdelay = os.clock() + 2
		return true
	elseif not has_shadows() and player.sub_job == 'SAM' and windower.ffxi.get_ability_recasts()[133] < latency then
		windower.chat.input('/ja "Third Eye" <me>')
		tickdelay = os.clock() + .7
		return true
	else
		return false
	end
end

function handle_autows(cmdParams)
	if #cmdParams == 0 then
		add_to_chat(122,'Your must specify a ws to auto-weaponskill with.')
	elseif state.RngHelper.value then
		if cmdParams[1] == 'tp' then
			rangedautowstp = tonumber(cmdParams[2])
			add_to_chat(122,'Your ranged autows tp value is set to '..rangedautowstp..'.')
			if state.DisplayMode.value then update_job_states()	end
		else
			rangedautows = table.concat(cmdParams, ' '):ucfirst()
			add_to_chat(122,'Your ranged autows weaponskill is set to '..rangedautows..'.')
			if state.DisplayMode.value then update_job_states()	end
		end
	elseif cmdParams[1] == 'tp' then
		autowstp = tonumber(cmdParams[2])
		add_to_chat(122,'Your autows tp value is set to '..autowstp..'.')
		if state.DisplayMode.value then update_job_states()	end
	else
		autows = table.concat(cmdParams, ' '):ucfirst()
		add_to_chat(122,'Your autows weaponskill is set to '..autows..'.')
		if state.DisplayMode.value then update_job_states()	end
	end
end

function handle_autofood(cmdParams)
	if #cmdParams == 0 then
		add_to_chat(122,'Your must specify a food to automatically eat.')
	else
		autofood = table.concat(cmdParams, ' '):ucfirst()
		add_to_chat(122,'Your autofood item is set to '..autofood..'.')
		if state.DisplayMode.value then update_job_states()	end
	end
end

function handle_displayrune()
	
	local RuneResist = ''
	local RuneDamage = ''

	if state.RuneElement.value == 'Ignis' then
                RuneResist = "<Ice> (Bind, Paralyze)"
                RuneDamage = '<Fire> (Strong vs Ice, Weak vs Water)'
        elseif state.RuneElement.value == 'Gelus' then
                RuneResist = "<Wind> (Gravity, Silence)"
                RuneDamage = '<Ice> (Strong vs Wind, Weak vs Fire)'
        elseif state.RuneElement.value == 'Flabra' then
                RuneResist = "<Earth> (Petrify, Slow)"
                RuneDamage = '<Wind> (Strong vs Earth, Weak vs Ice)'
        elseif state.RuneElement.value == 'Tellus' then
                RuneResist = "<Lightning> (Stun)"
                RuneDamage = '<Earth> (Strong vs Lightning, Weak vs Wind)'
        elseif state.RuneElement.value == 'Sulpor' then
                RuneResist = "<Water> (Poison)"
                RuneDamage = '<Lightning> (Strong vs Water, Weak vs Earth)'
        elseif state.RuneElement.value == 'Unda' then
                RuneResist = "<Fire> (Addle, Amnesia, Plague)"
                RuneDamage = '<Water> (Strong vs Fire, Weak vs Lightning)'
        elseif state.RuneElement.value == 'Lux' then
                RuneResist = "<Darkness> (Curse, Doom, Sleep, Terror, Zombie, Blind)"
                RuneDamage = '<Light> (Strong vs Darkness)'
        elseif state.RuneElement.value == 'Tenebrae' then
                RuneResist = "<Light> (Charm, Repose)"
                RuneDamage = '<Darkness> (Strong vs Light)'
	end

	add_to_chat(8,''..state.RuneElement.value..' Resists: '.. RuneResist ..', Deals: '.. RuneDamage ..'')
end

function handle_displayelement()
	
	if state.ElementalMode.value == 'Fire' then
		add_to_chat(8,'<Fire> (Strong vs Ice, Weak vs Water)')
	elseif state.ElementalMode.value == 'Wind' then
		add_to_chat(8,'<Wind> (Strong vs Earth, Weak vs Ice)')
	elseif state.ElementalMode.value == 'Lightning' then
		add_to_chat(8,'<Lightning> (Strong vs Water, Weak vs Earth)')
	elseif state.ElementalMode.value == 'Light' then
		add_to_chat(8,'<Light> (Strong vs Darkness)')
	elseif state.ElementalMode.value == 'Earth' then
		add_to_chat(8,'<Earth> (Strong vs Lightning, Weak vs Wind)')
	elseif state.ElementalMode.value == 'Ice' then
		add_to_chat(8,'<Ice> (Strong vs Wind, Weak vs Fire)')
	elseif state.ElementalMode.value == 'Water' then
		add_to_chat(8,'<Water> (Strong vs Fire, Weak vs Lightning)')
	elseif state.ElementalMode.value == 'Dark' then
		add_to_chat(8,'<Darkness> (Strong vs Light)')
	end

end

function handle_displayshot()
	if state.ElementalMode.value == 'Fire' then
		add_to_chat(8,'<Fire> (Strong vs Ice, Weak vs Water)')
		add_to_chat(8,'Shot Enhances: Burn.')
	elseif state.ElementalMode.value == 'Wind' then
		add_to_chat(8,'<Wind> (Strong vs Earth, Weak vs Ice)')
		add_to_chat(8,'Shot Enhances: Choke.')
	elseif state.ElementalMode.value == 'Lightning' then
		add_to_chat(8,'<Lightning> (Strong vs Water, Weak vs Earth)')
		add_to_chat(8,'Shot Enhances: Shock.')
	elseif state.ElementalMode.value == 'Light' then
		add_to_chat(8,'<Light> (Strong vs Darkness)')
		add_to_chat(8,'Shot Enhances: Dia')
		add_to_chat(8,'Shot Effect: Sleep.')
	elseif state.ElementalMode.value == 'Earth' then
		add_to_chat(8,'<Earth> (Strong vs Lightning, Weak vs Wind)')
		add_to_chat(8,'Shot Enhances: Slow, Hojo, Rasp.')
	elseif state.ElementalMode.value == 'Ice' then
		add_to_chat(8,'<Ice> (Strong vs Wind, Weak vs Fire)')
		add_to_chat(8,'Shot Enhances: Paralyze, Frost.')
	elseif state.ElementalMode.value == 'Water' then
		add_to_chat(8,'<Water> (Strong vs Fire, Weak vs Lightning)')
		add_to_chat(8,'Shot Enhances: Poison, Drown.')
	elseif state.ElementalMode.value == 'Dark' then
		add_to_chat(8,'<Darkness> (Strong vs Light)')
		add_to_chat(8,'Shot Enhances: Bio, Blind, Kurayami.')
		add_to_chat(8,'Shot Effect: Dispel.')
	end

end

function handle_curecheat(cmdParams)
    if sets.HPDown then
        curecheat = true
		equip(sets.HPDown)
		if player.main_job == 'BLU' then
			send_command('@wait 1;input /ma "Magic Fruit" <me>')
		elseif player.main_job == 'WHM' then
			send_command('@wait 1;input /ma "Cure III" <me>')
		else
			send_command('@wait 1;input /ma "Cure IV" <me>')
		end
	--If we only have an HighHP set, we assume that this is sufficient.
	elseif sets.HPCure then
		curecheat = true
		if player.main_job == 'BLU' then
			windower.chat.input('/ma "Magic Fruit" <me>')
		elseif player.main_job == 'WHM' then
			windower.chat.input('/ma "Cure III" <me>')
		else
			windower.chat.input('/ma "Cure IV" <me>')
		end
    else
        add_to_chat(123,"You don't have a sets.HPDown nor a sets.HPCure to cheat with.")
    end
end

function handle_smartcure()
	local cureTarget = '<t>'
	local missingHP
	local spell_recasts = windower.ffxi.get_spell_recasts()
	-- If curing ourself, get our exact missing HP
	if player.target.type == "SELF" or player.target.type == 'MONSTER' or player.target.type == 'NONE' then
		missingHP = player.max_hp - player.hp
		cureTarget = '<me>'
	elseif player.target.status:lower():contains('dead') then
		windower.chat.input('/ma "Raise III" '..cureTarget..'')
		return
	-- If curing someone in our alliance, we can estimate their missing HP
	elseif player.target.isallymember then
		local target = find_player_in_alliance(player.target.name)
		local est_max_hp = target.hp / (target.hpp/100)
		missingHP = math.floor(est_max_hp - target.hp)
	else
		if player.target.hpp > 95 then
			if spell_recasts[1] < spell_latency then
				windower.chat.input('/ma "Cure" '..cureTarget..'')
			elseif spell_recasts[2] < spell_latency then
				windower.chat.input('/ma "Cure II" '..cureTarget..'')
			else
				add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
			end
		elseif player.target.hpp > 85 then
			if spell_recasts[2] < spell_latency then
				windower.chat.input('/ma "Cure II" <t>')
			elseif spell_recasts[3] < spell_latency then
				windower.chat.input('/ma "Cure III" <t>')
			elseif spell_recasts[1] < spell_latency then
				windower.chat.input('/ma "Cure" <t>')
			else
				add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
			end
		elseif player.target.hpp > 70 then
			if spell_recasts[3] < spell_latency then
				windower.chat.input('/ma "Cure III" <t>')
			elseif silent_can_use(4) and spell_recasts[4] < spell_latency then
				windower.chat.input('/ma "Cure IV" <t>')
			elseif spell_recasts[2] < spell_latency then
				windower.chat.input('/ma "Cure II" <t>')
			else
				add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
			end
		else
			if silent_can_use(4) and spell_recasts[4] < spell_latency then
				windower.chat.input('/ma "Cure IV" <t>')
			elseif spell_recasts[3] < spell_latency then
				windower.chat.input('/ma "Cure III" <t>')
			elseif spell_recasts[2] < spell_latency then
				windower.chat.input('/ma "Cure II" <t>')
			else
				add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
			end
		end
		return
	end
	
	if missingHP < 170 then
		if spell_recasts[1] < spell_latency then
			windower.chat.input('/ma "Cure" '..cureTarget..'')
		elseif spell_recasts[2] < spell_latency then
			windower.chat.input('/ma "Cure II" '..cureTarget..'')
		else
			add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
		end
	elseif missingHP < 350 then
		if spell_recasts[2] < spell_latency then
			windower.chat.input('/ma "Cure II" '..cureTarget..'')
		elseif spell_recasts[3] < spell_latency then
			windower.chat.input('/ma "Cure III" '..cureTarget..'')
		elseif spell_recasts[1] < spell_latency then
			windower.chat.input('/ma "Cure" '..cureTarget..'')
		else
			add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
		end
	elseif missingHP < 700 then
		if spell_recasts[3] < spell_latency then
			windower.chat.input('/ma "Cure III" '..cureTarget..'')
		elseif spell_recasts[4] < spell_latency then
			windower.chat.input('/ma "Cure IV" '..cureTarget..'')
		elseif spell_recasts[2] < spell_latency then
			windower.chat.input('/ma "Cure II" '..cureTarget..'')
		else
			add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
		end
	else
		if spell_recasts[4] < spell_latency then
			windower.chat.input('/ma "Cure IV" '..cureTarget..'')
		elseif spell_recasts[3] < spell_latency then
			windower.chat.input('/ma "Cure III" '..cureTarget..'')
		elseif spell_recasts[2] < spell_latency then
			windower.chat.input('/ma "Cure II" '..cureTarget..'')
		else
			add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
		end
	end
end

function handle_mount(cmdParams)
	if player.status == 'Mount' then
		windower.chat.input('/dismount')
	else
		if #cmdParams == 0 then
			add_to_chat(123,'Your must specify a mount to ride.')
			return
		else
			local mount = table.concat(cmdParams, ' '):ucfirst()
			windower.chat.input('/mount '..mount..'')
		end
	end
end

------------------------------------------------------------------------------------------------------------------

-- Get the state var that matches the requested name.
-- Only returns mode vars.
function get_state(name)
    if state[name] then
        return state[name]._class == 'mode' and state[name] or nil
    else
        local l_name = name:lower()
        for key,var in pairs(state) do
            if key:lower() == l_name then
                return var._class == 'mode' and var or nil
            end
        end
    end
end


-- Function to reset state.Buff values (called from update).
function reset_buff_states()
    if state.Buff then
        for buff,present in pairs(state.Buff) do
            if mote_vars.res_buffs:contains(buff) then
                state.Buff[buff] = buffactive[buff] or false
            end
        end
    end
end


-- Function to display the current relevant user state when doing an update.
-- Uses display_current_job_state instead if that is defined in the job lua.
function display_current_state()
    local eventArgs = {handled = false}
    if display_current_job_state then
        display_current_job_state(eventArgs)
    end

    if not eventArgs.handled then
        local msg = 'Melee'
        
        if state.CombatForm.has_value then
            msg = msg .. ' (' .. state.CombatForm.value .. ')'
        end
        
        msg = msg .. ': '
        
        msg = msg .. state.OffenseMode.value
        if state.HybridMode.value ~= 'Normal' then
            msg = msg .. '/' .. state.HybridMode.value
        end
        msg = msg .. ', WS: ' .. state.WeaponskillMode.value
        
        if state.DefenseMode.value ~= 'None' then
            msg = msg .. ', Defense: ' .. state.DefenseMode.value .. ' (' .. state[state.DefenseMode.value .. 'DefenseMode'].value .. ')'
        end
        
        if state.Kiting.value == true then
            msg = msg .. ', Kiting'
        end

        if state.PCTargetMode.value ~= 'default' then
            msg = msg .. ', Target PC: '..state.PCTargetMode.value
        end

        if state.SelectNPCTargets.value == true then
            msg = msg .. ', Target NPCs'
        end

        add_to_chat(122, msg)
    end

    if state.EquipStop.value ~= 'off' then
        add_to_chat(122,'Gear equips are blocked after ['..state.EquipStop.value..'].  Use "//gs c reset equipstop" to turn it off.')
    end
end

-- Generic version of this for casters
function display_current_caster_state()
    local msg = ''
    
    if state.OffenseMode.value ~= 'None' then
        msg = msg .. 'Melee'

        if state.CombatForm.has_value then
            msg = msg .. ' (' .. state.CombatForm.value .. ')'
        end
        
        msg = msg .. ', '
    end
    
    msg = msg .. 'Casting ['..state.CastingMode.value..'], Idle ['..state.IdleMode.value..']'
    
    if state.DefenseMode.value ~= 'None' then
        msg = msg .. ', ' .. 'Defense: ' .. state.DefenseMode.value .. ' (' .. state[state.DefenseMode.value .. 'DefenseMode'].value .. ')'
    end
    
    if state.Kiting.value == true then
        msg = msg .. ', Kiting'
    end

    if state.PCTargetMode.value ~= 'default' then
        msg = msg .. ', Target PC: '..state.PCTargetMode.value
    end

    if state.SelectNPCTargets.value == true then
        msg = msg .. ', Target NPCs'
    end

    add_to_chat(122, msg)
end


-------------------------------------------------------------------------------------------------------------------

-- Function to show what commands are available, and their syntax.
-- Syntax: gs c help
-- Or: gs c
function handle_help(cmdParams)
    if cmdParams[1] and cmdParams[1]:lower():startswith('field') then
        print('Predefined Library Fields:')
        print('--------------------------')
        print('OffenseMode, HybridMode, RangedMode, WeaponskillMode')
        print('CastingMode, IdleMode, RestingMode, Kiting')
        print('DefenseMode, PhysicalDefenseMode, MagicalDefenseMode')
        print('SelectNPCTargets, PCTargetMode')
        print('EquipStop (precast, midcast, pet_midcast)')
    else
        print('Custom Library Self-commands:')
        print('-----------------------------')
        print('Show TP Set:      gs c showtp')
        print('Toggle bool:      gs c toggle [field]')
        print('Cycle list:       gs c cycle [field] [(r)everse]')
        print('Cycle list back:  gs c cycleback [field]')
        print('Reset a state:    gs c reset [field]')
        print('Reset all states: gs c reset all')
        print('Set state var:    gs c set [field] [value]')
        print('Set bool true:    gs c set [field]')
        print('Set bool false:   gs c unset [field]')
        print('Remove gear:      gs c naked')
        print('Show TP Set:      gs c showtp')
        print('State vars:       gs c help field')
    end
end


-- A function for testing lua code.  Called via "gs c test".
function handle_test(cmdParams)
    if user_test then
        user_test(cmdParams)
    elseif job_test then
        job_test(cmdParams)
    end
end

function handle_facetarget()
	face_target()
end

-------------------------------------------------------------------------------------------------------------------
-- The below table maps text commands to the above handler functions.
-------------------------------------------------------------------------------------------------------------------

selfCommandMaps = {
    ['toggle']   		= handle_toggle,
    ['cycle']    		= handle_cycle,
    ['cycleback']		= handle_cycleback,
    ['set']      		= handle_set,
    ['reset']    		= handle_reset,
    ['unset']    		= handle_unset,
    ['update']   		= handle_update,
    ['showtp']   		= handle_showtp,
    ['naked']    		= handle_naked,
	['weapons']  		= handle_weapons,
	['showset']  		= handle_showset,
    ['help']     		= handle_help,
    ['forceequip']  	= handle_forceequip,
	['useitem']			= handle_useitem,
    ['quietenable'] 	= handle_quietenable,
	['quietdisable']	= handle_quietdisable,
	['autonuke'] 		= handle_autonuke,
	['autows'] 			= handle_autows,
	['autofood']		= handle_autofood,
	['facetarget']		= handle_facetarget,
    ['test']        	= handle_test,
	['displayrune'] 	= handle_displayrune,
	['displayshot'] 	= handle_displayshot,
	['displayelement'] 	= handle_displayelement,
	['curecheat'] 		= handle_curecheat,
	['smartcure']		= handle_smartcure,
	['mount'] 			= handle_mount,
	['shadows']			= handle_shadows,
	['buffup']			= handle_buffup,
	['delayedcast']		= handle_delayedcast,
	['runeelement']		= handle_runeelement,
	}