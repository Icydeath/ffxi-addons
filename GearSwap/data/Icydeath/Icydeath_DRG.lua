-------------------------------------------------------------------------------------------------------------------
-- Initialization function that defines sets and variables to be used.
-------------------------------------------------------------------------------------------------------------------
 
-- IMPORTANT: Make sure to also get the Mote-Include.lua file (and its supplementary files) to go with this.
 
-- Initialization function for this job file.
function get_sets()
	mote_include_version = 2
	
	include('organizer-lib')
	-- Load and initialize the include file.
	include('Mote-Include.lua')
end
 
 
-- Setup vars that are user-independent.
function job_setup()
	--state.CombatForm = get_combat_form()
	state.Buff = {}
	state.AutoMode = M{['description'] = 'Auto Mode(default: On)'}
	state.AutoMode:options('On', 'Off')
	state.AutoWS = M{['description'] = 'Auto WS'}
	state.AutoWS:options('Camlann\'s Torment', 'Stardiver', 'Drakesbane')
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
	
	
end
 
 
-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
	-- Options: Override default values
	options.OffenseModes = {'Normal', 'Acc', 'Multi'}
	options.DefenseModes = {'Normal', 'PDT', 'Reraise'}
	options.WeaponskillModes = {'Normal', 'Acc', 'Att', 'Mod'}
	options.CastingModes = {'Normal'}
	options.IdleModes = {'Normal'}
	options.RestingModes = {'Normal'}
	options.PhysicalDefenseModes = {'PDT', 'Reraise'}
	options.MagicalDefenseModes = {'MDT'}
	 
	-- Additional local binds
	send_command('bind ^` input /ja "Hasso" <me>')
	send_command('bind !` input /ja "Seigan" <me>')

	--select_default_macro_book(1, 16)
	set_lockstyle('4')
end
 
 
-- Called when this job file is unloaded (eg: job change)
function file_unload()
	if binds_on_unload then
		binds_on_unload()
	end

	send_command('unbind ^`')
	send_command('unbind !-')
