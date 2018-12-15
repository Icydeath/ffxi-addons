--[[
		gs c toggle luzafring -- Toggles use of Luzaf Ring on and off
		
		Offense mode is melee or ranged.  Used ranged offense mode if you are engaged
		for ranged weaponskills, but not actually meleeing.
		Acc on offense mode (which is intended for melee) will currently use .Acc weaponskill
		mode for both melee and ranged weaponskills.  Need to fix that in core.
--]]


-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2
    
    -- Load and initialize the include file.
    include('Mote-Include.lua')
	-- Organizer library
	include('organizer-lib.lua')
end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    -- Whether to use Luzaf's Ring
    state.LuzafRing = M(false, "Luzaf's Ring")
	-- Detect Triple Shot
	state.Buff['Triple Shot'] = buffactive['Triple Shot'] or false
    -- Whether a warning has been given for low ammo
    state.warned = M(false)
	state.Obi = 'ON' -- Turn Default Obi ON or OFF Here --
	state.ShowRollInfo = 'ON'
	
    define_roll_values()
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('Melee', 'Acc', 'Ranged')
    state.RangedMode:options('Normal', 'Acc')
    state.WeaponskillMode:options('Normal', 'Acc', 'Att', 'Mod')
    state.CastingMode:options('Normal', 'Resistant')
    state.IdleMode:options('Normal', 'PDT', 'MDT')

	gear.FallbackBullet = "Bronze Bullet"
    gear.RAbullet = "Adlivun Bullet"
    gear.WSbullet = "Eminent Bullet"
    gear.MAbullet = "Bronze Bullet"
    gear.QDbullet = "Animikii Bullet"
	gear.WScape = "Gunslinger's Cape"
	gear.PRcape = "Camulus's Mantle"
    options.ammo_warning_limit = 20

	gear.weaponskill_waist = "Fotia Belt"
	gear.weaponskill_neck = "Fotia Gorget"
    
	set_lockstyle('4')
end


-- Called when this job file is unloaded (eg: job change)
function user_unload()

end

