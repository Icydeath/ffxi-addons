--[[
 Macro: /con gs c cycle CapacityMode


AutoMode Info
-------------
 Macro: /con gs c cycle AutoMode
	-> uses Hasso (if subbed sam)
	-> uses berserk, warcry, aggressor before weaponskills.
	
	
 NOTE: Below macros only matter if you have AutoMode = 'On'
 ------------------------------------------------------------
 
 Macro: /con gs c cycle AutoWS
	-> Automatically weaponskills if set to 'On'
 
 Macro: /con gs c cycle SelectedWS
	-> Uses the weaponskill selected
	-> Note: If Ragnarok is equipped and aftermath lvl 3 is not active
			  it will wait for 3000tp and then use Scourge to gain the aftermath
				
 Macro: /con gs c cycle WSWhenHPGreaterThan
	-> will only weaponskill if the mobs HP is greater than [% selected] (default = 0)
 
 Macro: /con gs c cycle AutoRetaliation
	-> uses Retaliation when set to 'On'
	

 NOTE: You can change the default of each setting in the job_setup() section.
	
]]-- 

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2
    -- Load and initialize the include file.
    include('Mote-Include.lua')
    include('organizer-lib')
end
 
 
-- Setup vars that are user-independent.
function job_setup()

	-- Set the Great Axe weapons you use.
	gaList = S{'Ukonvasara'}
	-- Set the GreatSword weapons you use.
	gsList = S{'Ragnarok', 'Macbain', 'Kaquljaan'}
	-- Set the off hand weapons you use.
    war_sub_weapons = S{'Sangarius', 'Usonmunku'}
	
	
	
	-- The first option that's listed is the default option, change the order around to your liking.
	state.AutoMode = M{['description'] = 'AutoMode'}
	state.AutoMode:options('Off', 'On')
	
	-- The first option that's listed is the default option, change the order around to your liking.
	state.AutoRetaliation = M{['description'] = 'AutoRetaliation'}
	state.AutoRetaliation:options('Off', 'On')
	
	-- The first option that's listed is the default option, change the order around to your liking.
	state.AutoWS = M{['description'] = 'AutoWS'}
	state.AutoWS:options('On', 'Off')
	
	-- The first option that's listed is the default option, change the order around to your liking.
	state.SelectedWS = M{['description'] = 'SelectedWS'}
	state.SelectedWS:options('Ukko\'s Fury', 'Resolution', 'King\'s Justice', 'Torcleaver', 'Upheaval')
	
	-- The first option that's listed is the default option, change the order around to your liking.
	state.WSWhenHPGreaterThan = M{['description'] = 'WS when HP is Greater Than %'}
	state.WSWhenHPGreaterThan:options(0, 20, 40)
	
	
	
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
	
	
	
	-- Map for auto activation of Berserk/Warcry/Aggressor based
    -- on Weaponskills listed
    berserk_warcry_automation = S{
        'Ukko\'s Fury',
        'Resolution',
        'King\'s Justice',
        'Torcleaver',
		'Upheaval'}
	
	
	
	state.CapacityMode = M(false, 'Capacity Point Mantle')
	
	
    state.Buff.Berserk = buffactive.berserk or false
    state.Buff.Retaliation = buffactive.retaliation or false

	
    get_combat_form()
    get_combat_weapon()
end
 
 
-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    -- Options: Override default values
    state.OffenseMode:options('Normal', 'Mid', 'Acc')
    state.HybridMode:options('Normal', 'PDT')
    state.WeaponskillMode:options('Normal', 'Mid', 'Acc')
    state.CastingMode:options('Normal')
    state.IdleMode:options('Normal')
    state.RestingMode:options('Normal')
    state.PhysicalDefenseMode:options('PDT', 'Reraise')
    state.MagicalDefenseMode:options('MDT')
    
    -- Additional local binds
    send_command('bind != gs c toggle CapacityMode')
    send_command('bind ^` input /ja "Hasso" <me>')
    send_command('bind !` input /ja "Seigan" <me>')
    
    select_default_macro_book()
end
 
-- Called when this job file is unloaded (eg: job change)
function file_unload()
    send_command('unbind ^`')
    send_command('unbind !=')
    send_command('unbind ^[')
    send_command('unbind ![')
    send_command('unbind @f9')
