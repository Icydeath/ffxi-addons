_addon.name = 'MassTrade'
_addon.author = 'Sudox'
_addon.command = 'mt'
_addon.version = '1.0.0'

require('tables')
require('strings')
packets = require 'packets'
resources = require('resources')

-- Global variables --
bagIndex = 0
targetInfo = T{}
tradeSlotLimit = 8
itemsHeldElementCount = 0

itemsHeld = 
T{
	    [1] = {inventoryIndex=0x00,count=0x00},
		[2] = {inventoryIndex=0x00,count=0x00},
		[3] = {inventoryIndex=0x00,count=0x00},
		[4] = {inventoryIndex=0x00,count=0x00},
		[5] = {inventoryIndex=0x00,count=0x00},
		[6] = {inventoryIndex=0x00,count=0x00},
		[7] = {inventoryIndex=0x00,count=0x00},
		[8] = {inventoryIndex=0x00,count=0x00}
}

-- TODO: Move these variables and tables into a settings file to facility sharing of new aliases --
tradeAlias =
T{
	['kc'] = {targetID=17784905,targetIndex=73,itemString='Kindred\'s Crest',npcName='Shami'},
	['r1'] = {targetID=17784989,targetIndex=157,itemString='Rem\'s Tale Ch.1',npcName='Monisette'},
	['r2'] = {targetID=17784989,targetIndex=157,itemString='Rem\'s Tale Ch.2',npcName='Monisette'},
	['r3'] = {targetID=17784989,targetIndex=157,itemString='Rem\'s Tale Ch.3',npcName='Monisette'},
	['r4'] = {targetID=17784989,targetIndex=157,itemString='Rem\'s Tale Ch.4',npcName='Monisette'},
	['r5'] = {targetID=17784989,targetIndex=157,itemString='Rem\'s Tale Ch.5',npcName='Monisette'},
	['r6'] = {targetID=17784989,targetIndex=157,itemString='Rem\'s Tale Ch.6',npcName='Monisette'},
	['r7'] = {targetID=17784989,targetIndex=157,itemString='Rem\'s Tale Ch.7',npcName='Monisette'},
	['r8'] = {targetID=17784989,targetIndex=157,itemString='Rem\'s Tale Ch.8',npcName='Monisette'},
	['r9'] = {targetID=17784989,targetIndex=157,itemString='Rem\'s Tale Ch.9',npcName='Monisette'},
	['r10'] = {targetID=17784989,targetIndex=157,itemString='Rem\'s Tale Ch.10',npcName='Monisette'},
	['alex'] = {targetID=16994398,targetIndex=94,itemString='Alexandrite',npcName='Paparoon'},
	['pluton'] = {targetID=17784988,targetIndex=156,itemString='Pluton',npcName='Oboro'},
	['beitetsu'] = {targetID=17784988,targetIndex=156,itemString='Beitetsu',npcName='Oboro'},
	['riftborn'] = {targetID=17784988,targetIndex=156,itemString='Riftborn Boulder',npcName='Oboro'},
}

