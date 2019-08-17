require 'luau'
res = require('resources')
files = require('files')
packets = require('packets')
require('my_gambits')

_addon = _addon or {}
_addon.name = 'Gambits';
_addon.commands = {'g'};
_addon.author = 'ibm2431';
_addon.version = 0.10;


--[[
WATCHED_PLAYER
ANY_ALLY
PT_(JOB)
ALLY_(JOB)
WATCHED_(JOB)
ENEMY

HP < (10% -> 100%)
MP < (10% -> 100%)
TP > (0 -> 3000)
STATUS
NOT_STATUS
DEAD
CASTING
READYING

CURE
REMOVE
DISPEL
DEBUFF

ENEMY: STATUS (PROTECT) -> DISPEL
--]]

-- ==============================================
-- == UTILITY FUNCTIONS
-- ==============================================

-- Sorts an id-sorted resource table with the english names as keys
---------------------------------------------------------------------
function sort_by_en(resource, option)
  local resorted = {}
  local en_name
  local v
  if (option == 'item') then
    for i = 4096, 6370, 1 do
      v = resource[i]
      if (v) then
        en_name = v.en:lower()
        resorted[en_name] = v
      end
    end
  elseif (option == 'enl') then
    for _,v in pairs(resource) do
      en_name = v.enl:lower()
      if (resorted[en_name] == nil) then
        resorted[en_name] = v
      end
    end
  else
    for _,v in pairs(resource) do
      en_name = v.en:lower()
      if (resorted[en_name] == nil) then
        resorted[en_name] = v
      end
    end
  end
  return resorted
end

-- Refreshes variables when we enter a new zone to
-- adjust for new mob IDs
function zone_refresh()
  enemies = {}

  mob = {}
  mob.performing = false
  mob.statuses = {}
  
  player = windower.ffxi.get_player()
  my_id = player.id
  my_name = player.name
  party = {}
  party_members = {}
  
  local party_info = windower.ffxi.get_party()
  local mob_id = false
  for key,value in pairs(party_info) do
    if (string.find(key, "count")) then
      -- ignore
    elseif (string.find(key, "leader")) then
      -- ignore
    else
      if (value.mob) then
        mob_id = value.mob.id
        if (in_party(mob_id) ~= true) then
          party_members[mob_id] = value.name
          party_members[value.name] = mob_id
          party[mob_id] = {}
          party[mob_id].id = mob_id
          party[mob_id].name = value.name
          party[mob_id].statuses = {}
        end
        party[mob_id].hp = value.hp
        party[mob_id].hpp = value.hpp
        party[mob_id].mp = value.mp
        party[mob_id].mpp = value.mpp
        party[mob_id].tp = value.tp
      end
    end
  end
end

-- =======================================================
-- COMBAT RELATED ACTIONS & EVENTS
-- =======================================================

-- Refreshs stored pt members, hp, mp, and tp. Also
-- rechecks our own buffs/statuses.
---------------------------------------------------------------------
function refresh_party_status()
  local party_info = windower.ffxi.get_party()
  local mob_id = false
  for key,value in pairs(party_info) do
    if (string.find(key, "count")) then
      -- ignore
    elseif (string.find(key, "leader")) then
      -- ignore
    else
      if (value.mob) then
        mob_id = value.mob.id
        if (in_party(mob_id) ~= true) then
          party_members[mob_id] = value.name
          party_members[value.name] = mob_id
          party[mob_id] = {}
          party[mob_id].id = mob_id
          party[mob_id].name = value.name
          party[mob_id].statuses = {}
        end
        party[mob_id].hp = value.hp
        party[mob_id].hpp = value.hpp
        party[mob_id].mp = value.mp
        party[mob_id].mpp = value.mpp
        party[mob_id].tp = value.tp
      end
    end
  end
  
  -- Process own buffs via accurate get_player().buffs
  local get_player_buffs = windower.ffxi.get_player().buffs
  local my_buffs = {}
  local my_id = player.id
  party[my_id].shadows = 0
  party[my_id].f_moves = 0
  for _,value in pairs(get_player_buffs) do
    my_buffs[value] = true
    if (value == 66) then
      party[my_id].shadows = 1
    elseif ((value > 380) and (value < 385)) then
      party[my_id].f_moves = value - 380
    elseif ((value > 443) and (value < 447)) then
      party[my_id].shadows = value - 442
    elseif (value == 588) then
      party[my_id].f_moves = 6
    end
  end
  party[my_id].statuses = my_buffs
