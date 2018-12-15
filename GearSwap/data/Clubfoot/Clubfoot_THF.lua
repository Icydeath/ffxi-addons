-------------------------------------------------------------------------------------------------------------------
-- Initialization function that defines sets and variables to be used.
-------------------------------------------------------------------------------------------------------------------

-- IMPORTANT: Make sure to also get the Mote-Include.lua file (and its supplementary files) to go with this.

-- Initialization function for this job file.
function get_sets()
	-- Load and initialize the include file.
    mote_include_version = 2
	include('Mote-Include.lua')
	include('organizer-lib')
end

-- Setup vars that are user-independent.
function job_setup()
	state.Buff['Sneak Attack'] = buffactive['sneak attack'] or false
	state.Buff['Trick Attack'] = buffactive['trick attack'] or false
	state.Buff['Feint'] = buffactive['feint'] or false

    include('Mote-TreasureHunter')
	determine_haste_group()
	
    state.CapacityMode = M(false, 'Capacity Point Mantle')
	-- For th_action_check():
	-- JA IDs for actions that always have TH: Provoke, Animated Flourish
	info.default_ja_ids = S{35, 204}
	-- Unblinkable JA IDs for actions that always have TH: Quick/Box/Stutter Step, Desperate/Violent Flourish
	info.default_u_ja_ids = S{201, 202, 203, 205, 207}
end


-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
	-- Options: Override default values
	state.OffenseMode:options('Normal', 'Mid', 'Acc')
	state.HybridMode:options('Normal', 'Evasion', 'PDT')
	state.RangedMode:options('Normal', 'Acc')
	state.WeaponskillMode:options('Normal', 'Mid', 'Acc')
	state.IdleMode:options('Normal')
	state.RestingMode:options('Normal')
	state.PhysicalDefenseMode:options('Evasion', 'PDT')
	state.MagicalDefenseMode:options('MDT')
	state.RangedMode:options('Normal')

	-- Additional local binds
	send_command('bind ^= gs c cycle treasuremode')
	send_command('bind !- gs c cycle targetmode')
    send_command('bind != gs c toggle CapacityMode')
	--select_default_macro_book()
end


-- Called when this job file is unloaded (eg: job change)
function file_unload()

	send_command('unbind !-')
	send_command('unbind !=')
	send_command('unbind ^[')
	send_command('unbind ![')
end

