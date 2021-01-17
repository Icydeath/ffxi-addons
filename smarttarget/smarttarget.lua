_addon.version = '0.0.1'
_addon.name = 'smarttarget'
_addon.author = 'Anonymous'
_addon.commands = {'smarttarget','smrt'}

local packets = require('packets')

local status = 0
local zone = 0
local target_id = nil
local desired_target = nil
local active = true
local statues_first = false
local recently_departed = nil
local radians_45degrees = math.pi / 4;
local max_distance = 25

local blacklist = S{}
local statues = S{"Impish Statue","Corporal Tombstone","Lithicthrower Image","Incarnation Idol","Goblin Replica","Goblin Statue"}

function is_mob_claimable(mob, player_mob, party)
    if mob.valid_target and mob.is_npc and not mob.charmed and not mob.in_party and not mob.in_alliance and mob.spawn_type == 16 and math.sqrt(mob.distance) <= max_distance then
        if not mob.claim_id or mob.claim_id < 1 then
            return true
        elseif mob.claim_id == player_mob.id then
            return true
        else
            for _,v in pairs(party) do
                if mob.claim_id == v then
                    return true
                end
            end
            return false
        end
    else
        return false
    end
end

function calculate_target_type_rating(mob)
    if recently_departed and mob.id == recently_departed then
        return nil
    end

    if not string.match(mob.name, "Luopan") and (string.match(mob.name, "'s") or string.match(mob.name, "???")) then
        return nil
    end

    if blacklist:contains(mob.name) then
        return nil
    end

    if statues:contains(mob.name) then
        if statues_first then
            return 0
        else
            return 8
        end
    end

    if string.match(mob.name, "Operative") or string.match(mob.name, "Shinobi") or string.match(mob.name, "Shadowstalker") or string.match(mob.name, "Spy") or string.match(mob.name, "Ninja") or string.match(mob.name, "Hitman") then
        return 10
    end

    if string.match(mob.name, "Animist") or string.match(mob.name, "Tamer") or string.match(mob.name, "Harnesser") or string.match(mob.name, "Empath") or string.match(mob.name, "Beastmaster") or string.match(mob.name, "Pathfinder") then
        return 9
    end

    if string.match(mob.name, "Commander") or string.match(mob.name, "Leader") then
        return 7
    end

    if string.match(mob.name, "Circle") then
        return 3
    end

    if mob.name == "Aurix" then
        return 4
    end

    return 5
end

function table_val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table_tostring( v ) or
      tostring( v )
  end
end

function table_key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table_val_to_str( k ) .. "]"
  end
end

function table_tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table_val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table_key_to_str( k ) .. "=" .. table_val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end

function calculate_target_rating(mob, player_mob, party, not_aggro_okay)
    --if mob.id == 17547320 then
    --    add_chat(table_tostring(mob))
    --end

    if not is_mob_claimable(mob, player_mob, party) then
        return nil
    end

    local aggro_rating = 0

    if mob.status ~= 1 then
        --add_chat('Mob '..mob.name..' ('..mob.id..') not aggro, status '..mob.status)
        if not not_aggro_okay then
            return nil
        else
            aggro_rating = 1
        end
    end

    local type_rating = calculate_target_type_rating(mob)

    if not type_rating then
        --add_chat('Mob '..mob.name..' ('..mob.id..') blacklisted')
        return nil
    end

    local distance_rating = math.sqrt(mob.distance)

    if distance_rating <= 5 then
        local angle = math.atan2((mob.y - player_mob.y), (mob.x - player_mob.x)) * -1
        if angle < 0 then
            angle = angle + 2*math.pi
        end
        local diff = math.abs(angle-player_mob.facing)
        if diff > math.pi then
            diff = diff - math.pi
        end
        if diff < radians_45degrees then
            distance_rating = 0
        else
            distance_rating = 1
        end
    end

    --add_chat('Rated '..mob.name..' ('..mob.id..') at '..(aggro_rating * 10000 + type_rating * 100 + distance_rating))

    return aggro_rating * 10000 + type_rating * 100 + distance_rating
end

local party_member_names = {"p0","p1","p2","p3","p4","p5","a10","a11","a12","a13","a14","a15","a20","a21","a22","a23","a24","a25"}

function get_party()
    local party_table = windower.ffxi.get_party()
    local party = {}

    for _,v in pairs(party_member_names) do
        if party_table and party_table[v] and party_table[v].mob and party_table[v].mob.id then
            party[v] = party_table[v].mob.id
        end
    end

    return party
end

function find_mob(player_mob, current_target_id)
    local party = get_party()
    local mobs = windower.ffxi.get_mob_array()
    local selected_mob = nil
    local selected_target_rating = nil
    local target_rating = nil

    add_chat('Finding mob for player with default '..(current_target_id or 0))

    if current_target_id ~= nil then
        for _,mob in pairs(mobs) do
            if mob.id == current_target_id then
                target_rating = calculate_target_rating(mob, player_mob, party, 1)
                if target_rating ~= nil then
                    add_chat('Found default mob '..mob.name..' ('..mob.id..') rating '..target_rating)
                    selected_mob = mob
                    selected_target_rating = target_rating
                end
                break
            end
        end
    end

    for _,mob in pairs(mobs) do
        target_rating = calculate_target_rating(mob, player_mob, party)
        if target_rating ~= nil then
            if selected_target_rating == nil or target_rating < selected_target_rating then
                add_chat('Found better mob '..mob.name..' ('..mob.id..') rating '..target_rating)
                selected_mob = mob
                selected_target_rating = target_rating
            end
        end
    end

    return selected_mob
