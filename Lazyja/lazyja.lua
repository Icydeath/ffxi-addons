--[[

Copyright © 2018, Myrchee of Quetzalcoatl
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Lazyja nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Myrchee BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]



_addon.name = 'lazyja'
_addon.author = 'Myrchee'
_addon.version = '1.3'
_addon.command = 'lazyja'

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


delay = 6  -- time (seconds) between spells
maxDistance = 20 --yalms

--/equipsets
dtSet = 59
magSet = 60
enhSet = 50
cureSet = 46

buff_list = T{
	[1] = 'Haste',
	[2] = 'Phalanx',
	[3] = 'Ice Spikes'
}

aoe_list = T{
	[1] = 'Blizzaja', 
	[2] = 'Thundaja',
	[3] = 'Firaja'
}
aoecount = 3

--[[
target_mobs = T{
	[1] = 'Eschan Mosquito',
	[2] = 'Eschan Shadow Dragon',
	[3] = 'Eschan Puk'
}
]]--

continue = 0
loopcount = 0

windower.register_event('addon command', function(...)
	local args = T{...}
    local cmd = args[1]
	if cmd then 
		if cmd:lower() == 'start' then
			continue = 1
			windower.send_command('input /equipset '..dtSet)
			coroutine.sleep(1)
		elseif cmd:lower() == 'stop' then
			continue = 0
		end
	end
	
	while continue == 1 do
		pewpew()
	end
end)


--windower.register_event('lose buff',)

function buffactive(...)
	local args = S{...}:map(string.lower)
	local player = windower.ffxi.get_player()
	if (player ~= nil) and (player.buffs ~= nil) then
		for _,bid in pairs(player.buffs) do
			local buff = res.buffs[bid]
			if args:contains(buff.en:lower()) then
				return true
			end
		end
	end
	return false
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

function checkMPP(threshold)
	local player = windower.ffxi.get_player()
	--local threshold = 60
	if (player.vitals.mpp < threshold) then
		return true
	else
		return false
	end
end

function GetAngle(playervec,mobvec)
	--radians
    angle = (math.atan2(playervec.y-mobvec.y, playervec.x-mobvec.x) * -1) + math.pi
	print("angle: "..angle.." "..angle/math.pi)
	return angle
end

function TurnToClosest()
	player = windower.ffxi.get_mob_by_target('me')
	marray = windower.ffxi.get_mob_array()
	
	target_id = -1
	local dist = 999999
	local mobx
	local moby
	local mobname
	local angle
	
	
	for i,v in pairs(marray) do
		if (v["name"] ~= player.name) and (v["name"] ~= "Emblazoned Reliquary") and (v["distance"] > 0) and (v["valid_target"]) and (v["in_party"] == false) then
			if v["distance"] < dist then
				dist = v["distance"]
				mobname = v["name"]
				mobx = v["x"]
				moby = v["y"]
				target_id = v["id"]
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
	
	return target_id
end

function pewpew()
	--TODO: move TurnToClosest() and only cast buffs if nothing is nearby
	--windower.add_to_chat(2,'Starting')
	--while continue == 1 do
		--Cure if needed
		if checkHPP(65) then
			windower.send_command('input /equipset '..cureSet)
			windower.send_command('input /ma \"Cure IV\" <me>')
			coroutine.sleep(delay)
		elseif checkMPP(30) and not checkHPP(85) then
			windower.send_command('input /equipset '..dtSet)
			windower.send_command('input /ja Convert <me>')
			coroutine.sleep(2)
		else
			--TODO: check for close enemies before casting buffs
			for i,v in pairs(buff_list) do
				--check if buff timer is <30sec or gone, if so, recast here
				if not buffactive(buff_list[i]) then
					windower.send_command('input /equipset '..enhSet)
					windower.send_command('input /ma \"'..buff_list[i]..'\" <me>')
					coroutine.sleep(delay)
				--end
				else
					coroutine.sleep(1)
				end
			end
			
			--if not checkHPP(65) then
				local target_id = TurnToClosest()
				if target_id > 0 then
					local mob = windower.ffxi.get_mob_by_id(target_id)
					if math.sqrt(mob.distance) < maxDistance then
					
						windower.send_command('input /equipset '..magSet)
						windower.send_command('input /ma '..aoe_list[1 + math.fmod(loopcount, aoecount)]..' <t>')
						coroutine.sleep(delay)
						windower.send_command('input /equipset '..dtSet)
					
						if loopcount == aoecount * 10 then
							loopcount = 1
						else
							loopcount = loopcount + 1
						end
					end
				end
			--end
			
			--[[
			for i,v in pairs(aoe_list) do
				if checkRecast(v) then
					windower.send_command('input /equipset '..magSet)
					windower.send_command('input /ma '..v..' <t>')
					coroutine.sleep(delay)
					break; --stops trying to cast when a spell is ready, this is probably a terrible way to do it but oh well
				end
			end
			]]--
				--[[
					Not worth it
				local mob = Nearest_Target()
				--local mob = Nearest_Mob()
				
				if (mob > 0) then
					--local tgtmob = marray[id_targ]
					windower.add_to_chat(2,mob.index)
					--if (mob["distance"] < maxDistance) then
						--mob = windower.ffxi.get_mob_by_id(tonumber(mob_id))
						--windower.add_to_chat("coords: " .. (mob.x)) --.. mob.y
						--FaceEnemy(mob["x"], mob["y"])
						--windower.ffxi.follow(mob)
						
						windower.send_command("input /targetbnpc")
						for i,v in pairs(aoe_list) do
							if checkRecast(v) then
								windower.send_command('input /equipset '..magSet)
								windower.send_command('input /ma '..v..' <t>')
								coroutine.sleep(delay)
								break; --stops trying to cast when a spell is ready, this is probably a terrible way to do it but oh well
							end
						end
					--end
				end
				]]--
				--[[]
				if (windower.ffxi.get_mob_by_target('t').id ~= nil) then
					local mob = windower.ffxi.get_mob_by_target('t')
					for i,v in pairs(aoe_list) do
						if checkRecast(v) then
							windower.send_command('input /equipset '..magSet)
							windower.send_command('input /ma '..v..' <t>')
							coroutine.sleep(delay)
							if (mob.hpp==0) then
								windower.send_command('input /equipset '..dtSet)
								break
							end
						end
					end
				end
				]]--
					
				--windower.send_command('input /ma ',spell_list[math.fmod(loopcount, 3)],' <t>')
				--end
		end
	--end
end
