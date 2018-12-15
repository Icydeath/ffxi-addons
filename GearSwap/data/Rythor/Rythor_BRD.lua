-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

--[[
    Custom commands:
    
    ExtraSongsMode may take one of three values: None, Dummy, FullLength
    
    You can set these via the standard 'set' and 'cycle' self-commands.  EG:
    gs c cycle ExtraSongsMode
    gs c set ExtraSongsMode Dummy
    
    The Dummy state will equip the bonus song instrument and ensure non-duration gear is equipped.
    The FullLength state will simply equip the bonus song instrument on top of standard gear.
    
    
    Simple macro to cast a dummy Daurdabla song:
    /console gs c set ExtraSongsMode Dummy
    /ma "Shining Fantasia" <me>
    
    To use a Terpander rather than Daurdabla, set the info.ExtraSongInstrument variable to
    'Terpander', and info.ExtraSongs to 1.
--]]

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2
    
    -- Load and initialize the include file.
    include('Mote-Include.lua')
	include('organizer-lib')
end


-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    state.ExtraSongsMode = M{['description']='Extra Songs', 'None', 'Dummy', 'FullLength'}

    state.Buff['Pianissimo'] = buffactive['pianissimo'] or false
	
	state.LullabyList = M{['description']='Display Lullaby List:', 'Off', 'On'} 
	send_command('alias llist gs c cycle LullabyList')
    -- For tracking current recast timers via the Timers plugin.
    custom_timers = {}
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
	
	-- created this for the addon singer
	state.ExtraSongSpell = M(false, 'Extra Song') 
	
	-- modifed Singer to set this varible from its setting: dummy song
	-- Command to change info.ExtraSongSpellName 
	--   	//gs c dummysong Blade-Madrigal
	-- 	Note: Must use - instead of spaces when specifing the song.
	info.ExtraSongSpellName = 'Valor Minuet IV'
	
    brd_daggers = S{'Kustawi', 'Izhiikoh', 'Vanir Knife', 'Atoyac', 'Aphotic Kukri', 'Sabebus'}
    pick_tp_weapon()
    
    -- Adjust this if using the Terpander (new +song instrument)
    info.ExtraSongInstrument = 'Terpander'
    
	-- How many extra songs we can keep from Daurdabla/Terpander
    info.ExtraSongs = 1
    
	-- This is used for determining if MaxJobPoints to detect timers for all the benefits from Gifts etc
	MaxJobPoints = 1
	
    -- Set this to false if you don't want to use custom timers.
    state.UseCustomTimers = M(true, 'Use Custom Timers')
    
    -- Additional local binds
    send_command('bind ^` gs c cycle ExtraSongsMode')
    send_command('bind !` input /ma "Chocobo Mazurka" <me>')

    --select_default_macro_book()
	set_lockstyle('1')
end


-- Called when this job file is unloaded (eg: job change)
function user_unload()
    send_command('unbind ^`')
    send_command('unbind !`')
end


