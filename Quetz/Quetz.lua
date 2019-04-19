-- Modified by Icy, added the ability to run to the set target and attack it.

_addon.author   = 'Kaotic, modified by Icy'
_addon.version  = '1.2.1'
_addon.commands = {'Quetz'}

require('logger')
require('coroutine')
packets = require('packets')
res = require('resources')

info = {}
info.settings = {}
info.settings.target = 'Quetzalcoatl'

local conditions = {

	quetzPortal = false,
	goblin = false,
	reisenPortal = false,
	running = false,
	quetzAlive = false,
	quetzDead = false,
	
}

function stop()
	windower.send_command('lua unload quetz;wait .5;lua load enternity')
end


function start()
	log('Summoning Trusts')
	coroutine.sleep(1)
	--Here is where you can edit the trust list that you wish to summon
	--Remove the -- infront of the lines if you want to use additional trusts, I use 4 of the same ones for each character and use easyfarm to summon the other character specific one.
	--If you use easyfarm for trusts, put -- in front of each line 246-254, but I recommend putting them in the Battle tab.
	
	windower.send_command('input /ma "Apururu (UC)" <me>')
	coroutine.sleep(6)
	windower.send_command('input /ma "Joachim" <me>')
	coroutine.sleep(6)
	windower.send_command('input /ma "Qultada" <me>')
	coroutine.sleep(6)
	windower.send_command('input /ma "selh\'teus"')
	coroutine.sleep(6)
	windower.send_command('input /ma "king of hearts" <me>')
	coroutine.sleep(5)
	
	log('Waiting for pop zZz...')
	--coroutine.sleep(15)
	
	local quetz = windower.ffxi.get_mob_by_name(info.settings.target)	
	quetzDead = true
	
	while quetzDead do
		if quetz.hpp > 0 then
			windower.send_command('timers delete "Quetz:"')
			quetzDead = false
		end
		coroutine.sleep(.25)
		quetz = windower.ffxi.get_mob_by_name(info.settings.target)
	end
	log('Quetz popped attack it!')
	fight()
end


function fight()
	coroutine.sleep(1)
	log('Attempting to fight quetz...')
	
	local player = windower.ffxi.get_player()
	local quetz = windower.ffxi.get_mob_by_name(info.settings.target)
	quetzAlive = true
	
	while quetzAlive do
		if quetz.hpp == 0 then
			windower.send_command('timers create "Quetz:" 900 down fire')
			quetzAlive = false
		end
		coroutine.sleep(.25)
		
		quetz = windower.ffxi.get_mob_by_name(info.settings.target)
		player = windower.ffxi.get_player()
		
		if player.status ~= 1 and quetz.hpp ~= 0 and player.vitals.hp ~= 0 then
			log('Targeting, locking on, attacking, and getting closer...')
			windower.send_command("input /targetbnpc;wait 1;input /lockon;wait 1;input /attack on;wait 2;input /follow;wait 4;setkey numpad2 down;wait .1;setkey numpad2 up")
			coroutine.sleep(10)
		end
		
	end
	exitArena()
end

function exitArena()
	local player = windower.ffxi.get_player()
	
	if player.vitals.hp == 0 then
		log('You died, raising...')
		coroutine.sleep(1)
		windower.send_command('setkey enter down')
		coroutine.sleep(.05)
		windower.send_command('setkey enter up')
		coroutine.sleep(3)
		
		log("I'm alive! Equiping ring to teleport.")
		coroutine.sleep(1)

		windower.send_command('input /equip ring2 "Dim. Ring (Holla)"')
		coroutine.sleep(15)
		log("Teleporting...")
		windower.send_command('input /item "Dim. Ring (Holla)" <me>')
		coroutine.sleep(45)
		enterReisen()
	else
		log("Fight's over, equiping ring to teleport.")
		coroutine.sleep(1)

		windower.send_command('input /equip ring2 "Dim. Ring (Holla)"')
		coroutine.sleep(15)
		log("Teleporting...")
		windower.send_command('input /item "Dim. Ring (Holla)" <me>')
		coroutine.sleep(45)
		enterReisen()
	end
end


