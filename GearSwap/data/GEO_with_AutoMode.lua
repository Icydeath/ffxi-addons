--[[

Common Macros needed:

Geo AutoAction (ON/OFF)
/con send {Player} gs c auto_action


Modes:
- Fury = iFury / G.Frailty
- Haste = iHaste / G.Frailty
- Attunement = iAttunement / G.Vex
- Acumen = iAcumen / G.Malaise
- Precision = iPrecision / G.Torpor
- Focus = iFocus / G.Languor

Macro:
/con send {Player} gs c geo_mode


Entrust (This goes always to <p1>)
/con send {Player} gs c entrust_acc
/con send {Player} gs c entrust_focus
/con send {Player} gs c entrust_fury
/con send {Player} gs c entrust_haste


Geo BoG: (BoG the current Geo Bubble set as mode)
/con send {Player} gs c blaze


Assist (To get on the hate list on new mobs)
/con send {Player} /assist <p1>   // oder {DD}
/wait 1
/con send {Player} /ma "Dia II" <t>

]]--

-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2

    -- Load and initialize the include file.
--	include('Mote-Include.lua')  
--	include('organizer-lib')

    -- VARIABLES --
    auto_action = 'Off'
	geo_mode = 'Fury'	
	blaze = 'Off'
	
	windower.register_event('tp change', function(new, old)
        if new > 349
        and auto_action == 'On' then
            relaxed_play_mode()
        end
    end)

    windower.register_event('time change', function(time)
        if auto_action == 'On' then
            relaxed_play_mode()
        end
    end)
	
	
	--------------------------------------
    -- Precast sets
    --------------------------------------

    -- Precast sets to enhance JAs
    sets.precast = {}
    sets.precast.JA = {}	
    sets.precast.JA.Bolster = {body="Bagua Tunic"}
    sets.precast.JA['Life cycle'] = {body="Geo. Tunic +1",back="Nantosuelta's Cape"}
	sets.precast.JA['Full cycle'] = {head="Azimuth Hood"}
    sets.precast.JA['Radial Arcana'] = {feet="Bagua sandals"}
	sets.precast.JA['Primeval Zeal'] = {head="Bagua Galero"}
	sets.precast.JA['Cardinal Chant'] = {head="Geomancy Galero"}
	sets.precast.JA['Curative Recantation'] = {hands="Bagua Mitaines"}
	sets.precast.JA['Mending Halation'] = {legs="Bagua Pants +1"}

	merl_head_FC="Merlinic Hood"
	merl_feet_FC={name="Merlinic Crackows", augments={'INT+8'}}
	merl_feet_idle={name="Merlinic Crackows", augments={'CHR+1'}}
	solstice="Solstice"
	merl_legs_MAB="Merlinic Shalwar"

	
    -- Fast cast sets for spells

    sets.precast.FastCast = {
	main="Sucellus",sub="Genbu's Shield",range="Dunna",
        head=merl_head_FC,neck="Voltsurge Torque",
        body="Merlinic Jubbah",hands="Merlinic Dastanas",ring1="Prolix Ring",
        back="Swith Cape",waist="Channeler's Stone",legs="Telchine Braconi",feet=merl_feet_FC
		}

    --sets.precast.FC.Cure = set_combine(sets.precast.FC, {main="Tamaxchi",sub="Sors Shield",back="Pahtli Cape"})

    --sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {hands="Bagua mitaines"})

    
    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {}

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS['Flash Nova'] = {}

    sets.precast.WS['Starlight'] = {ear2="Moonshade Earring"}

    sets.precast.WS['Moonlight'] = {ear2="Moonshade Earring"}


    --------------------------------------
    -- Midcast sets
    --------------------------------------

    -- Base fast recast for spells
    sets.midcast = {}
    sets.midcast.FastRecast = {range="Dunna",ammo=empty,back="Lifestream Cape"}

    sets.midcast.Geomancy = {
		main=solstice,sub="Genbu's Shield",range="Dunna",
	    head="Azimuth Hood",neck="Deceiver's Torque",
		body="Bagua Tunic",hands="Geomancy Mitaines",back="Nantosuelta's Cape",waist="Channeler's Stone"
	}
		
    sets.midcast.Geomancy.Indi = set_combine(sets.midcast.Geomancy, {back=geo_PET,legs="Bagua Pants +1",feet="Azimuth Gaiters"})
		
        sets.midcast.Cure = sets.midcast.FastRecast
		
    sets.midcast.Curaga = sets.midcast.Cure

    sets.midcast.Protectra = {ring1="Sheltered Ring"}

    sets.midcast.Shellra = {ring1="Sheltered Ring"}

    sets.midcast['Enhancing Magic'] = {main="Gada",sub="Ammurapi Shield",head=telc_head_ENH,body=telc_body_ENH,hands=telc_hands_ENH,legs=telc_legs_ENH,feet=telc_feet_ENH}

    sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {ear1="Earthcry Earring",waist="Siegel Sash"})
	sets.midcast.Cursna = {waist="Gishdubar Sash",ring1="Haoma's Ring",ring2="Ephedra Ring"}
	sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {waist="Gishdubar Sash",feet="Inspirited Boots"})
	sets.midcast.Warp = set_combine(sets.midcast.FastRecast, {})

    
	sets.midcast['Enfeebling Magic'] = {main=grio_ENF,sub="Enki Strap",ammo="Hydrocera",
	    head=merl_head_MAB,neck="Incanter's Torque",ear1="Barkarole Earring",ear2="Dignitary's Earring",
		body=merl_body_MB,hands="Lurid Mitts",ring1="Metamorph Ring +1",ring2="Kishar Ring",
		back=geo_MAB,waist="Luminary Sash",legs=merl_legs_MAB,feet="Skaoi Boots"}
    
	sets.midcast['Elemental Magic'] = {main=solstice,sub="Genbu's Shield",
		head="Merlinic Hood",neck="Quanpur Necklace",ear1="Friomisi Earring",ear2="Strophadic Earring", 
		body="Merlinic Jubbah",hands="Amalric Gages",ring1="Mujin Band",ring2="Acumen Ring",
		back="Nantosuelta's Cape",waist="Channeler's Stone",legs=merl_legs_MAB,feet=merl_feet_FC}
		
        
    sets.midcast.Impact = set_combine(sets.midcast['Elemental Magic'], {head=empty,body="Twilight Cloak"})

	sets.midcast['Dark Magic'] = {main="Rubicundity",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
	    head=merl_head_MAB,neck="Incanter's Torque",ear1="Barkarole Earring",ear2="Dignitary's Earring",
        body="Shango Robe",hands=merl_hands_AS,ring1="Evanescence Ring",ring2="Kishar Ring",
		back="Swith Cape +1",waist="Witful Belt",legs="Psycloth Lappas",feet="Skaoi Boots"}
	
	sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {main="Rubicundity",sub="Ammurapi Shield",
	    head="Pixie Hairpin +1",neck="Incanter's Torque",ear1="Hirudinea Earring",
		hands=merl_hands_AS,back=geo_MAB,waist="Fucho-no-obi"})
    sets.midcast.Aspir = set_combine(sets.midcast.Drain, {})	

		
		
    sets.magic_burst = sets.midcast['Elemental Magic']
	sets.midcast.Elemental = sets.midcast['Elemental Magic']

	
				
	sets.obi = {}				
				
    --------------------------------------
    -- Idle/resting/defense/etc sets
    --------------------------------------
	
    -- Resting sets
    sets.resting = {}
	
    -- Idle sets

    sets.idle = {
		main=solstice,
		sub="Genmei Shield",
		range="Dunna",
        head="Befouled Crown",
		neck="Loricate Torque +1",
		ear1="Hearty Earring",
		ear2="Moonshade Earring",
        body="Jhakri Robe +1",
		hands=merl_hands_DT,
		ring1="Shneddick Ring",
		ring2="Warp Ring",
        back="Lifestream Cape",
		waist="Gishdubar Sash",
		legs="Assiduity Pants +1",
		feet=merl_feet_idle}

    sets.idle.PDT = sets.idle

    -- .Pet sets are for when Luopan is present.
	sets.idle.Pet = sets.idle
   
    sets.idle.PDT.Pet = sets.idle.Pet

    -- .Indi sets are for when an Indi-spell is active.
    --sets.idle.Indi = set_combine(sets.idle, {legs="Bagua Pants"})
    --sets.idle.Pet.Indi = set_combine(sets.idle.Pet, {legs="Bagua Pants"})
    --sets.idle.PDT.Indi = set_combine(sets.idle.PDT, {legs="Bagua Pants"})
    --sets.idle.PDT.Pet.Indi = set_combine(sets.idle.PDT.Pet, {legs="Bagua Pants"})

    sets.Kiting = {feet="Geomancy Sandals"}

    sets.latent_refresh = {waist="Fucho-no-obi"}


    --------------------------------------
    -- Engaged sets
    --------------------------------------

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion

    -- Normal melee group
    sets.engaged = {}
	
	
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

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    indi_timer = ''
    indi_duration = 180
	
	
	    -- VARIABLES --
    auto_action = 'Off'
	geo_mode = 'Fury'
	blaze = 'Off'
	
	windower.register_event('tp change', function(new, old)
        if new > 349
        and auto_action == 'On' then
            relaxed_play_mode()
        end
    end)

    windower.register_event('time change', function(time)
        if auto_action == 'On' then
            relaxed_play_mode()
        end
    end)
	
	
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('None', 'Normal')
    state.CastingMode:options('Normal', 'Resistant')
    state.IdleMode:options('Normal', 'PDT')

	state.MagicBurst = M(true, 'Magic Burst')
 
    -- Additional local binds
    send_command('bind ^` gs c toggle MagicBurst')
