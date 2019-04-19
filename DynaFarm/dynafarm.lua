--[[
Don't get banned. Or do.
]]

--[[
Stuff that needs to be fixed:
	-Prevent running to stuff way outside of targets
	-Check for attacking mobs before using sneakInvisible and running to next camp
	-Weaponskills when fighting non-targets
	-Move away when too close to target
	-Cancel sneak and reapply sneakInvisible
	-Make sure player turns to face engaged mob
	-Prioritize closest mob
	-Disengage and reengage if mob HP doesn't change in X seconds (to work around bug where player doesn't attack)
]]

--lolpseudocode
--[[
mob = windower.ffxi.get_mob_by_target('t')
player = windower.ffxi.get_mob_by_target('me')
if mob.distance < 10 and mob.status = 1 and (mob.claim_id = player.id or mob.claim_id = 0){
	attack
}

to deal with non-target aggression
]]

--[[
Pre-release pseudo code
Note: add something to attack mobs attacking you regardless of ID

while (0 < time < 8){
	while (distance > byne area){
		RunTo(byne area)
	}
	while ( distance <= byne area && 0 < time < 8){
		Getmobs()
		while (targetMob = exists and targetMob.isValidTarget == true and targetMob.HP > 0){
			if (targetMob.distance > maxdistance){
				runTo(targetMob)
				NOTE: may need to add pos.x and pos.y restrictions for certain areas
					to prevent getting stuck
			}
			else if (targetMob.distance < mindistance){
				backUp(direction)
			}
			else{
				Fight(mob)
			}
		}
	}

}

Fight(mob){
	while (mob.HP > 0){
		if (mob.distance > max){
			runTo(mob)
			sleep(1)
		}
		if (mob.distance < min){
			runAway(mob)
			sleep(0.5)
		}
		if (step.ready == true){
			useStep(mob)
		}
	}
	
	sleep(0.5) //to hopefully prevent windower from crashing
}

]]

_addon.name = 'dyna'
_addon.author = 'Myrchee'
_addon.version = '0.4'
_addon.commands = {'dyna', 'dfarm'}

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

step = 'Quickstep'
stepTP = 100
stepID = 220

ws = 'Dancing Edge'

timeDelay = 0.1 --time for coroutine.sleep
startDelay = 15
wpDistance = 2 --proximity to waypoints required (in yalms)
searchRadius = 200 --yalms
aggroRadius = 15

atkd = 4 --max attack distance
dmin = 2 --min attack distance
continue = 0

jaTargets = T{
	[39] = T{ --Dynamis - Valkurm
		[0] = 'Nightmare Flytrap',
		[8] = 'Nightmare Hippogryph',
		[16] = 'Nightmare Treant'
		
	},
	[41] = T{ --Dynamis - Qufim
		[0] = 'Nightmare Kraken',
		[8] = 'Nightmare Snoll',
		[16] = 'Nightmare Tiger'
		
	}
}

--currency areas
wpCamps = T{
	[39] = T{-- Dynamis - Valkurm
		[0] = {x = -145, y = -110},
		[8] = {x = -267, y = -33},
		[16] = {x = -325, y = 63}
	},
	[41] = T{ --Dynamis - Qufim
		[0] = {x = 15, y = -75},
		[8] = {x = 19, y = 275},
		[16] = {x = 92, y = -170}
	}
}

wpStart = T{ --move from start to camps - will need to change when dynamis campaign isn't active
	[39] = T{ --Dynamis - Valkurm
		[1] = {x = 0, y = 0}
	},
	[41] = T{ --Dynamis - Qufim
		[1] = {x = -4, y = 99},
		[2] = {x = -9, y = 70},
		[3] = {x = -47, y = 75},
		[4] = {x = -61, y = 53},
		[5] = {x = -62, y = 10},
		[6] = {x = -55, y = -15},
		[7] = {x = 3, y = -26},
		[8] = {x = 46, y = -91}
	}
}