-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------
    sets.CP = {back="Mecisto. Mantle"}
	
    -- Precast Sets

    -- Fast cast sets for spells
    sets.precast.FC = {
		body="Vrikodara Jupon",
		hands={ name="Chironic Gloves", augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','MND+10',}},
		legs="Aya. Cosciales +1",
		waist="Witful Belt",
		left_ear="Etiolation Earring",
		right_ear="Loquac. Earring",
		back="Ogapepo Cape",
	}

    sets.precast.FC.Cure = set_combine(sets.precast.FC, {
		head={ name="Kaykaus Mitra", augments={'MP+60','"Cure" spellcasting time -5%','Enmity-5',}},
		hands={ name="Telchine Gloves", augments={'"Cure" spellcasting time -6%',}},
		legs={ name="Chironic Hose", augments={'Mag. Acc.+13','"Cure" spellcasting time -10%','INT+3','"Mag.Atk.Bns."+10',}},
	})

    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC, {
		--head="Umuthi Hat"
	})

    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {
		waist="Siegel Sash"
	})

    sets.precast.FC.BardSong = {
		main="Felibre's Dague",
		range="Gjallarhorn",
		head="Fili Calot",
		body="Praeco Doublet",
		hands="Bewegt Cuffs",
		legs="Fili Rhingrave",
		feet="Fili Cothurnes",
		neck="Aoidos' Matinee",
		waist="Witful Belt",
		left_ear="Aoidos' Earring",
		right_ear="Loquac. Earring",
		back="Ogapepo Cape",
	}

    sets.precast.FC.Daurdabla = set_combine(sets.precast.FC.BardSong, {range=info.ExtraSongInstrument})
        
    
    -- Precast sets to enhance JAs
    
    sets.precast.JA.Nightingale = {feet="Bihu Slippers"}
    sets.precast.JA.Troubadour = {body="Bihu Justaucorps"}
    sets.precast.JA['Soul Voice'] = {legs="Bihu Cannions"}

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {}
    
       
    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
	sets.precast.WS = {
		head="Aya. Zucchetto +1",
		body="Ayanmo Corazza +1",
		hands="Aya. Manopolas +1",
		legs="Aya. Cosciales +1",
		feet="Aya. Gambieras +1",
		neck="Maskirova Torque",
		waist="Cetl Belt",
		left_ear="Mache Earring",
		right_ear="Mache Earring",
		left_ring="Enlivened Ring",
		right_ring="Apate Ring",
		back="Bleating Mantle",
	}
    
    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS)

    sets.precast.WS['Exenterator'] = set_combine(sets.precast.WS)

    sets.precast.WS['Mordant Rime'] = set_combine(sets.precast.WS)
    
    
    -- Midcast Sets

    -- General set for recast times.
    sets.midcast.FastRecast = set_combine(sets.precast.FC, {})
        
    -- Gear to enhance certain classes of songs.  No instruments added here since Gjallarhorn is being used.
	sets.midcast.SongBuff = {
		main="Legato Dagger",
		head="Fili Calot",
		body="Fili Hongreline",
		hands="Fili Manchettes",
		legs="Fili Rhingrave",
		feet="Fili Cothurnes",
		neck="Moonbow Whistle",
	}
    sets.midcast.Ballad = set_combine(sets.midcast.SongBuff, {})
    sets.midcast.Lullaby = set_combine(sets.midcast.SongBuff, {hands="Brioso Cuffs"})
    sets.midcast.Madrigal = set_combine(sets.midcast.SongBuff, {})
    sets.midcast.March = set_combine(sets.midcast.SongBuff, {})
    sets.midcast.Minuet = set_combine(sets.midcast.SongBuff, {})
    sets.midcast.Minne = set_combine(sets.midcast.SongBuff, {})
    sets.midcast.Paeon = set_combine(sets.midcast.SongBuff, {head="Brioso Roundlet"})
    sets.midcast.Carol = set_combine(sets.midcast.SongBuff, {})
    sets.midcast["Sentinel's Scherzo"] = set_combine(sets.midcast.SongBuff, {})
    
	sets.midcast['Magic Finale'] = {
		main="Legato Dagger",
		range="Gjallarhorn",
		head={ name="Chironic Hat", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','Haste+1','INT+8','Mag. Acc.+15',}},
		body="Fili Hongreline",
		hands="Fili Manchettes",
		legs="Fili Rhingrave",
		feet={ name="Chironic Slippers", augments={'Mag. Acc.+6 "Mag.Atk.Bns."+6','CHR+1','Mag. Acc.+12','"Mag.Atk.Bns."+12',}},
		neck="Moonbow Whistle",
		waist="Aswang Sash",
		left_ear="Aoidos' Earring",
		right_ear="Musical Earring",
		left_ring="Stikini Ring",
		right_ring="Renaye Ring",
		back="Ogapepo Cape",
	}

    sets.midcast.Mazurka = {range=info.ExtraSongInstrument}
    

    -- For song buffs (duration and AF3 set bonus)
    sets.midcast.SongEffect = set_combine(sets.midcast.SongBuff, {})

    -- For song defbuffs (duration primary, accuracy secondary)
    sets.midcast.SongDebuff = set_combine(sets.midcast['Magic Finale'], {})

    -- For song defbuffs (accuracy primary, duration secondary)
    sets.midcast.ResistantSongDebuff = set_combine(sets.midcast.SongDebuff, {})

    -- Song-specific recast reduction
    sets.midcast.SongRecast = {
		hands="Bewegt Cuffs",
		legs="Fili Rhingrave",
		back="Harmony Cape",
	}

    --sets.midcast.Daurdabla = set_combine(sets.midcast.FastRecast, sets.midcast.SongRecast, {range=info.ExtraSongInstrument})

    -- Cast spell with normal gear, except using Daurdabla instead
    sets.midcast.Daurdabla = {range=info.ExtraSongInstrument}

    -- Dummy song with Daurdabla; minimize duration to make it easy to overwrite.
    sets.midcast.DaurdablaDummy = set_combine(sets.midcast.SongDebuff, {
		main="Felibre's Dague",
		range=info.ExtraSongInstrument,
	})

    -- Other general spells and classes.
    sets.midcast.Cure = {
		head={ name="Kaykaus Mitra", augments={'MP+60','"Cure" spellcasting time -5%','Enmity-5',}},
		body="Vrikodara Jupon",
		hands={ name="Telchine Gloves", augments={'"Cure" spellcasting time -6%',}},
		legs="Gyve Trousers",
		feet={ name="Chironic Slippers", augments={'Mag. Acc.+6 "Mag.Atk.Bns."+6','CHR+1','Mag. Acc.+12','"Mag.Atk.Bns."+12',}},
		neck="Nodens Gorget",
		waist="Gishdubar Sash",
		left_ring="Stikini Ring",
		right_ring="Sirona's Ring",
		back="Solemnity Cape",
	}
        
    sets.midcast.Curaga = sets.midcast.Cure
        
    sets.midcast.Stoneskin = {
		neck="Nodens Gorget",
		waist="Siegel Sash"
	}
        
    sets.midcast.Cursna = {
		feet="Gendewitha Galoshes",
		back="Oretania's Cape +1",
		right_ring="Ephedra Ring",
		left_ring="Ephedra Ring",
	}

    
    -- Sets to return to when not performing an action.
    
    -- Resting sets
    sets.resting = set_combine(sets.idle, {})
    
    
    -- Idle sets (default idle set not needed since the other three are defined, but leaving for testing purposes)
    sets.idle = {
		range="Gjallarhorn",
		head="Aya. Zucchetto +1",
		body="Vrikodara Jupon",
		hands="Aya. Manopolas +1",
		legs="Assid. Pants +1",
		feet="Aya. Gambieras +1",
		neck="Sanctity Necklace",
		waist="Flume Belt",
		left_ear="Etiolation Earring",
		right_ear={ name="Moonshade Earring", augments={'Mag. Acc.+4','Latent effect: "Refresh"+1',}},
		left_ring="Moonbeam Ring",
		right_ring="Moonbeam Ring",
		back="Solemnity Cape",
	}

    sets.idle.PDT = set_combine(sets.idle, {
		
	})

    sets.idle.Town = set_combine(sets.idle, {
		
	})
    
    sets.idle.Weak = set_combine(sets.idle, {
		
	})
    
    
    -- Defense sets

    sets.defense.PDT = set_combine(sets.idle, {
		
	})

    sets.defense.MDT = set_combine(sets.idle, {
		
	})

    sets.Kiting = {feet="Fili Cothurnes"}

    sets.latent_refresh = {waist="Fucho-no-obi"}

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion
    
    -- Basic set for if no TP weapon is defined.
    sets.engaged = {
		main="Kustawi",
		sub="Genbu's Shield",
		range="Gjallarhorn",
		head="Aya. Zucchetto +1",
		body="Ayanmo Corazza +1",
		hands="Aya. Manopolas +1",
		legs="Aya. Cosciales +1",
		feet="Aya. Gambieras +1",
		neck="Maskirova Torque",
		waist="Cetl Belt",
		left_ear="Mache Earring",
		right_ear="Mache Earring",
		left_ring="Enlivened Ring",
		right_ring="Adler Ring",
		back="Bleating Mantle",
	}

    -- Sets with weapons defined.
    sets.engaged.Dagger = set_combine(sets.engaged, {
		main="Kustawi",
		sub="Genbu's Shield",
	})

    -- Set if dual-wielding
    sets.engaged.DW = set_combine(sets.engaged, {
		main="Kustawi",
		sub="Legato Dagger"
	})
end


-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    if spell.type == 'BardSong' then
        -- Auto-Pianissimo
        if ((spell.target.type == 'PLAYER' and not spell.target.charmed) or (spell.target.type == 'NPC' and spell.target.in_party)) and
            not state.Buff['Pianissimo'] then
            
            local spell_recasts = windower.ffxi.get_spell_recasts()
            if spell_recasts[spell.recast_id] < 2 then
                send_command('@input /ja "Pianissimo" <me>; wait 1.5; input /ma "'..spell.name..'" '..spell.target.name)
                eventArgs.cancel = true
                return
            end
        end
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_midcast(spell, action, spellMap, eventArgs)
    if spell.action_type == 'Magic' then
        if spell.type == 'BardSong' then
            -- layer general gear on first, then let default handler add song-specific gear.
            local generalClass = get_song_class(spell)
            if generalClass and sets.midcast[generalClass] then
                equip(sets.midcast[generalClass])
            end
        end
    end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.type == 'BardSong' then
        if state.ExtraSongsMode.value == 'FullLength' then
            equip(sets.midcast.Daurdabla)
        end

        state.ExtraSongsMode:reset()
    end
end

-- Set eventArgs.handled to true if we don't want automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.type == 'BardSong' and not spell.interrupted then
        if spell.target and spell.target.type == 'SELF' then
            adjust_timers(spell, spellMap)
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Handle notifications of general user state change.
function job_state_change(stateField, newValue, oldValue)
    if stateField == 'Offense Mode' then
        if newValue == 'Normal' then
            disable('main','sub','ammo')
        else
            enable('main','sub','ammo')
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Called by the 'update' self-command.
function job_update(cmdParams, eventArgs)
    pick_tp_weapon()
end


-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if player.mpp < 51 and S{'RDM','WHM','SCH','BLU','SMN','RUN','BLM','GEO'}:contains(player.sub_job) then
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


-- Function to display the current relevant user state when doing an update.
function display_current_job_state(eventArgs)
    display_current_caster_state()
    eventArgs.handled = true
end

-- custom self commands - example: //gs c dummysong Valor-Minute-VI
function job_self_command(commandArgs, eventArgs)
	if #commandArgs == 0 then
        add_to_chat(123, 'job_self_command.Error: Field not specified.')
        return
    end
	
	if commandArgs[1] == 'dummysong' then
		if commandArgs[2] == nil then 
			return
		end
		
		local newSpell = ""
		if #commandArgs > 2 then
			for i = 2, #commandArgs do
				newSpell = newSpell..commandArgs[i].." "
			end
		elseif string.match(commandArgs[2], "-") then
			newSpell = string.gsub(commandArgs[2], "-", " ")
		else
			newSpell = commandArgs[2]
		end
		newSpell = string.trim(newSpell)
		
		local oldSpell = info.ExtraSongSpellName
		info.ExtraSongSpellName = newSpell
		
		add_to_chat(122, 'ExtraSongSpellName set to: '..newSpell)
		
		eventArgs.handled = true
	end
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- Determine the custom class to use for the given song.
function get_song_class(spell)
    -- Can't use spell.targets:contains() because this is being pulled from resources
    if set.contains(spell.targets, 'Enemy') then
        if state.CastingMode.value == 'Resistant' then
            return 'ResistantSongDebuff'
        else
            return 'SongDebuff'
        end
    elseif state.ExtraSongsMode.value == 'Dummy' then
        return 'DaurdablaDummy'
	elseif state.ExtraSongSpell.current == 'on' and spell.english == info.ExtraSongSpellName then
		return 'DaurdablaDummy'
    else
        return 'SongEffect'
    end
end


-- Function to create custom buff-remaining timers with the Timers plugin,
-- keeping only the actual valid songs rather than spamming the default
-- buff remaining timers.
function adjust_timers(spell, spellMap)
    if state.UseCustomTimers.value == false then
        return
    end
    
    local current_time = os.time()
    
    -- custom_timers contains a table of song names, with the os time when they
    -- will expire.
    
    -- Eliminate songs that have already expired from our local list.
    local temp_timer_list = {}
    for song_name,expires in pairs(custom_timers) do
        if expires < current_time then
            temp_timer_list[song_name] = true
        end
    end
    for song_name,expires in pairs(temp_timer_list) do
        custom_timers[song_name] = nil
    end
    
    local dur = calculate_duration(spell.name, spellMap)
    if custom_timers[spell.name] then
        -- Songs always overwrite themselves now, unless the new song has
        -- less duration than the old one (ie: old one was NT version, new
        -- one has less duration than what's remaining).
        
        -- If new song will outlast the one in our list, replace it.
        if custom_timers[spell.name] < (current_time + dur) then
            send_command('timers delete "'..spell.name..'"')
            custom_timers[spell.name] = current_time + dur
            send_command('timers create "'..spell.name..'" '..dur..' down')
        end
    else
        -- Figure out how many songs we can maintain.
        local maxsongs = 2
        if player.equipment.range == info.ExtraSongInstrument then
            maxsongs = maxsongs + info.ExtraSongs
        end
        if buffactive['Clarion Call'] then
            maxsongs = maxsongs + 1
        end
        -- If we have more songs active than is currently apparent, we can still overwrite
        -- them while they're active, even if not using appropriate gear bonuses (ie: Daur).
        if maxsongs < table.length(custom_timers) then
            maxsongs = table.length(custom_timers)
        end
        
        -- Create or update new song timers.
        if table.length(custom_timers) < maxsongs then
            custom_timers[spell.name] = current_time + dur
            send_command('timers create "'..spell.name..'" '..dur..' down')
        else
            local rep,repsong
            for song_name,expires in pairs(custom_timers) do
                if current_time + dur > expires then
                    if not rep or rep > expires then
                        rep = expires
                        repsong = song_name
                    end
                end
            end
            if repsong then
                custom_timers[repsong] = nil
                send_command('timers delete "'..repsong..'"')
                custom_timers[spell.name] = current_time + dur
                send_command('timers create "'..spell.name..'" '..dur..' down')
            end
        end
    end
end

-- Function to calculate the duration of a song based on the equipment used to cast it.
-- Called from adjust_timers(), which is only called on aftercast().
function calculate_duration(spellName, spellMap)
    local mult = 1
    if player.equipment.range == 'Daurdabla' then mult = mult + 0.3 end -- change to 0.25 with 90 Daur
    if player.equipment.range == "Gjallarhorn" then mult = mult + 0.4 end -- change to 0.3 with 95 Gjall
    if player.equipment.range == "Marsyas" then mult = mult + 0.5 end
	
    if player.equipment.main == "Carnwenhan" then mult = mult + 0.1 end -- 0.1 for 75, 0.4 for 95, 0.5 for 99/119
    if player.equipment.main == "Legato Dagger" then mult = mult + 0.05 end
    if player.equipment.sub == "Legato Dagger" then mult = mult + 0.05 end
    if player.equipment.neck == "Aoidos' Matinee" then mult = mult + 0.1 end
    if player.equipment.body == "Fili Hongreline" then mult = mult + 0.1 end
    if player.equipment.legs == "Mdk. Shalwar +1" then mult = mult + 0.1 end
    if player.equipment.feet == "Brioso Slippers" then mult = mult + 0.1 end
    if player.equipment.feet == "Brioso Slippers +1" then mult = mult + 0.11 end
    
    if spellMap == 'Paeon' and player.equipment.head == "Brioso Roundlet" then mult = mult + 0.1 end
    if spellMap == 'Paeon' and player.equipment.head == "Brioso Roundlet +1" then mult = mult + 0.1 end
    if spellMap == 'Madrigal' and player.equipment.head == "Fili Calot" then mult = mult + 0.1 end
    if spellMap == 'Minuet' and player.equipment.body == "Fili Hongreline" then mult = mult + 0.1 end
    if spellMap == 'March' and player.equipment.hands == 'Fili Manchettes' then mult = mult + 0.1 end
    if spellMap == 'Ballad' and player.equipment.legs == "Fili Rhingrave" then mult = mult + 0.1 end
    if spellName == "Sentinel's Scherzo" and player.equipment.feet == "Fili Cothurnes" then mult = mult + 0.1 end
    
    if buffactive.Troubadour then
        mult = mult*2
    end
    if spellName == "Sentinel's Scherzo" then
        if buffactive['Soul Voice'] then
            mult = mult*2
        elseif buffactive['Marcato'] then
            mult = mult*1.5
        end
    end
    
    local totalDuration = math.floor(mult*120)

    return totalDuration
end


-- Examine equipment to determine what our current TP weapon is.
function pick_tp_weapon()
    if brd_daggers:contains(player.equipment.main) then
        state.CombatWeapon:set('Dagger')
        
        if S{'NIN','DNC'}:contains(player.sub_job) and brd_daggers:contains(player.equipment.sub) then
            state.CombatForm:set('DW')
        else
            state.CombatForm:reset()
        end
    else
        state.CombatWeapon:reset()
        state.CombatForm:reset()
    end
end

-- Function to reset timers.
function reset_timers()
    for i,v in pairs(custom_timers) do
        send_command('timers delete "'..i..'"')
    end
    custom_timers = {}
	reset_lullaby()
end


-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    set_macro_page(2, 18)
end


windower.raw_register_event('zone change',reset_timers)
windower.raw_register_event('logout',reset_timers)


--[[
  Custom TXT Box for Lullaby Duration
]]
  
--texts = require('texts')
res = require 'resources'
packets = require('packets')
  
lullaby_txt = {}
lullaby_txt.pos = {}
lullaby_txt.pos.x = -180
lullaby_txt.pos.y = 45
lullaby_txt.text = {}
lullaby_txt.text.font = 'Arial'
lullaby_txt.text.size = 10
lullaby_txt.flags = {}
lullaby_txt.flags.right = true
  
lullaby_box = texts.new('${value}', lullaby_txt)
  
  
local lullaby_list = {}
  
function reset_lullaby()
    for i,v in pairs(lullaby_list) do
        lullaby_list[i] = nil
    end
end
  
function new_lullaby(target, duration)
    local lullabytime = os.clock()
    local mob = windower.ffxi.get_mob_by_id(target)
    lullaby_list[target] = {start=lullabytime,lullabyduration=duration,x=mob.x,y=mob.y,z=mob.z}
end
  
function count_lullaby_list()
    local num = 0
        for i,v in pairs(lullaby_list) do
            num = num +1
        end
    return num
end
  
windower.raw_register_event('prerender', function()
    local t = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().target_index or 0)
    local mob_id,value
    if lullaby_list and count_lullaby_list() > 0 then 
        local lullaby_txtbox = 'Sleep List: '..count_lullaby_list()
        for mob_id,value in pairs(lullaby_list) do
            local mob = windower.ffxi.get_mob_by_id(mob_id)
              
            if mob then 
              
            if mob.x and value.x then 
                x_delta = mob.x - value.x
            else
                x_delta = 0
            end
            if mob.y and value.y then 
                y_delta = mob.y - value.y
            else
                y_delta = 0
            end
              
              
            if x_delta > 5 or x_delta < -5 or y_delta > 5 or y_delta < -5 then 
                lullaby_list[mob_id].lullabyduration = 0
            end
              
            local start_time = lullaby_list[mob_id].start
            local duration = lullaby_list[mob_id].lullabyduration
            local now = os.clock()  
            local remaining_time = string.format("%.1f", duration - (now - start_time))
              
            if mob.status == 1 or mob.status == 0 then 
                if t then
                    if t.id == mob_id then 
                        -- Print the txt in Green!
                        if duration - (now - start_time) < 0 then 
                            lullaby_txtbox = lullaby_txtbox.."\n\\cs(0,255,0)Mob: "..mob.name.." Awake!\\cs(255,255,255)" 
                        else
                            lullaby_txtbox = lullaby_txtbox.."\n\\cs(0,255,0)Mob: "..mob.name.." Is Asleep! Remaining:"..remaining_time.."\\cs(255,255,255)"
                        end
                    else
                        if duration - (now - start_time) < 0 then 
                            lullaby_txtbox = lullaby_txtbox.."\nMob: "..mob.name.." Awake!" 
                        else
                            lullaby_txtbox = lullaby_txtbox.."\nMob: "..mob.name.." Is Asleep! Remaining:"..remaining_time  
                        end
                    end
                else
                    if duration - (now - start_time) < 0 then 
                        lullaby_txtbox = lullaby_txtbox.."\nMob: "..mob.name.." Awake!" 
                    else
                        lullaby_txtbox = lullaby_txtbox.."\nMob: "..mob.name.." Is Asleep! Remaining:"..remaining_time  
                    end
                end
            else
                lullaby_list[mob_id] = nil
            end
            end
        end
        lullaby_box.value = lullaby_txtbox
        if state.LullabyList.value == "On" then
            lullaby_box:visible(true)
        else 
            lullaby_box:visible(false)
        end
    else
        lullaby_box:visible(false)
    end
end)
  
last_spell = ''
lullaby_spell_ids = S{376, 377, 463, 471}
  
windower.raw_register_event('incoming chunk', function(id,original,modified,injected,blocked)
    local self = windower.ffxi.get_player()
    if id == 0x028 then
        local packet = packets.parse('incoming', original)
        local now = os.clock()
          
        if packet['Category'] == 8 and packet.Actor == self.id then 
            last_spell = packet['Target 1 Action 1 Param']
        end
          
        if packet['Category'] == 4 and packet.Actor == self.id and lullaby_spell_ids:contains(last_spell) then
            local numtargets = packet['Target Count']
            local count = 0
              
            if packet.Actor == self.id then
                while count < numtargets do
                    count = count + 1
                    local target_id = packet['Target '..count..' ID']
                    local spell_duration = calculate_duration_raw(last_spell)
                    local message = packet['Target '..count..' Action 1 Message']
                    --print("Target ID:",target_id,message)
                    if message == 270 or message == 236 then 
                        new_lullaby(target_id, spell_duration)
                    end
                end
                  
            end
        end
        if lullaby_list[packet.Actor] and ((now - lullaby_list[packet.Actor].start) > 5) then 
            --lullaby_list[packet.Actor] = nil
            lullaby_list[packet.Actor] = {start=lullaby_list[packet.Actor].start,lullabyduration=0}
        end
    end
end)
  
function calculate_duration_raw(spell_id)
    local jobpointsspent = 0
    for k, v in pairs(player.job_points.brd) do
        jobpointsspent = jobpointsspent + (v^2 + v)/2
    end
     
    spell = res.spells[spell_id]
    local mult = 1
    if player.equipment.range == 'Daurdabla' then mult = mult + 0.3 end -- change to 0.25 with 90 Daur
    if player.equipment.range == "Gjallarhorn" then mult = mult + 0.4 end -- change to 0.3 with 95 Gjall
    if player.equipment.range == "Marsyas" then mult = mult + 0.5 end -- 
      
    if player.equipment.main == "Carnwenhan" then mult = mult + 0.5 end -- 0.1 for 75, 0.4 for 95, 0.5 for 99/119
    if player.equipment.main == "Legato Dagger" then mult = mult + 0.05 end
    if player.equipment.main == "Kali" then mult = mult + 0.05 end
    if player.equipment.sub == "Legato Dagger" then mult = mult + 0.05 end
    if player.equipment.neck == "Aoidos' Matinee" then mult = mult + 0.1 end
    if player.equipment.neck == "Moonbow Whistle" then mult = mult + 0.2 end 
	if player.equipment.legs == "Mdk. Shalwar +1" then mult = mult + 0.1 end
	if player.equipment.body == "Fili Hongreline" then mult = mult + 0.11 end
    if player.equipment.body == "Fili Hongreline +1" then mult = mult + 0.12 end
    if player.equipment.legs == "Inyanga Shalwar +1" then mult = mult + 0.15 end
    if player.equipment.feet == "Brioso Slippers" then mult = mult + 0.1 end
    if player.equipment.feet == "Brioso Slippers +1" then mult = mult + 0.11 end
    if player.equipment.feet == "Brioso Slippers +2" then mult = mult + 0.13 end
      
    if player.equipment.hands == 'Brioso Cuffs +1' then mult = mult + 0.1 end
     
    if jobpointsspent >= 1200 then
        mult = mult + 0.05
    end
      
    if buffactive.Troubadour then
        mult = mult*2
    end
      
    if spell.en == "Foe Lullaby II" or spell.en == "Horde Lullaby II" then 
        base = 60
    elseif spell.en == "Foe Lullaby" or spell.en == "Horde Lullaby" then 
        base = 30
    end
      
    totalDuration = math.floor(mult*base)       
      
    if jobpointsspent >= 1 then
    local player = windower.ffxi.get_player()
        -- add_to_chat(8,'Adding ' ..player.job_points.brd.lullaby_duration.. ' seconds to Timer for Lullaby Job Points')
        totalDuration = totalDuration + player.job_points.brd.lullaby_duration
        if buffactive['Clarion Call'] then
            -- add_to_chat(8,'Adding '..player.job_points.brd.clarion_call_effect * 2.. ' seconds to Timer for Clarion Call Job Points')
            totalDuration = totalDuration + (player.job_points.brd.clarion_call_effect * 2)
        end
        if buffactive['Tenuto'] then
            -- add_to_chat(8,'Adding '..player.job_points.brd.tenuto_effect..' seconds to Timer for Tenuto Job Points')
            totalDuration = totalDuration + player.job_points.brd.tenuto_effect
        end
        if buffactive['Marcato'] then
            -- add_to_chat(8,'Adding '..player.job_points.brd.marcato_effect..' seconds to Timer for Marcato Job Points')
            totalDuration = totalDuration + player.job_points.brd.marcato_effect
        end
    end
      
    return totalDuration
      
end

function set_lockstyle(num)
	send_command('wait 3; input /lockstyleset '..num)
end