end

function self_command(str)
    -- Use an in game macro "/con gs c auto_action" to toggle bot Off and On
							--macro: "/con send Anukk gs c auto_action"
    if str == 'auto_action' then
		if auto_action == 'Off' then
			auto_action = 'On'
		else
			auto_action  = 'Off'
		end
		windower.add_to_chat(8,'Auto fire event set to: '..auto_action)
		windower.send_command('input /echo Auto_action: '..auto_action)
		
	elseif str == 'geo_mode' then
		if geo_mode == 'Fury' then
			geo_mode = 'Haste'
		elseif geo_mode == 'Haste' then
			geo_mode = 'Attunement'
		elseif geo_mode == 'Attunement' then
			geo_mode = 'Acumen'
		elseif geo_mode == 'Acumen' then
			geo_mode = 'Precision'
		elseif geo_mode == 'Precision' then
			geo_mode = 'Focus'
		elseif geo_mode == 'Focus' then
			geo_mode = 'Fury'
		end		
		windower.add_to_chat(8,'Geo set mode: '..geo_mode)		
		windower.send_command('input /echo Geo_mode: '..geo_mode)
		
	elseif str == 'entrust_acc' then
		if not check_buffs('silence', 'mute')
		and check_recasts(s('Indi-Precision'))
		and check_recasts(s('Entrust')) then
			windower.send_command('Entrust <me>;wait 1;Indi-Precision <p1>')				
		end
		
	elseif str == 'entrust_focus' then
		if not check_buffs('silence', 'mute')
		and check_recasts(s('Indi-Focus'))
		and check_recasts(s('Entrust')) then
			windower.send_command('Entrust <me>;wait 1;Indi-Focus <p1>')				
		end		

	elseif str == 'entrust_fury' then
		if not check_buffs('silence', 'mute')
		and check_recasts(s('Indi-Fury'))
		and check_recasts(s('Entrust')) then
			windower.send_command('Entrust <me>;wait 1;Indi-Fury <p1>')				
		end	
	
	elseif str == 'entrust_refresh' then
		if not check_buffs('silence', 'mute')
		and check_recasts(s('Indi-Refresh'))
		and check_recasts(s('Entrust')) then
			windower.send_command('Entrust <me>;wait 1;Indi-Refresh <p1>')				
		end			
	
	elseif str == 'entrust_haste' then
		if not check_buffs('silence', 'mute')
		and check_recasts(s('Indi-Haste'))
		and check_recasts(s('Entrust')) then
			windower.send_command('Entrust <me>;wait 1;Indi-Haste <p1>')				
		end	

	elseif str == 'blaze' then
		if not check_buffs('silence', 'mute')
		and player.mp > 379
		and check_recasts(s('Radial Arcana'))
		and check_recasts(s('Blaze of Glory'))
		and check_recasts(s('Dematerialize')) then
			blaze = 'On'
		end	
		
	end
