_addon.author = 'Skittylove'
_addon.command = 'ring'
_addon.name = 'RingUse'
_addon.version = '1.0'


require('strings')
require('GUI')
require('tables')
require('Modes')
res = require('resources')
extdata = require('extdata')
packets = require('packets')
config = require('config')

settings = config.load({gearswap=false,x=500,y=500}) --Import settings with defined defaults

sendcom = 'send @all ' --quick text for the sendall command
target = ' <me>' --quick text for ring target.
send = M(false, 'Send Command')

------- Defining variables for use in GS, do not tamper ----
usingring = false
goingtoenter = false
enterarea = false
running = false
proceed = false
tp = false
currentsender = false
renablenow = false
renablecount = 0
useringat = 0
ringcommand = ''
ringbeingused=''
attempts = 0
----------------------------------------------------------------------


Ringlist = M{['description']='AllRings','None', 'Warp Ring', 'Teleport Ring', 'EXP Ring', 'CP Ring', 'Emporox'} -- Builds list of Ring types
RingGroups = { --Generates ring groups. This also determines the order it searches for rings, move around to set priority if desired
['Warp Ring'] = M{['description']='Warp Rings', 'Warp Ring'},
['EXP Ring'] = M{['description']='EXP Rings', 'Echad Ring','Caliber Ring','Emperor Band', 'Empress Band', 'Chariot Band', 'Resolution Ring', 'Allied Ring', 'Kupofried\'s Ring'},
['CP Ring'] = M{['description']='CP Rings','Trizek Ring','Endorsement Ring','Facility Ring','Capacity Ring','Vocation Ring',},
['Teleport Ring'] = M{['description']='TeleportRings', 'Dim. Ring (Holla)', 'Dim. Ring (Dem)', 'Dim. Ring (Mea)'},
['Emporox'] = M{['description']='Emporox Rings', 'Emporox\'s Ring'},
}


RingImages = { --Defines ring Images
  ['None'] = {img='None.png'},
  ['Warp Ring'] ={img='WarpRing.png'},
  ['Teleport Ring'] = {img='Holla.png', act = 8},
  ['EXP Ring'] = {img='Dem.png', act = 8},
  ['CP Ring'] = {img='Mea.png', act = 8}, 
  ['Emporox'] = {img='Trizek.png'},
  }
  
RingDetails = { -- Manually defined ring activation
  ['None'] = {act = 10},
  ['Warp Ring'] ={act = 8},
  ['Dim. Ring (Holla)'] = {act = 8},
  ['Dim. Ring (Dem)'] = {act = 8},
  ['Dim. Ring (Mea)'] = {act = 8},
  ['Capactiy Ring'] ={act = 5},
  ['Trizek Ring'] ={act = 5},
  ['Echad Ring'] ={act = 5},
  ['Emperor Band'] ={act = 8},
  ['Caliber Ring'] ={act = 8},
  ['Emporox\'s Ring'] = {act = 5},
  
  }

function use(ringlist, sent) --main function. sent is only given if the sentuse command is used
	
	local echotext = 'input /echo ' --generating echo text to identify other character issues
	if send.value then -- Send command to all
		currentsender = true --flag to skip the sentuse command to avoid overflow
		windower.send_command(sendcom..'ring sentuse '..ringlist) --Send command to other consoles. Requires that the add on be loaded
		echotext = sendcom..'input /echo '..windower.ffxi.get_mob_by_target('me').name..': ' --Refine Echotext to identify the character with the problem
	end
	
	if sent then  -- otherconsole sets echotext here
		echotext = sendcom..'input /echo '..windower.ffxi.get_mob_by_target('me').name..': '
	end

	if ringlist == 'None' then reset() return end --Returns if ringlist value is None
	
	local bestring = determinebestring(ringlist) --Determines the best ring to use for the list given
	
	if not bestring[1] then	--For logging errors.
		if bestring[2] == 2 then -- 2 is returned if its not found inventory
			windower.send_command(echotext..ringlist..' is either not in your inventory or hasn\'t been loaded')
			reset()
		else
			windower.send_command(echotext..ringlist..' is still on cooldown')
			reset()
		end
		return
	end
	local ring = bestring[1] -- Set ring for easier calling
	if RingDetails[ring] then --Generators activation time from table or defaults to 10
		ringtimer =  RingDetails[ring].act + 2
	else
		ringtimer = 10
	end

	
	if settings.gearswap then -- Disable slot
	windower.send_command('gs disable ring1')
	end
	

	
	windower.chat.input('/equip ring1 "'..ring..'"')  --Puts ring on
	if ringlist == 'Teleport Ring' then goingtoenter = true else goingtoenter = false end -- sets up logic for reisenjima teleport
	usingring = true -- set value for prender to check
	useringat = os.clock() + ringtimer --set time to trigger
	ringcommand = '/item "'..ring..'"'..target --command for using the ring
	ringbeingused = ring -- set global value
