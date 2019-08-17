require 'luau'
res = require('resources')
require('my_gambits')

_addon = _addon or {}
_addon.name = 'Gambits';
_addon.commands = {'g'};
_addon.author = 'ibm2431';
_addon.version = 0.6;


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
STUN

ANY_PT: HP < (70%) -> CURE
SELF: TP > 1000 -> WS ("Rudra's Storm")
SELF: NOT_STATUS (PROTECT) -> BUFF (PROTECT)
ENEMY: STATUS (PROTECT) -> DISPEL
ENEMY: READYING ("Incinerating Lahar") -> STUN
--]]

-- ==============================================
-- == UTILITY FUNCTIONS
-- ==============================================

function sort_by_en(resource)
  local resorted = {}
  local en_name
  for _,v in pairs(resource) do
    en_name = v.en:lower()
    if (resorted[en_name] == nil) then
      resorted[en_name] = v
    end
  end
  return resorted
end

-- Refreshs stored pt members, hp, mp, and tp. Also
-- rechecks our own buffs/statuses.
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
  for _,value in pairs(get_player_buffs) do
    my_buffs[value] = true
  end
  party[my_id].statuses = my_buffs
end

-- Checks if the given player ID belongs to a party member
function in_party(id)
  if (party_members[id]) then return true
  else return false end
end

-- Checks to see if a given target has the
-- specified status effect.
function has_status(target, id)
  if in_party(target) then
    if (party[target].statuses[id]) then
      return party[target].statuses[id]
    end
  end
  return false
end

-- Updates the given status effect in the target's status array
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

-- Checks to see if the recast time for the given
-- given ID ability type is 0 (ie: ready to use)
function ability_ready(ability_type, ability_id)
  local ready = false
  local ability = false
  local recast_id = false
  if (ability_type == 'WS') then
    return (party[my_id].tp >= 1000)
  else
    if (ability_type == 'JA') then
      recasts = windower.ffxi.get_ability_recasts()
      ability = res.job_abilities[ability_id]
      recast_id = ability.recast_id
    elseif (ability_type == 'MA') then
      recasts = windower.ffxi.get_spell_recasts()
      ability = res.spells[ability_id]
      recast_id = ability.recast_id
    end
    
    return(recasts[recast_id] == 0)
  end
end

-- Returns true/false if the player is targetting a monster
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

-- Checks to see if an action message concerns the
-- party, and if so, how the situation has changed.
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
    
    if (in_party(actor_id) or in_party(target_id)) then
      effects_us = true
      -- Mob is preparing an action
      if (in_party(actor_id) ~= true) then
        if (action.category) == 7 then
          mob.performing = tonumber(action['targets'][1]['actions'][1]['param']) - 256
        elseif (action.category) == 8 then
          mob.performing = tonumber(action['targets'][1]['actions'][1]['param'])
        end
      else
        -- Party member is the actor
      end
      
      -- Process effects of the action to update status effects
      
      -- NOTE: "<player> is no longer <status>" is NOT given through ANY action message
      for _,v1 in pairs(value.actions) do
        local type = v1.message
        -- 100 :: <actor> uses <ability>. [Note: v1.param is the BUFF id, not ability]
        -- 242 :: <actor> uses <weapon_skill>. <target> is <status>. [Note: Target of Mob TP moves]
        -- 277 :: <target> is <status>. [Note: Includes AoE of Mob TP moves] 
        if ((type == 100) or (type == 242) or (type == 277)) then
          set_status(target_id, v1.param, true)
        end
        -- 064 :: <target> is no longer <status>. [Note: From AoE status removal (Divine Veil)]
        -- 075 :: <actor>'s <spell> has no effect on <target>. [Note: Paralyna when no paralysis; PARAM WILL BE 255]]
        -- 083 :: <actor> casts <spell>. <actor> successfully removes <target>'s <status>. [[Note: Successful Paralyna]]
        -- 123 :: <actor> uses <ability>. <actor> successfully removes <target>'s <status>. [[Note: Healing Waltz heals Silence]]
        if ((type == 64) or (type == 83) or (type == 123)) then
          set_status(target_id, v1.param, false)
        end
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
    ["ENEMY"] = function(t_arg) return {windower.ffxi.get_mob_by_target("t")} end
  }
  
  return switch[target](t_arg)
end

--  Runs through the loaded gambit list looking for the
--  highest priority trigger and executes it.
function check_gambit_list()
  local reaction = false
  local satisfying_target = false
  local i = 1
  local gambit
  
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
      return "ASSIST", c_arg
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
  
  -- For now, just see if the ability timer is ready, we can
  -- do more thorough checking (ie: targeting the mob for a WS,
  -- not trying to cast a spell while silenced, etc) later.

  if (ready) then
    -- Check if the condition is satisfied
    local satisfied, satisfying_target = satisfies_condition(subject,condition,c_arg)
    if (satisfied) then
      return ability, satisfying_target
    end
  end
  
  return false, false
end

