-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2
	--include('Icy-Include.lua') -- this is only required for auto open Velkk Coffersuse
    
    -- Load and initialize the include file.
    include('Mote-Include.lua')
		include('organizer-lib')

end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    state.Buff['Afflatus Solace'] = buffactive['Afflatus Solace'] or false
    state.Buff['Afflatus Misery'] = buffactive['Afflatus Misery'] or false

	    state.OffenseMode:options('None', 'Normal')
    state.CastingMode:options('Normal', 'Resistant')
    state.IdleMode:options('Normal', 'PDT','MDT')
    state.PCTargetMode:options('default', 'stpc', 'stpt', 'stal')
	
		AutoAga = 1
		Curaga_benchmark = 30
		Enmity = 1
		Safe_benchmark = 70
		Sublimation_benchmark = 30
		Sublimation = 1
		
    select_default_macro_book()

	custom_timers = {}
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------

    -- Precast Sets

    -- Fast cast sets for spells
    sets.precast.FC = {
						sub="Chanter's Shield",
						ammo="Impatiens",
                        head="Nahtirah Hat",
                        neck="Orunmila's Torque",
                        ear2="Loquac. Earring",
                        body="Gendewitha Bliaut +1",
                        hands="Gendewitha Gages",
                        ring1="Prolix Ring",
                        ring2="Veneficium Ring",
                        back="Alaunus's Cape",
                        waist="Witful Belt";
                        legs="Orvail Pants",
                        feet="Regal Pumps"}
        
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist="Siegel Sash"})

    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {})

    sets.precast.FC['Healing Magic'] = set_combine(sets.precast.FC, {main="Queller Rod",legs="Ebers pantaloons"})

    sets.precast.FC.StatusRemoval = sets.precast.FC['Healing Magic']
		

    sets.precast.FC.Cure = set_combine(sets.precast.FC['Healing Magic'], 
		{main="",sub="",ammo="",
		body="",feet="Hygieia Clogs",back="Pahtli Cape"})
		
    sets.precast.FC.Curaga = sets.precast.FC.Cure
    sets.precast.FC.CureSolace = sets.precast.FC.Cure
    -- CureMelee spell map should default back to Healing Magic.
    
    -- Precast sets to enhance JAs
    sets.precast.JA.Benediction = {body="Piety Briault"}

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {}
    
    
    -- Weaponskill sets

    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {}
    
    
    -- Midcast Sets
    
    sets.midcast.FastRecast = {ammo="Sapience Orb",sub="Chanter's Shiled",
        head="",neck="Orison locket",ear1="",ear2="Loquacious Earring",
        body="",hands="",ring1="Prolix Ring",ring2="Lebeche Ring",
        back="Swith Cape",waist="Witful belt",legs="Lengo Pants",feet=""}
    
    ------------ Cure sets-------------------

	sets.midcast.CureWithLightWeather = {}

    sets.midcast.CureSolace = { 
						main="Queller Rod",
						sub="Sors Shield",
						ammo="Clarus Stone",
						head="Ebers Cap",
						body="Ebers Bliaud",
						hands="Augur's Gloves",
						legs="Ebers Pantaloons",
						feet="Hygieia Clogs",
						neck="Noetic Torque",
						waist="Hierarch Belt",
						left_ear="Nourish. Earring",
						right_ear="Orison Earring",
						left_ring="Sirona's Ring",
						right_ring="Janniston Ring",
						back="Mending Cape",}

    sets.midcast.Cure = { 
						main="Queller Rod",
						sub="Sors Shield",
						ammo="Clarus Stone",
						head="Ebers Cap",
						body="Ebers Bliaud",
						hands="Augur's Gloves",
						legs="Ebers Pantaloons",
						feet="Hygieia Clogs",
						neck="Noetic Torque",
						waist="Hierarch Belt",
						left_ear="Nourish. Earring",
						right_ear="Orison Earring",
						left_ring="Sirona's Ring",
						right_ring="Janniston Ring",
						back="Mending Cape",}

    sets.midcast.Curaga = { 
						main="Queller Rod",
						sub="Sors Shield",
						ammo="Clarus Stone",
						head="Ebers Cap",
						body="Ebers Bliaud",
						hands="Augur's Gloves",
						legs="Ebers Pantaloons",
						feet="Hygieia Clogs",
						neck="Noetic Torque",
						waist="Hierarch Belt",
						left_ear="Nourish. Earring",
						right_ear="Orison Earring",
						left_ring="Sirona's Ring",
						right_ring="Janniston Ring",
						back="Mending Cape",}

    sets.midcast.CureMelee = {}

    sets.midcast.Cursna = {back="Alaunus's Cape",}

    sets.midcast.StatusRemoval = {head="Ebers Cap",main="Yagrush",}