-- Define sets and vars used by this job file.
function init_gear_sets()
	--------------------------------------
	-- Start defining the sets
	--------------------------------------
	organizer_items = {
		echos="Echo Drops",
		shihei="Shihei",
		orb="Macrocosmic Orb",
		atoyac="Atoyac",
		vanir="Vanir Knife",
		degen="Demersal Degen +1",
		arendsi="Arendsi Fleuret",
		fetter="Fettering Blade",
		ebullet="Eminent Bullet",
		adlivun="Adlivun Bullet",
		bronze="Bronze Bullet",
		doomsday="Doomsday",
		compensator="Compensator",
		trump="Trump Card",
		capring="Capacity Ring"
	}
	-- Precast Sets

	-- Precast sets to enhance JAs
	
	sets.precast.JA['Triple Shot'] = {body="Chasseur's Frac +1"}
	sets.precast.JA['Snake Eye'] = {legs="Lanun Culottes +1"}
	sets.precast.JA['Wild Card'] = {feet="Lanun Bottes +1"} 
	sets.precast.JA['Random Deal'] = {body="Lanun Frac +1"}
	
	sets.Obi = {waist="Hachirin-no-Obi"}

	sets.precast.CorsairRoll = {head="Lanun Tricorne +1",hands="Chasseur's Gants +1", ring2="Barataria Ring", legs="Desultor Tassets", back=gear.PRcape}
	
	sets.precast.CorsairRoll["Caster's Roll"] = set_combine(sets.precast.CorsairRoll, {}) -- need > legs="Chas. Culottes +1" 
	sets.precast.CorsairRoll["Courser's Roll"] = set_combine(sets.precast.CorsairRoll, {feet="Chasseur's Bottes +1"})
	sets.precast.CorsairRoll["Blitzer's Roll"] = set_combine(sets.precast.CorsairRoll, {}) -- need > head="Chass. Tricorne +1"
	sets.precast.CorsairRoll["Tactician's Roll"] = set_combine(sets.precast.CorsairRoll, {body="Chasseur's Frac +1"})
	sets.precast.CorsairRoll["Allies' Roll"] = set_combine(sets.precast.CorsairRoll, {hands="Chasseur's Gants +1"})
	
	sets.precast.LuzafRing = {ring1="Luzaf's Ring"}
	sets.precast.FoldDoubleBust = {hands="Lanun Gants +1"}
	
	sets.precast.CorsairShot = {feet="Chasseur's Bottes +1"}
	
	-- Waltz set (chr and vit)
	sets.precast.Waltz = {}
		
	-- Don't need any special gear for Healing Waltz.
	sets.precast.Waltz['Healing Waltz'] = {}

	-- Fast cast sets for spells
	
	sets.precast.FC = {
		ammo="Impatiens",
		left_ear="Enchntr. Earring +1",
		right_ear="Loquac. Earring",
		left_ring="Prolix Ring",
		right_ring="Veneficium Ring",
	}

	sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck="Magoraga Beads"})

	-- Racc
	sets.precast.RA = {
		ammo=gear.RAbullet,
		head="Pursuer's Beret",
		body={ name="Pursuer's Doublet", augments={'HP+50','Crit. hit rate+4%','"Snapshot"+6',}},
		hands={ name="Floral Gauntlets", augments={'Rng.Acc.+15','Accuracy+15','"Triple Atk."+3','Magic dmg. taken -4%',}},
		legs={ name="Pursuer's Pants", augments={'AGI+10','"Rapid Shot"+10','"Subtle Blow"+7',}},
		feet={ name="Pursuer's Gaiters", augments={'Rng.Acc.+10','"Rapid Shot"+10','"Recycle"+15',}},
		neck="Marked Gorget",
		waist="Aquiline Belt",
		left_ear="Volley Earring",
		right_ear="Enervating Earring",
		left_ring="Cacoethic Ring +1",
		right_ring="Paqichikaji Ring",
		back={ name="Gunslinger's Cape", augments={'Enmity-4','"Mag.Atk.Bns."+4','"Phantom Roll" ability delay -1','Weapon skill damage +2%',}},
	}

       
	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined
	sets.precast.WS = {
		head={ name="Adhemar Bonnet", augments={'DEX+10','AGI+10','Accuracy+15',}},
		body={ name="Adhemar Jacket", augments={'DEX+10','AGI+10','Accuracy+15',}},
		hands={ name="Herculean Gloves", augments={'Accuracy+21 Attack+21','"Triple Atk."+3','STR+9','Accuracy+15','Attack+9',}},
		legs={ name="Herculean Trousers", augments={'Accuracy+24 Attack+24','DEX+9','Accuracy+3',}},
		feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','Attack+7',}},
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Steelflash Earring",
		right_ear="Bladeborn Earring",
		left_ring="Cacoethic Ring +1",
		right_ring="Rajas Ring",
		back="Bleating Mantle",
	}

	-- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
	
	-- DEX - Shadow, Soil, Light
	sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS, {
		
	})
	
	-- AGI - Breeze, Soil, Thunder
	sets.precast.WS['Exenterator'] = set_combine(sets.precast.WS, {
		
	})

	-- MND - Breeze, Soil, Thunder
	sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, {
		
	})

	-- AGI - Flame, Aqua, Light
	sets.precast.WS['Last Stand'] = set_combine(sets.precast.RA, {
		ammo=gear.WSbullet,
		neck="Fotia Gorget",
		waist="Fotia Belt",
		back={ name="Gunslinger's Cape", augments={'Enmity-4','"Mag.Atk.Bns."+4','"Phantom Roll" ability delay -1','Weapon skill damage +2%',}},
	})

	sets.precast.WS['Last Stand'].Acc = set_combine(sets.precast.WS['Last Stand'], { })

	-- MAB, AGI, INT
	sets.precast.WS['Wildfire'] = {
		ammo=gear.MAbullet,
		head={ name="Herculean Helm", augments={'Mag. Acc.+16 "Mag.Atk.Bns."+16','Crit. hit damage +2%','STR+3','Mag. Acc.+15','"Mag.Atk.Bns."+11',}},
		body={ name="Samnuha Coat", augments={'Mag. Acc.+11','"Mag.Atk.Bns."+10','"Fast Cast"+3',}},
		hands={ name="Leyline Gloves", augments={'Accuracy+15','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+3',}},
		legs={ name="Herculean Trousers", augments={'"Mag.Atk.Bns."+25','STR+2','Mag. Acc.+17 "Mag.Atk.Bns."+17',}},
		feet={ name="Herculean Boots", augments={'Mag. Acc.+17 "Mag.Atk.Bns."+17','"Store TP"+1','STR+1','"Mag.Atk.Bns."+15',}},
		neck="Sanctity Necklace",
		waist="Fotia Belt",
		left_ear="Friomisi Earring",
		right_ear="Moonshade Earring",
		left_ring="Fenrir Ring +1",
		right_ring="Acumen Ring",
		back={ name="Gunslinger's Cape", augments={'Enmity-4','"Mag.Atk.Bns."+4','"Phantom Roll" ability delay -1','Weapon skill damage +2%',}},
	}

	sets.precast.WS['Wildfire'].Brew = set_combine(sets.precast.WS['Wildfire'], {})

	-- MAB
	sets.precast.WS['Leaden Salute'] = set_combine(sets.precast.WS['Wildfire'], {
		head="Pixie Hairpin +1",
		legs={ name="Herculean Trousers", augments={'"Mag.Atk.Bns."+25','STR+2','Mag. Acc.+17 "Mag.Atk.Bns."+17',}},
		ring2="Archon Ring"
	})

	-- MAB, DEX, INT
	sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS['Wildfire'], {})


	-- Midcast Sets
	-- QuickDraw: equip MAB, AGI, INT 
	sets.midcast.CorsairShot = set_combine(sets.precast.CorsairShot, {
		ammo=gear.QDbullet,
		head={ name="Herculean Helm", augments={'Mag. Acc.+16 "Mag.Atk.Bns."+16','Crit. hit damage +2%','STR+3','Mag. Acc.+15','"Mag.Atk.Bns."+11',}},
		body={ name="Samnuha Coat", augments={'Mag. Acc.+11','"Mag.Atk.Bns."+10','"Fast Cast"+3',}},
		hands={ name="Leyline Gloves", augments={'Accuracy+15','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+3',}},
		legs={ name="Herculean Trousers", augments={'"Mag.Atk.Bns."+25','STR+2','Mag. Acc.+17 "Mag.Atk.Bns."+17',}},
		feet={ name="Herculean Boots", augments={'Mag. Acc.+17 "Mag.Atk.Bns."+17','"Store TP"+1','STR+1','"Mag.Atk.Bns."+15',}},
		neck="Sanctity Necklace",
		waist="Aquiline Belt",
		left_ear="Friomisi Earring",
		right_ear="Hecate's Earring",
		left_ring="Fenrir Ring +1",
		right_ring="Acumen Ring",
		back={ name="Gunslinger's Cape", augments={'Enmity-4','"Mag.Atk.Bns."+4','"Phantom Roll" ability delay -1','Weapon skill damage +2%',}},
	})
	
	sets.midcast.CorsairShot.Acc = set_combine(sets.midcast.CorsairShot, {
		left_ear="Lifestorm Earring",
		right_ear="Psystorm Earring",
		left_ring="Fenrir Ring +1",
		right_ring="Balrahn's Ring",
	})

	sets.midcast.CorsairShot['Light Shot'] = set_combine(sets.midcast.CorsairShot.Acc, {})

	sets.midcast.CorsairShot['Dark Shot'] = set_combine(sets.midcast.CorsairShot.Acc, {
		ring2="Archon Ring"
	})
	
	-- Haste & FC
	sets.midcast.FastRecast = {}

	-- Specific spells
	sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {})

	
	-- Ranged gear
	-- need to update this to be a good mix of racc and ratt
	sets.midcast.RA = set_combine(sets.precast.RA, {})
	
	sets.midcast.TS = set_combine(sets.midcast.RA, {})
	
	-- need to update this to all racc
	sets.midcast.RA.Acc = set_combine(sets.precast.RA, {})

	
	-- Sets to return to when not performing an action.
	
	-- Idle sets
	sets.idle = {
		ammo=gear.RAbullet,
		head={ name="Dampening Tam", augments={'DEX+9','Accuracy+13','Mag. Acc.+14','Quadruple Attack +2',}},
		body="Mekosu. Harness",
		hands={ name="Floral Gauntlets", augments={'Rng.Acc.+15','Accuracy+15','"Triple Atk."+3','Magic dmg. taken -4%',}},
		legs={ name="Herculean Trousers", augments={'Accuracy+24 Attack+24','DEX+9','Accuracy+3',}},
		feet="Skd. Jambeaux +1",
		neck="Sanctity Necklace",
		waist="Flume Belt +1",
		left_ear="Infused Earring",
		right_ear="Etiolation Earring",
		left_ring="Sheltered Ring",
		right_ring="Paguroidea Ring",
		back="Xucau Mantle",
	}

	sets.idle.Town = set_combine(sets.idle, {})

	-- Resting sets
	sets.resting = set_combine(sets.idle, {})
	
	-- Defense sets
	sets.defense.PDT = {}

	sets.defense.MDT = {}


	sets.Kiting = {feet="Skadi's Jambeaux +1"}
	-- buff sets
	sets.buff['Triple Shot'] = {body="Chasseur's Frac +1"}
	
	-- Engaged sets

	-- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
	-- sets if more refined versions aren't defined.
	-- If you create a set with both offense and defense modes, the offense mode should be first.
	-- EG: sets.engaged.Dagger.Accuracy.Evasion

	-- Normal melee group
	sets.engaged.Melee = { 
		ammo=gear.RAbullet,
		head={ name="Taeon Chapeau", augments={'Accuracy+18','"Dual Wield"+4','STR+7 AGI+7',}},
		body={ name="Adhemar Jacket", augments={'DEX+10','AGI+10','Accuracy+15',}},
		hands={ name="Herculean Gloves", augments={'Accuracy+21 Attack+21','"Triple Atk."+3','STR+9','Accuracy+15','Attack+9',}},
		legs="Samnuha Tights",
		feet={ name="Rawhide Boots", augments={'HP+50','Accuracy+15','Evasion+20',}},
		neck="Clotharius Torque",
		waist="Windbuffet Belt +1",
		left_ear="Dudgeon Earring",
		right_ear="Heartseeker Earring",
		left_ring="Hetairoi Ring",
		right_ring="Epona's Ring",
		back="Bleating Mantle",
	}

	sets.engaged.Acc = { 
		ammo=gear.RAbullet,
		head={ name="Dampening Tam", augments={'DEX+9','Accuracy+13','Mag. Acc.+14','Quadruple Attack +2',}},
		body={ name="Adhemar Jacket", augments={'DEX+10','AGI+10','Accuracy+15',}},
		hands={ name="Herculean Gloves", augments={'Accuracy+21 Attack+21','"Triple Atk."+3','STR+9','Accuracy+15','Attack+9',}},
		legs={ name="Herculean Trousers", augments={'Accuracy+24 Attack+24','DEX+9','Accuracy+3',}},
		feet={ name="Rawhide Boots", augments={'HP+50','Accuracy+15','Evasion+20',}},
		neck="Sanctity Necklace",
		waist="Kentarch Belt +1",
		left_ear="Dudgeon Earring",
		right_ear="Heartseeker Earring",
		left_ring="Cacoethic Ring +1",
		right_ring="Patricius Ring",
		back="Sokolski Mantle",
	}

	sets.engaged.Melee.DW = set_combine(sets.engaged.Melee, {})

	sets.engaged.Acc.DW = set_combine(sets.engaged.Acc, {})

	sets.engaged.Ranged = set_combine(sets.precast.RA, {})

	-- Max Ranged Acc where you can and fill in agi/ranged attack everywhere else.
	sets.engaged.TS = set_combine(sets.precast.RA, {
		
	})
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
	-- Check that proper ammo is available if we're using ranged attacks or similar.
    if spell.action_type == 'Ranged Attack' or spell.type == 'WeaponSkill' or spell.type == 'CorsairShot' then
        do_bullet_checks(spell, spellMap, eventArgs)
    end
	
    -- gear sets	
    if (spell.type == 'CorsairRoll' or spell.english == "Double-Up") and state.LuzafRing.value then
        equip(sets.precast.LuzafRing)
    elseif spell.type == 'CorsairShot' and state.CastingMode.value == 'Resistant' then
			classes.CustomClass = 'Acc'
    elseif spell.english == 'Fold' and buffactive['Bust'] == 2 then
        if sets.precast.FoldDoubleBust then
            equip(sets.precast.FoldDoubleBust)
            eventArgs.handled = true
        end
    end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
	-- Equip obi if QD element is the same as weather or day.
	if spell.type == 'CorsairShot' then
		if (world.weather_element == spell.element) or (world.day_element == spell.element) then
			equip(set_combine(sets.precast.CorsairShot, sets.Obi))
		end
	end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if state.ShowRollInfo == 'ON' and spell.type == 'CorsairRoll' and not spell.interrupted then
        display_roll_info(spell)
    end
