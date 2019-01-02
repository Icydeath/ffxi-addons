-------------------------------------------------------------------------------------------------------------------
-- (Original: Motenten / Modified: Arislan)
-------------------------------------------------------------------------------------------------------------------

--[[	Custom Features:

		QuickDraw Selector	Cycle through available primary and secondary shot types,
							and trigger with a single macro
		Haste Detection		Detects current magic haste level and equips corresponding engaged set to
							optimize delay reduction (automatic)
		Haste Mode			Toggles between Haste II and Haste I recieved, used by Haste Detection [WinKey-H]
		Capacity Pts. Mode	Capacity Points Mode Toggle [WinKey-C]
		Reive Detection		Automatically equips Reive bonus gear
		Auto. Lockstyle		Automatically locks specified equipset on file load
--]]


-------------------------------------------------------------------------------------------------------------------

--[[

	Custom commands:
	
	gs c qd
		Uses the currently configured shot on the target, with either <t> or <stnpc> depending on setting.

	gs c qd t
		Uses the currently configured shot on the target, but forces use of <t>.
	
	
	Configuration commands:
	
	gs c cycle mainqd
		Cycles through the available steps to use as the primary shot when using one of the above commands.
		
	gs c cycle altqd
		Cycles through the available steps to use for alternating with the configured main shot.
		
	gs c toggle usealtqd
		Toggles whether or not to use an alternate shot.
		
	gs c toggle selectqdtarget
		Toggles whether or not to use <stnpc> (as opposed to <t>) when using a shot.
		
		
	gs c toggle LuzafRing -- Toggles use of Luzaf Ring on and off
	
	Offense mode is melee or ranged.  Used ranged offense mode if you are engaged
	for ranged weaponskills, but not actually meleeing.
	
	Weaponskill mode, if set to 'Normal', is handled separately for melee and ranged weaponskills.
--]]


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
	-- QuickDraw Selector
	state.Mainqd = M{['description']='Primary Shot', 'Dark Shot', 'Earth Shot', 'Water Shot', 'Wind Shot', 'Fire Shot', 'Ice Shot', 'Thunder Shot'}
	state.Altqd = M{['description']='Secondary Shot', 'Earth Shot', 'Water Shot', 'Wind Shot', 'Fire Shot', 'Ice Shot', 'Thunder Shot', 'Dark Shot'}
	state.UseAltqd = M(false, 'Use Secondary Shot')
	state.SelectqdTarget = M(false, 'Select Quick Draw Target')
	state.IgnoreTargetting = M(false, 'Ignore Targetting')
	state.HasteMode = M{['description']='Haste Mode', 'Haste II', 'Haste I'}

	state.Currentqd = M{['description']='Current Quick Draw', 'Main', 'Alt'}
	
	-- Whether to use Luzaf's Ring
	state.LuzafRing = M(true, "Luzaf's Ring")
	-- Whether a warning has been given for low ammo
	state.warned = M(false)

	define_roll_values()
	determine_haste_group()

end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
	state.OffenseMode:options('STP', 'Normal', 'LowAcc', 'MidAcc', 'HighAcc')
	state.RangedMode:options('STP', 'Normal', 'Acc', 'Critical')
	state.WeaponskillMode:options('Normal', 'Acc')
	state.CastingMode:options('Normal', 'Resistant')
	state.IdleMode:options('Normal', 'DT')

	state.WeaponLock = M(false, 'Weapon Lock')	
	state.CP = M(false, "Capacity Points Mode")

	gear.PRCape = "Camulus's Mantle"
	gear.RAbullet = "Adlivun Bullet"
	gear.WSbullet = "Eminent Bullet"
	gear.MAbullet = "Orichalc. Bullet"
	gear.QDbullet = "Orichalc. Bullet"
	options.ammo_warning_limit = 10
	
	-- Set to 1 to turn on; Set to 0 to turn off
	options.send_ammo_warning = 1 
	options.send_ammo_warning_to = "Icydeath"
	
	
	-- Additional local binds
	send_command('bind ^` input /ja "Double-up" <me>')
	send_command('bind !` input /ja "Bolter\'s Roll" <me>')
	send_command ('bind @` gs c toggle LuzafRing')

	send_command('bind ^- gs c cycleback mainqd')
	send_command('bind ^= gs c cycle mainqd')
	send_command('bind !- gs c cycle altqd')
	send_command('bind != gs c cycleback altqd')
	send_command('bind ^[ gs c toggle selectqdtarget')
	send_command('bind ^] gs c toggle usealtqd')

	if player.sub_job == 'DNC' then
		send_command('bind ^, input /ja "Spectral Jig" <me>')
		send_command('unbind ^.')
	elseif player.sub_job == "RDM" or player.sub_job == "WHM" then
		send_command('bind ^, input /ma "Sneak" <stpc>')
		send_command('bind ^. input /ma "Invisible" <stpc>')
	else
		send_command('bind ^, input /item "Silent Oil" <me>')
		send_command('bind ^. input /item "Prism Powder" <me>')
	end

	send_command('bind @c gs c toggle CP')
	send_command('bind @h gs c cycle HasteMode')
	send_command('bind @w gs c toggle WeaponLock')

	--select_default_macro_book()
	set_lockstyle('1')