--Main Method--
windower.register_event('addon command', function(...)
	local args = {...}
	
	if args[1] == 'npc' then
		if windower.ffxi.get_mob_by_target('t') ~= nil then
			targetInfo['targetID'] = windower.ffxi.get_mob_by_target('t').id
			targetInfo['targetIndex'] = windower.ffxi.get_mob_by_target('t').index
			itemID = getItemID(args[2])
			itemsHeld = getItemsHeld(itemID)
			
			if itemsHeldElementCount == 0 then
				debug("Failed to construct table of items to be traded.  Insure that you have the specified item in your inventory and that ")
				debug("you have spelled the item name correctly.")
				debug("For multi-word items, enclose the name in double quotes.  Example: \"Kindred's Crest\"")
			else
				local tradePacket = constructNPCTradePacket(targetInfo, itemsHeld)
				packets.inject(tradePacket)
				resetGlobals()
			end
		else
			debug("No target selected.")
		end
	elseif args[1] == 'tInfo' then
		debug("targetID: " .. windower.ffxi.get_mob_by_target('t').id)
		debug("targetIndex: " .. windower.ffxi.get_mob_by_target('t').index)
	elseif tableHasKey(tradeAlias, args[1]) then
		itemID = getItemID(tradeAlias[args[1]].itemString)
		itemsHeld = getItemsHeld(itemID)
		
		if itemsHeldElementCount == 0 then
			debug("Failed to construct table of items to be traded.  Insure that you have the specified item in your inventory.")
		else
			local tradeNPCPacket = constructNPCTradePacket(tradeAlias, itemsHeld, args[1])
			
			packets.inject(tradeNPCPacket)
			resetGlobals()
		end
	elseif args[1] == 'pc' then
		itemID = getItemID(args[2])
		itemsHeld = getItemsHeld(itemID)
		
		for i=1,itemsHeldElementCount do
			local tradePCPacket = constructPCTradePacket(itemsHeld, itemID, i)
			packets.inject(tradePCPacket)
		end
		resetGlobals()
	elseif args[1] == 'h' or args[1] == 'help' then
		debug("MassTrade allows the automatic trading of bulk items.")
		debug("Commands:")
		debug("'mt npc <itemName>' will trade the targeted NPC with up to 8 slots of the specified item.")
		debug("'mt pc <itemName>' will populate the existing PC-to-PC trade window with up to 8 slots of the specified item.")
		debug("     -Requires that a trade window already be opened.")
		debug("'mt <tradeAliasKey>' will search the existing tradeAlias table and trade in items automatically")
		debug("Example: 'mt alex' will complete the trade interaction with Paparoon with up to 8x 99 stacks of Alexandrite.")
		debug("Trade Aliases do not require you to target the NPC")
	else
		debug('Invalid command')
	end
end)

-- Debug function to print to log
function debug(msg)
    if debug then
		windower.add_to_chat(200, '' ..msg)
	end
end

-- Return the table containing the Inventory ID and the Count of the instances of itemID in our Inventory.  Returns a minimum of zero to a maximum of tradeSlotLimit. --
function getItemsHeld(itemID)
	inventory = windower.ffxi.get_items(bagIndex)
	itemsHeldIndex = 1

	for k in pairs(inventory) do
		if itemsHeldIndex == 9 then
			break
		elseif type(inventory[k]) == 'table' then
			if inventory[k].id == itemID then
				itemsHeld[itemsHeldIndex].count = inventory[k]['count']
				itemsHeld[itemsHeldIndex].inventoryIndex = inventory[k]['slot']
				itemsHeldIndex = itemsHeldIndex + 1
				itemsHeldElementCount = itemsHeldElementCount + 1
			end
		end
	end

	return itemsHeld
end

-- Used with targeting NPC and explicitly typing in the item to be traded --
function constructNPCTradePacket(targetInfo, itemsHeld)
	tradePacket = packets.new('outgoing', 0x036, 
	{
		['Target'] = targetInfo['targetID'],
		['Item Count 1'] = itemsHeld[1].count,
		['Item Count 2'] = itemsHeld[2].count,
		['Item Count 3'] = itemsHeld[3].count,
		['Item Count 4'] = itemsHeld[4].count,
		['Item Count 5'] = itemsHeld[5].count,
		['Item Count 6'] = itemsHeld[6].count,
		['Item Count 7'] = itemsHeld[7].count,
		['Item Count 8'] = itemsHeld[8].count,
		['Item Count 9'] = 0x00000000,
		['_unknown1'] = 0x0,
		['Item Index 1'] = itemsHeld[1].inventoryIndex,
		['Item Index 2'] = itemsHeld[2].inventoryIndex,
		['Item Index 3'] = itemsHeld[3].inventoryIndex,
		['Item Index 4'] = itemsHeld[4].inventoryIndex,
		['Item Index 5'] = itemsHeld[5].inventoryIndex,
		['Item Index 6'] = itemsHeld[6].inventoryIndex,
		['Item Index 7'] = itemsHeld[7].inventoryIndex,
		['Item Index 8'] = itemsHeld[8].inventoryIndex,
		['Item Index 9'] = 0x00000000,
		['_unknown2'] = 0x0,
		['Target Index'] = targetInfo['targetIndex'],
		['Number of Items'] = itemsHeldElementCount,
	})

	return tradePacket
