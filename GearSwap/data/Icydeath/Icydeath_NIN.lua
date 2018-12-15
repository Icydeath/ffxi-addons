-- /con gs c toggle CP
-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2

	include('organizer-lib')
    -- Load and initialize the include file.
    include('Mote-Include.lua')
end


-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
	state.AutoMode = M{['description'] = 'Auto Mode(default: Off)'}
	state.AutoMode:options('Off', 'On')
	AutoWS = "Blade: Shun"
	
    state.Buff.Migawari = buffactive.migawari or false
    state.Buff.Doom = buffactive.doom or false
    state.Buff.Yonin = buffactive.Yonin or false
    state.Buff.Innin = buffactive.Innin or false
    state.Buff.Futae = buffactive.Futae or false

    determine_haste_group()
	
	-- Event Register for AutoMode
	windower.register_event('tp change', function(tp)
        if tp > 100
				and state.AutoMode.value == 'On'
				and player.status == 'Engaged' then
            relaxed_play_mode()
        end
    end)
	
	windower.register_event('time change', function(time)
        if player.tp == 3000
                and state.AutoMode.value == 'On'
                and player.status == 'Engaged' then
            relaxed_play_mode()
        end
    end)
	
	-- Map for auto activation of Berserk/Warcry based
    -- on Weaponskills listed
    berserk_warcry_automation = S{
        'Blade: Hi',
        'Blade: Ten',
        'Blade: Jin',
        'Blade: Shun'}
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('Normal', 'Acc')
    state.HybridMode:options('Normal', 'Evasion', 'PDT')
    state.WeaponskillMode:options('Normal', 'Acc', 'Mod')
    state.CastingMode:options('Normal', 'Resistant')
    state.PhysicalDefenseMode:options('PDT', 'Evasion')
	
	state.CP = M(false, "Capacity Points Mode")
	
    gear.MovementFeet = {}
    gear.DayFeet = ""
    gear.NightFeet = ""
    
    select_movement_feet()
	
    --select_default_macro_book()
	set_lockstyle('4')
end