end

-- Parses a party buff packet and sets status IDs for real players
---------------------------------------------------------------------
function parse_party_buffs(data)
    buff_packet = packets.parse('incoming', data)
    
    local player_id, player_buff_data, player_buff_bitmask
    local player_i = 1
    
    local buff_i = 0
    local buff_add_value = 0
    local buff_value = 0
    
    player_id = buff_packet["ID ".. player_i]
    player_buff_data = buff_packet["Buffs ".. player_i]
    player_buff_bitmask = string.unpack(buff_packet["Bit Mask ".. player_i],'i')
    
    while ((player_id ~= 0) and (player_i <= 5)) do
      party[player_id].statuses = {}
      
      buff_i = 1
      buff_value = string.byte(player_buff_data, buff_i)
      while (buff_value ~= 255) do
        buff_add_value = bit.band(3, bit.rshift(player_buff_bitmask,(buff_i - 1) * 2))
        if (buff_add_value >= 1) then
          if (buff_add_value == 2) then
            buff_value = buff_value + 512
          else
            buff_value = buff_value + 256
          end
        end
        
        set_status(player_id, buff_value, true)
        buff_i = buff_i + 1
        buff_value = string.byte(player_buff_data, buff_i)
      end
      
      player_i = player_i + 1
      player_id = buff_packet["ID ".. player_i]
      player_buff_data = buff_packet["Buffs ".. player_i]
      player_buff_bitmask = string.unpack(buff_packet["Bit Mask ".. player_i],'i')
    end
end

-- Checks if the given player ID belongs to a party member
---------------------------------------------------------------------
function in_party(id)
  if (party_members[id]) then return true
  else return false end
end

-- Checks to see if a given target has the
-- specified status effect.
---------------------------------------------------------------------
function has_status(target, id)
  if in_party(target) then
    if (party[target].statuses[id]) then
      return party[target].statuses[id]
    end
  end
  return false
end

-- Updates the given status effect in the target's status array
---------------------------------------------------------------------
function set_status(target_id, status, gain_lose)
  if (gain ~= true) then
    gain = false
  end
  if (in_party(target_id)) then
    party[target_id].statuses[status] = gain_lose
  else
    -- mob was inflicted with status
  end
end

-- Updates the current skillchain property open on the enemy
---------------------------------------------------------------------
function sc_property(ws, time)
  time = tostring(time)
  ws = tonumber(ws)
  if (ws >= 0) then
  --[[
    local ws_info = res.weapon_skills[ws]
    sc_prop_a = ws_info.skillchain_a
    sc_prop_b = ws_info.skillchain_b
    ws_time = time
    windower.send_command("@wait 4.5; g scprop -1 ".. ws_time)
  --]]
  else
    if (time == ws_time) then
      sc_prop_a = false
      sc_prop_b = false
      ws_time = false
    end
  end
end

