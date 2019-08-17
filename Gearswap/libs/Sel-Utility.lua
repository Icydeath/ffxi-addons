-------------------------------------------------------------------------------------------------------------------
-- General utility functions that can be used by any job files.
-- Outside the scope of what the main include file deals with.
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- Buff utility functions.
-------------------------------------------------------------------------------------------------------------------

local cancel_spells_to_check = S{'Sneak', 'Stoneskin', 'Spectral Jig', 'Trance', 'Monomi: Ichi', 'Utsusemi: Ichi','Utsusemi: Ni','Diamondhide','Magic Barrier'}
local cancel_types_to_check = S{'Waltz', 'Samba'}

-- Function to cancel buffs if they'd conflict with using the spell you're attempting.
-- Requirement: Must have Cancel addon installed and loaded for this to work.
function cancel_conflicting_buffs(spell, spellMap, eventArgs)
    if cancel_spells_to_check:contains(spell.english) or cancel_types_to_check:contains(spell.type) then
        if spell.english == 'Spectral Jig' and buffactive.sneak then
            cast_delay(0.2)
			send_command('cancel sneak')
			tickdelay = os.clock() + 1.5
        elseif spell.english == 'Sneak' and spell.target.type == 'SELF' and buffactive.sneak then
            send_command('cancel sneak')
        elseif spell.english == ('Stoneskin') or spell.english == ('Diamondhide') or spell.english == ('Magic Barrier') then
            send_command('@wait 1;cancel stoneskin')
        elseif spell.english:startswith('Monomi') then
            send_command('@wait 1.5;cancel sneak')
        elseif spell.english == 'Utsusemi: Ni' and player.main_job == 'NIN' and lastshadow == 'Utsusemi: San' then
			if buffactive['Copy Image (4+)'] and conserveshadows then
				add_to_chat(123,'Abort: You have four or more shadows.')
                eventArgs.cancel = true
			else
				send_command('@wait '..utsusemi_ni_cancel_delay..';cancel copy image*')
			end
        elseif spell.english == 'Utsusemi: Ichi' and lastshadow ~= 'Utsusemi: Ichi' then
			if (buffactive['Copy Image (3)'] or buffactive['Copy Image (4+)']) and conserveshadows then
				add_to_chat(123,'Abort: You have three or more shadows.')
                eventArgs.cancel = true
			else
				send_command('@wait '..utsusemi_cancel_delay..';cancel copy image*')
			end
        elseif (spell.english == 'Trance' or spell.type=='Waltz') and buffactive['saber dance'] then
            cast_delay(0.2)
            send_command('cancel saber dance')
			tickdelay = os.clock() + 1.7
        elseif spell.type=='Samba' and buffactive['fan dance'] then
            cast_delay(0.2)
            send_command('cancel fan dance')
			tickdelay = os.clock() + 1.7
        end
    end
end


function notify_buffs(buff, gain)
	if state.NotifyBuffs.value and NotifyBuffs:contains(buff) then
		if gain then
			windower.chat.input('/p I just got hit with '..buff..'.')
		else
			windower.chat.input('/p '..buff..' is off now.')
		end
	end
end

-- Function to make auto-translate work in windower.
-- Usage: windower.add_to_chat(207, 'Test ' .. auto_translate(command))

do
    local cache = {}
    auto_translate = function(term)
        if not cache[term] then
            local entry = res.auto_translates:with('english', term)
            cache[term] = entry and 'CH>HC':pack(0xFD, 0x0202, entry.id, 0xFD) or term
        end

        return cache[term]
    end
end

-- Some mythics have special durations for level 1 and 2 aftermaths
local special_aftermath_mythics = S{'Tizona', 'Kenkonken', 'Murgleis', 'Yagrush', 'Carnwenhan', 'Nirvana', 'Tupsimati', 'Idris'}

-- Call from job_precast() to setup aftermath information for custom timers.
function custom_aftermath_timers_precast(spell)
    if spell.type == 'WeaponSkill' then
        info.aftermath = {}
        
        local relic_ws = data.weaponskills.relic[player.equipment.main] or data.weaponskills.relic[player.equipment.range]
        local mythic_ws = data.weaponskills.mythic[player.equipment.main] or data.weaponskills.mythic[player.equipment.range]
        local empy_ws = data.weaponskills.empyrean[player.equipment.main] or data.weaponskills.empyrean[player.equipment.range]
        
        if not relic_ws and not mythic_ws and not empy_ws then
            return
        end

        info.aftermath.weaponskill = spell.english
        info.aftermath.duration = 0
        
        info.aftermath.level = math.floor(player.tp / 1000)
        if info.aftermath.level == 0 then
            info.aftermath.level = 1
        end
        
        if spell.english == relic_ws then
            info.aftermath.duration = math.floor(0.2 * player.tp)
            if info.aftermath.duration < 20 then
                info.aftermath.duration = 20
            end
        elseif spell.english == empy_ws then
            -- nothing can overwrite lvl 3
            if buffactive['Aftermath: Lv.3'] then
                return
            end
            -- only lvl 3 can overwrite lvl 2
            if info.aftermath.level ~= 3 and buffactive['Aftermath: Lv.2'] then
                return
            end
            
            -- duration is based on aftermath level
            info.aftermath.duration = 30 * info.aftermath.level
        elseif spell.english == mythic_ws then
            -- nothing can overwrite lvl 3
            if buffactive['Aftermath: Lv.3'] then
                return
            end
            -- only lvl 3 can overwrite lvl 2
            if info.aftermath.level ~= 3 and buffactive['Aftermath: Lv.2'] then
                return
            end

            -- Assume mythic is lvl 80 or higher, for duration
                        
            if info.aftermath.level == 1 then
                info.aftermath.duration = (special_aftermath_mythics:contains(player.equipment.main) and 270) or 90
            elseif info.aftermath.level == 2 then
                info.aftermath.duration = (special_aftermath_mythics:contains(player.equipment.main) and 270) or 120
            else
                info.aftermath.duration = 180
            end
        end
    end
end


-- Call from job_aftercast() to create the custom aftermath timer.
function custom_aftermath_timers_aftercast(spell)
    if not spell.interrupted and spell.type == 'WeaponSkill' and
       info.aftermath and info.aftermath.weaponskill == spell.english and info.aftermath.duration > 0 then

        local aftermath_name = 'Aftermath: Lv.'..tostring(info.aftermath.level)
        send_command('timers d "Aftermath: Lv.1"')
        send_command('timers d "Aftermath: Lv.2"')
        send_command('timers d "Aftermath: Lv.3"')
        send_command('timers c "'..aftermath_name..'" '..tostring(info.aftermath.duration)..' down abilities/00027.png')

        info.aftermath = {}
    end
end


-------------------------------------------------------------------------------------------------------------------
-- Utility functions for changing spells and target types in an automatic manner.
-------------------------------------------------------------------------------------------------------------------

waltz_tp_cost = {['Curing Waltz'] = 200, ['Curing Waltz II'] = 350, ['Curing Waltz III'] = 500, ['Curing Waltz IV'] = 650, ['Curing Waltz V'] = 800}

-- Utility function for automatically adjusting the waltz spell being used to match HP needs and TP limits.
-- Handle spell changes before attempting any precast stuff.
function refine_waltz(spell, spellMap, eventArgs)
    if spell.type ~= 'Waltz' then
        return
	elseif player.tp < 150 then
		add_to_chat(123, 'Abort: Insufficient TP ['..tostring(player.tp)..'] to waltz.')
		eventArgs.cancel = true
		return
    end

	if sets.precast.Waltz and sets.precast.Waltz.legs and (sets.precast.Waltz.legs == "Desultor Tassets" or sets.precast.Waltz.legs == "Blitzer Poleyn" or sets.precast.Waltz.legs == "Tatsumaki Sitagoromo") then
		waltz_tp_cost = {['Curing Waltz'] = 150, ['Curing Waltz II'] = 300, ['Curing Waltz III'] = 450, ['Curing Waltz IV'] = 600, ['Curing Waltz V'] = 750}
	else
		waltz_tp_cost = {['Curing Waltz'] = 200, ['Curing Waltz II'] = 350, ['Curing Waltz III'] = 500, ['Curing Waltz IV'] = 650, ['Curing Waltz V'] = 800}
	end
	
    -- Don't modify anything for Healing Waltz or Divine Waltzes
    if spell.english == "Healing Waltz" or spell.english == "Divine Waltz" or spell.english == "Divine Waltz II" then
        return
    end

    local newWaltz = spell.english
    local waltzID
    
    local missingHP
    
    -- If curing ourself, get our exact missing HP
    if spell.target.type == "SELF" then
        missingHP = player.max_hp - player.hp
    -- If curing someone in our alliance, we can estimate their missing HP
    elseif spell.target.isallymember then
        local target = find_player_in_alliance(spell.target.name)
        local est_max_hp = target.hp / (target.hpp/100)
        missingHP = math.floor(est_max_hp - target.hp)
		
		if buffactive['Contradance'] then
			missingHP = missingHP / 2
		end
    end
    
    -- If we have an estimated missing HP value, we can adjust the preferred tier used.
    if missingHP ~= nil then
        if player.main_job == 'DNC' then
			local abil_recasts = windower.ffxi.get_ability_recasts()
            if missingHP < 40 and spell.target.name == player.name then
                -- Not worth curing yourself for so little.
                -- Don't block when curing others to allow for waking them up.
                add_to_chat(123,'Abort: You have full HP!')
                eventArgs.cancel = true
                return
            elseif missingHP < 200 then
                newWaltz = 'Curing Waltz'
                waltzID = 190
            elseif missingHP < 600 then
                newWaltz = 'Curing Waltz II'
                waltzID = 191
            elseif missingHP < 1100 then
                newWaltz = 'Curing Waltz III'
                waltzID = 192
			elseif state.AutoContradanceMode.value and abil_recasts[229] < latency then
                eventArgs.cancel = true
				windower.chat.input('/ja "Contradance" <me>')
				windower.chat.input:schedule(1,'/ja "Curing Waltz IV" '..spell.target.raw..'')
                return
            elseif missingHP < 1500 then
                newWaltz = 'Curing Waltz IV'
                waltzID = 193
            else
                newWaltz = 'Curing Waltz V'
                waltzID = 311
            end
        elseif player.sub_job == 'DNC' then
            if missingHP < 40 and spell.target.name == player.name then
                -- Not worth curing yourself for so little.
                -- Don't block when curing others to allow for waking them up.
                add_to_chat(123,'Abort: You have full HP!')
                eventArgs.cancel = true
                return
            elseif missingHP < 150 then
                newWaltz = 'Curing Waltz'
                waltzID = 190
            elseif missingHP < 300 then
                newWaltz = 'Curing Waltz II'
                waltzID = 191
            else
                newWaltz = 'Curing Waltz III'
                waltzID = 192
            end
        else
            -- Not dnc main or sub; bail out
            return
        end
    end

    local tpCost = waltz_tp_cost[newWaltz]

    local downgrade
    
    -- Downgrade the spell to what we can afford
    if player.tp < tpCost and not buffactive.trance then
        --[[ Costs:
            Curing Waltz:     200 TP
            Curing Waltz II:  350 TP
            Curing Waltz III: 500 TP
            Curing Waltz IV:  650 TP
            Curing Waltz V:   800 TP
            Divine Waltz:     400 TP
            Divine Waltz II:  800 TP
        --]]
        
		if player.tp < 350 then
            newWaltz = 'Curing Waltz'
        elseif player.tp < 500 then
            newWaltz = 'Curing Waltz II'
        elseif player.tp < 650 then
            newWaltz = 'Curing Waltz III'
        elseif player.tp < 800 then
            newWaltz = 'Curing Waltz IV'
        end
        
        downgrade = 'Insufficient TP ['..tostring(player.tp)..']. Downgrading to '..newWaltz..'.'
    end

    
    if newWaltz ~= spell.english then
        send_command('@input /ja "'..newWaltz..'" '..tostring(spell.target.raw))
        if downgrade then
            add_to_chat(122, downgrade)
        end
        eventArgs.cancel = true
        return
    end

    if missingHP and missingHP > 0 then
        add_to_chat(122,'Trying to cure '..tostring(missingHP)..' HP using '..newWaltz..'.')
    end