-- Define sets and vars used by this job file.
function init_gear_sets()
	sets.CP = {back="Mecisto. Mantle"}
	
	organizer_items = {
		echos="Echo Drops",
		ammo="Happo Shuriken",
		ammopouch="Hap. Sh. Pouch",
		shikabag="Toolbag (Shika)",
		inoshibag="Toolbag (Ino)",
		chonobag="Toolbag (Cho)",
		shika="Shikanofuda",
		inoshi="Inoshishinofunda",
		chono="Chonofuda",
		facility="Facility Ring",
		capring="Capacity Ring",
		kanaria="Kanaria",
		aizush="Aizushintogo"
	}
	
	--------------------------------------
    -- Precast sets
    --------------------------------------
	
    -- Precast sets to enhance JAs
    sets.precast.JA['Mijin Gakure'] = {} --legs="Mochizuki Hakama"
    sets.precast.JA['Futae'] = {} --legs="Iga Tekko +2"
    sets.precast.JA['Sange'] = {legs="Mochizuki Chainmail"}

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {}
        
    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz['Healing Waltz'] = {}

    -- Set for acc on steps, since Yonin drops acc a fair bit
    sets.precast.Step = {left_ear="Choreia Earring", waist="Chaac Belt"}

    sets.precast.Flourish1 = {waist="Chaac Belt"}

    -- Fast cast sets for spells
    
    sets.precast.FC = {
		ammo="Impatiens",
		body="Dread Jupon",
		hands={ name="Leyline Gloves", augments={'Accuracy+15','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+3',}},
		left_ear="Loquac. Earring",
		right_ear="Etiolation Earring",
		left_ring="Prolix Ring",
	}
    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {
		neck="Magoraga Beads",
		body="Passion Jacket",
		back="Andartia's Mantle"
	})

    -- Snapshot for ranged
    sets.precast.RA = {}
       
    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
		ammo="Ginsen",
		head={ name="Adhemar Bonnet", augments={'DEX+10','AGI+10','Accuracy+15',}},
		body={ name="Herculean Vest", augments={'Accuracy+3 Attack+3','Crit. hit damage +4%','DEX+9','Accuracy+7','Attack+1',}},
		hands={ name="Herculean Gloves", augments={'Accuracy+21 Attack+21','"Triple Atk."+3','STR+9','Accuracy+15','Attack+9',}},
		legs={ name="Samnuha Tights", augments={'STR+8','DEX+9','"Dbl.Atk."+3','"Triple Atk."+2',}},
		feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','Attack+7',}},
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Cessance Earring",
		right_ear="Brutal Earring",
		left_ring="Petrov Ring",
		right_ring="Epona's Ring",
		back={ name="Andartia's Mantle", augments={'AGI+20','Accuracy+20 Attack+20','Accuracy+10','Weapon skill damage +10%',}},
	}
    sets.precast.WS.Acc = set_combine(sets.precast.WS, {})

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS['Blade: Jin'] = set_combine(sets.precast.WS, {})

    sets.precast.WS['Blade: Hi'] = set_combine(sets.precast.WS, {
		ammo="Ginsen",
		head={ name="Adhemar Bonnet", augments={'DEX+10','AGI+10','Accuracy+15',}},
		body={ name="Herculean Vest", augments={'Accuracy+3 Attack+3','Crit. hit damage +4%','DEX+9','Accuracy+7','Attack+1',}},
		hands={ name="Herculean Gloves", augments={'Accuracy+23 Attack+23','Crit. hit damage +3%','STR+8','Attack+15',}},
		legs={ name="Herculean Trousers", augments={'Accuracy+15','Crit. hit damage +3%','DEX+6','Attack+3',}},
		feet={ name="Herculean Boots", augments={'Crit. hit damage +4%','STR+12','Accuracy+11','Attack+11',}},
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Ishvara Earring",
		right_ear={ name="Moonshade Earring", augments={'"Mag.Atk.Bns."+4','TP Bonus +25',}},
		left_ring="Begrudging Ring",
		right_ring="Hetairoi Ring",
		back={ name="Andartia's Mantle", augments={'AGI+20','Accuracy+20 Attack+20','Accuracy+10','Weapon skill damage +10%',}},
	})
	
    sets.precast.WS['Blade: Ten'] = set_combine(sets.precast.WS['Blade: Hi'], {})
	
    sets.precast.WS['Blade: Shun'] = set_combine(sets.precast.WS, {})

	sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS, {})

    
    --------------------------------------
    -- Midcast sets
    --------------------------------------

    sets.midcast.FastRecast = {}
        
    sets.midcast.Utsusemi = {
		back="Andartia's Mantle",
		--feet="Iga Kyahan +2"
	}

    sets.midcast.ElementalNinjutsu = {}

    sets.midcast.ElementalNinjutsu.Resistant = set_combine(sets.midcast.Ninjutsu, {})

    sets.midcast.NinjutsuDebuff = {}

    sets.midcast.NinjutsuBuff = {head="Hachiya Hatsuburi",neck="Ninjutsu Torque"}

    sets.midcast.RA = {}
    -- Hachiya Hakama/Thurandaut Tights +1

    --------------------------------------
    -- Idle/resting/defense/etc sets
    --------------------------------------
    
    -- Resting sets
    sets.resting = {}
    
    -- Idle sets
    sets.idle = {
		ammo="Vanir Battery",
		head={ name="Dampening Tam", augments={'DEX+9','Accuracy+13','Mag. Acc.+14','Quadruple Attack +2',}},
		body="Mekosu. Harness",
		hands="Kurys Gloves",
		legs={ name="Herculean Trousers", augments={'Accuracy+15','Crit. hit damage +3%','DEX+6','Attack+3',}},
		feet={ name="Amm Greaves", augments={'HP+50','VIT+10','Accuracy+15','Damage taken-2%',}},
		neck="Sanctity Necklace",
		waist="Flume Belt +1",
		left_ear="Infused Earring",
		right_ear="Etiolation Earring",
		left_ring="Sheltered Ring",
		right_ring="Paguroidea Ring",
		back="Xucau Mantle",
	}

    --sets.idle.Town = {main="Raimitsukane",sub="Kaitsuburi",ammo="Qirmiz Tathlum",
    --    head="Whirlpool Mask",neck="Wiglen Gorget",ear1="Dudgeon Earring",ear2="Heartseeker Earring",
    --    body="Hachiya Chainmail +1",hands="Otronif Gloves +1",ring1="Sheltered Ring",ring2="Paguroidea Ring",
    --    back="Atheling Mantle",waist="Patentia Sash",legs="Hachiya Hakama",feet=gear.MovementFeet}
    
    --sets.idle.Weak = {
    --    head="Whirlpool Mask",neck="Wiglen Gorget",ear1="Dudgeon Earring",ear2="Heartseeker Earring",
    --    body="Hachiya Chainmail +1",hands="Otronif Gloves",ring1="Sheltered Ring",ring2="Paguroidea Ring",
    --    back="Shadow Mantle",waist="Flume Belt",legs="Hachiya Hakama",feet=gear.MovementFeet}
    
    -- Defense sets
    sets.defense.Evasion = {}

    sets.defense.PDT = {}

    sets.defense.MDT = {}


    sets.Kiting = {feet=gear.MovementFeet}


    --------------------------------------
    -- Engaged sets
    --------------------------------------

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion
    
    -- Normal melee group
    sets.engaged = {
		ammo="Happo Shuriken",
		--main={ name="Kanaria", augments={'Phys. dmg. taken -1%','STR+1','Accuracy+17','Attack+2','DMG:+20',}},
		--sub={ name="Kanaria", augments={'"Triple Atk."+2','DEX+4','Accuracy+23','Attack+19','DMG:+14',}},
		head={ name="Dampening Tam", augments={'DEX+9','Accuracy+13','Mag. Acc.+14','Quadruple Attack +2',}},
		body={ name="Adhemar Jacket", augments={'DEX+10','AGI+10','Accuracy+15',}},
		hands={ name="Herculean Gloves", augments={'Accuracy+21 Attack+21','"Triple Atk."+3','STR+9','Accuracy+15','Attack+9',}},
		legs={ name="Samnuha Tights", augments={'STR+8','DEX+9','"Dbl.Atk."+3','"Triple Atk."+2',}},
		feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','Attack+7',}},
		neck="Clotharius Torque",
		waist="Windbuffet Belt +1",
		left_ear="Cessance Earring",
		right_ear="Brutal Earring",
		left_ring="Petrov Ring",
		right_ring="Epona's Ring",
		back="Yokaze Mantle",
	}
	
    sets.engaged.Acc = set_combine(sets.engaged, {})
    sets.engaged.Evasion = set_combine(sets.engaged, {})
    sets.engaged.Acc.Evasion = set_combine(sets.engaged, {})
    sets.engaged.PDT = set_combine(sets.engaged, {})
    sets.engaged.Acc.PDT = set_combine(sets.engaged, {})

    -- Custom melee group: High Haste (~20% DW)
    sets.engaged.HighHaste = set_combine(sets.engaged, {})
    sets.engaged.Acc.HighHaste = set_combine(sets.engaged.HighHaste, {})
    sets.engaged.Evasion.HighHaste = set_combine(sets.engaged.HighHaste, {})
    sets.engaged.Acc.Evasion.HighHaste = set_combine(sets.engaged.HighHaste, {})
    sets.engaged.PDT.HighHaste = set_combine(sets.engaged.HighHaste, {})
    sets.engaged.Acc.PDT.HighHaste = set_combine(sets.engaged.HighHaste, {})

    -- Custom melee group: Embrava Haste (7% DW)
    sets.engaged.EmbravaHaste = set_combine(sets.engaged, {})
    sets.engaged.Acc.EmbravaHaste = set_combine(sets.engaged.EmbravaHaste, {})
    sets.engaged.Evasion.EmbravaHaste = set_combine(sets.engaged.EmbravaHaste, {})
    sets.engaged.Acc.Evasion.EmbravaHaste = set_combine(sets.engaged.EmbravaHaste, {})
    sets.engaged.PDT.EmbravaHaste = set_combine(sets.engaged.EmbravaHaste, {})
    sets.engaged.Acc.PDT.EmbravaHaste = set_combine(sets.engaged.EmbravaHaste, {})

    -- Custom melee group: Max Haste (0% DW)
    sets.engaged.MaxHaste = set_combine(sets.engaged, {})
    sets.engaged.Acc.MaxHaste = set_combine(sets.engaged.MaxHaste, {})
    sets.engaged.Evasion.MaxHaste = set_combine(sets.engaged.MaxHaste, {})
    sets.engaged.Acc.Evasion.MaxHaste = set_combine(sets.engaged.MaxHaste, {})
    sets.engaged.PDT.MaxHaste = set_combine(sets.engaged.MaxHaste, {})
    sets.engaged.Acc.PDT.MaxHaste = set_combine(sets.engaged.MaxHaste, {})


    --------------------------------------
    -- Custom buff sets
    --------------------------------------

    sets.buff.Migawari = {body="Iga Ningi +2"}
    sets.buff.Doom = {}
    sets.buff.Yonin = {}
    sets.buff.Innin = {}
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Run after the general midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if state.Buff.Doom then
        equip(sets.buff.Doom)
    end
