require 'luau'
res = require('resources')

_addon = _addon or {}
_addon.name = 'g';
_addon.commands = {'g'};
_addon.author = 'ibm2431';
_addon.version = 0.2;



--[[
SELF
WATCHED_PLAYER
ANY_PT
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
BUFF
JA
NUKE
WS
STUN

ANY_PT: HP < (70%) -> CURE
SELF: TP > 1000 -> WS ("Rudra's Storm")
SELF: NOT_STATUS (PROTECT) -> BUFF (PROTECT)
ENEMY: STATUS (PROTECT) -> DISPEL
ENEMY: READYING ("Incinerating Lahar") -> STUN
--]]

player = windower.ffxi.get_player()
my_id = player.id
my_name = player.name
party = {}
party_members = {}

can_take_action = true

mob = {}
mob.performing = false
mob.statuses = {}

function get_party()
  party = windower.ffxi.get_party()
  for key,value in pairs(party) do
    if (string.find(key, "count")) then
      -- ignore
    elseif (string.find(key, "leader")) then
      -- ignore
    else
      if (value.mob) then
        string_id = tostring(value.mob.id)
        member_name = value.name
        party_members[string_id] = member_name
        party_members[member_name] = string_id
      end
    end
  end
end

function refresh_party_status()
  party = windower.ffxi.get_party()
  for key,value in pairs(party) do
    if (string.find(key, "count")) then
      -- ignore
    elseif (string.find(key, "leader")) then
      -- ignore
    else
      if (value.mob) then
        member_name = value.name
        party[member_name] = {}
        party[member_name].name = member_name
        party[member_name].statuses = {}
        party[member_name].hp = value.hp
        party[member_name].hpp = value.hpp
        party[member_name].mp = value.mp
        party[member_name].mpp = value.mpp
        party[member_name].tp = value.tp
      end
    end
  end
  local my_buffs = windower.ffxi.get_player().buffs
  party[my_name].statuses = my_buffs
  --print(party[my_name].statuses[1])
end

function in_party(id)
  id = tostring(id)
  if (party_members[id]) then
    return true
  else
    return false
  end
end

-- Checks to see if a given target has the
-- specified status effect. (Current n-time)
function has_status(target, id)
  statuses = target.statuses
  for _, value in pairs(statuses) do
    if (value == id) then
      return true
    end
  end
  return false
end

-- Checks to see if the recast time for the given
-- given ID ability type is 0 (ie: ready to use)
function ability_ready(ability_type, recast_id)
  local recasts = false
  local ready = false
  if (ability_type == 'JA') then
    recasts = windower.ffxi.get_ability_recasts()
    return (recasts[recast_id] == 0)
  elseif (ability_type == 'MA') then
    recasts = windower.ffxi.get_spell_recasts()
    return (recasts[recast_id] == 0)
  else
    return false
  end
end

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
      for k1,v1 in pairs(value.actions) do
        local type = v1.message
        -- 242 :: <actor> uses <weapon_skill>. <target> is <status>.
        -- 277 :: <target> is <status>.
        if ((type == 242) or (type == 277)) then
          --print('target')
          --print(target_id)
          --print(party_members[target_id])
          --print(' ' .. type .. ' '.. v1.param)
          
          --situation_changed = true
          --think(THOUGHT_TYPE_INFLICTED, party_members[target_id], v1.param)
        end
      end
    end
  end
  
  return effects_us
end


-- Returns a given target information table based on
-- the provided descriptor
function get_target(target, t_arg)
  local switch = {
    ["SELF"] = function(t_arg) return (party[my_name]) end,
    ["ENEMY"] = function(t_arg) return mob end
  }
  
  return switch[target](t_arg)
end

-- Takes a target descriptor and sees if it is satisfied.
function satisfies_condition(target, condition, c_arg)
  -- Get information about the target
  local target = get_target(target, '_')
  --- Checks trigger against the information
  local switch = {
    ["TP >="] = function(c_arg) return (target.tp >= c_arg) end,
    ["PERFORMING"] = function(c_arg) return (target.performing == c_arg) end,
    ["NOT_STATUS"] = function(c_arg) return (has_status(target, c_arg) == false) end,
    ["JA_READY"] = function(c_arg) return (ability_ready(c_arg, 'JA') == true) end
  }
  
  return switch[condition](c_arg)
end

--- Builds an input string to send to FFXI for a given reaction
function reaction_string(reaction, r_arg)
  local switch = {
    ["WS"] = function(r_arg) return ("/ws \"".. r_arg .."\" <t>") end,
    ["STUN"] = function(r_arg) return ("/ja \"Violent Flourish\" <t>") end,
    ["JA"] = function(r_arg) return ("/ja \"".. r_arg .."\" <me>") end
  }
  
  return switch[reaction](r_arg)
end

--  Runs through the loaded gambit list looking for the
--  highest priority trigger and executes it.
function check_gambit_list()
  reaction = false
  if (satisfies_condition("SELF","TP >=",1000)) then
    reaction = reaction_string("WS", "Rudra's Storm")
  elseif (satisfies_condition("ENEMY","PERFORMING",2696)) then
    reaction = reaction_string("STUN")
    mob.performing = false
  --elseif (check_gambit("SELF","JA_READY",223,"JA",239)) then
    --reaction = check_gambit("SELF","JA_READY",223,"JA",239)
  elseif (check_gambit("SELF","NOT_STATUS",410,"JA",237)) then
    reaction = check_gambit("SELF","NOT_STATUS",410,"JA",237)
  end
  
  if (reaction ~= false) then
    can_take_action = false
    react(reaction)
  end
end

function check_gambit(subject, condition, c_arg, reaction, r_arg)
  -- Check if ja can be performed, if not, fail, fall through
  
  --- Get information about the ability
  local ability = false
  local macro_target = "<me>"
  
  if (reaction == "JA") then
    ability = res.job_abilities[r_arg]
  elseif (reaction == "MA") then
    ability = res.spells[r_arg]
  end
  
  -- For now, just see if the ability timer is ready, we can
  -- do more thorough checking (ie: targeting the mob for a WS,
  -- not trying to cast a spell while silenced, etc) later.

  if (ability_ready(reaction, ability.recast_id)) then
    -- Check if the condition is satisfied
    if satisfies_condition("SELF","NOT_STATUS",410) then
      if (ability.targets == 1) then
        macro_target = "<me>"
      elseif (ability.targets == 32) then
        macro_target = "<t>"
      end
      return ability.prefix .. " \"".. ability.en .."\" ".. macro_target
    end
  end
  
  return false
end

--- Attempts to perform a reaction
function react(reaction)
  to_wait = .2 --- so we don't appear to have inhuman reaction time
  action_time = 2
  windower.send_command("@wait ".. to_wait .."; input " .. reaction);
  windower.send_command("@wait ".. to_wait + action_time .."; g cta");
end

windower.register_event("action", function(action)
  if (concerns_us(action)) then
    refresh_party_status()
    if (can_take_action) then
      check_gambit_list()
    end
  end
end)

windower.register_event('addon command',function (command, ...)
	command = command and command:lower()
	local args = T{...}
	if command == 'cta' then
    can_take_action = true
	else
		warning('Unknown command: \''..command..'\'. Ignored.')
	end
end)

get_party()
refresh_party_status()