end

-- Called any time we attempt to handle automatic gear equips (ie: engaged or idle gear).
function job_handle_equipping_gear(playerStatus, eventArgs)    	
	if player.equipment.back == 'Mecisto. Mantle' or player.equipment.back == 'Aptitude Mantle' or player.equipment.back == 'Aptitude Mantle +1' then
		disable('back')
	else
		enable('back')
	end
end
-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Return a customized weaponskill mode to use for weaponskill sets.
-- Don't return anything if you're not overriding the default value.
function get_custom_wsmode(spell, spellMap, default_wsmode)
    if buffactive['Transcendancy'] then
        return 'Brew'
    end
end


-- Called by the 'update' self-command, for common needs.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(cmdParams, eventArgs)
    if newStatus == 'Engaged' and player.equipment.main == 'Chatoyant Staff' then
        state.OffenseMode:set('Ranged')
    end
end


-- Set eventArgs.handled to true if we don't want the automatic display to be run.
function display_current_job_state(eventArgs)
    local msg = ''
    
    msg = msg .. 'Off.: '..state.OffenseMode.current
    msg = msg .. ', Rng.: '..state.RangedMode.current
    msg = msg .. ', WS.: '..state.WeaponskillMode.current
    msg = msg .. ', QD.: '..state.CastingMode.current

    if state.DefenseMode.value ~= 'None' then
        local defMode = state[state.DefenseMode.value ..'DefenseMode'].current
        msg = msg .. ', Defense: '..state.DefenseMode.value..' '..defMode
    end
    
    if state.Kiting.value then
        msg = msg .. ', Kiting'
    end
    
    if state.PCTargetMode.value ~= 'default' then
        msg = msg .. ', Target PC: '..state.PCTargetMode.value
    end

    if state.SelectNPCTargets.value then
        msg = msg .. ', Target NPCs'
    end

    msg = msg .. ', Roll Size: ' .. (state.LuzafRing.value and 'Large') or 'Small'
    
    add_to_chat(122, msg)

    eventArgs.handled = true
