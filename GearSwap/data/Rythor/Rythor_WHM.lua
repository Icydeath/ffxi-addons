-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2
    
    -- Load and initialize the include file.
    include('Mote-Include.lua')
	include('organizer-lib')	
end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    state.Buff['Afflatus Solace'] = buffactive['Afflatus Solace'] or false
    state.Buff['Afflatus Misery'] = buffactive['Afflatus Misery'] or false
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('None', 'Normal')
    state.CastingMode:options('Normal', 'Resistant')
    state.IdleMode:options('Normal', 'PDT')
	state.CP = M(false, "Capacity Points Mode")
	
    --select_default_macro_book()
	set_lockstyle('1')
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------

    -- Precast Sets

    -- Fast cast sets for spells
    sets.precast.FC = {
		ammo="Impatiens",
		body="Vrikodara Jupon",
		hands="Fanatic Gloves",
		legs="Aya. Cosciales +1",
		feet="Regal Pumps +1",
		waist="Witful Belt",
		left_ear="Etiolation Earring",
		right_ear="Loquac. Earring",
		back="Ogapepo Cape",
	}
        
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {
		main="Vadose Rod", 
		waist="Siegel Sash", 
		legs="Ebers Pantaloons +1"
	})

    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {
		head="Umuthi Hat"
	})

    sets.precast.FC['Healing Magic'] = set_combine(sets.precast.FC, {main="Vadose Rod", legs="Ebers Pantaloons +1"})

    sets.precast.FC.StatusRemoval = sets.precast.FC['Healing Magic']

    sets.precast.FC.Cure = {
		sub="Sors Shield",
		head={ name="Kaykaus Mitra", augments={'MP+60','"Cure" spellcasting time -5%','Enmity-5',}},
		body="Ebers Bliaud +1",
		hands={ name="Telchine Gloves", augments={'"Cure" spellcasting time -6%',}},
		legs="Ebers Pant. +1",
		feet="Litany Clogs",
		waist="Witful Belt",
		left_ear="Nourish. Earring",
		right_ear="Nourish. Earring +1",
		back="Ogapepo Cape",
	}

    sets.precast.FC.Curaga = sets.precast.FC['Healing Magic']
    
    -- Precast sets to enhance JAs
    sets.precast.JA.Benediction = {body="Piety Briault"}

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {}
    
    
    -- Weaponskill sets

    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {}
    
    sets.precast.WS['Flash Nova'] = {}
    

    -- Midcast Sets
    -- [ Haste gear ]
    sets.midcast.FastRecast = {}
    
    -- Cure sets
    sets.midcast.CureSolace = {
		main={ name="Queller Rod", augments={'Healing magic skill +15','"Cure" potency +10%','"Cure" spellcasting time -7%',}},
		sub="Sors Shield",
		ammo="Impatiens",
		head={ name="Kaykaus Mitra", augments={'MP+60','"Cure" spellcasting time -5%','Enmity-5',}},
		body="Ebers Bliaud +1",
		hands={ name="Telchine Gloves", augments={'"Cure" spellcasting time -6%',}},
		legs="Ebers Pant. +1",
		feet="Regal Pumps +1",
		neck="Nodens Gorget",
		waist="Gishdubar Sash",
		left_ear="Glorious Earring",
		right_ear="Nourish. Earring +1",
		left_ring="Stikini Ring",
		right_ring="Sirona's Ring",
		back="Oretan. Cape +1",
	}

    sets.midcast.Cure = set_combine(sets.midcast.CureSolace, {
	
	})

	-- Healing magic, MND
    sets.midcast.Curaga = set_combine(sets.midcast.Cure, {})

    sets.midcast.CureMelee = {}

    sets.midcast.Cursna = {
		main={ name="Queller Rod", augments={'Healing magic skill +15','"Cure" potency +10%','"Cure" spellcasting time -7%',}},
		sub="Thuellaic Ecu +1",
		ammo="Impatiens",
		head={ name="Kaykaus Mitra", augments={'MP+60','"Cure" spellcasting time -5%','Enmity-5',}},
		body="Ebers Bliaud +1",
		hands={ name="Fanatic Gloves", augments={'MP+45','Healing magic skill +9','"Conserve MP"+6','"Fast Cast"+5',}},
		legs="Ebers Pant. +1",
		feet="Gende. Galoshes",
		neck="Mizu. Kubikazari",
		waist="Cascade Belt",
		left_ear="Nourish. Earring",
		right_ear="Nourish. Earring +1",
		right_ring="Ephedra Ring",
		left_ring="Ephedra Ring",
		back="Alaunus's Cape",
	}

    sets.midcast.StatusRemoval = {}

    -- 110 total Enhancing Magic Skill; caps even without Light Arts
    sets.midcast['Enhancing Magic'] = {
		head="Chironic Hat",
		back="Mending Cape",
		waist="Cascade Belt",
		feet="Regal Pumps +1",
		ring1="Stikini Ring",
		
	}

    sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {
		neck="Nodens Gorget"
	})

    sets.midcast.Auspice = set_combine(sets.midcast['Enhancing Magic'], {})

    sets.midcast.BarElement = set_combine(sets.midcast['Enhancing Magic'], {})

    sets.midcast.Regen = set_combine(sets.midcast['Enhancing Magic'], {})

    sets.midcast.Protectra = set_combine(sets.midcast['Enhancing Magic'], {})

    sets.midcast.Shellra = set_combine(sets.midcast['Enhancing Magic'], {})


    sets.midcast['Divine Magic'] = {}

    sets.midcast['Dark Magic'] = {}

    -- Custom spell classes
    sets.midcast.MndEnfeebles = {}

    sets.midcast.IntEnfeebles = {}

    
    -- Sets to return to when not performing an action.
    
    -- Resting sets
    sets.resting = {}
    

    -- Idle sets (default idle set not needed since the other three are defined, but leaving for testing purposes)
    sets.idle = {
		main="Bolelabunga",
		sub="Genbu's Shield",
		ammo="Homiliary",
		head="Aya. Zucchetto +1",
		body="Ebers Bliaud +1",
		hands="Aya. Manopolas +1",
		legs="Assid. Pants +1",
		feet="Aya. Gambieras +1",
		neck="Sanctity Necklace",
		waist="Gishdubar Sash",
		left_ear="Etiolation Earring",
		right_ear={ name="Moonshade Earring", augments={'Mag. Acc.+4','Latent effect: "Refresh"+1',}},
		left_ring="Renaye Ring",
		right_ring="Sirona's Ring",
		back="Solemnity Cape",
	}

    sets.idle.PDT = sets.idle

    sets.idle.Town = sets.idle
    
    sets.idle.Weak = sets.idle
    
    -- Defense sets

    sets.defense.PDT = {}

    sets.defense.MDT = {}

    sets.Kiting = {feet="Herald's Gaiters"}

    sets.latent_refresh = {waist="Fucho-no-obi"}

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion
    
    -- Basic set for if no TP weapon is defined.
    sets.engaged = {}


    -- Buff sets: Gear that needs to be worn to actively enhance a current player buff.
    sets.buff['Divine Caress'] = {hands="Orison Mitts +2",back="Mending Cape"}
	
	sets.CP = {back="Mecisto. Mantle"}
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------
--Pretarget
-------------------------------------------------------------------------
function job_auto_change_target(spell, action, spellMap, eventArgs)
	eventArgs = {handled = false, PCTargetMode = state.PCTargetMode.value, SelectNPCTargets = state.SelectNPCTargets.value}
