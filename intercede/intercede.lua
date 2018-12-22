_addon.name = 'Intercede'
_addon.author = 'Kanryu, Flippant'
_addon.commands = {'i','int','intercede'}
_addon.version = '1.0.3'

require('tables')
require('strings')
require('sets')
require('pack')
packets = require('packets')

-- To do:
    -- Tell if NPC is visible

valid_npcs = {
	hp = S{'Home Point #1', 'Home Point #2', 'Home Point #3', 'Home Point #4', 'Home Point #5', 'Home Point #6'},
	wp = S{"Waypoint"},
	roe = S{'Eternal Flame','Rolandienne','Isakoth','Fhelm Jobeizat'},
	vw = S{'Voidwatch Officer', 'Owain', 'Hildegarde'},
	vw_port = S{'Atmacite Refiner'},
	rift = S{'Planar Rift'},
	gt = S{'Grounds Tome'},
	sg = S{'Survival Guide'},
	tribulens = S{'Affi', 'Dremi', 'Shiftrix'},
	signet = S{'Kochahy-Muwachahy'}, -- Missing a lot of NPCs
	ionis = S{'Fleuricette','Quiri-Aliri'},
	cruor = S{'Cruor Prospector'},
	maw = S{'Cavernous Maw'},
	abytime = S{'Conflux Surveyor'},
	traverser = S{'Joachim'},
	abyssea_port = S{"Horst"},
	orb = S{"Shami"},
	unity = S{},
	unitypop = S{"Ethereal Junction"},
	ethereal = S{"Ethereal Radiance"},
	escha = S{'Undulating Confluence'},
	sr = S{"Malobra"},
	ambusc = S{"Ambuscade Tome"},
	chest = S{'Riftworn Pyxis'},
	vw_prep = S{'Ardrick'},
	nomad = S{'Nomad Moogle'},
	emoogle = S{'Ephemeral Moogle'},
	taskd = S{'Task Delegator'},
	tags = S{'Rytaal'},
	runic = S{'Runic Portal'},
	mysterybox = S{'Rewardox','Winrix','Habitox','Specilox','Mystrix',},
}

valid_items = {		
	phase = {id=3853,type="rift"},
	cell = {id=3435,type="rift"},
	gobbiekey = {id=8973,type="mysterybox"},
	anvkey = {id=9274,type="mysterybox"},
}

windower.register_event('addon command',function (command,...)
	local args = T{...}
	if not command then
		local target = windower.ffxi.get_mob_by_target('t').name
		poke_npc(target)
	elseif command=="poke" and args[1] then
		poke_npc(args[1])
	elseif command=="all" then
		local target = windower.ffxi.get_mob_by_target('t').name
	elseif command=="type" and args[1] then
		poke_npc(args[1])
	elseif command=="name" and args[1] then
		poke_npc(args:concat(' '))
	elseif command=="trade" and args[1] then
		trade_npc(args[1])
	elseif command=="gobbiekey" then
		local havekey = get_item_index(8973)
		if havekey then
			windower.send_command('setkey f8 down; wait .2;setkey f8 up;int trade gobbiekey;wait 2;setkey enter down;wait .2;setkey enter up;wait 12;int gobbiekey')
		else
			message('SP Gobbie Key not found')
		end
	elseif command=="anvkey" then
		local havekey = get_item_index(9274)
		if havekey then
			windower.send_command('setkey f8 down; wait .2;setkey f8 up;int trade anvkey;wait 2;setkey enter down;wait .2;setkey enter up;wait 12;int anvkey')
		else
			message('Anniversary Key not found')
		end
	end
end)

windower.register_event('unhandled command', function(command, ...)
	local args = {...}
    if command:lower() == 'pokeall' then
		if args[1] then
			windower.send_command('send @all int type '..args[1])
		else
			local target = windower.ffxi.get_mob_by_target('t').name
			windower.send_command('send @all int name '..target)
		end
    elseif command:lower() == 'tradeall' and args[1] then
        windower.send_command('send @all int trade '..args[1])
    end
end)

