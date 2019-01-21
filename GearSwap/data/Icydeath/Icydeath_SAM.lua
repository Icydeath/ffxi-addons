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

include('Arcon-Recasts.lua')

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
	
	state.CP = M(false, "Capacity Points Mode")
	
	state.FullAuto = M{['description'] = 'Full Auto(default: Off)'}
	state.FullAuto:options('Off', 'On')
	
	state.AutoStance = M{['description'] = 'Auto Hasso/Seigan(default: Hasso)'}
	state.AutoStance:options('Hasso', 'Seigan')
	
	state.AutoWS = M{['description'] = 'Auto WS(default: Off)'}
	state.AutoWS:options('Off', 'On')
	
	state.WSHP = M{['description'] = 'WS when HP is greater than(default: 0)'}
	state.WSHP:options(0, 10, 20, 30, 40, 50)
	
	state.AutoWSName = M{['description'] = 'Set Weapon Skill (default: Tachi: Fudo)'}
	state.AutoWSName:options('Tachi: Fudo', 'Tachi: Shoha', 'Tachi: Rana', 'Namas Arrow')
	
	state.BowMode = M(true, "Bow Mode")
	
    update_combat_form()
	
	-- Map for auto activation of Berserk/Warcry based
    -- on Weaponskills listed
    berserk_warcry_automation = S{'Tachi: Fudo', 'Tachi: Shoha', 'Tachi: Rana', 'Namas Arrow'}
	
	windower.register_event('tp change', function(new, old)
		if state.FullAuto.value == 'On' then
			full_auto()
			return true
			
		elseif not midaction() 
		  and not areas.Cities:contains(world.area) 
		  and not buffactive['amnesia']  
		  and player.status == 'Engaged' then
		  
			if not buffactive['Hasso'] 
			  and not buffactive['Seigan'] then
				send_command(state.AutoStance.value)
				
			elseif buffactive['Seigan'] 
		      and player.hpp < 60
			  and not buffactive['Third Eye'] 
			  and check_recasts(j('Third Eye')) then
				send_command('Third Eye')
				
			elseif state.AutoWS.value == 'On' then
			  if player.target.distance ~= nil and player.tp > 999 and player.target.hpp > state.WSHP.value then
			    if state.AutoWSName.value == 'Namas Arrow' and player.target.distance < 20 then 
					send_command(state.AutoWSName.value) 
			    elseif player.target.distance < 6 then 
					send_command(state.AutoWSName.value) 
				end
			  end
			end
			
			return true
		end
	end)

	windower.register_event('time change', function(time)
		if player.tp == 3000 then
			if state.FullAuto.value == 'On' then
				full_auto()
				
			elseif not midaction() 
			  and not areas.Cities:contains(world.area) 
			  and not buffactive['amnesia'] 
			  and player.status == 'Engaged' then 
			  
			  if not buffactive['Hasso'] and not buffactive['Seigan'] then
				send_command(state.AutoStance.value)
			  elseif state.AutoWS.value == 'On' then
			    if player.target.distance ~= nil and player.tp > 999 and player.target.hpp > state.WSHP.value then
			      if state.AutoWSName.value == 'Namas Arrow' and player.target.distance < 20 then 
					send_command(state.AutoWSName.value) 
			      elseif player.target.distance < 6 then 
					send_command(state.AutoWSName.value) 
				  end
			    end
			  end
			end
		end
	end)	
	
	set_lockstyle('1')
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
    sets.CP = {back="Mecisto. Mantle"}
	sets.BowArrow = {range="Yoichinoyumi", ammo="Yoichi's Arrow"}
	sets.Ammo = {ammo="Ginsen"}
	
    -- Precast Sets
    -- Precast sets to enhance JAs
    sets.precast.JA.Meditate = {head="Myochin Kabuto", hands="Sakonji Kote +1", back="Smertrios's Mantle"} --,hands="Sakonji Kote"
    sets.precast.JA['Warding Circle'] = {} --head="Myochin Kabuto"
    sets.precast.JA['Blade Bash'] = {hands="Sakonji Kote +1"} 

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {}
        
    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz['Healing Waltz'] = {}

       
    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
		head={ name="Valorous Mask", augments={'Accuracy+29','Weapon skill damage +1%','VIT+7','Attack+15',}},
		body="Ken. Samue",
		hands="Ken. Tekko",
		legs={ name="Ryuo Hakama", augments={'Accuracy+20','"Store TP"+4','Phys. dmg. taken -3',}},
		feet={ name="Valorous Greaves", augments={'Weapon skill damage +3%','STR+5','Accuracy+15','Attack+14',}},
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Ishvara Earring",
		right_ear={ name="Moonshade Earring", augments={'"Mag.Atk.Bns."+4','TP Bonus +250',}},
		left_ring="Petrov Ring",
		right_ring="Apate Ring",
		back="Smertrios's Mantle",
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

    sets.precast.WS['Tachi: Ageha'] = set_combine(sets.precast.WS, {
		head={ name="Founder's Corona", augments={'DEX+8','Accuracy+15','Mag. Acc.+14','Magic dmg. taken -3%',}},
		neck="Sanctity Necklace",
		waist="Anguinus Belt",
		left_ear="Gwati Earring",
		right_ear="Enchntr. Earring +1",
		left_ring="Fenrir Ring +1",
		right_ring="Balrahn's Ring",
	})

    sets.precast.WS['Tachi: Jinpu'] = set_combine(sets.precast.WS, {})
	
	sets.precast.WS['Namas Arrow'] = set_combine(sets.precast.WS, {
		ammo=gear.Arrow,
		right_ear="Enervating Earring",
		left_ring="Cacoethic Ring +1",
		right_ring="Paqichikaji Ring",
		back="Sokolski Mantle",
	})


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
		head={ name="Valorous Mask", augments={'Accuracy+16 Attack+16','"Store TP"+6','AGI+4','Accuracy+7','Attack+2',}},
		body="Ken. Samue",
		hands="Ken. Tekko",
		legs={ name="Ryuo Hakama", augments={'Accuracy+20','"Store TP"+4','Phys. dmg. taken -3',}},
		feet={ name="Valorous Greaves", augments={'Accuracy+30','"Dbl.Atk."+1','DEX+1','Attack+7',}},
		neck="Lissome Necklace",
		waist="Kentarch Belt +1",
		left_ear="Brutal Earring",
		right_ear="Cessance Earring",
		left_ring="Petrov Ring",
		right_ring="Rajas Ring",
		back="Smertrios's Mantle",
	}
    sets.engaged.Acc = set_combine(sets.engaged, {})
    sets.engaged.PDT = set_combine(sets.engaged, {})
    sets.engaged.Acc.PDT = set_combine(sets.engaged, {})
    sets.engaged.Reraise = set_combine(sets.engaged, {})
    sets.engaged.Acc.Reraise = set_combine(sets.engaged, {})
        
    -- Melee sets for in Adoulin, which has an extra 10 Save TP for weaponskills.
    sets.engaged.Adoulin = set_combine(sets.engaged, {})
    sets.engaged.Adoulin.Acc = set_combine(sets.engaged, {})
    sets.engaged.Adoulin.PDT = set_combine(sets.engaged, {})
    sets.engaged.Adoulin.Acc.PDT = set_combine(sets.engaged, {})
    sets.engaged.Adoulin.Reraise = set_combine(sets.engaged, {})
    sets.engaged.Adoulin.Acc.Reraise = set_combine(sets.engaged, {})


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

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
	-- Automates Aggressor/Berserk/Warcry for Warrior sub job
    if (state.FullAuto.value == 'On' or state.AutoWS.value == 'On')
	  and berserk_warcry_automation:contains(spell.name)
	  and player.status == 'Engaged'
	  and player.sub_job == 'WAR'
	  and check_recasts(j('Aggressor'))
	  and not check_buffs('Amnesia', 'Berserk', 'Obliviscence', 'Paralysis') then
		windower.send_command('aggressor; wait 1; berserk; wait 1; warcry; wait 1;'..spell.name..' '..spell.target.raw)
		cancel_spell()
		return
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