--------------ENHANCING AND SUCH---------------------

    -- 110 total Enhancing Magic Skill; caps even without Light Arts
    sets.midcast['Enhancing Magic'] = {main="Ababinili +1",sub="Fulcio Grip",
        head="Telchine cap",neck="Incanter's Torque",ear1="Andoaa Earring",
        body="Telchine chasuble",hands="Telchine gloves",
        back="Mending Cape",waist="Olympus Sash",legs="Piety Pantaloons",feet="Piety Duckbills"}

	sets.midcast.Haste = set_combine(sets.midcast['Enhancing Magic'], 
		{back="Ogapepo Cape",})
	
	sets.midcast.Aurorastorm = sets.midcast['Enhancing Magic']
	
	sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'],
		{})	

    sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {waist="Siegel Sash",neck="Nodens Gorget"})

    sets.midcast.Auspice = set_combine(sets.midcast['Enhancing Magic'],{body="Telchine chasuble",feet="Ebers Duckbills"})

    sets.midcast.BarElement = set_combine(sets.midcast['Enhancing Magic'], {
		-- Only put in gear that enhances bar elemental spells
        head="Ebers cap",
        body="Ebers bliaud",
		hands="Ebers mitts",
		feet="Ebers Duckbills"
	})

    sets.midcast.Regen = set_combine(sets.midcast['Enhancing Magic'], {hands="Ebers mitts"})

    sets.midcast.Protectra = set_combine(sets.midcast['Enhancing Magic'], {ring1="Sheltered Ring",feet="Piety Duckbills"})

    sets.midcast.Shellra = set_combine(sets.midcast['Enhancing Magic'], {ring1="Sheltered Ring",legs="Piety Pantaloons"})
	
	sets.midcast.Dia = set_combine(sets.midcast.MndEnfeebles, {waist="Chaac Belt"})

    sets.midcast['Divine Magic'] = {}

    sets.midcast['Dark Magic'] = {}

    -- Custom spell classes
    sets.midcast.MndEnfeebles = {}

    sets.midcast.IntEnfeebles = {}

    sets.midcast.Impact = {}
    	

    -- Sets to return to when not performing an action.
    
    -- Resting set
    sets.resting = {  
        body="Vrikodara jupon",hands="Serpentes Cuffs",
        legs="Assiduity pants",feet="Serpentes Sabots"}
    

    -- Idle sets (default idle set not needed since the other three are defined, but leaving for testing purposes)
    sets.idle = {
						main="Queller Rod",
						sub="Sors Shield",
						ammo="Homiliary",
						head="Ebers Cap",
						body="Gendewitha Bliaut +1",
						hands="Ebers Mitts",
						legs={ name="Tatsu. Sitagoromo", augments={'"Cure" potency +5%','Movement speed +8%+2',}},
						feet="Hygieia Clogs",
						neck="Nodens Gorget",
						waist="Witful Belt",
						left_ear="Nourish. Earring",
						right_ear="Mendi. Earring",
						left_ring="Lebeche Ring",
						right_ring="Janniston Ring",
						back="Medala Cape",}

    sets.idle.PDT = {}

	sets.idle.MDT = {}


    sets.idle.Town = {}
    
    sets.idle.Weak = {}
    
    -- Defense sets

    sets.defense.PDT = {}

    sets.defense.MDT = {}

    sets.Kiting = {feet=""}

    sets.latent_refresh = {waist="Fucho-no-obi"}

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion
    
    -- Basic set for if no TP weapon is defined.
    sets.engaged = {}


    -- Buff sets: Gear that needs to be worn to actively enhance a current player buff.
    sets.buff['Divine Caress'] = {hands="Ebers mitts",back="Mending Cape"}
	
	sets.CP = {back="Mecisto. Mantle"}
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific pretarget
-------------------------------------------------------------------------------------------------------------------

