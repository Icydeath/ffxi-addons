require 'luau'
res = require('resources')
files = require('files')
packets = require('packets')
require('my_gambits')

_addon = _addon or {}
_addon.name = 'Gambits';
_addon.commands = {'g'};
_addon.author = 'ibm2431';
_addon.version = '0.14.0';


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

DISPEL
DEBUFF

ENEMY: STATUS (PROTECT) -> DISPEL
--]]

-- ==============================================
-- == UTILITY FUNCTIONS
-- ==============================================

-- Determines if we can currently take an action
---------------------------------------------------------------------
function can_act()
  if (can_take_action and gambits_enabled and (status_locked == false)) then
    return true
  else
    return false
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
          return enemies[mob.id]
        end
      end
    end
  end
  return {['casting']=false,['readying']=false,['id']=0,['mob_type']='none',['tagged']=false}
end

-- Returns distance between two points
function get_distance(x1, y1, x2, y2)
  x_diff = x2 - x1
  y_diff = (y2 - y1) * -1
  local distance = math.sqrt((x_diff ^ 2) + (y_diff ^ 2))
  return distance
end

-- Returns our best guess for a person's job type
-- when given their max HP and max MP.
function guess_job_type(mhp, mmp)
  if (mmp <= 800) then
    return 'melee'
  else
    if (mmp <= 1350) then
      if (mmp <= 1000) then
        return 'tank'
      else
        return 'melee_mage'
      end
    else
      return 'mage'
    end
  end
end

-- Refreshes variables when we enter a new zone to
-- adjust for new mob IDs
---------------------------------------------------------------------
function zone_refresh()
  enemies = {}

  mob = {}
  mob.performing = false
  mob.statuses = {}
  
  location_update_loop = coroutine.schedule(update_distances, 5)
  can_take_action = true
  
  process_updated_party_list()
end

-- Initializes the party's status when Gambits is first loaded.
---------------------------------------------------------------------
function first_load()
  local party_info = windower.ffxi.get_party()
  local mob_id = false
  local mob_name = false
  for key,value in pairs(party_info) do
    if (get_pt_party_keys[key]) then
      if (value.mob) then
        mob_id = value.mob.id
        mob_name = value.name
        add_party_entry(mob_id, mob_name)
        
        local mhp, mmp = (value.hp/value.hpp)*100, (value.mp/value.mpp)*100
        local job_type = guess_job_type(mhp, mmp)
        party[mob_id].job_type = job_type
        if (job_type == 'melee_mage') then
          party_jobs['melee'][mob_id] = party[mob_id]
          party_jobs['mage'][mob_id] = party[mob_id]
        else
          party_jobs[job_type][mob_id] = party[mob_id]
        end
      end
    end
  end
  
  process_updated_party_list()
end

-- =======================================================
-- PARTY STATUS FUNCTIONS
-- =======================================================

-- Adds an empty entry for a given ID into the party table.
-- Optionally takes a name to associate that new entry with
-- inside the party_members table.
---------------------------------------------------------------------
function add_party_entry(mob_id, mob_name)
  party[mob_id] = {}
  party_statuses[mob_id] = {}
  party[mob_id].statuses = {}
  
  party[mob_id].id = mob_id
  party[mob_id].job = 0
  party[mob_id].job_type = '???'
  party[mob_id].mob_type = 'party'
  
  party[mob_id].hp = 0
  party[mob_id].hpp = 0
  party[mob_id].mp = 0
  party[mob_id].mpp = 0
  party[mob_id].tp = 0
  
  if (mob_name ~= '_') then
    party_members[mob_id] = mob_name -- Name linked to Curent ID
    party_members[mob_name] = mob_id -- Current ID stored by Name
    party[mob_id].name = mob_name
  end
end

-- Refreshes the party list when a list change triggers
-- an incoming update packet.
---------------------------------------------------------------------
function parse_party_list(data)
  local update_packet = packets.parse('incoming', data)
  local player_id, player_i = 1, 1
  party_members = {}
  party = {}
  party_jobs = {}
  party_jobs['tank'], party_jobs['melee'], party_jobs['ranged'], party_jobs['mage'] = {}, {}, {}, {}
  
  while ((player_id ~= 0) and (player_i <= 6)) do
    player_id = update_packet['ID '.. player_i]
    if (player_id ~= 0) then
      party[player_id] = true
      player_i = player_i + 1
    end
  end
