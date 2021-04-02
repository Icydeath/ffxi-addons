
_addon.name = 'ZenimonSnap'
_addon.version = '0.1'
_addon.author = 'Akaden'
_addon.commands = {'zs','zenimonsnap'}

extdata = require("extdata")
require 'tables'
require 'logger'
require('coroutine')
packets = require('packets')
res = require('resources')
math = require('math')

state = {
	stopping = true,
	equip_locked = false,
	equipped_camera = nil,
	trying_use_camera = false,
	trading_plates=false,
	log_debug = false,
}

items = {
	["Soultrapper"] = 18721,
	["Soultrapper 2000"] = 18724,
	["Blank Soulplate"] = 18722,
	["Blank high-speed soul plate"] = 18725,
	["Soul Plate"] = 2477
}

time_offset = -39601
	
if time_offset then
	local t = os.time()
	local offset = os.difftime(os.time(os.date('!*t', t)), t)
	time_offset = offset - 61201
end

player = windower.ffxi.get_player()

------- Utility section --------

local function debug( message )
	if state.log_debug then
		log('debug -- '..message)
	end
end

-- Find an item in inventory
local function get_inventory_item(name)
	local inventory = windower.ffxi.get_items(0) -- only get inventory items.
	for index = 1, inventory.max do
		local item = inventory[index]

		if item.id == items[name] then
			return {count=item.count,
					status=item.status,
					id=item.id,
					index=index,
					slot=item.slot,
					bazaar=item.bazaar,
					extdata=item.extdata,}
		end
	end
end

local function check_equipped(name, slot)
	local item = get_inventory_item(name)
	return item.status == 5
end

-- equip a camera to the ranged slot
local function equip_camera(name)
	local item = get_inventory_item(name)
	if not item then
		return
	end
	while not check_equipped(name, 'range') and not state.stopping do
		windower.ffxi.set_equip(item.index, 2, 0)
		coroutine.sleep(1)
	end

	if state.equipped_camera ~= name then
		log('Equipped camera: '..name)
	end

	state.equipped_camera = name
end

-- equip a soulplate to the ammo slot
local function equip_plate(name)
	local item = get_inventory_item(name)
	if item == nil then
		return
	end
	while not check_equipped(name, 'ammo') and not state.stopping do
		windower.ffxi.set_equip(item.index, 3, 0)
		coroutine.sleep(1)
	end
end

-- gets the recast info (remaning time, remaining charges, etc.)
local function get_recast_info(name)
	local item = get_inventory_item(name)

	local CurrentTime = (os.time(os.date('!*t')) + time_offset)
	if item ~= nil and type(item) == "table" and item.id ~= 0 then
		local data = extdata.decode(item)
        return { next_use_time = math.max(data.next_use_time - CurrentTime, 0),
    			 activation_time = math.max(data.activation_time - CurrentTime, 0),
    			 charges_remaining = data.charges_remaining}
    end
    return nil
end

local function use_camera()
	state.trying_use_camera = true
	while state.trying_use_camera and not state.stopping do
		debug('use camera')
		windower.send_command('input /item "'..state.equipped_camera..'" <t>')
		coroutine.sleep(1)
	end	
	debug('end camera use.')
end

---------- Main section --------------
-- stop either trading or taking pictures.
local function stop()
	if not state.stopping then
		state.stopping = true
		state.trading_plates = false
		windower.send_command('gs enable range ammo')
		log('Stopped.')
	end
end

------- Photo section --------

local function get_camera(name)
	local item = get_inventory_item(name)
	if item ~= nil and get_recast_info(name).charges_remaining > 0 then
		return item
	end
	return nil
end

local function find_and_equip_camera()
	local soultrapper = get_camera("Soultrapper")
	local soultrapper2000 = get_camera("Soultrapper 2000")
	if soultrapper == nil and soultrapper2000 == nil then
		return false
	end

	local soultrapper_recast = 1000
	local soultrapper2000_recast = 1000
	if soultrapper ~= nil then
		soultrapper_recast = get_recast_info("Soultrapper").next_use_time
	end
	if soultrapper2000 ~= nil then
		soultrapper2000_recast = get_recast_info("Soultrapper 2000").next_use_time
	end

	if soultrapper2000_recast < soultrapper_recast then
		equip_camera("Soultrapper 2000")
		return true
	else
		equip_camera("Soultrapper")
		return true
	end

	return false
end

local function find_and_equip_plates()
	local soulplate = get_inventory_item("Blank Soulplate")
	if soulplate == nil then
		soulplate = get_inventory_item("Blank high-speed soul plate")
		if soulplate == nil then
			return false
		end
		equip_plate("Blank high-speed soul plate")
	else
		equip_plate("Blank Soulplate")
	end

	return true