end


-- Called when this job file is unloaded (eg: job change)
function user_unload()
	send_command('unbind ^`')
	send_command('unbind !`')
	send_command('unbind @`')
	send_command('unbind ^-')
	send_command('unbind ^=')
	send_command('unbind !-')
	send_command('unbind !=')
	send_command('unbind ^[')
	send_command('unbind ^]')
	send_command('unbind ^,')
	send_command('unbind @c')
	send_command('unbind @h')
	send_command('unbind @w')
end

-- Define sets and vars used by this job file.
function init_gear_sets()
	
	organizer_items = {
		echos="Echo Drops",
		shihei="Shihei",
		orb="Macrocosmic Orb",
		capring="Capacity Ring",
		
		doomsday="Doomsday",
		compensator="Compensator",
		atoyac="Atoyac",
		vanir="Vanir Knife",
		degen="Demersal Degen +1",
		arendsi="Arendsi Fleuret",
		fetter="Fettering Blade",
		
		trump="Trump Card",
		ebullet="Eminent Bullet",
		adlivun="Adlivun Bullet",
		bullet="Bullet",
		mabullet = "Orichalc. Bullet"
	}
	
	------------------------------------------------------------------------------------------------
	---------------------------------------- Precast Sets ------------------------------------------
	------------------------------------------------------------------------------------------------

	sets.precast.JA['Snake Eye'] = {legs="Lanun Culottes"}
	sets.precast.JA['Wild Card'] = {}--feet="Lanun Bottes"
	sets.precast.JA['Random Deal'] = {body="Lanun Frac"}

	
	sets.precast.CorsairRoll = {head="Lanun Tricorne",hands="Chasseur's Gants", ring2="Barataria Ring", legs="Desultor Tassets", back=gear.PRcape}
	
	sets.precast.CorsairRoll["Caster's Roll"] = set_combine(sets.precast.CorsairRoll, {legs="Chas. Culottes" })
	sets.precast.CorsairRoll["Courser's Roll"] = set_combine(sets.precast.CorsairRoll, {feet="Chasseur's Bottes"})
	sets.precast.CorsairRoll["Blitzer's Roll"] = set_combine(sets.precast.CorsairRoll, {head="Chass. Tricorne"})
	sets.precast.CorsairRoll["Tactician's Roll"] = set_combine(sets.precast.CorsairRoll, {body="Chasseur's Frac"})
	sets.precast.CorsairRoll["Allies' Roll"] = set_combine(sets.precast.CorsairRoll, {hands="Chasseur's Gants"})
	
	sets.precast.LuzafRing = {ring1="Luzaf's Ring"}
	sets.precast.FoldDoubleBust = {hands="Lanun Gants"}
	
	sets.precast.CorsairShot = {ammo=gear.QDbullet, head="Corsair's Tricorne", feet="Chasseur's Bottes"}

	sets.precast.Waltz = {
	}

	sets.precast.Waltz['Healing Waltz'] = {}
	
	sets.precast.FC = {
	
	}

	sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck="Magoraga Beads"})

	-- Snapshot
	sets.precast.RA = {
		ammo=gear.RAbullet,
		hands="Lanun Gants",
		legs="Lanun Culottes",
		feet="Meg. Jambeaux"
	}

	   
	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined
	sets.precast.WS = {
		ammo=gear.WSbullet,
		head={ name="Herculean Helm", augments={'Accuracy+24 Attack+24','"Triple Atk."+2','STR+14','Accuracy+14',}},
		body="Mummu Jacket",
		hands={ name="Herculean Gloves", augments={'Accuracy+23 Attack+23','"Dual Wield"+1','AGI+3','Accuracy+7','Attack+13',}},
		legs="Mummu Kecks",
		feet={ name="Herculean Boots", augments={'Accuracy+15 Attack+15','"Triple Atk."+2','Accuracy+9',}},
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Suppanomimi",
		right_ear="Mache Earring",
		left_ring="Enlivened Ring",
		right_ring="Epona's Ring",
		back={ name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10',}},
	}
	
	sets.precast.WS.Acc = set_combine(sets.precast.WS, {
		waist="Kwahu Kachina Belt",
	})


	------------------------------------------------------------------------------------------------
	------------------------------------- Weapon Skill Sets ----------------------------------------
	------------------------------------------------------------------------------------------------

	sets.precast.WS["Last Stand"] = {
		ammo=gear.WSbullet,
		head="Mummu Bonnet",
		body="Mummu Jacket",
		hands={ name="Floral Gauntlets", augments={'Rng.Acc.+11','Accuracy+5','"Triple Atk."+2',}},
		legs="Mummu Kecks",
		feet="Meg. Jambeaux",
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Clearview Earring",
		right_ear="Neritic Earring",
		left_ring="Longshot Ring",
		right_ring="Jaeger Ring",
		back={ name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10',}},
	}

	sets.precast.WS['Last Stand'].Acc = set_combine(sets.precast.WS['Last Stand'], {
		waist="Kwahu Kachina Belt",
	})

	sets.precast.WS['Wildfire'] = {
		ammo=gear.MAbullet,
		head={ name="Herculean Helm", augments={'"Mag.Atk.Bns."+24','STR+3','Mag. Acc.+15 "Mag.Atk.Bns."+15',}},
		body={ name="Samnuha Coat", augments={'Mag. Acc.+3','"Mag.Atk.Bns."+2','"Fast Cast"+2',}},
		hands={ name="Leyline Gloves", augments={'Accuracy+2','Mag. Acc.+5','"Mag.Atk.Bns."+4',}},
		legs={ name="Herculean Trousers", augments={'Accuracy+21','"Triple Atk."+1','MND+3','Attack+3',}},
		feet={ name="Herculean Boots", augments={'Mag. Acc.+18','Weapon skill damage +4%','STR+3','"Mag.Atk.Bns."+11',}},
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Novio Earring",
		right_ear="Friomisi Earring",
		left_ring="Perception Ring",
		right_ring="Acumen Ring",
		back="Izdubar Mantle",
	}
	
	sets.precast.WS['Leaden Salute'] = 	{
		ammo=gear.MAbullet,
		head={ name="Herculean Helm", augments={'"Mag.Atk.Bns."+24','STR+3','Mag. Acc.+15 "Mag.Atk.Bns."+15',}},
		body={ name="Samnuha Coat", augments={'Mag. Acc.+3','"Mag.Atk.Bns."+2','"Fast Cast"+2',}},
		hands={ name="Leyline Gloves", augments={'Accuracy+2','Mag. Acc.+5','"Mag.Atk.Bns."+4',}},
		legs={ name="Herculean Trousers", augments={'Accuracy+21','"Triple Atk."+1','MND+3','Attack+3',}},
		feet={ name="Herculean Boots", augments={'Mag. Acc.+18','Weapon skill damage +4%','STR+3','"Mag.Atk.Bns."+11',}},
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Novio Earring",
		right_ear="Friomisi Earring",
		left_ring="Perception Ring",
		right_ring="Acumen Ring",
		back="Izdubar Mantle",
	}

	sets.precast.WS['Leaden Salute'].FullTP = {}
		
	sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS, {
		
	})

	sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {
		
	})
		
	sets.precast.WS['Savage Blade'].Acc = set_combine(sets.precast.WS['Savage Blade'], {
	
	})

	sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS['Savage Blade'], {
	
	}) --MND

	sets.precast.WS['Requiescat'].Acc = set_combine(sets.precast.WS['Requiescat'], {
	
	})


	------------------------------------------------------------------------------------------------
	---------------------------------------- Midcast Sets ------------------------------------------
	------------------------------------------------------------------------------------------------

	sets.midcast.FastRecast = sets.precast.FC

	sets.midcast.SpellInterrupt = {}

	sets.midcast.Cure = {}	

	sets.midcast.Utsusemi = sets.midcast.SpellInterrupt

	sets.midcast['Dark Magic'] = {}

	sets.midcast.CorsairShot = set_combine(sets.precast.WS['Wildfire'], {
		ammo=gear.QDbullet,
	})

	sets.midcast.CorsairShot.Resistant = set_combine(sets.midcast.CorsairShot, {})

	sets.midcast.CorsairShot['Light Shot'] = sets.midcast.CorsairShot.Resistant
	sets.midcast.CorsairShot['Dark Shot'] = sets.midcast.CorsairShot.Resistant


	-- Ranged gear
	sets.midcast.RA = {
		ammo=gear.RAbullet,	
		head="Mummu Bonnet",
		body="Mummu Jacket",
		hands={ name="Floral Gauntlets", augments={'Rng.Acc.+11','Accuracy+5','"Triple Atk."+2',}},
		legs="Mummu Kecks",
		feet="Meg. Jambeaux",
		neck="Sanctity Necklace",
		waist="Kwahu Kachina Belt",
		left_ear="Clearview Earring",
		right_ear="Neritic Earring",
		left_ring="Longshot Ring",
		right_ring="Jaeger Ring",
		back={ name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10',}},
	}

	sets.midcast.RA.Acc = set_combine(sets.midcast.RA, {
		
	})

	sets.midcast.RA.Critical = set_combine(sets.midcast.RA.Acc, {
		
	})

	sets.midcast.RA.STP = set_combine(sets.midcast.RA, {
		
	})


	------------------------------------------------------------------------------------------------
	----------------------------------------- Idle Sets --------------------------------------------
	------------------------------------------------------------------------------------------------

	sets.resting = {}

	sets.idle = {
		ammo=gear.RAbullet,
		head="Dampening Tam",
		body={ name="Lanun Frac", augments={'Enhances "Loaded Deck" effect',}},
		hands={ name="Herculean Gloves", augments={'Accuracy+23 Attack+23','"Dual Wield"+1','AGI+3','Accuracy+7','Attack+13',}},
		legs="Mummu Kecks",
		feet={ name="Herculean Boots", augments={'Accuracy+15 Attack+15','"Triple Atk."+2','Accuracy+9',}},
		neck="Sanctity Necklace",
		waist="Kwahu Kachina Belt",
		left_ear="Suppanomimi",
		right_ear="Eabani Earring",
		left_ring="Enlivened Ring",
		right_ring="Sheltered Ring",
		back="Solemnity Cape",
	}

	sets.idle.DT = set_combine (sets.idle, {
	
	})

	sets.idle.Town = set_combine(sets.idle, {
	
	})


	------------------------------------------------------------------------------------------------
	---------------------------------------- Defense Sets ------------------------------------------
	------------------------------------------------------------------------------------------------

	sets.defense.PDT = sets.idle.DT
	sets.defense.MDT = sets.idle.DT

	sets.Kiting = {}


	------------------------------------------------------------------------------------------------
	---------------------------------------- Engaged Sets ------------------------------------------
	------------------------------------------------------------------------------------------------

	-- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
	-- sets if more refined versions aren't defined.
	-- If you create a set with both offense and defense modes, the offense mode should be first.
	-- EG: sets.engaged.Dagger.Accuracy.Evasion

	-- * DNC Subjob DW Trait: +15%
	-- * NIN Subjob DW Trait: +25%
	
	-- No Magic Haste (74% DW to cap)
	sets.engaged = {
		head="Dampening Tam",
		body="Mummu Jacket",
		hands={ name="Floral Gauntlets", augments={'Rng.Acc.+11','Accuracy+5','"Triple Atk."+2',}},
		legs="Samnuha Tights",
		feet={ name="Taeon Boots", augments={'Accuracy+17','"Triple Atk."+1',}},
		neck="Clotharius Torque",
		waist="Windbuffet Belt +1",
		left_ear="Suppanomimi",
		right_ear="Eabani Earring",
		left_ring="Enlivened Ring",
		right_ring="Epona's Ring",
		back={ name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10',}},
	}

	sets.engaged.LowAcc = set_combine(sets.engaged, {
		
	})

	sets.engaged.MidAcc = set_combine(sets.engaged.LowAcc, {
		
	})

	sets.engaged.HighAcc = set_combine(sets.engaged.MidAcc, {
	
	})

	sets.engaged.STP = set_combine(sets.engaged, {
		
	})

	-- 15% Magic Haste (67% DW to cap)
	sets.engaged.LowHaste = set_combine(sets.engaged, {
		
	})
	
	sets.engaged.LowAcc.LowHaste = set_combine(sets.engaged.LowHaste, {
		
	})

	sets.engaged.MidAcc.LowHaste = set_combine(sets.engaged.LowAcc.LowHaste, {
		
	})

	sets.engaged.HighAcc.LowHaste = set_combine(sets.engaged.MidAcc.LowHaste, {
		
	})

	sets.engaged.STP.LowHaste = set_combine(sets.engaged.LowHaste, {
		
	})

	-- 30% Magic Haste (56% DW to cap)
	sets.engaged.MidHaste = set_combine(sets.engaged, {
		
	})

	sets.engaged.LowAcc.MidHaste = set_combine(sets.engaged.MidHaste, {
	
	})

	sets.engaged.MidAcc.MidHaste = set_combine(sets.engaged.LowAcc.MidHaste, {
	
	})

	sets.engaged.HighAcc.MidHaste = set_combine(sets.engaged.MidAcc.MidHaste, {
	
	})

	sets.engaged.STP.MidHaste = set_combine(sets.engaged.MidHaste, {
		
	})

	-- 35% Magic Haste (51% DW to cap)
	sets.engaged.HighHaste = set_combine(sets.engaged, {
		
	})

	sets.engaged.LowAcc.HighHaste = set_combine(sets.engaged.HighHaste, {
	
	})

	sets.engaged.MidAcc.HighHaste = set_combine(sets.engaged.LowAcc.HighHaste, {
	
	})

	sets.engaged.HighAcc.HighHaste = set_combine(sets.engaged.MidAcc.HighHaste, {
	
	})

	sets.engaged.STP.HighHaste = set_combine(sets.engaged.HighHaste, {
	
	})
		
	-- 47% Magic Haste (36% DW to cap)
	sets.engaged.MaxHaste = set_combine(sets.engaged, {
		
	})

	sets.engaged.LowAcc.MaxHaste = set_combine(sets.engaged.MaxHaste, {
	
	})

	sets.engaged.MidAcc.MaxHaste = set_combine(sets.engaged.LowAcc.MaxHaste, {
	
	})

	sets.engaged.HighAcc.MaxHaste = set_combine(sets.engaged.MidAcc.MaxHaste, {
	
	})

	sets.engaged.STP.MaxHaste = set_combine(sets.engaged.MaxHaste, {
	
	})

	sets.buff.Doom = {waist="Gishdubar Sash"}

	sets.TripleShot = {body="Chasseur's Frac"}
	sets.Obi = {waist="Hachirin-no-Obi"}
	sets.CP = {back="Mecisto. Mantle"}
	sets.Reive = {neck="Ygnas's Resolve +1"}

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
	end
	
	if spell.english == 'Fold' and buffactive['Bust'] == 2 then
		if sets.precast.FoldDoubleBust then
			equip(sets.precast.FoldDoubleBust)
			eventArgs.handled = true
		end
	end
end

function job_post_precast(spell, action, spellMap, eventArgs)
	-- Equip obi if weather/day matches for WS/Quick Draw.
	if spell.type == 'WeaponSkill' then
		if spell.english == 'Leaden Salute' then
			if world.weather_element == 'Dark' or world.day_element == 'Dark' then
				equip(sets.Obi)
			end
			if player.tp > 2900 then
				equip(sets.precast.WS['Leaden Salute'].FullTP)
			end	
		elseif spell.english == 'Wildfire' and (world.weather_element == 'Fire' or world.day_element == 'Fire') then
			equip(sets.Obi)
		end
	end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
	if spell.action_type == 'Ranged Attack' and buffactive['Triple Shot'] then
		equip(sets.TripleShot)
	end
	if spell.type == 'WeaponSkill' or spell.type == 'CorsairShot' then
		if spell.english ~= "Light Shot" and spell.english ~= "Dark Shot" then
			equip(sets.Obi)
		end
	end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
	if spell.type == 'CorsairRoll' and not spell.interrupted then
		display_roll_info(spell)
	end
end

function job_buff_change(buff,gain)
	-- If we gain or lose any haste buffs, adjust which gear set we target.
	if S{'haste', 'march', 'mighty guard', 'embrava', 'haste samba', 'geo-haste', 'indi-haste'}:contains(buff:lower()) then
		determine_haste_group()
		if not midaction() then
			handle_equipping_gear(player.status)
		end
	end

	if buffactive['Reive Mark'] then
		equip(sets.Reive)
		disable('neck')
	else
		enable('neck')
	end

	if buff == "doom" then
		if gain then		   
			equip(sets.buff.Doom)
			send_command('@input /p Doomed.')
			disable('ring1','ring2','waist')
		else
			enable('ring1','ring2','waist')
			handle_equipping_gear(player.status)
		end
	end

end

-- Handle notifications of general user state change.
function job_state_change(stateField, newValue, oldValue)
	if state.WeaponLock.value == true then
		disable('ranged')
	else
		enable('ranged')
	end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
	if state.CP.current == 'on' then
		equip(sets.CP)
		disable('back')
	else
		enable('back')
	end
	return idleSet
end

-- Return a customized weaponskill mode to use for weaponskill sets.
-- Don't return anything if you're not overriding the default value.

function job_update(cmdParams, eventArgs)
	determine_haste_group()
end

-- Handle auto-targetting based on local setup.
function job_auto_change_target(spell, action, spellMap, eventArgs)
	if spell.type == 'CorsairShot' then
		if state.IgnoreTargetting.value == true then
			state.IgnoreTargetting:reset()
			eventArgs.handled = true
		end
		
		eventArgs.SelectNPCTargets = state.SelectqdTarget.value
	end
end

-- Set eventArgs.handled to true if we don't want the automatic display to be run.
function display_current_job_state(eventArgs)
	local msg = ''
	
	msg = msg .. '[ Offense/Ranged: '..state.OffenseMode.current..'/'..state.RangedMode.current .. ' ]'
	msg = msg .. '[ WS: '..state.WeaponskillMode.current .. ' ]'

	if state.DefenseMode.value ~= 'None' then
		msg = msg .. '[ Defense: ' .. state.DefenseMode.value .. state[state.DefenseMode.value .. 'DefenseMode'].value .. ' ]'
	end
	
	if state.Kiting.value then
		msg = msg .. '[ Kiting Mode: ON ]'
	end

	msg = msg .. '[ ' .. state.HasteMode.value .. ' ]'

	msg = msg .. '[ *'..state.Mainqd.current

	if state.UseAltqd.value == true then
		msg = msg .. '/'..state.Altqd.current
	end
	
	msg = msg .. '* ]'
	
	add_to_chat(060, msg)

	eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- User self-commands.
-------------------------------------------------------------------------------------------------------------------

-- Called for custom player commands.
function job_self_command(cmdParams, eventArgs)
	if cmdParams[1] == 'qd' then
		if cmdParams[2] == 't' then
			state.IgnoreTargetting:set()
		end

		local doqd = ''
		if state.UseAltqd.value == true then
			doqd = state[state.Currentqd.current..'qd'].current
			state.Currentqd:cycle()
		else
			doqd = state.Mainqd.current
		end		
		
		send_command('@input /ja "'..doqd..'" <t>')
	end
end


-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

function determine_haste_group()

	-- Gearswap can't detect the difference between Haste I and Haste II
	-- so use winkey-H to manually set Haste spell level.

	-- Haste (buffactive[33]) - 15%
	-- Haste II (buffactive[33]) - 30%
	-- Haste Samba - 5%/10%
	-- Victory March +0/+3/+4/+5	9.4%/14%/15.6%/17.1%
	-- Advancing March +0/+3/+4/+5  6.3%/10.9%/12.5%/14% 
	-- Embrava - 30%
	-- Mighty Guard (buffactive[604]) - 15%
	-- Geo-Haste (buffactive[580]) - 40%

	classes.CustomMeleeGroups:clear()

	if state.HasteMode.value == 'Haste II' then
		if(((buffactive[33] or buffactive[580] or buffactive.embrava) and (buffactive.march or buffactive[604])) or
			(buffactive[33] and (buffactive[580] or buffactive.embrava)) or
			(buffactive.march == 2 and buffactive[604]) or buffactive.march == 3) then
			add_to_chat(122, 'Magic Haste Level: 43%')
			classes.CustomMeleeGroups:append('MaxHaste')
		elseif ((buffactive[33] or buffactive.march == 2 or buffactive[580]) and buffactive['haste samba']) then
			add_to_chat(122, 'Magic Haste Level: 35%')
			classes.CustomMeleeGroups:append('HighHaste')
		elseif ((buffactive[580] or buffactive[33] or buffactive.march == 2) or
			(buffactive.march == 1 and buffactive[604])) then
			add_to_chat(122, 'Magic Haste Level: 30%')
			classes.CustomMeleeGroups:append('MidHaste')
		elseif (buffactive.march == 1 or buffactive[604]) then
			add_to_chat(122, 'Magic Haste Level: 15%')
			classes.CustomMeleeGroups:append('LowHaste')
		end
	else
		if (buffactive[580] and ( buffactive.march or buffactive[33] or buffactive.embrava or buffactive[604]) ) or
			(buffactive.embrava and (buffactive.march or buffactive[33] or buffactive[604])) or
			(buffactive.march == 2 and (buffactive[33] or buffactive[604])) or
			(buffactive[33] and buffactive[604] and buffactive.march ) or buffactive.march == 3 then
			add_to_chat(122, 'Magic Haste Level: 43%')
			classes.CustomMeleeGroups:append('MaxHaste')
		elseif ((buffactive[604] or buffactive[33]) and buffactive['haste samba'] and buffactive.march == 1) or
			(buffactive.march == 2 and buffactive['haste samba']) or
			(buffactive[580] and buffactive['haste samba'] ) then
			add_to_chat(122, 'Magic Haste Level: 35%')
			classes.CustomMeleeGroups:append('HighHaste')
		elseif (buffactive.march == 2 ) or
			((buffactive[33] or buffactive[604]) and buffactive.march == 1 ) or  -- MG or haste + 1 march
			(buffactive[580] ) or  -- geo haste
			(buffactive[33] and buffactive[604]) then
			add_to_chat(122, 'Magic Haste Level: 30%')
			classes.CustomMeleeGroups:append('MidHaste')
		elseif buffactive[33] or buffactive[604] or buffactive.march == 1 then
			add_to_chat(122, 'Magic Haste Level: 15%')
			classes.CustomMeleeGroups:append('LowHaste')
		end
	end
end

function define_roll_values()
	rolls = {
		["Corsair's Roll"]   = {lucky=5, unlucky=9, bonus="Experience Points"},
		["Ninja Roll"]	   = {lucky=4, unlucky=8, bonus="Evasion"},
		["Hunter's Roll"]	= {lucky=4, unlucky=8, bonus="Accuracy"},
		["Chaos Roll"]	   = {lucky=4, unlucky=8, bonus="Attack"},
		["Magus's Roll"]	 = {lucky=2, unlucky=6, bonus="Magic Defense"},
		["Healer's Roll"]	= {lucky=3, unlucky=7, bonus="Cure Potency Received"},
		["Drachen Roll"]	  = {lucky=4, unlucky=8, bonus="Pet Magic Accuracy/Attack"},
		["Choral Roll"]	  = {lucky=2, unlucky=6, bonus="Spell Interruption Rate"},
		["Monk's Roll"]	  = {lucky=3, unlucky=7, bonus="Subtle Blow"},
		["Beast Roll"]	   = {lucky=4, unlucky=8, bonus="Pet Attack"},
		["Samurai Roll"]	 = {lucky=2, unlucky=6, bonus="Store TP"},
		["Evoker's Roll"]	= {lucky=5, unlucky=9, bonus="Refresh"},
		["Rogue's Roll"]	 = {lucky=5, unlucky=9, bonus="Critical Hit Rate"},
		["Warlock's Roll"]   = {lucky=4, unlucky=8, bonus="Magic Accuracy"},
		["Fighter's Roll"]   = {lucky=5, unlucky=9, bonus="Double Attack Rate"},
		["Puppet Roll"]	 = {lucky=3, unlucky=7, bonus="Pet Magic Attack/Accuracy"},
		["Gallant's Roll"]   = {lucky=3, unlucky=7, bonus="Defense"},
		["Wizard's Roll"]	= {lucky=5, unlucky=9, bonus="Magic Attack"},
		["Dancer's Roll"]	= {lucky=3, unlucky=7, bonus="Regen"},
		["Scholar's Roll"]   = {lucky=2, unlucky=6, bonus="Conserve MP"},
		["Naturalist's Roll"]	   = {lucky=3, unlucky=7, bonus="Enh. Magic Duration"},
		["Runeist's Roll"]	   = {lucky=4, unlucky=8, bonus="Magic Evasion"},
		["Bolter's Roll"]	= {lucky=3, unlucky=9, bonus="Movement Speed"},
		["Caster's Roll"]	= {lucky=2, unlucky=7, bonus="Fast Cast"},
		["Courser's Roll"]   = {lucky=3, unlucky=9, bonus="Snapshot"},
		["Blitzer's Roll"]   = {lucky=4, unlucky=9, bonus="Attack Delay"},
		["Tactician's Roll"] = {lucky=5, unlucky=8, bonus="Regain"},
		["Allies' Roll"]	= {lucky=3, unlucky=10, bonus="Skillchain Damage"},
		["Miser's Roll"]	 = {lucky=5, unlucky=7, bonus="Save TP"},
		["Companion's Roll"] = {lucky=2, unlucky=10, bonus="Pet Regain and Regen"},
		["Avenger's Roll"]   = {lucky=4, unlucky=8, bonus="Counter Rate"},
	}
end

function display_roll_info(spell)
	rollinfo = rolls[spell.english]
	local rollsize = (state.LuzafRing.value and 'Large') or 'Small'

	if rollinfo then
		add_to_chat(104, '[ Lucky: '..tostring(rollinfo.lucky)..' / Unlucky: '..tostring(rollinfo.unlucky)..' ] '..spell.english..': '..rollinfo.bonus..' ('..rollsize..') ')
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
		if spell.type == 'CorsairShotShot' and player.equipment.ammo ~= 'empty' then
			add_to_chat(104, 'No Quick Draw ammo left.  Using what\'s currently equipped ('..player.equipment.ammo..').')
			return
		elseif spell.type == 'WeaponSkill' and player.equipment.ammo == gear.RAbullet then
--			add_to_chat(104, 'No weaponskill ammo left.  Using what\'s currently equipped (standard ranged bullets: '..player.equipment.ammo..').')
			return
		else
			add_to_chat(104, 'No ammo ('..tostring(bullet_name)..') available for that action.')
			if options.send_ammo_warning == 1 then
				send_command('input /t '..options.send_ammo_warning_to..' OUT OF AMMO: '..tostring(bullet_name))
			end
			eventArgs.cancel = true
			return
		end
	end
	
	-- Don't allow shooting or weaponskilling with ammo reserved for quick draw.
	if spell.type ~= 'CorsairShot' and bullet_name == gear.QDbullet and available_bullets.count <= bullet_min_count then
		add_to_chat(104, 'No ammo will be left for Quick Draw.  Cancelling.')
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
		
		add_to_chat(104, border)
		add_to_chat(104, msg)
		add_to_chat(104, border)
		
		if options.send_ammo_warning == 1 then
			send_command('input /t '..options.send_ammo_warning_to..' '..msg)
		end
		
		state.warned:set()
	elseif available_bullets.count > options.ammo_warning_limit and state.warned then
		state.warned:reset()
	end
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
	if player.sub_job == 'DNC' then
		set_macro_page(1, 7)
	else
		set_macro_page(1, 7)
	end
end

function set_lockstyle(num)
	send_command('wait 2; input /lockstyleset '..num)
end