end


-- Function to allow for automatic adjustment of the spell target type based on preferences.
function auto_change_target(spell, spellMap)
    -- Don't adjust targetting for explicitly named targets
    if not spell.target.raw:startswith('<') then
        return
    end

    -- Do not modify target for spells where we get <lastst> or <me>.
    if spell.target.raw == ('<lastst>') or spell.target.raw == ('<me>') then
        return
    end
    
    -- init a new eventArgs with current values
    local eventArgs = {handled = false, PCTargetMode = state.PCTargetMode.value, SelectNPCTargets = state.SelectNPCTargets.value}

    -- Allow the job to do custom handling, or override the default values.
    -- They can completely handle it, or set one of the secondary eventArgs vars to selectively
    -- override the default state vars.
    if job_auto_change_target then
        job_auto_change_target(spell, action, spellMap, eventArgs)
    end
    
    -- If the job handled it, we're done.
    if eventArgs.handled then
        return
    end
    
    local pcTargetMode = eventArgs.PCTargetMode
    local selectNPCTargets = eventArgs.SelectNPCTargets

    
    local validPlayers = S{'Self', 'Player', 'Party', 'Ally', 'NPC'}

    local intersection = spell.targets * validPlayers
    local canUseOnPlayer = not intersection:empty()
    
    local newTarget
    
    -- For spells that we can cast on players:
    if canUseOnPlayer and pcTargetMode ~= 'default' then
        -- Do not adjust targetting for player-targettable spells where the target was <t>
        if spell.target.raw ~= ('<t>') then
            if pcTargetMode == 'stal' then
                -- Use <stal> if possible, otherwise fall back to <stpt>.
                if spell.targets.Ally then
                    newTarget = '<stal>'
                elseif spell.targets.Party then
                    newTarget = '<stpt>'
                end
            elseif pcTargetMode == 'stpt' then
                -- Even ally-possible spells are limited to the current party.
                if spell.targets.Ally or spell.targets.Party then
                    newTarget = '<stpt>'
                end
            elseif pcTargetMode == 'stpc' then
                -- If it's anything other than a self-only spell, can change to <stpc>.
                if spell.targets.Player or spell.targets.Party or spell.targets.Ally or spell.targets.NPC then
                    newTarget = '<stpc>'
                end
            end
        end
    -- For spells that can be used on enemies:
    elseif spell.targets and spell.targets.Enemy and selectNPCTargets then
        -- Note: this means macros should be written for <t>, and it will change to <stnpc>
        -- if the flag is set.  It won't change <stnpc> back to <t>.
        newTarget = '<stnpc>'
    end
    
    -- If a new target was selected and is different from the original, call the change function.
    if newTarget and newTarget ~= spell.target.raw then
        change_target(newTarget)
    end
end


-------------------------------------------------------------------------------------------------------------------
-- Environment utility functions.
-------------------------------------------------------------------------------------------------------------------

-- Function to get the current weather intensity: 0 for none, 1 for single weather, 2 for double weather.
function get_weather_intensity()
    return gearswap.res.weather[world.weather_id].intensity
end


-- Returns true if you're in a party solely comprised of Trust NPCs.
-- TODO: Do we need a check to see if we're in a party partly comprised of Trust NPCs?
function is_trust_party()
    -- Check if we're solo
    if party.count == 1 then
        return false
    end

    -- If we're in an alliance, can't be a Trust party.
    if alliance[2].count > 0 or alliance[3].count > 0 then
        return false
    end
    
    -- Check that, for each party position aside from our own, the party
    -- member has one of the Trust NPC names, and that those party members
    -- are flagged is_npc.
    for i = 2,6 do
        if party[i] then
            if not npcs.Trust:contains(party[i].name) then
                return false
            end
            if party[i].mob and party[i].mob.is_npc == false then
                return false
            end
        end
    end
    
    -- If it didn't fail any of the above checks, return true.
    return true
end


-- Call these function with a list of equipment slots to check ('head', 'neck', 'body', etc)
-- Returns true if any of the specified slots are currently encumbered.
-- Returns false if all specified slots are unencumbered.
function is_encumbered(...)
    local check_list = {...}
    -- Compensate for people passing a table instead of a series of strings.
    if type(check_list[1]) == 'table' then
        check_list = check_list[1]
    end
    local check_set = S(check_list)
    
    for slot_id,slot_name in pairs(gearswap.default_slot_map) do
        if check_set:contains(slot_name) then
            if gearswap.encumbrance_table[slot_id] then
                return true
            end
        end
    end
    
    return false
end

-------------------------------------------------------------------------------------------------------------------
-- Elemental gear utility functions.
-------------------------------------------------------------------------------------------------------------------

-- General handler function to set all the elemental gear for an action.
function set_elemental_gear(spell)
	--No longer needed because of Fotia.
    --set_elemental_gorget_belt(spell)
    set_elemental_obi_cape_ring(spell)
    set_elemental_staff(spell)
end


--[[ Set the name field of the predefined gear vars for gorgets and belts, for the specified weaponskill. No longer needed because of Fotia.
function set_elemental_gorget_belt(spell)
    if spell.type ~= 'WeaponSkill' then
        return
    end

    -- Get the union of all the skillchain elements for the weaponskill
    local weaponskill_elements = S{}:
        union(skillchain_elements[spell.skillchain_a]):
        union(skillchain_elements[spell.skillchain_b]):
        union(skillchain_elements[spell.skillchain_c])
    
    gear.ElementalGorget.name = get_elemental_item_name("gorget", weaponskill_elements) or gear.default.weaponskill_neck  or ""
    gear.ElementalBelt.name   = get_elemental_item_name("belt", weaponskill_elements)   or gear.default.weaponskill_waist or ""
end
]]--

-- Function to get an appropriate obi/cape/ring for the current action.
function set_elemental_obi_cape_ring(spell)
    if spell.element == 'None' then
        return
    end
	
	if spell.element == world.weather_element or spell.element == world.day_element then
		gear.ElementalCape.name = "Twilight Cape"
		local orpheus_avail = item_available("Orpheus's Sash")
		local hachirin_avail = item_available('Hachirin-no-Obi')
		if hachirin_avail and spell.element == world.weather_element and gearswap.res.weather[world.weather_id].intensity == 2 then
			gear.ElementalObi.name = "Hachirin-no-Obi"
		elseif orpheus_avail and spell.target.distance < (1.7 + spell.target.model_size) then
			gear.ElementalObi.name ="Orpheus's Sash"
		elseif hachirin_avail and spell.element and spell.element == world.weather_element then
			gear.ElementalObi.name = "Hachirin-no-Obi"
		elseif orpheus_avail and spell.target.distance < (8 + spell.target.model_size) then
			gear.ElementalObi.name ="Orpheus's Sash"
		elseif hachirin_avail then
			gear.ElementalObi.name = "Hachirin-no-Obi"
		else
			gear.ElementalObi.name = gear.default.obi_waist
		end

	else
		gear.ElementalObi.name = gear.default.obi_waist
		gear.ElementalCape.name = gear.default.obi_back
	end
	
	if spell.element == world.day_element and spell.english ~= 'Impact' and not S{'Divine Magic','Dark Magic','Healing Magic'}:contains(spell.skill) then
        gear.ElementalRing.name = "Zodiac Ring"
	else
		gear.ElementalRing.name = gear.default.obi_ring
	end

--[[
    local world_elements = S{world.day_element}
    if world.weather_element ~= 'None' then
        world_elements:add(world.weather_element)
    end
	
    local obi_name = get_elemental_item_name("obi", S{spell.element}, world_elements)
    gear.ElementalObi.name = obi_name or gear.default.obi_waist  or ""
    
    if obi_name then
        if player.inventory['Twilight Cape'] or player.wardrobe['Twilight Cape'] or player.wardrobe2['Twilight Cape'] then
            gear.ElementalCape.name = "Twilight Cape"
        end
        if (player.inventory['Zodiac Ring'] or player.wardrobe['Zodiac Ring'] or player.wardrobe2['Twilight Cape']) and spell.english ~= 'Impact' and
            not S{'Divine Magic','Dark Magic','Healing Magic'}:contains(spell.skill) then
            gear.ElementalRing.name = "Zodiac Ring"
        end
    else
        gear.ElementalCape.name = gear.default.obi_back
        gear.ElementalRing.name = gear.default.obi_ring
    end
]]-- Old Text

end


-- Function to get the appropriate fast cast and/or recast staves for the current spell.
function set_elemental_staff(spell)
    if spell.action_type ~= 'Magic' then
        return
    end

    gear.FastcastStaff.name = get_elemental_item_name("fastcast_staff", S{spell.element}) or gear.default.fastcast_staff  or ""
    gear.RecastStaff.name   = get_elemental_item_name("recast_staff", S{spell.element})   or gear.default.recast_staff    or ""
end