-- Checks to see if the recast time for the given
-- given ID ability type is 0 (ie: ready to use)
---------------------------------------------------------------------
function ability_ready(ability_type, ability_id)
  local ready = false
  local ability = false
  local recast_id = false
  if (ability_type == 'WS') then
    return (party[my_id].tp >= 1000)
  elseif (ability_type == 'ITEM') then
    local items = windower.ffxi.get_items()
    local inv_items = items.inventory
    local temp_items = items.temporary
    local num_slots = items.count_inventory
    for i = 1, num_slots, 1 do
      if (inv_items[i].id == ability_id) then
        return true
      end
    end
    num_slots = items.count_temporary
    for i = 1, num_slots, 1 do
      if (temp_items[i].id == ability_id) then
        return true
      end
    end
    return false
  else
    if (ability_type == 'JA') then
      recasts = windower.ffxi.get_ability_recasts()
      ability = res.job_abilities[ability_id]
      recast_id = ability.recast_id
      if (recast_id == 231) then --Strategems
        if ((player.main_job == 'SCH') or (player.sub_job == 'SCH')) then
          if (recasts[recast_id] < 240) then
            return true
          end
        end
      end
      if (party[my_id].tp < ability.tp_cost) then
        return false
      end
    elseif (ability_type == 'MA') then
      recasts = windower.ffxi.get_spell_recasts()
      ability = res.spells[ability_id]
      recast_id = ability.recast_id
      
      if (party[my_id].mp < ability.mp_cost) then
        return false
      end
    end
    
    return(recasts[recast_id] == 0)
  end
end

-- Returns true/false if the player is targetting a monster
---------------------------------------------------------------------
function targetting_monster(claimed_only)
  local mob = windower.ffxi.get_mob_by_target("<t>")
  if (mob) then
    if (mob.valid_target and mob.is_npc) then
      -- I've never seen a Player/Trust with an index < 1000.
      if (windower.ffxi.get_player().target_index < 1000) then
        if (claimed_only) then
          return in_party(mob.claim_id)
        else
          return ((mob.claim_id == 0) or (in_party(mob.claim_id)))
        end
      end
    end
  end
  return false
end

-- Returns an array representing the targetted enemy
---------------------------------------------------------------------
function get_targetted_enemy()
  local mob = windower.ffxi.get_mob_by_target("<t>")
  if (mob) then
    if (mob.valid_target and mob.is_npc) then
      -- I've never seen a Player/Trust with an index < 1000.
      if (windower.ffxi.get_player().target_index < 1000) then
        if enemies[mob.id] then
          return {enemies[mob.id]}
        end
      end
    end
  end
  return {{['casting']=false,['readying']=false}}
end

-- Adds an aggroed mob to the enemies table
---------------------------------------------------------------------
function aggroed_by(id)
  if (enemies[id] == nil) then
    enemies[id] = {}
    enemies[id].readying = false
    enemies[id].casting = false
  end
end

-- Checks to see if an action message concerns the
-- party, and if so, how the situation has changed.
---------------------------------------------------------------------
function concerns_us(action)
  local effects_us = false
  local all_effects = {}
  
  local targets = action['targets']
  local actor_id = action['actor_id']
  local target_id = 0
  
  if (action.actor_id == my_id) then
    if ((action.category > 1) and (action.category < 7)) then
      --can_take_action = true
    end
  end
  
  for index,value in pairs(targets) do
    target_id = value.id
    
    if (in_party(actor_id) or in_party(target_id) or (enemies[actor_id] ~= nil)) then

      effects_us = true
      if (in_party(actor_id) and (not in_party(target_id))) then
        aggroed_by(target_id)
      elseif (in_party(target_id) and (not in_party(actor_id))) then
        aggroed_by(actor_id)
      end
      
      if (enemies[actor_id] ~= nil) then
        local action_param = tonumber(action['targets'][1]['actions'][1]['param'])
        if (action.category == 7) then -- Initiation TP move
          enemies[actor_id].readying = action_param
        elseif (action.category == 8) then -- Initiation of spell
          if (action.param == 24931) then
            enemies[actor_id].casting = action_param
          elseif (action.param == 28787) then
            enemies[actor_id].casting = false
          end
        elseif (action.category == 4) then -- Completion of spell
          enemies[actor_id].casting = false
        elseif (action.category == 11) then -- Completion of TP move
          enemies[actor_id].readying = false
        end
      end
      
      -- NOTE: "<player> is no longer <status>" (from wearing off) is NOT given through ANY action message
      for _,v1 in pairs(value.actions) do
        local type = v1.message
        
        -- 043 :: <actor> readies <weapon_skill>.
        if ((type == 43) and in_party(actor_id)) then
          windower.send_command("@wait 2.5; g scprop ".. v1.param .." ".. windower.ffxi.get_info().time);
        end
        
        -- See cut_code.bak (code segment 1) for old buff status code, which is 
        -- technically still applicable to trusts, but the system was never perfect, 
        -- and could potentially interfere with perfect buff info on real players.
      end
    end
    

  end
  
  return effects_us