end
	
function relaxed_play_mode()
    -- This can be used as a mini bot to automate actions
    if not midaction() then
        if player.hpp < 70
                and not check_buffs('silence', 'mute')
                and check_recasts(s('cure4')) then
				windower.send_command('cure4 <me>')
				
		elseif player.hpp > 90 
                and player.mpp < 10
                and check_recasts(s('Convert')) then
				windower.send_command('Convert;wait 1;cure4 <me>')
				
		elseif not check_buffs('Refresh')
                and not check_buffs('silence', 'mute')
                and check_recasts(s('Refresh')) then
				windower.send_command('Refresh <me>')
														
		--Indi	
		elseif not check_buffs('Attack Boost')
                and not check_buffs('silence', 'mute')
				and geo_mode == 'Fury'
                and check_recasts(s('Indi-Fury')) then
				windower.send_command('Indi-Fury')
				
		elseif not buffactive[580]
				--buffactive[581]
				--check_buffs('Haste')
                and not check_buffs('silence', 'mute')
				and geo_mode == 'Haste'
                and check_recasts(s('Indi-Haste')) then
				windower.send_command('Indi-Haste')
				
		elseif not check_buffs('Magic Evasion Boost')
                and not check_buffs('silence', 'mute')
				and geo_mode == 'Attunement'
                and check_recasts(s('Indi-Attunement')) then
				windower.send_command('Indi-Attunement')
			
		elseif not check_buffs('Magic Atk. Boost')
                and not check_buffs('silence', 'mute')
				and geo_mode == 'Acumen'
                and check_recasts(s('Indi-Acumen')) then
				windower.send_command('Indi-Acumen')

		elseif not check_buffs('Accuracy Boost')
                and not check_buffs('silence', 'mute')
				and geo_mode == 'Precision'
                and check_recasts(s('Indi-Precision')) then
				windower.send_command('Indi-Precision')				

		elseif not check_buffs('Magic Accuracy Boost')
                and not check_buffs('silence', 'mute')
				and geo_mode == 'Focus'
                and check_recasts(s('Indi-Focus')) then
				windower.send_command('Indi-Focus')	
				
		--blaze of glory
		elseif blaze == 'On'
				and not check_buffs('silence', 'mute')
				and check_recasts(s('Geo-Frailty'))
				and player.mp > 379 
				and check_recasts(s('Radial Arcana'))
				and check_recasts(s('Blaze of Glory'))
				and check_recasts(s('Dematerialize')) then
					if geo_mode == 'Fury' then
						windower.send_command('Radial Arcana <me>;wait 1;Blaze of Glory <me>;wait 2;Geo-Frailty <bt>;wait 6;Dematerialize <me>;wait 1;Life Cycle <me>;wait 1;Lasting Emanation <me>;wait 1;Dia2 <bt>')
					elseif geo_mode == 'Haste' then
						windower.send_command('Radial Arcana <me>;wait 1;Blaze of Glory <me>;wait 2;Geo-Frailty <bt>;wait 6;Dematerialize <me>;wait 1;Life Cycle <me>;wait 1;Lasting Emanation <me>;wait 1;Dia2 <bt>')
					elseif geo_mode == 'Attunement' then
						windower.send_command('Radial Arcana <me>;wait 1;Blaze of Glory <me>;wait 2;Geo-Vex <bt>;wait 6;Dematerialize <me>;wait 1;Life Cycle <me>;wait 1;Lasting Emanation <me>;wait 1;Dia2 <bt>')
					elseif geo_mode == 'Acumen' then
						windower.send_command('Radial Arcana <me>;wait 1;Blaze of Glory <me>;wait 2;Geo-Malaise <bt>;wait 6;Dematerialize <me>;wait 1;Life Cycle <me>;wait 1;Lasting Emanation <me>;wait 1;Dia2 <bt>')
					elseif geo_mode == 'Precision' then
						windower.send_command('Radial Arcana <me>;wait 1;Blaze of Glory <me>;wait 2;Geo-Torpor <bt>;wait 6;Dematerialize <me>;wait 1;Life Cycle <me>;wait 1;Lasting Emanation <me>;wait 1;Dia2 <bt>')
					elseif geo_mode == 'Focus' then
						windower.send_command('Radial Arcana <me>;wait 1;Blaze of Glory <me>;wait 2;Geo-Languor <bt>;wait 6;Dematerialize <me>;wait 1;Life Cycle <me>;wait 1;Lasting Emanation <me>;wait 1;Dia2 <bt>')
					end
					blaze = 'Off'
		
		--Geo
		elseif not pet.isvalid
				and not check_buffs('silence', 'mute')
				and check_recasts(s('Geo-Frailty'))
				and check_recasts(s('Geo-Vex'))
				and check_recasts(s('Geo-Malaise'))
				and check_recasts(s('Geo-Torpor'))	then
 					if player.mp > 305	and geo_mode == 'Fury' then
						windower.send_command('wait 1;Geo-Frailty <bt>;wait 7;Dia2 <bt>;wait 3;Distract <bt>')
					elseif player.mp > 302	and geo_mode == 'Haste' then
						windower.send_command('wait 1;Geo-Frailty <bt>;wait 7;Dia2 <bt>;wait 3;Distract <bt>')
					elseif player.mp > 302	and geo_mode == 'Attunement' then
						windower.send_command('wait 1;Geo-Vex <bt>;wait 7;Dia2 <bt>;wait 3;Distract <bt>')
					elseif player.mp > 379 and geo_mode == 'Acumen' then
						windower.send_command('wait 1;Geo-Malaise <bt>;wait 7;Frazzle <bt>')	
					elseif player.mp > 203 and geo_mode == 'Precision' then
						windower.send_command('wait 1;Geo-Torpor <bt>;wait 7;Dia2 <bt>;wait 3;Distract <bt>')
					elseif player.mp > 249 and geo_mode == 'Focus' then
						windower.send_command('wait 1;Geo-Languor <bt>;wait 7;Dia2 <bt>;wait 3;Frazzle <bt>')						
					end
		
		end
	end
	
	if not midaction() then
		--[[
		if not check_buffs('Stoneskin')
			and not check_buffs('silence', 'mute')
			and check_recasts(s('Stoneskin')) then
			windower.send_command('Stoneskin')	
		end]]--
		--if not check_buffs('Phalanx')
		--	and not check_buffs('silence', 'mute')
		--	and check_recasts(s('Phalanx')) then
		--	windower.send_command('Phalanx')	
		--end		
	end
	