function init_gear_sets()
	--------------------------------------
	-- Start defining the sets
	--------------------------------------
	sets.TreasureHunter = {hands="Plunderer's Armlets +1", feet="Skulker's Poulaines +1", waist="Chaac Belt"}
    sets.ExtraRegen = {}
    sets.CapacityMantle = {back="Mecistopins Mantle"}

    sets.Organizer = {
		main="Taming Sari",
		sub="Sandung",
		capring="Capacity Ring",
    }
	
	sets.buff['Sneak Attack'] = {
		
    }

	sets.buff['Trick Attack'] = {
		
    }
    -- Precast Sets
	
	-- Precast sets to enhance JAs
	sets.precast.JA['Collaborator'] = {}
	sets.precast.JA['Accomplice'] = {}
	sets.precast.JA['Flee'] = {} -- feet="Rogue's Poulaines"
	sets.precast.JA['Hide'] = {}
	sets.precast.JA['Conspirator'] = {} -- body="Raider's Vest +2"
	sets.precast.JA['Steal'] = {
		head="Rogue's Bonnet",
		hands="Rogue's Armlets",
		legs="Rogue's Culottes",
		feet="Rogue's Poulaines"
	}
	sets.precast.JA['Despoil'] = {}
	sets.precast.JA['Perfect Dodge'] = {} -- hands="Plunderer's Armlets +1"
	sets.precast.JA['Feint'] = {} -- legs="Assassin's Culottes +1", hands="Plunderer's Armlets +1"
	
	sets.precast.JA['Sneak Attack'] = sets.buff['Sneak Attack']
	sets.precast.JA['Trick Attack'] = sets.buff['Trick Attack']

	-- Waltz set (chr and vit)
	sets.precast.Waltz = {}
	-- TH actions
	sets.precast.Step = {waist="Chaac Belt", right_ear="Choreia Earring"}
    
	sets.precast.Flourish1 = sets.TreasureHunter
	sets.precast.JA.Provoke = sets.TreasureHunter

	-- Fast cast sets for spells
	sets.precast.FC = {
	
	}
	sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck="Magoraga Beads", body="Passion Jacket"})

	-- Ranged snapshot gear
	sets.precast.RA = {}
    sets.midcast.RA = {}
    --sets.midcast['Enfeebling Magic'] = sets.midcast.RA
       
	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined
	sets.precast.WS = {
		ammo="Ginsen",
		head={ name="Adhemar Bonnet", augments={'DEX+10','AGI+10','Accuracy+15',}},
		body="Mummu Jacket",
		hands={ name="Herculean Gloves", augments={'Accuracy+23 Attack+23','"Dual Wield"+1','AGI+3','Accuracy+7','Attack+13',}},
		legs={ name="Herculean Trousers", augments={'Accuracy+21','"Triple Atk."+1','MND+3','Attack+3',}},
		feet={ name="Herculean Boots", augments={'Accuracy+15 Attack+15','"Triple Atk."+2','Accuracy+9',}},
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Mache Earring",
		right_ear="Kemas Earring",
		left_ring="Petrov Ring",
		right_ring="Epona's Ring",
		back="Atheling Mantle",
	}
	sets.precast.WS.Acc = set_combine(sets.precast.WS, {
	
	})

	-- Specific weaponskill sets.  Uses the base set if an appropriate WSMid version isn't found.
	sets.precast.WS['Exenterator'] = set_combine(sets.precast.WS, {})
	sets.precast.WS['Exenterator'].Mid = set_combine(sets.precast.WS['Exenterator'], {})
	sets.precast.WS['Exenterator'].Acc = set_combine(sets.precast.WS['Exenterator'].Mid, {})
	sets.precast.WS['Exenterator'].SA = set_combine(sets.precast.WS['Exenterator'].Mid, {})
	sets.precast.WS['Exenterator'].TA = set_combine(sets.precast.WS['Exenterator'].Mid, {})
	sets.precast.WS['Exenterator'].SATA = set_combine(sets.precast.WS['Exenterator'].SA, {})

	sets.precast.WS['Dancing Edge'] = set_combine(sets.precast.WS, {})
	sets.precast.WS['Dancing Edge'].Mid = set_combine(sets.precast.WS['Dancing Edge'], {})
	sets.precast.WS['Dancing Edge'].Acc = set_combine(sets.precast.WS['Dancing Edge'], {})
	sets.precast.WS['Dancing Edge'].SA = set_combine(sets.precast.WS['Dancing Edge'].Mid, {})
	sets.precast.WS['Dancing Edge'].TA = set_combine(sets.precast.WS['Dancing Edge'].Mid, {})
	sets.precast.WS['Dancing Edge'].SATA = set_combine(sets.precast.WS['Dancing Edge'].Mid, {})

	sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS, {})
	sets.precast.WS['Evisceration'].Mid = set_combine(sets.precast.WS['Evisceration'], {})
	sets.precast.WS['Evisceration'].Acc = set_combine(sets.precast.WS['Evisceration'], {})
	sets.precast.WS['Evisceration'].SA = set_combine(sets.precast.WS['Evisceration'].Mid, {})
	sets.precast.WS['Evisceration'].TA = set_combine(sets.precast.WS['Evisceration'].Mid, {})
	sets.precast.WS['Evisceration'].SATA = set_combine(sets.precast.WS['Evisceration'].Mid, {})
	
    sets.precast.WS["Rudra's Storm"] = set_combine(sets.precast.WS, {})
	sets.precast.WS["Rudra's Storm"].Mid = set_combine(sets.precast.WS["Rudra's Storm"], {})
	sets.precast.WS["Rudra's Storm"].Acc = set_combine(sets.precast.WS["Rudra's Storm"], {})
	sets.precast.WS["Rudra's Storm"].SA = set_combine(sets.precast.WS["Rudra's Storm"].Mid, {})
	sets.precast.WS["Rudra's Storm"].TA = set_combine(sets.precast.WS["Rudra's Storm"].Mid, {})
	sets.precast.WS["Rudra's Storm"].SATA = set_combine(sets.precast.WS["Rudra's Storm"].Mid, {})

	sets.precast.WS["Shark Bite"] = set_combine(sets.precast.WS, {})
	sets.precast.WS['Shark Bite'].Acc = set_combine(sets.precast.WS['Shark Bite'], {})
	sets.precast.WS['Shark Bite'].Mid = set_combine(sets.precast.WS['Shark Bite'], {})
	sets.precast.WS['Shark Bite'].SA = set_combine(sets.precast.WS['Shark Bite'].Mid, {})
	sets.precast.WS['Shark Bite'].TA = set_combine(sets.precast.WS['Shark Bite'].Mid, {})
	sets.precast.WS['Shark Bite'].SATA = set_combine(sets.precast.WS['Shark Bite'].Mid, {})

	sets.precast.WS['Aeolian Edge'] = {}
	
        -- Midcast Sets
	sets.midcast.FastRecast = {}
		
	-- Specific spells
	sets.midcast.Utsusemi = sets.midcast.FastRecast

	-- Ranged gear -- acc + TH
	sets.midcast.RA.TH = set_combine(sets.midcast.RA, set.TreasureHunter)

	sets.midcast.RA.Acc = sets.midcast.RA
	
	-- Resting sets
	sets.resting = set_combine(sets.idle, {})

	-- Idle sets (default idle set not needed since the other three are defined, but leaving for testing purposes)
	sets.idle = {
		ammo="Ginsen",
		head={ name="Adhemar Bonnet", augments={'DEX+10','AGI+10','Accuracy+15',}},
		body="Mummu Jacket",
		hands={ name="Plun. Armlets", augments={'Enhances "Perfect Dodge" effect',}},
		legs={ name="Herculean Trousers", augments={'Accuracy+21','"Triple Atk."+1','MND+3','Attack+3',}},
		feet="Skulk. Poulaines",
		neck="Sanctity Necklace",
		waist="Kentarch Belt",
		left_ear="Eabani Earring",
		right_ear="Suppanomimi",
		left_ring="Petrov Ring",
		right_ring="Epona's Ring",
		back="Atheling Mantle",
    }

	sets.idle.Town = set_combine(sets.idle, {})

    sets.idle.Regen = set_combine(sets.idle, {})
	
	sets.idle.Weak = sets.idle

	-- Defense sets
	sets.defense.Evasion = {}

	sets.defense.PDT = {}

	sets.defense.MDT = {}

	sets.Kiting = {feet="Skadi's Jambeaux +1"}

	-- Engaged sets

	-- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
	-- sets if more refined versions aren't defined.
	-- If you create a set with both offense and defense modes, the offense mode should be first.
	-- EG: sets.engaged.Dagger.Accuracy.Evasion
	
	-- Normal melee group
	sets.engaged = {
		ammo="Ginsen",
		head={ name="Adhemar Bonnet", augments={'DEX+10','AGI+10','Accuracy+15',}},
		body="Mummu Jacket",
		hands={ name="Plun. Armlets", augments={'Enhances "Perfect Dodge" effect',}},
		legs={ name="Herculean Trousers", augments={'Accuracy+21','"Triple Atk."+1','MND+3','Attack+3',}},
		feet="Skulk. Poulaines",
		neck="Sanctity Necklace",
		waist="Kentarch Belt",
		left_ear="Eabani Earring",
		right_ear="Suppanomimi",
		left_ring="Petrov Ring",
		right_ring="Epona's Ring",
		back="Atheling Mantle",
	}
    sets.engaged.Mid = set_combine(sets.engaged, {})
	sets.engaged.Acc = set_combine(sets.engaged.Mid, {})
	sets.engaged.Evasion = set_combine(sets.engaged, {})
    sets.engaged.Mid.Evasion = sets.engaged.Evasion
	sets.engaged.Acc.Evasion = set_combine(sets.engaged.Evasion, {})
	sets.engaged.PDT = set_combine(sets.engaged, {})
	sets.engaged.Mid.PDT = set_combine(sets.engaged.PDT, {})
	sets.engaged.Acc.PDT = set_combine(sets.engaged.PDT, {})
    
    -- Haste 43%
    sets.engaged.Haste_43 = set_combine(sets.engaged, {})
    sets.engaged.Mid.Haste_43 = set_combine(sets.engaged.Haste_43, {})
    sets.engaged.Acc.Haste_43 = set_combine(sets.engaged.Haste_43, {})
    sets.engaged.Evasion.Haste_43 = set_combine(sets.engaged.Haste_43, {})
    sets.engaged.PDT.Haste_43 = set_combine(sets.engaged.Haste_43, {})
    
     -- 40
    sets.engaged.Haste_40 = set_combine(sets.engaged, {})
    sets.engaged.Mid.Haste_40 = set_combine(sets.engaged.Haste_40, {})

    sets.engaged.Acc.Haste_40 = set_combine(sets.engaged.Acc.Haste_40, {})
    sets.engaged.Evasion.Haste_40 = set_combine(sets.engaged.Haste_40, {})
    sets.engaged.PDT.Haste_40 = set_combine(sets.engaged.Haste_40, {})

     -- 30
    sets.engaged.Haste_30 = set_combine(sets.engaged, {})
    sets.engaged.Mid.Haste_30 = set_combine(sets.engaged.Haste_30, {})
    sets.engaged.Acc.Haste_30 = set_combine(sets.engaged.Acc.Haste_30, {})
    sets.engaged.Evasion.Haste_30 = set_combine(sets.engaged.Haste_30, {})
    sets.engaged.PDT.Haste_30 = set_combine(sets.engaged.Haste_30, {})

     -- 25
    sets.engaged.Haste_25 = set_combine(sets.engaged, {})
    sets.engaged.Acc.Haste_25 = set_combine(sets.engaged.Acc.Haste_25, {})
    sets.engaged.Mid.Haste_25 = set_combine(sets.engaged.Haste_25, {})
    sets.engaged.Evasion.Haste_25 = set_combine(sets.engaged.Haste_25, {})
    sets.engaged.PDT.Haste_25 = set_combine(sets.engaged.Haste_25, {})
