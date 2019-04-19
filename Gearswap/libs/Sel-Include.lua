-------------------------------------------------------------------------------------------------------------------
-- Much of these files have been adapted from Motenten's base files, much credit goes to him,
-- I have started to rename his files so that they don't get modified whenever the Windower
-- team very rarely decides to update his old files.
-- Common variables and functions to be included in job scripts, for general default handling.
--
-- Include this file in the get_sets() function with the command:
-- include('Sel-Include.lua')
--
-- It will then automatically run its own init_include() function.
--
-- IMPORTANT: This include requires supporting include files:
-- Sel-Utility
-- Sel-Mappings
-- Sel-SelfCommands
-- Sel-Globals
--
-- Place the include() directive at the start of a job's get_sets() function.
--
-- Included variables and functions are considered to be at the same scope level as
-- the job script itself, and can be used as such.
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- Initialization function that defines variables to be used.
-- These are accessible at the including job lua script's scope.
--
-- Auto-initialize after defining this function.
-------------------------------------------------------------------------------------------------------------------

function init_include()
	extdata = require("extdata")
	res = require ("resources")
	
	--Snaps's Rnghelper extension for automatic ranged attacks that should be superior to my implementation.
	require('Snaps-RngHelper')

    -- Used to define various types of data mappings.  These may be used in the initialization, so load it up front.
    include('Sel-Mappings')
    
    -- Modes is the include for a mode-tracking variable class.  Used for state vars, below.
    include('Modes')
	
	-- Adding Organizer for gear management.
	include('organizer-lib.lua')
	
    -- Var for tracking state values
    state = {}

	--My Auto-Stun/Reaction module for gearswap, must come after state is defined.
	include('Sel-Stahp.lua')
	
	--Making Extdata/Resources dependant functions work
	cp_delay = 20

    -- General melee offense/defense modes, allowing for hybrid set builds, as well as idle/resting/weaponskill.
    -- This just defines the vars and sets the descriptions.  List modes with no values automatically
    -- get assigned a 'Normal' default value.
	state.OffenseMode         = M{['description'] = 'Offense Mode'}
	state.HybridMode          = M{['description'] = 'Hybrid Mode'}
	state.RangedMode          = M{['description'] = 'Ranged Mode'}
	state.WeaponskillMode     = M{['description'] = 'Weaponskill Mode','Match'}
	state.CastingMode         = M{['description'] = 'Casting Mode'}
	state.IdleMode            = M{['description'] = 'Idle Mode'}
	state.RestingMode         = M{['description'] = 'Resting Mode'}

	state.DefenseMode         = M{['description'] = 'Defense Mode', 'None', 'Physical', 'Magical', 'Resist'}
	state.PhysicalDefenseMode = M{['description'] = 'Physical Defense Mode', 'PDT'}
	state.MagicalDefenseMode  = M{['description'] = 'Magical Defense Mode', 'MDT'}
	state.ResistDefenseMode   = M{['description'] = 'Resistance Defense Mode', 'MEVA'}
	
	state.Passive   		  = M{['description'] = 'Passive Mode','None'}
	state.Kiting              = M(false, 'Kiting')
	state.SelectNPCTargets    = M(false, 'Select NPC Targets')
	state.Capacity 			  = M(false, 'Capacity Mode')
	state.ReEquip 			  = M(false, 'ReEquip Mode')
	state.AutoArts	 		  = M(false, 'AutoArts Mode')
	state.AutoTrustMode 	  = M(false, 'Auto Trust Mode')
	state.RngHelper		 	  = M(false, 'RngHelper')
	state.AutoTankMode 		  = M(false, 'Auto Tank Mode')
	state.AutoAcceptRaiseMode = M(false, 'Auto Accept Raise Mode')
	state.AutoNukeMode 		  = M(false, 'Auto Nuke Mode')
	state.AutoRuneMode 		  = M(false, 'Auto Rune Mode')
	state.AutoShadowMode 	  = M(false, 'Auto Shadow Mode')
	state.AutoContradanceMode = M(true, 'Auto Contradance Mode')
	state.AutoHolyWaterMode   = M(true, 'Auto Holy Water Mode')
	state.AutoRemoveDoomMode  = M(true, 'Auto Remove Doom Mode')
	state.AutoWSMode		  = M(false, 'Auto Weaponskill Mode')
	state.AutoFoodMode		  = M(false, 'Auto Food Mode')
	state.AutoSubMode 		  = M(false, 'Auto Sublimation Mode')
	state.AutoBuffMode 		  = M(false, 'Auto Buff Mode')
	state.AutoCleanupMode  	  = M(false, 'Auto Cleanup Mode')
	state.DisplayMode  	  	  = M(true, 'Display Mode')
	state.UseCustomTimers 	  = M(true, 'Use Custom Timers')
	state.CancelStoneskin	  = M(true, 'Auto Cancel Stoneskin')
	state.BlockMidaction	  = M(true, 'Block Midaction')
	state.MaintainAftermath	  = M(true, 'Maintain Aftermath')
	state.ElementalWheel 	  = M(false, 'Elemental Wheel')
	state.MaintainDefense 	  = M(false, 'Maintain Defense')
	state.SkipProcWeapons 	  = M(false, 'Skip Proc Weapons')
	state.NotifyBuffs		  = M(false, 'Notify Buffs')
	
	state.RuneElement 		  = M{['description'] = 'Rune Element','Ignis','Gelus','Flabra','Tellus','Sulpor','Unda','Lux','Tenebrae'}
	state.ElementalMode 	  = M{['description'] = 'Elemental Mode', 'Fire','Ice','Wind','Earth','Lightning','Water','Light','Dark'}
	state.AutoSambaMode 	  = M{['description']= 'Auto Samba Mode', 'Off', 'Haste Samba', 'Aspir Samba', 'Drain Samba II'}

	state.MagicBurstMode 	  = M{['description'] = 'Magic Burst Mode', 'Off', 'Single', 'Lock'}
	state.SkillchainMode 	  = M{['description'] = 'Skillchain Mode', 'Off', 'Single', 'Lock'}
	state.PCTargetMode        = M{['description'] = 'PC Target Mode', 'default', 'stpt', 'stal', 'stpc'}
	state.EquipStop           = M{['description'] = 'Stop Equipping Gear', 'off', 'precast', 'midcast', 'pet_midcast'}
	state.CombatWeapon        = M{['description']='Combat Weapon', ['string']=''}
	state.CombatForm          = M{['description']='Combat Form', ['string']=''}
	
	NotifyBuffs = S{}
	
	if mageJobs:contains(player.main_job) then
		state.Weapons		  = M{['description'] = 'Weapons','None','Weapons'}
	else
		state.Weapons		  = M{['description'] = 'Weapons','Weapons','None'}
	end
	
    -- Non-mode vars that are used for state tracking.
    state.MaxWeaponskillDistance = 0
    state.Buff = {}
	
	--Tracking these here because required quick actions on multiple jobs.
	state.Buff['Light Arts'] = buffactive['Light Arts'] or false
	state.Buff['Addendum: White'] = buffactive['Addendum: White'] or false
	state.Buff['Dark Arts'] = buffactive['Dark Arts'] or false
	state.Buff['Addendum: Black'] = buffactive['Addendum: Black'] or false
	state.Buff['Accession'] = buffactive['Accession'] or false
	state.Buff['Warcry'] = buffactive['Warcry'] or false

    -- Classes describe a 'type' of action.  They are similar to state, but
    -- may have any free-form value, or describe an entire table of mapped values.
    classes = {}
    -- Basic spell mappings are based on common spell series.
    -- EG: 'Cure' for Cure, Cure II, Cure III, Cure IV, Cure V, or Cure VI.
    classes.SpellMaps = spell_maps
    -- List of spells and spell maps that don't benefit from greater skill (though
    -- they may benefit from spell-specific augments, such as improved regen or refresh).
    -- Spells that fall under this category will be skipped when searching for
    -- spell.skill sets.
    classes.NoSkillSpells = no_skill_spells_list
    classes.SkipSkillCheck = false
    -- Custom, job-defined class, like the generic spell mappings.
    -- Takes precedence over default spell maps.
    -- Is reset at the end of each spell casting cycle (ie: at the end of aftercast).
    classes.JAMode = nil
    classes.CustomClass = nil
    -- Custom groups used for defining melee and idle sets.  Persists long-term.
    classes.CustomMeleeGroups = L{}
    classes.CustomRangedGroups = L{}
    classes.CustomIdleGroups = L{}
    classes.CustomDefenseGroups = L{}

    -- Class variables for time-based flags
    classes.Daytime = false
    classes.DuskToDawn = false
	
    -- Var for tracking misc info
    info = {}
    options = {}

    -- Special control flags.
    mote_vars = {}
    mote_vars.set_breadcrumbs = L{}
    mote_vars.res_buffs = S{}
    for index,struct in pairs(gearswap.res.buffs) do
        mote_vars.res_buffs:add(struct.en)
    end
	
	-- Define and default variables for global functions that can be overwritten.
	useItem = false
	useItemName = ''
	useItemSlot = ''
	
	autonuke = 'Fire'
	autows = ''
	rangedautows = ''
	autowstp = 1000
	rangedautowstp = 1000
	time_offset = -39602
	framerate = 60
	latency = .75
	spell_latency = nil
	buffup = ''
	curecheat = false
	lastincombat = player.in_combat
	next_cast = 0
	delayed_cast = ''
	delayed_target = ''
	
	time_test = false
	utsusemi_cancel_delay = .5
	conserveshadows = true
	
	-- Buff tracking that buffactive can't detect
	lastshadow = "Utsusemi: San"
	lastwarcry = ''
	lasthaste = 1
	lastflurry = 1
	
    -- Sub-tables within the sets table that we expect to exist, and are annoying to have to
    -- define within each individual job file.  We can define them here to make sure we don't
    -- have to check for existence.  The job file should be including this before defining
    -- any sets, so any changes it makes will override these anyway.
    sets.precast = {}
    sets.precast.FC = {}
    sets.precast.JA = {}
    sets.precast.WS = {}
    sets.precast.RA = {}
	sets.precast.Item = {}
    sets.midcast = {}
    sets.midcast.RA = {}
    sets.midcast.Pet = {}
    sets.idle = {}
    sets.resting = {}
    sets.engaged = {}
    sets.defense = {}
    sets.buff = {}
	sets.element = {}
	sets.passive = {}
	sets.weapons = {}

	sets.DuskIdle = {}
	sets.DayIdle = {}
	sets.NightIdle = {}
	
    gear = {}
    gear.default = {}

    gear.ElementalGorget = {name=""}
    gear.ElementalBelt = {name=""}
    gear.ElementalObi = {name=""}
    gear.ElementalCape = {name=""}
    gear.ElementalRing = {name=""}
    gear.FastcastStaff = {name=""}
    gear.RecastStaff = {name=""}

    -- Load externally-defined information (info that we don't want to change every time this file is updated).

    -- Used to define misc utility functions that may be useful for this include or any job files.
    include('Sel-Utility')

    -- Used for all self-command handling.
    include('Sel-SelfCommands')
	include('Sel-TreasureHunter')

    -- Include general user globals, such as custom binds or gear tables.
    -- Load Sel-Globals first, followed by User-Globals, followed by <character>-Globals.
    -- Any functions re-defined in the later includes will overwrite the earlier versions.
    include('Sel-GlobalItems')
    optional_include('user-globals.lua')
    optional_include(player.name..'-globals.lua')
    optional_include(player.name..'-items.lua')
	optional_include(player.name..'_Crafting.lua')

	-- New Display functions, needs to come after globals for user settings.
	include('Sel-Display.lua')


    -- Global default binds
    global_on_load()

    -- Load sidecar file
	include(player.name..'_'..player.main_job..'_gear.lua')

	
	-- Controls for handling our autmatic functions.
	
	tickdelay = os.clock() + 5
	
	if spell_latency == nil then
		spell_latency = (latency + .05)
	end
	
	-- General var initialization and setup.
    if job_setup then
        job_setup()
    end

    -- User-specific var initialization and setup.
    if user_setup then
        user_setup()
    end
	
	if extra_user_setup then
        extra_user_setup()
    end

	if state.Weapons.value == 'None' then
		enable('main','sub','range','ammo')
	else
		send_command('@wait 3;gs c weapons Default')
	end
	
	-- Event register to watch incoming items.
	windower.raw_register_event('add item', function(bag, index, id, count)
		if id == 4146 and world.area == "Ghoyu's Reverie" then --4146 Revitalizer ID
			useItem = true
			useItemName = 'Revitalizer'
			useItemSlot = 'item'
			add_to_chat(217,"Revitalizer added to inventory, using, /heal to cancel.")
		end
	end)
	
	-- Event register to make time variables track.
	windower.raw_register_event('time change', time_change)

	-- Event register to perform actions on new targets.
	function target_change(new)
	
		if state.RngHelper.value then
			send_command('gs rh clear')
		end
	
		local target = windower.ffxi.get_mob_by_target('t')
		local sub= windower.ffxi.get_mob_by_target('st')
		if (target ~= nil) and (sub == nil) then
			if state.AutoCleanupMode.value and math.sqrt(target.distance) < 7 then
				if target.name == "Runje Desaali" then 
					for i in pairs(bayld_items) do
						if player.inventory[bayld_items[i]] then
							windower.chat.input('/item "'..bayld_items[i]..'" <t>')
							windower.chat.input:schedule(2,'/targetnpc')
							return
						end
					end
				elseif target.name == "Sturdy Pyxis" and player.inventory['Forbidden Key'] then
					windower.chat.input('/item "Forbidden Key" <t>')
				end
			end
		end
		
		if user_job_target_change then
			if user_job_target_change(target) then return end
		end
		
		if user_target_change then
			if user_job_target_change(target) then return end
		end
	end
	windower.raw_register_event('target change', target_change)

	-- Event register to prevent auto-modes from spamming after zoning.
	windower.register_event('zone change', function()
		tickdelay = os.clock() + 10
		state.AutoBuffMode:reset()
		state.AutoSubMode:reset()
		state.AutoTrustMode:reset()
		state.AutoTankMode:reset()
		state.AutoRuneMode:reset()
		state.AutoFoodMode:reset()
		state.AutoWSMode:reset()
		state.AutoNukeMode:reset()
		useItem = false
		useItemName = ''
		useItemSlot = ''
		lastincombat = false
		being_attacked = false
		
		if world.area:contains('Abyssea') or areas.ProcZones:contains(world.area) then
			state.SkipProcWeapons:set('False')
		else
			state.SkipProcWeapons:reset()
		end
		
		if state.DisplayMode.value then update_job_states()	end
	end)

	-- New implementation of tick.
	windower.raw_register_event('prerender', function()
		if not (os.clock() > tickdelay) then return end
		
		gearswap.refresh_globals(false)
		
		if (player ~= nil) and (player.status == 'Idle' or player.status == 'Engaged') and not (check_midaction() or moving or buffactive['Sneak'] or buffactive['Invisible'] or silent_check_disable()) then
			if pre_tick then
				if pre_tick() then return end
			end

			if user_job_tick then
				if user_job_tick() then return end
			end

			if user_tick then
				if user_tick() then return end
			end

			if job_tick then
				if job_tick() then return end
			end
			
			if default_tick then
				if default_tick() then return end
			end			

			if extra_user_job_tick then
				if extra_user_job_tick() then return end
			end

			if extra_user_tick then
				if extra_user_tick() then return end
			end
			
		end

		tickdelay = os.clock() + .5
		
		if lastincombat == true and not player.in_combat and being_attacked then
			being_attacked = false
			if player.status == 'Idle' and not midaction() and not pet_midaction() then
				handle_equipping_gear(player.status)
			end
		end			
		lastincombat = player.in_combat
	end)
	
    -- Load up all the gear sets.
    init_gear_sets()
end

-- Called when this job file is unloaded (eg: job change)
-- Conditional definition so that it doesn't overwrite explicit user
-- versions of this function.
if not file_unload then
    file_unload = function()
        if user_unload then
            user_unload()
		end
		
        if job_unload then
            job_unload()
        end
		
		global_unload()
    end
end

-- Function to bind GearSwap binds when loading a GS script, moved to globals to seperate per character and user.
function global_on_load()

end

-- Function to revert binds when unloading.
function global_unload()
	send_command('unbind ^f8')
	send_command('unbind !f8')
	send_command('unbind @f8')
	send_command('unbind f9')
	send_command('unbind ^f9')
	send_command('unbind !f9')
	send_command('unbind @f9')
	send_command('unbind f10')
	send_command('unbind ^f10')
	send_command('unbind !f10')
	send_command('unbind @f10')
	send_command('unbind f11')
	send_command('unbind ^f11')
	send_command('unbind !f11')
	send_command('unbind @f11')
	send_command('unbind f12')
	send_command('unbind ^f12')
	send_command('unbind !f12')
	send_command('unbind @f12')
	send_command('unbind ^@!pause')
	send_command('unbind ^pause')
	send_command('unbind !pause')
	send_command('unbind @pause')
	send_command('unbind ^@!pause')

	send_command('unbind ^\\\\')
	send_command('unbind @\\\\')
	send_command('unbind !\\\\')

	send_command('unbind ^`')
	send_command('unbind !`')
	send_command('unbind @`')

	send_command('unbind ^backspace')
	send_command('unbind !backspace')
	send_command('unbind @backspace')

	send_command('unbind ^r')
	send_command('unbind !r')
	send_command('unbind @r')

	send_command('unbind ^y')
	send_command('unbind !y')
	send_command('unbind @y')

	send_command('unbind ^q')
	send_command('unbind !q')
	send_command('unbind @q')
	
	send_command('unbind ^-')
	send_command('unbind !-')
	send_command('unbind @-')

	send_command('unbind ^=')
	send_command('unbind !=')
	send_command('unbind @=')

	send_command('unbind ^delete')
	send_command('unbind !delete')
	send_command('unbind @delete')
	
	if clear_job_states then
		clear_job_states()
	end		
end

-------------------------------------------------------------------------------------------------------------------
-- Generalized functions for handling precast/midcast/aftercast for player-initiated actions.
-- This depends on proper set naming.
-- Global hooks can be written as user_xxx() to override functions at a global level.
-- Each job can override any of these general functions using job_xxx() hooks.
-------------------------------------------------------------------------------------------------------------------

-----------------------------------	-------------------------------------
-- Generic function to map a set processing order to all action events.
------------------------------------------------------------------------


-- Process actions in a specific order of events:
-- Filter  - filter_xxx() functions determine whether to run any of the code for this action.
-- Global  - user_xxx() functions get called first.  Define in Sel-Globals or User-Globals.
-- Local   - job_xxx() functions get called next. Define in JOB.lua file.
-- Default - default_xxx() functions get called next. Defined in this file.
-- Cleanup - cleanup_xxx() functions always get called before exiting.
--
-- Parameters:
-- spell - standard spell table passed in by GearSwap
-- action - string defining the function mapping to use (precast, midcast, etc)
function handle_actions(spell, action)
    -- Init an eventArgs that allows cancelling.
    local eventArgs = {handled = false, cancel = false}
    
    mote_vars.set_breadcrumbs:clear()

    -- Get the spell mapping, since we'll be passing it to various functions and checks.
    local spellMap = get_spell_map(spell)
	gearswap.refresh_globals(false)

    -- General filter checks to see whether this function should be run.
    -- If eventArgs.cancel is set, cancels this function, not the spell.
    if _G['user_filter_'..action] then
        _G['user_filter_'..action](spell, spellMap, eventArgs)
		
		if eventArgs.cancel and (action == 'pretarget' or action == 'precast') then
			cancel_spell()
			return
		end
    end
	
    if _G['user_job_filter_'..action] and not eventArgs.cancel then
        _G['user_job_filter_'..action](spell, spellMap, eventArgs)
		
		if eventArgs.cancel and (action == 'pretarget' or action == 'precast') then
			cancel_spell()
			return
		end
    end
	
    if _G['job_filter_'..action] and not eventArgs.cancel then
        _G['job_filter_'..action](spell, spellMap, eventArgs)
		
		if eventArgs.cancel and (action == 'pretarget' or action == 'precast') then
			cancel_spell()
			return
		end
    end
	
    if _G['filter_'..action] and not eventArgs.cancel then
        _G['filter_'..action](spell, spellMap, eventArgs)
		
		if eventArgs.cancel and (action == 'pretarget' or action == 'precast') then
			cancel_spell()
			return
		end
    end
	
    -- If filter didn't cancel it, process user and default actions.
    if not eventArgs.cancel then
        -- Global user handling of this action
        if _G['user_'..action] then
            _G['user_'..action](spell, spellMap, eventArgs)
            
            if eventArgs.cancel and (action == 'pretarget' or action == 'precast') then
                cancel_spell()
				return
            end
        end
		
        -- Job-specific handling of this action
        if not eventArgs.cancel and not eventArgs.handled and _G['job_'..action] then
            _G['job_'..action](spell, spellMap, eventArgs)
            
            if eventArgs.cancel and (action == 'pretarget' or action == 'precast') then
                cancel_spell()
				return
            end
        end
		
        if not eventArgs.cancel and not eventArgs.handled and _G['user_job_'..action] then
            _G['user_job_'..action](spell, spellMap, eventArgs)
            
            if eventArgs.cancel and (action == 'pretarget' or action == 'precast') then
                cancel_spell()
				return
            end
        end
    
        -- Default handling of this action
        if not eventArgs.cancel and not eventArgs.handled and _G['default_'..action] then
            _G['default_'..action](spell, spellMap, eventArgs)
            display_breadcrumbs(spell, spellMap, action)
			
			if eventArgs.cancel and (action == 'pretarget' or action == 'precast') then
				cancel_spell()
				return
			end
        end
		
        -- Global user handling of this action
        if _G['extra_user_'..action] then
            _G['extra_user_'..action](spell, spellMap, eventArgs)
            
            if eventArgs.cancel and (action == 'pretarget' or action == 'precast') then
                cancel_spell()
				return
            end
        end
		
        -- Global post-handling of this action
        if not eventArgs.cancel and _G['user_post_'..action] then
            _G['user_post_'..action](spell, spellMap, eventArgs)
        end

       -- Job-specific post-handling of this action
        if not eventArgs.cancel and _G['job_post_'..action] then
            _G['job_post_'..action](spell, spellMap, eventArgs)
        end
		
        if not eventArgs.cancel and _G['user_job_post_'..action] then
            _G['user_job_post_'..action](spell, spellMap, eventArgs)
        end

        if not eventArgs.cancel and _G['default_post_'..action] then
            _G['default_post_'..action](spell, spellMap, eventArgs)
        end
		
        if not eventArgs.cancel and _G['extra_user_post_'..action] then
            _G['extra_user_post_'..action](spell, spellMap, eventArgs)
        end
		
    end

    -- Cleanup once this action is done
    if _G['cleanup_'..action] then
        _G['cleanup_'..action](spell, spellMap, eventArgs)
    end
end


--------------------------------------
-- Action hooks called by GearSwap.
--------------------------------------

function filtered_action(spell, eventArgs)
	local eventArgs = {cancel = false}

    -- Check users action filtering
    if not eventArgs.cancel and user_filtered_action then
        user_filtered_action(spell, eventArgs)
    end

    -- Check jobs action filtering
    if not eventArgs.cancel and user_job_filtered_action then
        user_job_filtered_action(spell, eventArgs)
    end
	
    -- Check jobs action filtering
    if not eventArgs.cancel and job_filtered_action then
        job_filtered_action(spell, eventArgs)
    end
	
    -- Check users action filtering
    if not eventArgs.cancel and default_filtered_action then
        default_filtered_action(spell, eventArgs)
    end
	
	-- Final user for filtering and error reporting.
    if not eventArgs.cancel and extra_user_filtered_action then
        extra_user_filtered_action(spell, eventArgs)
    end
	
	-- Final pass for filtering and error reporting.
    if not eventArgs.cancel and extra_default_filtered_action then
        extra_default_filtered_action(spell, eventArgs)
    end

end

function pretarget(spell)
    handle_actions(spell, 'pretarget')
end

function precast(spell)
    handle_actions(spell, 'precast')
end

function midcast(spell)
    handle_actions(spell, 'midcast')
end

function aftercast(spell)

    if state.Buff[spell.english:ucfirst()] ~= nil and spell.target.type == 'SELF' then
        state.Buff[spell.english:ucfirst()] = not spell.interrupted or buffactive[spell.english] or false
    end
	
    handle_actions(spell, 'aftercast')
end

function pet_midcast(spell)
    handle_actions(spell, 'pet_midcast')
end

function pet_aftercast(spell)
    handle_actions(spell, 'pet_aftercast')
end

--------------------------------------
-- Default code for each action.
--------------------------------------

function default_filtered_action(spell, eventArgs)
	if spell.english == 'Warp' then
		if (item_available('Warp Ring') or player.satchel['Warp Ring']) then
			useItem = true
			useItemName = 'Warp Ring'
			useItemSlot = 'ring2'
			add_to_chat(217,"You can't cast warp, attempting to use Warp Ring instead, /heal to cancel.")
		elseif (item_available('Treat Staff') or player.satchel['Treat Staff']) then
			useItem = true
			useItemName = 'Treat Staff'
			useItemSlot = 'main'
		elseif (item_available('Warp Cudgel') or player.satchel['Warp Cudgel']) then
			add_to_chat(217,"You can't cast warp, attempting to use Warp Cudgel instead, /heal to cancel.")
			useItem = true
			useItemName = 'Warp Cudgel'
			useItemSlot = 'main'
			add_to_chat(217,"You can't cast warp, attempting to use Warp Cudgel instead, /heal to cancel.")
		elseif (item_available('Instant Warp') or player.satchel['Instant Warp']) then
			useItem = true
			useItemName = 'Instant Warp'
			useItemSlot = 'item'
			add_to_chat(217,"You can't cast warp, attempting to use a Warp Scroll instead, /heal to cancel.")
		else
			add_to_chat(122,'Warp unavailable and no warp items available.')
		end
		cancel_spell()
		eventArgs.cancel = true
	elseif spell.english == 'Retrace' then
		if spell.target.type == 'SELF' and (item_available('Instant Retrace') or player.satchel['Instant Retrace']) then
			useItem = true
			useItemName = 'Instant Retrace'
			useItemSlot = 'item'
			add_to_chat(217,"You can't cast Retrace, attempting to use a Retrace Scroll instead, /heal to cancel.")
			cancel_spell()
			eventArgs.cancel = true
		end
	elseif spell.english == 'Teleport-Holla' then
		if (item_available('Dim. Ring (Holla)') or player.satchel['Dim. Ring (Holla)']) then
			useItem = true
			useItemName = 'Dim. Ring (Holla)'
			useItemSlot = 'ring2'
			add_to_chat(217,"You can't cast Teleport-Holla, attempting to use Dimensional Ring instead, /heal to cancel.")
			cancel_spell()
			eventArgs.cancel = true
		end
	elseif spell.english == 'Teleport-Dem' then
		if (item_available('Dim. Ring (Dem)') or player.satchel['Dim. Ring (Dem)']) then
			useItem = true
			useItemName = 'Dim. Ring (Dem)'
			useItemSlot = 'ring2'
			add_to_chat(217,"You can't cast Teleport-Dem, attempting to use Dimensional Ring instead, /heal to cancel.")
			cancel_spell()
			eventArgs.cancel = true
		end
	elseif spell.english == 'Teleport-Mea' then
		if (item_available('Dim. Ring (Mea)') or player.satchel['Dim. Ring (Mea)']) then
			useItem = true
			useItemName = 'Dim. Ring (Mea)'
			useItemSlot = 'ring2'
			add_to_chat(217,"You can't cast Teleport-Mea, attempting to use Dimensional Ring instead, /heal to cancel.")
			cancel_spell()
			eventArgs.cancel = true
		end
	elseif spell.english == 'Invisible' then
		if player.main_job == 'DNC' or player.sub_job == 'DNC' then
			windower.chat.input('/ja "Spectral Jig" <me>')
			add_to_chat(217,"You can't cast Invisible, attempting to use Spectral Jig instead.")
			cancel_spell()
			eventArgs.cancel = true
			return
		elseif player.main_job == 'NIN' or player.sub_job == 'NIN' then
			windower.chat.input('/ma "Tonko: Ni" <me>')
			add_to_chat(217,"You can't cast Invisible, attempting to use Tonko: Ni instead.")
			cancel_spell()
			eventArgs.cancel = true
			return
		elseif item_available('Prism Powder') then
			windower.chat.input('/item "Prism Powder" <me>')
			add_to_chat(217,"You can't cast Invisible, attempting to use Prism Powder instead.")
			cancel_spell()
			eventArgs.cancel = true
			return
		elseif item_available('Rainbow Powder') then
			windower.chat.input('/item "Rainbow Powder" <me>')
			add_to_chat(217,"You can't cast Invisible, attempting to use Prism Powder instead.")
			cancel_spell()
			eventArgs.cancel = true
			return
		end
	elseif spell.english == 'Sneak' then
		if player.main_job == 'DNC' or player.sub_job == 'DNC' then
			windower.chat.input('/ja "Spectral Jig" <me>')
			add_to_chat(217,"You can't cast Sneak, attempting to use Spectral Jig instead.")
			cancel_spell()
			eventArgs.cancel = true
			return
		elseif player.main_job == 'NIN' or player.sub_job == 'NIN' then
			windower.chat.input('/ma "Monomi: Ichi" <me>')
			add_to_chat(217,"You can't cast Sneak, attempting to use Monomi: Ichi instead.")
			cancel_spell()
			eventArgs.cancel = true
			return
		elseif item_available('Silent Oil') then
			windower.chat.input('/item "Silent Oil" <me>')
			add_to_chat(217,"You can't cast Sneak, attempting to use Silent Oil instead.")
			cancel_spell()
			eventArgs.cancel = true
			return
		end
	end
end

function extra_default_filtered_action(spell, eventArgs)
	if spell.action_type == 'Item' and world.area == "Mog Garden" then
		return
	elseif spell.action_type == 'Magic' and not silent_can_use(spell.recast_id) and stepdown(spell, eventArgs) then
		cancel_spell()
		return
	elseif not can_use(spell) then
		cancel_spell()
		eventArgs.cancel = true
		return		
	end
end

function default_pretarget(spell, spellMap, eventArgs)
    auto_change_target(spell, spellMap)
end

function default_precast(spell, spellMap, eventArgs)
    cancel_conflicting_buffs(spell, spellMap, eventArgs)
    refine_waltz(spell, spellMap, eventArgs)

	if eventArgs.cancel then
		cancel_spell()
	else
		equip(get_precast_set(spell, spellMap))
	end
	
	if spell.action_type == 'Magic' then
		next_cast = os.clock() + 3.5 - latency
	elseif spell.type == 'WeaponSkill' then
		next_cast = os.clock() + 2.5 - latency
	elseif spell.action_type == 'Ability' then
		next_cast = os.clock() + .75 - latency
	elseif spell.action_type == 'Item' then
		next_cast = os.clock() + 1.35 - latency
	elseif spell.action_type == 'Ranged Attack' then
		next_cast = os.clock() + 1.05 - latency
	end
	
	if tickdelay < next_cast then tickdelay = next_cast end
	if areas.LaggyZones:contains(world.area) then next_cast = next_cast - .25 end
end

function default_post_precast(spell, spellMap, eventArgs)
	if not eventArgs.handled then
		if spell.action_type == 'Magic' then
			if spell.english:startswith('Utsusemi') then
				if sets.precast.FC.Shadows and ((spell.english == 'Utsusemi: Ni' and player.main_job == 'NIN' and lastshadow == 'Utsusemi: San') or (spell.english == 'Utsusemi: Ichi' and lastshadow ~= 'Utsusemi: Ichi')) then
					equip(sets.precast.FC.Shadows)
				end
			end
			
		elseif spell.type == 'WeaponSkill' then
		
			if state.WeaponskillMode.value ~= 'Proc' and elemental_obi_weaponskills:contains(spell.name) then
				local orpheus_avail = item_available("Orpheus's Sash")
				local hachirin_avail = item_available('Hachirin-no-Obi')
				
				if hachirin_avail and spell.element == world.weather_element and gearswap.res.weather[world.weather_id].intensity == 2 then
					equip({waist="Hachirin-no-Obi"})
				elseif orpheus_avail and spell.target.distance < (1.7 + spell.target.model_size) then
					equip({waist="Orpheus's Sash"})
				elseif hachirin_avail and spell.element and spell.element == world.weather_element then
					equip({waist="Hachirin-no-Obi"})
				elseif orpheus_avail and spell.target.distance < (8 + spell.target.model_size) then
					equip({waist="Orpheus's Sash"})
				elseif hachirin_avail and spell.element == world.day_element then
					equip({waist="Hachirin-no-Obi"})
				end
			end
			
			if sets.Reive and buffactive['Reive Mark'] and sets.Reive.neck == "Ygnas's Resolve +1" then
				equip(sets.Reive)
			end
			
			if state.WeaponskillMode.value == 'Proc' and not (sets.precast.WS[spell.english] and sets.precast.WS[spell.english].Proc) and sets.precast.WS.Proc then
				equip(sets.precast.WS.Proc)
			end
			
			if state.Capacity.value == true then 
				equip(sets.Capacity)
			end
			
			if state.TreasureMode.value ~= 'None' and not info.tagged_mobs[spell.target.id] then
				equip(sets.TreasureHunter)
			end
			
		elseif spell.action_type == 'Ability' then
			if spell.type == 'Waltz' then
				if spell.target.type == 'SELF' and sets.Self_Waltz and not (spell.english == "Healing Waltz" or spell.english == "Divine Waltz" or spell.english == "Divine Waltz II") then
					equip(sets.Self_Waltz)
				end
			elseif state.TreasureMode.value ~= 'None' and spell.target.type == 'MONSTER' and not info.tagged_mobs[spell.target.id] then
				equip(sets.TreasureHunter)
			end
		end
		
		if state.DefenseMode.value ~= 'None' and (player.in_combat or being_attacked) then
			if spell.action_type == 'Magic' then
				if sets.precast.FC[spell.english] and sets.precast.FC[spell.english].DT then
					equip(sets.precast.FC[spell.english].DT)
				elseif sets.precast.FC[spellMap] and sets.precast.FC[spellMap].DT then
					equip(sets.precast.FC[spellMap].DT)
				elseif sets.precast.FC[spell.skill] and sets.precast.FC[spell.skill].DT then
					equip(sets.precast.FC[spell.skill].DT)
				elseif sets.precast.FC.DT then
					equip(sets.precast.FC.DT)
				else
					handle_equipping_gear(player.status)
				end
			elseif spell.type == 'WeaponSkill' then
				if state.SkillchainMode.value ~= 'Off' and sets.Skillchain then
					equip(sets.Skillchain)
				end
				
				if sets.precast.WS[spell.english] and sets.precast.WS[spell.english].DT then
					equip(sets.precast.WS[spell.english].DT)
				elseif sets.precast.WS.DT then
					equip(sets.precast.WS.DT)
				else
					handle_equipping_gear(player.status)
				end
			elseif spell.action_type == 'Ability' then
				if sets.precast.JA[spell.english] and sets.precast.JA[spell.english].DT then
					equip(sets.precast.JA[spell.english].DT)
				else
					handle_equipping_gear(player.status)
				end
			else
				handle_equipping_gear(player.status)
			end
		end
	end
end

function default_midcast(spell, spellMap, eventArgs)
    equip(get_midcast_set(spell, spellMap))
end

function default_post_midcast(spell, spellMap, eventArgs)

	if not eventArgs.handled then
		if not job_post_midcast and is_nuke(spell, spellMap) and state.MagicBurstMode.value ~= 'Off' and sets.MagicBurst then
			equip(sets.MagicBurst)
		end

		if spell.target.type == 'SELF' and spellMap then
			if spellMap:contains('Cure') then
				if curecheat then
					if sets.HPCure then
						equip(sets.HPCure)
					end
					curecheat = false
				elseif sets.Self_Healing and not (state.CastingMode.value:contains('SIRD') and (player.in_combat or being_attacked)) then
					equip(sets.Self_Healing)
				elseif sets.Self_Healing and sets.Self_Healing.SIRD and state.CastingMode.value:contains('SIRD') then
					equip(sets.Self_Healing.SIRD)
				end
			elseif spellMap == 'Refresh' and sets.Self_Refresh and not (state.CastingMode.value:contains('SIRD') and (player.in_combat or being_attacked)) then
				equip(sets.Self_Refresh)
			end
		end
		
		if state.Capacity.value == true then
			if set.contains(spell.targets, 'Enemy') then
		
				if spell.skill == 'Elemental Magic' or spell.skill == 'Blue Magic' or spell.action_type == 'Ranged Attack' then
					equip(sets.Capacity)
				end
			end
		end
		
		if sets.Reive and buffactive['Reive Mark'] and (spell.skill == 'Elemental Magic' or spellMap == 'Cure' or spellMap == 'Curaga') then
			if sets.Reive.neck == "Arciela's Grace +1" then
				equip(sets.Reive)
			end
		end
		
		if state.TreasureMode.value ~= 'None' and spell.target.type == 'MONSTER' and not info.tagged_mobs[spell.target.id] then
			equip(sets.TreasureHunter)
		end
		
		if state.DefenseMode.value ~= 'None' and spell.action_type == 'Magic' and (player.in_combat or being_attacked) then
			if sets.midcast[spell.english] and sets.midcast[spell.english].DT then
				equip(sets.midcast[spell.english].DT)
			elseif sets.midcast[spellMap] and sets.midcast[spellMap].DT then
				equip(sets.midcast[spellMap].DT)
			elseif sets.midcast[spell.skill] and sets.midcast[spell.skill].DT then
				equip(sets.midcast[spell.skill].DT)
			elseif sets.midcast.FastRecast.DT then
				equip(sets.midcast.FastRecast.DT)
			else
				handle_equipping_gear(player.status)
			end

			if spell.target.type == 'SELF' and spellMap and spellMap:contains('Cure') and sets.Self_Healing and sets.Self_Healing.DT then
				equip(sets.Self_Healing.DT)

			end
			
			eventArgs.handled = true
		end
	end		
	
	if buffactive.doom then
		equip(sets.buff.Doom)
	end
end

function default_post_pet_midcast(spell, spellMap, eventArgs)
	if state.Capacity.value == true then
		equip(sets.Capacity)
	end

	if buffactive.doom then
		equip(sets.buff.Doom)
	end
end

function default_aftercast(spell, spellMap, eventArgs)
	if spell.interrupted then
		if spell.type:contains('Magic') then
			next_cast = os.clock() + 3 - latency
		else
			next_cast = os.clock() + 1.75 - latency
		end
	elseif spell.action_type == 'Magic' then
		next_cast = os.clock() + 3.45 - latency
	elseif spell.type == 'WeaponSkill' then
		next_cast = os.clock() + 2 - latency
	elseif spell.action_type == 'Ability' then
		next_cast = os.clock() + .75 - latency
	elseif 	spell.action_type == 'Item' then
		next_cast = os.clock() + .85 - latency
	elseif spell.action_type == 'Ranged Attack' then
		next_cast = os.clock() + .85 - latency
	end
	
	if tickdelay < next_cast then tickdelay = next_cast end
	
	if areas.LaggyZones:contains(world.area) then
		next_cast = next_cast - .25
	end
	
	if not spell.interrupted then
		if delayed_cast == spell.english then
			delayed_cast = ''
			delayed_target = ''
		end
		if state.TreasureMode.value ~= 'None' and state.DefenseMode.value == 'None' and spell.target.type == 'MONSTER' and not info.tagged_mobs[spell.target.id] then
			info.tagged_mobs[spell.target.id] = os.time()
			if player.target.id == spell.target.id and state.th_gear_is_locked then
				unlock_TH()
			end
		end
		if is_nuke(spell, spellMap) then
			if state.MagicBurstMode.value == 'Single' then state.MagicBurstMode:reset() end
			if state.ElementalWheel.value and (spell.skill == 'Elemental Magic' or spellMap:contains('ElementalNinjutsu')) then
				state.ElementalMode:cycle()
				local startindex = state.ElementalMode.index
				while S{"Light","Dark"}:contains(state.ElementalMode.value) do
					state.ElementalMode:cycle()
					if startindex == state.ElementalMode.index then break end
				end
			end
			if state.DisplayMode.value then update_job_states()	end
		elseif spell.type == 'WeaponSkill' and state.SkillchainMode.value == 'Single' then
			state.SkillchainMode:reset()
			if state.DisplayMode.value then update_job_states()	end
		elseif spell.english:startswith('Utsusemi') then
			lastshadow = spell.english
		elseif spell.action_type == 'Item' and useItem and (spell.english == useItemName or useItemSlot == 'set') then
			useItem = false
			if useItemSlot == 'item' then
				windower.send_command('put '..useItemName..' satchel')
			elseif useItemSlot == 'set' then
				local slots = T{}
				for slot,item in pairs(sets[useItemName]) do
					slots:append(slot)
				end
				enable(slots)
				if player.inventory[useItemName] then
					windower.send_command('wait 1;put '..set_to_item(useItemName)..' satchel')
				end
			else 
				enable(useItemSlot)
				if player.inventory[useItemName] then
					windower.send_command('wait 1;put '..useItemName..' satchel')
				end
			end
			useItemName = ''
			useItemSlot = ''
		end
	else
	end

	if not eventArgs.handled then
        handle_equipping_gear(player.status)
    end
end

function default_pet_midcast(spell, spellMap, eventArgs)
	if not (type(spell.type) == 'string' and (spell.type:startswith('BloodPact') or spell.type == 'Monster')) then
		equip(get_pet_midcast_set(spell, spellMap))
	end
end

function default_pet_aftercast(spell, spellMap, eventArgs)
    if not midaction() then handle_equipping_gear(player.status) end
end

--------------------------------------
-- Filters for each action.
-- Set eventArgs.cancel to true to stop further processing.
-- May show notification messages, but should not do any processing here.
--------------------------------------

function filter_precast(spell, spellMap, eventArgs)
	if check_rnghelper(spell, spellMap, eventArgs) then return end
	if check_midaction(spell, spellMap, eventArgs) then return end
	if check_disable(spell, spellMap, eventArgs) then return end
	if check_doom(spell, spellMap, eventArgs) then return end
	
	if spell.action_type == 'Magic' then
		if check_silence(spell, spellMap, eventArgs) then return end
		if check_spell_targets(spell, spellMap, eventArgs) then return end
		if check_cost(spell, spellMap, eventArgs) then return end
		if check_warps(spell, spellMap, eventArgs) then return end
	elseif spell.action_type == 'Ability' or spell.type == 'WeaponSkill' then
		if check_amnesia(spell, spellMap, eventArgs) then return end
		if check_abilities(spell, spellMap, eventArgs) then return end
	end
	if check_recast(spell, spellMap, eventArgs) then return end
end

function filter_midcast(spell, spellMap, eventArgs)
    if state.EquipStop.value == 'precast' then
        eventArgs.cancel = true
		return
	end
	
	-- Default base equipment layer of fast recast, needs to come before job-midcast.
	if spell.action_type == 'Magic' and sets.midcast and sets.midcast.FastRecast then
		equip(sets.midcast.FastRecast)
	end
end

function filter_aftercast(spell, spellMap, eventArgs)
    if state.EquipStop.value == 'precast' or state.EquipStop.value == 'midcast' or state.EquipStop.value == 'pet_midcast' then
        eventArgs.cancel = true
    elseif spell.name == 'Unknown Interrupt' then
        eventArgs.cancel = true
    end
end

function filter_pet_midcast(spell, spellMap, eventArgs)
    -- If we have show_set active for precast or midcast, don't try to equip pet midcast gear.
    if state.EquipStop.value == 'precast' or state.EquipStop.value == 'midcast' then
        add_to_chat(104, 'Show Sets: Pet midcast not equipped.')
        eventArgs.cancel = true
    end
end

function filter_pet_aftercast(spell, spellMap, eventArgs)
    -- If show_set is flagged for precast or midcast, don't try to equip aftercast gear.
    if state.EquipStop.value == 'precast' or state.EquipStop.value == 'midcast' or state.EquipStop.value == 'pet_midcast' then
        eventArgs.cancel = true
    end
end

--------------------------------------
-- Cleanup code for each action.
--------------------------------------

function cleanup_precast(spell, spellMap, eventArgs)
    -- If show_set is flagged for precast, notify that we won't try to equip later gear.
    if state.EquipStop.value == 'precast' then
        add_to_chat(104, 'Show Sets: Stopping at precast.')
    end
end

function cleanup_midcast(spell, spellMap, eventArgs)
    -- If show_set is flagged for midcast, notify that we won't try to equip later gear.
    if state.EquipStop.value == 'midcast' then
        add_to_chat(104, 'Show Sets: Stopping at midcast.')
    end
end

function cleanup_aftercast(spell, spellMap, eventArgs)
    -- Reset custom classes after all possible precast/midcast/aftercast/job-specific usage of the value.
    -- If we're in the middle of a pet action, pet_aftercast will handle clearing it.
    if not pet_midaction() then
        reset_transitory_classes()
    end
end

function cleanup_pet_midcast(spell, spellMap, eventArgs)
    -- If show_set is flagged for pet midcast, notify that we won't try to equip later gear.
    if state.EquipStop.value == 'pet_midcast' then
        add_to_chat(104, 'Show Sets: Stopping at pet midcast.')
    end
end

function cleanup_pet_aftercast(spell, spellMap, eventArgs)
    -- Reset custom classes after all possible precast/midcast/aftercast/job-specific usage of the value.
    reset_transitory_classes()
end

function pre_tick()
	if check_trust() then return true end
	if check_rune() then return true end
	return false
end

function default_tick()
	if check_doomed() then return true end
	if check_shadows() then return true end
	if check_use_item() then return true end
	if check_sub() then return true end
	if check_food() then return true end
	if check_ws() then return true end
	if check_samba() then return true end
	if check_cpring_buff() then return true end
	if check_cleanup() then return true end
	if check_nuke() then return true end
	return false
end

-- Clears the values from classes that only exist til the action is complete.
function reset_transitory_classes()
    classes.CustomClass = nil
    classes.JAMode = nil
end



-------------------------------------------------------------------------------------------------------------------
-- High-level functions for selecting and equipping gear sets.
-------------------------------------------------------------------------------------------------------------------

-- Central point to call to equip gear based on status.
-- Status - Player status that we're using to define what gear to equip.
function handle_equipping_gear(playerStatus, petStatus)
    -- init a new eventArgs
    local eventArgs = {handled = false}
	
    -- Allow jobs to override this code
    if job_handle_equipping_gear then
        job_handle_equipping_gear(playerStatus, eventArgs)
    end

	if state.ReEquip.value and state.Weapons.value ~= 'None' then
		if player.equipment.main == 'empty' or player.equipment.sub == 'empty' then
			handle_weapons()
		end
	end

	if player.equipment.ammo == 'empty' and sets.weapons[state.Weapons.value] and sets.weapons[state.Weapons.value].ammo then
		enable('ammo')
		equip({ammo=sets.weapons[state.Weapons.value].ammo})
		disable('ammo')
	end
	
    -- Equip default gear if job didn't handle it.
    if not eventArgs.handled then
        equip_gear_by_status(playerStatus, petStatus)
    end
end


-- Function to wrap logic for equipping gear on aftercast, status change, or user update.
-- @param status : The current or new player status that determines what sort of gear to equip.
function equip_gear_by_status(playerStatus, petStatus)
    if _global.debug_mode then add_to_chat(123,'Debug: Equip gear for status ['..tostring(status)..'], HP='..tostring(player.hp)) end

    playerStatus = playerStatus or player.status or 'Idle'
    -- If status not defined, treat as idle.
    -- Be sure to check for positive HP to make sure they're not dead.
    if (playerStatus == 'Idle' or playerStatus == '') and player.hp > 0 then
        equip(get_idle_set(petStatus))
    elseif playerStatus == 'Engaged' then
		if player.target and player.target.model_size and player.target.distance < (3.2 + player.target.model_size) then
			equip(get_melee_set(petStatus))
		else
			equip(get_idle_set(petStatus))
		end
    elseif playerStatus == 'Resting' then
        equip(get_resting_set(petStatus))
    end
end


-------------------------------------------------------------------------------------------------------------------
-- Functions for constructing default gear sets based on status.
-------------------------------------------------------------------------------------------------------------------

-- Returns the appropriate idle set based on current state values and location.
-- Set construction order (all of which are optional):
--   sets.idle[idleScope][state.IdleMode][Pet[Engaged]][CustomIdleGroups]
--
-- Params:
-- petStatus - Optional explicit definition of pet status.
function get_idle_set(petStatus)
    local idleSet = sets.idle
    
    if not idleSet then
        return {}
    end
    
    mote_vars.set_breadcrumbs:append('sets')
    mote_vars.set_breadcrumbs:append('idle')
    
    local idleScope

    if buffactive.weakness then
        idleScope = 'Weak'
    else
        idleScope = 'Field'
    end

    if idleSet[idleScope] then
        idleSet = idleSet[idleScope]
        mote_vars.set_breadcrumbs:append(idleScope)
    end

    if not (player.in_combat or being_attacked) and (state.IdleMode.current:contains('DT') or state.IdleMode.current:contains('Tank')) then
	elseif idleSet[state.IdleMode.current] then
		idleSet = idleSet[state.IdleMode.current]
		mote_vars.set_breadcrumbs:append(state.IdleMode.current)
    end

    if (pet.isvalid or state.Buff.Pet) and idleSet.Pet then
        idleSet = idleSet.Pet
        petStatus = petStatus or pet.status
        mote_vars.set_breadcrumbs:append('Pet')

        if petStatus == 'Engaged' and idleSet.Engaged then
            idleSet = idleSet.Engaged
            mote_vars.set_breadcrumbs:append('Engaged')
        end
    end

    for _,group in ipairs(classes.CustomIdleGroups) do
        if idleSet[group] then
            idleSet = idleSet[group]
            mote_vars.set_breadcrumbs:append(group)
        end
    end

	--Apply time based gear.
    if (state.IdleMode.value == 'Normal' or state.IdleMode.value == 'Sphere') and not pet.isvalid then
		if classes.DuskToDawn then
			if sets.DuskIdle then idleSet = set_combine(idleSet, sets.DuskIdle) end
		end
		
		if classes.Daytime then
			if sets.DayIdle then idleSet = set_combine(idleSet, sets.DayIdle) end
		else
			if sets.NightIdle then idleSet = set_combine(idleSet, sets.NightIdle) end
		end
	end

    if areas.Assault:contains(world.area) and sets.Assault then
        idleSet = set_combine(idleSet, sets.Assault)
    end
	
    if sets.Reive and buffactive['Reive Mark'] then
        idleSet = set_combine(idleSet, sets.Reive)
    end

    if user_customize_idle_set then
        idleSet = user_customize_idle_set(idleSet)
    end
	
    if job_customize_idle_set then
        idleSet = job_customize_idle_set(idleSet)
    end
	
    if user_job_customize_idle_set then
        idleSet = user_job_customize_idle_set(idleSet)
    end

    if areas.Cities:contains(world.area) then
		if sets.idle.Town then
			idleSet = set_combine(idleSet, sets.Kiting, sets.idle.Town)
		elseif sets.Town then
			idleSet = set_combine(idleSet, sets.Kiting, sets.Town)
		else 
			idleSet = set_combine(idleSet, sets.Kiting)
		end

		if (world.area:contains('Adoulin') or world.area == "Celennia Memorial Library") and item_available("Councilor's Garb") then
			idleSet = set_combine(idleSet, {body="Councilor's Garb"})
		elseif (world.area:contains('Bastok') or world.area == "Metalworks") and item_available("Republic Aketon") then
			idleSet = set_combine(idleSet, {body="Republic Aketon"})
		elseif (world.area:contains('Windurst') or world.area == "Heavens Tower") and item_available("Federation Aketon") then
			idleSet = set_combine(idleSet, {body="Federation Aketon"})
		elseif (world.area:contains("San d'Oria") or world.area == "Chateau d'Oraguille") and item_available("Kingdom Aketon") then
			idleSet = set_combine(idleSet, {body="Kingdom Aketon"})
		elseif world.area == "Mog Garden" and item_available("Jubilee Shirt") then
			idleSet = set_combine(idleSet, {body="Jubilee Shirt"})
		end
	end

	idleSet = apply_passive(idleSet)
	
	if state.Capacity.value then 
		idleSet = set_combine(idleSet, sets.Capacity)
	end
	
    idleSet = apply_defense(idleSet)
    idleSet = apply_kiting(idleSet)
	
	if silent_check_disable() and state.DefenseMode.value == 'None' then
		if state.IdleMode.value:contains('MDT') and sets.defense.MDT then
			idleSet = set_combine(idleSet, sets.defense.MDT)
		elseif sets.defense.PDT then
			idleSet = set_combine(idleSet, sets.defense.PDT)
		end
	end
	
	if (buffactive.sleep or buffactive.Lullaby) and (player.main_job == 'SMN' and pet.isvalid) then
		idleSet = set_combine(idleSet, sets.buff.Sleep)
	end
	
    if buffactive.doom then
        idleSet = set_combine(idleSet, sets.buff.Doom)
    end

    if extra_user_customize_idle_set then
        idleSet = extra_user_customize_idle_set(idleSet)
    end

    return idleSet
end


-- Returns the appropriate melee set based on current state values.
-- Set construction order (all sets after sets.engaged are optional):
--   sets.engaged[state.CombatForm][state.CombatWeapon][state.OffenseMode][state.DefenseMode][classes.CustomMeleeGroups (any number)]
function get_melee_set()
    local meleeSet = sets.engaged
    
    if not meleeSet then
        return {}
    end
    
    mote_vars.set_breadcrumbs:append('sets')
    mote_vars.set_breadcrumbs:append('engaged')

    if state.CombatForm.has_value and meleeSet[state.CombatForm.value] then
        meleeSet = meleeSet[state.CombatForm.value]
        mote_vars.set_breadcrumbs:append(state.CombatForm.value)
    end

    if state.CombatWeapon.has_value and meleeSet[state.CombatWeapon.value] then
        meleeSet = meleeSet[state.CombatWeapon.value]
        mote_vars.set_breadcrumbs:append(state.CombatWeapon.value)
    end

    if meleeSet[state.OffenseMode.current] then
        meleeSet = meleeSet[state.OffenseMode.current]
        mote_vars.set_breadcrumbs:append(state.OffenseMode.current)
    end

    if meleeSet[state.HybridMode.current] then
        meleeSet = meleeSet[state.HybridMode.current]
        mote_vars.set_breadcrumbs:append(state.HybridMode.current)
    end

    for _,group in ipairs(classes.CustomMeleeGroups) do
        if meleeSet[group] then
            meleeSet = meleeSet[group]
            mote_vars.set_breadcrumbs:append(group)
        end
    end

    if user_customize_melee_set then
        meleeSet = user_customize_melee_set(meleeSet)
    end
	
    if job_customize_melee_set then
        meleeSet = job_customize_melee_set(meleeSet)
    end
	
    if user_job_customize_melee_set then
        meleeSet = user_job_customize_melee_set(meleeSet)
    end
	
    if state.ExtraMeleeMode and state.ExtraMeleeMode.value ~= 'None' then
        meleeSet = set_combine(meleeSet, sets[state.ExtraMeleeMode.value])
    end
	
	meleeSet = apply_passive(meleeSet)
	
	if state.Capacity.value == true then 
		meleeSet = set_combine(meleeSet, sets.Capacity)
	end
	
    meleeSet = apply_defense(meleeSet)
    meleeSet = apply_kiting(meleeSet)
	
	if silent_check_disable() and state.DefenseMode.value == 'None' then
		if state.HybridMode.value:contains('MDT') and sets.defense.MDT then
			meleeSet = set_combine(meleeSet, sets.defense.MDT)
		elseif sets.defense.PDT then
			meleeSet = set_combine(meleeSet, sets.defense.PDT)
		end
	end
	
	if sets.Reive and buffactive['Reive Mark'] then
        meleeSet = set_combine(meleeSet, sets.Reive)
    end
	
	if (buffactive.sleep or buffactive.Lullaby) and sets.buff.Sleep then
        meleeSet = set_combine(meleeSet, sets.buff.Sleep)
    end
	
	if buffactive.doom then
        meleeSet = set_combine(meleeSet, sets.buff.Doom)
    end
	
    if extra_user_customize_melee_set then
        meleeSet = extra_user_customize_melee_set(meleeSet)
    end
	
    return meleeSet
end


-- Returns the appropriate resting set based on current state values.
-- Set construction order:
--   sets.resting[state.RestingMode]
function get_resting_set()
    local restingSet = sets.resting

    if not restingSet then
        return {}
    end

    mote_vars.set_breadcrumbs:append('sets')
    mote_vars.set_breadcrumbs:append('resting')

    if restingSet[state.RestingMode.current] then
        restingSet = restingSet[state.RestingMode.current]
        mote_vars.set_breadcrumbs:append(state.RestingMode.current)
    end

    return restingSet
end


-------------------------------------------------------------------------------------------------------------------
-- Functions for constructing default gear sets based on action.
-------------------------------------------------------------------------------------------------------------------

-- Get the default precast gear set.
function get_precast_set(spell, spellMap)
    -- If there are no precast sets defined, bail out.
    if not sets.precast then
        return {}
    end

    local equipSet = sets.precast

    mote_vars.set_breadcrumbs:append('sets')
    mote_vars.set_breadcrumbs:append('precast')
    
    -- Determine base sub-table from type of action being performed.
    
    local cat
    
    if spell.action_type == 'Magic' then
        cat = 'FC'
    elseif spell.action_type == 'Ranged Attack' then
        cat = (sets.precast.RangedAttack and 'RangedAttack') or 'RA'
    elseif spell.action_type == 'Ability' then
        if spell.type == 'WeaponSkill' then
            cat = 'WS'
        elseif spell.type == 'JobAbility' then
            cat = 'JA'
        else
            -- Allow fallback to .JA table if spell.type isn't found, for all non-weaponskill abilities.
            cat = (sets.precast[spell.type] and spell.type) or 'JA'
        end
    elseif spell.action_type == 'Item' then
        cat = 'Item'
    end
    
    -- If no proper sub-category is defined in the job file, bail out.
    if cat then
        if equipSet[cat] then
            equipSet = equipSet[cat]
            mote_vars.set_breadcrumbs:append(cat)
        else
            mote_vars.set_breadcrumbs:clear()
            return {}
        end
    end

    classes.SkipSkillCheck = false
    -- Handle automatic selection of set based on spell class/name/map/skill/type.
    equipSet = select_specific_set(equipSet, spell, spellMap)

    
    -- Once we have a named base set, do checks for specialized modes (casting mode, weaponskill mode, etc).
    
    if spell.action_type == 'Magic' then
		if (state.CastingMode.current:contains('SIRD') or state.CastingMode.current:contains('DT')) and not (player.in_combat or being_attacked) then
        elseif equipSet[state.CastingMode.current] then
            equipSet = equipSet[state.CastingMode.current]
            mote_vars.set_breadcrumbs:append(state.CastingMode.current)
        end
    elseif spell.type == 'WeaponSkill' then
        equipSet = get_weaponskill_set(equipSet, spell, spellMap)
    elseif spell.action_type == 'Ability' then
        if classes.JAMode and equipSet[classes.JAMode] then
            equipSet = equipSet[classes.JAMode]
            mote_vars.set_breadcrumbs:append(classes.JAMode)
        end
    elseif spell.action_type == 'Ranged Attack' then
        equipSet = get_ranged_set(equipSet, spell, spellMap)
    end

    -- Update defintions for element-specific gear that may be used.
    set_elemental_gear(spell)
    
    -- Return whatever we've constructed.
    return equipSet
end



-- Get the default midcast gear set.
-- This builds on sets.midcast.
function get_midcast_set(spell, spellMap)
    -- If there are no midcast sets defined, bail out.
    if not sets.midcast then
        return {}
    end
    
    local equipSet = sets.midcast

    mote_vars.set_breadcrumbs:append('sets')
    mote_vars.set_breadcrumbs:append('midcast')
    
    -- Determine base sub-table from type of action being performed.
    -- Only ranged attacks and items get specific sub-categories here.
    
    local cat

    if spell.action_type == 'Ranged Attack' then
        cat = (sets.precast.RangedAttack and 'RangedAttack') or 'RA'
    elseif spell.action_type == 'Item' then
        cat = 'Item'
    end
    
    -- If no proper sub-category is defined in the job file, bail out.
    if cat then
        if equipSet[cat] then
            equipSet = equipSet[cat]
            mote_vars.set_breadcrumbs:append(cat)
        else
            mote_vars.set_breadcrumbs:clear()
            return {}
        end
    end
    
    classes.SkipSkillCheck = classes.NoSkillSpells:contains(spell.english)
    -- Handle automatic selection of set based on spell class/name/map/skill/type.
    equipSet = select_specific_set(equipSet, spell, spellMap)
    
    -- After the default checks, do checks for specialized modes (casting mode, etc).
    
    if spell.action_type == 'Magic' then
        if equipSet[state.CastingMode.current] then
            equipSet = equipSet[state.CastingMode.current]
            mote_vars.set_breadcrumbs:append(state.CastingMode.current)
        end
    elseif spell.action_type == 'Ranged Attack' then
        equipSet = get_ranged_set(equipSet, spell, spellMap)
    end
    
    -- Return whatever we've constructed.
    return equipSet
end


-- Get the default pet midcast gear set.
-- This is built in sets.midcast.Pet.
function get_pet_midcast_set(spell, spellMap)
    -- If there are no midcast sets defined, bail out.
    if not sets.midcast or not sets.midcast.Pet then
        return {}
    end

    local equipSet = sets.midcast.Pet

    mote_vars.set_breadcrumbs:append('sets')
    mote_vars.set_breadcrumbs:append('midcast')
    mote_vars.set_breadcrumbs:append('Pet')

    if sets.midcast and sets.midcast.Pet then
        classes.SkipSkillCheck = false
        equipSet = select_specific_set(equipSet, spell, spellMap)

        -- We can only generally be certain about whether the pet's action is
        -- Magic (ie: it cast a spell of its own volition) or Ability (it performed
        -- an action at the request of the player).  Allow CastinMode and
        -- OffenseMode to refine whatever set was selected above.
		
        if spell.action_type == 'Magic' then
            if equipSet[state.CastingMode.current] then
                equipSet = equipSet[state.CastingMode.current]
                mote_vars.set_breadcrumbs:append(state.CastingMode.current)
            end
        elseif spell.action_type == 'Ability' then
            if equipSet[state.OffenseMode.current] then
                equipSet = equipSet[state.OffenseMode.current]
                mote_vars.set_breadcrumbs:append(state.OffenseMode.current)
            end
        end
    end

    return equipSet
end


-- Function to handle the logic of selecting the proper weaponskill set.
function get_weaponskill_set(equipSet, spell, spellMap)
    -- Custom handling for weaponskills
    local ws_mode = state.WeaponskillMode.current
    
    if ws_mode == 'Match' then
        -- Weaponskill mode is specified to match, see if we have a weaponskill mode
        -- corresponding to the current offense mode.  If so, use that.
        if spell.skill == 'Archery' or spell.skill == 'Marksmanship' then
            if state.RangedMode.current ~= 'Normal' and state.WeaponskillMode:contains(state.RangedMode.current) then
                ws_mode = state.RangedMode.current
			else
				ws_mode = 'Normal'
            end
        else
            if state.OffenseMode.current ~= 'Normal' and state.WeaponskillMode:contains(state.OffenseMode.current) then
                ws_mode = state.OffenseMode.current
			else
				ws_mode = 'Normal'
            end
        end
    end

    local custom_wsmode

    -- Allow the job file to specify a preferred weaponskill mode
    if get_custom_wsmode then
        custom_wsmode = get_custom_wsmode(spell, spellMap, ws_mode)
    end

    -- If the job file returned a weaponskill mode, use that.
    if custom_wsmode then
        ws_mode = custom_wsmode
    end

    if equipSet[ws_mode] then
        equipSet = equipSet[ws_mode]
        mote_vars.set_breadcrumbs:append(ws_mode)
    end
    
    return equipSet
end


-- Function to handle the logic of selecting the proper ranged set.
function get_ranged_set(equipSet, spell, spellMap)
    -- Attach Combat Form and Combat Weapon to set checks
    if state.CombatForm.has_value and equipSet[state.CombatForm.value] then
        equipSet = equipSet[state.CombatForm.value]
        mote_vars.set_breadcrumbs:append(state.CombatForm.value)
    end

    if state.CombatWeapon.has_value and equipSet[state.CombatWeapon.value] then
        equipSet = equipSet[state.CombatWeapon.value]
        mote_vars.set_breadcrumbs:append(state.CombatWeapon.value)
    end

    -- Check for specific mode for ranged attacks (eg: Acc, Att, etc)
    if equipSet[state.RangedMode.current] then
        equipSet = equipSet[state.RangedMode.current]
        mote_vars.set_breadcrumbs:append(state.RangedMode.current)
    end

    -- Tack on any additionally specified custom groups, if the sets are defined.
    for _,group in ipairs(classes.CustomRangedGroups) do
        if equipSet[group] then
            equipSet = equipSet[group]
            mote_vars.set_breadcrumbs:append(group)
        end
    end

    return equipSet
end


-------------------------------------------------------------------------------------------------------------------
-- Functions for optional supplemental gear overriding the default sets defined above.
-------------------------------------------------------------------------------------------------------------------

-- Function to apply any active defense set on top of the supplied set
-- @param baseSet : The set that any currently active defense set will be applied on top of. (gear set table)

function apply_defense(baseSet)
    if state.DefenseMode.current ~= 'None' then
        local defenseSet = sets.defense
		
        defenseSet = sets.defense[state[state.DefenseMode.current .. 'DefenseMode'].current] or defenseSet

        for _,group in ipairs(classes.CustomDefenseGroups) do
            defenseSet = defenseSet[group] or defenseSet
        end

		if sets.Reive and buffactive['Reive Mark'] and sets.Reive.neck == "Adoulin's Refuge +1" then
			defenseSet = set_combine(defenseSet, sets.Reive)
		end

        if user_customize_defense_set then
            defenseSet = user_customize_defense_set(defenseSet)
        end
		
        if job_customize_defense_set then
            defenseSet = job_customize_defense_set(defenseSet)
        end
		
        if user_job_customize_defense_set then
            defenseSet = user_job_customize_defense_set(defenseSet)
        end
		
        if user_job_customize_defense_set then
            defenseSet = extra_user_customize_defense_set(defenseSet)
        end

        baseSet = set_combine(baseSet, defenseSet)
    end
	
    return baseSet
end

--Apply a set for special modes where we are engaged or idle, that still allows swapping for other more important things.
function apply_passive(baseSet)
    if state.Passive.value ~= 'None' then
		baseSet = set_combine(baseSet, sets.passive[state.Passive.value])
	end
	
	if user_customize_passive_set then
		baseSet = user_customize_passive_set(baseSet)
    end
	
	if job_customize_passive_set then
		baseSet = job_customize_passive_set(baseSet)
	end
	
	if user_job_customize_passive_set then
		baseSet = user_job_customize_passive_set(baseSet)
	end

    return baseSet
end

-- Function to add kiting gear on top of the base set if kiting state is true.
-- @param baseSet : The gear set that the kiting gear will be applied on top of.
function apply_kiting(baseSet)
	if sets.Kiting and (state.Kiting.value or (player.status == 'Idle' and moving and state.DefenseMode.value == 'None' and state.Passive.value == 'None' and (state.IdleMode.value == 'Normal' or state.IdleMode.value == 'Sphere' or not (player.in_combat or being_attacked)))) then
		baseSet = set_combine(baseSet, sets.Kiting)
	end
	
	if user_customize_kiting_set then
		baseSet = user_customize_kiting_set(baseSet)
    end
	
	if job_customize_kiting_set then
		baseSet = job_customize_kiting_set(baseSet)
	end
	
	if user_job_customize_kiting_set then
		baseSet = user_job_customize_kiting_set(baseSet)
	end

    return baseSet
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions for constructing default gear sets.
-------------------------------------------------------------------------------------------------------------------

-- Get a spell mapping for the spell.
function get_spell_map(spell)
    local defaultSpellMap = classes.SpellMaps[spell.english]
    local jobSpellMap
    
    if job_get_spell_map then
        jobSpellMap = job_get_spell_map(spell, defaultSpellMap)
    end

    return jobSpellMap or defaultSpellMap
end


-- Select the equipment set to equip from a given starting table, based on standard
-- selection order: custom class, spell name, spell map, spell skill, and spell type.
-- Spell skill and spell type may further refine their selections based on
-- custom class, spell name and spell map.
function select_specific_set(equipSet, spell, spellMap)
    -- Take the determined base equipment set and try to get the simple naming extensions that
    -- may apply to it (class, spell name, spell map).
    local namedSet = get_named_set(equipSet, spell, spellMap)
    
    -- If no simple naming sub-tables were found, and we simply got back the original equip set,
    -- check for spell.skill and spell.type, then check the simple naming extensions again.
    if namedSet == equipSet then
	
        if spell.skill and equipSet[spell.skill] and not classes.SkipSkillCheck then
            namedSet = equipSet[spell.skill]
            mote_vars.set_breadcrumbs:append(spell.skill)
        elseif spell.type and equipSet[spell.type] then
            namedSet = equipSet[spell.type]
            mote_vars.set_breadcrumbs:append(spell.type)
        else
            return equipSet
        end
        
        namedSet = get_named_set(namedSet, spell, spellMap)
    end

    return namedSet or equipSet
end


-- Simple utility function to handle a portion of the equipment set determination.
-- It attempts to select a sub-table of the provided equipment set based on the
-- standard search order of custom class, spell name, and spell map.
-- If no such set is found, it returns the original base set (equipSet) provided.
function get_named_set(equipSet, spell, spellMap)
    if equipSet then
        if classes.CustomClass and equipSet[classes.CustomClass] then
            mote_vars.set_breadcrumbs:append(classes.CustomClass)
            return equipSet[classes.CustomClass]
        elseif equipSet[spell.english] then
            mote_vars.set_breadcrumbs:append(spell.english)
            return equipSet[spell.english]
        elseif spellMap and equipSet[spellMap] then
            mote_vars.set_breadcrumbs:append(spellMap)
            return equipSet[spellMap]
        else
            return equipSet
        end
    end
end


-------------------------------------------------------------------------------------------------------------------
-- Hooks for other events.
-------------------------------------------------------------------------------------------------------------------

-- Called when the player's subjob changes.
function sub_job_change(newSubjob, oldSubjob)
    if user_setup then
        user_setup()
    end
	
    if extra_user_setup then
        extra_user_setup()
    end
    
    if job_sub_job_change then
        job_sub_job_change(newSubjob, oldSubjob)
    end
    
    send_command('gs c update')
end


-- Called when the player's status changes.
function status_change(newStatus, oldStatus)
    -- init a new eventArgs
    local eventArgs = {handled = false}
    mote_vars.set_breadcrumbs:clear()

	if not (newStatus == 'Idle' or newStatus == 'Engaged') then
		if state.RngHelper.value then
			send_command('gs rh clear')
		end
		
		if useItem then
			useItem = false
			if useItemSlot == 'item' then
				windower.send_command('put '..useItemName..' satchel')
			elseif useItemSlot == 'set' then
				local slots = T{}
				for slot,item in pairs(sets[useItemName]) do
					slots:append(slot)
				end
				enable(slots)
				if player.inventory[useItemName] then
					windower.send_command('wait 1;put '..set_to_item(useItemName)..' satchel')
				end
			else 
				enable(useItemSlot)
				if player.inventory[useItemName] then
					windower.send_command('wait 1;put '..useItemName..' satchel')
				end
			end
			add_to_chat(217,"Cancelling using "..useItemName..".")
			useItemName = ''
			useItemSlot = ''
		end
	end
	
    if newStatus == 'Engaged' then
		update_combat_form()
	end
	
    -- Allow a global function to be called on status change.
    if user_status_change then
        user_status_change(newStatus, oldStatus, eventArgs)
    end
	
    -- Then call individual jobs to handle status change events.
    if not eventArgs.handled then
        if user_job_status_change then
            user_job_status_change(newStatus, oldStatus, eventArgs)
        end
    end
	
    if not eventArgs.handled then
        if job_status_change then
            job_status_change(newStatus, oldStatus, eventArgs)
        end
    end
	
    if extra_user_status_change then
        extra_user_status_change(newStatus, oldStatus, eventArgs)
    end

    -- Handle equipping default gear if the job didn't mark this as handled.
    if not eventArgs.handled and not midaction() and not pet_midaction() then
        handle_equipping_gear(newStatus)
        display_breadcrumbs()
    end
end

-- Handle notifications of general state change.
function state_change(stateField, newValue, oldValue)
    if stateField == 'Weapons' then
		if ((newValue:contains('DW') or newValue:contains('Dual')) and not can_dual_wield()) or (newValue:contains('Proc') and state.SkipProcWeapons.value) then
			local startindex = state.Weapons.index
			while ((state.Weapons.value:contains('DW') or state.Weapons.value:contains('Dual')) and not can_dual_wield()) or (state.SkipProcWeapons.value and state.Weapons.value:contains('Proc')) do
				state.Weapons:cycle()
				if startindex == state.Weapons.index then break end
			end
			handle_weapons()
		elseif sets.weapons[newValue] then
			equip_weaponset(newValue)
		elseif newValue == 'None' then
			enable('main','sub','range','ammo')
		else
			if not sets.weapons[newValue] then
				add_to_chat(123,"sets.weapons."..newValue.." does not exist, resetting weapon state.")
			end
			state.Weapons:reset()
			if sets.weapons[state.Weapons.value] then
				equip_weaponset(state.Weapons.value)
			end
		end
	elseif stateField == 'RngHelper' then
		if newValue == true then
			send_command('gs rh enable')
		else
			send_command('gs rh disable')
		end
    end
	
	if user_job_state_change then
		user_job_state_change(stateField, newValue, oldValue)
	end
	
	if user_state_change then
		user_state_change(stateField, newValue, oldValue)
	end
	
	if job_state_change then
		job_state_change(stateField, newValue, oldValue)
	end
	
	if stateField == 'Rune Element' then
		send_command('wait .001;gs c DisplayRune')
	elseif stateField == 'Elemental Mode' then
		if player.main_job == 'COR' then
			send_command('wait .001;gs c DisplayShot')
		else
			send_command('wait .001;gs c DisplayElement')
		end
	elseif stateField == 'Capacity' and newValue == 'false' and cprings:contains(player.equipment.left_ring) then
            enable("left_ring")
	end
	
	update_job_states()
end

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function buff_change(buff, gain)
    -- Init a new eventArgs
    local eventArgs = {handled = false}

    if state.Buff[buff:ucfirst()] ~= nil then
        state.Buff[buff:ucfirst()] = gain
    end

    -- Allow a global function to be called on buff change.
    if user_buff_change then
        user_buff_change(buff, gain, eventArgs)
    end
	
    -- Allow jobs to handle buff change events.
    if not eventArgs.handled then
        if job_buff_change then
            job_buff_change(buff, gain, eventArgs)
        end
    end
	
    if user_job_buff_change then
        user_job_buff_change(buff, gain, eventArgs)
    end
	
	if buff == 'Voidwatcher' then
		state.SkipProcWeapons:set('False')
	elseif S{'sleep','Lullaby'}:contains(buff) and state.CancelStoneskin.value then
		send_command('cancel stoneskin')
	elseif (S{'Blink','Third Eye'}:contains(buff) or buff:contains('Copy Image')) and not gain then
		lastshadow = "None"
    elseif S{'Commitment','Dedication'}:contains(buff) then
        if gain and (cprings:contains(player.equipment.left_ring) or xprings:contains(player.equipment.left_ring)) then
            enable("left_ring")
			
			if time_test and player.equipment.left_ring == 'Capacity Ring' then
				--local CurrentTime = (os.time(os.date("!*t", os.time())) + time_offset)
				local CurrentTime = os.time(os.date("!*t"))
				time_test = false
				local CapacityNextUse = get_item_next_use('Capacity Ring').next_use_time
				local CapacityOffset = CapacityNextUse - CurrentTime
				local NegativeCapacityOffset = (CapacityNextUse - CurrentTime) * -1
				local CapacityOffsetPlus = CapacityOffset + 900
				local CapacityOffsetMinus = CapacityOffset - 900
				local NegativeCapacityOffsetPlus =  NegativeCapacityOffset + 900
				local NegativeCapacityOffsetMinus = NegativeCapacityOffset - 900
				if (CapacityNextUse - (CurrentTime + CapacityOffsetPlus)) > 895 and (CapacityNextUse - (CurrentTime + CapacityOffsetPlus)) < 905 then
					windower.add_to_chat(123,"Capacity Ring Used: Your offset is: "..CapacityOffsetPlus.."")
				elseif (CapacityNextUse - (CurrentTime + CapacityOffsetMinus)) > 895 and (CapacityNextUse - (CurrentTime + CapacityOffsetMinus)) < 905 then
					windower.add_to_chat(123,"Capacity Ring Used: Your offset is: "..CapacityOffsetMinus.."")
				elseif (CapacityNextUse - (CurrentTime + NegativeCapacityOffsetPlus)) > 895 and (CapacityNextUse - (CurrentTime + NegativeCapacityOffsetPlus)) < 905 then
					windower.add_to_chat(123,"Capacity Ring Used: Your offset is: "..NegativeCapacityOffsetPlus.."")
				elseif (CapacityNextUse - (CurrentTime + NegativeCapacityOffsetMinus)) > 895 and (CapacityNextUse - (CurrentTime + NegativeCapacityOffsetMinus)) < 905 then
					windower.add_to_chat(123,"Capacity Ring Used: Your offset is: "..NegativeCapacityOffsetMinus.."")
				else
					windower.add_to_chat(123,"Unable to automatically determine your offset")
					time_test = true
				end
			end
			
		elseif gain and (player.equipment.head == "Guide Beret" or player.equipment.head == "Sprout Beret") then
			enable("head")
        end
    end

	if not midaction() and not pet_midaction() then
		handle_equipping_gear(player.status)
	end
	
	notify_buffs(buff, gain)
	
    if extra_user_buff_change then
        extra_user_buff_change(buff, gain, eventArgs)
    end
	
	if state.DisplayMode.value then update_job_states()	end
end


-- Called when a player gains or loses a pet.
-- pet == pet gained or lost
-- gain == true if the pet was gained, false if it was lost.
function pet_change(pet, gain)
    -- Init a new eventArgs
    local eventArgs = {handled = false}

    -- Allow jobs to handle pet change events.
    if user_job_pet_change then
        user_job_pet_change(pet, gain, eventArgs)
    end
	
    if user_pet_change and not not eventArgs.handled then
        user_pet_change(pet, gain, eventArgs)
    end
	
    if job_pet_change and not eventArgs.handled then
        job_pet_change(pet, gain, eventArgs)
    end

    -- Equip default gear if not handled by the job.
    if not eventArgs.handled then
        if not midaction() and not pet_midaction() then handle_equipping_gear(player.status) end
    end
end


-- Called when the player's pet's status changes.
-- Note that this is also called after pet_change when the pet is released.
-- As such, don't automatically handle gear equips.  Only do so if directed
-- to do so by the job.
function pet_status_change(newStatus, oldStatus)
    -- Init a new eventArgs
    local eventArgs = {handled = false}

    -- Allow jobs to override this code
    if job_pet_status_change then
        job_pet_status_change(newStatus, oldStatus, eventArgs)
    end
	
	if not midaction() and not pet_midaction() then handle_equipping_gear(player.status) end
end

-------------------------------------------------------------------------------------------------------------------
-- Debugging functions.
-------------------------------------------------------------------------------------------------------------------

-- This is a debugging function that will print the accumulated set selection
-- breadcrumbs for the default selected set for any given action stage.
function display_breadcrumbs(spell, spellMap, action)
    if not _settings.debug_mode then
        return
    end
    
    local msg = 'Default '
    
    if action and spell then
        msg = msg .. action .. ' set selection for ' .. spell.name
    end
    
    if spellMap then
        msg = msg .. ' (' .. spellMap .. ')'
    end
    msg = msg .. ' : '
    
    local cons
    
    for _,name in ipairs(mote_vars.set_breadcrumbs) do
        if not cons then
            cons = name
        else
            if name:contains(' ') or name:contains("'") then
                cons = cons .. '["' .. name .. '"]'
            else
                cons = cons .. '.' .. name
            end
        end
    end

    if cons then
        if action and cons == ('sets.' .. action) then
            msg = msg .. "None"
        else
            msg = msg .. tostring(cons)
        end
        add_to_chat(123, msg)
    end
end

-- Auto-initialize the include - Do this at the bottom so that other user-files can overwrite these functions.
init_include()