end

-- Triggered on an individualized party member update
-- packet. Fills out the rest of the information for
-- a party member who has a 'true' placeholder in party{}
---------------------------------------------------------------------
function update_party_list(data)
  local update_packet = packets.parse('incoming', data)
  local time = windower.ffxi.get_info().time
  local job_type, hp, hpp, mp, mpp, mhp, mmp  
  local id = update_packet['ID']
  if (party[id]) then
    add_party_entry(id, update_packet['Name'])
    party[id].job = update_packet['Main job']
    if (update_packet['Main job'] ~= 0) then
      job_type = job_types[update_packet['Main job']]
    else
      hp, hpp, mp, mpp = update_packet['HP'], update_packet['HP%'], update_packet['MP'], update_packet['MP%']
      mhp, mmp = (hp/hpp)*100, (mp/mpp)*100
      job_type = guess_job_type(mhp, mmp)
    end
    
    if ((job_type == 'melee') and (update_packet['Sub job'] == 13)) then
      job_type = 'melee_mage' -- Melee/NIN
    end
    
    party[id].job_type = job_type
    if (party[id].job_type == 'melee_mage') then
      party_jobs['melee'][id] = party[id]
      party_jobs['mage'][id] = party[id]
    else
      party_jobs[job_type][id] = party[id]
    end
  end
end

-- Cheap work-around for the way party_size and the party list update
-- packet works. 'Triggered' a half-second after every individual
-- party list update packet, but only works once every Vana'diel minute.
-- This method ensures it's fired after all the party list update
-- packets have gone through.
function process_updated_party_list()
  local time = windower.ffxi.get_info().time
  if (last_party_list_processed_time ~= time) then
    party_locations, party_distances, clusters, distance_to_enemy = get_party_distances()
    refresh_party_status()
    last_party_list_processed_time = time
    updating_party_list = false
  end
end

-- Refreshs stored pt members, hp, mp, and tp. Also
-- rechecks our own buffs/statuses.
---------------------------------------------------------------------
function refresh_party_status()
  local party_info = windower.ffxi.get_party()
  local mob_id = false
  local mob_name = false
  for key,value in pairs(party_info) do
    if (get_pt_party_keys[key]) then
      if (value.mob) then
        mob_id = value.mob.id
        mob_name = value.name
        -- Cut Code Segement 2; Member should always already be in pt
        -- Nevermind, without this, it broke the fuck up in an alliance,
        -- was throwing lots of party[mob_id] and party[my_id] errors look into later.
        if (in_party(mob_id) ~= true) then
          if (party_members[mob_name]) then
            -- Clear the old ID-based array by looking up ID associated
            -- with the party member's name.
            local old_id = party_members[mob_name]
            party_members[old_id] = nil
            party[old_id] = nil
          end
          add_party_entry(mob_id, mob_name)
        end
        -- End segmenet 2.
        if (party[mob_id]) then
          party[mob_id].hp = value.hp
          party[mob_id].hpp = value.hpp
          party[mob_id].mp = value.mp
          party[mob_id].mpp = value.mpp
          party[mob_id].tp = value.tp
          party[mob_id].statuses = party_statuses[mob_id]
        end
      end
    end
  end
  
  -- Process own buffs via accurate get_player().buffs
  local get_player_buffs = windower.ffxi.get_player().buffs
  local my_buffs = {}
  local my_id = player.id
  party[my_id].shadows = 0
  party[my_id].f_moves = 0
  status_locked = false
  for _,value in pairs(get_player_buffs) do
    my_buffs[value] = true
    if ((value == 2) or (value == 7) or (value == 10) or (value == 14) or (value == 28)) then
      status_locked = true
    elseif (value == 66) then
      party[my_id].shadows = 1
    elseif ((value > 380) and (value < 385)) then
      party[my_id].f_moves = value - 380
    elseif ((value > 443) and (value < 447)) then
      party[my_id].shadows = value - 442
    elseif (value == 588) then
      party[my_id].f_moves = 6
    end
  end
  party_statuses[my_id] = my_buffs
  party[my_id].statuses = party_statuses[my_id]
  
  -- Process pet information
  local pet = windower.ffxi.get_mob_by_target('pet')
  if (pet) then
    party[my_id].pet = pet
  else
    party[my_id].pet = false
  end