end
 
       
-- Define sets and vars used by this job file.
function init_gear_sets()

	sets.Organizer = {
	 
	}
	
	sets.CapacityMantle  = { back="Mecistopins Mantle" }
	sets.WSDayBonus      = { head="Gavialis Helm" }
	
	-- TP ears for night and day, AM3 up and down. 
	sets.BrutalLugra     = { ear1="Brutal Earring" } -- ear2="Lugra Earring +1" 
	sets.Lugra           = {  } -- ear1="Lugra Earring +1"
	sets.Brutal          = { ear1="Brutal Earring" }
	-- Lugra Earring is obtained From: https://www.bg-wiki.com/bg/Tiyanak
	
	sets.reive = {neck="Ygnas's Resolve +1"}
	
	---------------------------------------
	-- PRECASTS TO ENHANCE JOB ABILITIES --
	---------------------------------------
	
	-- On activation relic 119 hands adds an additional 15 sec
	sets.precast.JA['Mighty Strikes'] = { hands="Agoge Mufflers +1" }
	
	-- On activation relic 119 head adds an additional 30 sec
	sets.precast.JA.Warcry = { head="Agoge Mask +1" }
	
	-- On activation af 119 body adds an additional 14 sec
	--  Also, relic 119 feet adds an additional 20 sec
	--  Also, Cichol's mantle adds an additional 15 sec
	sets.precast.JA.Berserk = { body="Pummeler's Lorica +1", feet="Agoge Calligae +1", back="Cichol's Mantle" }
	
	-- On activation af 119 head adds an additional 14 sec
	--  Also, relic 119 body reducing the evasion penalty and extending duration by 20 seconds
	sets.precast.JA.Aggressor = {head="Pummeler's Mask +1", body="Agoge Lorica +1" }
	
	-- On activation relic 119 legs adds 1% critical hit rate per merit
	--  NOTE: Warrior's Charge does not work with Weaponskills, Jump and other similar abilities.
	sets.precast.JA['Warrior\'s Charge'] = { legs="Agoge Cuisses +1" }
	
	-- On activation empyrean 119 body adds an additional 34 sec
	sets.precast.JA['Blood Rage'] = { body="Boii Lorica +1" }
	
	-- Relic 119 feet increases the special defense reduction of Tomahawk by 1% merit level
	sets.precast.JA.Tomahawk = { ammo="Throwing Tomahawk", feet="Agoge Calligae +1" }
	

	-- Waltz set (chr and vit)
	sets.precast.Waltz = {}
		
	-- Fast cast sets for spells
	sets.precast.FC = {
		ammo="Impatiens",
		ear1="Loquacious Earring",
	}
	
	sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, { neck="Magoraga Beads" })

	---------------------------------------
	-- 			 MIDCAST SETS 			 --
	---------------------------------------
	
	sets.midcast.FastRecast = {
		ammo="Impatiens",
	}
		
	-- Specific spells
	sets.midcast.Utsusemi = {}

	-- Ranged for xbow
	sets.precast.RA = {}
	sets.midcast.RA = {}

	
	
	---------------------------------------
	-- 			WEAPONSKILL SETS		 --
	---------------------------------------
	
	-- General sets
	sets.precast.WS = {
		ammo="Ginsen",
		head="Flamma Zucchetto +1",
		body="Sulevia's Plate. +1",
		hands="Flamma Manopolas +1",
		legs={ name="Argosy Breeches", augments={'STR+10','DEX+10','Attack+15',}},
		feet="Flamma Gambieras +1",
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Brutal Earring",
		right_ear="Cessance Earring",
		left_ring="Petrov Ring",
		right_ring="Apate Ring",
		back={ name="Cichol's Mantle", augments={'STR+20','Accuracy+20 Attack+20','"Dbl.Atk."+10',}},
	}
	sets.precast.WS.Mid = set_combine(sets.precast.WS, {
	
	})
	sets.precast.WS.Acc = set_combine(sets.precast.WS.Mid, {
	
	})
    
	
	-- UPHEAVAL
	-- 73~85% VIT
    sets.precast.WS['Upheaval'] = set_combine(sets.precast.WS, {
        
    })
	sets.precast.WS["Upheaval"].Mid = set_combine(sets.precast.WS["Upheaval"], {
	 
	})
	sets.precast.WS["Upheaval"].Acc = set_combine(sets.precast.WS["Upheaval"].Mid, sets.precast.WS.Acc)
	
	
	-- UKKO'S FURY
	-- 80% STR
    sets.precast.WS["Ukko's Fury"] = set_combine(sets.precast.WS, {
        
    })
	sets.precast.WS["Ukko's Fury"].Mid = set_combine(sets.precast.WS["Ukko's Fury"], {
	 
	})
	sets.precast.WS["Ukko's Fury"].Acc = set_combine(sets.precast.WS["Ukko's Fury"].Mid, sets.precast.WS.Acc)
	
	
	-- RESOLUTION
	-- 86-100% STR
	sets.precast.WS.Resolution = set_combine(sets.precast.WS, {
	 
	})
	sets.precast.WS.Resolution.Mid = set_combine(sets.precast.WS.Resolution, {
	 
	})
	sets.precast.WS.Resolution.Acc = set_combine(sets.precast.WS.Resolution.Mid, sets.precast.WS.Acc) 

	
	-- TORCLEAVER 
	-- VIT 80%
	sets.precast.WS.Torcleaver = set_combine(sets.precast.WS, {

	})
	sets.precast.WS.Torcleaver.Mid = set_combine(sets.precast.WS.Mid, {
	 
	})
	sets.precast.WS.Torcleaver.Acc = set_combine(sets.precast.WS.Torcleaver.Mid, sets.precast.WS.Acc)

	
	-- SANGUINE BLADE
	-- 50% MND / 50% STR Darkness Elemental
	sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS, {

	})
	sets.precast.WS['Sanguine Blade'].Mid = set_combine(sets.precast.WS['Sanguine Blade'], sets.precast.WS.Mid)
	sets.precast.WS['Sanguine Blade'].Acc = set_combine(sets.precast.WS['Sanguine Blade'], sets.precast.WS.Acc)


	-- REQUISCAT
	-- 73% MND - breath damage
	sets.precast.WS.Requiescat = set_combine(sets.precast.WS, {
	 
	})
	sets.precast.WS.Requiescat.Mid = set_combine(sets.precast.WS.Requiscat, sets.precast.WS.Mid)
	sets.precast.WS.Requiescat.Acc = set_combine(sets.precast.WS.Requiscat, sets.precast.WS.Acc)

	
	
	---------------------------------------
	--   IDLE / RESTING / DEFENSE SETS   --
	---------------------------------------

	sets.resting = {}

	sets.idle.Town = {
		ammo="Ginsen",
		head="Sulevia's Mask +1",
		body="Sulevia's Plate. +1",
		hands="Sulev. Gauntlets +1",
		legs="Sulevi. Cuisses +1",
		feet="Hermes' Sandals",
		neck="Twilight Torque",
		waist="Kentarch Belt +1",
		left_ear="Brutal Earring",
		right_ear="Infused Earring",
		left_ring="Petrov Ring",
		right_ring="Apate Ring",
		back={ name="Cichol's Mantle", augments={'STR+20','Accuracy+20 Attack+20','"Dbl.Atk."+10',}},
	}
	sets.idle.Field = set_combine(sets.idle.Town, {})
	sets.idle.Regen = set_combine(sets.idle.Field, {})
	sets.idle.Weak = {}

	
	-- Defense sets
	sets.defense.PDT = {}
	sets.defense.Reraise = set_combine(sets.idle.Weak, {})
	sets.defense.MDT = set_combine(sets.defense.PDT, {})

	sets.Kiting = {feet="Hermes' Sandals"}

	sets.Reraise = {head="Twilight Helm", body="Twilight Mail"}

	-- Defensive sets to combine with various weapon-specific sets below
	-- These allow hybrid acc/pdt sets for difficult content
	sets.Defensive = {}
	sets.Defensive_Mid = {}
	sets.Defensive_Acc = {}

	
	
	---------------------------------------
	-- 			 ENGAGED SETS		 	 --
	---------------------------------------
	
	-- ENGAGED SET > BASE : 
	sets.engaged = {
		ammo="Ginsen",
		head="Flamma Zucchetto +1",
		body="Sulevia's Plate. +1",
		hands="Flamma Manopolas +1",
		legs="Sulevi. Cuisses +1",
		feet="Flam. Gambieras +1",
		neck="Clotharius Torque",
		waist="Ioskeha Belt",
		left_ear="Brutal Earring",
		right_ear="Cessance Earring",
		left_ring="Petrov Ring",
		right_ring="Apate Ring",
		back={ name="Cichol's Mantle", augments={'STR+20','Accuracy+20 Attack+20','"Dbl.Atk."+10',}},
	}
	sets.engaged.Mid = set_combine(sets.engaged, {
	 
	})
	sets.engaged.Acc = set_combine(sets.engaged.Mid, {
	 
	})

	-- ENGAGED > DEFENSIVE SETS
	sets.engaged.PDT = set_combine(sets.engaged, sets.Defensive)
	sets.engaged.Mid.PDT = set_combine(sets.engaged.Mid, sets.Defensive_Mid)
	sets.engaged.Acc.PDT = set_combine(sets.engaged.Acc, sets.Defensive_Acc)
	
	
	-- ENGAGED > DUALWIELDING
	sets.engaged.DW = set_combine(sets.engaged, {

	})

	-- ENGAGED > ONE HANDED (Sword and Board)
	sets.engaged.OneHand = set_combine(sets.engaged, {

	})

	
	-- ENGAGED > GREAT AXE
	sets.engaged.GreatAxe = set_combine(sets.engaged, {
	 
	})
	sets.engaged.GreatAxe.Mid = set_combine(sets.engaged.GreatAxe, {
	
	})
	sets.engaged.GreatAxe.Acc = set_combine(sets.engaged.GreatAxe.Mid, {

	})
	
	
	-- ENGAGED > GREAT SWORD
	sets.engaged.GreatSword = set_combine(sets.engaged, {
	 
	})
	sets.engaged.GreatSword.Mid = set_combine(sets.engaged.GreatSword, {
		--back="Grounded Mantle +1"
		--ring2="K'ayres Ring"
	})
	sets.engaged.GreatSword.Acc = set_combine(sets.engaged.GreatSword.Mid, {

	})
	
	
	-- ENGAGED > RERAISE
	sets.engaged.Reraise = set_combine(sets.engaged, {
		head="Twilight Helm",
		neck="Twilight Torque",
		body="Twilight Mail"
	})

	-- Gear you want equipped when berserk is active.
	--sets.buff.Berserk = { 
		--feet="Warrior's Calligae +2" 
	--}

	-- Gear you want to be equipped when retaliation is active.
	-- af 119 hands give 15% dmg increase.
	-- empy 119 feet give 25% dmg increase.
	sets.buff.Retaliation = {
		hands="Pummeler's mufflers +1",
		feet="Boii calligae +1" 
	}
    