end

function relaxed_play_mode2()
    -- Skillup Elemental/Enfeebling/Dark
    if not midaction() then
        if player.hpp < 70
                and not check_buffs('silence', 'mute')
                and check_recasts(s('cure4')) then
				windower.send_command('cure4 <me>')

		elseif player.hpp > 90 
                and player.mpp < 10
                and check_recasts(s('Convert')) then
				windower.send_command('Convert;wait 1;cure4 <me>')

		elseif not check_buffs('Regen')
                and not check_buffs('silence', 'mute')
                and check_recasts(s('Indi-Regen')) then
				windower.send_command('Indi-Regen')				
     			
		elseif not pet.isvalid
                and not check_buffs('silence', 'mute')
                and check_recasts(s('Geo-Refresh')) then
				windower.send_command('Geo-Refresh <me>')
			
		elseif not check_buffs('silence', 'mute') then
				windower.send_command('dia <bt>')
									
        end
    end
end


-- Define sets and vars used by this job file.
-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

function job_get_spell_map(spell, default_spell_map)
    if spell.action_type == 'Magic' then
        if spell.skill == 'Enfeebling Magic' then
            if spell.type == 'WhiteMagic' then
                return 'MndEnfeebles'
            else
                return 'IntEnfeebles'
            end
        elseif spell.skill == 'Geomancy' then
            if spell.english:startswith('Indi') then
                return 'Indi'
            end
        end
    end