-- Gets the name of an elementally-aligned piece of gear within the player's
-- inventory that matches the conditions set in the parameters.
--
-- item_type: Type of item as specified in the elemental_map mappings.
-- EG: gorget, belt, obi, fastcast_staff, recast_staff
--
-- valid_elements: Elements that are valid for the action being taken.
-- IE: Weaponskill skillchain properties, or spell element.
--
-- restricted_to_elements: Secondary elemental restriction that limits
-- whether the item check can be considered valid.
-- EG: Day or weather elements that have to match the spell element being queried.
--
-- Returns: Nil if no match was found (either due to elemental restrictions,
-- or the gear isn't in the player inventory), or the name of the piece of
-- gear that matches the query.
function get_elemental_item_name(item_type, valid_elements, restricted_to_elements)
    local potential_elements = restricted_to_elements or elements.list
    local item_map = elements[item_type:lower()..'_of']
    
    for element in (potential_elements.it or it)(potential_elements) do
        if valid_elements:contains(element) and (player.inventory[item_map[element]] or player.wardrobe[item_map[element]] or player.wardrobe2[item_map[element]]) or player.wardrobe3[item_map[element]] or player.wardrobe4[item_map[element]] then
            return item_map[element]
        end
    end
end


-------------------------------------------------------------------------------------------------------------------
-- Function to easily change to a given macro set or book.  Book value is optional.
-------------------------------------------------------------------------------------------------------------------

function set_macro_page(set,book)
    if not tonumber(set) then
        add_to_chat(123,'Error setting macro page: Set is not a valid number ('..tostring(set)..').')
        return
    end
    if set < 1 or set > 10 then
        add_to_chat(123,'Error setting macro page: Macro set ('..tostring(set)..') must be between 1 and 10.')
        return
    end

    if book then
        if not tonumber(book) then
            add_to_chat(123,'Error setting macro page: book is not a valid number ('..tostring(book)..').')
            return
        end
        if book < 1 or book > 20 then
            add_to_chat(123,'Error setting macro page: Macro book ('..tostring(book)..') must be between 1 and 20.')
            return
        end
        send_command('@input /macro book '..tostring(book)..';wait .1;input /macro set '..tostring(set))
    else
        send_command('@input /macro set '..tostring(set))
    end
end


-- Function for optionally including files if they exist.
function optional_include(filename)
	local path = gearswap.pathsearch({filename})
	if path then
		include(filename)
	else
		return false
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions for vars or other data manipulation.
-------------------------------------------------------------------------------------------------------------------

-- Attempt to locate a specified name within the current alliance.
function find_player_in_alliance(name)
    for party_index,ally_party in ipairs(alliance) do
        for player_index,_player in ipairs(ally_party) do
            if _player.name == name then
                return _player
            end
        end
    end
end

function number_of_jps(jp_tab)
    local count = 0
    for _,v in pairs(jp_tab) do
        count = count + v*(v+1)
    end
    return count/2
end

function add_table_to_chat(table)
    for k, v in pairs( table ) do
        add_to_chat(123,''..k..', '..v)
    end
end

function get_spell_table_by_name(spell_name)
	for k in pairs(res.spells) do
		if res.spells[k][language] == spell_name then
			return res.spells[k]
		end
	end
	return false
end

function silent_can_use(spellid)
	local available_spells = windower.ffxi.get_spells()
	local spell_jobs = copy_entry(res.spells[spellid].levels)
        
	-- Filter for spells that you do not know. Exclude Impact.
	if not available_spells[spellid] and not (spellid == 503 or spellid == 417) then
		return false
	-- Filter for spells that you know, but do not currently have access to
	elseif (not spell_jobs[player.main_job_id] or not (spell_jobs[player.main_job_id] <= player.main_job_level or
		(spell_jobs[player.main_job_id] >= 100 and number_of_jps(player.job_points[(res.jobs[player.main_job_id].ens):lower()]) >= spell_jobs[player.main_job_id]) ) ) and
		(not spell_jobs[player.sub_job_id] or not (spell_jobs[player.sub_job_id] <= player.sub_job_level)) then
		return false
	elseif res.spells[spellid].type == 'BlueMagic' and not ((player.main_job_id == 16 and (unbridled_learning_set[res.spells[spellid].en] or table.contains(windower.ffxi.get_mjob_data().spells,spellid))) or (player.sub_job_id == 16 and table.contains(windower.ffxi.get_sjob_data().spells,spellid))) then	
		return false
	else
		return true
	end
end

function can_use(spell)
    local category = outgoing_action_category_table[unify_prefix[spell.prefix]]
    if world.in_mog_house then
        add_to_chat(123,"Abort: You are currently in a Mog House zone.")
        return false
    elseif category == 3 then
        local available_spells = windower.ffxi.get_spells()
        local spell_jobs = copy_entry(res.spells[spell.id].levels)
        
        -- Filter for spells that you do not know. Exclude Impact.
        if not available_spells[spell.id] and not (spell.id == 503 or spell.id == 417) then
            add_to_chat(123,"Abort: You haven't learned ["..(res.spells[spell.id][language] or spell.id).."].")
            return false
        elseif spell.type == 'Ninjutsu'  then
            if player.main_job_id ~= 13 and player.sub_job_id ~= 13 then
                add_to_chat(123,"Abort: You don't have access to ["..(spell[language] or spell.id).."].")
                return false
            elseif not player.inventory[tool_map[spell.english][language]] and not (player.main_job_id == 13 and player.inventory[universal_tool_map[spell.english][language]]) then
				if player.main_job == 'NIN' and player.satchel[universal_tool_map[spell.english][language]] then
					windower.send_command('get "'..universal_tool_map[spell.english][language]..'" satchel 99')
					windower.chat.input:schedule(1.5,'/ma "'..spell.english..'" '..spell.target.raw..'')
				elseif player.satchel[tool_map[spell.english][language]] then
					windower.send_command('get "'..tool_map[spell.english][language]..'" satchel 99')
					windower.chat.input:schedule(1.5,'/ma "'..spell.english..'" '..spell.target.raw..'')
				elseif player.main_job == 'NIN' and player.inventory[universal_toolbag_map[spell.english][language]] then
					windower.chat.input('/item "'..universal_toolbag_map[spell.english][language]..'" <me>')
					windower.chat.input:schedule(4,'/ma "'..spell.english..'" '..spell.target.raw..'')
				elseif player.main_job == 'NIN' and player.satchel[universal_toolbag_map[spell.english][language]] then
					windower.send_command('get "'..universal_toolbag_map[spell.english][language]..'" satchel 1')
					windower.chat.input:schedule(2,'/item "'..universal_toolbag_map[spell.english][language]..'" <me>')
					windower.chat.input:schedule(6,'/ma "'..spell.english..'" '..spell.target.raw..'')
				elseif player.inventory[toolbag_map[spell.english][language]] then
					windower.chat.input('/item "'..toolbag_map[spell.english][language]..'" <me>')
					windower.chat.input:schedule(4,'/ma "'..spell.english..'" '..spell.target.raw..'')
				elseif player.satchel[toolbag_map[spell.english][language]] then
					windower.send_command('get "'..toolbag_map[spell.english][language]..'" satchel 1')
					windower.chat.input:schedule(2,'/item "'..universal_toolbag_map[spell.english][language]..'" <me>')
					windower.chat.input:schedule(6,'/ma "'..spell.english..'" '..spell.target.raw..'')
				else
					add_to_chat(123,"Abort: You don't have the proper ninja tool available.")
				end
                return false
            end
        -- Filter for spells that you know, but do not currently have access to
        elseif (not spell_jobs[player.main_job_id] or not (spell_jobs[player.main_job_id] <= player.main_job_level or
            (spell_jobs[player.main_job_id] >= 100 and number_of_jps(player.job_points[__raw.lower(res.jobs[player.main_job_id].ens)]) >= spell_jobs[player.main_job_id]) ) ) and
            (not spell_jobs[player.sub_job_id] or not (spell_jobs[player.sub_job_id] <= player.sub_job_level)) then
            add_to_chat(123,"Abort: You don't have access to ["..(res.spells[spell.id][language] or spell.id).."].")
            return false
        -- At this point, we know that it is technically castable by this job combination if the right conditions are met.
        elseif player.main_job_id == 20 and ((addendum_white[spell.id] and not buffactive[401] and not buffactive[416]) or
            (addendum_black[spell.id] and not buffactive[402] and not buffactive[416])) and
            not (spell_jobs[player.sub_job_id] and spell_jobs[player.sub_job_id] <= player.sub_job_level) then
            
            if addendum_white[spell.id] then
				if state.AutoArts.value and not buffactive["Addendum: White"] and not silent_check_amnesia() and get_current_strategem_count() > 0 then
					if buffactive["Light Arts"] then
						windower.chat.input('/ja "Addendum: White" <me>')
						windower.chat.input:schedule(1.5,'/ma "'..spell.english..'" '..spell.target.raw..'')
					else
						local abil_recasts = windower.ffxi.get_ability_recasts()
						if abil_recasts[228] < latency then
							windower.chat.input('/ja "Light Arts" <me>')
							windower.chat.input:schedule(1.5,'/ja "Addendum: White" <me>')
							windower.chat.input:schedule(3.5,'/ma "'..spell.english..'" '..spell.target.raw..'')
						end
					end
				else
					add_to_chat(123,"Abort: Addendum: White required for ["..(res.spells[spell.id][language] or spell.id).."].")
				end
            end
            if addendum_black[spell.id] then
				if state.AutoArts.value and not buffactive["Addendum: Black"] and not silent_check_amnesia() and get_current_strategem_count() > 0 then
					if buffactive["Dark Arts"] then
						windower.chat.input('/ja "Addendum: Black" <me>')
						windower.chat.input:schedule(1.5,'/ma "'..spell.english..'" '..spell.target.raw..'')
					else
						local abil_recasts = windower.ffxi.get_ability_recasts()
						if abil_recasts[232] < latency then
							windower.chat.input('/ja "Dark Arts" <me>')
							windower.chat.input:schedule(1.5,'/ja "Addendum: Black" <me>')
							windower.chat.input:schedule(3.5,'/ma "'..spell.english..'" '..spell.target.raw..'')
						end
					end
				else
					add_to_chat(123,"Abort: Addendum: Black required for ["..(res.spells[spell.id][language] or spell.id).."].")
				end
            end
            return false
        elseif player.sub_job_id == 20 and ((addendum_white[spell.id] and not buffactive[401] and not buffactive[416]) or
            (addendum_black[spell.id] and not buffactive[402] and not buffactive[416])) and
            not (spell_jobs[player.main_job_id] and (spell_jobs[player.main_job_id] <= player.main_job_level or
            (spell_jobs[player.main_job_id] >= 100 and number_of_jps(player.job_points[__raw.lower(res.jobs[player.main_job_id].ens)]) >= spell_jobs[player.main_job_id]) ) ) then
                        
            if addendum_white[spell.id] then
				if state.AutoArts.value and not buffactive["Addendum: White"] and not silent_check_amnesia() and get_current_strategem_count() > 0 then
					if buffactive["Light Arts"] then
						windower.chat.input('/ja "Addendum: White" <me>')
						windower.chat.input:schedule(1.5,'/ma "'..spell.english..'" '..spell.target.raw..'')
					else
						local abil_recasts = windower.ffxi.get_ability_recasts()
						if abil_recasts[228] < latency then
							windower.chat.input('/ja "Light Arts" <me>')
							windower.chat.input:schedule(1.5,'/ja "Addendum: White" <me>')
							windower.chat.input:schedule(3.5,'/ma "'..spell.english..'" '..spell.target.raw..'')
						end
					end
				else
					add_to_chat(123,"Abort: Addendum: White required for ["..(res.spells[spell.id][language] or spell.id).."].")
				end
            end
            if addendum_black[spell.id] then
				if state.AutoArts.value and not buffactive["Addendum: Black"] and not silent_check_amnesia() and get_current_strategem_count() > 0 then
					if buffactive["Dark Arts"] then
						windower.chat.input('/ja "Addendum: Black" <me>')
						windower.chat.input:schedule(1.5,'/ma "'..spell.english..'" '..spell.target.raw..'')
					else
						local abil_recasts = windower.ffxi.get_ability_recasts()
						if abil_recasts[232] < latency then
							windower.chat.input('/ja "Dark Arts" <me>')
							windower.chat.input:schedule(1.5,'/ja "Addendum: Black" <me>')
							windower.chat.input:schedule(3.5,'/ma "'..spell.english..'" '..spell.target.raw..'')
						end
					end
				else
					add_to_chat(123,"Abort: Addendum: Black required for ["..(res.spells[spell.id][language] or spell.id).."].")
				end
            end
            return false
        elseif spell.type == 'BlueMagic' and not ((player.main_job_id == 16 and table.contains(windower.ffxi.get_mjob_data().spells,spell.id)) 
            or unbridled_learning_set[spell.english]) and
            not (player.sub_job_id == 16 and table.contains(windower.ffxi.get_sjob_data().spells,spell.id)) then
            -- This code isn't hurting anything, but it doesn't need to be here either.
            add_to_chat(123,"Abort: You haven't set ["..(res.spells[spell.id][language] or spell.id).."].")
            return false
        end
    elseif category == 7 or category == 9 then
        local available = windower.ffxi.get_abilities()
        if category == 7 and not S(available.weapon_skills)[spell.id] then
            add_to_chat(123,"Abort: You don't have access to ["..(res.weapon_skills[spell.id][language] or spell.id).."].")
            return false
        elseif category == 9 then
			if not S(available.job_abilities)[spell.id] then
				add_to_chat(123,"Abort: You don't have access to ["..(res.job_abilities[spell.id][language] or spell.id).."].")
				return false
			elseif spell.type == 'CorsairShot' and not player.inventory['Trump Card'] then
				if player.inventory['Trump Card Case'] then
					windower.chat.input('/item "Trump Card Case" <me>')
				elseif player.satchel['Trump Card Case'] then
					windower.send_command('get "Trump Card Case" satchel')
					windower.chat.input:schedule(1.5,'/item "Trump Card Case" <me>')
				end
				return false
			end
        end
    elseif category == 25 and (not player.main_job_id == 23 or not windower.ffxi.get_mjob_data().species or
        not res.monstrosity[windower.ffxi.get_mjob_data().species] or not res.monstrosity[windower.ffxi.get_mjob_data().species].tp_moves[spell.id] or
        not (res.monstrosity[windower.ffxi.get_mjob_data().species].tp_moves[spell.id] <= player.main_job_level)) then
        -- Monstrosity filtering
        add_to_chat(123,"Abort: You don't have access to ["..(res.monster_abilities[spell.id][language] or spell.id).."].")
        return false
    end
    
    return true
end

-- buff_set is a set of buffs in a library table (any of S{}, T{} or L{}).
-- This function checks if any of those buffs are present on the player.
function has_any_buff_of(buff_set)
    return buff_set:any(
        -- Returns true if any buff from buff set that is sent to this function returns true:
        function (b) return buffactive[b] end
    )
end


-- Invert a table such that the keys are values and the values are keys.
-- Use this to look up the index value of a given entry.
function invert_table(t)
    if t == nil then error('Attempting to invert table, received nil.', 2) end
    
    local i={}
    for k,v in pairs(t) do 
        i[v] = k
    end
    return i
end


-- Gets sub-tables based on baseSet from the string str that may be in dot form
-- (eg: baseSet=sets, str='precast.FC', this returns the table sets.precast.FC).
function get_expanded_set(baseSet, str)
    local cur = baseSet
    for i in str:gmatch("[^.]+") do
        if cur then
            cur = cur[i]
        end
    end
    
    return cur
end

function copy_entry(tab)
    if not tab then return nil end
    local ret = setmetatable(table.reassign({},tab),getmetatable(tab))
    return ret
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions data and event tracking.
-------------------------------------------------------------------------------------------------------------------

-- This is a function that can be attached to a registered event for 'time change'.
-- It will send a call to the update() function if the time period changes.
-- It will also call job_time_change when any of the specific time class values have changed.
-- To activate this in your job lua, add this line to your user_setup function:
-- windower.register_event('time change', time_change)
--
-- Variables it sets: classes.Daytime, and classes.DuskToDawn.  They are set to true
-- if their respective descriptors are true, or false otherwise.
function time_change(new_time, old_time)
    local was_daytime = classes.Daytime
    local was_dusktime = classes.DuskToDawn
    
    if new_time and (new_time >= 6*60 and new_time < 18*60) then
        classes.Daytime = true
    else
        classes.Daytime = false
    end

    if new_time and (new_time >= 17*60 or new_time < 7*60) then
        classes.DuskToDawn = true
    else
        classes.DuskToDawn = false
    end
    
    if was_daytime ~= classes.Daytime or was_dusktime ~= classes.DuskToDawn then
        if job_time_change then
            job_time_change(new_time, old_time)
        end

        handle_update({'auto'})
    end
end

--Selindrile's Functions

function item_available(item)
	if player.inventory[item] or player.wardrobe[item] or player.wardrobe2[item] or player.wardrobe3[item] or player.wardrobe4[item] then
		return true
	else
		return false
	end
end

function check_disable(spell, spellMap, eventArgs)

	if player.hp == 0 then
		add_to_chat(123,'Abort: You are dead.')
		eventArgs.cancel = true
		return true
	elseif buffactive.terror then
		add_to_chat(123,'Abort: You are terrorized.')
		eventArgs.cancel = true
		return true
	elseif buffactive.petrification then
		add_to_chat(123,'Abort: You are petrified.')
		eventArgs.cancel = true
		return true
	elseif buffactive.sleep or buffactive.Lullaby then
		add_to_chat(123,'Abort: You are asleep.')
		eventArgs.cancel = true
		return true
	elseif buffactive.stun then
		add_to_chat(123,'Abort: You are stunned.')
		eventArgs.cancel = true
		return true
	else
		return false
	end	

end

function silent_check_disable()

	if buffactive.terror or buffactive.petrification or buffactive.sleep or buffactive.Lullaby or buffactive.stun then
		return true
	else
		return false
	end	

end

-- Checks doom, returns true if we're going to cancel and use an or cursna.
function check_doom(spell, spellMap, eventArgs)
	if buffactive.doom and state.AutoRemoveDoomMode.value and not cursna_exceptions:contains(spell.english) then
	
		if (buffactive.mute or buffactive.Omerta or buffactive.silence) or not (silent_can_use(20) and windower.ffxi.get_spell_recasts()[20] < spell_latency) then
			if state.AutoHolyWaterMode.value and not buffactive.muddle then
				if player.inventory['Hallowed Water'] then
					windower.chat.input('/item "Hallowed Water" <me>')
					add_to_chat(123,'Abort: You are doomed, using Hallowed Water instead.')
					eventArgs.cancel = true
					return true
				elseif player.inventory['Holy Water'] or player.satchel['Holy Water'] then
					windower.chat.input('/item "Holy Water" <me>')
					add_to_chat(123,'Abort: You are doomed, using Holy Water instead.')
					eventArgs.cancel = true
					return true
				elseif buffactive.silence then
					if player.inventory['Echo Drops'] or player.satchel['Echo Drops'] then
						windower.chat.input('/item "Echo Drops" <me>')
						eventArgs.cancel = true
						return true
					elseif player.inventory["Remedy"] then
						windower.chat.input('/item "Remedy" <me>')
						eventArgs.cancel = true
						return true
					end
					return false
				end
			end
		elseif silent_can_use(20) then
			windower.chat.input('/ma "Cursna" <me>')
			add_to_chat(123,'Abort: You are doomed, using Cursna instead.')
			eventArgs.cancel = true
			return true
		end
	else
		return false
	end
	return false
end

function check_midaction(spell, spellMap, eventArgs)
	if os.clock() < next_cast then
		if eventArgs then
			eventArgs.cancel = true
			if delayed_cast == '' then
				windower.send_command:schedule((next_cast - os.clock()),'gs c delayedcast')
			end
			delayed_cast = spell.english
			delayed_target = spell.target.id
		end
		return true
	else
		return false
	end
end

function check_amnesia(spell, spellMap, eventArgs)

	if spell.type == 'WeaponSkill' or spell.action_type == 'Ability' then

		if buffactive.amnesia then
			add_to_chat(123,'Abort: You have Amnesia.')
			eventArgs.cancel = true
			return true
		elseif buffactive.impairment then
			add_to_chat(123,'Abort: Your abilities are restricted.')
			eventArgs.cancel = true
			return true
		else
			return false
		end

	else
		return false	
	end
end

function silent_check_amnesia()

	if buffactive.amnesia or buffactive.impairment then
		return true
	else
		return false	
	end
	
end

function check_silence(spell, spellMap, eventArgs)

	if spell.action_type == 'Magic' then

		if buffactive.mute then
			add_to_chat(123,'Abort: You are muted.')
			eventArgs.cancel = true
			return true
		elseif buffactive.Omerta then
			add_to_chat(123,'Abort: Your magic is restricted.')
			eventArgs.cancel = true
			return true
		elseif buffactive.silence then
			if buffactive.paralysis then
				if player.inventory["Remedy"] then
					send_command('input /item "Remedy" <me>')
				elseif player.inventory['Echo Drops'] or player.satchel['Echo Drops'] then
					send_command('input /item "Echo Drops" <me>')
				else
					add_to_chat(123,'Abort: You are silenced.')
				end
			else
				if player.inventory['Echo Drops'] or player.satchel['Echo Drops'] then
					send_command('input /item "Echo Drops" <me>')
				elseif player.inventory["Remedy"] then
					send_command('input /item "Remedy" <me>')
				else
					add_to_chat(123,'Abort: You are silenced.')
				end
			end
			
			eventArgs.cancel = true
			return true
		else
			return false
		end	
	
	else
		return false
	end
end

function silent_check_silence()

	if buffactive.mute or buffactive.Omerta then
		return true

	elseif buffactive.silence then
			if player.inventory['Echo Drops'] or player.satchel['Echo Drops'] then
				windower.chat.input('/item "Echo Drops" <me>')
			elseif player.inventory["Remedy"] then
				windower.chat.input('/item "Remedy" <me>')
			end
			tickdelay = os.clock() + 1.5
			return true
	else
		return false
	end
end

function check_recast(spell, spellMap, eventArgs)
        if spell.action_type == 'Ability' and spell.type ~= 'WeaponSkill' then
			if spell.recast_id == 231 or spell.recast_id == 255 or spell.recast_id == 102 or spell.recast_id == 195 then return false end
            local abil_recasts = windower.ffxi.get_ability_recasts()
			if not abil_recasts[spell.recast_id] then
				add_to_chat(123,"Abort: You don't have access to ["..spell.english.."].")
				eventArgs.cancel = true
				return true
            elseif abil_recasts[spell.recast_id] > latency then
				if spell.english == "Lunge" and abil_recasts[241] < latency then
					eventArgs.cancel = true
					windower.send_command('@input /ja "Swipe" <t>')
					return true
				else
					add_to_chat(123,'Abort: ['..spell.english..'] waiting on recast. ('..seconds_to_clock(abil_recasts[spell.recast_id])..')')
					eventArgs.cancel = true
					return true
				end
			else
				return false
            end
        elseif spell.action_type == 'Magic' then
            local spell_recasts = windower.ffxi.get_spell_recasts()
            if ((spell_recasts[spell.recast_id]/60) > spell_latency) then
				if stepdown(spell, eventArgs) then 
					return true
				else
					add_to_chat(123,'Abort: ['..spell.english..'] waiting on recast. ('..seconds_to_clock(spell_recasts[spell.recast_id]/60)..')')
					eventArgs.cancel = true
					return true
				end
			else
				return false
            end
		else
			return false
        end

end

function check_cost(spell, spellMap, eventArgs)
	local spellCost = actual_cost(spell)
	
	if spell.action_type == 'Magic' and player.mp < spellCost then
		if stepdown(spell, eventArgs) then 
			return true
		else
			add_to_chat(123,'Abort: '..spell.english..' costs more MP. ('..player.mp..'/'..spellCost..')')
			cancel_spell()
			eventArgs.cancel = true
			return true
		end
	elseif spell.type:startswith('BloodPact') and not buffactive['Astral Conduit'] and player.mp < spellCost then
		add_to_chat(123,'Abort: '..spell.english..' costs more MP. ('..player.mp..'/'..spellCost..')')
		cancel_spell()
		eventArgs.cancel = true
		return true
	else
		return false
	end
end

function check_warps(spell, spellMap, eventArgs)
	if spell.target.type == 'SELF' and spell.english:contains('Warp') then
		if world.area == 'Hazhalm Testing Grounds' and player.inventory['Glowing Lamp'] then
			cancel_spell()
			eventArgs.cancel = true
			add_to_chat(123,"Abort: Drop your Glowing Lamp, you don't want to lose your plasm!")
			return true
		end
	end
	return false
end

function check_spell_targets(spell, spellMap, eventArgs)
	if spellMap == 'Cure' or spellMap == 'Curaga' then
		if spell.target.distance > 21 and spell.target.type == 'PLAYER' then
			cancel_spell()
			eventArgs.cancel = true
			add_to_chat(123,'Target out of range, too far to heal!')
		elseif spell.english:startswith('Curaga') and not spell.target.in_party then
			if (buffactive['light arts'] or buffactive['addendum: white']) then
				if get_current_strategem_count() > 0 then
					local number = spell.name:match('Curaga ?%a*'):sub(7) or ''
					eventArgs.cancel = true
					if buffactive['Accession'] then
						windower.chat.input('/ma "Cure'..number..'" '..spell.target.name..'')
					else
						windower.chat.input('/ja "Accession" <me>')
						windower.chat.input:schedule(1,'/ma "Cure'..number..'" '..spell.target.name..'')
					end
				else
					windower.add_to_chat(123,"Error: Not enough Stratagems to convert Curaga to Accesion Cure.")
				end
			else
				windower.add_to_chat(123,"Error: You can't Curaga outside of party.")
			end
			return true
		end
	end

	return false
end

function check_abilities(spell, spellMap, eventArgs)

	if spell.action_type == 'Ability' then
		if spell.english == "Light Arts" and buffactive['Light Arts'] then
			eventArgs.cancel = true
			windower.chat.input('/ja "Addendum: White" <me>')
			return true
		elseif spell.english == "Dark Arts" and buffactive['Dark Arts'] then
			eventArgs.cancel = true
			windower.chat.input('/ja "Addendum: Black" <me>')
			return true
		elseif spell.english == "Penury" and buffactive['Dark Arts'] then
			eventArgs.cancel = true
			windower.chat.input('/ja "Parsimony" <me>')
			return true
		elseif spell.english == "Parsimony" and buffactive['Light Arts'] then
			eventArgs.cancel = true
			windower.chat.input('/ja "Penury" <me>')
			return true
		elseif spell.english == "Celerity" and buffactive['Dark Arts'] then
			eventArgs.cancel = true
			windower.chat.input('/ja "Alacrity" <me>')
			return true
		elseif spell.english == "Alacrity" and buffactive['Light Arts'] then
			eventArgs.cancel = true
			windower.chat.input('/ja "Celerity" <me>')
			return true
		elseif spell.english == "Accession" and buffactive['Dark Arts'] then
			eventArgs.cancel = true
			windower.chat.input('/ja "Manifestation" <me>')
			return true
		elseif spell.english == "Rapture" and buffactive['Dark Arts'] then
			eventArgs.cancel = true
			windower.chat.input('/ja "Ebullience" <me>')
			return true
		elseif spell.english == "Ebullience" and buffactive['Light Arts'] then
			eventArgs.cancel = true
			windower.chat.input('/ja "Rapture" <me>')
			return true
		elseif spell.english == "Manifestation" and buffactive['Light Arts'] then
			eventArgs.cancel = true
			windower.chat.input('/ja "Accession" <me>')
			return true
		elseif spell.english == "Altruism" and buffactive['Dark Arts'] then
			eventArgs.cancel = true
			windower.chat.input('/ja "Focalization" <me>')
			return true
		elseif spell.english == "Focalization" and buffactive['Light Arts'] then
			eventArgs.cancel = true
			windower.chat.input('/ja "Altruism" <me>')
			return true
		elseif spell.english == "Seigan" and buffactive['Seigan'] then
			eventArgs.cancel = true
			windower.chat.input('/ja "Third Eye" <me>')
			return true
		end
	end

	return false
end

function stepdown(spell, eventArgs)
	if spell_stepdown[spell.english] then
		eventArgs.cancel = true
		windower.chat.input('/ma "'..spell_stepdown[spell.english]..'" '..spell.target.raw..'')
		return true
	else
		return false
	end
end

function actual_cost(spell)
    local cost = spell.mp_cost
	if buffactive["Manafont"] or buffactive["Manawell"]
		then return 0
    elseif spell.type=="WhiteMagic" then
        if buffactive["Penury"] then
            return cost*.5
        elseif buffactive["Light Arts"] or buffactive["Addendum: White"] then
            return cost*.9
        elseif buffactive["Dark Arts"] or buffactive["Addendum: Black"] then
            return cost*1.1
        end
    elseif spell.type=="BlackMagic" then
        if buffactive["Parsimony"] then
            return cost*.5
        elseif buffactive["Dark Arts"] or buffactive["Addendum: Black"] then
            return cost*.9
        elseif buffactive["Light Arts"] or buffactive["Addendum: White"] then
            return cost*1.1
        end
    end
    return cost
end

function check_nuke()
	if state.AutoNukeMode.value and player.target.type == "MONSTER" then
		local spell = res.spells:with('name',autonuke)
		local spell_recasts = windower.ffxi.get_spell_recasts()
		if spell_recasts[spell.id] < spell_latency then
			windower.chat.input('/ma '..autonuke..' <t>')
			tickdelay = os.clock() + 1.5
			return true
		else
			return false
		end
	else
		return false
	end
end

function check_samba()
	if not (buffactive['Haste Samba'] or buffactive['Drain Samba'] or buffactive['Aspir Samba']) and windower.ffxi.get_ability_recasts()[216] and windower.ffxi.get_ability_recasts()[216] < latency and state.AutoSambaMode.value ~= 'Off' and player.tp > 400 then
		windower.chat.input('/ja "'..state.AutoSambaMode.value..'" <me>')
		tickdelay = os.clock() + 1.8
		return true
	else
		return false
	end
end

function check_sub()
	if state.AutoSubMode.value and not areas.Cities:contains(world.area) then
		if player.mpp < 70 and player.tp > 999 then
			local available_ws = S(windower.ffxi.get_abilities().weapon_skills)
			
			if available_ws:contains(190) then
				windower.chat.input('/ws Myrkr <me>')
				tickdelay = os.clock() + 1.5
				return true
			elseif available_ws:contains(173) then
				windower.chat.input('/ws Dagan <me>')
				tickdelay = os.clock() + 1.5
				return true
			end
		end
		if (player.main_job == 'SCH' or player.sub_job == 'SCH') and not buffactive['Refresh'] then
			local abil_recasts = windower.ffxi.get_ability_recasts()
			if (not (buffactive['Sublimation: Activated'] or buffactive['Sublimation: Complete'])) and abil_recasts[234] < latency then
				windower.chat.input('/ja Sublimation <me>')
				tickdelay = os.clock() + 1.5
				return true
			elseif buffactive['Sublimation: Complete'] and player.mpp < 70 and abil_recasts[234] < latency then
				windower.chat.input('/ja Sublimation <me>')
				tickdelay = os.clock() + 1.5
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

function check_cleanup()
	if state.AutoCleanupMode.value then
		if player.inventory['Bead Pouch'] then
			send_command('input /item "Bead Pouch" <me>')
			tickdelay = os.clock() + 2.4
			return true
		elseif player.inventory['Silt Pouch'] then
			send_command('input /item "Silt Pouch" <me>')
			tickdelay = os.clock() + 2.4
			return true
		end

		local items = windower.ffxi.get_items()
		local moveditem = false
		if items.count_sack < items.max_sack then
			if player.inventory['Pellucid Stone'] then send_command('put "Pellucid Stone" sack all') moveditem = true end
			if player.inventory['Taupe Stone'] then send_command('put "Taupe Stone" sack all') moveditem = true end
			if player.inventory['Fern Stone'] then send_command('put "Fern Stone" sack all') moveditem = true end
			if player.inventory['Frayed Sack (Pel)'] then send_command('put "Frayed Sack (Pel)" sack all') moveditem = true end
			if player.inventory['Frayed Sack (Tau)'] then send_command('put "Frayed Sack (Tau)" sack all') moveditem = true end
			if player.inventory['Frayed Sack (Fer)'] then send_command('put "Frayed Sack (Fer)" sack all') moveditem = true end
			if player.inventory['Beitetsu'] then send_command('put Beitetsu sack all') moveditem = true end
			if player.inventory['Beitetsu Parcel'] then send_command('put "Beitetsu Parcel" sack all') moveditem = true end
			if player.inventory['Beitetsu Box'] then send_command('put "Beitetsu Box" sack all') moveditem = true end
			if player.inventory['Pluton'] then send_command('put Pluton sack all') moveditem = true end
			if player.inventory['Pluton Case'] then send_command('put "Pluton Case" sack all') moveditem = true end
			if player.inventory['Pluton Box'] then send_command('put "Pluton Box" sack all') moveditem = true end
			if player.inventory['Riftborn Boulder'] then send_command('put "Riftborn Boulder" sack all') moveditem = true end
			if player.inventory['Boulder Case'] then send_command('put "Boulder Case" sack all') moveditem = true end
			if player.inventory['Boulder Box'] then send_command('put "Boulder Box" sack all') moveditem = true end
		end
		
		if not state.Capacity.value then
			if player.inventory['Mecisto. Mantle'] then send_command('put "Mecisto. Mantle" satchel') moveditem = true end
      if player.inventory['Endorsement Ring'] then send_command('put "Endorsement Ring" satchel')  moveditem = true end
			if player.inventory['Trizek Ring'] then send_command('put "Trizek Ring" satchel')  moveditem = true end
			if player.inventory['Capacity Ring'] then send_command('put "Capacity Ring" satchel') moveditem = true end
			if player.inventory['Vocation Ring'] then send_command('put "Vocation Ring" satchel')  moveditem = true end
			if player.inventory['Facility Ring'] then send_command('put "Facility Ring" satchel') moveditem = true end
			if player.inventory['Guide Beret'] then send_command('put "Guide Beret" satchel') moveditem = true end
		end
		
		if moveditem then tickdelay = os.clock() + 2.3 return true end
		
		local shard_name = {'C. Ygg. Shard ','Z. Ygg. Shard ','A. Ygg. Shard ','P. Ygg. Shard '}
		
		for sni, snv in ipairs(shard_name) do
			local shard_count = {'I','II','III','IV','V'}
			for sci, scv in ipairs(shard_count) do
				if player.inventory[snv..''..scv] then
					send_command('wait 3.0;input /item "'..snv..''..scv..'" <me>')
					tickdelay = os.clock() + 2
					return true
				end
			end
		end

		return false
	else
		return false
	end
end

function check_trust()
	if not moving and state.AutoTrustMode.value and not areas.Cities:contains(world.area) and (buffactive['Reive Mark'] or buffactive['Elvorseal'] or not player.in_combat) then
		local party = windower.ffxi.get_party()
		if party.p5 == nil then
			local spell_recasts = windower.ffxi.get_spell_recasts()
		
			if spell_recasts[979] < spell_latency and not have_trust("Selh'teus") then
				windower.chat.input('/ma "Selh\'teus" <me>')
				tickdelay = os.clock() + 4.5
				return true
			elseif spell_recasts[1012] < spell_latency and not have_trust("Nashmeira") then
				windower.chat.input('/ma "Nashmeira II" <me>')
				tickdelay = os.clock() + 4.5
				return true
			elseif spell_recasts[1018] < spell_latency and not have_trust("Iroha") then
				windower.chat.input('/ma "Iroha II" <me>')
				tickdelay = os.clock() + 4.5
				return true
			elseif spell_recasts[1017] < spell_latency and not have_trust("Arciela") then
				windower.chat.input('/ma "Arciela II" <me>')
				tickdelay = os.clock() + 4.5
				return true
			elseif spell_recasts[947] < spell_latency and not have_trust("UkaTotlihn") then
				windower.chat.input('/ma "Uka Totlihn" <me>')
				tickdelay = os.clock() + 4.5
				return true
			elseif spell_recasts[1013] < spell_latency and not have_trust("Lilisette") then
				windower.chat.input('/ma "Lilisette II" <me>')
				tickdelay = os.clock() + 4.5
				return true
			else
				return false
			end
		end
	
	end
	return false
end

function check_auto_tank_ws()
	if state.AutoWSMode.value and state.AutoTankMode.value and player.target.type == "MONSTER" and not moving and player.status == 'Engaged' and not silent_check_amnesia() then
		if player.tp > 999 and relic_weapons:contains(player.equipment.main) and state.MaintainAftermath.value and (not buffactive['Aftermath']) then
			windower.chat.input('/ws "'..data.weaponskills.relic[player.equipment.main]..'" <t>')
			tickdelay = os.clock() + 2
			return true
		elseif player.tp > 999 and (buffactive['Aftermath: Lv.3'] or not state.MaintainAftermath.value or not mythic_weapons:contains(player.equipment.main)) then
			windower.chat.input('/ws "'..autows..'" <t>')
			tickdelay = os.clock() + 2
			return true
		elseif player.tp == 3000 then
			windower.chat.input('/ws "'..data.weaponskills.mythic[player.equipment.main]..'" <t>')
			tickdelay = os.clock() + 2
			return true
		else
			return false
		end
	end
end

function check_use_item()
	if useItem then
		local CurrentTime = (os.time(os.date('!*t')) + time_offset)
		if useItemSlot == 'item' and (player.inventory[useItemName] or player.temporary[useItemName]) then
			windower.chat.input('/item "'..useItemName..'" <me>')
			tickdelay = os.clock() + 3.5
			return true
		elseif useItemSlot == 'set' then
			if item_equipped(set_to_item(useItemName)) and get_item_next_use(set_to_item(useItemName)).usable then
				windower.chat.input('/item "'..set_to_item(useItemName)..'" <me>')
				tickdelay = os.clock() + 3
				return true
			elseif item_available(set_to_item(useItemName)) and ((get_item_next_use(set_to_item(useItemName)).next_use_time) - CurrentTime) < 10 then
				windower.send_command('gs c forceequip '..useItemSlot..' '..useItemName..'')
				tickdelay = os.clock() + 2
				return true
			elseif player.satchel[set_to_item(useItemName)] then
				windower.send_command('get "'..set_to_item(useItemName)..'" satchel')
				tickdelay = os.clock() + 2
				return true
			else
				add_to_chat(123,''..set_to_item(useItemName)..' not available or ready for use.')
				useItem = false
				return false
			end
		elseif item_equipped(useItemName) and get_item_next_use(useItemName).usable then
			windower.chat.input('/item "'..useItemName..'" <me>')
			tickdelay = os.clock() + 3
			return true
		elseif item_available(useItemName) and ((get_item_next_use(useItemName).next_use_time) - CurrentTime) < 10 then
			windower.send_command('gs c forceequip '..useItemSlot..' '..useItemName..'')
			tickdelay = os.clock() + 2
			return true
		elseif player.satchel[useItemName] then
			windower.send_command('get '..useItemName..'')
			tickdelay = os.clock() + 2
			return true
		else
			add_to_chat(123,''..useItemName..' not available or ready for use.')
			useItem = false
			return false
		end
	else
		return false
	end
	return false
end

function check_food()
	if state.AutoFoodMode.value and not buffactive['Food'] and not areas.Cities:contains(world.area) then
	
		if player.inventory[''..autofood..''] then
			windower.chat.input('/item "'..autofood..'" <me>')
			tickdelay = os.clock() + 1.5
			return true
		elseif player.satchel[''..autofood..''] then
			windower.send_command('get "'..autofood..'" satchel')
			tickdelay = os.clock() + 1.5
			return true
		else
			return false
		end
	
	else
		return false
	end
end

function check_doomed()
	if buffactive.doom and state.AutoRemoveDoomMode.value then 
	
		if (buffactive.mute or buffactive.Omerta or buffactive.silence) or not (silent_can_use(20) and windower.ffxi.get_spell_recasts()[20] < spell_latency) then
			if state.AutoHolyWaterMode.value and not buffactive.muddle then
				if player.inventory['Hallowed Water'] then
					windower.chat.input('/item "Hallowed Water" <me>')
					add_to_chat(123,'You are doomed, using Hallowed Water.')
					tickdelay = os.clock() + 1.5
					return true
				elseif player.inventory['Holy Water'] or player.satchel['Holy Water'] then
					windower.chat.input('/item "Holy Water" <me>')
					add_to_chat(123,'You are doomed, using Holy Water.')
					tickdelay = os.clock() + 1.5
					return true
				elseif buffactive.silence then
						if player.inventory['Echo Drops'] or player.satchel['Echo Drops'] then
							windower.chat.input('/item "Echo Drops" <me>')
						elseif player.inventory["Remedy"] then
							windower.chat.input('/item "Remedy" <me>')
						end
						tickdelay = os.clock() + 1.5
						return true
				end
			end
		else
			windower.chat.input('/ma "Cursna" <me>')
			tickdelay = os.clock() + 1.5
			return true
		end
	else
		return false
	end
	return false
end

function check_ws()
	if state.AutoWSMode.value and not state.RngHelper.value and player.status == 'Engaged' and player.target.type == "MONSTER" and player.tp > 999 and not silent_check_amnesia() and player.target and not (player.target.distance > (19.7 + player.target.model_size)) then

	local available_ws = S(windower.ffxi.get_abilities().weapon_skills)
		
		if player.hpp < 41 and available_ws:contains(47) and player.target.distance < (3.2 + player.target.model_size) then
			windower.chat.input('/ws "Sanguine Blade" <t>')
			tickdelay = os.clock() + 2.8
			return true
		elseif player.hpp < 41 and available_ws:contains(105) and player.target.distance < (3.2 + player.target.model_size) then
			windower.chat.input('/ws "Catastrophe" <t>')
			tickdelay = os.clock() + 2.8
			return true
		elseif player.mpp < 21 and available_ws:contains(109) and player.target.distance < (3.2 + player.target.model_size) then
			windower.chat.input('/ws "Entropy" <t>')
			tickdelay = os.clock() + 2.8
			return true
		elseif player.mpp < 21 and available_ws:contains(171) and player.target.distance < (3.2 + player.target.model_size) then
			windower.chat.input('/ws "Mystic Boon" <t>')
			tickdelay = os.clock() + 2.8
			return true
		elseif player.target.distance > (3.2 + player.target.model_size) and not ranged_weaponskills:contains(autows) then
			return false
		elseif player.tp > 999 and relic_weapons:contains(player.equipment.main) and state.MaintainAftermath.value and (not buffactive['Aftermath']) then
			windower.chat.input('/ws "'..data.weaponskills.relic[player.equipment.main]..'" <t>')
			tickdelay = os.clock() + 2.8
			return true
		elseif (buffactive['Aftermath: Lv.3'] or not state.MaintainAftermath.value or not mythic_weapons:contains(player.equipment.main)) and player.tp >= autowstp then
			windower.chat.input('/ws "'..autows..'" <t>')
			tickdelay = os.clock() + 2.8
			return true
		elseif player.tp == 3000 then
			windower.chat.input('/ws "'..data.weaponskills.mythic[player.equipment.main]..'" <t>')
			tickdelay = os.clock() + 2.8
			return true
		else
			return false
		end
	else
		return false
	end
end

function have_trust(trustname)
	local party = windower.ffxi.get_party()

	for i = 1,5 do
		local member = party['p' .. i]
		if member then
			if member.name:lower() == trustname:lower() then return true end
		end
		
	end

	return false
end

function is_party_member(playerid)
	local party = windower.ffxi.get_party()

	for i = 1,5 do
		local member = party['p' .. i]
		if member.mob.id then
			if member.mob.id == playerid then return true end
		end
		
	end

	return false
end

function get_item_next_use(name)--returns time that you can use the item again
    for _,n in pairs({"inventory","wardrobe","wardrobe2","wardrobe3","wardrobe4"}) do
        for _,v in pairs(gearswap.items[n]) do
            if type(v) == "table" and v.id ~= 0 and res.items[v.id].english:lower() == name:lower() then
                return extdata.decode(v)
            end
        end
    end
end

function cp_ring_equip(ring)--equips given ring
	enable("left_ring")
    gearswap.equip_sets('equip_command',nil,{left_ring=ring})
    disable("left_ring")
end

function check_cpring()
--	local CurrentTime = (os.time(os.date("!*t", os.time())) + time_offset)
	local CurrentTime = (os.time(os.date('!*t')) + time_offset)
	
	if player.main_job_level < 99 then
			if player.equipment.head and player.equipment.head == 'Sprout Beret' and get_item_next_use(player.equipment.head).usable then
				send_command('input /item "'..player.equipment.head..'" <me>')
				cp_delay = 0
				return true
			   
			elseif item_available('Sprout Beret') and ((get_item_next_use('Sprout Beret').next_use_time) - CurrentTime) < 15 and (get_item_next_use('Sprout Beret').charges_remaining > 0) then
				enable("head")
				gearswap.equip_sets('equip_command',nil,{head="Sprout Beret"})
				disable("head")
				cp_delay = 10
				return true
			   
			elseif player.equipment.left_ring == 'Echad Ring' and get_item_next_use('Echad Ring').usable then
				send_command('input /item "'..player.equipment.left_ring..'" <me>')
				cp_delay = 0
				return true
			elseif item_available('Echad Ring') and ((get_item_next_use('Echad Ring').next_use_time) - CurrentTime) < 15 then
				cp_ring_equip('Echad Ring')
				cp_delay = 10
				return true
			   
			elseif player.equipment.left_ring == 'Caliber Ring' and get_item_next_use('Caliber Ring').usable then
				send_command('input /item "'..player.equipment.left_ring..'" <me>')
				cp_delay = 0
				return true
			elseif item_available('Caliber Ring') and ((get_item_next_use('Caliber Ring').next_use_time) - CurrentTime) < 15 then
				cp_ring_equip('Caliber Ring')
				cp_delay = 10
				return true
			   
			elseif player.equipment.left_ring == 'Emperor Band' and get_item_next_use('Emperor Band').usable then
				send_command('input /item "'..player.equipment.left_ring..'" <me>')
				cp_delay = 0
				return true
			elseif item_available('Emperor Band') and ((get_item_next_use('Emperor Band').next_use_time) - CurrentTime) < 15 then
				cp_ring_equip('Emperor Band')
				cp_delay = 10
				return true
				
			elseif player.equipment.left_ring == 'Empress Band' and get_item_next_use('Empress Band').usable then
				send_command('input /item "'..player.equipment.left_ring..'" <me>')
				cp_delay = 0
				return true
			elseif item_available('Empress Band') and ((get_item_next_use('Empress Band').next_use_time) - CurrentTime) < 15 then
				cp_ring_equip('Empress Band')
				cp_delay = 10
				return true
				
			elseif player.equipment.left_ring == 'Resolution Ring' and get_item_next_use('Resolution Ring').usable then
				send_command('input /item "'..player.equipment.left_ring..'" <me>')
				cp_delay = 0
				return true
			elseif item_available('Resolution Ring') and ((get_item_next_use('Resolution Ring').next_use_time) - CurrentTime) < 15 then
				cp_ring_equip('Resolution Ring')
				cp_delay = 10
				return true
	 
			else
				cp_delay = 0
				return false
			end
		
	elseif cprings:contains(player.equipment.left_ring) and get_item_next_use(player.equipment.left_ring).usable then
		send_command('input /item "'..player.equipment.left_ring..'" <me>')
		cp_delay = 0
		return true
	
	elseif player.equipment.head and player.equipment.head == 'Guide Beret' and get_item_next_use(player.equipment.head).usable then
		send_command('input /item "'..player.equipment.head..'" <me>')
		cp_delay = 0
		return true
		
	elseif item_available('Guide Beret') and ((get_item_next_use('Guide Beret').next_use_time) - CurrentTime) < 15 and (get_item_next_use('Guide Beret').charges_remaining > 0) then
		enable("head")
		gearswap.equip_sets('equip_command',nil,{head="Guide Beret"})
		disable("head")
		cp_delay = 10
		return true
  
  elseif item_available('Endorsement Ring') and ((get_item_next_use('Endorsement Ring').next_use_time) - CurrentTime) < 15 then
		cp_ring_equip('Endorsement Ring')
		cp_delay = 10
		return true
		
	elseif item_available('Trizek Ring') and ((get_item_next_use('Trizek Ring').next_use_time) - CurrentTime) < 15 then
		cp_ring_equip('Trizek Ring')
		cp_delay = 10
		return true
		
	elseif item_available('Capacity Ring') and ((get_item_next_use('Capacity Ring').next_use_time) - CurrentTime) < 15 and (get_item_next_use('Capacity Ring').charges_remaining > 0) then
		cp_ring_equip('Capacity Ring')
		cp_delay = 10
		return true
			
	elseif item_available('Vocation Ring') and ((get_item_next_use('Vocation Ring').next_use_time) - CurrentTime) < 15 and (get_item_next_use('Vocation Ring').charges_remaining > 0) then
		cp_ring_equip('Vocation Ring')
		cp_delay = 10
		return true
	
	elseif item_available('Facility Ring') and ((get_item_next_use('Facility Ring').next_use_time) - CurrentTime) < 15 and (get_item_next_use('Facility Ring').charges_remaining > 0) then
		cp_ring_equip('Facility Ring')
		cp_delay = 10
		return true
	
	elseif player.equipment.head and player.equipment.head == 'Guide Beret' and (((get_item_next_use(player.equipment.head).next_use_time) - CurrentTime) > 15 or (get_item_next_use(player.equipment.head).charges_remaining == 0)) then
		enable("head")
		handle_equipping_gear(player.status)
		cp_delay = 19
		return true
		
	elseif cprings:contains(player.equipment.left_ring) and (((get_item_next_use(player.equipment.left_ring).next_use_time) - CurrentTime) > 15 or (get_item_next_use(player.equipment.left_ring).charges_remaining == 0)) then
		enable("left_ring")
		handle_equipping_gear(player.status)
		cp_delay = 19
		return true
	
	end
	
	cp_delay = 0
	return false
end

function check_cpring_buff()-- returs true if you do not have the buff from xp cp ring
	cp_delay = cp_delay + 1
	
	if time_test then
		local CurrentTime = (os.time(os.date("!*t", os.time())) + time_offset)
		windower.add_to_chat(123,"Capacity Ring Next Use: "..(get_item_next_use('Capacity Ring').next_use_time - CurrentTime).."")
	end
	
	if state.Capacity.value and cp_delay > 20 and not moving and not areas.Cities:contains(world.area) then
	
		if player.satchel['Mecisto. Mantle'] then send_command('get "Mecisto. Mantle" satchel;wait 2;gs c update') end
    if player.satchel['Endorsement Ring'] then send_command('get "Endorsement Ring" satchel') end
		if player.satchel['Trizek Ring'] then send_command('get "Trizek Ring" satchel') end
		if player.satchel['Capacity Ring'] then send_command('get "Capacity Ring" satchel') end
		if player.satchel['Vocation Ring'] then send_command('get "Vocation Ring" satchel') end
		if player.satchel['Facility Ring'] then send_command('get "Facility Ring" satchel') end
		if player.satchel['Guide Beret'] then send_command('get "Guide Beret" satchel') end
		if player.satchel['Echad Ring'] and player.main_job_level < 99 then send_command('get "Echad Ring" satchel') end
	
		if buffactive['Commitment'] then
			return false
		elseif buffactive['Dedication'] == 2 then
			return false
		elseif not buffactive['Dedication'] then
			if check_cpring() then
				return true
			else
				return false
			end
		elseif buffactive['Dedication'] == 1 then
			if have_trust("Kupofried") then
				if check_cpring() then
					return true
				else
					return false
				end
			else
				return false
			end
		end
	else
		return false
	end
	return false	
end

function is_defensive()
	if state.DefenseMode.value ~= 'None' or state.HybridMode.value:contains('DT') or state.HybridMode.value:contains('Tank') then
		return true
	else
		return false
	end
end

function has_shadows()
	if  buffactive["Copy Image (4+)"] then
		return 4
	elseif buffactive["Copy Image (3)"] then
		return 3
	elseif buffactive["Copy Image (2)"] then
		return 2
	elseif buffactive.Blink or buffactive["Copy Image"] then
		return 1
	else
		return 0
	end
end

function is_nuke(spell, spellMap)
	if (
		(spell.skill == 'Elemental Magic' and spellMap ~= 'ElementalEnfeeble') or
	    (player.main_job == 'BLU' and spell.skill == 'Blue Magic' and spellMap:contains('Magical')) or
		(player.main_job == 'NIN' and spell.skill == 'Ninjutsu' and spellMap:contains('ElementalNinjutsu')) or
		spell.english == 'Comet' or spell.english == 'Meteor' or spell.english == 'Impact' or spell.english == 'Death' or
		spell.english:startswith('Banish')
		) then
		
		return true
	else
		return false
	end
end

function ammo_left()

	local InventoryAmmo = ((player.inventory[player.equipment.ammo] or {}).count or 0)
	local WardrobeAmmo = ((player.wardrobe[player.equipment.ammo] or {}).count or 0)
	local Wardrobe2Ammo = ((player.wardrobe2[player.equipment.ammo] or {}).count or 0)
	local Wardrobe3Ammo = ((player.wardrobe3[player.equipment.ammo] or {}).count or 0)
	local Wardrobe4Ammo = ((player.wardrobe4[player.equipment.ammo] or {}).count or 0)
		
	local AmmoLeft = InventoryAmmo + WardrobeAmmo + Wardrobe2Ammo + Wardrobe3Ammo + Wardrobe4Ammo 
		
	return AmmoLeft	
end

 --Equip command but accepts the set name as a string to work around inability to use equip() in raw events.
function do_equip(setname)
	send_command('gs equip '..setname..'')
end

function seconds_to_clock(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%01.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end

function parse_set_to_keys(str)
    if type(str) == 'table' then
        str = table.concat(str, ' ')
    end
    
    -- Parsing results get pushed into the result list.
    local result = L{}

    local remainder = str
    local key
    local stop
    local sep = '.'
    local count = 0
    
    -- Loop as long as remainder hasn't been nil'd or reduced to 0 characters, but only to a maximum of 30 tries.
    while remainder and #remainder and count < 30 do
        -- Try aaa.bbb set names first
        while sep == '.' do
            _,_,key,sep,remainder = remainder:find("^([^%.%[]*)(%.?%[?)(.*)")
            -- "key" is everything that is not . or [ 0 or more times.
            -- "sep" is the next divider, which is necessarily . or [
            -- "remainder" is everything after that
            result:append(key)
        end
        
        -- Then try aaa['bbb'] set names.
        -- Be sure to account for both single and double quote enclosures.
        -- Ignore periods contained within quote strings.
        while sep == '[' do 
            _,_,sep,remainder = remainder:find([=[^(%'?%"?)(.*)]=]) --' --block bad text highlighting
            -- "sep" is the first ' or " found (or nil)
            -- remainder is everything after that (or nil)
            if sep == "'" then
                _,_,key,stop,sep,remainder = remainder:find("^([^']+)('])(%.?%[?)(.*)")
            elseif sep == '"' then
                _,_,key,stop,sep,remainder = remainder:find('^([^"]+)("])(%.?%[?)(.*)')
            elseif not sep or #sep == 0 then
                -- If there is no single or double quote detected, attempt to treat the index as a number or boolean
                local _,_,pot_key,pot_stop,pot_sep,pot_remainder = remainder:find('^([^%]]+)(])(%.?%[?)(.*)')
                if tonumber(pot_key) then
                    key,stop,sep,remainder = tonumber(pot_key),pot_stop,pot_sep,pot_remainder
                elseif pot_key == 'true' then
                    key,stop,sep,remainder = true,pot_stop,pot_sep,pot_remainder
                elseif pot_key == 'false' then
                    key,stop,sep,remainder = false,pot_stop,pot_sep,pot_remainder
                end
            end
            result:append(key)
        end
        
        count = count +1
    end

    return result
end

function get_set_from_keys(keys)
    local set = keys[1] == 'sets' and _G or sets
    for key in (keys.it or it)(keys) do
        if key == nil then
            return nil
        end
        set = set[key]
        if not set then
            return nil
        end
    end

    return set
end

function face_target()
	local target = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().target_index or 0)
	local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
	if target then  -- Please note if you target yourself you will face Due East
		local angle = (math.atan2((target.y - self_vector.y), (target.x - self_vector.x))*180/math.pi)*-1
		windower.ffxi.turn((angle):radian())
	else
		windower.add_to_chat(123,"Error: You're not targeting anything to face")
	end
end

function check_ammo()

	if state.AutoAmmoMode.value and player.equipment.range and not player.in_combat and not world.in_mog_house and not useItem then
		local ammo_to_stock
		if type(ammostock) == 'table' and ammostock[rema_ranged_weapons_ammo[player.equipment.range]] then
			ammo_to_stock = ammostock[rema_ranged_weapons_ammo[player.equipment.range]]
		else
			ammo_to_stock = ammostock
		end
	
		if rema_ranged_weapons:contains(player.equipment.range) and count_total_ammo(rema_ranged_weapons_ammo[player.equipment.range]) < ammo_to_stock then
			if get_item_next_use(player.equipment.range).usable then
				windower.chat.input("/item '"..player.equipment.range.."' <me>")
				add_to_chat(217,"You're low on "..rema_ranged_weapons_ammo[player.equipment.range]..", using "..player.equipment.range..".")
				tickdelay = os.clock() + 2
				return true
			elseif item_available(rema_ranged_weapons_ammo_pouch[player.equipment.range]) then
				local CurrentTime = (os.time(os.date('!*t')) + time_offset)
				if ((get_item_next_use(rema_ranged_weapons_ammo_pouch[player.equipment.range]).next_use_time) - CurrentTime) < 10 then
					add_to_chat(217,"You're low on "..rema_ranged_weapons_ammo[player.equipment.range]..", using "..rema_ranged_weapons_ammo_pouch[player.equipment.range]..".")
					useItem = true
					useItemName = rema_ranged_weapons_ammo_pouch[player.equipment.range]
					useItemSlot = 'waist'
					return true
				end				
			end
		end
	end
	return false
end

function count_available_ammo(ammo_name)
	local ammo_count = 0
	
    for _,n in pairs({"inventory","wardrobe","wardrobe2","wardrobe3","wardrobe4",}) do
		if player[n][ammo_name] then
			ammo_count = ammo_count + player[n][ammo_name].count
		end
    end

	return ammo_count
end

function count_total_ammo(ammo_name)
	local ammo_count = 0
	
    for _,n in pairs({"inventory","wardrobe","wardrobe2","wardrobe3","wardrobe4","satchel","sack","case"}) do
		if player[n][ammo_name] then
			ammo_count = ammo_count + player[n][ammo_name].count
		end
    end

	return ammo_count
end

function check_shadows()
	if not state.AutoShadowMode.value or moving or areas.Cities:contains(world.area) then 
		return false
	elseif handle_shadows() then
		return true
	else
		return false
	end
end

function check_rune()

	if state.AutoRuneMode.value and (player.main_job == 'RUN' or player.sub_job == 'RUN') then
		local abil_recasts = windower.ffxi.get_ability_recasts()

		if player.main_job == 'RUN' and (not buffactive[state.RuneElement.value] or buffactive[state.RuneElement.value] < 3) then
			if abil_recasts[92] > 0 then return false end		
			send_command('input /ja "'..state.RuneElement.value..'" <me>')
			tickdelay = os.clock() + 1.8
			return true

		elseif not buffactive[state.RuneElement.value] or buffactive[state.RuneElement.value] < 2 then
			if abil_recasts[92] > 0 then return false end		
			send_command('input /ja "'..state.RuneElement.value..'" <me>')
			tickdelay = os.clock() + 1.8
			return true
			
		elseif not player.in_combat then
			return false
			
		elseif not buffactive['Pflug'] then
			if abil_recasts[59] < latency then
				send_command('input /ja "Pflug" <me>')
				tickdelay = os.clock() + 1.8
				return true
			end
			
		elseif not (buffactive['Vallation'] or buffactive['Valiance']) then
			if player.main_job == 'RUN' and abil_recasts[113] < latency then
				send_command('input /ja "Valiance" <me>')
				tickdelay = os.clock() + 2.5
				return true
			elseif abil_recasts[23] < latency then
				send_command('input /ja "Vallation" <me>')
				tickdelay = os.clock() + 2.5
				return true
			else
				return false
			end
		else
			return false
		end
	
	end
	
	return false
end

function check_ws_acc()
	if state.WeaponskillMode.value == 'Match' then
		return state.OffenseMode.value
	else
		return state.WeaponskillMode.value
	end
end

function can_dual_wield()
	if (dualWieldJobs:contains(player.main_job) or (player.sub_job == 'DNC' or player.sub_job == 'NIN')) then
		return true
	else
		return false
	end
end

function is_dual_wielding()
	if ((player.equipment.main and not (player.equipment.sub == 'empty' or player.equipment.sub:contains('Grip') or player.equipment.sub:contains('Strap') or res.items[item_name_to_id(player.equipment.sub)].shield_size))) then
		return true
	else
		return false
	end
end

function is_fencing()
	if main_weapon_is_one_handed() and (player.equipment.sub == 'empty' or res.items[item_name_to_id(player.equipment.sub)].shield_size) then
		return true
	else
		return false
	end
end

function main_weapon_is_one_handed()
	if player.equipment.main == nil then return false end
	return S{2,3,5,9,11}:contains(res.items[item_name_to_id(player.equipment.main)].skill) or false
end

-- Generic combat form handling
function update_combat_form()
	if sets.engaged[state.Weapons.value] then
		state.CombatForm:set(state.Weapons.value)
	elseif not player.equipment.main then
		if sets.engaged.Unarmed then
			state.CombatForm:set('Unarmed')
		else
			state.CombatForm:reset()
		end
	elseif sets.engaged.DW and ((state.Weapons.value:contains('DW') or state.Weapons.value:contains('Dual')) or (state.Weapons.value == 'None' and can_dual_wield()) or is_dual_wielding()) then
		state.CombatForm:set('DW')
	elseif sets.engaged[player.equipment.main] then
		state.CombatForm:set(player.equipment.main)
	elseif sets.engaged.Fencer and (player.equipment.sub == 'empty' or player.equipment.sub:contains('Grip') or player.equipment.sub:contains('Strap') or res.items[item_name_to_id(player.equipment.sub)].shield_size) then
		state.CombatForm:set('Fencer')
	else
		state.CombatForm:reset()
	end
end

function item_name_to_id(name)
    return (player.inventory[name] or player.wardrobe[name] or player.wardrobe2[name] or player.wardrobe3[name] or player.wardrobe4[name] or {}).id
end

function set_to_item(set)
	for k, v in pairs(sets[set]) do
		if v ~= empty then
			return v
		end
	end
	return false
end

function item_equipped(item)
	for k, v in pairs(player.equipment) do
		if v == item then
			return true
		end
	end
	return false
end

function get_current_strategem_count()
    -- returns recast in seconds.
    local allRecasts = windower.ffxi.get_ability_recasts()
    local stratsRecast = allRecasts[231]
	local StratagemChargeTimer = 240
	local maxStrategems = 1
	
	if player.sub_job == 'SCH' and player.sub_job_level > 29 then
		StratagemChargeTimer = 120
	elseif player.main_job_level > 89 then
		if player.job_points[(res.jobs[player.main_job_id].ens):lower()].jp_spent > 549 then
			StratagemChargeTimer = 33
		else
			StratagemChargeTimer = 48
		end
	elseif player.main_job_level > 69 then
		StratagemChargeTimer = 60
	elseif player.main_job_level > 49 then
		StratagemChargeTimer = 80
	elseif player.main_job_level > 29 then
		StratagemChargeTimer = 120
	end
	
	if player.sub_job == 'SCH' then
		if player.sub_job_level > 29 then
			maxStrategems = 2
		end
	else
		maxStrategems = math.floor((player.main_job_level + 10) / 20)
	end


    local currentCharges = math.floor(maxStrategems - (stratsRecast / StratagemChargeTimer))
    return currentCharges
end

function arts_active()
	if buffactive['Light Arts'] or buffactive['Addendum: White'] or buffactive['Dark Arts'] or buffactive['Addendum: Black'] then
		return true
	else
		return false
	end
end

-- Movement Handling
lastlocation = 'fff':pack(0,0,0)
moving = false
wasmoving = false

windower.raw_register_event('outgoing chunk',function(id,data,modified,is_injected,is_blocked)
    if id == 0x015 then
        moving = lastlocation ~= modified:sub(5, 16)
        lastlocation = modified:sub(5, 16)
		
		if wasmoving ~= moving then
			if moving and buffup~= '' then
				buffup = ''
				add_to_chat(123,'Buffup cancelled due to movement.')
			end
			if not (midaction() or pet_midaction()) then
				send_command('gs c forceequip')
			end
		end
		
		if moving then
			if state.RngHelper.value then
				send_command('gs rh clear')
			end
			
			if not state.Uninterruptible.value then delayed_cast = '' end
		end
		
		wasmoving = moving
    end
end)
		
-- Uninterruptible Handling

state.Uninterruptible = M(false, 'Uninterruptible')
fixed_pos = ''

windower.raw_register_event('outgoing chunk',function(id,original,modified,injected,blocked)
	if not blocked and id == 0x15 and state.Uninterruptible.value then
		if player.status ~= 'Event' and (gearswap.cued_packet or midaction()) and fixed_pos ~= '' then
			return original:sub(1,4)..fixed_pos..original:sub(17)
		else
			fixed_pos = original:sub(5,16)
		end
	end
end)

--TP Bonus Handling
function get_effective_player_tp(spell, WSset)
	local effective_tp = player.tp
	if is_fencing() then effective_tp = effective_tp + get_fencer_tp_bonus(WSset) end
	if buffactive['Crystal Blessing'] then effective_tp = effective_tp + 250 end
	if magian_tp_bonus_melee_weapons:contains(player.equipment.sub) then effective_tp = effective_tp + 1000 end
	if magian_tp_bonus_ranged_weapons:contains(player.equipment.range) then effective_tp = effective_tp + 1000 end
	if state.Buff['Warcry'] and player.main_job == "WAR" and lastwarcry == player.name then effective_tp = effective_tp + warcry_tp_bonus end
	if WSset.ear1 == "Moonshade Earring" or WSset.ear2 == "Moonshade Earring" then effective_tp = effective_tp + 250 end
	
	if S{25,26}:contains(spell.skill) then
		if aeonic_weapons:contains(player.equipment.range) then effective_tp = effective_tp + 500 end
	else
		if aeonic_weapons:contains(player.equipment.main) then effective_tp = effective_tp + 500 end
	end

	return effective_tp
end

function standardize_set(set)
	local standardized_set = {}
	
    for slot, inner in pairs(set) do
		if slot_names:contains(slot) then
			if type(inner) == 'table' then
				standardized_set[slot] = inner.name
			else
				standardized_set[slot] = inner
			end
		end
    end

	standardized_set.ear1 = standardized_set.ear1 or standardized_set.left_ear or standardized_set.lear or nil
	standardized_set.ear2 = standardized_set.ear2 or standardized_set.right_ear or standardized_set.rear or nil
	standardized_set.ring1 = standardized_set.ring1 or standardized_set.left_ring or standardized_set.rring or nil
	standardized_set.ring2 = standardized_set.ring2 or standardized_set.right_ring or standardized_set.lring or nil
	standardized_set.range = standardized_set.range or standardized_set.ranged or nil
	
	return standardized_set
end

function get_fencer_tp_bonus(WSset)
	local fencer_tp_bonus = 0
	local fencer_tier_bonuses = {[0]=0,[1]=200,[2]=300,[3]=400,[4]=450,[5]=500,[6]=550,[7]=600,[8]=660,[9]=730}
	local fencer_tp_bonus = fencer_tier_bonuses[base_fencer_tier] + jp_fencer_tp_bonus
	
	if WSset.legs then
		if WSset.legs == 'Boii Cuisses' then fencer_tp_bonus = fencer_tp_bonus + 50 
		elseif WSset.legs and WSset.legs == 'Boii Cuisses +1' then fencer_tp_bonus = fencer_tp_bonus + 100
		end
	end
	if WSset.neck then
		if WSset.neck:contains('War. Beads') or WSset.neck:contains("Warrior's Beads") then
			fencer_tp_bonus = fencer_tp_bonus + 50
		end
	end
	
	if player.equipment.sub and player.equipment.sub == 'Blurred Shield +1' then fencer_tp_bonus = fencer_tp_bonus + 50 end
	
	return fencer_tp_bonus
end

function get_fencer_gifts()
	local war_fencer_gift_tiers = {[80]=50,[405]=50,[980]=60,[1805]=70}
	local bst_fencer_gift_tiers = {[150]=50,[500]=50,[1125]=60,[2000]=70}
	local jp_spent_on_war = windower.ffxi.get_player().job_points[string.lower(player.main_job)].jp_spent
	local tp_bonus_from_jp = 0
	
	if player.main_job == "WAR" then
		for tier_threshold,tp_bonus in ipairs(war_fencer_gift_tiers) do
			if jp_spent_on_war >= tier_threshold then
				tp_bonus_from_jp = tp_bonus_from_jp + tp_bonus
			end
		end
	elseif player.main_job == "BST" then
		for tier_threshold,tp_bonus in ipairs(bst_fencer_gift_tiers) do
			if jp_spent_on_war >= tier_threshold then
				tp_bonus_from_jp = tp_bonus_from_jp + tp_bonus
			end
		end
	end
	
	return tp_bonus_from_jp
end

function get_base_fencer_tier()
	local fencer_jobs_level_thresholds = {['BRD'] = {85,95},['BST'] = {80,87,94},['WAR'] = {45,58,71,84,97}}
	local fencer_tier_level = 0

	if fencer_jobs_level_thresholds[player.main_job] ~= nil then
		for _,level_threshold in ipairs(fencer_jobs_level_thresholds[player.main_job]) do
			if player.main_job_level >= level_threshold then
				fencer_tier_level = fencer_tier_level + 1
			end
		end

	elseif player.sub_job == 'WAR' and player.sub_job_level >= 45 then
		fencer_tier_level = 1
	end

	return fencer_tier_level
end

base_fencer_tier = get_base_fencer_tier()
jp_fencer_tp_bonus = get_fencer_gifts()

function get_warcry_tp_bonus()
	local tp_bonus = 0
	
	if player.main_job == 'WAR' then
		local savagery_merits = windower.ffxi.get_player().merits.savagery and windower.ffxi.get_player().merits.savagery or 0
		tp_bonus = tp_bonus + (100 * savagery_merits)
			
		local relic_bonus_per_merit = 40
		if sets.precast.JA.Warcry and sets.precast.JA.Warcry.head and sets.precast.JA.Warcry.head:contains('Agoge Mask') then
			tp_bonus = tp_bonus + (relic_bonus_per_merit * savagery_merits)
		end
	end
	
	return tp_bonus
end

warcry_tp_bonus = get_warcry_tp_bonus()