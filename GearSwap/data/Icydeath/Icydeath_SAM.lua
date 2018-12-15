-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------
-- City areas for town gear and behavior.
areas = {}
areas.Cities = S{
    "Ru'Lude Gardens",
    "Upper Jeuno",
    "Lower Jeuno",
    "Port Jeuno",
    "Port Windurst",
    "Windurst Waters",
    "Windurst Woods",
    "Windurst Walls",
    "Heavens Tower",
    "Port San d'Oria",
    "Northern San d'Oria",
    "Southern San d'Oria",
    "Port Bastok",
    "Bastok Markets",
    "Bastok Mines",
    "Metalworks",
    "Aht Urhgan Whitegate",
    "Tavnazian Safehold",
    "Nashmau",
    "Selbina",
    "Mhaura",
    "Norg",
    "Eastern Adoulin",
    "Western Adoulin",
    "Kazham"
}


-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2
	include('organizer-lib')
    -- Load and initialize the include file.
    include('Mote-Include.lua')
end


-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    state.Buff.Hasso = buffactive.Hasso or false
    state.Buff.Seigan = buffactive.Seigan or false
    state.Buff.Sekkanoki = buffactive.Sekkanoki or false
    state.Buff.Sengikori = buffactive.Sengikori or false
    state.Buff['Meikyo Shisui'] = buffactive['Meikyo Shisui'] or false
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.
function user_setup()
    state.OffenseMode:options('Normal', 'Acc')
    state.HybridMode:options('Normal', 'PDT', 'Reraise')
    state.WeaponskillMode:options('Normal', 'Acc', 'Mod')
    state.PhysicalDefenseMode:options('PDT', 'Reraise')

    update_combat_form()

	windower.register_event('tp change', function(new, old)
		if not areas.Cities:contains(world.area)
			and player.status == 'Engaged'
			and not buffactive['Hasso'] 
			and not buffactive['Seigan']
			and not buffactive['Invisible'] then
				send_command('Hasso')
				return true
		end
	end)	
end


-- Called when this job file is unloaded (eg: job change)
function user_unload()
    send_command('unbind ^`')
    send_command('unbind !-')
end