end

-- Parses a party buff packet and sets status IDs for real players
---------------------------------------------------------------------
function parse_party_buffs(data)
  buff_packet = packets.parse('incoming', data)
  
  local player_id, player_name, player_buff_data, player_buff_bitmask
  local player_i = 1
  
  local buff_i = 0
  local buff_add_value = 0
  local buff_value = 0
  
  player_id = buff_packet["ID ".. player_i]
  player_buff_data = buff_packet["Buffs ".. player_i]
  player_buff_bitmask = string.unpack(buff_packet["Bit Mask ".. player_i],'i')
  
  while ((player_id ~= 0) and (player_i <= 5)) do
    party_statuses[player_id] = {}
    
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
    if (player_i <= 5) then
      player_id = buff_packet["ID ".. player_i]
      player_buff_data = buff_packet["Buffs ".. player_i]
      player_buff_bitmask = string.unpack(buff_packet["Bit Mask ".. player_i],'i')
    end
  end
end

-- Updates the table of member distances from other members
---------------------------------------------------------------------
function get_party_distances()
  local distances, party_locations, clusters, distance_to_enemy = {}, {}, {}, 9999
  local mob = false
  local distance = 9999
  local members_in_cluster = 0
  for key,value in pairs(party) do
    mob = windower.ffxi.get_mob_by_id(key)
    party_locations[key] = {}
    party_locations[key]['x'] = -9999
    party_locations[key]['y'] = -9999
    if (mob) then
      if (mob.valid_target) then
        party_locations[key]['x'] = mob.x
        party_locations[key]['y'] = mob.y
      end
    end
  end
  
  for key,value in pairs(party_locations) do
    distances[key] = {}
    clusters[key] = {}
    members_in_cluster = 0
    for target_key, target_value in pairs(party_locations) do
      distance = get_distance(value['x'], value['y'], target_value['x'], target_value['y'])
      distances[key][target_key] = distance
      if ((value['x'] ~= -9999) and (distance < 10)) then
        members_in_cluster = members_in_cluster + 1
        clusters[key][members_in_cluster + 2] = target_key
      end
    end
    clusters[key][1] = members_in_cluster
    clusters[key][2] = false
  end
  
  local target_mob = get_targetted_enemy()
  if (target_mob.id) then
    if (target_mob.id ~= 0) then
      target_mob = windower.ffxi.get_mob_by_id(target_mob.id)
      local me = windower.ffxi.get_mob_by_id(my_id)
      distance_to_enemy = get_distance(me.x, me.y, target_mob.x, target_mob.y)
    end
  end
  
  return party_locations, distances, clusters, distance_to_enemy
end

function update_distances()
  while true do
    party_locations, party_distances, clusters, distance_to_enemy = get_party_distances()
    coroutine.sleep(5)
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
    party_statuses[target_id][status] = gain_lose
  else
    -- mob was inflicted with status
  end
end


-- ==============================================
-- == COMBAT STATUS FUNCTIONS
-- ==============================================

-- Adds an aggroed mob to the enemies table
---------------------------------------------------------------------
function aggroed_by(id)
  if (enemies[id] == nil) then
    enemies[id] = {}
    enemies[id].id = id
    enemies[id].readying = false
    enemies[id].casting = false
    enemies[id].mob_type = 'enemy'
    enemies[id].tagged = false
  end
end


-- Updates the current skillchain property open on the enemy
---------------------------------------------------------------------
function sc_property(ws, time)
  local time = tostring(time)
  local ws = tonumber(ws)
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

-- Applies a skillchain effect for a mob
---------------------------------------------------------------------
function sc_prop(mob_id, skillchain_id)
  local skillchain = skillchain_names[skillchain_id]
  local time = windower.ffxi.get_info().time
  Enemy_SC_Props[mob_id] = {}
  Enemy_SC_Props[mob_id]['sc_prop'] = skillchain
  Enemy_SC_Props[mob_id]['time'] = time
  coroutine.schedule(function() clear_prop(mob_id, time) end, 9)
end

