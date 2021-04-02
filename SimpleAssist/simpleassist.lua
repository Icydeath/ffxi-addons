_addon.author = 'Icy'
_addon.commands = {'simpleassist','sassist'}
_addon.name = 'SimpleAssist'
_addon.version = '1.0.0'

--local inspect = require('inspect')
local packets = require('packets')


local engage = true
local get_in_range = true
local engage_distance = 2.8 -- will close in until < X yalms from the target.

local verbose = false

local player = windower.ffxi.get_player()
local assisting = nil

function HeadingTo(x, y)
	local p = windower.ffxi.get_mob_by_id(player.id)
	local x = x - p.x
	local y = y - p.y
	local h = math.atan2(x, y)
	return h - 1.5708
end

function TurnToTarget()
	local mob = windower.ffxi.get_mob_by_target('t')
	
	if not mob then
		verbose_msg('TurnToTarget: Invalid target.')
		return 
	end
	
	--verbose_msg('Turning to '..mob.name)
	windower.ffxi.turn(HeadingTo(mob.x, mob.y))
end

function TargetMob(id)
	local mob = windower.ffxi.get_mob_by_id(id)
	
	if not mob then 
		verbose_msg('TargetMob: Invalid target - '..id)
		return 
	end

	verbose_msg('Targeting '..mob.name..' ('..mob.id..')')
	
	packets.inject(packets.new('incoming', 0x058, {
		['Player'] = player.id,
		['Target'] = mob.id,
		['Player Index'] = player.index,
	}))
end

function AssistPlayer()
	if assisting then
		local t = nil
		if assisting == 'bt' then
			t = windower.ffxi.get_mob_by_target('bt')
			if t then TargetMob(t.id) end
		elseif tonumber(assisting) then
			t = windower.ffxi.get_mob_by_id(assisting)
			if t then TargetMob(t.id) end
		else
			windower.send_command('input /assist '..assisting)
		end
	end
end

function EngageTarget(t)
	if not engage then return end
	if not t then t = windower.ffxi.get_mob_by_target('t') end
	
	if t then
		player = windower.ffxi.get_player()
		if player.status == 1 then
			verbose_msg('Already engaged')
			return
		end
		
		if player.status ~= 1 then
			verbose_msg('Engaging > '..t.name)
			local packet = packets.new('outgoing', 0x01A, {
				["Target"]=t.id,
				["Target Index"]=t.index,
				["Category"]=2,
				["Param"]=0,
				["_unknown1"]=0})
			packets.inject(packet)
		end
	end
end

function CloseIn(mobid)
	if not get_in_range then return end
	
	local mob = windower.ffxi.get_mob_by_id(mobid)
	if not mob then
		verbose_msg('')
		return
	end
	local dist = math.sqrt(mob.distance)
	while dist > engage_distance do
		mob = windower.ffxi.get_mob_by_id(mobid)
		TurnToTarget()
		windower.ffxi.run(true)
		dist = math.sqrt(mob.distance)
	end
	
	windower.ffxi.run(false)
end

function run()
	AssistPlayer()
	coroutine.sleep(.5)
	
	local target = windower.ffxi.get_mob_by_target('t')
	if not target then -- try again
		AssistPlayer()
		coroutine.sleep(1)
		target = windower.ffxi.get_mob_by_target('t')
	end
	
	if not target then -- last attempt!
		AssistPlayer()
		coroutine.sleep(1)
		target = windower.ffxi.get_mob_by_target('t')
	end
	
	local self = windower.ffxi.get_mob_by_target('me')
	if not target or target.id == self.id then
		verbose_msg('Unable to assist '..assisting)
		return 
	end
	
	if target.hpp == 0 then
		verbose_msg('Target is dead... Assist cancelled')
		return
	end
	
	verbose_msg('   > Targeting successful')
	
	if not get_in_range and target.distance:sqrt() > 29.5 then 
		verbose_msg('Out of range to engage, closing in.')
		TurnToTarget()
		coroutine.sleep(.5)
		CloseIn(target.id)
	else
		TurnToTarget()
		coroutine.sleep(.5)
	end
		
	player = windower.ffxi.get_player()
	if engage and player.status ~= 1 and player.status ~= 2 and player.status ~= 3 then 
		EngageTarget()
		coroutine.sleep(1)
	end
	-- try again if first attempted failed
	player = windower.ffxi.get_player()
	if engage and player.status ~= 1 and player.status ~= 2 and player.status ~= 3 then 
		EngageTarget()
		coroutine.sleep(1)
	end
 
	CloseIn(target.id)
	coroutine.sleep(1)
	target = windower.ffxi.get_mob_by_target('t')
	
	verbose_msg('= DONE =')
end

function verbose_msg(str)
	if verbose then
		windower.add_to_chat(10, '['..(_addon.name)..'] '..str)
	end
end

function report(str)
	windower.add_to_chat(100, '['..(_addon.name)..'] '..str)
end

function Print_Help()
	report('//sassist {playername} - attempts to assist {playername}, get in range, and engage')
	report('//sassist bt - attempts to target the battle target, get in range, and engage')
	report('//sassist {id} - attempts to target the mob by {id}, get in range, and engage')
	report('[TODO:] //sassist monitor|mon {playername} - monitors the {playername} and assists that player when they are fighting.')
end

function addon_command(...)
	local commands = {...}
	
	if commands[1] and commands[1] == 'help' then
		Print_Help()
		return
	end
		
	-- Run the script if the first command wasn't a toggle
	if commands[1] then
        assisting = commands[1]
		
		player = windower.ffxi.get_player()
		if player.status == 2 or player.status == 3 then verbose_msg('Dead, cancelling request') return end
		
		run()
	end
	
end
windower.register_event('addon command', addon_command)