function party_index_lookup(name)
    for i=1,party.count do
        if party[i].name == name then
            return i
        end
    end
    return nil
end
function job_auto_change_target(spell, action, spellMap, eventArgs)
	eventArgs = {handled = false, PCTargetMode = state.PCTargetMode.value, SelectNPCTargets = state.SelectNPCTargets.value}
end
function pretarget(spell, action, spellMap, eventArgs)
	job_auto_change_target(spell, action, spellMap, eventArgs)
	if spell.action_type == 'Magic' and buffactive.silence then -- Auto Use Echo Drops If You Are Silenced --
		cancel_spell()
		send_command('input /item "Echo Drops" <me>')
	end
	
    --if T{"Cure","Cure II","Cure III","Cure IV"}:contains(spell.name) and spell.target.type == 'PLAYER' and not spell.target.charmed and AutoAga == 1 then
        --if not party_index_lookup(spell.target.name) then
            --return
        --end
        --local target_count = 0
        --local total_hpp_deficit = 0
        --for i=1,party.count do          
		--if party[i].hpp<75 and party[i].status_id ~= 2 and party[i].status_id ~= 3 then
			--target_count = target_count + 1
			--total_hpp_deficit = total_hpp_deficit + (100 - party[i].hpp)
		--end
	--end
	--if target_count > 1 then
		--cancel_spell()
		--if total_hpp_deficit / target_count > Curaga_benchmark then           
			--send_command(';input /ma "Curaga IV" '..spell.target.name..';')
		--else
			--send_command(';input /ma "Curaga III" '..spell.target.name..';')
		--end
	--end
    --end 
end


Cures 									= S{'Cure','Cure II','Cure III','Cure IV','Cure V','Cure VI'}
Curagas 								= S{'Curaga','Curaga II','Curaga III','Curaga IV','Curaga V','Cura','Cura II','Cura III'}
Lyna									= S{'Paralyna','Silena','Viruna','Erase','Stona','Blindna','Poisona'}
Barspells								= S{'Barfira','Barfire','Barwater','Barwatera','Barstone','Barstonra','Baraero','Baraera','Barblizzara','Barblizzard','Barthunder','Barthundra'}
Turtle									= S{'Protectra V','Shellra V'}
Cursna									= S{'Cursna'}
Regens									= S{'Regen','Regen II','Regen III','Regen IV','Regen V'}
Enhanced								= S{'Flurry','Haste','Refresh'}
Banished								= S{'Banish','Banish II','Banish III','Banishga','Banishga II'}
Smited									= S{'Holy','Holy II'}
Reposed									= S{'Repose','Flash'}
Potency									= S{'Slow','Paralyze'}
Defense									= S{'Stoneskin'}



-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    if spell.english == "Impact" then
        equip(set_combine(sets.precast.FC,{body="Twilight Cloak"}))
    end
    if spell.english == "Paralyna" and buffactive.Paralyzed then
        -- no gear swaps if we're paralyzed, to avoid blinking while trying to remove it.
        eventArgs.handled = true
    end
    if spell.name:startswith('Cure')then
        equip(sets.precast.FC.Cure)
    end
end

function job_midcast(spell, action)
	if spell.skill == 'Healing Magic' then
		if Cures:contains(spell.name) then
			if  world.day =='Lightsday' or  world.weather_element == 'Light'  or buffactive == 'Aurorastorm' then
				equip(sets.midcast.CureWithLightWeather)
			elseif Enmity == 1 then
				equip(sets.midcast.CureEnmity)
			elseif buffactive['Afflatus Solace'] then
				equip(sets.midcast.CureSolace)
			end
		end
		if Curagas:contains(spell.name) then
			if  world.day =='Lightsday' or  world.weather_element == 'Light'  or buffactive == 'Aurorastorm' then
				equip(sets.midcast.CureWithLightWeather)
			else
				equip(sets.midcast.Curaga)
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
    if spell.skill == 'Enhancing Magic' then
            adjust_timers(spell, spellMap)
	end
end
-- Function to create custom buff-remaining timers with the Timers plugin,