end

function job_pretarget(spell, action, spellMap, eventArgs)
    if spell.type:endswith('Magic') and buffactive.silence then
        eventArgs.cancel = true
        send_command('input /item "Echo Drops" <me>')
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
	

	-- Automates Aggressor/Berserk/Warcry for Warrior sub job
    if state.AutoMode.value == 'On'
			and berserk_warcry_automation:contains(spell.name)
            and player.status == 'Engaged'
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
 
function job_post_precast(spell, action, spellMap, eventArgs)

    -- Make sure abilities using head gear don't swap 
	if spell.type:lower() == 'weaponskill' then
        -- handle Gavialis Helm
        
        -- CP mantle must be worn when a mob dies, so make sure it's equipped for WS.
        if state.CapacityMode.value then
            equip(sets.CapacityMantle)
        end
        
        if player.tp > 2999 then
            equip(sets.BrutalLugra)
        else -- use Lugra + moonshade
            if world.time >= (17*60) or world.time <= (7*60) then
                equip(sets.Lugra)
            else
                equip(sets.Brutal)
            end
        end
        -- Use SOA neck piece for WS in rieves
        if buffactive['Reive Mark'] then
            equip(sets.reive)
        end
    end
end
 
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_midcast(spell, action, spellMap, eventArgs)

