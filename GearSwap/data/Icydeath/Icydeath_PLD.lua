--[[
-----------------------------------------------------------------------------------------------------------------
== TODO ==
	Add a warning for
		- Crusade
		- Repraisal
		- Enlight/Enlight II
		

-----------------------------------------------------------------------------------------------------------------
--]]

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2

    -- Load and initialize the include file.
    include('Mote-Include.lua')
	include('organizer-lib.lua')
end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    state.Buff.Sentinel = buffactive.sentinel or false
    state.Buff.Cover = buffactive.cover or false
    state.Buff.Doom = buffactive.Doom or false
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('PDT', 'MDT', 'Normal', 'Acc')
    state.HybridMode:options('Normal', 'PDT', 'Reraise')
    state.WeaponskillMode:options('Normal', 'Acc')
    --state.CastingMode:options('Normal', 'Resistant')
    state.PhysicalDefenseMode:options('PDT', 'HP', 'Reraise', 'Charm')
    state.MagicalDefenseMode:options('MDT', 'HP', 'Reraise', 'Charm')
    
    state.ExtraDefenseMode = M{['description']='Extra Defense Mode', 'None', 'MP', 'Knockback', 'MP_Knockback'}
    state.EquipShield = M(false, 'Equip Shield w/Defense')

    update_defense_mode()
    
    send_command('bind ^f11 gs c cycle MagicalDefenseMode')
    send_command('bind !f11 gs c cycle ExtraDefenseMode')
    send_command('bind @f10 gs c toggle EquipShield')
    send_command('bind @f11 gs c toggle EquipShield')

    --select_default_macro_book(15)
	set_lockstyle('1')
end

function user_unload()
    send_command('unbind ^f11')
    send_command('unbind !f11')
    send_command('unbind @f10')
    send_command('unbind @f11')
end