end


-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks that are called to process player actions at specific points in time.
-------------------------------------------------------------------------------------------------------------------

function job_precast(spell, action, spellMap, eventArgs)
	if state.Buff[spell.english] ~= nil then
		state.Buff[spell.english] = true
	end
	
	cancel_conflicting_buffs(spell, action, spellMap, eventArgs)
end

-- Run after the general precast() is done.
function job_post_precast(spell, action, spellMap, eventArgs)
	if spell.english == 'Aeolian Edge' and state.TreasureMode.value ~= 'None' then
		equip(sets.TreasureHunter)
	elseif spell.english=='Sneak Attack' or spell.english=='Trick Attack' or spell.type == 'WeaponSkill' then
		if state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime' then
			equip(sets.TreasureHunter)
		end
	end
    if spell.type == 'WeaponSkill' then
        if state.CapacityMode.value then
            equip(sets.CapacityMantle)
        end
    end
end

-- Run after the general midcast() set is constructed.
function job_post_midcast(spell, action, spellMap, eventArgs)
	if state.TreasureMode.value ~= 'None' and spell.action_type == 'Ranged Attack' then
		equip(sets.TreasureHunter)
	end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
	if state.Buff[spell.english] ~= nil then
		state.Buff[spell.english] = not spell.interrupted or buffactive[spell.english]
	end

	-- Weaponskills wipe SATA/Feint.  Turn those state vars off before default gearing is attempted.
	if spell.type == 'WeaponSkill' and not spell.interrupted then
		state.Buff['Sneak Attack'] = false
		state.Buff['Trick Attack'] = false
		state.Buff['Feint'] = false
	end