end

function add_chat(s)
    windower.add_to_chat(207, s)
end

function smarttarget_command(...)
    local args = {...}

    if not args[1] then
        active = true
        do_target()
        return
    end

    if args[1] == 'on' then
        active = true
        local player = windower.ffxi.get_player()
        if player ~= nil then
            if player.status == 1 then
                player.status = 1
            else
                player.status = 0
            end
        else
            player.status = 0
        end
        target_id = nil
        desired_target = nil
        recently_departed = nil
    elseif args[1] == 'off' then
        active = false
        status = 0
        target_id = nil
        desired_target = nil
        recently_departed = nil
        return
    elseif string.match(args[1], "stat") then
        if not args[2] or args[2] == 'toggle' then
            statues_first = not statues_first
        elseif args[2] == 'first' then
            statues_first = true
        else
            statues_first = false
        end
        if statues_first then
            add_chat('Smart Target: Statues FIRST')
        else
            add_chat('Smart Target: Statues LATER')
        end
    else
        add_chat([[
smart target Commands
//smrt  -- Engage
//smrt on  -- Activate smart auto-targeting
//smrt off  -- Deactivate smart auto-targeting
//smrt stat  -- Toggle statues first/later
]])
        return
    end
end

function facemob(player_mob, mob)
    if not mob then
        return
    end
    if not player_mob then
        return
    end
    windower.ffxi.turn(math.atan2((mob.y - player_mob.y), (mob.x - player_mob.x)) * -1)
end

function disengage_player(player_mob)
    if status == 0 then
        return
    end

    status = 0
    target_id = nil

    if not player_mob then
        return
    end
    
    local p = packets.new('outgoing', 0x01A, {
        ["Target"] = player_mob.id,
        ["Target Index"] = player_mob.index,
        ["Category"] = 0x04 -- Disengage
    })

    packets.inject(p)
end

function engage_player(player_mob, mob)
    if not mob then
        return
    end

    add_chat('Engaging '..mob.name..' ('..mob.id..')')

    local p = packets.new('outgoing', 0x01A, {
        ["Target"] = mob.id,
        ["Target Index"] = mob.index,
        ["Category"] = 0x02 -- Engage Monster
    })

    packets.inject(p)

    status = 2

    facemob(player_mob, mob)
end

function switch_player(player_mob, mob)
    if not mob then
        return
    end

    add_chat('Switching to '..mob.name..' ('..mob.id..')')

    local p = packets.new('outgoing', 0x01A, {
        ["Target"] = mob.id,
        ["Target Index"] = mob.index,
        ["Category"] = 0x0F -- Switch Target
    })

    packets.inject(p)

    status = 2

    facemob(player_mob, mob)
end

function do_target(current_target_id, engage)
    if not active then
        return
    end
    if current_target_id and desired_target and current_target_id == desired_target.id and not engage then
        desired_target = nil
        recently_departed = nil
        return
    end

    --add_chat('Doing target routine with default '..(current_target_id or 0)..' and engage '..(engage or 0))

    local player_mob = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)

    if not player_mob then
        add_chat('No player mob found')
        return
    end

    --add_chat('Finding mob')

    local mob = find_mob(player_mob, current_target_id)
    if not mob then
        add_chat('No mob found')
        desired_target = nil
        recently_departed = nil
        if not engage then
            disengage_player(player_mob)
        end
        return
    end

    desired_target = mob

    if status == 0 or engage ~= nil then
        engage_player(player_mob, mob)
    else
        switch_player(player_mob, mob)
    end
end

function mob_died(id, index)
    if target_id == id or (desired_target and desired_target.id == id) then
        target_id = nil
        desired_target = nil
        if status ~= 0 then
            recently_departed = id
            status = 2
            do_target()
        end
    end
end

function smarttarget_outgoing(id, original, modified, injected, blocked)
    if not active then
        return
    end
    if blocked then
        return
    end
    if injected then
        return
    end
    if id == 0x01A then -- Player action
        local p = packets.parse('outgoing', original)
        if p.Category == 0x02 then -- Engage
            status = 1
            do_target(p.Target, 1)
            blocked = true
            return blocked
        elseif p.Category == 0x04 then -- Disengage
            status = 0
        end
    end
end

function smarttarget_incoming(id, original, modified, injected, blocked)
    if not active then
        return
    end
    if blocked then
        return
    end
    if injected then
        return
    end
    if id == 0x058 then -- Switch target
        local p = packets.parse('incoming', original)
        target_id = p.Target
        status = 1
        do_target(p.Target)
    elseif id == 0x02D then -- Monster kill
        local p = packets.parse('incoming', original)
        mob_died(p.Target)
    elseif id == 0x00E then -- NPC update
        local p = packets.parse('incoming', original)
        if (math.floor(p.Mask / 0x20) % 2) ~= 0 then
            mob_died(p.NPC, p.Index)
        elseif (math.floor(p.Mask / 0x04) % 2) ~= 0 then
            if p['HP %'] == 0 then
                mob_died(p.NPC, p.Index)
            end
        end
    end
end

function smarttarget_zone(new_id, old_id)
    status = 0
    desired_target = nil
    recently_departed = nil
    zone = new_id
end

windower.register_event('addon command', smarttarget_command)
windower.register_event('incoming chunk', smarttarget_incoming)
windower.register_event('outgoing chunk', smarttarget_outgoing)
windower.register_event('zone change', smarttarget_zone)