-- keeping only the actual valid songs rather than spamming the default

-- buff remaining timers.

function adjust_timers(spell, spellMap)
    local current_time = os.time()
    
    -- custom_timers contains a table of song names, with the os time when they
    -- will expire.
    
    -- Eliminate songs that have already expired from our local list.
    local temp_timer_list = {}
    local dur = calculate_duration(spell, spellName, spellMap)
         custom_timers[spell.name] = nil
         send_command('timers delete "'..spell.name..' ['..spell.target.name..']"')
         custom_timers[spell.name] = current_time + dur
         send_command('timers create "'..spell.name..' ['..spell.target.name..']" '..dur..' down')
end




-- Function to calculate the duration of a song based on the equipment used to cast it.

-- Called from adjust_timers(), which is only called on aftercast().

function calculate_duration(spell, spellName, spellMap)

    local mult = 1.00

	if player.equipment.Head == 'Telchine Cap' then mult = mult + 0.09 end
	if player.equipment.Body == 'Telchine Chas.' then mult = mult + 0.08 end
	if player.equipment.Hands == 'Telchine Gloves' then mult = mult + 0.09 end
	if player.equipment.Legs == 'Telchine Braconi' then mult = mult + 0.08 end
	if player.equipment.Feet == 'Telchine Pigaches' then mult = mult + 0.08 end
	
	if player.equipment.Feet == 'Estq. Houseaux +2' then mult = mult + 0.20 end
	if player.equipment.Legs == 'Futhark Trousers' then mult = mult + 0.10 end
	if player.equipment.Legs == 'Futhark Trousers +1' then mult = mult + 0.20 end
	if player.equipment.Hands == 'Atrophy Gloves' then mult = mult + 0.15 end
	if player.equipment.Hands == 'Atrophy Gloves +1' then mult = mult + 0.16 end
	if player.equipment.Back == 'Estoqueur\'s Cape' then mult = mult + 0.10 end
	if player.equipment.Hands == 'Dynasty Mitts' then mult = mult + 0.05 end
	if player.equipment.Body == 'Shabti Cuirass' then mult = mult + 0.09 end
	if player.equipment.Body == 'Shabti Cuirass +1' then mult = mult + 0.10 end
	if player.equipment.Feet == 'Leth. Houseaux' then mult = mult + 0.25 end
	if player.equipment.Feet == 'Leth. Houseaux +1' then mult = mult + 0.30 end


	local base = 0

	if spell.name == 'Haste' then base = base + 180 end
	if spell.name == 'Stoneskin' then base = base + 300 end
	if string.find(spell.name,'Bar') then base = base + 480 end
	if spell.name == 'Blink' then base = base + 300 end
	if spell.name == 'Aquaveil' then base = base + 600 end
	if string.find(spell.name,'storm') then base = base + 180 end
	if spell.name == 'Auspice' then base = base + 180 end
	if string.find(spell.name,'Boost') then base = base + 300 end
	if spell.name == 'Phalanx' then base = base + 180 end
	if string.find(spell.name,'Protect') then base = base + 1800 end
	if string.find(spell.name,'Shell') then base = base + 1800 end
	if string.find(spell.name,'Refresh') then base = base + 150 end
	if string.find(spell.name,'Regen') then base = base + 60 end
	if spell.name == 'Adloquium' then base = base + 180 end
	if string.find(spell.name,'Animus') then base = base + 60 end
	if spell.name == 'Crusade' then base = base + 300 end
	if spell.name == 'Embrava' then base = base + 90 end
	if string.find(spell.name,'En') then base = base + 180 end
	if string.find(spell.name,'Flurry') then base = base + 180 end
	if spell.name == 'Foil' then base = base + 30 end
	if string.find(spell.name,'Gain') then base = base + 180 end
	if spell.name == 'Reprisal' then base = base + 60 end
	if string.find(spell.name,'Temper') then base = base + 180 end
	if string.find(spell.name,'Spikes') then base = base + 180 end

	if spell.name == 'Gekka: Ichi' then base = base + 300 end
	if spell.name == 'Yain: Ichi' then base = base + 180 end
	if spell.name == 'Myoshu: Ichi' then base = base + 180 end
	if spell.name == 'Kakka: Ichi' then base = base + 180 end
	if spell.name == 'Migawari: Ichi' then base = base + 60 end
	
	if player.main_job == 'NIN' then
		--This is if your Ninja has 550+ job points for ninjutsu duration to accurately reflect on Timers.
		mult = mult*1.1
	end
	
	if buffactive['Perpetuance'] then
		if player.equipment.Hands == 'Arbatel Bracers' then
			mult = mult*2.5
		elseif player.equipment.Hands == 'Arbatel Bracers +1' then
			mult = mult*2.55
		else
			mult = mult*2
		end
	end

	if buffactive['Composure'] then
		if spell.target.type == 'SELF' then
			mult = mult*3
		else
			mult = mult
		end
	end
			
			

    local totalDuration = math.floor(mult*base)

	--print(totalDuration)


    return totalDuration