end


-- ==============================================
-- == GAMBITS FUNCTIONS
-- ==============================================

-- Returns a given target information table based on
-- the provided descriptor
function get_target(target, t_arg)
  local switch = {
    ["SELF"] = function(t_arg) return {party[my_id]} end,
    ["PARTY"] = function(t_arg) return party end,
    ["ENEMY"] = function(t_arg) return get_targetted_enemy() end
  }
  
  return switch[target](t_arg)
end

--  Runs through the loaded gambit list looking for the
--  highest priority trigger and executes it.
function check_gambit_list(gambits, num_gambits)
  local reaction = false
  local satisfying_target = false
  local i = 1
  local gambit

  if (can_take_action and gambits_enabled) then
    local me = windower.ffxi.get_player()
    if ((engaged_only == false) or (engaged_only and (me.status == 1))) then
      while ((reaction == false) and (i <= num_gambits)) do
        gambit = gambits[i]
        reaction, satisfying_target = check_gambit(gambit[1],gambit[2],gambit[3],gambit[4],gambit[5])
        i = i + 1
      end

      if (reaction ~= false) then
        can_take_action = false
        react(reaction, satisfying_target)
      end
    end
  end
end


-- Checks if the reaction can be performed (ability/spell ready),
-- That the reaction is on a valid target, and then sees if the
-- trigger condition has been satisfied.
function check_gambit(subject, condition, c_arg, reaction, r_arg)
  --- Get information about the ability
  local ability = false
  local ready = false
  
  
  -- Job-specific stunning methods
  if (reaction == "STUN") then
    reaction = "JA"
    r_arg = 207
    -- Note: Sets to false even if stun method isn't up
    -- Need to hook into proper action messages later.
    mob.performing = false
  end

  if (reaction == "ATTACK") then
    ready = targetting_monster(true)
    ability = "ATTACK"
  elseif (reaction == "ASSIST") then
    local satisfied, satisfying_target = satisfies_condition(subject,condition,c_arg)
    if (satisfied) then
      return reaction, c_arg
    end
  else
    if (reaction == "WS") then
      ability = res.weapon_skills[r_arg]
    elseif (reaction == "JA") then
      ability = res.job_abilities[r_arg]
    elseif (reaction == "MA") then
      ability = res.spells[r_arg]
    end
    
    ready = ability_ready(reaction, r_arg)
    
    --- Block an attempt to use an Enemy-only ability on a pt member
    if ((reaction == "WS") or (reaction == "JA") or (reaction == "MA")) then
      if (ability.targets.Enemy) then
        if (ability.targets.Party ~= true) then
          -- The true argument sets "claimed by pt only". If you want
          -- to WS/MA/JA unclaimed mobs, set to false.
          if (targetting_monster(true) ~= true) then
            ready = false
          end
        end
      end
    end
  end
  
  -- For now, just see if the ability timer is ready, we can
  -- do more thorough checking (ie: targeting the mob for a WS,
  -- not trying to cast a spell while silenced, etc) later.

  if (ready) then
    -- Check if the condition is satisfied
    local satisfied, satisfying_target = satisfies_condition(subject,condition,c_arg)
    if (satisfied) then
      if (reaction == "ITEM") then
        return r_arg, "ITEM"
      else
        return ability, satisfying_target
      end
    end
  end
  
  return false, false
end

