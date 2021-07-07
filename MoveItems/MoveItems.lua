_addon.name = 'MoveItems'
_addon.author = 'Ivaar'
_addon.version = '0.0.1.5'
_addon.commands = {'moveitems','mi'}

require('sets')
require('logger')
packets = require('packets')
config = require('config')
res = require('resources')

defaults = {}
defaults.sort = {}
defaults.sort.satchel = true
defaults.sort.sack = true
defaults.sort.case = true
defaults.verbose = true

settings = config.load(defaults)

all_ids = T{}
for item in res.items:it() do
    local name = item.name:lower()
    if not all_ids[name] then
        all_ids[name] = S{}
    end
    local name_log = item.name_log:lower()
    if not all_ids[name_log] then
        all_ids[name_log] = S{}
    end
    all_ids[name]:add(item.id)
    all_ids[name_log]:add(item.id)
end

all_ids.gil = nil

local flatten = function(s)
    return s:reduce(function(s1, s2)
        return s1 + s2
    end, S{})
end

local extract_ids = function(names)
    return flatten(names:map(table.get+{all_ids} .. string.lower))
end

local addremove_commands = T{
    add = 'add',
    a = 'add',
    ['+'] = 'add',
    remove = 'remove',
    r = 'remove',
    ['-'] = 'remove',
}

local enabledisable_commands = T{
    disable = 'disable',
    enable = 'enable',
}

local sort_bags = {[5] = 'satchel', [6] = 'sack', [7] = 'case'}
local folder_path = windower.addon_path .. 'data/' 
local player_name = (windower.ffxi.get_player() or {}).name
local enabled, move, loading, last_sequence

function load_file(name)
    player_name = name
    enabled = S(sort_bags)
    move = T{}

    for bag in enabled:it() do
        move[bag] = S{}
    end

    if name then
        local file_path = folder_path .. name ..'.lua'

        if windower.file_exists(file_path) then
            local file = dofile(file_path)

            for bag, items in pairs(file) do
                if enabled:contains(bag) then
                    move[bag] = extract_ids(S(items))
                end
            end
        end
    end

    put_item = flatten(move)
end

load_file(player_name)

function save_file()
    if not windower.dir_exists(folder_path) then
        windower.create_dir(folder_path)
    end

    local make_file = io.open(folder_path .. '%s.lua':format(player_name), 'w')

    make_file:write('return {\n')

    for items, bag in move:it() do
        make_file:write('    %s = {\n':format(bag))

        for id in items:it() do
            make_file:write('        "%s",\n':format(res.items[id].name))
        end

        make_file:write('    },\n')
    end

    make_file:write('}\n')
    make_file:close()
end

local function space_available(bag_id)
    local bag = windower.ffxi.get_bag_info(bag_id)
    return bag.enabled and (bag.max - bag.count) or 0
end

function check_item(id, index, count)
    for bag_id, bag_name in pairs(sort_bags) do
        if move[bag_name][id] and enabled:contains(bag_name) and space_available(bag_id) > 0 then
            if settings.verbose then
                notice('Moving to %s: %d %s':format(bag_name, count, res.items[id].name))
            end

            windower.ffxi.put_item(bag_id, index, count)
            return
        end
    end
end

function check_inventory()
    for index, item in ipairs(windower.ffxi.get_items('inventory')) do
        if put_item:contains(item.id) and item.status == 0 then
            check_item(item.id, index, item.count)
        end
    end
end

check_inventory()

windower.register_event('incoming chunk',function(id, data)
    if id == 0x00A then
        loading = true
    elseif id == 0x00B then
        loading = true
    elseif id == 0x01D then
        loading = false
    elseif loading then
        return
    elseif id == 0x1E then
        local packet = packets.parse('incoming', data)

        if packet.Bag == 0 and packet.Count ~= 0 and packet.Index ~= 0 and packet.Status == 0 then
            local item_id = windower.ffxi.get_items(packet.Bag, packet.Index).id

            if put_item:contains(item_id) then
                check_item(item_id, packet.Index, packet.Count)
            end
        end
    elseif id == 0x020 then
        local packet = packets.parse('incoming', data)

        if packet.Count == 0 then return end

        if packet.Bag == 0 and put_item:contains(packet.Item) and packet.Status == 0 then
            check_item(packet.Item, packet.Index, packet.Count)
        elseif settings.sort[sort_bags[packet.Bag]] and packet._sequence ~= last_sequence then
            last_sequence = packet._sequence
            packets.inject(packets.new('outgoing', 0x3A, {Bag = packet.Bag}))
        end
    end
end)

windower.register_event('addon command', function(command1, ...)
    command1 = command1 and command1:lower() or 'help'
    local command2 = arg[1] and arg[1]:lower()

    if enabledisable_commands:containskey(command1) then
        command1 = enabledisable_commands[command1]

        if command2 and command2 ~= 'all' then
            arg = S(arg):map(string.lower):filter(table.contains+{sort_bags})
        else
            arg = S(sort_bags)
        end

        if not arg:empty() then
            if command1 == 'enable' then
                enabled = enabled + arg
            else
                enabled = enabled - arg
            end

            notice('[%s] %sd':format(arg:concat(', '), command1))
            return
        end
    end

    if command1 == 'help' then
        notice('mi <satchel/sack/case> <add/remove> <item>')
        notice('mi disable [satchel/sack/case/all], defaults to all bags')
    elseif not move:containskey(command1) then
        error('invalid bag name')
    elseif addremove_commands:containskey(command2) then
        command2 = addremove_commands[command2]
        local term = windower.convert_auto_trans(table.concat(arg, ' ', 2))
        local items = all_ids:key_filter(windower.wc_match-{term})

        if items:empty() then
            error('No items found matching: %s':format(term))
            return
        end

        local names = items:keyset():tostring()
        local ids = flatten(items)

        if command2 == 'add' then
            put_item = put_item + ids
            move[command1] = move[command1] + ids
            notice('Adding to auto-%s list: %s':format(command1, names))
        else
            put_item = put_item - ids
            move[command1] = move[command1] - ids
            notice('Removing from auto-%s list: %s':format(command1, names))
        end

        save_file()
        check_inventory()
    elseif enabledisable_commands:containskey(command2) then
        command2 = enabledisable_commands[command2]

        if command2 == 'enable' then
            enabled:add(command1)
        else
            enabled:remove(command1)
        end

        notice('[%s] %sd':format(command1, command2))
    elseif command2 == 'list' then
        log(command1 .. ':' .. move[command1]:map(table.get-{'name'} .. table.get+{res.items}):tovstring():sub(2,-3))
    end
end)

windower.register_event('login', load_file)