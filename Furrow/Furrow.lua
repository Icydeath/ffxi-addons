_addon.name = 'Furrow'
_addon.author = 'Algar'
_addon.version = '1.0'
_addon.language = 'english'
_addon.commands = {'furrow'}

require('logger')
require('coroutine')

notice('Please note that Furrow requires all three Garden Furrows to be unlocked for proper operation. Refer to the readme for more information.')

running = false

function loop()
	if running == true then
		windower.add_to_chat(200, 'Furrow: Starting the planting cycle.')
		plantcycle()
		coroutine.sleep (2)
		running = true
		windower.add_to_chat(200, 'Furrow: Sleeping for an hour before the harvest.')
		coroutine.sleep (600)
		windower.add_to_chat(200, 'Reminder: Furrow will commence harvest in fifty minutes. Use //furrow abort to cancel.')
		coroutine.sleep (600)
		windower.add_to_chat(200, 'Reminder: Furrow will commence harvest in forty minutes. Use //furrow abort to cancel.')
		coroutine.sleep (600)
		windower.add_to_chat(200, 'Reminder: Furrow will commence harvest in thiry minutes. Use //furrow abort to cancel.')
		coroutine.sleep (600)
		windower.add_to_chat(200, 'Reminder: Furrow will commence harvest in twenty minutes. Use //furrow abort to cancel.')
		coroutine.sleep (600)
		windower.add_to_chat(200, 'Reminder: Furrow will commence harvest in ten minutes. Use //furrow abort to cancel.')
		coroutine.sleep (600)
		windower.add_to_chat(200, 'Furrow: Starting the harvesting cycle.')
		harvestcycle()
		coroutine.sleep (2)
		windower.add_to_chat(200, 'Furrow: Cycle complete! Restarting the loop shortly...')
		running = true
		coroutine.sleep(5)
		loop()
	else
		windower.add_to_chat(200, 'Something went wrong! Please try your command again after reloading Furrow.')
		end
end

function target1()
	windower.send_command('setkey TAB down')
    coroutine.sleep(0.5)
    windower.send_command('setkey TAB up')
    coroutine.sleep(0.5)
		
		player = windower.ffxi.get_player()
		
		if windower.ffxi.get_mob_by_target( 't' ) == nil then
            windower.add_to_chat(200, 'Furrow: No target, cycling.' )
			coroutine.sleep (0.5)
			target1()
		elseif windower.ffxi.get_mob_by_target('t').name == "Garden Furrow" then
			windower.add_to_chat(200, 'Furrow: Found the first furrow.')
        else
            coroutine.sleep(0.5)
			target1()
		end
end	
	
function target2()
	windower.send_command('setkey TAB down')
    coroutine.sleep(0.5)
    windower.send_command('setkey TAB up')
    coroutine.sleep(0.5)
		
		player = windower.ffxi.get_player()
		
		if windower.ffxi.get_mob_by_target( 't' ) == nil then
            windower.add_to_chat(200, 'Furrow: No target, cycling.' )
			coroutine.sleep (0.5)
			target2()
		elseif windower.ffxi.get_mob_by_target('t').name == "Garden Furrow #2" then
			windower.add_to_chat(200, 'Furrow: Found the second furrow.')
        else
            coroutine.sleep(0.5)
			target2()
		end
end	

function target3()
	windower.send_command('setkey TAB down')
    coroutine.sleep(0.5)
    windower.send_command('setkey TAB up')
    coroutine.sleep(0.5)
		
		player = windower.ffxi.get_player()
		
		if windower.ffxi.get_mob_by_target( 't' ) == nil then
            windower.add_to_chat( 200, 'Furrow: No target, cycling.' )
			coroutine.sleep (0.5)
			target3()
		elseif windower.ffxi.get_mob_by_target('t').name == "Garden Furrow #3" then
			windower.add_to_chat(200, 'Furrow: Found the third furrow.')
        else
            coroutine.sleep(0.5)
			target3()
		end
end	