end
 
 
-- Define sets and vars used by this job file.
function init_gear_sets()
        --------------------------------------
        -- Start defining the sets
        --------------------------------------
		organizer_items = {
			polearm="Areadbhar",
			grip="Dilettante's Grip +1",
		}
		
        -- Precast Sets
        -- Precast sets to enhance JAs
        sets.precast.JA.Angon = {ammo="Angon",hands="Pteroslaver Finger Gauntlets",right_ear="Dragoon's Earring"}
        sets.precast.JA['Ancient Circle'] = {legs="Vishap Brais +1"}
		
		-- Jump: base damage (+fSTR) multiplier of (1 + VIT/256)
		-- DA and TA can proc
		sets.precast.JA.Jump = { 
			ammo="Vanir Battery",
			head="Sulevia's Mask +1",
			body="Vishap Mail +1",
			hands="Vishap F. G. +1",
			legs="Sulevi. Cuisses +1",
			feet="Vishap Greaves +1",
			neck="Asperity Necklace",
			waist="Windbuffet Belt +1",
			left_ear="Cessance Earring",
			right_ear="Brutal Earring",
			left_ring="Petrov Ring",
			right_ring="Oneiros Ring",
			back="Brigantia's Mantle",
		}
        sets.precast.JA['High Jump'] = set_combine(sets.precast.JA.Jump, {
			legs="Vishap Brais +1",
		})
		sets.precast.JA['Spirit Jump'] = set_combine(sets.precast.JA.Jump, {
			legs="Peltast's Cuissots",
			feet="Peltast's Schynbalds",
		})
        sets.precast.JA['Soul Jump'] = set_combine(sets.precast.JA['Spirit Jump'], {
			feet="Vishap Greaves +1",
		})
        sets.precast.JA['Super Jump'] = {}
		
		
		-- Restores ( Player HP Lost + MND + α )×2 HP to the Wyvern
			-- "α" = Wyvern Level × 0.7
        sets.precast.JA['Spirit Link'] = {
			head="Vishap Armet +1",
			body="Sulevia's Plate. +1",
			hands="Peltast's Vambraces +1",
			legs="Sulevi. Cuisses +1",
			feet="Pteroslaver Greaves",
			left_ear="Lifestorm Earring",
			left_ring="Globidonta Ring",
			back="Brigantia's Mantle",
		}
        sets.precast.JA['Call Wyvern'] = {
			head={ name="Ptero. Armet", augments={'Enhances "Deep Breathing" effect',}},
			body={ name="Pteroslaver Mail", augments={'Enhances "Spirit Surge" effect',}},
			hands={ name="Ptero. Fin. Gaunt.", augments={'Enhances "Angon" effect',}},
			legs="Vishap Brais +1",
			feet={ name="Ptero. Greaves", augments={'Enhances "Empathy" effect',}},
			back={ name="Updraft Mantle", augments={'STR+1','Pet: Breath+3','Weapon skill damage +3%',}},
		}
        sets.precast.JA['Deep Breathing'] = { 
			head={ name="Ptero. Armet", augments={'Enhances "Deep Breathing" effect',}} 
		}
        sets.precast.JA['Spirit Surge'] = { 
			body={ name="Pteroslaver Mail", augments={'Enhances "Spirit Surge" effect',}} 
		}
 
       
        -- Healing Breath sets
		--	HP Recovered = [[(Wyvern HP)*(Breath Multiplier)] + HBB]
		--	Breath Multiplier = Σ(HBV + Enhances Breath Equipment + Deep Breathing Modifier)
		--	Deep Breathing Modifier = (DB + Additional DB Merits + Augment DB)
		--	DB = (50/256) When Deep Breathing is active Additional DB Merits = ??? per merit after the first Augment DB = (5/256) per merit including the first 
        sets.HB = { }
        sets.HB.Pre = { 
			head="Vishap Armet +1",
			waist="Glassblower's Belt",
		}
        sets.HB.Mid = {
			head={ name="Ptero. Armet", augments={'Enhances "Deep Breathing" effect',}},
			neck="Lancer's Torque",
			back="Brigantia's Mantle",
			waist="Glassblower's Belt",
		}
               
        -- Waltz set (chr and vit)
        sets.precast.Waltz = {
			
		}
               
        -- Don't need any special gear for Healing Waltz.
        sets.precast.Waltz['Healing Waltz'] = {}
 
        sets.midcast.Breath = set_combine(sets.HB.Mid, { })
       
        -- Fast cast sets for spells
        sets.precast.FC = {
			ammo="Impatiens",
			head={ name="Carmine Mask", augments={'Accuracy+15','Mag. Acc.+10','"Fast Cast"+3',}},
			left_ear="Enchntr. Earring +1",
			right_ear="Loquac. Earring",
			left_ring="Prolix Ring",
			right_ring="Veneficium Ring",
		}
   
        -- Midcast Sets
        sets.midcast.FastRecast = {
			
		}     
               
        -- Weaponskill sets
        -- Default set for any weaponskill that isn't any more specifically defined
        --sets.precast.WS = {}
		sets.precast.WS = {
			ammo="Ginsen",
			head={ name="Valorous Mask", augments={'Accuracy+29','Weapon skill damage +1%','VIT+7','Attack+15',}},
			body={ name="Found. Breastplate", augments={'Accuracy+14','Mag. Acc.+13','Attack+14','"Mag.Atk.Bns."+14',}},
			hands={ name="Valorous Mitts", augments={'Accuracy+16','Crit. hit damage +3%','STR+3',}},
			legs="Sulevi. Cuisses +1",
			feet={ name="Valorous Greaves", augments={'Attack+26','Crit. hit damage +2%','STR+6','Accuracy+10',}},
			neck="Fotia Gorget",
			waist="Fotia Belt",
			left_ear="Cessance Earring",
			right_ear={ name="Moonshade Earring", augments={'"Mag.Atk.Bns."+4','TP Bonus +25',}},
			left_ring="Petrov Ring",
			right_ring="Begrudging Ring",
			back={ name="Updraft Mantle", augments={'STR+1','Pet: Breath+3','Weapon skill damage +3%',}},
		}
        
		sets.precast.WS.Acc = set_combine(sets.precast.WS, {
			
		})
		
        -- 73~85% STR
        sets.precast.WS['Stardiver'] = set_combine(sets.precast.WS, {
			
		})
        sets.precast.WS['Stardiver'].Acc = set_combine(sets.precast.WS, {
			
		})
        sets.precast.WS['Stardiver'].Mod = set_combine(sets.precast.WS, {
			
		})
 
		-- 50% STR
        sets.precast.WS['Drakesbane'] = set_combine(sets.precast.WS, {
			
		})
        sets.precast.WS['Drakesbane'].Acc = set_combine(sets.precast.WS, {
			
		})
        sets.precast.WS['Drakesbane'].Mod = set_combine(sets.precast.WS, {
			
		})
		
		-- 60% STR 60% VIT
		sets.precast.WS['Camlann\'s Torment'] = set_combine(sets.precast.WS, {
			
		})
        sets.precast.WS['Camlann\'s Torment'].Acc = set_combine(sets.precast.WS, {
			
		})
        sets.precast.WS['Camlann\'s Torment'].Mod = set_combine(sets.precast.WS, {
			
		})
		
		-- [Dagger] 73~85% AGI
        sets.precast.WS['Exenterator'] = set_combine(sets.precast.WS, {
			
		})
       
        -- Sets to return to when not performing an action.
       
        -- Resting sets
        sets.resting = { }
       
 
        -- Idle sets
        sets.idle = {
			ammo="Vanir Battery",
			head="Sulevia's Mask +1",
			body="Sulevia's Plate. +1",
			hands="Sulev. Gauntlets +1",
			legs="Sulevi. Cuisses +1",
			feet="Sulev. Leggings +1",
			neck="Sanctity Necklace",
			waist="Flume Belt +1",
			left_ear="Infused Earring",
			right_ear="Etiolation Earring",
			left_ring="Paguroidea Ring",
			right_ring="Sheltered Ring",
			back="Xucau Mantle",
		}
 
        -- Idle sets (default idle set not needed since the other three are defined, but leaving for testing purposes)
        sets.idle.Town = set_combine(sets.idle, { })
       
        sets.idle.Field = set_combine(sets.idle, { })
 
        sets.idle.Weak = set_combine(sets.idle, { })
		
        -- Defense sets
		sets.defense = { }
        sets.defense.PDT = { }
 
        sets.defense.Reraise = { }
 
        sets.defense.MDT = { }
 
        sets.Kiting = { }
 
        sets.Reraise = {head="Twilight Helm",body="Twilight Mail"}
 
        -- Engaged sets
 
        -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
        -- sets if more refined versions aren't defined.
        -- If you create a set with both offense and defense modes, the offense mode should be first.
        -- EG: sets.engaged.Dagger.Accuracy.Evasion
       
        -- Normal melee group
        sets.engaged = {
			ammo="Hasty Pinion +1",
			head={ name="Valorous Mask", augments={'Accuracy+29','Weapon skill damage +1%','VIT+7','Attack+15',}},
			body={ name="Found. Breastplate", augments={'Accuracy+14','Mag. Acc.+13','Attack+14','"Mag.Atk.Bns."+14',}},
			hands="Sulev. Gauntlets +1",
			legs={ name="Valor. Hose", augments={'"Dbl.Atk."+3','AGI+5','Accuracy+11','Attack+8',}},
			feet={ name="Valorous Greaves", augments={'Accuracy+30','"Dbl.Atk."+1','DEX+1','Attack+7',}},
			neck="Lissome Necklace",
			waist="Kentarch Belt +1",
			left_ear="Cessance Earring",
			right_ear="Brutal Earring",
			left_ring="Petrov Ring",
			right_ring="Hetairoi Ring",
			back={ name="Updraft Mantle", augments={'STR+1','Pet: Breath+3','Weapon skill damage +3%',}},
		}
        sets.engaged.Acc = set_combine(sets.engaged, { })
		
        sets.engaged.Multi = set_combine(sets.engaged, { })
        sets.engaged.Multi.PDT = set_combine(sets.engaged, { })
        sets.engaged.Multi.Reraise = set_combine(sets.engaged, { })
        sets.engaged.PDT = set_combine(sets.engaged, { })
        sets.engaged.Acc.PDT = set_combine(sets.engaged, { })
        sets.engaged.Reraise = set_combine(sets.engaged, { })
        sets.engaged.Acc.Reraise = set_combine(sets.engaged, { })
               
        -- Melee sets for in Adoulin, which has an extra 2% Haste from Ionis.
        sets.engaged.Adoulin = set_combine(sets.engaged, { })
        sets.engaged.Adoulin.Acc = set_combine(sets.engaged, { })
        sets.engaged.Adoulin.Multi = set_combine(sets.engaged, { })
        sets.engaged.Adoulin.Multi.PDT = set_combine(sets.engaged, { })
        sets.engaged.Adoulin.Multi.Reraise = set_combine(sets.engaged, { })
        sets.engaged.Adoulin.PDT = set_combine(sets.engaged, { })
        sets.engaged.Adoulin.Acc.PDT = set_combine(sets.engaged, { })
        sets.engaged.Adoulin.Reraise = set_combine(sets.engaged, { })
        sets.engaged.Adoulin.Acc.Reraise = set_combine(sets.engaged, { })
 