end


function customize_idle_set(idleSet)
    if player.mpp < 51 then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    return idleSet
end

-- Called by the 'update' self-command.
function job_update(cmdParams, eventArgs)
    classes.CustomIdleGroups:clear()
    if player.indi then
        classes.CustomIdleGroups:append('Indi')
    end
end

-- Function to display the current relevant user state when doing an update.
function display_current_job_state(eventArgs)
    local msg = 'Offense'
    msg = msg .. ': [' .. state.OffenseMode.value .. '], '
    msg = msg .. 'Casting'
    msg = msg .. ': [' .. state.CastingMode.value .. '], '
    msg = msg .. 'Idle'
    msg = msg .. ': [' .. state.IdleMode.value .. '], '

    if state.MagicBurst.value == true then
        msg = msg .. 'Magic Burst: [On]'
    elseif state.MagicBurst.value == false then
        msg = msg .. 'Magic Burst: [Off]'
    end

    add_to_chat(122, msg)

    eventArgs.handled = true
end

function job_post_midcast(spell, action, spellMap, eventArgs)
	if spell.action_type == "Magic" then
        if spell.element == world.weather_element or spell.element == world.day_element then
            equip(sets.obi[spell.element])
        end
    end
    if spell.skill == 'Elemental Magic' then
	--and state.MagicBurst.value then
        equip(sets.magic_burst)
    end