-- Define sets and vars used by this job file.
function init_gear_sets()
	organizer_items = {
		echoes="Echo Drops",
		capring="Capacity Ring"
	}
	
    --------------------------------------
    -- Precast sets
    --------------------------------------
	
    -- Precast sets to enhance JAs
    sets.precast.JA['Invincible'] = {legs="Caballarius Breeches"}
    sets.precast.JA['Holy Circle'] = {} --feet="Reverence Leggings"
    sets.precast.JA['Shield Bash'] = {hands="Caballarius Gauntlets"} --ear1="Knightly earring"
    sets.precast.JA['Sentinel'] = {feet="Caballarius Leggings"}
    sets.precast.JA['Rampart'] = {head="Caballarius Coronet"}
    sets.precast.JA['Fealty'] = {body="Caballarius Surcoat"}
    sets.precast.JA['Divine Emblem'] = {feet="Creed Sabatons +2"}
    sets.precast.JA['Cover'] = {} --head="Reverence Coronet"

    -- add mnd for Chivalry
    sets.precast.JA['Chivalry'] = {
        -- head="Reverence Coronet",
        body="Caballarius Surcoat",
	}
    

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {}
        
    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz['Healing Waltz'] = {}
    
    sets.precast.Step = {} 
    sets.precast.Flourish1 = {} 

    -- Fast cast sets for spells
    -- Cap = 80%
    sets.precast.FC = {
		ammo="Impatiens",
		head={ name="Carmine Mask", augments={'Accuracy+15','Mag. Acc.+10','"Fast Cast"+3',}},
		hands={ name="Leyline Gloves", augments={'Accuracy+15','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+3',}},
		legs={ name="Odyssean Cuisses", augments={'"Fast Cast"+5',}},
		feet={ name="Odyssean Greaves", augments={'Accuracy+25 Attack+25','STR+4','Accuracy+7','Attack+2',}},
		left_ear="Enchntr. Earring +1",
		right_ear="Loquac. Earring",
		left_ring="Prolix Ring",
		back="Rudianos's Mantle",
	}
	
	sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {
		waist="Siegel Sash"
	})
	
	sets.precast.FC['Healing Magic'] = set_combine(sets.precast.FC, {
		left_ear="Nourishing Earring",
		right_ear="Nourishing Earring +1",
	})
       
    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
		ammo="Ginsen",
		head={ name="Founder's Corona", augments={'DEX+8','Accuracy+15','Mag. Acc.+14','Magic dmg. taken -3%',}},
		body={ name="Found. Breastplate", augments={'Accuracy+14','Mag. Acc.+13','Attack+14','"Mag.Atk.Bns."+14',}},
		hands="Sulev. Gauntlets +1",
		legs="Sulevi. Cuisses +1",
		feet="Sulev. Leggings +1",
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Steelflash Earring",
		right_ear="Bladeborn Earring",
		left_ring="Petrov Ring",
		right_ring="Begrudging Ring",
		back="Rudianos's Mantle",
	}

    sets.precast.WS.Acc = set_combine(sets.precast.WS, {})

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
	
	-- Mod: 80% DEX
	sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS, { })
    sets.precast.WS['Chant du Cygne'].Acc = set_combine(sets.precast.WS['Chant du Cygne'], { })
	
	-- Deals property-less damage (not Magic or Physical), but uses regular physical damage equations. 
	-- Mod: 73~85% MND
    sets.precast.WS['Requiescat'] = { 
		ammo="Hasty Pinion +1",
		head={ name="Carmine Mask", augments={'Accuracy+15','Mag. Acc.+10','"Fast Cast"+3',}},
		body="Chozor. Coselete",
		hands={ name="Leyline Gloves", augments={'Accuracy+15','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+3',}},
		legs={ name="Founder's Hose", augments={'MND+5','Mag. Acc.+5','Attack+7','Breath dmg. taken -2%',}},
		feet={ name="Odyssean Greaves", augments={'Accuracy+25 Attack+25','STR+4','Accuracy+7','Attack+2',}},
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Steelflash Earring",
		right_ear="Bladeborn Earring",
		left_ring="Petrov Ring",
		right_ring="Begrudging Ring",
		back="Rudianos's Mantle",
	}
    sets.precast.WS['Requiescat'].Acc = set_combine(sets.precast.WS['Requiescat'], { })

	-- dSTAT: (pINT-mINT)*2
	-- Mod: 50% MND / 30% STR
    sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS["Requiescat"], {
		neck="Unmoving Collar",
		waist="Grunfeld Rope"
	})
    
	-- Damage dealt is based on Enmity, capping out at Player Level*10 damage.
	-- Weapon Skill Damage equipment applies to both hits.
    sets.precast.WS['Atonement'] = set_combine(sets.precast.WS, sets.midcast.Enmity)
    
	
	
    --------------------------------------
    -- Midcast sets
    --------------------------------------
	
	-- Cap gear haste
    sets.midcast.FastRecast = {
		head={ name="Carmine Mask", augments={'Accuracy+15','Mag. Acc.+10','"Fast Cast"+3',}},
		body="Chozor. Coselete",
		hands={ name="Souv. Handschuhs", augments={'HP+50','Shield skill +10','Phys. dmg. taken -3',}},
		legs={ name="Odyssean Cuisses", augments={'"Fast Cast"+5',}},
		feet="Hippomenes Socks",
	}
        
    sets.midcast.Enmity = {
		head={ name="Cab. Coronet", augments={'Enhances "Iron Will" effect',}},
		body={ name="Souveran Cuirass", augments={'HP+80','Enmity+7','Potency of "Cure" effect received +10%',}},
		hands={ name="Eschite Gauntlets", augments={'Mag. Evasion+15','Spell interruption rate down +15%','Enmity+7',}},
		legs={ name="Cab. Breeches", augments={'Enhances "Invincible" effect',}},
		feet="Eschite Greaves",
		neck="Unmoving Collar",
		waist="Creed Baudrier",
		right_ear="Friomisi Earring",
		ring1="Apeile Ring",
		ring2="Apeile Ring +1",
		back="Fierabras's Mantle",
	}
	sets.midcast.Stun = sets.midcast.Enmity
	
    sets.midcast.Cure = set_combine(sets.midcast.Enmity, {
		body={ name="Jumalik Mail", augments={'HP+50','Attack+13','Enmity+7','"Refresh"+1',}},
		legs={ name="Founder's Hose", augments={'MND+5','Mag. Acc.+5','Attack+7','Breath dmg. taken -2%',}},
		feet={ name="Odyssean Greaves", augments={'Accuracy+25 Attack+25','STR+4','Accuracy+7','Attack+2',}},
		left_ear="Nourish. Earring",
		right_ear="Nourish. Earring +1",
		back="Fierabras's Mantle",
	})

    sets.midcast['Enhancing Magic'] = {
		head={ name="Carmine Mask", augments={'Accuracy+15','Mag. Acc.+10','"Fast Cast"+3',}},
		waist="Olympus Sash",
		left_ear="Andoaa Earring",
		back="Merciful Cape"
	}
    
	sets.midcast['Phalanx'] = set_combine(sets.midcast['Enhancing Magic'], {
		hands={ name="Souv. Handschuhs", augments={'HP+50','Shield skill +10','Phys. dmg. taken -3',}}, -- phalanx +4
		back="Weard Mantle" -- phalanx +5
	})
	
	-- Divine magic to enhance Enlight
	sets.midcast['Divine Magic'] = {
		head={ name="Jumalik Helm", augments={'MND+7','"Mag.Atk.Bns."+12','Magic burst mdg.+7%',}},
		hands={ name="Eschite Gauntlets", augments={'Mag. Evasion+15','Spell interruption rate down +15%','Enmity+7',}},
		feet="Templar Sabatons",
		neck="Divine Torque",
		waist="Asklepian Belt",
		left_ear="Beatific Earring",
		left_ring="Globidonta Ring",
	}
	
	sets.midcast['Flash'] = set_combine(sets.midcast['Divine Magic'], sets.midcast.Enmity)
	
    sets.midcast.Protect = set_combine(sets.midcast["Enhancing Magic"], {ring1="Sheltered Ring"})
    sets.midcast.Shell = set_combine(sets.midcast["Enhancing Magic"], {ring1="Sheltered Ring"})
    
    --------------------------------------
    -- Idle/resting/defense/etc sets
    --------------------------------------

    sets.Reraise = {head="Twilight Helm", body="Twilight Mail"}
	
    -- Idle sets
    sets.idle = {
		ammo="Homiliary",
		head="Valorous Mask",
		body="Chozoron Coselete",
		hands={ name="Souv. Handschuhs", augments={'HP+50','Shield skill +10','Phys. dmg. taken -3',}},
		legs="Sulevia's Cuisses +1",
		feet={ name="Amm Greaves", augments={'HP+50','VIT+10','Accuracy+15','Damage taken-2%',}},
		neck="Coatl Gorget +1",
		waist="Flume Belt +1",
		left_ear="Etiolation Earring",
		right_ear="Infused Earring",
		left_ring="Sheltered Ring",
		right_ring="Paguroidea Ring",
		back="Weard Mantle",
	}

    sets.idle.Town = set_combine(sets.idle, {})
    
    sets.idle.Weak = set_combine(sets.idle, {})
    
    sets.idle.Weak.Reraise = set_combine(sets.idle.Weak, sets.Reraise)
    
    sets.Kiting = {feet="Hippomenes Socks"}

    sets.latent_refresh = {waist="Fucho-no-obi"}

	sets.resting = set_combine(sets.idle, {})
	
	
    --------------------------------------
    -- Defense sets
    --------------------------------------
    
    -- Extra defense sets.  Apply these on top of melee or defense sets.
    sets.Knockback = {} -- back="Repulse Mantle"
    sets.MP = {neck="Coatl Gorget +1",waist="Flume Belt +1"}
    sets.MP_Knockback = {waist="Flume Belt +1"} -- back="Repulse Mantle"
    
    -- If EquipShield toggle is on (Win+F10 or Win+F11), equip the weapon/shield combos here
    -- when activating or changing defense mode:
    sets.PhysicalShield = {main="Brilliance", sub="Ochain"}
    sets.MagicalShield = {main="Almace", sub="Aegis"} 

    -- Basic defense sets.
    -- Source: https://www.bg-wiki.com/bg/Damage_Taken
	-- -50% cap on the various types of damage taken. 
	-- There is an overall cap of -87.5% damage taken, including sources that bypass the other caps.
    sets.defense.PDT = {
		ammo="Vanir Battery",
		head={ name="Founder's Corona", augments={'DEX+8','Accuracy+15','Mag. Acc.+14','Magic dmg. taken -3%',}},
		body={ name="Souveran Cuirass", augments={'HP+80','Enmity+7','Potency of "Cure" effect received +10%',}},
		hands={ name="Souv. Handschuhs", augments={'HP+50','Shield skill +10','Phys. dmg. taken -3',}},
		legs={ name="Valor. Hose", augments={'Accuracy+23','Damage taken-4%','AGI+6',}},
		feet={ name="Amm Greaves", augments={'HP+50','VIT+10','Accuracy+15','Damage taken-2%',}},
		neck="Twilight Torque",
		--waist="Flume Belt +1", -- use this when WoE campaign is over.
		waist="Goading Belt",
		left_ear="Ethereal Earring",
		right_ear="Thureous Earring",
		left_ring="Defending Ring",
		right_ring="Patricius Ring",
		back={ name="Rudianos's Mantle", augments={'"Fast Cast"+10',}},
		-- Gear totals: 
		--	DEF				627
		-- 	PDT 		   -50%
		--	MDT 		   -47%
		--	MDB			  	12%
		--	MEva			320
		--	Enmity			18%
		--	Haste 			22%
		--	Dmg to MP 		 7%
		--	Convert to MP	 3%
		--	Shield skill	10%
		--	Resist Elements	25%
		--	Block chance	 2%
		--	Cure Pot. Rec.	10%
		--	HP				617
		--	VIT				155
		--	Acc				130
	}
    sets.defense.HP = sets.defense.PDT
    sets.defense.Reraise = set_combine(sets.defense.PDT, sets.Reraise)
    sets.defense.Charm = {neck="Unmoving Collar"}
	
    -- To cap MDT with Shell IV (52/256), need 76/256 in gear.
    -- Shellra V can provide 75/256, which would need another 53/256 in gear.
	-- (I assume I will always have Shellra V)
    sets.defense.MDT = {
		ammo="Vanir Battery",
		head={ name="Founder's Corona", augments={'DEX+8','Accuracy+15','Mag. Acc.+14','Magic dmg. taken -3%',}},
		body={ name="Souveran Cuirass", augments={'HP+80','Enmity+7','Potency of "Cure" effect received +10%',}},
		hands={ name="Souv. Handschuhs", augments={'HP+50','Shield skill +10','Phys. dmg. taken -3',}},
		legs={ name="Valor. Hose", augments={'Accuracy+23','Damage taken-4%','AGI+6',}},
		feet={ name="Amm Greaves", augments={'HP+50','VIT+10','Accuracy+15','Damage taken-2%',}},
		neck="Twilight Torque",
		waist="Creed Baudrier",
		left_ear="Etiolation Earring",
		right_ear="Sanare Earring",
		left_ring="Defending Ring",
		right_ring="Shadow Ring",
		back="Engulfer Cape +1", -- use this when WoE campaign is over.
		--back={ name="Weard Mantle", augments={'VIT+3','Enmity+3','Phalanx +5',}},
	}


    --------------------------------------
    -- Engaged sets
    --------------------------------------
    -- acc = 1019, DA = 22%, Haste = 22%
    sets.engaged = {
		ammo="Vanir Battery",
		head="Valorous Mask",
		body={ name="Found. Breastplate", augments={'Accuracy+14','Mag. Acc.+13','Attack+14','"Mag.Atk.Bns."+14',}},
		hands="Sulev. Gauntlets +1",
		legs={ name="Valor. Hose", augments={'Accuracy+23','Damage taken-4%','AGI+6',}},
		feet={ name="Amm Greaves", augments={'HP+50','VIT+10','Accuracy+15','Damage taken-2%',}},
		neck="Lissome Necklace",
		waist="Kentarch Belt +1",
		left_ear="Steelflash Earring",
		right_ear="Bladeborn Earring",
		left_ring="Petrov Ring",
		right_ring="Patricius Ring",
		back="Rudianos's Mantle",
	}

	-- acc = 1049, DA = 19%
    sets.engaged.Acc = {
		ammo="Vanir Battery",
		head="Valorous Mask",
		body={ name="Found. Breastplate", augments={'Accuracy+14','Mag. Acc.+13','Attack+14','"Mag.Atk.Bns."+14',}},
		hands="Sulev. Gauntlets +1",
		legs={ name="Valor. Hose", augments={'Accuracy+23','Damage taken-4%','AGI+6',}},
		feet={ name="Odyssean Greaves", augments={'Accuracy+25 Attack+25','STR+4','Accuracy+7','Attack+2',}},
		neck="Subtlety Spec.",
		waist="Kentarch Belt +1",
		left_ear="Steelflash Earring",
		right_ear="Bladeborn Earring",
		left_ring="Petrov Ring",
		right_ring="Patricius Ring",
		back="Rudianos's Mantle",
	}
	
	sets.engaged.PDT = sets.defense.PDT
    sets.engaged.Acc.PDT = set_combine(sets.engaged.PDT, {})
	
	sets.engaged.MDT = sets.defense.MDT
    sets.engaged.Acc.MDT = set_combine(sets.engaged.MDT, {})
	
	sets.engaged.Reraise = set_combine(sets.engaged, sets.Reraise)
    sets.engaged.Acc.Reraise = set_combine(sets.engaged.Acc, sets.Reraise)
	
    sets.engaged.DW = set_combine(sets.engaged, {left_ear="Dudgeon Earring",right_ear="Heartseeker Earring",})
    sets.engaged.DW.Acc = set_combine(sets.engaged.Acc, {left_ear="Dudgeon Earring",right_ear="Heartseeker Earring",})
	
	sets.engaged.DW.PDT = set_combine(sets.engaged.PDT, {})
    sets.engaged.DW.Acc.PDT = set_combine(sets.engaged.Acc.PDT, {})
	
	sets.engaged.DW.Reraise = set_combine(sets.engaged.DW, sets.Reraise)
    sets.engaged.DW.Acc.Reraise = set_combine(sets.engaged.DW.Acc, sets.Reraise)
	

    --------------------------------------
    -- Custom buff sets
    --------------------------------------

    sets.buff.Doom = {} -- ring2="Saida Ring"
    sets.buff.Cover = {body="Caballarius Surcoat"} -- head="Reverence Coronet"
