--lolwut

_addon.name = 'circles'
_addon.author = 'Myrchee'
_addon.version = '1.1'
_addon.command = 'circles'

require('logger')
require('strings')
require('tables')
require('lists')
require('sets')
require('maths')
require('functions')
require('chat')
res = require('resources')
packets = require('packets')

startDistance = 8
continue = 0
zoneID = 0
i = 1

wp = T{
	[243] = T{ --Ru'Lude Gardens
		[1] = {x = 30, y = -6},
		[2] = {x = -27, y = -6},
		[4] = {x = -27, y = -73},
		[3] = {x = 30, y = -73}
	},
	[249] = T{ --Mhaura
		[1] = {x = -10, y = 67},
		[2] = {x = 20, y = 70},
		[3] = {x = 46, y = 74},
		[4] = {x = 44, y = 48},
		[5] = {x = -21, y = 44},
		[6] = {x = -29, y = 35},
		[7] = {x = -39, y = 25},
		[8] = {x = -36, y = 54}
	}
}

windower.register_event('addon command', function(...)
	local args = T{...}
    local cmd = args[1]
	if cmd then 
		if cmd:lower() == 'start' then
			if ValidateLocation() == 1 then
				continue = 1
				coroutine.sleep(1)
			end
		elseif cmd:lower() == 'stop' then
			windower.add_to_chat(2,'Stopping.')
			continue = 0
		elseif cmd:lower() == 'test' then
			ValidateLocation()
		end
	end
	
	while continue == 1 do
	 RunCircles()
	end
end)

function RunCircles()
	--start near waypoints[1]
	--local player = windower.ffxi.get_mob_by_target('me')
	--local vecPlayer = UpdatePlayerPosition()
	local zone = windower.ffxi.get_info()['zone']
	local vecPlayer
	local vecWaypoint
	local dist
	local i = 2
	local iMax = #wp[zone]
	
	--for i,v in pairs(wp[zone]) do
	--	vecWaypoint = {x = v.x, y = v.y}
	--	--debug
	--	windower.add_to_chat(2,'Going to ['..i..'] -- '..v.x..', '..v.y)
	--	dist = 9999
	--	while (dist > 4) and (continue == 1) do
	--		vecPlayer = UpdatePlayerPosition()
	--		dist = GetDistance(vecPlayer, vecWaypoint)
	--		GoToWaypoint(vecPlayer,vecWaypoint)
	--		coroutine.sleep(1)
	--		windower.ffxi.run(false)
	--		coroutine.sleep(0.05)
	--	end	
	--end
	
	while continue == 1 do
		vecWaypoint = {x = wp[zone][i].x, y = wp[zone][i].y}
		dist = 9999
		--debug
		windower.add_to_chat(2,'Going to ['..i..'] -- '..wp[zone][i].x..', '..wp[zone][i].y)
		while (dist > 4) and (continue == 1) do
			vecPlayer = UpdatePlayerPosition()
			dist = GetDistance(vecPlayer, vecWaypoint)
			GoToWaypoint(vecPlayer, vecWaypoint)
			coroutine.sleep(1)
			windower.ffxi.run(false)
			coroutine.sleep(0.1)
		end
		
		i = i + 1
		
		if i > iMax then
			i = 1
		end
	end
	
end

function ValidateLocation()
	local zone = windower.ffxi.get_info()['zone']
	local player = windower.ffxi.get_mob_by_target('me')
	local vecStart
	
	if wp[zone] ~= nil then
		vecStart = wp[zone][1]
		if GetDistance(player, vecStart) < startDistance then
			windower.add_to_chat(2,'Validated')
			return 1
		else
			windower.add_to_chat(2,'Too far from starting point -- move closer to '..vecStart.x..', '..vecStart.y)
			return 0
		end
	else
		windower.add_to_chat(2,'Current zone not currently implemented.')
		return 0
	end
end

function GetDistance(player, location)
	return math.sqrt((location.x - player.x)^2 + (location.y - player.y)^2)
end

function UpdatePlayerPosition()
	local player = windower.ffxi.get_mob_by_target('me')
	vecPlayer = {x = player.x, y = player.y}
	return vecPlayer
end

function GoToWaypoint(player, location)
	if continue == 1 then
		local angle = GetAngle(player,location)
		windower.ffxi.turn(angle)
		windower.ffxi.run(angle)
		--windower.ffxi.run(location.y, location.x)
	end
end

function GetAngle(playervec,mobvec)
	--radians
    angle = (math.atan2(playervec.y-mobvec.y, playervec.x-mobvec.x) * -1) + math.pi
	--print("angle: "..angle.." "..angle/math.pi)
	return angle
end