wp = T{ --waypoints for moving between camps
	[39] = T{ --Dynamis - Valkurm
		[0] = T{ --0-8 to 8-16
			[1] = {x = 0, y = 0}
		},
		[8] = T{ --8-16 to 16-24
			[1] = {x = 0, y = 0}
		},
		[16] = T{ --16-24 to 0-8
			[1] = {x = 0, y = 0}
		}
	},
	[41] = T{ --Dynamis - Qufim
		[0] = T{ --0-8 to 8-16
			[1] = {x = 39, y = -105},
			[2] = {x = 88, y = 34},
			[3] = {x = 76, y = 82},
			[4] = {x = 120, y = 110},
			[5] = {x = 95, y = 161},
			[6] = {x = 64, y = 174},
			[7] = {x = 13, y = 252},
			[8] = {x = 21, y = 275}
		},
		[8] = T{ --8-16 to 16-24
			[1] = {x = 34, y = 270},
			[2] = {x = 60, y = 232},
			[3] = {x = 97, y = 160}
		},
		[16] = T{ --16-24 to 0-8
			[1] = {x = 113, y = 156},
			[2] = {x = 121, y = 115},
			[3] = {x = 77, y = 86},
			[4] = {x = 89, y = 23},
			[5] = {x = 11, y = -85}
		}
	}
}


trusts = T{
	[1] = 'Mayakov',
	[2] = 'Uka Totlihn',
	[3] = 'Koru-Moru',
	[4] = 'Kupipi',
	[5] = 'Apururu (UC)'
}

--event handlers
windower.register_event('addon command', function(...)
	local args = T{...}
    local cmd = args[1]
	if cmd then 
		if cmd:lower() == 'start' then
			if ValidateLocation() == true then
				continue = 1
				MyMoneyAndINeedItNow()
			end
		elseif cmd:lower() == 'stop' then
			windower.add_to_chat(2,'Stopping.')
			continue = 0
		elseif cmd:lower() == 'stepper' then
			Step()
		end
	end
end)

windower.register_event('action message',function (actor_id, target_id, actor_index, target_index, message_id, param_1, param_2, param_3)
	if (message_id == 5) or (message_id == 154) then
		windower.add_to_chat(2,'Disengaging -- unable to see target.')
		windower.send_command('input /a off')
	end
end)

windower.register_event('zone change', function(new_id, old_id)
	if continue == 1 then
		continue = 0
		windower.add_to_chat(2, 'Area changed -- stopping dynafarm')
	end
end)