end


-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

function job_midcast(spell, action, spellMap, eventArgs)
    -- If DefenseMode is active, apply that gear over midcast
    -- choices.  Precast is allowed through for fast cast on
    -- spells, but we want to return to def gear before there's
    -- time for anything to hit us.
    -- Exclude Job Abilities from this restriction, as we probably want
    -- the enhanced effect of whatever item of gear applies to them,
    -- and only one item should be swapped out.
    if state.DefenseMode.value ~= 'None' and spell.type ~= 'JobAbility' then
        handle_equipping_gear(player.status)
        eventArgs.handled = true
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Called when the player's status changes.
function job_state_change(field, new_value, old_value)
    classes.CustomDefenseGroups:clear()
    classes.CustomDefenseGroups:append(state.ExtraDefenseMode.current)
    if state.EquipShield.value == true then
        classes.CustomDefenseGroups:append(state.DefenseMode.current .. 'Shield')
    end

    classes.CustomMeleeGroups:clear()
    classes.CustomMeleeGroups:append(state.ExtraDefenseMode.current)
end


-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Called by the 'update' self-command, for common needs.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(cmdParams, eventArgs)
    update_defense_mode()
end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if player.mpp < 51 then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    if state.Buff.Doom then
        idleSet = set_combine(idleSet, sets.buff.Doom)
    end
    
    return idleSet