-- Takes a target descriptor and sees if it is satisfied.
function satisfies_condition(target, condition, c_arg, multiple)
  local satisfying_targets = {}
  local at_least_one_satisfying_target = false
  
  if (target == 'AND') then
    return satisfies_multiple('AND', condition)
  else
    -- Get information about the target
    local targets = get_target(target, '_')
    
    --- Checks trigger against the information
    local switch = {
      ["HPP >"] = function(target, c_arg) return (target.hpp > c_arg) end,
      ["HPP <="] = function(target, c_arg) return (target.hpp <= c_arg) end,
      ["TP >="] = function(target, c_arg) return (target.tp >= c_arg) end,
      ["READYING"] = function(target, c_arg) return (target.readying == c_arg) end,
      ["CASTING"] = function(target, c_arg) return (target.casting == c_arg) end,
      ["STATUS"] = function(target, c_arg) return (has_status(target.id, c_arg)) end,
      ["NOT_STATUS"] = function(target, c_arg) return (has_status(target.id, c_arg) == false) end,
      ["JA_READY"] = function(target, c_arg) return (ability_ready('JA',c_arg)) end,
      ["MA_READY"] = function(target, c_arg) return (ability_ready('MA',c_arg)) end,
      ["SHADOWS <"] = function(target, c_arg) return (target.shadows < c_arg) end,
      ["MOVES <"] = function(target, c_arg) return (target.moves < c_arg) end,
      ["MOVES >="] = function(target, c_arg) return (target.moves >= c_arg) end,
      ["CAN_SC"] = function(target, c_arg) return ((target.tp >= 1000) and (skillchains[c_arg][sc_prop_a] or skillchains[c_arg][sc_prop_b])) end,
      ["NOT_ENGAGED"] = function(target, c_arg) return (windower.ffxi.get_player().status ~= 1) end,
      ["NOT_ASSISTING"] = function(target, c_arg)
        local to_assist = windower.ffxi.get_mob_by_name(c_arg)
        return ((to_assist.status == 1) and (to_assist.target_index ~= windower.ffxi.get_player().target_index))
      end
    }

    for k,v in pairs(targets) do
      if(switch[condition](v, c_arg)) then
        if (multiple) then
          table.insert(satisfying_targets, k)
          at_least_one_satisfying_target = true
        else
          return true, k
        end
      end
    end
    
    if (multiple and at_least_one_satisfying_target) then
      return true, satisfying_targets
    else
      return false
    end
  end
end

-- Checks to see if multiple conditions are satisfied.
function satisfies_multiple(type, all_conditions)
  local satisfied, satisfying_targets
  local satisfying_targets_thus_far = {}
  local target, trigger, t_arg
  local conditions = all_conditions
  if (type == 'AND') then
    local i, v = next(conditions, nil)
    
    target, trigger, t_arg = conditions[i][1], conditions[i][2], conditions[i][3]
    
    satisfied, satisfying_targets = satisfies_condition(target, trigger, t_arg, true)
    if (satisfied == true) then
      satisfying_targets_thus_far = satisfying_targets
    else
      return false
    end
    
    i, v = next(conditions, i)
    while i do  
      target, trigger, t_arg = conditions[i][1], conditions[i][2], conditions[i][3]
      satisfied, satisfying_targets = satisfies_condition(target, trigger, t_arg, true)
      if (satisfied == true) then
        for k,_ in pairs(satisfying_targets) do
          if (satisfying_targets_thus_far[k] == nil) then
            satisfying_targets[k] = nil
          end
        end
        if (next(satisfying_targets) == nil) then
          return false
        else
          satisfying_targets_thus_far = satisfying_targets
        end
      else
        return false
      end
      i, v = next(conditions, i)
    end
    
    return true, satisfying_targets_thus_far[1]
  end
end

