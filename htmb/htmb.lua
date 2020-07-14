_addon.name = 'htmb'
_addon.author = 'Ivaar, modded by Icy'
_addon.version = '1.0.0.2i'
_addon.command = 'htmb'

require('luau')
require('pack')
bit = require('bit')
config = require('config')

default = {}
default.buy_list = {20,} -- key items will be purchased in this order until you are unable to buy more
settings = config.load(default)

htmb_map = {
     [0] = {name = 'Shadow Lord phantom gem',      cost = 10},
     [1] = {name = 'Stellar Fulcrum phantom gem',  cost = 10},
     [2] = {name = 'Celestial Nexus phantom gem',  cost = 10},
     [3] = {name = 'Phantom gem of apathy',        cost = 15},
     [4] = {name = 'Phantom gem of arrogance',     cost = 15},
     [5] = {name = 'Phantom gem of envy',          cost = 15},
     [6] = {name = 'Phantom gem of cowardice',     cost = 15},
     [7] = {name = 'Phantom gem of rage',          cost = 15},
     [8] = {name = 'P. Perpetrator phantom gem',   cost = 20},
     [9] = {name = 'Savage\'s phantom gem',        cost = 10},
    [10] = {name = 'Warrior\'s Path phantom gem',  cost = 10},
    [11] = {name = 'Puppet in Peril phantom gem',  cost = 10},
    [12] = {name = 'Legacy phantom gem',           cost = 10},
    [13] = {name = 'Head wind phantom gem',        cost = 10},
    [14] = {name = 'Avatar phantom gem',           cost = 10},
    [15] = {name = 'Moonlit Path phantom gem',     cost = 10},
    -- page 2
    [16] = {name = 'Waking the Beast phantom gem', cost = 10},
    [17] = {name = 'Waking Dream phantom gem',     cost = 10},
    [18] = {name = 'Feared One phantom gem',       cost = 10},
    [19] = {name = 'Dawn phantom gem',             cost = 10},
    [20] = {name = 'Stygian Pact phantom gem',     cost = 10},
    [21] = {name = 'Champion phantom gem',         cost = 10},
    [22] = {name = 'Divine phantom gem',           cost = 10},
    [23] = {name = 'Maiden phantom gem',           cost = 10},
}

htmb_npcs = {
    [231] = {name = 'Trisvain',       menu_id = 892}, -- Northern San d'Oria (J-7)
    [236] = {name = 'Raving Opossum', menu_id = 429}, -- Port Bastok (J-11)
    [240] = {name = 'Mimble-Pimble',  menu_id = 895}, -- Port Windurst (L-5)
}

menu_options = 0
merit_points = 0

math.has_bit = function(mask, offset)
    return math.floor(mask/2^offset)%2 == 1
end

function get_option_index()
    for x = 1, #settings.buy_list do
        local option = settings.buy_list[x]
        if htmb_map[option] and htmb_map[option].cost <= merit_points and menu_options:has_bit(option) then
            return option
        end
    end
end

function initiate_npc(name)
    local self = windower.ffxi.get_mob_by_target('me')
    local target = windower.ffxi.get_mob_by_name(name)
    if not self or self.status > 0 then return end
    if target and math.sqrt(target.distance) < 6 and target.valid_target and target.is_npc and bit.band(target.spawn_type, 0xDF) == 2 then
        windower.packets.inject_outgoing(0x1A, 'I2H2d2':pack(0xE1A,target.id,target.index,0,0,0))
    end
end

function print_help()
	windower.add_to_chat(170, '== HTMB COMMANDS ==')
	windower.add_to_chat(170, '//htmb - When near one of the KI NPCs, it will buy the KI\'s you have set.')
	windower.add_to_chat(170, '//htmb {list/l} - Prints out the full list of KI\'s you can add to the buy list.')
	windower.add_to_chat(170, '//htmb {list/l} {buy/set} - Prints out your currently set buy list.')
	windower.add_to_chat(170, '//htmb {add/a} {#} - adds the given KI # to the buy list.')
	windower.add_to_chat(170, '//htmb {remove/r} {#} - removes the KI # from the buy list.')
	--windower.add_to_chat(170, '')
end

function print_buylist()
	windower.add_to_chat(100, '==CURRENT BUY LIST==')
	for key,val in ipairs(settings.buy_list) do
		windower.add_to_chat(100, val..' : '..htmb_map[val].name)
	end
end

function print_options()
	windower.add_to_chat(200, '==OPTIONS==')
	for key,val in ipairs(htmb_map) do
		windower.add_to_chat(200, key..' : '..val.name)
	end
end

windower.register_event('incoming chunk', function(id, data, modified, injected, blocked)
    if id == 0x034 then
        local zone_id, menu_id = data:unpack('H2', 43)
        if htmb_npcs[zone_id] and menu_id == htmb_npcs[zone_id].menu_id then
            menu_options, merit_points = data:unpack('I2', 13)
            windower.send_command('wait 2;setkey escape;wait .5;setkey escape up;')
        end
    end
end)

windower.register_event('outgoing chunk', function(id, data, modified, injected, blocked)
    if id == 0x05B then
        local zone_id, menu_id = data:unpack('H2', 17)
        if htmb_npcs[zone_id] and menu_id == htmb_npcs[zone_id].menu_id and data:byte(15) == 0 then
            local new_option = get_option_index()
            if data:unpack('I', 9) == 0x40000000 and new_option then
                initiate_npc(htmb_npcs[zone_id].name)
                return data:sub(1,8)..string.char(0x02,new_option,0,0)..data:sub(13)
            end
        end
    end
end)

windower.register_event('addon command', function(...)
	local commands = {...}
	if commands[1] then
		commands[1] = commands[1]:lower()
		
		if tonumber(commands[2]) then 
			if commands[1] == 'add' or commands[1] == 'a' then
				local has_item = false
				for key,val in ipairs(settings.buy_list) do
					if val == tonumber(commands[2]) then
						has_item = true
					end
				end
				if not has_item then
					table.insert(settings.buy_list, tonumber(commands[2]))
					settings:save()
					windower.add_to_chat(100, 'HTMB: Added "' .. htmb_map[tonumber(commands[2])].name .. '"')
				end
			elseif commands[1] == 'remove' or commands[1] == 'r' then
				local r_key
				for key,val in ipairs(settings.buy_list) do
					if val == tonumber(commands[2]) then
						r_key = key
					end
				end
				if r_key then
					settings.buy_list[r_key] = nil
					settings:save()
					windower.add_to_chat(100, 'HTMB: Removed "' .. htmb_map[tonumber(commands[2])].name .. '"')
				end
			end
			
		elseif commands[1] == 'help' or commands[1] == 'h' then
			print_help()
			
		elseif commands[1] == 'list' or commands[1] == 'l' then
			if commands[2] and commands[2] == 'set' or commands[2] == 'buy' then
				print_buylist()
			else
				print_options()
			end
		end
	else
		local zone = windower.ffxi.get_info().zone
		if htmb_npcs[zone] then
			initiate_npc(htmb_npcs[zone].name)
		end
	end
end)

windower.register_event('load', function()
    if windower.ffxi.get_info().logged_in then
        print_help()
		print_buylist()
    end
end)