function validate_npc(npc_type,check_type)
	check_type = check_type or 'type'

	if not valid_npcs[npc_type] then
		message('NPC type "'..npc_type..'" not indexed, checking mob array by name')
		check_type = 'name'
	end
	
	local target_index,target_id
	
	for i,v in pairs(windower.ffxi.get_mob_array()) do
		if v['name'] == windower.ffxi.get_player().name then
			my_index = i
		elseif v.valid_target and ( (check_type == 'type' and valid_npcs[npc_type]:contains(v['name'])) or (check_type == 'name' and npc_type == v['name']) ) and math.sqrt(v.distance)<6 then --windower.ffxi.get_mob_by_id(v['id'])
			target_index = i
			target_id = v['id']
		end
	end
	
	if not target_index or not target_id then
		message('NPC not found')
		return false
	end

	return target_index,target_id
end


function poke_npc(npc_type)
	local target_index,target_id = validate_npc(npc_type)
	
	if target_id and target_index then
		local packet = packets.new('outgoing', 0x01A, {
			["Target"]=target_id,
			["Target Index"]=target_index,
			["Category"]=0,
			["Param"]=0,
			["_unknown1"]=0})
		packets.inject(packet)
	end
end

--[[windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
 if id == 0x034 or id == 0x032 then
  if my_index then
  --coroutine.sleep(1)
  local packet = packets.new('outgoing', 0x016, {
  ["Target Index"]=my_index,
  })
  packets.inject(packet)
  result = {}
  return true
  end
 end 
end)]]--

function trade_npc(item)
	if not valid_items[item] then
		message('Item not indexed')
		return
	end
	
	local target_index,target_id = validate_npc(valid_items[item].type)
    if not target_index or not target_id then
        return
    end
	
	local ind = get_item_index(valid_items[item].id)
    if not ind then
        message('Item not found in inventory.')
        return
    end
	
	if ind and target_index and target_id then
		local textvar = assemble_menu_item_packet(target_id,target_index,ind)
		windower.packets.inject_outgoing(0x36,textvar)
	end
end

-----------------------------------------------------------------------------------
--Name: assemble_menu_item_packet(target_id,target_index,inventory_index)
--Desc: Puts together an "action" packet (0x1A)
--Args:
---- target_id - The target's ID
---- target_index - The target's index
---- inventory_index - The item's index
-----------------------------------------------------------------------------------
--Returns:
---- string - A menu packet. First four bytes are dummy bytes.
-----------------------------------------------------------------------------------

function assemble_menu_item_packet(target_id,target_index,inventory_index)
	local outstr = string.char(0x36,0x20,0,0)
    -- Target ID
    outstr = outstr..string.char( (target_id%256), math.floor(target_id/256)%256, math.floor( (target_id/65536)%256) , math.floor( (target_id/16777216)%256) ) 
    -- One unit traded 
    outstr = outstr..string.char(1,0,0,0,0,0,0,0)..string.char(0,0,0,0,0,0,0,0)..string.char(0,0,0,0,0,0,0,0)..
        string.char(0,0,0,0,0,0,0,0)..string.char(0,0,0,0,0,0,0,0)
    -- Inventory Index for the one unit
    outstr = outstr..string.char(inventory_index%256)
    -- Nothing else being traded
    outstr = outstr..string.char(0,0,0,0,0,0,0,0,0)
    -- Target Index
    outstr = outstr..string.char( (target_index%256), math.floor(target_index/256)%256)
    -- Only one item being traded
    outstr = outstr..string.char(1,0,0,0)
    return outstr	
end

function get_item_index(item_id)
	local items = windower.ffxi.get_items().inventory
	for ind,item in ipairs(items) do
		if item.id == item_id then
			return ind
		end
	end
	return nil	
end

function message(msg)
    windower.add_to_chat(200,'Intercede:: '..tostring(msg)..'')
end