-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------
    
    -- Precast Sets
    -- Precast sets to enhance JAs
    sets.precast.JA.Meditate = {} --head="Myochin Kabuto",hands="Sakonji Kote"
    sets.precast.JA['Warding Circle'] = {} --head="Myochin Kabuto"
    sets.precast.JA['Blade Bash'] = {} --hands="Sakonji Kote"

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {}
        
    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz['Healing Waltz'] = {}

       
    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
		head={ name="Valorous Mask", augments={'Accuracy+29','Weapon skill damage +1%','VIT+7','Attack+15',}},
		body={ name="Found. Breastplate", augments={'Accuracy+14','Mag. Acc.+13','Attack+14','"Mag.Atk.Bns."+14',}},
		hands={ name="Valorous Mitts", augments={'Accuracy+25','"Dbl.Atk."+1','STR+6','Attack+8',}},
		legs={ name="Ryuo Hakama", augments={'Accuracy+20','"Store TP"+4','Phys. dmg. taken -3',}},
		feet={ name="Valorous Greaves", augments={'Accuracy+30','"Dbl.Atk."+1','DEX+1','Attack+7',}},
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Ishvara Earring",
		right_ear={ name="Moonshade Earring", augments={'"Mag.Atk.Bns."+4','TP Bonus +250',}},
		left_ring="Petrov Ring",
		right_ring="Cacoethic Ring +1",
		back={ name="Takaha Mantle", augments={'STR+4','"Zanshin"+2','"Store TP"+1',}},
	}
    sets.precast.WS.Acc = set_combine(sets.precast.WS, {})

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS['Tachi: Fudo'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Tachi: Fudo'].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS['Tachi: Fudo'].Mod = set_combine(sets.precast.WS['Tachi: Fudo'], {})

    sets.precast.WS['Tachi: Shoha'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Tachi: Shoha'].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS['Tachi: Shoha'].Mod = set_combine(sets.precast.WS['Tachi: Shoha'], {})

    sets.precast.WS['Tachi: Rana'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Tachi: Rana'].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS['Tachi: Rana'].Mod = set_combine(sets.precast.WS['Tachi: Rana'], {})

    sets.precast.WS['Tachi: Kasha'] = set_combine(sets.precast.WS, {})

    sets.precast.WS['Tachi: Gekko'] = set_combine(sets.precast.WS, {})

    sets.precast.WS['Tachi: Yukikaze'] = set_combine(sets.precast.WS, {})

    sets.precast.WS['Tachi: Ageha'] = set_combine(sets.precast.WS, {})

    sets.precast.WS['Tachi: Jinpu'] = set_combine(sets.precast.WS, {})


    -- Midcast Sets
    sets.midcast.FastRecast = {}

    
    -- Sets to return to when not performing an action.
    
    -- Resting sets
    sets.resting = {}
    

    -- Idle sets (default idle set not needed since the other three are defined, but leaving for testing purposes)
	sets.idle = {
		head={ name="Valorous Mask", augments={'Accuracy+16 Attack+16','"Store TP"+6','AGI+4','Accuracy+7','Attack+2',}},
		body="Chozor. Coselete",
		hands="Kurys Gloves",
		legs={ name="Ryuo Hakama", augments={'Accuracy+20','"Store TP"+4','Phys. dmg. taken -3',}},
		feet={ name="Amm Greaves", augments={'HP+50','VIT+10','Accuracy+15','Damage taken-2%',}},
		neck="Twilight Torque",
		waist="Flume Belt +1",
		left_ear="Ethereal Earring",
		right_ear="Etiolation Earring",
		left_ring="Sheltered Ring",
		right_ring="Defending Ring",
		back="Xucau Mantle",
	}
	
    sets.idle.Town = set_combine(sets.idle, {})
    
    sets.idle.Field = set_combine(sets.idle, {})

    sets.idle.Weak = set_combine(sets.idle, {
        head="Twilight Helm",
        body="Twilight Mail"
	})
    
    -- Defense sets
    sets.defense.PDT = {}

    sets.defense.Reraise = {}

    sets.defense.MDT = {}

    sets.Kiting = {}

    sets.Reraise = {head="Twilight Helm",body="Twilight Mail"}

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion
    
    -- Normal melee group
    sets.engaged = {
		main={ name="Himetsuruichimonji", augments={'STR+10','Accuracy+10','Attack+10','Quadruple Attack +3',}},
		sub="Bloodrain Strap",
		ammo="Ginsen",
		head={ name="Valorous Mask", augments={'Accuracy+16 Attack+16','"Store TP"+6','AGI+4','Accuracy+7','Attack+2',}},
		body={ name="Found. Breastplate", augments={'Accuracy+14','Mag. Acc.+13','Attack+14','"Mag.Atk.Bns."+14',}},
		hands={ name="Valorous Mitts", augments={'Accuracy+25','"Dbl.Atk."+1','STR+6','Attack+8',}},
		legs={ name="Ryuo Hakama", augments={'Accuracy+20','"Store TP"+4','Phys. dmg. taken -3',}},
		feet={ name="Valorous Greaves", augments={'Accuracy+30','"Dbl.Atk."+1','DEX+1','Attack+7',}},
		neck="Lissome Necklace",
		waist="Kentarch Belt +1",
		left_ear="Brutal Earring",
		right_ear="Cessance Earring",
		left_ring="Petrov Ring",
		right_ring="Rajas Ring",
		back={ name="Takaha Mantle", augments={'STR+4','"Zanshin"+2','"Store TP"+1',}},
	}
    sets.engaged.Acc = {}
    sets.engaged.PDT = {}
    sets.engaged.Acc.PDT = {}
    sets.engaged.Reraise = {}
    sets.engaged.Acc.Reraise = {}
        
    -- Melee sets for in Adoulin, which has an extra 10 Save TP for weaponskills.
    sets.engaged.Adoulin = {}
    sets.engaged.Adoulin.Acc = {}
    sets.engaged.Adoulin.PDT = {}
    sets.engaged.Adoulin.Acc.PDT = {}
    sets.engaged.Adoulin.Reraise = {}
    sets.engaged.Adoulin.Acc.Reraise = {}


    sets.buff.Sekkanoki = {} --hands="Unkai Kote +2"
    sets.buff.Sengikori = {} --feet="Unkai Sune-ate +2"
    sets.buff['Meikyo Shisui'] = {} --feet="Sakonji Sune-ate"
end


-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic target handling to be done.
function job_pretarget(spell, action, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        -- Change any GK weaponskills to polearm weaponskill if we're using a polearm.
        if player.equipment.main=='Quint Spear' or player.equipment.main=='Quint Spear' then
            if spell.english:startswith("Tachi:") then
                send_command('@input /ws "Penta Thrust" '..spell.target.raw)
                eventArgs.cancel = true
            end
        end
    end
end

-- Run after the default precast() is done.
-- eventArgs is the same one used in job_precast, in case information needs to be persisted.
function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type:lower() == 'weaponskill' then
        if state.Buff.Sekkanoki then
            equip(sets.buff.Sekkanoki)
        end
        if state.Buff.Sengikori then
            equip(sets.buff.Sengikori)
        end
        if state.Buff['Meikyo Shisui'] then
            equip(sets.buff['Meikyo Shisui'])
        end
    end
end


-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Effectively lock these items in place.
    if state.HybridMode.value == 'Reraise' or
        (state.DefenseMode.value == 'Physical' and state.PhysicalDefenseMode.value == 'Reraise') then
        equip(sets.Reraise)
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Called by the 'update' self-command, for common needs.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(cmdParams, eventArgs)
    update_combat_form()
end

-- Set eventArgs.handled to true if we don't want the automatic display to be run.
function display_current_job_state(eventArgs)

end


-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

function update_combat_form()
    if areas.Adoulin:contains(world.area) and buffactive.ionis then
        state.CombatForm:set('Adoulin')
    else
        state.CombatForm:reset()
    end
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == 'WAR' then
        set_macro_page(1, 11)
    elseif player.sub_job == 'DNC' then
        set_macro_page(2, 11)
    elseif player.sub_job == 'THF' then
        set_macro_page(3, 11)
    elseif player.sub_job == 'NIN' then
        set_macro_page(4, 11)
    else
        set_macro_page(1, 11)
    end
end