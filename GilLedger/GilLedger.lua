_addon.name = 'GilLedger'
_addon.author = 'Dean James (Xurion of Bismarck)'
_addon.version = '1.0.0'
_addon.commands = {'gilledger', 'ledger'}

packets = require('packets')
config = require('config')

defaults = {}
settings = config.load(defaults)
config.save(settings)

item_assign_packet_id = 0x01F
item_updates_packet_id = 0x020
gil_item_id = 65535

function comma_value(n) --credit http://richard.warburton.it
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function uc_word(word)
	return word:gsub("^%l", string.upper)
end

windower.register_event('incoming chunk', function(id, packet)
	if id == item_assign_packet_id or id == item_updates_packet_id then
		local parsed = packets.parse('incoming', packet)
		if parsed.Item == gil_item_id then
			local character_name = windower.ffxi.get_player().name:lower()
			settings[character_name] = parsed.Count
			config.save(settings, 'all')
		end
	end
end)

windower.register_event('addon command', function()
	local total_gil = 0
	for character, gil in pairs(settings) do
		total_gil = total_gil + gil
		windower.add_to_chat(8, uc_word(character) .. ': ' .. comma_value(gil) .. 'g')
	end
	windower.add_to_chat(8, 'Total: ' .. comma_value(total_gil) .. 'g')
end)