end

-- Called after the default aftercast handling is complete.
function job_post_aftercast(spell, action, spellMap, eventArgs)
	-- If Feint is active, put that gear set on on top of regular gear.
	-- This includes overlaying SATA gear.
	check_buff('Feint', eventArgs)
end


-------------------------------------------------------------------------------------------------------------------
-- Customization hooks.
-------------------------------------------------------------------------------------------------------------------

function get_custom_wsmode(spell, spellMap, defaut_wsmode)
	local wsmode

	if state.Buff['Sneak Attack'] then
		wsmode = 'SA'
	end
	if state.Buff['Trick Attack'] then
		wsmode = (wsmode or '') .. 'TA'
	end

	return wsmode
end


-- Called any time we attempt to handle automatic gear equips (ie: engaged or idle gear).
function job_handle_equipping_gear(playerStatus, eventArgs)
	-- Check that ranged slot is locked, if necessary
	check_range_lock()

	-- Check for SATA when equipping gear.  If either is active, equip
	-- that gear specifically, and block equipping default gear.
	check_buff('Sneak Attack', eventArgs)
	check_buff('Trick Attack', eventArgs)
end


function customize_idle_set(idleSet)
	if player.hpp < 80 then
		idleSet = set_combine(idleSet, sets.idle.Regen)
	end

	return idleSet
