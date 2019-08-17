_addon.name = 'Canteen'
_addon.author = 'KateFFXI'
_addon.version = '1.0.0.1'
_addon.command = 'canteen'

require('tables')
require('logger')
require('functions')
res = require('resources')


local conditions = {
	running = false,
}

windower.register_event('addon command', function(input, ...)
    local cmd = string.lower(input)
	local args = {...}
	
	if cmd == 'get' then
		canteen()
    end

end)


function canteen()

	log('Target NPC')
	tp = windower.ffxi.get_mob_by_name('Incantrix')
	windower.send_command('settarget ' .. tp.id)
	coroutine.sleep(1)
	windower.send_command('input /lockon')
	coroutine.sleep(1)
	
	log('Run')
	windower.ffxi.run(true)

	conditions['running'] = true
		while conditions['running'] do
			local distance
			distance = windower.ffxi.get_mob_by_name('Incantrix').distance
			if math.sqrt(distance)<5 then
				conditions['running'] = false
			end
			coroutine.sleep(0.3)
		end

	log('Getting Canteen')
	coroutine.sleep(1)
	windower.send_command('setkey enter down')
	coroutine.sleep(.5)
	windower.send_command('setkey enter up')
	coroutine.sleep(3)
	windower.send_command('setkey enter down')
	coroutine.sleep(.5)
	windower.send_command('setkey enter up')
	coroutine.sleep(3)
	windower.send_command('setkey enter down')
	coroutine.sleep(.5)
	windower.send_command('setkey enter up')
	coroutine.sleep(3)
	windower.send_command('setkey enter down')
	coroutine.sleep(.5)
	windower.send_command('setkey enter up')
	

end