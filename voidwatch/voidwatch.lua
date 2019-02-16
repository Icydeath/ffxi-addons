_addon.name     = 'voidwatch'
_addon.author   = 'Mojo'
_addon.version  = '1.20150930'
_addon.commands = {'vw'}

require('logger')
require('coroutine')
packets = require('packets')
res = require('resources')

local handlers = {}
local choice = {}
local conditions = {
    receive = false,
    box = false,
    rift = false,
    running = false,
    escape = false,
    trade = true,
    received = false,
}

local bags = {
    'inventory',
    'safe',
    'safe2',
    'storage',
    'locker',
    'satchel',
    'sack',
    'case',
    'wardrobe',
    'wardrobe2',
    'wardrobe3',
    'wardrobe4',
}

local pulse_items = {
    [18457] = 'Murasamemaru',
    [18542] = 'Aytanri',
    [18904] = 'Ephemeron',
    [19144] = 'Coruscanti',
    [19145] = 'Asteria',
    [19174] = 'Borealis',
    [19794] = 'Delphinius',
}

local cells = {
    ['Cobalt Cell'] = 3434,
    ['Rubicund Cell'] = 3435,
    ['Phase Displacer'] = 3853,
}

local materials = {
}

local function escape()
    conditions['escape'] = true
    coroutine.sleep(1)
    while conditions['escape'] do
        log('escaping')
        windower.send_command('setkey escape down')
        coroutine.sleep(.2)
        windower.send_command('setkey escape up')
        coroutine.sleep(1)
    end
end

local function leader()
    local self = windower.ffxi.get_player()
    local party = windower.ffxi.get_party()
    return (party.alliance_leader == self.id) or ((party.party1_leader == self.id) and (not party.alliance_leader)) or (not party.party1_leader)
end