end

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

function gear_modes()
    -- User created bridge for aftercast and status_change functions
    -- Sequential gear sets used to easily allow for changing player needs
    --slot_disabling()

    local attack_preference = 'null'

    if player.status == 'Engaged' then
        equip(sets.engaged)
    elseif player.status == 'Idle' then
        equip(sets.idle)
        if dt_mode == 'None' then
            --print(party.count)
            if party.count > 1 then
                equip(sets.idle.SphereRefresh)
            end
            if player.mpp < 50 then
                equip(sets.idle.under_50mpp)
            end
            if check_buffs('Reive Mark') then
                equip(sets.misc.Reive)
            end
        end
    end

   -- Will inform you if no weapon is equiped and re-equip once able
    if player.equipment.main == 'empty' then
        equip(sets.weapon[weapon_combo])
        windower.add_to_chat(8,'No Weapon, trying to re-equip: '..weapon_combo)
    end
end

function precast(spell,arg)
    gear_change_ok = false
    slot_disabling()


    --[[ Generic equip command for Job Abilities and Weaponskills that have
            a gear set listed in get_sets()
            If Idle and a weaponskill macro is pressed you will change to
            current Idle/DT set, useful as a fast way to equip proper gear
            For then in game macros the quotations("") and <t> aren't needed
            EX: /ws Expiacion ]]
    if sets.precast.JA[spell.name] then
        equip(sets.precast.JA[spell.name])
    elseif sets.precast.WS[spell.name] then
        if player.status == 'Engaged' then
            equip(sets.precast.WS[spell.name])
            if check_buffs('Reive Mark') then
                equip(sets.misc.Reive)
            end
        else
            cancel_spell()
            gear_modes()
            return
        end
    end

    -- Magic spell gear handling(Precast)
    if spell.prefix == '/magic'
            or spell.prefix == '/ninjutsu'
            or spell.prefix == '/song' then
        if spell.type == 'BlueMagic' then
            equip(sets.precast.FastCast.BlueMagic)
        else
            equip(sets.precast.FastCast)
        end
        if spell.name == 'Utsusemi: Ichi'
                and check_recasts(spell)
                and shadow_type == 'Ni' then
            if check_buffs(
                    'Copy Image',
                    'Copy Image (2)',
                    'Copy Image (3)') then
                windower.send_command('cancel copy image;'
                    ..'cancel copy image (2); cancel copy image (3)')
            end
        elseif (spell.name == 'Monomi: Ichi' or spell.name == 'Sneak')
                and check_buffs('Sneak')
                and check_recasts(spell)
                and spell.target.type == 'SELF' then
            windower.send_command('cancel sneak')
        elseif (spell.name == 'Diamondhide'
                or spell.name == 'Metallic body'
                or spell.name == 'Stoneskin')
                and check_buffs('Stoneskin')
                and check_recasts(spell) then
            windower.send_command('cancel stoneskin')
        end
    end

    -- Dancer Sub Job
    if spell.name == 'Spectral Jig'
            and check_buffs('Sneak')
            and check_recasts(spell) then
        windower.send_command('cancel sneak')
        cast_delay(0.3)
    elseif windower.wc_match(spell.name,'*Step') then
        equip(sets.TP['Accuracy High'])
    end