end
-- Function to reset timers.

function reset_timers()

    for i,v in pairs(custom_timers) do

        send_command('timers delete "'..i..'"')

    end

    custom_timers = {}

end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Handle notifications of general user state change.
function job_state_change(stateField, newValue, oldValue)
    if stateField == 'Offense Mode' then
        if newValue == 'Normal' then
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
	elseif (default_spell_map == 'Cure' or default_spell_map == 'Curaga') and (world.day == 'Lightsday' or world.weather_element == 'Light' or buffactive == 'Aurorastorm') then
		return "CureWithLightWeather"
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
    return idleSet
end

function self_command(command)
	if command == 'A10' then -- Aga Toggle --
		if AutoAga == 1 then
			AutoAga = 0
			add_to_chat(8,'Curaga 3 Mode: [Off]')
		else
			AutoAga = 1
			add_to_chat(158,'Curaga 3 Mode: [ON]')
		end
		status_change(player.status)

	elseif command == 'Z10' then -- Enmity Toggle --
		if Enmity == 1 then
			Enmity = 0
			add_to_chat(8,'Enmity - Mode: [Off]')
		else
			Enmity = 1
			add_to_chat(158,'Enmity - Mode: [ON]')
		end
		status_change(player.status)
		
	
	elseif command == 'B10' then -- Sublimation Toggle --
		if Sublimation == 1 then
			Sublimation = 0
			add_to_chat(8,'Auto Sublimation: [Off]')
		else
			Sublimation = 1
			add_to_chat(158,'Auto Sublimation: [ON]')
		end
		status_change(player.status)
		
	elseif command == 'SUPERCURE' then
		if (windower.ffxi.get_spell_recasts()[215] > 0) then
			send_command('input /ma "Cure V" <t>')
		else
			send_command('input /ja "Penury" <me>;wait 1.2;input /ma "Cure V" <me>')
		end
		
	elseif command == 'SUPERGEN' then
		if (windower.ffxi.get_spell_recasts()[215] > 0) then
			send_command('input /ma "Regen IV" <t>')
		else
			send_command('input /ja "Penury" <me>;wait 1.2;input /ma "Regen IV" <t>')
		end
	
	elseif command == 'SESUNA' then
		if (windower.ffxi.get_spell_recasts()[246] > 0) then
			send_command('input /ma "Esuna" <t>')
		else
			send_command('input /ja "Afflatus Misery" <me>;wait 1.2;input /ma "Esuna" <me>')
		end
	end
end

function AutoSublimation()      
        if buffactive['Sublimation: Complete'] then
                if player.mpp < Sublimation_benchmark then  
                    if Sublimation == 1 then
                        windower.send_command('@wait 4;input /ja "Sublimation" <me>')
                        add_to_chat(039,'Sublimation Completed: MP Danger Zone')
                    end
                elseif player.mpp < 75 then
                    if Sublimation == 1 then
                        windower.send_command('@wait 4;input /ja "Sublimation" <me>')
                        add_to_chat(159,'Sublimation Completed: MP Mid Range')
                    end
                end
        elseif not buffactive['Sublimation: Complete'] and not buffactive['Sublimation: Activated'] then
            if Sublimation == 1 then
            windower.send_command('@wait 4;input /ja "Sublimation" <me>')
            end
        end
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
                send_command('@input /ja "Afflatus Solace" <me>;wait 1.2;input /ja "Light Arts" <me>')
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