end
 
-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks that are called to process player actions at specific points in time.
-------------------------------------------------------------------------------------------------------------------
 
-- Set eventArgs.handled to true if we don't want any automatic target handling to be done.
function job_pretarget(spell, action, spellMap, eventArgs)
 
end
 
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
	if spell.action_type == 'Magic' then
		equip(sets.precast.FC)
	end
	
	if spell.name == 'Spirit Jump' and not pet.isvalid then
		add_to_chat(158,'No Wyvern, using [Jump]')
		windower.send_command('Jump')
		cancel_spell()
		return
	elseif spell.name == 'Soul Jump' and not pet.isvalid then
		add_to_chat(158,'No Wyvern, using [High Jump]')
		windower.send_command('High Jump')
		cancel_spell()
		return
	elseif spell.name == 'Jump' and pet.isvalid then
		add_to_chat(158,'Wyvern alive, using [Spirit Jump]')
		windower.send_command('Spirit Jump')
		cancel_spell()
		return
	elseif spell.name == 'High Jump' and pet.isvalid then
		add_to_chat(158,'Wyvern alive, using [Soul Jump]')
		windower.send_command('Soul Jump')
		cancel_spell()
		return		
	end
end
 
-- Run after the default precast() is done.
-- eventArgs is the same one used in job_precast, in case information needs to be persisted.
function job_post_precast(spell, action, spellMap, eventArgs)
 
