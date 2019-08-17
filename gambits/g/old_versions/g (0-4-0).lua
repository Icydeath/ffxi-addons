require 'luau'
res = require('resources')
require('my_gambits')

_addon = _addon or {}
_addon.name = 'g';
_addon.commands = {'g'};
_addon.author = 'ibm2431';
_addon.version = 0.4;


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

num_gambits = 0
for _,_ in pairs(gambits) do
  num_gambits = num_gambits + 1
end

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

function in_party(id)
  if (party_members[id]) then
    return true
  else
    return false
  end
end

-- Checks to see if a given target has the
-- specified status effect. (Current n-time)
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
      
      -- NOTE: "<player> is no longer <status>" is NOT given through ANY action message
      for _,v1 in pairs(value.actions) do
        local type = v1.message
        -- 100 :: <actor> uses <ability>. [Note: v1.param is the BUFF id, not ability]
        -- 242 :: <actor> uses <weapon_skill>. <target> is <status>. [Note: Target of Mob TP moves]
        -- 277 :: <target> is <status>. [Note: Includes AoE of Mob TP moves] 
        if ((type == 100) or (type == 242) or (type == 277)) then
          set_status(target_id, v1.param, true)
        end
        -- 075 :: <actor>'s <spell> has no effect on <target>. [Note: Paralyna when no paralysis; PARAM WILL BE 255]]
        -- 083 :: <actor> casts <spell>. <actor> successfully removes <target>'s <status>. [[Note: Successful Paralyna]]
        -- 123 :: <actor> uses <ability>. <actor> successfully removes <target>'s <status>. [[Note: Healing Waltz heals Silence]]
        if ((type == 83) or (type == 123)) then
          set_status(target_id, v1.param, false)
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
    ["SELF"] = function(t_arg) return {party[my_id]} end,
    ["ENEMY"] = function(t_arg) return {windower.ffxi.get_mob_by_target("t")} end
  }
  
  return switch[target](t_arg)
end

-- Takes a target descriptor and sees if it is satisfied.
function satisfies_condition(target, condition, c_arg)
  -- Get information about the target
  local target = get_target(target, '_')
  target = target[1]
  --- Checks trigger against the information
  local switch = {
    ["HPP <="] = function(c_arg) return (target.hpp <= c_arg) end,
    ["TP >="] = function(c_arg) return (target.tp >= c_arg) end,
    ["PERFORMING"] = function(c_arg) return (target.performing == c_arg) end,
    ["NOT_STATUS"] = function(c_arg) return (has_status(target.id, c_arg) == false)end,
    ["JA_READY"] = function(c_arg) return (ability_ready(c_arg, 'JA') == true) end
  }
  
  return switch[condition](c_arg)
end

--  Runs through the loaded gambit list looking for the
--  highest priority trigger and executes it.
function check_gambit_list()
  local reaction = false
  local i = 1
  local gambit
  
  while ((reaction == false) and (i <= num_gambits)) do
    gambit = gambits[i]
    reaction = check_gambit(gambit[1],gambit[2],gambit[3],gambit[4],gambit[5])
    i = i + 1
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
  local ready = false
  local macro_target = "<me>"
  
  -- Job-specific stunning methods
  if (reaction == "STUN") then
    reaction = "JA"
    r_arg = 207
    -- Note: Sets to false even if stun method isn't up
    -- Need to hook into proper action messages later.
    mob.performing = false
  end

  if (reaction == "WS") then
    ability = res.weapon_skills[r_arg]
    macro_target = "<t>" -- res isn't returning stated value, "{Enemy}" instead
    local target = windower.ffxi.get_mob_by_target("t")
    if (target) then
      ready = ((in_party(target.id) == false) and (party[my_id].tp >= 1000))
    end
  else
    if (reaction == "JA") then
      ability = res.job_abilities[r_arg]
    elseif (reaction == "MA") then
      ability = res.spells[r_arg]
    end
    ready = ability_ready(reaction, ability.recast_id)
  end
  
  -- For now, just see if the ability timer is ready, we can
  -- do more thorough checking (ie: targeting the mob for a WS,
  -- not trying to cast a spell while silenced, etc) later.

  if (ready) then
    -- Check if the condition is satisfied
    if satisfies_condition(subject,condition,c_arg) then
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

refresh_party_status()