end

function useit()

	if renablenow and settings.gearswap and renablecount >= 500 then --Checks for Ring renabling
		windower.send_command('gs enable ring1') 
		renablecount = 0
		renablenow = false
	elseif renablenow and settings.gearswap then
		renablecount = renablecount + 1
	end

	if enterarea then --Checks if you zone into reisenjima area
		attempts = attempts + 1 --Adds to timeout 
		local info = windower.ffxi.get_info()
		local zone = res.zones[info.zone].name
		if zone == 'La Theine Plateau' or zone == 'Konschtat Highlands' or zone == 'Tahrongi Canyon' then --If you used a teleport ring and are in the teleport zone beging reisenjima movement
			movetozone()
		elseif attempts > 3000 then --Times out after 3000 frames if zone is never found
			enterarea = false
			attempts = 0
		end		
	end
	
	if not usingring then  --returns if we aren't using a ring
		return 
	elseif usingring and os.clock() <= useringat then --returns if it isn't time
		return
	elseif usingring then
		windower.chat.input(ringcommand) --sends ring input
		if goingtoenter then enterarea = true goingtoenter = false end  --Flags that the ring is used and we are ready to movetozone
		reset()
		renablenow = true
	--	if settings.gearswap then windower.send_command('gs enable ring1') end -- Reenables ring
	end
	
end

function checkinventory(ring) -- Goes things inventory to find ring. Returns the bag its in, index and what the item ID is
	-- 0, 8 , 10, 11, 12
	local inventory = windower.ffxi.get_items(0)
	local wardrobe1 = windower.ffxi.get_items(8)
	local wardrobe2 = windower.ffxi.get_items(10)
	local wardrobe3 = windower.ffxi.get_items(11)
	local wardrobe4 = windower.ffxi.get_items(12)
	for i, v in ipairs(inventory) do
		if res.items[v.id] then
			if res.items[v.id].en == ring then
				return {0, i}
			end
		end
	end
	
	for i, v in ipairs(wardrobe1) do
		if res.items[v.id] then
			if res.items[v.id].en == ring then
				return {8, i, v.id}
			end
		end
	end
	
	for i, v in ipairs(wardrobe2) do
		if res.items[v.id] then
			if res.items[v.id].en == ring then
				return {10, i, v.id}
			end
		end
	end
	
	for i, v in ipairs(wardrobe3) do
		if res.items[v.id] then
			if res.items[v.id].en == ring then
				return {11, i, v.id}
			end
		end
	end
	
	for i, v in ipairs(wardrobe4) do
		if res.items[v.id] then
			if res.items[v.id].en == ring then
				return {12, i, v.id}
			end
		end
	end
	
	return false
end

function checkcooldown(ring) --checks to see if the ring is in inventory and if its on cooldown.
	local bagval = checkinventory(ring)
	if not bagval then return {false, 2} end
	local itemtable = windower.ffxi.get_items(bagval[1], bagval[2])
	e = extdata.decode(itemtable)
	local t = e.type
	local recast = t and e.charges_remaining > 0 and math.max(e.next_use_time+18000-os.time(),0)
	if not recast then return {false, 1} end

	if recast > 0 then 
		return {false, 1}
	else
		return {true, 1}
	end
end

function determinebestring(ringlist) --Loop to determine best ring in list to use
	
	if not RingGroups[ringlist] then print('Verify Ring Groups') return end
	local checkrecast = {}
	
	for i, v in ipairs(RingGroups[ringlist]) do
		checkrecast = checkcooldown(v)
		if checkrecast[1] then return {v, checkrecast[1], checkrecast[2]} end
	end
	
	return {checkrecast[1],checkrecast[2]}
	
end

function reset() --Resets ringlist value and other variables

	Ringlist:set('None')
	useringat=0
	usingring=false
	ringbeingused=''

end