-- Clears a skillchain effect for a mob, but only if the call is
-- still current. Checks this by checking the time associated with
-- the table entry. If the slept coroutine call has the same time
-- as the entry, then we can clear the call. But if another SC
-- occurred and opened a newer window, the coroutine call will have
-- an older timestamp than the association in the table,
-- and thus, should be ignored. The newer courtine call will proc
-- at a later time to clear this newer window.
---------------------------------------------------------------------
function clear_prop(mob_id, time)
  if (Enemy_SC_Props[mob_id]['time']) then
    if (Enemy_SC_Props[mob_id]['time'] == time) then
      Enemy_SC_Props[mob_id] = {}
    end
  end
end

-- Checks to see if a spell element will MB on a mob_id, returning true or false
---------------------------------------------------------------------
function check_MB_elements(mob_id, element)
  local current_mob_sc_prop = Enemy_SC_Props[mob_id]
  if (current_mob_sc_prop) then
    local current_skillchain = Enemy_SC_Props[mob_id]['sc_prop']
    if (current_skillchain) then
      if (skillchain_MBs[current_skillchain][element]) then
        return true
      end
    end
  end
  return false
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
      if (ability.type == "Scholar") then --Strategems
        if (player.main_job == 'SCH') then
          if (recasts[recast_id] < 48) then
            return true
          end
        elseif (player.sub_job == 'SCH') then
          if (recasts[recast_id] < 120) then
            return true
          end
        end
        return false
      end
      if (party[my_id].tp < ability.tp_cost) then
        return false
      end
    elseif (ability_type == 'MA') then
      recasts = windower.ffxi.get_spell_recasts()
      ability = res.spells[ability_id]
      recast_id = ability.recast_id
      if ((party[my_id].mp < ability.mp_cost) or has_status(my_id,6) or has_status(my_id,29)) then
        return false
      end
    end
    
    return(recasts[recast_id] == 0)
  end
end

-- Given a chain, checks to make sure all abilities
-- in it are ready for use. Stop evaluation when
-- an ability which isn't ready is found.
---------------------------------------------------------------------
function chain_ready(chain)
  local i = 1
  while (chain[i] ~= nil) do
    if (ability_ready(chain[i][1],chain[i][2])) then
      i = i + 1
    else
      return false
    end
  end
  return true
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
  
  local tagging_action = false
  
  -- Process actions taken by self
  if (action.actor_id == my_id) then
    if (action.category == 1) then -- Melee attack
      tagging_action = true
    elseif ((action.category >= 2) and (action.category <= 5)) then
      if (action.category == 4) then
        coroutine.schedule(function()  check_gambit_list() end, action.recast)
      end
      coroutine.schedule(function()  cta(true) end,3)
      if (action.category ~= 5) then
        tagging_action = true
      end
    elseif ((action.category == 6) or (action.category == 14)) then
      cta(false)
      if (action.category == 6) then
        coroutine.schedule(function()
          local recasts = windower.ffxi.get_ability_recasts()
          local recast_id = res.job_abilities[action.param].recast_id
          coroutine.schedule(function() check_gambit_list() end, recasts[recast_id])
        end, 2)
      end
      coroutine.schedule(function()  cta(true) end,3)
      tagging_action = true
    elseif ((action.category >= 7) and (action.category <= 9)) then
      if (action.param == 24931) then -- Initiate
        cta(false)
      elseif (action.param == 28787) then -- Interrupt
        coroutine.schedule(function()  cta(true) end,3)
      end
    end
    
    if (tagging_action) then
      for index,value in pairs(targets) do
        if (enemies[value.id]) then
          enemies[value.id].tagged = true
        end
      end
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
        local add_effect_message = v1.add_effect_message
        
        -- 043 :: <actor> readies <weapon_skill>.
        if ((type == 43) and in_party(actor_id)) then
          Enemy_SC_Props[target_id] = {}
          windower.send_command("@wait 2.5; g scprop ".. v1.param .." ".. windower.ffxi.get_info().time);
        end
        
        -- Skillchain: <skillchain>. <target> takes <number> points of damage.
        if ((add_effect_message >= 288) and (add_effect_message <= 301)) then
          sc_prop(target_id, add_effect_message - 287)
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
    ["TANK"] = function(t_arg) return party_jobs['tank'] end,
    ["MELEE"] = function(t_arg) return party_jobs['melee'] end,
    ["RANGED"] = function(t_arg) return party_jobs['ranged'] end,
    ["MAGE"] = function(t_arg) return party_jobs['mage'] end,
    ["CLUSTER"] = function(t_arg) return clusters end,
    ["ENEMY"] = function(t_arg) return get_targetted_enemy() end
  }
  
  return switch[target](t_arg)