local function calculate_time_offset()
    local self = windower.ffxi.get_player().name
    local members = {}
    for k, v in pairs(windower.ffxi.get_party()) do
        if type(v) == 'table' then
            members[#members + 1] = v.name
        end
    end
    table.sort(members)
    for k, v in pairs(members) do
        if v == self then
            return (k - 1) * .4
        end
    end
end

local function get_mob_by_name(name)
    local mobs = windower.ffxi.get_mob_array()
    for i, mob in pairs(mobs) do
        if (mob.name == name) and (math.sqrt(mob.distance) < 6) then
            return mob
        end
    end
end

local function poke_thing(thing)
    local npc = get_mob_by_name(thing)
    if npc then
        local p = packets.new('outgoing', 0x1a, {
            ['Target'] = npc.id,
            ['Target Index'] = npc.index,
        })
        packets.inject(p)
    end
end

local function poke_rift()
    conditions['rift'] = true
    while conditions['rift'] do
        log('poke rift')
        poke_thing('Planar Rift')
        coroutine.sleep(4)
    end
end

local function poke_box()
    --conditions['box'] = true
    while conditions['box'] do
        log('poke box')
        poke_thing('Riftworn Pyxis')
        coroutine.sleep(4)
    end
end

local function trade_cells()
    log('trade cells')
    local npc = get_mob_by_name('Planar Rift')
    if npc then
        local trade = packets.new('outgoing', 0x36, {
            ['Target'] = npc.id,
            ['Target Index'] = npc.index,
        })
        local remaining = {
            cobalt = 1,
            rubicund = 1,
            phase = 5,
        }
        local idx = 1
        local n = 0
        local inventory = windower.ffxi.get_items(0)
        for index = 1, inventory.max do
            if (remaining.cobalt > 0) and (inventory[index].id == cells['Cobalt Cell']) then
                trade['Item Index %d':format(idx)] = index
                trade['Item Count %d':format(idx)] = 1
                idx = idx + 1
                remaining.cobalt = 0
                n = n + 1
            elseif (remaining.rubicund > 0) and (inventory[index].id == cells['Rubicund Cell']) then
                trade['Item Index %d':format(idx)] = index
                trade['Item Count %d':format(idx)] = 1
                idx = idx + 1
                remaining.rubicund = 0
                n = n + 1
            elseif (remaining.phase > 0) and (inventory[index].id == cells['Phase Displacer']) then
                local count = 0
                if (inventory[index].count >= remaining.phase) then
                    count = remaining.phase
                else
                    count = inventory[index].count
                end
                trade['Item Index %d':format(idx)] = index
                trade['Item Count %d':format(idx)] = count
                idx = idx + 1
                remaining.phase = remaining.phase - count
                n = n + count
            end
        end
        trade['Number of Items'] = n
        conditions['trade'] = false
        packets.inject(trade)
        if leader() and (remaining.phase == 0) then
            coroutine.schedule(poke_rift, 2)
        end
    end
end

local function observe_box_spawn(id, data)
    if (id == 0xe) and conditions['running'] then
        local p = packets.parse('incoming', data)
        local mob = windower.ffxi.get_mob_by_id(p['NPC'])
        if not mob then elseif (mob.name == 'Riftworn Pyxis') then
            if (p['_unknown2'] == 768) and (not conditions['box']) and (not conditions['trade']) then
                log('box spawn on 0xe')
                log('time offset %f':format(calculate_time_offset()))
                conditions['box'] = true
                coroutine.schedule(poke_box, calculate_time_offset())
            elseif p['_unknown2'] == 770 then
                log('box despawn on 0xe')
                conditions['trade'] = true
                conditions['box'] = false
            end
        end
    end
    if (id == 0x38) and conditions['running'] then
        local p = packets.parse('incoming', data)
        local mob = windower.ffxi.get_mob_by_id(p['Mob'])
        if not mob then elseif (mob.name == 'Riftworn Pyxis') then
            if (p['Type'] == 'deru') and (not conditions['box']) and (not conditions['trade']) then
                log('box spawn 0x38')
                log('time offset %f':format(calculate_time_offset()))
                conditions['box'] = true
                coroutine.schedule(poke_box, calculate_time_offset())
            elseif p['Type'] == 'kesu' then
                log('box despawn on 0x38')
                conditions['trade'] = true
                conditions['box'] = false
            end
        end
    end
end

local function observe_rift_spawn(id, data)
    if (id == 0xe) and conditions['running'] and conditions['trade'] then
        local p = packets.parse('incoming', data)
        local npc = windower.ffxi.get_mob_by_id(p['NPC'])
        if not npc then elseif (npc.name == 'Planar Rift') then
            log('rift spawn')
            coroutine.schedule(trade_cells, 1)
        end
    end
end

local function start_fight(id, data)
    if (id == 0x5b) and conditions['rift'] then
        log('start fight')
        local p = packets.parse('outgoing', data)
        p['Option Index'] = 0x51
        p['_unknown1'] = 0
        conditions['rift'] = false
        conditions['escape'] = false
        return packets.build(p)
    end
end

local function no_longer_eligible(id, data)
    if (id == 0x36) and conditions['box'] then
        local p = packets.parse('incoming', data)
        if (p['Message ID'] == 10876) or (p['Message ID'] == 10875) then
            conditions['trade'] = true
            conditions['box'] = false
        end
    end
end

local function obtain_item(id, data)
    if (id == 0x5b) and conditions['box'] then
        log('obtain item')
        local p = packets.parse('outgoing', data)
        p['Option Index'] = choice.option
        if pulse_items[choice.item] then
            p['_unknown1'] = 1
        else
            p['_unknown1'] = 0
        end
        conditions['escape'] = false
        return packets.build(p)
    end
end

local function examine_rift(id, data)
    if (id == 0x34) and conditions['rift'] then
        coroutine.schedule(escape, 0)
    end
end

local function is_item_rare(id)
    if res.items[id].flags['Rare'] then
        return true
    end
    return false
end

local function has_rare_item(id)
    local items = windower.ffxi.get_items()
    log("Searching for rare item %s":format(res.items[id].en))
    for k, v in pairs(bags) do
        for index = 1, items["max_%s":format(v)] do
            if items[v][index].id == id then
                return true
            end
        end
    end
    return false
end

local function examine_box(id, data)
    if (id == 0x34) and conditions['box'] then
        local p = packets.parse('incoming', data)
        local count = 0
        local rare = false
        choice = {}
        for i = 1, 8 do
            local item = p['Menu Parameters']:unpack('I', 1 + (i - 1)*4)
            if not (item == 0) then
                if pulse_items[item] then
                    choice.option = i
                    choice.item = item
                end
                if is_item_rare(item) and has_rare_item(item) then
                    rare = true
                end
                count = count + 1
            end
        end
        if not choice.option then
            if (count == 1) and rare then
                choice.option = 9
            else
                choice.option = 10
            end
        end
        coroutine.schedule(escape, 0)
    end
end

local function start()
    conditions['running'] = true
    trade_cells()
end

local function stop()
    conditions['running'] = false
end

handlers['start'] = start
handlers['stop'] = stop

local function handle_command(...)
    local cmd  = (...) and (...):lower()
    local args = {select(2, ...)}
    if handlers[cmd] then
        local msg = handlers[cmd](unpack(args))
        if msg then
            error(msg)
        end
    else
        error("unknown command %s":format(cmd))
    end
end

windower.register_event('addon command', handle_command)
windower.register_event('outgoing chunk', obtain_item)
windower.register_event('incoming chunk', examine_box)
windower.register_event('outgoing chunk', start_fight)
windower.register_event('incoming chunk', examine_rift)
windower.register_event('incoming chunk', observe_box_spawn)
windower.register_event('incoming chunk', observe_rift_spawn)
windower.register_event('incoming chunk', no_longer_eligible)