-- Attempts to perform a reaction
function react(ability, target)
  to_wait = .2 --- so we don't appear to have inhuman reaction time
  local command
  if (ability == "ATTACK") then
    action_time = 2
    command = "/lockon; @wait 1; input /follow; @wait 1; input /a"
  elseif (ability == "ASSIST") then
    action_time = 2
    command = "/assist ".. target
  elseif (target == "ITEM") then
    action_time = 5
    command = '/item "'.. res.items[ability].en ..'" <me>'
  else
    if (ability.targets.Party and in_party(target)) then
      macro_target = party[target].name
    elseif (ability.targets.Self) then
      macro_target = "<me>"
    elseif (ability.targets.Enemy) then
      macro_target = "<t>"
    else
      macro_target = "<t>"
    end
    
    if (ability.cast_time) then
      action_time = ability.cast_time + 4
    else
      action_time = 4
    end
    
    command = ability.prefix .. " \"".. ability.en .."\" ".. macro_target
  end
  
  
  windower.send_command("@wait ".. to_wait .."; input " .. command);
  windower.send_command("@wait ".. to_wait + action_time .."; g cta");
end

-- Determines if we should use special tactics, or just our default
-- gambits against the mob we're currently fighting.
function determine_gambits()
  local correct_gambits, num_correct_gambits
  local t_mob, t_mob_name, bt_mob, bt_mob_name
  t_mob = windower.ffxi.get_mob_by_target("<t>")
  bt_mob = windower.ffxi.get_mob_by_target("<bt>")
  if (t_mob) then
    t_mob_name = t_mob.name
  end
  if (bt_mob) then
    bt_mob_name = bt_mob.name
  end
  
  if (tactics[t_mob_name] ~= nil) then
    correct_gambits = tactics[t_mob_name]['gambits']
    num_correct_gambits = tactics[t_mob_name]['num_gambits']
  elseif(tactics[bt_mob_name ~= nil]) then
    correct_gambits = tactics[bt_mob_name]['gambits']
    num_correct_gambits = tactics[bt_mob_name]['num_gambits']
  else  
    correct_gambits, num_correct_gambits = default_gambits, num_default_gambits
  end
  return correct_gambits, num_correct_gambits
end

-- Toggles gambits on/off
function toggle_gambits()
  if (gambits_enabled) then
    gambits_enabled = false
    notice("OFF")
  else
    gambits_enabled = true
    notice("ON")
  end
end


-- =======================================================
-- GAMBIT LOADING/PROCESSING/TRANSLATING
-- =======================================================

-- Loads the gambits for the current job
---------------------------------------------------------------------
function load_gambits(source)
  local gambits = require(source)
  gambits = gambits[player.main_job]
  if (gambits) then
    local num_gambits = 0
    for _,_ in pairs(gambits) do
      num_gambits = num_gambits + 1
    end
    gambits = process_gambits(gambits, num_gambits)
    return gambits, num_gambits
  else
    return {}, 0
  end
end

--- Loads all the existing tactics lists
---------------------------------------------------------------------
function load_tactics()
  local tactics = {}
  local mob_tactics = {}
  local num_mob_tactics = 0
  lines = files.readlines("tactics/tactics_list.txt")
  for _,v in ipairs(lines) do
    if (v) then
      tactics[v] = {}
      mob_tactics, num_mob_tactics = load_gambits('tactics/'.. v)
      tactics[v]['gambits'] = mob_tactics
      tactics[v]['num_gambits'] = num_mob_tactics
    end
  end
  return tactics
end