end

local function equip_next_camera()
	if state.stopping then
		return
	end

	local bags = windower.ffxi.get_bag_info()
	debug("inv check: "..bags.inventory.count..'/'..bags.inventory.max)
	if bags.inventory.max >= 30 and bags.inventory.count == bags.inventory.max then
		log('Inventory is full.')
		stop()
		return
	end

	local target = windower.ffxi.get_mob_by_target('t')
	if target == nil or target.name == '' then
		log('No target. Targeting nearest NPC.')
        windower.send_command('input /targetnpc')
        
		coroutine.schedule(equip_next_camera, 1)
		return
	elseif target.id == player.id then
		log('Nobody wants a picture of you.')

		-- escape, try target npc.
        windower.send_command('setkey escape down')
        coroutine.sleep(.2)
        windower.send_command('setkey escape up')
        coroutine.sleep(.2)

		coroutine.schedule(equip_next_camera, 1)
		return
	end

	if not find_and_equip_camera() then 
		log('Unable to equip camera. None are in inventory or all cameras are out of charges.')
		stop()
		return
	end

	if not find_and_equip_plates() then
		log('Unable to equip plates. None are in inventory.')
		stop()
		return 
	end

	local recast_info = get_recast_info(state.equipped_camera)
	if recast_info then
		local next_time = math.max(recast_info.activation_time,recast_info.next_use_time)
		debug(state.equipped_camera..' ready in '..next_time..' seconds.')	
		coroutine.schedule(use_camera, next_time)
	end
end

-- begin taking pictures of the targeted enemy.
local function begin_snap()
	state.stopping = false
	windower.send_command('gs disable range ammo')

	log('Starting to take pretty pictures...')
	coroutine.schedule(equip_next_camera, 1)
end

--------- Trading section -----------

local function get_mob_by_name(name)
    local mobs = windower.ffxi.get_mob_array()
    for i, mob in pairs(mobs) do
        if (mob.name == name) and (math.sqrt(mob.distance) < 6) then
            return mob
        end
    end
end

local function trade_plate()
	local plate_item = get_inventory_item("Soul Plate")
	if not plate_item then
		state.trading_plates = false
		log("No plates found in inventory.")
		return
	end

	local npc = get_mob_by_name('Sanraku')
	if not npc then
		state.trading_plates = false
		log("Can't find Sanraku!")
		return
	end

	local trade = packets.new('outgoing', 0x36, {
        ['Target'] = npc.id,
        ['Target Index'] = npc.index,
    })
    trade['Item Index 1':format(idx)] = plate_item.index
    trade['Item Count 1':format(idx)] = 1
	trade['Number of Items'] = 1
	packets.inject(trade)	
end

-- begin trading soul plates to the npc vendor.
local function begin_trade()
	state.trading_plates = true

	trade_plate()
end

local function toggle_debug()
	state.log_debug = not state.log_debug
	log('Debug: '..tostring(state.log_debug))
end

handlers = {}
handlers['snap'] = begin_snap
handlers['trade'] = begin_trade
handlers['stop'] = stop
handlers['debug'] = toggle_debug

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

local function on_item_failure(id, data)
	if id == 0x029 then
		local packet = packets.parse('incoming', data)
		if packet.message == 62 then
			if packet['Actor'] == player.id and packet['Param 1'] == items[state.equipped_camera] then
				coroutine.schedule(use_camera, 1)
				debug('camera use failure')
			end
		end
	end
end

local function on_item_success(id, data)
	if id == 0x028 then
		local packet = packets.parse('incoming', data)

		if packet['Actor'] == player.id and packet['Category'] == 5 and packet['Param'] == items[state.equipped_camera] then
			-- complete item, try take next picture.
			debug('camera use success')
			coroutine.schedule(equip_next_camera,1)

		end
	end
end

local function on_item_start(id, data)
	if id == 0x028 then
		local packet = packets.parse('incoming', data)

		if packet['Actor'] == player.id and packet['Category'] == 9 and packet['Target 1 Action 1 Param'] == items[state.equipped_camera] then
			debug('using camera started')
			state.trying_use_camera = false
		end
	end
end

windower.register_event('addon command', handle_command)
windower.register_event('incoming chunk', on_item_failure)
windower.register_event('incoming chunk', on_item_success)
windower.register_event('incoming chunk', on_item_start)
windower.register_event('unload', stop)

windower.register_event('status change', function(new_status_id)
    if new_status_id ~= 4 then
    	if state.trading_plates then
			coroutine.schedule(trade_plate, 0.5)
    	end
	end
end)