end
 
-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if (state.HybridMode.current == 'PDT' and state.PhysicalDefenseMode.current == 'Reraise') then
        equip(sets.Reraise)
    end
    --if state.Buff.Berserk and not state.Buff.Retaliation then
	if state.Buff.Retaliation then
        equip(sets.buff.Retaliation)
    end
end
 
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if state.Buff[spell.english] ~= nil then
        state.Buff[spell.english] = not spell.interrupted or buffactive[spell.english]
    end
end

function job_post_aftercast(spell, action, spellMap, eventArgs)
end
-------------------------------------------------------------------------------------------------------------------
-- Customization hooks for idle and melee sets, after they've been automatically constructed.
-------------------------------------------------------------------------------------------------------------------
-- Called before the Include starts constructing melee/idle/resting sets.
-- Can customize state or custom melee class values at this point.
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_handle_equipping_gear(status, eventArgs)

end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if player.hpp < 90 then
        idleSet = set_combine(idleSet, sets.idle.Regen)
    end
	
    if state.HybridMode.current == 'PDT' then
        idleSet = set_combine(idleSet, sets.defense.PDT)
    end
	
    return idleSet
end
 
-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    --if state.Buff.Berserk and not state.Buff.Retaliation then
	if state.Buff.Retaliation then
    	meleeSet = set_combine(meleeSet, sets.buff.Retaliation)
    end
	
    if state.CapacityMode.value then
        meleeSet = set_combine(meleeSet, sets.CapacityMantle)
    end
	
    return meleeSet