function plant()
		windower.add_to_chat(200, 'Furrow: Planting a revival root.')
		windower.chat.input("/item \"Revival Root\" <t>")
		coroutine.sleep(5)
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(2)
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(2)
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(5)
		windower.send_command('setkey escape down')
		coroutine.sleep(0.5)
		windower.send_command('setkey escape up')
		coroutine.sleep(0.5)
end			

function harvest()
		windower.add_to_chat(200, 'Furrow: Harvesting this furrow.')
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(5)
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(2)
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(2)
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(2)
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(5)
		windower.send_command('setkey escape down')
		coroutine.sleep(0.5)
		windower.send_command('setkey escape up')
		coroutine.sleep(0.5)
end

function harvestcycle()
	if running == true then
		windower.add_to_chat(200, 'Furrow: Searching for the first furrow.')
		target1()
		coroutine.sleep(2)
		harvest()
		coroutine.sleep(2)
		windower.add_to_chat(200, 'Furrow: Searching for the second furrow.')
		target2()
		coroutine.sleep(2)
		harvest()
		coroutine.sleep(2)
		windower.add_to_chat(200, 'Furrow: Searching for the third furrow.')
		target3()
		coroutine.sleep(2)
		harvest()
		coroutine.sleep(2)
		running = false
		windower.add_to_chat(200, 'Furrow: Harvesting Complete!')
	else
		windower.add_to_chat(200, 'Furrow: Something went wrong! Please try your command again after reloading Furrow.')
		end
end

function plantcycle()
	if running == true then
		windower.add_to_chat(200, 'Furrow: Searching for the first furrow.')
		target1()
		coroutine.sleep(2)
		plant()
		coroutine.sleep(2)
		windower.add_to_chat(200, 'Furrow: Searching for the second furrow.')
		target2()
		coroutine.sleep(2)
		plant()
		coroutine.sleep(2)
		windower.add_to_chat(200, 'Furrow: Searching for the third furrow.')
		target3()
		coroutine.sleep(2)
		plant()
		coroutine.sleep(2)
		running = false
		windower.add_to_chat(200, 'Furrow: Planting Complete!')
	else
		windower.add_to_chat(200, 'Furrow: Something went wrong! Please try your command again after reloading Furrow.')
		end
end

function furrow_command(...)
    if #arg > 1 then
        windower.add_to_chat(167, 'Invalid command.')
    elseif #arg == 1 and arg[ 1 ]:lower() == 'start' then
        if running == false then
            running = true
            windower.add_to_chat(200, 'Furrow: Begin loop...')
            loop()
        elseif running == true then
            windower.add_to_chat(200, 'It appears Furrow is already running an action, please use //furrow abort to reload the addon and try again.')
        end
    elseif #arg == 1 and arg[ 1 ]:lower() == 'stop' then
        if running == false then
            windower.add_to_chat(200, 'Furrow: There are no current actions to stop. Use //furrow abort to force-reload the addon if necessary.')
		elseif running == true then
			windower.add_to_chat(200, 'Furrow: Aborting all actions and reloading.')
			windower.send_command('lua reload furrow')
        end
	elseif #arg == 1 and arg[ 1 ]:lower() == 'plant' then
		if running == false then
            windower.add_to_chat(200, 'Furrow: Starting a single planting cycle.')
			running = true			
			plantcycle()
		elseif running == true then
            windower.add_to_chat(200, 'It appears Furrow is already running an action, please use //furrow abort to reload the addon and try again.')
		end
	elseif #arg == 1 and arg[ 1 ]:lower() == 'harvest' then
		if running == false then
            windower.add_to_chat(200, 'Furrow: Starting a single harvesting cycle.')
			running = true
			harvestcycle()
		elseif running == true then
            windower.add_to_chat(200, 'It appears Furrow is already running an action, please use //furrow abort to reload the addon and try again.')
		end
	elseif #arg == 1 and arg[ 1 ]:lower() == 'abort' then
        windower.add_to_chat(200, 'Furrow: Aborting all actions and reloading.')
		windower.send_command('lua reload furrow')
	elseif #arg == 1 and arg[ 1 ]:lower() == 'help' then
        windower.add_to_chat(200, 'Furrow commands: start stop abort plant harvest. See readme for additional information.')
	else
		end
end

windower.register_event('addon command', furrow_command)