function enterReisen()
	log('Entering Reisenjima in 1 minute.')
	
	coroutine.sleep(45)
	windower.send_command('setkey numpad8 down;wait 1.5;setkey numpad8 up;wait 1;ew z')
	coroutine.sleep(15)
	
	--[[ -- this bombs out for me.
	local me = windower.ffxi.get_mob_by_target('me')
	local tp = windower.ffxi.get_mob_by_name('Dimensional Portal')
	
	windower.ffxi.run(tp.x - me.x, tp.y - me.y, tp.z - me.z)
	conditions['running'] = true
	while conditions['running'] do
		if(math.sqrt(tp.distance)) < 3 then
			conditions['running'] = false
		end
		tp = windower.ffxi.get_mob_by_name('Dimensional Portal')
	end
	windower.ffxi.run(false)
    ]]
    --windower.send_command('input //ew z')
	
	
	log('Obtaining Elvorseal in 5 minutes...')
	windower.send_command('timers create "Elvorseal:" 300 down fire')
	coroutine.sleep(300)
	windower.send_command('timers delete "Elvorseal:"')
	enterArena()
end


function enterArena()
	log('Obtaining Elvorseal')
	
	local gob = windower.ffxi.get_mob_by_name('Shiftrix')
    if gob then
        local p = packets.new('outgoing', 0x01A, {
            ['Target'] = gob.id,
            ['Target Index'] = gob.index,
        })
        packets.inject(p)
    end
	
	coroutine.sleep(5)
	
	windower.send_command('setkey enter down')
	coroutine.sleep(.05)
	windower.send_command('setkey enter up')
	coroutine.sleep(2)
	
	windower.send_command('setkey down down')
	coroutine.sleep(.05)
	windower.send_command('setkey down up')
	coroutine.sleep(2)
	
	windower.send_command('setkey enter down')
	coroutine.sleep(.05)
	windower.send_command('setkey enter up')
	coroutine.sleep(5)
	
	windower.send_command('setkey enter down')
	coroutine.sleep(.05)
	windower.send_command('setkey enter up')
	coroutine.sleep(2)
	
	windower.send_command('setkey enter down')
	coroutine.sleep(.05)
	windower.send_command('setkey enter up')
	coroutine.sleep(2)
	
	windower.send_command('setkey enter down')
	coroutine.sleep(.05)
	windower.send_command('setkey enter up')
	coroutine.sleep(2)
	
	windower.send_command('setkey enter down')
	coroutine.sleep(.05)
	windower.send_command('setkey enter up')
	coroutine.sleep(5)
	
	windower.send_command('setkey up down')
	coroutine.sleep(.05)
	windower.send_command('setkey up up')
	coroutine.sleep(2)
	
	windower.send_command('setkey enter down')
	coroutine.sleep(.05)
	windower.send_command('setkey enter up')
	coroutine.sleep(2)
	
	windower.send_command('setkey enter down')
	coroutine.sleep(.05)
	windower.send_command('setkey enter up')
	coroutine.sleep(2)
	
	log('Elvorseal obtained, moving to fighting location in 15 seconds.')
	coroutine.sleep(15)
	
	moveToLocation()
end


function moveToLocation()
	log('Moving to pull location.')
	-- Spin camara a little, run forward for 4 seconds
	windower.send_command('setkey left down;wait .1;setkey left up;wait .5;setkey numpad8 down;wait 5;setkey numpad8 up')
	coroutine.sleep(7)
	log('Arrived at pull location.')
	coroutine.sleep(1)
	
	start()
end

function test()
	local zone = windower.ffxi.get_info()
	log(zone.zone)
end

windower.register_event('load', function()
	windower.send_command('lua load eschawarp;wait 1;lua unload enternity')
end)

windower.register_event('addon command', function(input, ...)
    local cmd = string.lower(input)
	local args = {...}
	
	if cmd == 'stop' then
		stop()
    elseif cmd == 'start' then
		start()
	elseif cmd == 'exit' then
		exitArena()
	elseif cmd == 'enter' then
		enterArena()
	elseif cmd == 'move' then
		moveToLocation()
	elseif cmd == 'test' then
		test()
	elseif cmd == 'fight' then
		fight()
	elseif cmd == 'reisen' then
		enterReisen()
    end
end)