-- Called any time we attempt to handle automatic gear equips (ie: engaged or idle gear).
function job_handle_equipping_gear(playerStatus, eventArgs)    	
	if state.BowMode.current == 'on' then
		equip(sets.BowArrow)
	else
		equip(sets.Ammo)
	end
end

-- Called by the 'update' self-command, for common needs.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(cmdParams, eventArgs)
    update_combat_form()
end

-- Set eventArgs.handled to true if we don't want the automatic display to be run.
function display_current_job_state(eventArgs)

end


-- /con gs c toggle AutoMode
-- This method trys to utilize all of SAMs job abilities before using weapon skills.
-- Gets called during windowers event 'tp change'
function full_auto()
	if not midaction() then
	  if not areas.Cities:contains(world.area) and not buffactive['amnesia'] and player.status == 'Engaged' then
	  
	    if not has_any_buff_of(S{'Hasso', 'Seigan'}) then --not buffactive['Hasso'] and not buffactive['Seigan'] then
		  send_command(state.AutoStance.value)
		
		elseif buffactive['Seigan'] 
		  and player.hpp < 60
		  and not buffactive['Third Eye'] 
		  and check_recasts(j('Third Eye')) then
		    send_command('Third Eye')
		
		elseif player.target.distance ~= nil and player.target.hpp ~= nil then
		  if player.target.distance < 6 and player.target.hpp > state.WSHP.value then
			if player.tp > 999 then
			  if player.tp > 1500 and check_recasts(j('Sekkanoki')) then
				send_command('Sekkanoki') -- limits weapon skill to 1000tp
			  elseif player.tp < 2000 and check_recasts(j('Hagakure')) then 
				send_command('Hagakure') -- 1000 TP Bonus & 400 Save TP
			  else
				send_command(state.AutoWSName.value) -- Default = Tachi: Fudo
			  end
			else --if player.tp < 999 then
			  if check_recasts(j('Meditate')) then
				send_command('Meditate') -- Regain
			  elseif check_recasts(j('Konozen-ittai')) then
				send_command('Konozen-ittai') -- readies target of skillchain
			  end
			end
	      end
		end
		
	  end
	  
	end -- end of not midaction()
end -- end of function
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

function set_lockstyle(num)
	send_command('wait 2; input /lockstyleset '..num)
end