end


-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

function define_roll_values()
    rolls = {
        ["Corsair's Roll"]   = {lucky=5, unlucky=9, bonus="Experience Points"},
        ["Ninja Roll"]       = {lucky=4, unlucky=8, bonus="Evasion"},
        ["Hunter's Roll"]    = {lucky=4, unlucky=8, bonus="Accuracy"},
        ["Chaos Roll"]       = {lucky=4, unlucky=8, bonus="Attack"},
        ["Magus's Roll"]     = {lucky=2, unlucky=6, bonus="Magic Defense"},
        ["Healer's Roll"]    = {lucky=3, unlucky=7, bonus="Cure Potency Received"},
        ["Puppet Roll"]      = {lucky=4, unlucky=8, bonus="Pet Magic Accuracy/Attack"},
        ["Choral Roll"]      = {lucky=2, unlucky=6, bonus="Spell Interruption Rate"},
        ["Monk's Roll"]      = {lucky=3, unlucky=7, bonus="Subtle Blow"},
        ["Beast Roll"]       = {lucky=4, unlucky=8, bonus="Pet Attack"},
        ["Samurai Roll"]     = {lucky=2, unlucky=6, bonus="Store TP"},
        ["Evoker's Roll"]    = {lucky=5, unlucky=9, bonus="Refresh"},
        ["Rogue's Roll"]     = {lucky=5, unlucky=9, bonus="Critical Hit Rate"},
        ["Warlock's Roll"]   = {lucky=4, unlucky=8, bonus="Magic Accuracy"},
        ["Fighter's Roll"]   = {lucky=5, unlucky=9, bonus="Double Attack Rate"},
        ["Drachen Roll"]     = {lucky=3, unlucky=7, bonus="Pet Accuracy"},
        ["Gallant's Roll"]   = {lucky=3, unlucky=7, bonus="Defense"},
        ["Wizard's Roll"]    = {lucky=5, unlucky=9, bonus="Magic Attack"},
        ["Dancer's Roll"]    = {lucky=3, unlucky=7, bonus="Regen"},
        ["Scholar's Roll"]   = {lucky=2, unlucky=6, bonus="Conserve MP"},
        ["Bolter's Roll"]    = {lucky=3, unlucky=9, bonus="Movement Speed"},
        ["Caster's Roll"]    = {lucky=2, unlucky=7, bonus="Fast Cast"},
        ["Courser's Roll"]   = {lucky=3, unlucky=9, bonus="Snapshot"},
        ["Blitzer's Roll"]   = {lucky=4, unlucky=9, bonus="Attack Delay"},
        ["Tactician's Roll"] = {lucky=5, unlucky=8, bonus="Regain"},
        ["Allies's Roll"]    = {lucky=3, unlucky=10, bonus="Skillchain Damage"},
        ["Miser's Roll"]     = {lucky=5, unlucky=7, bonus="Save TP"},
        ["Companion's Roll"] = {lucky=2, unlucky=10, bonus="Pet Regain and Regen"},
        ["Avenger's Roll"]   = {lucky=4, unlucky=8, bonus="Counter Rate"},
        ["Runeist's Roll"]   = {lucky=4, unlucky=8, bonus="Magic Evasion"},
    }