end

function pretarget(spell, action, spellMap, eventArgs)
	job_auto_change_target(spell, action, spellMap, eventArgs)
    if (spell.type:endswith('Magic') or spell.type == "Ninjutsu") and buffactive.silence then -- Auto Use Echo Drops If You Are Silenced --
		cancel_spell()
		send_command('input /item "Echo Drops" <me>')
	elseif buffactive['Light Arts'] or buffactive['Addendum: White'] then
		if spell.english == "Light Arts" and not buffactive['Addendum: White'] then
			cancel_spell()
			send_command('input /ja Addendum: White <me>')
		elseif spell.english == "Manifestation" then
			cancel_spell()
			send_command('input /ja Accession <me>')
		elseif spell.english == "Alacrity" then
			cancel_spell()
			send_command('input /ja Celerity <me>')
		elseif spell.english == "Parsimony" then
			cancel_spell()
			send_command('input /ja Penury <me>')
		end
	elseif buffactive['Dark Arts'] or buffactive['Addendum: Black'] then
		if spell.english == "Dark Arts" and not buffactive['Addendum: Black'] then
			cancel_spell()
			send_command('input /ja Addendum: Black <me>')
		elseif spell.english == "Accession" then
			cancel_spell()
			send_command('input /ja Manifestation <me>')
		elseif spell.english == "Celerity" then
			cancel_spell()
			send_command('input /ja Alacrity <me>')
		elseif spell.english == "Penury" then
			cancel_spell()
			send_command('input /ja Parsimony <me>')
		end
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    if spell.english == "Paralyna" and buffactive.Paralyzed then
        -- no gear swaps if we're paralyzed, to avoid blinking while trying to remove it.
        eventArgs.handled = true
    end
	if spell.type == 'WeaponSkill' then
		info.aftermath = {}
		info.aftermath.duration = 0
		
		info.aftermath.level = math.floor(player.tp / 1000)
        if info.aftermath.level == 0 then
            info.aftermath.level = 1
        end
		
		if spell.english == "Randgrith" then
			info.aftermath.weaponskill = spell.english
			
			info.aftermath.duration = math.floor(0.02 * player.tp)
			if info.aftermath.duration < 20 then
				info.aftermath.duration = 20
			end
		end
	end