end
 
-------------------------------------------------------------------------------------------------------------------
-- General hooks for other events.
-------------------------------------------------------------------------------------------------------------------
 
-- Called when the player's status changes.
function job_status_change(newStatus, oldStatus, eventArgs)
    if newStatus == "Engaged" then
        --if buffactive.Berserk and not state.Buff.Retaliation then
		if state.Buff.Retaliation then
            equip(sets.buff.Retaliation)
        end
        
		get_combat_weapon()
    end
end
 
-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
    
    if state.Buff[buff] ~= nil then
        handle_equipping_gear(player.status)
    end
    
    -- Warp ring rule, for any buff being lost
    if S{'Warp', 'Vocation', 'Capacity'}:contains(player.equipment.ring2) then
        if not buffactive['Dedication'] then
            disable('ring2')
        end
    else
        enable('ring2')
    end
    
    --if buff == "Berserk" then
        --if gain and not buffactive['Retaliation'] then
            --equip(sets.buff.Berserk)
        --else
            --if not midaction() then
                --handle_equipping_gear(player.status)
            --end
        --end
    --end
	
	if buff == "Retaliation" then
        if gain and buffactive['Retaliation'] then
            equip(sets.buff.Retaliation)
        else
            if not midaction() then
                handle_equipping_gear(player.status)
            end
        end
    end
end
 
 
-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------
 
-- Called by the 'update' self-command, for common needs.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(cmdParams, eventArgs)
    get_combat_form()
    get_combat_weapon()
end

function get_custom_wsmode(spell, spellMap, default_wsmode)
end
-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------
function get_combat_form()
    if S{'NIN', 'DNC'}:contains(player.sub_job) and war_sub_weapons:contains(player.equipment.sub) then
        state.CombatForm:set("DW")
    elseif S{'SAM', 'WAR'}:contains(player.sub_job) and player.equipment.sub == 'Rinda Shield' then
        state.CombatForm:set("OneHand")
    else
        state.CombatForm:reset()
    end

end

function get_combat_weapon()
    if gsList:contains(player.equipment.main) then
        state.CombatWeapon:set("GreatSword")
	elseif gaList:contains(player.equipment.main) then
		state.CombatWeapon:set("GreatAxe")
    else -- use regular set
        state.CombatWeapon:reset()
    end
end

-- Handle notifications of general user state change.
function job_state_change(stateField, newValue, oldValue)

end

function check_buffs(...)
    --[[ Function Author: Arcon
            Simple check before attempting to auto activate Job Abilities that
            check active buffs and debuffs ]]
    return table.any({...}, table.get+{buffactive})
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


function relaxed_play_mode()
    -- This can be used as a mini bot to automate actions
    if not midaction() and player.status == 'Engaged' then
        if player.sub_job == 'SAM' 
				and not check_buffs('Hasso')
				and not check_buffs('Seigan')
                and not check_buffs('amnesia')
                and check_recasts(s('Hasso')) then
            windower.send_command('Hasso')
		
		elseif state.AutoRetaliation.value == 'On'
				and not check_buffs('Retaliation')
				and not check_buffs('amnesia')
				and check_recasts(s('Retaliation')) then
			windower.send_command('Retaliation')
		
		elseif player.equipment.main == 'Ragnarok'
                and not check_buffs('Aftermath: Lv.3')
                and player.tp < 3000 then
            return

        elseif player.equipment.main == 'Ragnarok'
                and not check_buffs('Aftermath: Lv.3')
                and player.target.hpp > state.WSWhenHPGreaterThan.value
				and player.target.distance < 6 
                and player.tp == 3000 then
            windower.send_command('Scourge')
			
		elseif player.tp > 999
				and state.AutoWS.value == 'On'
                and player.target.hpp > state.WSWhenHPGreaterThan.value
                and player.target.distance < 6 
				and not check_buffs('amnesia') then
            windower.send_command(state.SelectedWS.value)
        end
		
    end
	
end

function select_default_macro_book()
    -- Default macro set/book
	if player.sub_job == 'DNC' then
		set_macro_page(6, 2)
	elseif player.sub_job == 'SAM' then
		set_macro_page(6, 2)
	else
		set_macro_page(6, 2)
	end
end