end

--  Runs through the loaded gambit list looking for the
--  highest priority trigger and executes it.
function check_gambit_list()
  local reaction = false
  local satisfying_target = false
  local satisfied_chain, next_chain_action
  local i = 1
  local gambit

  if (can_act()) then
    local gambits, num_gambits = determine_gambits()
    local me = windower.ffxi.get_player()
    if ((engaged_only == false) or (engaged_only and (me.status == 1))) then
      if (chaining) then
        if (current_chain[current_chain_i]) then
          if (current_chain[current_chain_i][1] == "WS") then
            next_chain_action = res.weapon_skills[current_chain[current_chain_i][2]]
          elseif (current_chain[current_chain_i][1] == "JA") then
            next_chain_action  = res.job_abilities[current_chain[current_chain_i][2]]
          elseif (current_chain[current_chain_i][1] == "MA") then
            next_chain_action  = res.spells[current_chain[current_chain_i][2]]
          end
          
          current_chain_i = current_chain_i + 1
          react(next_chain_action, chain_target)
        else
          chaining, current_chain, current_chain_i, chain_target = false, {}, 1, false
          coroutine.schedule(function()  check_gambit_list() end,0.2)
        end
      else
        while ((reaction == false) and (i <= num_gambits)) do
          gambit = gambits[i]
          reaction, satisfying_target, satisfied_chain = check_gambit(gambit[1],gambit[2],gambit[3],gambit[4],gambit[5])
          i = i + 1
        end

        if (reaction ~= false) then
          if (satisfied_chain) then
            chaining = true
            current_chain = reaction
            current_chain_i = 1
            chain_target = satisfying_target
            check_gambit_list()
          else
            react(reaction, satisfying_target)
          end
        end
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
  
  if (reaction == "CHAIN") then
    if (chain_ready(r_arg)) then
      ready = true
    end
  else
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
        return reaction, c_arg, false
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
  end
  
  -- For now, just see if the ability timer is ready, we can
  -- do more thorough checking (ie: targeting the mob for a WS,
  -- not trying to cast a spell while silenced, etc) later.

  if (ready) then
    -- Check if the condition is satisfied
    local satisfied, satisfying_target = false, 0
    if (subject == "CLUSTER") then
      satisfied, satisfying_target = satisfies_condition(subject,condition,c_arg,false,true)
    else
      satisfied, satisfying_target = satisfies_condition(subject,condition,c_arg)
    end
    if (satisfied) then
      if (reaction == "ITEM") then
        return r_arg, "ITEM", false
      elseif (reaction == "CHAIN") then
        return r_arg, satisfying_target, true
      else
        return ability, satisfying_target, false
      end
    end
  end
  
  return false, false, false
end