end


-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if not spell.interrupted and spell.english == "Migawari: Ichi" then
        state.Buff.Migawari = true
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------
function job_precast(spell, action, spellMap, eventArgs)
	-- Automates Aggressor/Berserk/Warcry for Warrior sub job
    if state.AutoMode.value == 'On'
			and berserk_warcry_automation:contains(spell.name)
            and player.status == 'Engaged'
            and player.sub_job == 'WAR'
            and check_recasts(j('Aggressor'))
            and not check_buffs(
                'Amnesia',
                'Berserk',
                'Obliviscence',
                'Paralysis') then
        windower.send_command('aggressor; wait 1; berserk; wait 1; warcry; wait 1;'..spell.name..' '..spell.target.raw)
        cancel_spell()
        return
    end
end

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
    -- If we gain or lose any haste buffs, adjust which gear set we target.
    if S{'haste','march','embrava','haste samba'}:contains(buff:lower()) then
        determine_haste_group()
        handle_equipping_gear(player.status)
    elseif state.Buff[buff] ~= nil then
        handle_equipping_gear(player.status)
    end
end

function job_status_change(new_status, old_status)
    if new_status == 'Idle' then
        select_movement_feet()
    end
end


-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Get custom spell maps
function job_get_spell_map(spell, default_spell_map)
    if spell.skill == "Ninjutsu" then
        if not default_spell_map then
            if spell.target.type == 'SELF' then
                return 'NinjutsuBuff'
            else
                return 'NinjutsuDebuff'
            end
        end
    end