-- Takes a target descriptor and sees if it is satisfied.
function satisfies_condition(target, condition, c_arg)
  -- Get information about the target
  local targets = get_target(target, '_')

  --- Checks trigger against the information
  local switch = {
    ["HPP <="] = function(target, c_arg) return (target.hpp <= c_arg) end,
    ["TP >="] = function(target, c_arg) return (target.tp >= c_arg) end,
    ["PERFORMING"] = function(target, c_arg) return (target.performing == c_arg) end,
    ["STATUS"] = function(target, c_arg) return (has_status(target.id, c_arg)) end,
    ["NOT_STATUS"] = function(target, c_arg) return (has_status(target.id, c_arg) == false) end,
    ["JA_READY"] = function(target, c_arg) return (ability_ready('JA',c_arg)) end,
    ["MA_READY"] = function(target, c_arg) return (ability_ready('MA',c_arg)) end,
    ["NOT_ENGAGED"] = function(target, c_arg) return (windower.ffxi.get_player().status ~= 1) end,
    ["NOT_ASSISTING"] = function(target, c_arg)
      local to_assist = windower.ffxi.get_mob_by_name(c_arg)
      return ((to_assist.status == 1) and (to_assist.target_index ~= windower.ffxi.get_player().target_index))
    end
  }

  for k,v in pairs(targets) do
    if(switch[condition](v, c_arg)) then
      return true, k
    end
  end 
  return false
end

--- Attempts to perform a reaction
function react(ability, target)
  to_wait = .2 --- so we don't appear to have inhuman reaction time
  local command
  if (ability == "ATTACK") then
    action_time = 2
    command = "/lockon; @wait 1; input /follow; @wait 1; input /a"
  elseif (ability == "ASSIST") then
    action_time = 2
    command = "/assist ".. target
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

--- Toggles gambits on/off
function toggle_gambits()
  if (gambits_enabled) then
    gambits_enabled = false
    notice("OFF")
  else
    gambits_enabled = true
    notice("ON")
  end
end

-- Piece apart a single gambit and, if valid, return its true form
function process_gambit(gambit, gambit_num)
  local selector, trigger, trigger_arg = gambit[1], gambit[2], gambit[3]
  local reaction, reaction_arg = gambit[4], gambit[5]
  
  local valid_self_triggers = S{"STATUS","NOT_STATUS","NOT_ENGAGED","NOT_ASSISTING","TP >=","HPP <=","MA_READY","JA_READY"}
  local valid_party_triggers = S{"STATUS","NOT_STATUS","TP >=","HPP <="}
  
  -- Check to see if the selector and trigger are valid.
  if ((selector == "SELF") or (selector == "PARTY")) then
    if (((selector == "SELF") and valid_self_triggers[trigger]) or
      ((selector == "PARTY") and valid_party_triggers[trigger])) then
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
  if ((trigger == "HPP <=") or (trigger == "TP >=") or (trigger == "NOT_ENGAGED") or (trigger == "NOT_ASSISTING")) then
    final_trigger_arg = trigger_arg
  else
    local res_table = false
    trigger_arg = tostring(trigger_arg):lower()
    if ((trigger == "STATUS") or (trigger == "NOT_STATUS")) then
      res_table = buffs_by_en
    elseif (trigger == "MA_READY") then
      res_table = spells_by_en
    elseif (trigger == "JA_READY") then
      res_table = job_abilities_by_en
    end

    if (res_table[trigger_arg]) then
      final_trigger_arg = res_table[trigger_arg].id
    end
  end

  if (final_trigger_arg == false) then
    error("Invalid trigger value '".. trigger_arg .."' for Gambit #".. gambit_num ..". Aborting.")
    return false
  end
  
  -- Check to see if the reaction/reaction_arg is valid
  local final_reaction_arg = false
  if ((reaction == "ATTACK") or (reaction == "ASSIST")) then
    final_reaction_arg = true
  else
    if (reaction == "JA") then
      res_table = job_abilities_by_en
    elseif (reaction == "MA") then
      res_table = spells_by_en
    elseif (reaction == "WS") then
      res_table = weapon_skills_by_en
    else
      error("Unknown reaction type '".. reaction .."' for Gambit #".. gambit_num ..". Aborting.")
      return false
    end
    
    reaction_arg = tostring(reaction_arg):lower()
    if (res_table[reaction_arg]) then
      final_reaction_arg = res_table[reaction_arg].id
    end
  end
  
  if (final_reaction_arg == false) then
    error("Invalid reaction value '".. reaction_arg .."' for Gambit #".. gambit_num ..". Aborting.")
    return false
  end
  
  local final_gambit = {selector, trigger, final_trigger_arg, reaction, final_reaction_arg}
  return final_gambit
end

-- Go through the player's stated gambits and validate/process them
function process_gambits(gambits)
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

windower.register_event("action", function(action)
  if (concerns_us(action)) then
    refresh_party_status()
    if (can_take_action and gambits_enabled) then
      check_gambit_list()
    end
  end
end)

windower.register_event('addon command',function (command, ...)
	command = command and command:lower()
	local args = T{...}
	if command == 'cta' then
    can_take_action = true
    refresh_party_status()
    check_gambit_list()
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
spells_by_en = sort_by_en(res.spells)
job_abilities_by_en = sort_by_en(res.job_abilities)
weapon_skills_by_en = sort_by_en(res.weapon_skills)

player = windower.ffxi.get_player()
my_id = player.id
my_name = player.name
party = {}
party_members = {}

can_take_action = true
gambits_enabled = true

mob = {}
mob.performing = false
mob.statuses = {}

gambits = gambits[player.main_job]
num_gambits = 0
for _,_ in pairs(gambits) do
  num_gambits = num_gambits + 1
end
gambits = process_gambits(gambits)

windower.send_command('bind ^g g toggle')
refresh_party_status()