--[[
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org/>
]]

_addon.name = 'Crystal Trader - Deprecated'
_addon.author = 'Valok@Asura'
_addon.version = '1.1.3'
_addon.command = 'ctr'

exampleOnly = false
textSkipTimer = 1

windower.register_event('addon command', function(...)
	-- Table of the elemental crystals/clusters, their itemIDs, quantities, and stack count in the player inventory
	local crystalIDs = {
		{4096, 'fire crystal', 0, 0},
		{4097, 'ice crystal', 0, 0},
		{4098, 'wind crystal', 0, 0},
		{4099, 'earth crystal', 0, 0},
		{4100, 'lightning crystal', 0, 0},
		{4101, 'water crystal', 0, 0},
		{4102, 'light crystal', 0, 0},
		{4103, 'dark crystal', 0, 0},
		{4104, 'fire cluster', 0, 0},
		{4105, 'ice cluster', 0, 0},
		{4106, 'wind cluster', 0, 0},
		{4107, 'earth cluster', 0, 0},
		{4108, 'lightning cluster', 0, 0},
		{4109, 'water cluster', 0, 0},
		{4110, 'light cluster', 0, 0},
		{4111, 'dark cluster', 0, 0},
	}
	
	local sealIDs = {
		{1126, "beastmen's seal", 0, 0},
		{1127, "kindred's seal", 0, 0},
		{2955, "kindred's crest", 0, 0},
		{2956, "high kindred's crest", 0, 0},
		{2957, "sacred kindred's crest", 0, 0},
	}
	
	local moatCarpIDs = {
		{4401, 'moat carp', 0, 0},
	}
	
	local copperVoucherIDs = {
		{8711, 'copper voucher', 0, 0},
	}
	
	local idTable = {}
	local tableType = ''
	local stackSize = 12
	local target = windower.ffxi.get_mob_by_target('t')
	
	if not target then
		print('CrystalTrader: No target selected')
		return
	end
	
	if target.name == 'Shami' then
		local zone = windower.ffxi.get_info()['zone']
		if zone == 246 then
			idTable = sealIDs
			tableType = 'Seals'
		else
			print('CrystalTrader: Must target Shami in Port Jeuno')
			return
		end
	elseif target.name == 'Ephemeral Moogle' or target.name == 'Waypoint' then
		idTable = crystalIDs
		tableType = 'Crystals'
	elseif target.name == 'Joulet' or target.name == 'Gallijaux' then
		idTable = moatCarpIDs
		tableType = 'Moat Carp'
	elseif target.name == 'Isakoth' or target.name == 'Rolandienne' or target.name == 'Fhelm Jobeizat' or target.name == 'Eternal Flame' then
		idTable = copperVoucherIDs
		tableType = 'Copper Vouchers'
	else
		print('CrystalTrader: Invalid Target')
		return
	end
	
	-- Read the player inventory
	local inventory = windower.ffxi.get_items(0)
	
	if not inventory then
		print('CrystalTrader: Unable to read inventory')
		return
	end
	
	-- Scan the inventory for each type of crystal and cluster
	for i = 1, #idTable do
		for k, v in ipairs(inventory) do
			if v.id == idTable[i][1] then
				idTable[i][3] = idTable[i][3] + v.count -- Updates the total number of items of each type
				idTable[i][4] = idTable[i][4] + 1 -- Updates the total number of stacks of each type
			end
		end
	end
	
	local numTrades = 0 -- Number of times //ctr needs to be run to empty the player inventory
	local availableTradeSlots = 8

	if tableType == 'Crystals' then
		for i = 1, 8 do
			if idTable[i][4] > 0 or idTable[i + 8][4] > 0 then
				numTrades = numTrades + math.ceil((idTable[i][4] + idTable[i + 8][4]) / 8)
			end
		end
	elseif tableType == 'Seals' or tableType == 'Moat Carp' or tableType == 'Copper Vouchers' then
		for i = 1, #idTable do
			if idTable[i][4] > 0 then
				numTrades = numTrades + math.ceil(idTable[i][4] / 8)
			end
		end
	end

	-- Prepare and send command through TradeNPC if there are trades to be made
	if numTrades > 0 then
		local tradeString = ''
		availableTradeSlots = 8
		--numTrades = numTrades - 1
		
		if tableType == 'Crystals' then
			stackSize = 12
			
			for i = 1, 8 do
				-- Build the string that will be used as the command
				tradeString = '//tradenpc '
				availableTradeSlots = 8
				
				if idTable[i][3] > 0 then
					tradeString = tradeString..math.min(availableTradeSlots * stackSize, idTable[i][3])..' "'..idTable[i][2]..'"'
					availableTradeSlots = math.max(0, availableTradeSlots - idTable[i][4])
				end
				
				if availableTradeSlots > 0 and idTable[i + 8][3] > 0 then
					tradeString = tradeString..' '..math.min(availableTradeSlots * stackSize, idTable[i + 8][3])..' "'..idTable[i + 8][2]..'"'
				end
				
				if tradeString ~= '//tradenpc ' then
					if exampleOnly then
						print(tradeString)
						windower.add_to_chat(8, 'Crystal Trader: '..(numTrades - 1)..' trades remaining')
						break
					else
						windower.send_command('input '..tradeString)
						windower.add_to_chat(8, 'Crystal Trader: '..(numTrades - 1)..' trades remaining')
						textSkipTimer = os.time()
						break
					end
				end
			end
		elseif tableType == 'Seals' or tableType == 'Moat Carp' or tableType == 'Copper Vouchers' then
			if tableType == 'Seals' or tableType == 'Copper Vouchers' then
				stackSize = 99
			elseif tableType == 'Moat Carp' then
				stackSize = 12
			end
			
			for i = 1, #idTable do
				tradeString = '//tradenpc '
				availableTradeSlots = 8
				
				if idTable[i][3] > 0 then
					availableTradeSlots = math.max(1, availableTradeSlots - idTable[i][4])
					tradeString = tradeString..math.min(availableTradeSlots * stackSize, idTable[i][3])..' "'..idTable[i][2]..'"'
				end
				
				if tradeString ~= '//tradenpc ' then
					if exampleOnly then
						print(tradeString)
						windower.add_to_chat(8, 'Crystal Trader: '..(numTrades - 1)..' trades remaining')
						break
					else
						windower.send_command('input '..tradeString)
						windower.add_to_chat(8, 'Crystal Trader: '..(numTrades - 1)..' trades remaining')
						textSkipTimer = os.time()
						break
					end
				end
			end
		end
	else
		windower.add_to_chat(8, "Crystal Trader - No "..tableType.." in inventory")
	end
end)
 
windower.register_event('incoming text', function(original, modified, mode)
	-- Allow the addon to skip the conversation text for up to 10 seconds after the trade
	if os.time() - textSkipTimer > 10 then
		return
	end
	
	local target = windower.ffxi.get_mob_by_target('t')
	
	if not target then return
		false
	end
	
	if mode == 150 or mode == 151 then
		modified = modified:gsub(string.char(0x7F, 0x31), '')
	end
	
	return modified
end)