-- Check to see if the selector and trigger are valid.
---------------------------------------------------------------------
function process_selector(selector, trigger, trigger_arg)
  local valid_self_triggers = S{"STATUS","NOT_STATUS","NOT_ENGAGED","NOT_ASSISTING","TP >=","HPP <=","HPP >","MA_READY","JA_READY","SHADOWS <","MOVES <","MOVES >=","CAN_SC"}
  local valid_party_triggers = S{"STATUS","NOT_STATUS","TP >=","HPP <=","HPP >"}
  local valid_enemy_triggers = S{"STATUS","NOT_STATUS","READYING","CASTING","HPP <=","HPP >"}
  
  if ((selector == "SELF") or (selector == "PARTY") or (selector == "ENEMY")) then
    if (((selector == "SELF") and valid_self_triggers[trigger]) or
      ((selector == "PARTY") and valid_party_triggers[trigger]) or
      ((selector == "ENEMY") and valid_enemy_triggers[trigger])) then
      -- Valid selector/trigger, fall through.
    else
      error("Invalid trigger type '".. trigger .."' for Gambit #".. gambit_num ..". Aborting.")
      return false
    end
  else
    error("Unknown selector '".. selector .."' for Gambit #".. gambit_num ..". Aborting.")
    return false
  end
  
  -- Check to see if the trigger argument is valid
  local final_trigger_arg = false
  local triggers_with_raw_args = S{"HPP <=","HPP >","TP >=","NOT_ENGAGED","NOT_ASSISTING","SHADOWS <","MOVES <","MOVES >=","CAN_SC"}
  if (triggers_with_raw_args[trigger]) then
    final_trigger_arg = trigger_arg
  else
    local res_table = false
    trigger_arg = tostring(trigger_arg):lower()
    if ((trigger == "STATUS") or (trigger == "NOT_STATUS")) then
      res_table = buffs_by_en
      if (res_table[trigger_arg] == nil) then
        res_table = buffs_by_enl
      end
    elseif ((trigger == "MA_READY") or (trigger == "CASTING")) then
      res_table = spells_by_en
    elseif (trigger == "JA_READY") then
      res_table = job_abilities_by_en
    elseif (trigger == "READYING") then
      res_table = monster_abilities_by_en
    end
    
    if (res_table[trigger_arg]) then
      final_trigger_arg = res_table[trigger_arg].id
    end
  end
  
  return final_trigger_arg
end

-- Checks to see if a given reaction/reaction_arg is valid
---------------------------------------------------------------------
function process_reaction(reaction, reaction_arg)
  local final_reaction_arg = false
  local res_table = false
  
  if ((reaction == "ATTACK") or (reaction == "ASSIST") or (reaction == "SC")) then
    final_reaction_arg = true
  else
    if (reaction == "JA") then
      res_table = job_abilities_by_en
    elseif (reaction == "MA") then
      res_table = spells_by_en
    elseif (reaction == "WS") then
      res_table = weapon_skills_by_en
    elseif (reaction == "ITEM") then
      res_table = items_by_en
    else
      error("Unknown reaction type '".. reaction .."' for Gambit #".. gambit_num ..". Aborting.")
      return false
    end
    
    reaction_arg = tostring(reaction_arg):lower()
    if (res_table[reaction_arg]) then
      final_reaction_arg = res_table[reaction_arg].id
    end
  end
  return final_reaction_arg
end