end

-- Used with using pre-populated table of trade aliases --
function constructNPCTradePacket(tradeAlias, itemsHeld, key)
	tradePacket = packets.new('outgoing', 0x036, 
	{
		['Target'] = tradeAlias[key].targetID,
		['Item Count 1'] = itemsHeld[1].count,
		['Item Count 2'] = itemsHeld[2].count,
		['Item Count 3'] = itemsHeld[3].count,
		['Item Count 4'] = itemsHeld[4].count,
		['Item Count 5'] = itemsHeld[5].count,
		['Item Count 6'] = itemsHeld[6].count,
		['Item Count 7'] = itemsHeld[7].count,
		['Item Count 8'] = itemsHeld[8].count,
		['Item Count 9'] = 0x00000000,
		['_unknown1'] = 0x0,
		['Item Index 1'] = itemsHeld[1].inventoryIndex,
		['Item Index 2'] = itemsHeld[2].inventoryIndex,
		['Item Index 3'] = itemsHeld[3].inventoryIndex,
		['Item Index 4'] = itemsHeld[4].inventoryIndex,
		['Item Index 5'] = itemsHeld[5].inventoryIndex,
		['Item Index 6'] = itemsHeld[6].inventoryIndex,
		['Item Index 7'] = itemsHeld[7].inventoryIndex,
		['Item Index 8'] = itemsHeld[8].inventoryIndex,
		['Item Index 9'] = 0x00000000,
		['_unknown2'] = 0x0,
		['Target Index'] = tradeAlias[key].targetIndex,
		['Number of Items'] = itemsHeldElementCount,
	})

	return tradePacket
end

-- Used with targeting PC and explicitly designating the item to be traded --
function constructPCTradePacket(itemsHeld, itemID, slot)
	tradePacket = packets.new('outgoing', 0x034, 
	{
		['Count'] = itemsHeld[slot].count,
		['Item'] = itemID,
		['Inventory Index'] = itemsHeld[slot].inventoryIndex,
		['Slot'] = slot,
	})

	return tradePacket
end

-- Used with using pre-populated table of trade aliases --
function constructTextAdvancePacket(tradeAlias, key)
	textAdvancePacket = packets.new('outgoing', 0x05B, 
	{
		['Target'] = tradeAlias[key].targetID,
		['Option Index'] = 0x0,
		['_unknown1'] = 0x0,
		['Target Index'] = tradeAlias[key].targetIndex,
		['Automated Message'] = false,
		['_unknown2'] = 0x0,
		['Zone'] = tradeAlias[key].zone,
		['Menu ID'] = tradeAlias[key].menuID,
	})

	return textAdvancePacket
end

function returnItemID(itemName)
	for k,v in pairs(items) do
		if v == itemName then
			return k
		end
	end
end

-- Retrieve ItemID from resources.items table.  Item must be encased in double quotes ("<item_name>") if more than a single word --
function getItemID(itemName)
    for k,v in pairs(resources.items) do
        if v.en:lower() == itemName:lower() or v.enl:lower() == itemName:lower() then
			return v.id
        end
    end
	
    return nil
end

-- Reset global variables after a packet is successfully sent --
function resetGlobals()
	bagIndex = 0
	targetInfo = T{}
	tradeSlotLimit = 8
	itemsHeldElementCount = 0
	itemsHeld = 
	T{
		[1] = {inventoryIndex=0x00,count=0x00},
		[2] = {inventoryIndex=0x00,count=0x00},
		[3] = {inventoryIndex=0x00,count=0x00},
		[4] = {inventoryIndex=0x00,count=0x00},
		[5] = {inventoryIndex=0x00,count=0x00},
		[6] = {inventoryIndex=0x00,count=0x00},
		[7] = {inventoryIndex=0x00,count=0x00},
		[8] = {inventoryIndex=0x00,count=0x00}
	}
end

-- Utility function to check if table contains key --
function tableHasKey(table,key)
    return table[key] ~= nil
end