-- Takes a target descriptor and sees if it is satisfied.
function satisfies_condition(target, condition, c_arg, multiple, cluster)
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
      ["MPP <="] = function(target, c_arg) return (target.mpp <= c_arg) end,
      ["TP >="] = function(target, c_arg) return (target.tp >= c_arg) end,
      ["READYING"] = function(target, c_arg) return (get_targetted_enemy().readying == c_arg) end,
      ["CASTING"] = function(target, c_arg) return (get_targetted_enemy().casting == c_arg) end,
      ["NOT_TAGGED"] = function(target, c_arg) return (get_targetted_enemy().tagged == false) end,
      ["STATUS"] = function(target, c_arg) return (has_status(target.id, c_arg)) end,
      ["NOT_STATUS"] = function(target, c_arg) return (has_status(target.id, c_arg) == false) end,
      ["JA_READY"] = function(target, c_arg) return (ability_ready('JA',c_arg)) end,
      ["MA_READY"] = function(target, c_arg) return (ability_ready('MA',c_arg)) end,
      ["SHADOWS <"] = function(target, c_arg) return (target.shadows < c_arg) end,
      ["MOVES <"] = function(target, c_arg) return (target.moves < c_arg) end,
      ["MOVES >="] = function(target, c_arg) return (target.moves >= c_arg) end,
      ["NO_PET"] = function(target, c_arg) return (target.pet == false) end,
      ["CAN_SC"] = function(target, c_arg) return ((target.tp >= 1000) and (skillchains[c_arg][sc_prop_a] or skillchains[c_arg][sc_prop_b])) end,
      ["CAN_MB"] = function(target, c_arg) return (check_MB_elements(get_targetted_enemy().id,c_arg)) end,
      ["NOT_ENGAGED"] = function(target, c_arg) return (windower.ffxi.get_player().status ~= 1) end,
      ["NOT_ASSISTING"] = function(target, c_arg)
        local to_assist = windower.ffxi.get_mob_by_name(c_arg)
        return ((to_assist.status == 1) and (to_assist.target_index ~= windower.ffxi.get_player().target_index))
      end
    }
    if (cluster) then
      local satisfying_cluster = {0, false, 0}
      local satisfying_cluster_key = 0
      local cluster_member_i, cluster_size, satisfying_members = 3, 0, 0
      for cluster_key, cluster_array in pairs(targets) do
        cluster_size = cluster_array[1]
        if (cluster_size >= 3) then
          cluster_member_i = 3
          satisfying_members = 0
          while (cluster_member_i <= cluster_size + 2) do
            if(switch[condition](party[cluster_array[cluster_member_i]], c_arg)) then
              satisfying_members = satisfying_members + 1
            end
            cluster_member_i = cluster_member_i + 1
          end
        end
        if (satisfying_members >= 3) then
          if (satisfying_members > satisfying_cluster[1]) then
            satisfying_cluster = cluster_array -- New cluster is larger
            satisfying_cluster_key = cluster_key
          elseif (satisfying_members == satisfying_cluster[1]) then
            if (cluster_array[2] == true) then
              if (satisfying_cluster[2] == false) then
                satisfying_cluster = cluster_array -- New cluster has tank
                satisfying_cluster_key = cluster_key
              else
                -- Check to see if target IS the tank
              end
            end
          end
        end
      end
      if (satisfying_cluster_key > 0) then
        return true, satisfying_cluster_key
      end
    else
      if (targets['mob_type']) then
        if (targets['mob_type'] == 'enemy') then
          if(switch[condition](targets, c_arg)) then
            return true, targets['id']
          end
        end
      else
        for k,v in pairs(targets) do
          if (party_locations[v.id]) then
            if (party_locations[v.id]['x'] ~= -9999) then
              if (party_distances[my_id][v.id] <= 20.5) then
                if(switch[condition](v, c_arg)) then
                  if (multiple) then
                    table.insert(satisfying_targets, k)
                    at_least_one_satisfying_target = true
                  else
                    return true, k
                  end
                end
              end
            end
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
    command = "/lockon; @wait 1; input /follow; @wait 1; input /a"
    following_mob = true
  elseif (ability == "ASSIST") then
    command = "/assist ".. target
  elseif (target == "ITEM") then
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
    
    command = ability.prefix .. " \"".. ability.en .."\" ".. macro_target
  end
  
  cta(false)
  
  if ((ability == "ATTACK") or (ability == "ASSIST")) then
    coroutine.schedule(function()  cta(true) end,2)
  end
  
  windower.send_command("@wait ".. to_wait .."; input " .. command);
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