end
 
 
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_midcast(spell, action, spellMap, eventArgs)
	if spell.action_type == 'Magic' then
		equip(sets.midcast.FastRecast)
		if player.hpp < 51 then
			classes.CustomClass = "Breath" -- This would cause it to look for sets.midcast.Breath
		end
	end
end
 
-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
       
end
 
-- Runs when a pet initiates an action.
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_pet_midcast(spell, action, spellMap, eventArgs)
	if spell.english:startswith('Healing Breath') or spell.english == 'Restoring Breath' then
		equip(sets.HB.Mid)
	end
end
 
-- Run after the default pet midcast() is done.
-- eventArgs is the same one used in job_pet_midcast, in case information needs to be persisted.
function job_pet_post_midcast(spell, action, spellMap, eventArgs)
       
end
 
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
	--if state.DefenseMode == 'Reraise' or (state.Defense.Active and state.Defense.Type == 'Physical' and state.Defense.PhysicalMode == 'Reraise') then
	--end
end
 
-- Run after the default aftercast() is done.
-- eventArgs is the same one used in job_aftercast, in case information needs to be persisted.
function job_post_aftercast(spell, action, spellMap, eventArgs)
 
end
 
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_pet_aftercast(spell, action, spellMap, eventArgs)
 
end
 
-- Run after the default pet aftercast() is done.
-- eventArgs is the same one used in job_pet_aftercast, in case information needs to be persisted.
function job_pet_post_aftercast(spell, action, spellMap, eventArgs)
 
end
 
 
-------------------------------------------------------------------------------------------------------------------
-- Customization hooks for idle and melee sets, after they've been automatically constructed.
-------------------------------------------------------------------------------------------------------------------
 
-- Called before the Include starts constructing melee/idle/resting sets.
-- Can customize state or custom melee class values at this point.
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_handle_equipping_gear(status, eventArgs)
 
end
 
-- Return a customized weaponskill mode to use for weaponskill sets.
-- Don't return anything if you're not overriding the default value.
function get_custom_wsmode(spell, action, spellMap)
 
end
 