end

function display_roll_info(spell)
    rollinfo = rolls[spell.english]
    local rollsize = (state.LuzafRing.value and 'Large') or 'Small'

    if rollinfo then
        add_to_chat(104, spell.english..' provides a bonus to '..rollinfo.bonus..'.  Roll size: '..rollsize)
        add_to_chat(104, 'Lucky roll is '..tostring(rollinfo.lucky)..', Unlucky roll is '..tostring(rollinfo.unlucky)..'.')
    end
end


-- Determine whether we have sufficient ammo for the action being attempted.
function do_bullet_checks(spell, spellMap, eventArgs)
    local bullet_name
    local bullet_min_count = 1
    
    if spell.type == 'WeaponSkill' then
        if spell.skill == "Marksmanship" then
            if spell.element == 'None' then
                -- physical weaponskills
                bullet_name = gear.WSbullet
            else
                -- magical weaponskills
                bullet_name = gear.MAbullet
            end
        else
            -- Ignore non-ranged weaponskills
            return
        end
    elseif spell.type == 'CorsairShot' then
        bullet_name = gear.QDbullet
    elseif spell.action_type == 'Ranged Attack' then
        bullet_name = gear.RAbullet
        if buffactive['Triple Shot'] then
            bullet_min_count = 3
        end
    end
    
    local available_bullets = player.inventory[bullet_name] or player.wardrobe[bullet_name]
    
    -- If no ammo is available, give appropriate warning and end.
    if not available_bullets then
		if spell.type == 'CorsairShot' and player.equipment.ammo ~= 'empty' then
			add_to_chat(8, ' >> No Quick Draw ammo left.  Using what\'s currently equipped ('..player.equipment.ammo..'). <<')
			return
		elseif spell.type == 'WeaponSkill' and player.equipment.ammo == gear.RAbullet then
			add_to_chat(8, ' >> No Weaponskill ammo left.  Using what\'s currently equipped (standard ranged bullets: '..player.equipment.ammo..'). <<')
			return
		elseif spell.action_type == 'Ranged Attack' then	
			local avail_fb_bullets = player.inventory[gear.FallbackBullet] or player.wardrobe[gear.FallbackBullet]
			-- if no FallbackBullet then cancel. 
			if not avail_fb_bullets then
				add_to_chat(8, ' >> Canceled: No ['..gear.RAbullet..'] or ['..gear.FallbackBullet..'] available to Ranged Attack. <<')
				eventArgs.cancel = true
				return
			else
				-- equip the FallbackBullet to perform the RA.
				equip(
					set_combine(sets.precast.RA, {
						ammo=gear.FallbackBullet
					})
				)
				add_to_chat(8, ' >> No Ranged Attack ammo left.  Using the fall back (fall back bullets: '..gear.FallbackBullet..'). <<')
				return
			end
		else
			add_to_chat(8, ' >> No ammo ('..tostring(bullet_name)..') available for that action. <<')
			eventArgs.cancel = true
			return
		end
    end
	
	if spell.type == 'CorsairShot' and player.inventory["Trump Card"] and player.inventory["Trump Card"].count < 10 then
		add_to_chat(8, 'Low on trump cards!')
	end
	
    
    -- Don't allow shooting or weaponskilling with ammo reserved for quick draw.
    if spell.type ~= 'CorsairShot' and bullet_name == gear.QDbullet and available_bullets.count <= bullet_min_count then
        add_to_chat(8, 'No ammo will be left for Quick Draw.  Cancelling.')
        eventArgs.cancel = true
        return
    end
    
    -- Low ammo warning.
    if spell.type ~= 'CorsairShot' and state.warned.value == false
        and available_bullets.count > 1 and available_bullets.count <= options.ammo_warning_limit then
        local msg = '*****  LOW AMMO WARNING: '..bullet_name..' *****'
        --local border = string.repeat("*", #msg)
        local border = ""
        for i = 1, #msg do
            border = border .. "*"
        end
        
        add_to_chat(8, border)
        add_to_chat(8, msg)
        add_to_chat(8, border)

        state.warned:set()
    elseif available_bullets.count > options.ammo_warning_limit and state.warned then
        state.warned:reset()
    end
end


function set_lockstyle(num)
	send_command('wait 2; input /lockstyleset '..num)
end