end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if state.Buff.Migawari then
        idleSet = set_combine(idleSet, sets.buff.Migawari)
    end
    if state.Buff.Doom then
        idleSet = set_combine(idleSet, sets.buff.Doom)
    end
	
	if state.CP.current == 'on' then
		equip(sets.CP)
		disable('back')
	else
		enable('back')
	end
	
    return idleSet
end


-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if state.Buff.Migawari then
        meleeSet = set_combine(meleeSet, sets.buff.Migawari)
    end
    if state.Buff.Doom then
        meleeSet = set_combine(meleeSet, sets.buff.Doom)
    end
    return meleeSet
end

-- Called by the default 'update' self-command.
function job_update(cmdParams, eventArgs)
    select_movement_feet()
    determine_haste_group()
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------
function check_buffs(...)
    --[[ Function Author: Arcon
            Simple check before attempting to auto activate Job Abilities that
            check active buffs and debuffs ]]
    return table.any({...}, table.get+{buffactive})
end

function check_set_spells(...)
    --[[ Function Author: Arcon
            Used to pull list of currently set spells, this is useful for
            determining traits such as Dual Wield IV
            Also used to determine the Cure spell set, when used with a
            self_command ]]
    set_spells = set_spells
        or gearswap.res.spells:type('BlueMagic'):rekey('name')
        return table.all({...}, function(name)
        return S(windower.ffxi.get_mjob_data().spells)
        :contains(set_spells[name].id)
    end)