function buildUI() -- builds UI

	local ri = {}
    local ri = {}
    for i,v in ipairs(Ringlist) do
        ri[i] = {img=RingImages[v].img, value=v, tooltip=v}
    end
	
	RingSelect = IconButton{
		x = settings.x + 0,
		y = settings.y + 54,
		var = Ringlist,
		icons = ri,
		direction = 'north',
		command = function() use(Ringlist.value) end		
	}
	RingSelect:draw()
	
	SendToggle= ToggleButton{
		x = settings.x + 50,
		y = settings.y + 54,
		var = send,
		iconUp = 'SendOff.png',
		iconDown = 'SendOn.png',
		command = function() windower.send_command('input /echo Send '..tostring(send.value)) end
		}		
	SendToggle:draw()
	
	end

function redrawUI() -- Redraws UI
	RingSelect:undraw()
	SendToggle:undraw()
	buildUI()
end

function movetozone() --Reisenjima Logic, took this from Quetzlua (Thanks!)
	local me = windower.ffxi.get_mob_by_target('me')
	tp = windower.ffxi.get_mob_by_name('Dimensional Portal')
	if tp and math.sqrt(tp.distance) > 3 and not running then
		windower.ffxi.run(tp.x - me.x, tp.y - me.y)
		running = true
	elseif tp and math.sqrt(tp.distance) == 0 and not running then return
	elseif tp and math.sqrt(tp.distance) <= 3 then
		windower.ffxi.run(false)
		running = false
		local p = packets.new('outgoing', 0x01A, {
            ['Target'] = tp.id,
            ['Target Index'] = tp.index,
        })
        packets.inject(p)
		enterarea = false
		proceed = true
	end
	
end

function trim(s) --trim function
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

windower.register_event('prerender', useit) --checks prerender for ring usage

windower.register_event('zone change', function(new, old) --Verifys zone change to force the Reisenjima timeout
	if enterarea then
		local zone = res.zones[new].name
		if not (zone == 'La Theine Plateau' or zone == 'Konschtat Highlands' or zone == 'Tahrongi Canyon') then enterarea = false end
	end	
end)

windower.register_event('addon command', function(...) --Commands
	local args = T{...}
	local cmd = args[1]:lower()
	args:remove(1)
	if cmd == 'sentuse' then -- used by the addon to send to other users
		local argsend = ''
		for i, v in ipairs(args) do -- combines arguments and trims
			argsend = argsend..v..' '
		end
			argsend = trim(argsend)
		if not currentsender then
			use(argsend, true)
		else
			currentsender = false
		end
	elseif cmd == 'gs' then -- Update gearswap setting
		settings.gearswap = not settings.gearswap
		windower.send_command('input /echo settings.gearswap set to '..tostring(settings.gearswap))
		config.save(settings,windower.ffxi.get_mob_by_target('me').name)
	elseif cmd == 'pos' then -- Update Addon position
	
		if not tonumber(args[1]) or not tonumber(args[2]) then
			print('Invalid arguments') 
			return 
		end
		settings.x = tonumber(args[1])
		settings.y = tonumber(args[2])
		redrawUI()

		config.save(settings,windower.ffxi.get_mob_by_target('me').name)		
	end
	
	end)

windower.register_event('incoming chunk',function(id,data,modified,injected,blocked) --Reisenjima logic, thanks Quetz lua!!
	local player = windower.ffxi.get_player()
	local me = windower.ffxi.get_mob_by_target('me')
	local zone_id = windower.ffxi.get_info().zone
	local zone_name = res.zones[zone_id].name
	local menu_id = 0
	if id == 0x034 or id == 0x032 then
		if proceed == true then
			local parse = packets.parse('incoming', data)
			local npc_id = parse['NPC']
			if tp and npc_id == tp.id then		--Dimensional Portal
				if zone_name == 'La Theine Plateau' then
					menu_id = 222
				elseif zone_name == 'Konschtat Highlands' or zone_name == 'Tahrongi Canyon' then
					menu_id = 926
				end
				local port = packets.new('outgoing', 0x05B, {
					["Target"] = tp.id,
					["Option Index"] = 0,
					["_unknown1"] = 0,
					["Target Index"] = tp.index,
					["Automated Message"] = true,
					["_unknown2"] = 0,
					["Zone"] = zone_id,
					["Menu ID"] = menu_id
				})
				packets.inject(port)
				
				local port = packets.new('outgoing', 0x05B, {
					["Target"] = tp.id,
					["Option Index"] = 2,
					["_unknown1"] = 0,
					["Target Index"] = tp.index,
					["Automated Message"] = false,
					["_unknown2"] = 0,
					["Zone"] = zone_id,
					["Menu ID"] = menu_id
				})
				packets.inject(port)
				delay = 10
				proceed = false
			end
		end
	end
end)
buildUI()