-- Sets can_take_action to true or false
function cta(true_false)
  can_take_action = true_false
  if (true_false) then
    refresh_party_status()
    check_gambit_list()
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
function process_selector(selector, trigger, trigger_arg, gambit_num)
  local valid_self_triggers = S{"STATUS","NOT_STATUS","NOT_ENGAGED","NOT_ASSISTING","TP >=","HPP <=","HPP >","MPP <=","MA_READY","JA_READY","SHADOWS <","MOVES <","MOVES >=","NO_PET","CAN_SC","CAN_MB"}
  local valid_party_triggers = S{"STATUS","NOT_STATUS","TP >=","HPP <=","HPP >","MPP <="}
  local valid_enemy_triggers = S{"STATUS","NOT_STATUS","READYING","CASTING","NOT_TAGGED","HPP <=","HPP >"}
  
  local party_type_selector = ((selector == "PARTY") or (selector == "TANK") or (selector == "MELEE") or 
                              (selector == "RANGED") or (selector == "MAGE") or (selector == "CLUSTER"))
  if ((selector == "SELF") or  party_type_selector or (selector == "ENEMY")) then
    if (((selector == "SELF") and valid_self_triggers[trigger]) or
        (party_type_selector and valid_party_triggers[trigger]) or
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
  local triggers_with_raw_args = S{"HPP <=","HPP >","MPP <=","TP >=","NOT_ENGAGED","NOT_ASSISTING","NOT_TAGGED","SHADOWS <","MOVES <","MOVES >=","NO_PET","CAN_SC","CAN_MB"}
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
function process_reaction(reaction, reaction_arg, gambit_num)
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
  local chain_reaction_arg, final_chain_args = false, {}

  if (reaction == "CHAIN") then
    for _,v in pairs(reaction_arg) do
      chain_reaction_arg = process_reaction(v[1], v[2], gambit_num)
      if (chain_reaction_arg == false) then
        error("Invalid reaction value '".. reaction_arg .."' for Gambit #".. gambit_num ..". Aborting.")
        return false
      else
        table.insert(final_chain_args, {v[1], chain_reaction_arg})
      end
    end
  else
    final_reaction_arg = process_reaction(reaction, reaction_arg, gambit_num)
    if (final_reaction_arg == false) then
      error("Invalid reaction value '".. reaction_arg .."' for Gambit #".. gambit_num ..". Aborting.")
      return false
    end
  end

  if (selector == "AND") then
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
    final_trigger_arg = process_selector(selector, trigger, trigger_arg, gambit_num)
    if (final_trigger_arg == false) then
      error("Invalid trigger value '".. trigger_arg .."' for Gambit #".. gambit_num ..". Aborting.")
      return false
    end
    if (reaction == "CHAIN") then
      final_gambit = {selector, trigger, final_trigger_arg, reaction, final_chain_args}
    else
      final_gambit = {selector, trigger, final_trigger_arg, reaction, final_reaction_arg}
    end
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
    check_gambit_list()
  end
end)

windower.register_event('incoming chunk', function(id, data)
  if (id == 0x029) then -- Action Message Packet
    local action_message = packets.parse('incoming', data)
    if (action_message['Message'] == 6) then -- Mob defeated
      local defeated_id = action_message['Target']
      if (enemies[defeated_id]) then
        enemies[defeated_id] = nil
      end
      windower.ffxi.run(false)
      cta(false)
      coroutine.schedule(function()  cta(true) end,5)
    elseif (unable_to_perform_messages[action_message['Message']]) then
      cta(true)
    elseif (action_message['Message'] == 202) then
      coroutine.schedule(function()  cta(true) end, 1)
    end
  elseif (id == 0x076) then -- Party Buff Packet
    parse_party_buffs(data)
    local to_refresh_time = 0
    if (updating_party_list) then
      to_refresh_time = 1.5
    end
    coroutine.schedule(function()
      refresh_party_status()
      check_gambit_list()
    end,to_refresh_time)
  elseif (id == 0x0DD) then -- Party Member Update Packet
    update_party_list(data)
    coroutine.schedule(function()  process_updated_party_list() end,0.4)
  elseif (id == 0x0C8) then -- Party/Alliance List Update Packet
    updating_party_list = true
    parse_party_list(data)
  end
end)

windower.register_event("incoming text", function(original, modified, orig_mode, mod_mode, blocked)
  if (following_mob) then
    if string.find(string.lower(original), string.lower('follow canceled')) then
      windower.ffxi.run(false)
      followong_mob = false
    end
  end
end)

windower.register_event("zone change", function(new_id, old_id)
  cta(false)
  coroutine.close(location_update_loop)
  coroutine.schedule(function()  zone_refresh() end,15)
end)