end

do
    --[[ Author: Arcon
            The three next "do" sections are used to aid in checking recast
            times, can check multiple recast times at once ]]
    local cache = {}

    function j(str)
        if not cache[str] then
            cache[str] = gearswap.res.job_abilities:with('name', str)
        end

        return cache[str]
    end
end

do
    local cache = {}

    function s(str)
        if not cache[str] then
            cache[str] = gearswap.res.spells:with('name', str)
        end

        return cache[str]
    end
end

do
    local ja_types = S(gearswap.res.job_abilities:map(table.get-{'type'}))

    function check_recasts(...)
        local spells = S{...}

        for spell in spells:it() do
            local fn = 'get_' .. (ja_types:contains(spell.type)
                    and 'ability'
                    or 'spell') ..'_recasts'
            if windower.ffxi[fn]()[spell.recast_id] > 0 then
                return false
            end
        end

        return true
    end
end


-- MAKE A MACRO: /con gs c cycle AutoMode
-- DEFAULT: Off
function relaxed_play_mode()
    -- This can be used as a mini bot to automate actions
    if not midaction() then
		if not check_buffs('Innin')
				and check_recasts(j('Innin')) then
			windower.send_command('Innin')
        elseif player.tp > 999
                and player.target.hpp > 0
                and player.target.distance < 6 
				and not check_buffs('amnesia') then
            windower.send_command(AutoWS)
        end
    end
end


function determine_haste_group()
    -- We have three groups of DW in gear: Hachiya body/legs, Iga head + Patentia Sash, and DW earrings
    
    -- Standard gear set reaches near capped delay with just Haste (77%-78%, depending on HQs)

    -- For high haste, we want to be able to drop one of the 10% groups.
    -- Basic gear hits capped delay (roughly) with:
    -- 1 March + Haste
    -- 2 March
    -- Haste + Haste Samba
    -- 1 March + Haste Samba
    -- Embrava
    
    -- High haste buffs:
    -- 2x Marches + Haste Samba == 19% DW in gear
    -- 1x March + Haste + Haste Samba == 22% DW in gear
    -- Embrava + Haste or 1x March == 7% DW in gear
    
    -- For max haste (capped magic haste + 25% gear haste), we can drop all DW gear.
    -- Max haste buffs:
    -- Embrava + Haste+March or 2x March
    -- 2x Marches + Haste
    
    -- So we want four tiers:
    -- Normal DW
    -- 20% DW -- High Haste
    -- 7% DW (earrings) - Embrava Haste (specialized situation with embrava and haste, but no marches)
    -- 0 DW - Max Haste
    
    classes.CustomMeleeGroups:clear()
    
    if buffactive.embrava and (buffactive.march == 2 or (buffactive.march and buffactive.haste)) then
        classes.CustomMeleeGroups:append('MaxHaste')
    elseif buffactive.march == 2 and buffactive.haste then
        classes.CustomMeleeGroups:append('MaxHaste')
    elseif buffactive.embrava and (buffactive.haste or buffactive.march) then
        classes.CustomMeleeGroups:append('EmbravaHaste')
    elseif buffactive.march == 1 and buffactive.haste and buffactive['haste samba'] then
        classes.CustomMeleeGroups:append('HighHaste')
    elseif buffactive.march == 2 then
        classes.CustomMeleeGroups:append('HighHaste')
    end
end


function select_movement_feet()
    if world.time >= 17*60 or world.time < 7*60 then
        gear.MovementFeet.name = gear.NightFeet
    else
        gear.MovementFeet.name = gear.DayFeet
    end
end


-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == 'DNC' then
        set_macro_page(4, 3)
    elseif player.sub_job == 'THF' then
        set_macro_page(5, 3)
    else
        set_macro_page(1, 3)
    end
end

function set_lockstyle(num)
	send_command('wait 2; input /lockstyleset '..num)
end