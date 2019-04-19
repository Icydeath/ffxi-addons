_addon.name = 'targetpractice'
_addon.author = 'Myrchee'
_addon.version = '1.0'
--_addon.commands = {'targetpractice','tp','tpa'}
_addon.command = 'tp'

require('tables')
require('packets')
require('functions')
require('chat')

cc = 8 --chat color
--delay = 0.001

mobInfo = {
    'name', --string
    'claim_id', --int
    'distance', --number
    'facing', --number
    'hpp', --int
    'id', -- int
    'is_npc', --bool
    'mob_type', --int
    'model_size', --number
    'speed', --number
    'speed_base', --number
    'race', --number
    'status', --int
    'index', --int
    'x', --number
    'y', --number
    'z', --number
    --target_index: number (only valid for PCs)
    --fellow_index: number (only valid for PCs)
    --pet_index: number  
    --tp: number  (only valid for pets - May not exist?)  
    --mpp: number  (only valid for pets - May not exist?)  
    'charmed', --bool
    'in_party', --bool
    'in_alliance', --bool
    'valid_target' --bool
}

mobDist = {
	'name',
	'id',
	'distance',
	'x',
	'y',
	'z'
}


mobBasic = {
	'name',
	'id'
}


windower.register_event('addon command', function(...)
	local args = T{...}
    local cmd = args[1]
	local cmd2 = args[2]
	if cmd then 
		--if cmd:lower() == 'mobarray' then
		--	if cmd2:lower() == 'dist' then
		--		mobarray(mobDist)
		--	elseif cmd2:lower() == 'basic' then
		--		mobarray(mobBasic)
		--	else
		--		mobarray(mobInfo)
		--	end
		--elseif cmd:lower() == 'target' then
		if cmd:lower() == 'target' then
			if cmd2:lower() == 'dist' then
				targetinfo(mobDist)
			elseif cmd2:lower() == 'basic' then
				targetinfo(mobBasic)
			else
				targetinfo(mobInfo)
			end
		elseif cmd:lower() == 'dump' then
			arrdump()
		elseif cmd:lower() == 'dump2' then
			arrdump2()
		elseif cmd:lower() == 'turn' then
			TurnToClosest()
		end
	end
end)


--[[
function mobarray(params)
	--wai tho
	marray = windower.ffxi.get_mob_array()
	for i,v in pairs(marray) do
	--for i,v in pairs(windower.ffxi.get_mob_array()) do
		windower.add_to_chat(cc,'i = '..i)
		ArrayToChat(v, params)
		--ArrayToChat(marray[i], params)
		--coroutine.sleep(delay)
	end
end
]]--

function arrdump()
	marray = windower.ffxi.get_mob_array()
	for i,v in pairs(marray) do
		print(i,v)
	end
end
function arrdump2(params)
	marray = windower.ffxi.get_mob_array()
	for i,v in pairs(marray) do
		if v["distance"] < 500 then 
			print(i,v)
			print(v["name"])
			print(v["distance"])
		end
	end
end

function targetinfo(params)
	mob = windower.ffxi.get_mob_by_target('t')
	ArrayToChat(mob, params)
end

function ArrayToChat(arr, params)
	for arri,arrv in pairs(params) do
		if arr[arrv] then
			windower.add_to_chat(cc, arrv..': '..tostring(mob[arrv]))
		else
			windower.add_to_chat(cc, arrv..': false or DNE')
		end
	end
end

function TurnToClosest()
	player = windower.ffxi.get_mob_by_target('me')
	marray = windower.ffxi.get_mob_array()
	
	--target_id
	local dist = 999999
	local mobx
	local moby
	local mobname
	local angle
	
	
	for i,v in pairs(marray) do
		if v["name"] ~= player.name then
			if v["distance"] < dist then
				dist = v["distance"]
				mobname = v["name"]
				mobx = v["x"]
				moby = v["y"]
				--target_id = v["id"]
			end
		end
	end
	
	
	vecPlayer = {x = player.x, y = player.y}
	vecMob = {x = mobx, y = moby}
	
	--get angle (in radians)
	angle = GetAngle(vecPlayer, vecMob)
	windower.ffxi.turn(angle)
	coroutine.sleep(0.1)
	windower.send_command('input /targetbnpc')
	print("closest dist: "..math.sqrt(dist).." "..mobname)
end

function GetAngle(playervec,mobvec)
	--radians
    angle = (math.atan2(playervec.y-mobvec.y, playervec.x-mobvec.x) * -1) + math.pi
	print("angle: "..angle.." "..angle/math.pi)
	return angle
end