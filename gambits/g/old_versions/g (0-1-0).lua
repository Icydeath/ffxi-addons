require 'luau'

_addon = _addon or {}
_addon.name = 'g';
_addon.commands = {'g'};
_addon.author = 'ibm2431';
_addon.version = 0.1;

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
my_id = windower.ffxi.get_player().id
party = {}
party_members = {}

party_hp = {}
party_mhp = {}
party_status = {}

can_take_action = true
mob_performing = false

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
        party[member_name].statuses = {}
        party[member_name].hp = value.hp
        party[member_name].hpp = value.hpp
        party[member_name].mp = value.mp
        party[member_name].mpp = value.mpp
        party[member_name].tp = value.tp
      end
    end
  end
end

function in_party(id)
  id = tostring(id)
  if (party_members[id]) then
    return true
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
          mob_performing = tonumber(action['targets'][1]['actions'][1]['param']) - 256
        elseif (action.category) == 8 then
          mob_performing = tonumber(action['targets'][1]['actions'][1]['param'])
        end
      end
    end
  end
  
  return effects_us
end

--  Runs through the loaded gambit list looking for the
--  highest priority trigger and executes it.
function check_gambit_list()
  reaction = false
  if (party['Hanatori'].tp >= 1000) then
    reaction = "/ws \"Rudra's Storm\" <t>"
  elseif (mob_performing == 2696) then
    reaction = "/ja \"Violent Flourish\" <t>"
    mob_performing = false
  end
  
  if (reaction ~= false) then
    can_take_action = false
    react(reaction)
  end
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