end


function customize_melee_set(meleeSet)
	if state.TreasureMode.value == 'Fulltime' then
		meleeSet = set_combine(meleeSet, sets.TreasureHunter)
	end
    if state.CapacityMode.value then
        meleeSet = set_combine(meleeSet, sets.CapacityMantle)
    end
	return meleeSet
end

-------------------------------------------------------------------------------------------------------------------
-- General hooks for change events.
-------------------------------------------------------------------------------------------------------------------

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
	-- If we gain or lose any haste buffs, adjust which gear set we target.
	if S{'haste','march', 'madrigal','embrava','haste samba'}:contains(buff:lower()) then
		determine_haste_group()
        handle_equipping_gear(player.status)
    end
	if state.Buff[buff] ~= nil then
		state.Buff[buff] = gain
		if not midaction() then
			handle_equipping_gear(player.status)
		end
	end
end


-------------------------------------------------------------------------------------------------------------------
-- Various update events.
-------------------------------------------------------------------------------------------------------------------

-- Called by the 'update' self-command.
function job_update(cmdParams, eventArgs)
	th_update(cmdParams, eventArgs)
	determine_haste_group()
end
-- Function to display the current relevant user state when doing an update.
-- Return true if display was handled, and you don't want the default info shown.
function display_current_job_state(eventArgs)
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

    msg = msg .. ', TH: ' .. state.TreasureMode.value
    add_to_chat(122, msg)
    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- State buff checks that will equip buff gear and mark the event as handled.
function check_buff(buff_name, eventArgs)
	if state.Buff[buff_name] then
		equip(sets.buff[buff_name] or {})
		if state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime' then
			equip(sets.TreasureHunter)
		end
		eventArgs.handled = true
	end
end

function determine_haste_group()
	
	classes.CustomMeleeGroups:clear()
    -- Haste (white magic) 15%
    -- Haste Samba (Sub) 5%
    -- Haste (Merited DNC) 10%
    -- Victory March +3/+4/+5     14%/15.6%/17.1%
    -- Advancing March +3/+4/+5   10.9%/12.5%/14%
    -- Embrava 25%
    if (buffactive.embrava or buffactive.haste) and buffactive.march == 2 then
        add_to_chat(8, '-------------Haste 43%-------------')
        classes.CustomMeleeGroups:append('Haste_43')
    elseif buffactive.embrava and buffactive.haste then
        add_to_chat(8, '-------------Haste 40%-------------')
        classes.CustomMeleeGroups:append('Haste_40')
    elseif (buffactive.haste and buffactive.march == 1) or (buffactive.march == 2 and buffactive['haste samba']) then
        add_to_chat(8, '-------------Haste 30%-------------')
        classes.CustomMeleeGroups:append('Haste_30')
    elseif buffactive.embrava or buffactive.march == 2 then
        add_to_chat(8, '-------------Haste 25%-------------')
        classes.CustomMeleeGroups:append('Haste_25')
    end

end

-- Check for various actions that we've specified in user code as being used with TH gear.
-- This will only ever be called if TreasureMode is not 'None'.
-- Category and Param are as specified in the action event packet.
function th_action_check(category, param)
	if category == 2 or -- any ranged attack
		--category == 4 or -- any magic action
		(category == 3 and param == 30) or -- Aeolian Edge
		(category == 6 and info.default_ja_ids:contains(param)) or -- Provoke, Animated Flourish
		(category == 14 and info.default_u_ja_ids:contains(param)) -- Quick/Box/Stutter Step, Desperate/Violent Flourish
		then return true
	end
end


-- Function to lock the ranged slot if we have a ranged weapon equipped.
function check_range_lock()
	if player.equipment.range ~= 'empty' then
		disable('range', 'ammo')
	else
		enable('range', 'ammo')
	end
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
	-- Default macro set/book
	if player.sub_job == 'DNC' then
		set_macro_page(5, 2)
	elseif player.sub_job == 'WAR' then
		set_macro_page(5, 1)
	elseif player.sub_job == 'NIN' then
		set_macro_page(5, 1)
	else
		set_macro_page(5, 2)
	end
end