-- Piece apart a single gambit and, if valid, return its true form
---------------------------------------------------------------------
function process_gambit(gambit, gambit_num)
  local selector, trigger, trigger_arg = gambit[1], gambit[2], gambit[3]
  local reaction, reaction_arg = gambit[4], gambit[5]
  local final_gambit = false

  final_reaction_arg = process_reaction(reaction, reaction_arg)
  if (final_reaction_arg == false) then
    error("Invalid reaction value '".. reaction_arg .."' for Gambit #".. gambit_num ..". Aborting.")
    return false
  end

  if (selector == "AND") then
    --local final_gambit = {"AND",{},"",
    local final_trigger_arg = false
    local all_selectors = {}
    for _,v in pairs(trigger) do
      final_trigger_arg = process_selector(v[1], v[2], v[3])
      if (final_trigger_arg == false) then
        error("Invalid trigger value '".. trigger_arg .."' for Gambit #".. gambit_num ..". Aborting.")
        return false
      else
        table.insert(all_selectors, {v[1],v[2],final_trigger_arg})
      end
    end
    final_gambit = {"AND", all_selectors, "", reaction, final_reaction_arg}
  else
    final_trigger_arg = process_selector(selector, trigger, trigger_arg)
    if (final_trigger_arg == false) then
      error("Invalid trigger value '".. trigger_arg .."' for Gambit #".. gambit_num ..". Aborting.")
      return false
    end
    final_gambit = {selector, trigger, final_trigger_arg, reaction, final_reaction_arg}
  end
  return final_gambit
end

-- Go through the player's stated gambits and validate/process them
function process_gambits(gambits, num_gambits)
  local processed_gambit = true
  local processed_gambits = {}
  local i = 1
  while ((i <= num_gambits) and (processed_gambit ~= false)) do
    gambit = gambits[i]
    processed_gambit = process_gambit(gambits[i], i)
    processed_gambits[i] = processed_gambit
    i = i + 1
  end
  return processed_gambits
end

-- =================================================
-- EVENT LISTENERS
-- =================================================

windower.register_event("action", function(action)
  if (concerns_us(action)) then
    refresh_party_status()
    local gambits_to_check, num_gambits_to_check = determine_gambits()
    check_gambit_list(gambits_to_check, num_gambits_to_check)
  end
end)

windower.register_event('incoming chunk', function(id, data)
  if (id == 0x029) then
    local action_message = packets.parse('incoming', data)
    if (action_message['Message'] == 6) then
      local defeated_id = action_message['Target']
      if (enemies[defeated_id]) then
        enemies[defeated_id] = nil
      end
    end
  elseif (id == 0x076) then
    parse_party_buffs(data)
    local gambits_to_check, num_gambits_to_check = determine_gambits()
    check_gambit_list(gambits_to_check, num_gambits_to_check)
  end
end)

windower.register_event("zone change", function(new_id, old_id)
  zone_refresh()
end)

windower.register_event('addon command',function (command, ...)
	command = command and command:lower()
	local args = T{...}
	if command == 'cta' then
    can_take_action = true
    refresh_party_status()
    local gambits_to_check, num_gambits_to_check = determine_gambits()
    check_gambit_list(gambits_to_check, num_gambits_to_check)
  elseif command == 'scprop' then
    sc_property(args[1], args[2])
  elseif command == 'toggle' then
    toggle_gambits()
	else
		warning('Unknown command: \''..command..'\'. Ignored.')
	end
end)

-- ==============================================
-- == ONLOAD SETUP
-- ==============================================

buffs_by_en = sort_by_en(res.buffs)
buffs_by_enl = sort_by_en(res.buffs, 'enl')
spells_by_en = sort_by_en(res.spells)
job_abilities_by_en = sort_by_en(res.job_abilities)
weapon_skills_by_en = sort_by_en(res.weapon_skills)
monster_abilities_by_en = sort_by_en(res.monster_abilities)
items_by_en = sort_by_en(res.items, 'item')
skillchains = {
  ["Light"] = S{"Fusion","Fragmentation","Light"},
  ["Darkness"] = S{"Gravitation","Distortion","Darkness"},
  ["Fusion"] = S{"Liquefaction","Distortion"},
  ["Fragmentation"] = S{"Induration","Gravitation"},
  ["Gravitation"] = S{"Detonation","Fusion"},
  ["Distortion"] = S{"Transfixion","Fragmentation"},
  ["Liquefaction"] = S{"Impaction","Scission"},
  ["Impaction"] = S{"Reverbation","Induration"},
  ["Detonation"] = S{"Impaction","Compression","Scission"},
  ["Scission"] = S{"Liquefaction","Detonation"},
  ["Reverberation"] = S{"Transfixion","Scission"},
  ["Induration"] = S{"Reverberation"},
  ["Compression"] = S{"Induration","Transfixion"},
  ["Transfixion"] = S{"Compression"}
}

can_take_action = true
gambits_enabled = true
engaged_only = true

enemies = {}
mob = {}
mob.performing = false
mob.statuses = {}

player = windower.ffxi.get_player()
my_id = player.id
my_name = player.name
party = {}
party_members = {}

sc_prop_a = false
sc_prop_b = false
ws_time = false

zone_refresh()
default_gambits, num_default_gambits = load_gambits('my_gambits')

tactics = load_tactics()

windower.send_command('bind ^g g toggle')
