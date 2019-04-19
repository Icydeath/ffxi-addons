--[[

Using this will probably get you banned. Don't do it.

]]


_addon.name = 'magiantrials'
_addon.author = 'Myrchee'
_addon.version = '1.2'
_addon.command = 'mtrial'

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

--distance for attacking, in yalms
atkd = 4
--minimum distance
dmin = 1

--target mob
target = 'Angler Tiger'

--weaponskill needed
ws = 'Randgrith'

--HP threshold for ws usage (set to 100 if killshot not needed)
threshold = 40

continue = 0

windower.register_event('addon command', function(...)
	local args = T{...}
    local cmd = args[1]
	if cmd then 
		if cmd:lower() == 'start' then
			continue = 1
			coroutine.sleep(1)
		elseif cmd:lower() == 'stop' then
			continue = 0
		elseif cmd == 'threshold' then
			threshold = args[2]
			windower.add_to_chat(2,'New threshold for using '..ws..' is '..threshold)
		end
	end
	
	while continue == 1 do
	 DoTrial()
	end
end)

windower.register_event('zone change', function(new_id, old_id)
	continue = 0
	windower.add_to_chat(2, 'Area changed -- stopping magiantrials')
end)

function checkHPP(threshold)
	local player = windower.ffxi.get_player()
	--local threshold = 60
	if (player.vitals.hpp < threshold) then
		return true
	else
		return false
	end
end


function GetAngle(playervec,mobvec)
	--radians
    angle = (math.atan2(playervec.y-mobvec.y, playervec.x-mobvec.x) * -1) + math.pi
	--print("angle: "..angle.." "..angle/math.pi)
	return angle
end

function GetClosestMob()
	local player = windower.ffxi.get_mob_by_target('me')
	marray = windower.ffxi.get_mob_array()
	
	--just to prevent returning a nil value
	target_id = player.id
	
	local dist = 99999
	
	for i,v in pairs(marray) do
		if (v["name"] == target) and (v["hpp"] > 0) and (v["valid_target"] == true) then
			if v["distance"] < dist then
				dist = v["distance"]
				mobname = v["name"]
				--mobx = v["x"]
				--moby = v["y"]
				target_id = v["id"]
			end
		end
	end
	
	
	return target_id
end

function GoToMob(playervec, mobvec)
	coroutine.sleep(0.1)
	local angle = GetAngle(playervec,mobvec)
	--windower.ffxi.turn(angle)
	windower.ffxi.run(angle)
end

function DoTrial()
	local player = windower.ffxi.get_mob_by_target('me')
	tar_id = GetClosestMob()
	local mob = windower.ffxi.get_mob_by_id(tar_id)
	local d = 99999
	local continue2 = 0
	
	--while continue == 1 do
		--move to target, turn again when in range, then /targetbnpc, then /a <t>
		while (d > atkd) and (tar_id ~= player.id) do
			--update position information
			mob = windower.ffxi.get_mob_by_id(tar_id)
			player = windower.ffxi.get_mob_by_target('me')
			vecPlayer = {x = player.x, y = player.y}
			vecMob = {x = mob.x, y = mob.y}
			
			GoToMob(vecPlayer,vecMob)
			coroutine.sleep(1)
			windower.ffxi.run(false)
			d = math.sqrt(windower.ffxi.get_mob_by_id(tar_id).distance)
			continue2 = 1
		end
		
		--turn to and attack target
		if continue2 == 1 then
			--update position information
			mob = windower.ffxi.get_mob_by_id(tar_id)
			player = windower.ffxi.get_mob_by_target('me')
			vecPlayer = {x = player.x, y = player.y}
			vecMob = {x = mob.x, y = mob.y}
			--turn
			windower.ffxi.turn(GetAngle(vecPlayer, vecMob))
			--target, attack
			coroutine.sleep(0.5)
			windower.send_command('input /targetbnpc')
			coroutine.sleep(0.1)
			windower.send_command('input /a <t>')
			
			--turn, check hpp, and WS
			while (mob.hpp > 0) and (continue == 1) and (mob.valid_target == true) do
				mob = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_id(tar_id)
				--mob = windower.ffxi.get_mob_by_id(tar_id)
				player = windower.ffxi.get_mob_by_target('me')
				if player.status == 0 then
					--target and engage if haven't already done so -- the command before this while statement can miss or disengage
					windower.send_command('input /targetbnpc')
					coroutine.sleep(0.1)
					windower.send_command('input /a <t>')
				end
				vecPlayer = {x = player.x, y = player.y}
				vecMob = {x = mob.x, y = mob.y}
				windower.ffxi.turn(GetAngle(vecPlayer, vecMob))
				if math.sqrt(mob.distance) > atkd then
					GoToMob(vecPlayer,vecMob)
					coroutine.sleep(1)
					windower.ffxi.run(false)
				elseif math.sqrt(mob.distance) < dmin then
					--back up if too close
					windower.ffxi.run(GetAngle(vecPlayer, vecMob) - math.pi)
					coroutine.sleep(0.5)
					windower.ffxi.run(false)
				elseif mob.hpp < threshold then
					windower.send_command('input /ws \"'..ws..'\" <t>')
				end
			end
		end
		
	--end
end