end


function midcast(spell,arg)
    -- Special handling for Spell Mappings outlined in get_maps()
    local stat
	
	if spell.english:startswith('Indi') or spell.english:startswith('Geo') then
		equip(sets.midcast.Geomancy)
	end
    if spell.skill == 'Healing Magic' or spell.skill == 'Enhancing Magic'
            or spell.type == 'Trust' then
        equip(sets.midcast.FastRecast)
        if spell.name:startswith('Cure') then
            equip(sets.midcast.Cure)
            if spell.target.type == 'SELF' then
                equip(sets.midcast.Cure)
            end
        end
	end
    if spell.skill == 'Elemental Magic' then
        equip(sets.midcast.Elemental)
    end

end


function aftercast(spell,arg)
    gear_change_ok = true
    gear_modes()

    -- Gear info, useful if using DressUp or BlinkMeNot

    if not spell.interrupted then
        -- Changes shadow type variable to allow cancel Copy Image
        -- if last cast was Utsusemi: Ni
        if spell.name == 'Utsusemi: Ni' then
            shadow_type = 'Ni'
        elseif spell.name == 'Utsusemi: Ichi' then
            shadow_type = 'Ichi'
        end

        -- If you have spells under a different macro set in game this will let
        -- you change to that set quickly and then change back once finished
        if spell.name:startswith('Unbridled') then
            windower.send_command('input /macro set 3')
        end

        -- TIMERS PLUGIN: Dream Flower
        if spell.name == 'Dream Flower' then
            windower.add_to_chat(8,'NOTE: 1:30 general timer set, '
                ..'max sleep can last 2:00')
            windower.send_command('timers c "Dream Flower" 90 down'
                ..'spells/00521.png')
        end

        -- TIMERS PLUGIN: Since Aftermath: Lv.1 can overwrite itself this
        -- will delete and re-create this specific timer
        if spell.name == 'Expiacion' and player.equipment.main == 'Tizona'
                and check_buffs('Aftermath: Lv.1') then
            windower.send_command('timers d "Aftermath: Lv.1"; wait 0.3;'
                ..'timers c "Aftermath: Lv.1" 90 down abilities/00027.png')
        end
    end
end

function slot_disabling()
    -- Disable slots for items you don't want removed when performing actions
    if player.equipment.head == 'Reraise Hairpin' then
        disable('head')
        windower.add_to_chat(8,'Reraise Hairpin equiped on head')
    else
        enable('head')
    end

    if player.equipment.left_ear == 'Reraise Earring' then
        disable('left_ear')
        windower.add_to_chat(8,'Reraise Earring equiped on left ear')
    else
        enable('left_ear')
    end

    if player.equipment.right_ear == 'Reraise Earring' then
        disable('right_ear')
        windower.add_to_chat(8,'Reraise Earring equiped on right ear')
    else
        enable('right_ear')
    end
end


function status_change(new,old)
    if T{'Idle','Engaged'}:contains(new) and gear_change_ok then
        gear_modes()
    end
end