-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
	return idleSet
end
 
-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
	return meleeSet
end
 
-------------------------------------------------------------------------------------------------------------------
-- General hooks for other events.
-------------------------------------------------------------------------------------------------------------------
 
-- Called when the player's status changes.
function job_status_change(newStatus, oldStatus, eventArgs)
 
end
 
-- Called when the player's pet's status changes.
function job_pet_status_change(newStatus, oldStatus, eventArgs)
 
end
 
-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
 
end
 
function job_update(cmdParams, eventArgs)
	--state.CombatForm = get_combat_form()
end
-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------
 
-- Called for custom player commands.
function job_self_command(cmdParams, eventArgs)
 
end
 
--function get_combat_form()
--      if areas.Adoulin:contains(world.area) and buffactive.ionis then
--              return 'Adoulin'
--      end
--end
 
-- Called by the 'update' self-command, for common needs.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(cmdParams, eventArgs)
	classes.CustomMeleeGroups:clear()
	if areas.Adoulin:contains(world.area) and buffactive.ionis then
		classes.CustomMeleeGroups:append('Adoulin')
	end
end
 
-- Job-specific toggles.
function job_toggle(field)
 
end
 
-- Request job-specific mode lists.
-- Return the list, and the current value for the requested field.
function job_get_mode_list(field)
 
end
 
-- Set job-specific mode values.
-- Return true if we recognize and set the requested field.
function job_set_mode(field, val)
 
end
 
-- Handle auto-targetting based on local setup.
function job_auto_change_target(spell, action, spellMap, eventArgs)
 
end
 
-- Handle notifications of user state values being changed.
function job_state_change(stateField, newValue)
 
end
 
-- Set eventArgs.handled to true if we don't want the automatic display to be run.
function display_current_job_state(eventArgs)
 
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


--[[ Author: Arcon
		The three next "do" sections are used to aid in checking recast
		times, can check multiple recast times at once ]]
do
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
-- DEFAULT: On
-- Uses call wyvern and hasso (if subbed sam)
function relaxed_play_mode()
    -- This can be used as a mini bot to automate actions
    if not midaction() and player.status == 'Engaged' then
        --[[
		if player.hpp < state.SelfCureWhenBelow.value 
				and not check_buffs('silence', 'mute') then
            select_self_cure()
		]]--
        if player.sub_job == 'SAM' 
				and not check_buffs('Hasso')
				and not check_buffs('Seigan')
                and not check_buffs('amnesia')
                and check_recasts(s('Hasso')) then
            windower.send_command('Hasso')
		elseif player.tp > 999
				and player.target.hpp ~= nil
				and player.target.hpp > 0
                and player.target.distance < 6 
				and not check_buffs('amnesia') then
            windower.send_command(state.AutoWS.value)
		--[[
        elseif check_recasts(s('Call Wyvern'))
                and not check_buffs('amnesia')
                and not pet.isvalid then
            windower.send_command('Call Wyvern')
		]]--
        end
		
    end
	
end

function select_self_cure()
	if player.sub_job == 'BLU' then
		if check_set_spells('Wild Carrot') 
				and check_recasts(s('Wild Carrot')) 
				and player.mp >= 37 then
			windower.send_command('input /ma "Wild Carrot" <me>')
			
		elseif check_set_spells('Healing Breeze') 
				and check_recasts(s('Healing Breeze')) 
				and player.mp >= 55 then
			windower.send_command('input /ma "Healing Breeze" <me>')
		else
			windower.add_to_chat(8,'WARNING: No Cure spell is currently set!')
		end
	else
		if player.sub_job == 'RDM' then
			if check_recasts(s('Cure IV')) 
					and player.mp > 88 then
				windower.send_command('input /ma "Cure IV" <me>')
				
			elseif check_recasts(s('Cure III')) 
					and player.mp > 46 then
				windower.send_command('input /ma "Cure III" <me>')
				
			else
				windower.add_to_chat(8,'WARNING: Unable to self cure!')
				
			end
		else
			windower.add_to_chat(8,'WARNING: No Cure spell is currently set!')
		end
	end
end
-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------
function select_default_macro_book()
	set_macro_page(1, 16)
end


function set_lockstyle(num)
	send_command('wait 2; input /lockstyleset '..num)
end