end

-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if state.Buff.Doom then
        meleeSet = set_combine(meleeSet, sets.buff.Doom)
    end
    
    return meleeSet
end

function customize_defense_set(defenseSet)
    if state.ExtraDefenseMode.value ~= 'None' then
        defenseSet = set_combine(defenseSet, sets[state.ExtraDefenseMode.value])
    end
    
    if state.EquipShield.value == true then
        defenseSet = set_combine(defenseSet, sets[state.DefenseMode.current .. 'Shield'])
    end
    
    if state.Buff.Doom then
        defenseSet = set_combine(defenseSet, sets.buff.Doom)
    end
    
    return defenseSet
end


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
        msg = msg .. ', Defense: ' .. state.DefenseMode.value .. ' (' .. state[state.DefenseMode.value .. 'DefenseMode'].value .. ')'
    end

    if state.ExtraDefenseMode.value ~= 'None' then
        msg = msg .. ', Extra: ' .. state.ExtraDefenseMode.value
    end
    
    if state.EquipShield.value == true then
        msg = msg .. ', Force Equip Shield'
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

    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

function update_defense_mode()
    if player.equipment.main == 'Kheshig Blade' and not classes.CustomDefenseGroups:contains('Kheshig Blade') then
        classes.CustomDefenseGroups:append('Kheshig Blade')
    end
    
    if player.sub_job == 'NIN' or player.sub_job == 'DNC' then
        if player.equipment.sub and not player.equipment.sub:contains('Shield') and
           player.equipment.sub ~= 'Aegis' and player.equipment.sub ~= 'Ochain' and 
		   player.equipment.sub ~= 'Ajax' and player.equipment.sub ~= 'Priwen' then
			state.CombatForm:set('DW')
        else
            state.CombatForm:reset()
        end
    end
end


-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == 'DNC' then
        set_macro_page(4, 15)
    elseif player.sub_job == 'NIN' then
        set_macro_page(4, 2)
    elseif player.sub_job == 'RDM' then
        set_macro_page(3, 2)
    else
        set_macro_page(10, 15)
    end
end

function set_lockstyle(num)
	send_command('wait 2; input /lockstyleset '..num)
end