end


function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Apply Divine Caress boosting items as highest priority over other gear, if applicable.
    if spellMap == 'StatusRemoval' and buffactive['Divine Caress'] then
        equip(sets.buff['Divine Caress'])
    end
end

function job_aftercast(spell, action, spellMap, eventArgs)
	if not spell.interrupted and spell.type == 'WeaponSkill' and info.aftermath and info.aftermath.weaponskill == spell.english and info.aftermath.duration > 0 then
		local aftermath_name = 'Aftermath: Lv.'..tostring(info.aftermath.level)
		send_command('timers d "Aftermath: Lv.1"')
		send_command('timers d "Aftermath: Lv.2"')
		send_command('timers d "Aftermath: Lv.3"')
		send_command('timers c "'..aftermath_name..'" '..tostring(info.aftermath.duration)..' down')

		info.aftermath = {}
	end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Handle notifications of general user state change.
function job_state_change(stateField, newValue, oldValue)
    if stateField == 'Offense Mode' then
        if newValue == 'Normal' then
		    disable('main','sub','range')
		elseif newValue == "ACC" then
            disable('main','sub','range')
        else
            enable('main','sub','range')
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Custom spell mapping.
function job_get_spell_map(spell, default_spell_map)
    if spell.action_type == 'Magic' then
        if (default_spell_map == 'Cure' or default_spell_map == 'Curaga') and player.status == 'Engaged' then
            return "CureMelee"
        elseif default_spell_map == 'Cure' and state.Buff['Afflatus Solace'] then
            return "CureSolace"
        elseif spell.skill == "Enfeebling Magic" then
            if spell.type == "WhiteMagic" then
                return "MndEnfeebles"
            else
                return "IntEnfeebles"
            end
        end
    end
end


function customize_idle_set(idleSet)
    if player.mpp < 51 then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
	
	if state.CP.current == 'on' then
		equip(sets.CP)
		disable('back')
	else
		enable('back')
	end
	
    return idleSet
end

-- Called by the 'update' self-command.
function job_update(cmdParams, eventArgs)
    if cmdParams[1] == 'user' and not areas.Cities:contains(world.area) then
        local needsArts = 
            player.sub_job:lower() == 'sch' and
            not buffactive['Light Arts'] and
            not buffactive['Addendum: White'] and
            not buffactive['Dark Arts'] and
            not buffactive['Addendum: Black']
            
        if not buffactive['Afflatus Solace'] and not buffactive['Afflatus Misery'] then
            if needsArts then
                send_command('@input /ja "Afflatus Solace" <me>;wait 1.2;input /ja "Light Arts" <me>;wait 1.2;input /ja "Addendum White" <me>')
            else
                send_command('@input /ja "Afflatus Solace" <me>')
            end
        end
    end
end

-- Function to display the current relevant user state when doing an update.
function display_current_job_state(eventArgs)
    display_current_caster_state()
    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    set_macro_page(1, 1)
end

function set_lockstyle(num)
	send_command('wait 2; input /lockstyleset '..num)
end