windower.register_event('addon command',function (command, ...)
	command = command and command:lower()
	local args = T{...}
  if command == 'scprop' then
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

buffs_by_en, buffs_by_en_keys = require('res/buffs_by_en')
buffs_by_enl, buffs_by_enl_keys = require('res/buffs_by_enl')
spells_by_en, spells_by_en_keys = require('res/spells_by_en')
job_abilities_by_en, job_abilities_by_en_keys = require('res/job_abilities_by_en')
weapon_skills_by_en, weapon_skills_by_en_keys = require('res/weapon_skills_by_en')
monster_abilities_by_en, monster_abilities_by_en_keys = require('res/monster_abilities_by_en')
monster_abilities_by_id = res.monster_abilities
items_by_en, items_by_en_keys = require('res/items_by_en')

-- Find some way of combining the next two tables later.
skillchains = {
  ["Light"] = S{"Fusion","Fragmentation","Light"},
  ["Darkness"] = S{"Gravitation","Distortion","Darkness"},
  ["Gravitation"] = S{"Detonation","Fusion"},
  ["Fragmentation"] = S{"Induration","Gravitation"},
  ["Distortion"] = S{"Transfixion","Fragmentation"},
  ["Fusion"] = S{"Liquefaction","Distortion"},
  ["Compression"] = S{"Induration","Transfixion"},
  ["Liquefaction"] = S{"Impaction","Scission"},
  ["Induration"] = S{"Reverberation"},
  ["Reverberation"] = S{"Transfixion","Scission"},
  ["Transfixion"] = S{"Compression"},
  ["Scission"] = S{"Liquefaction","Detonation"},
  ["Detonation"] = S{"Impaction","Compression","Scission"},
  ["Impaction"] = S{"Reverbation","Induration"}
}
skillchain_names = {"Light","Darkness","Gravitation","Fragmentation","Distortion","Fusion","Compression","Liquefaction","Induration","Reverberation","Transfixion","Scission","Detonation","Impaction"}

skillchain_MBs = {
  ["Light"] = S{"Fire","Light","Lightning","Wind"},
  ["Darkness"] = S{"Darkness","Earth","Ice","Water"},
  ["Gravitation"] = S{"Darkness","Earth"}, 
  ["Fragmentation"] = S{"Lightning","Wind"}, 
  ["Distortion"] = S{"Ice","Water"}, 
  ["Fusion"] = S{"Fire","Light"}, 
  ["Compression"] = S{"Darkness"}, 
  ["Liquefaction"] = S{"Fire"}, 
  ["Induration"] = S{"Ice"}, 
  ["Reverberation"] = S{"Water"},
  ["Transfixion"] = S{"Light"}, 
  ["Scission"] = S{"Earth"}, 
  ["Detonation"] = S{"Wind"}, 
  ["Impaction"] = S{"Lightning"}
}

job_types = {"melee","melee","mage","mage","melee_mage","melee",
             "tank","melee","melee","mage","ranged","melee",
             "melee_mage","melee","mage","melee_mage","ranged",
             "melee","melee","mage","mage","tank"}
get_pt_party_keys = S{"p0","p1","p2","p3","p4","p5"}

unable_to_perform_messages = S{17, 18, 78, 198, 328, 41, 154, 313, 47, 48, 71, 72, 92, 128, 155, 190, 193, 217, 219, 316, 338, 348, 349, 445, 446}

status_locked = false
can_take_action = true
gambits_enabled = true
engaged_only = false

enemies = {}
mob = {}
mob.performing = false
mob.statuses = {}

player = windower.ffxi.get_player()
my_id = player.id
my_name = player.name
party, party_members, party_jobs, party_locations, party_distances, clusters, distance_to_enemy = {}, {}, {}, {}, {}, {}, 9999
party_jobs['tank'], party_jobs['melee'], party_jobs['ranged'], party_jobs['mage'] = {}, {}, {}, {}
party_statuses = {} -- Deliberately separate from party{} because asynchronous update packets
location_update_loop = false
updating_party_list, last_party_list_processed_time = false, false
chaining, current_chain, chain_target, current_chain_i = false, {}, {}, 1

sc_prop_a = false
sc_prop_b = false
ws_time = false
Enemy_SC_Props = {}

default_gambits, num_default_gambits = load_gambits('my_gambits')

tactics = load_tactics()

windower.send_command('bind ^g g toggle')

first_load()
coroutine.schedule(function() zone_refresh() end,2)