--functions
function MyMoneyAndINeedItNow()
	--initialization to get to first camp from entrance
	local i = 1
	
	local zone = windower.ffxi.get_info()['zone']
	local vecPlayer
	local vecWaypoint
	local dist
	local tdist = 9999
	local campNum = 0
	local destination
	
	local attackingEnemy
	local mob
	
	coroutine.sleep(startDelay)
	summon(trusts)
	coroutine.sleep(2)
	sneakInvisible()
	
	--TODO: validate zone/location
	--TODO: replace RunToFirstCamp() with statue kills for use outside of dynamis campaigns
	
	RunToFirstCamp(zone)
	
	i = 1
	
	--goto camp
	if getHour() > 0 then
		RunToNextCamp(zone, 0)
		campNum = 8
	end
	
	if getHour() > 8 then
		RunToNextCamp(zone, 8)
		campNum = 16
	end
	
	--i = 1
	
	--fight stuff at camp, check hour
	--check time, then check mobs for time within a distance range, go to center if none found IN RANGE
	--(also make sure mob to be engaged isn't claimed)
	--prioritize unclaimed, attacking mobs within 10 yalms regardless of name
	
	while (continue == 1) do
		if (getHour() ~= campNum) then
			attackingEnemy = true
			while (attackingEnemy == true) do
				mob = GetAggressiveMob(zone)
				if mob["id"] ~= windower.ffxi.get_mob_by_target('me').id then
					--create a function to go here and kill attacking enemy
					Fight(mob)
				else
					attackingEnemy = false
				end
			end
			--go to camp upon time change
			--TODO: check is being attacked before sneakInvisible
			--[[
				check aggro, then
					if closest mob ~= player
						attack
					else
						proceed
			]]
			destination = GetDestination()
			sneakInvisible()
			RunToNextCamp(zone, destination)
			campNum = getHour()
		end
		CureCheck()
		MonsterHunter(zone)
	end
	
end

function checkHPP(threshold)
	local player = windower.ffxi.get_player()
	--local threshold = 60
	if (player.vitals.hpp < threshold) then
		return true
	else
		return false
	end
end

function CureCheck()
	if checkHPP(60) == true then
		windower.send_command('input /ja \"Curing Waltz III\" <me>')
		coroutine.sleep(5)
	end
end

function Step()
	local mob = windower.ffxi.get_mob_by_target('t')
	local tar_id = mob["id"]
	while (mob.hpp > 0) and (mob.valid_target == true) and ((mob.claim_id == 0) or (mob.claim_id == playerID)) do
		mob = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_id(tar_id)
		if (windower.ffxi.get_player().vitals.tp > stepTP) then
			if isReady(stepID) == true then
				windower.send_command('input /ja \"'..step..'\" <t>')
			end
		end
		coroutine.sleep(1)
	end
end

function SimpleStep()
	if (windower.ffxi.get_player().vitals.tp > stepTP) then
		if isReady(stepID) == true then
			windower.send_command('input /ja \"'..step..'\" <t>')
		end
	end
end

function isReady(abilityID)
	if windower.ffxi.get_ability_recasts()[abilityID] > 0 then
		return false
	else
		return true
	end
end

function EngageMob(tar_id)
	--local mob = GetTarget()
	local player = windower.ffxi.get_mob_by_target('me')
	local mob = windower.ffxi.get_mob_by_id(tar_id)
	
	if mob.id ~= player.id then
		engage = packets.new('outgoing', 0x1a, {
		['Target'] = mob.id,
		['Target Index'] = mob.index,
		['Category']     = 0x02,
		})
		
		packets.inject(engage)
	end
end

function Disengage()
	windower.send_command('input /a off')
end

function getHour()
	local currentTime = windower.ffxi.get_info()['time']
	if currentTime < 480 then
		return 0
	elseif currentTime < 960 then
		return 8
	else
		return 16
	end
end

function GetDestination()
	local k = getHour()
	if k == 0 then
		return 16
	elseif k == 8 then
		return 0
	else
		return 8
	end
end

function GoToWaypoint(player, location)
	if continue == 1 then
		local angle = GetAngle(player,location)
		windower.ffxi.run(angle)
	end
end

function GetDistance(player, location)
	return math.sqrt((location.x - player.x)^2 + (location.y - player.y)^2)
end

function GoToMob(playervec, mobvec)
	if continue == 1 then
		coroutine.sleep(0.1)
		local angle = GetAngle(playervec,mobvec)
		windower.ffxi.run(angle)
	end
end

function GetAngle(playervec,mobvec)
	--radians
    angle = (math.atan2(playervec.y-mobvec.y, playervec.x-mobvec.x) * -1) + math.pi
	--print("angle: "..angle.." "..angle/math.pi)
	return angle
end

function summon(trustList)
	local castDelay = 6
	for i = 1,#trustList,1 do
		windower.send_command('input /ma \"'..trustList[i]..'\" <me>')
		coroutine.sleep(castDelay)
	end
end

function sneakInvisible()
	local castDelay = 4
	windower.send_command('input /ja \"Spectral Jig\" <me>')
	coroutine.sleep(castDelay)
end

function RunToFirstCamp(zone)
	local i = 1
	while (i <= #wpStart[zone]) and (continue == 1) do
		vecWaypoint = {x = wpStart[zone][i].x, y = wpStart[zone][i].y}
		dist = 9999
		--debug
		windower.add_to_chat(2,'Going to ['..i..'] -- '..wpStart[zone][i].x..', '..wpStart[zone][i].y)
		while (dist > wpDistance) and (continue == 1) do
			vecPlayer = UpdatePlayerPosition()
			dist = GetDistance(vecPlayer, vecWaypoint)
			GoToWaypoint(vecPlayer, vecWaypoint)
			coroutine.sleep(timeDelay)
			windower.ffxi.run(false)
			--coroutine.sleep(0.1)
		end
		i = i + 1
		--if i > iMax then
		--	i = 1
		--end
	end
end

function RunToNextCamp(zone, destination)
	local i = 1
	while (i <= #wp[zone][destination]) and (continue == 1) do
		vecWaypoint = {x = wp[zone][destination][i].x, y = wp[zone][destination][i].y}
		dist = 9999
		--debug
		windower.add_to_chat(2,'Going to ['..i..'] -- '..wp[zone][destination][i].x..', '..wp[zone][destination][i].y)
		while (dist > wpDistance) and (continue == 1) do
			vecPlayer = UpdatePlayerPosition()
			dist = GetDistance(vecPlayer, vecWaypoint)
			GoToWaypoint(vecPlayer, vecWaypoint)
			coroutine.sleep(timeDelay)
			windower.ffxi.run(false)
			--coroutine.sleep(0.1)
		end
		i = i + 1
	end
end

function UpdatePlayerPosition()
	local player = windower.ffxi.get_mob_by_target('me')
	vecPlayer = {x = player.x, y = player.y}
	return vecPlayer
end

function ValidateLocation()
	local zone = windower.ffxi.get_info()['zone']
	local player = windower.ffxi.get_mob_by_target('me')
	
	if wp[zone] ~= nil then
		vecStart = wp[zone][1]
		windower.add_to_chat(2,'Validated')
		return true
	else
		windower.add_to_chat(2,'Current zone not currently implemented.')
		return false
	end
end

function GetDynamisMob(zone)
	local player = windower.ffxi.get_mob_by_target('me')
	local hour = getHour()
	--local zone = windower.ffxi.get_info()['zone']
	marray = windower.ffxi.get_mob_array()
	
	--just to prevent returning a nil value
	target_id = player.id
	
	local dist = 99999
	
	for i,v in pairs(marray) do
		if ((checkValidTarget(v, hour, zone, player.id) == true) and (v["id"] ~= player.id)) then
			if (v["distance"] < dist) then
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

function checkValidTarget(mob, hour, zone, playerID)
	--if mob = target unclaimed by other player OR attacking non-target unclaimed by another player
	if ((mob["name"] == jaTargets[zone][hour]) and (mob["hpp"] > 0) and (mob["valid_target"] == true) and (math.sqrt(mob["distance"]) < searchRadius) and ((mob["claim_id"] == 0) or (mob["claim_id"] == playerID))) or (((math.sqrt(mob["distance"]) < aggroRadius) and (mob["status"] == 1)) and ((mob["claim_id"] == 0) or (mob["claim_id"] == playerID))) then
		return true
	else
		return false
	end
end

function GetAggressiveMob(zone)
	local player = windower.ffxi.get_mob_by_target('me')
	local hour = getHour()
	--local zone = windower.ffxi.get_info()['zone']
	marray = windower.ffxi.get_mob_array()
	
	--just to prevent returning a nil value
	target_id = player.id
	
	local dist = 99999
	
	for i,v in pairs(marray) do
		if ((checkAggression(v, player.id) == true) and (v["id"] ~= player.id)) then
			if (v["distance"] < dist) then
				dist = v["distance"]
				mobname = v["name"]
				--mobx = v["x"]
				--moby = v["y"]
				target_id = v["id"]
			end
		end
	end
	
	if target_if ~= player.id then
		windower.add_to_chat(2,'Attacking enemy found: '..mobname..' [ID: '..target_id..']')
	end
	
	return target_id
end

function checkAggression(mob, playerID)
	if ((mob["hpp"] > 0) and (mob["valid_target"] == true) and ((math.sqrt(mob["distance"]) < aggroRadius) and (mob["claim_id"] == 0) or (mob["claim_id"] == playerID))) then
		return true
	else
		return false
	end
end

function MonsterHunter(zone)
	local player = windower.ffxi.get_mob_by_target('me')
	local vecPlayer
	local vecMob
	local timeCheck = 0
	local hppCheck = 999
	tar_id = GetDynamisMob(zone)
	local mob = windower.ffxi.get_mob_by_id(tar_id)
	local d = 99999
	local proceed = 0
	
	while (d > atkd) and (tar_id ~= player.id) do
		--update position information
		if continue == 1 then
			mob = windower.ffxi.get_mob_by_id(tar_id)
			player = windower.ffxi.get_mob_by_target('me')
			vecPlayer = {x = player.x, y = player.y}
			vecMob = {x = mob.x, y = mob.y}
			
			GoToMob(vecPlayer,vecMob)
			coroutine.sleep(1)
			windower.ffxi.run(false)
			d = math.sqrt(windower.ffxi.get_mob_by_id(tar_id).distance)
			--to account for new spawns/despawns/claims
			tar_id = GetDynamisMob(zone)
			proceed = 1
		end
	end
	
	if proceed == 1 then
		--update position information
		mob = windower.ffxi.get_mob_by_id(tar_id)
		player = windower.ffxi.get_mob_by_target('me')
		vecPlayer = {x = player.x, y = player.y}
		vecMob = {x = mob.x, y = mob.y}
		--turn
		windower.ffxi.turn(GetAngle(vecPlayer, vecMob))
		--target, attack
		coroutine.sleep(0.2)
		--windower.send_command('input /targetbnpc')
		--windower.send_command('input /a <t>')
		
		EngageMob(mob.id)
		
		--turn, check hpp, and WS
		--I think this is where non-aggressive non-targets have been attacked?
		while (mob.hpp > 0) and (continue == 1) and (mob.valid_target == true) and ((mob.claim_id == 0) or (mob.claim_id == player.id)) do
			mob = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_id(tar_id)
			player = windower.ffxi.get_mob_by_target('me')
			
			CureCheck()
						
			if (player.status == 0) and (math.abs(mob.z - player.z) < 2) then
			--math.abs(mob.z - player.z) < 2 then
				--target and engage if haven't already done so -- in case previous command misses or player has otherwise disengaged
				--don't attack if dHeight too great
				coroutine.sleep(0.1)
				EngageMob(mob.id)
				coroutine.sleep(0.1)
			end
			vecPlayer = {x = player.x, y = player.y}
			vecMob = {x = mob.x, y = mob.y}
			windower.ffxi.turn(GetAngle(vecPlayer, vecMob))
			
			if os.time() > (timeCheck + 12) then
			--Assumes no HP drop during time tick means we aren't actually attacking
				if (hppcheck == mob.hpp) then
					Disengage()
				end
				hppCheck = mob.hpp
				timeCheck = os.time()
				coroutine.sleep(1)
			end
			
			if math.sqrt(mob.distance) > atkd then
				GoToMob(vecPlayer,vecMob)
				coroutine.sleep(1)
				windower.ffxi.run(false)
			elseif math.sqrt(mob.distance) < dmin then
				--back up if too close
				windower.ffxi.run(GetAngle(vecPlayer, vecMob) - math.pi)
				coroutine.sleep(0.3)
				windower.ffxi.run(false)
			else
				SimpleStep()
			end
		end
		coroutine.sleep(1)
	end
end

function Fight(mob)
	--sans steps
	--update position information
		
		player = windower.ffxi.get_mob_by_target('me')
		mob = windower.ffxi.get_mob_by_id(mob.id) or player
		vecPlayer = {x = player.x, y = player.y}
		vecMob = {x = mob.x, y = mob.y}
		--turn
		windower.ffxi.turn(GetAngle(vecPlayer, vecMob))
		--target, attack
		coroutine.sleep(0.2)
		
		EngageMob(mob.id)
		
		--turn, check hpp, and WS
		if mob.id ~= player.id then
			while (mob.hpp > 0) and (continue == 1) and (mob.valid_target == true) and ((mob.claim_id == 0) or (mob.claim_id == player.id)) do
				mob = windower.ffxi.get_mob_by_id(tar_id)
				player = windower.ffxi.get_mob_by_target('me')
				
				CureCheck()
							
				if (player.status == 0) and (math.abs(mob.z - player.z) < 2) then
				--math.abs(mob.z - player.z) < 2 then
					--target and engage if haven't already done so -- in case previous command misses or player has otherwise disengaged
					--don't attack if dHeight too great
					coroutine.sleep(0.1)
					EngageMob(mob.id)
					coroutine.sleep(0.1)
				end
				vecPlayer = {x = player.x, y = player.y}
				vecMob = {x = mob.x, y = mob.y}
				windower.ffxi.turn(GetAngle(vecPlayer, vecMob))
				
				if os.time() > (timeCheck + 12) then
				--Assumes no HP drop during time tick means we aren't actually attacking
					if (hppcheck == mob.hpp) then
						Disengage()
					end
					hppCheck = mob.hpp
					timeCheck = os.time()
					coroutine.sleep(1)
				end
				
				if math.sqrt(mob.distance) > atkd then
					GoToMob(vecPlayer,vecMob)
					coroutine.sleep(1)
					windower.ffxi.run(false)
				elseif math.sqrt(mob.distance) < dmin then
					--back up if too close
					windower.ffxi.run(GetAngle(vecPlayer, vecMob) - math.pi)
					coroutine.sleep(0.3)
					windower.ffxi.run(false)
				elseif windower.ffxi.get_player().vitals.tp > 1000 then
					windower.send_command('input /ws \"'..ws..'\" <t>')
				end
			end
			coroutine.sleep(1)
		end
end

--[[
function GetClosestMob()
	local player = windower.ffxi.get_mob_by_target('me')
	marray = windower.ffxi.get_mob_array()
	
	--just to prevent returning a nil value
	target_id = player.id
	
	local dist = 99999
	
	for i,v in pairs(marray) do
		if (v["name"] == target or v["name"] == target2 or v["name"] == target3 or v["name"] == target4) and (v["hpp"] > 0) and (v["valid_target"] == true) then
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
]]
