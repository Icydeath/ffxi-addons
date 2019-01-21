require 'luau'

_addon.name = 'UNM'
_addon.author = 'Darkdoom, Modified by Icy'
_addon.version = '1.1'
_addon.command = 'unm'
_addon.commands = {'unm'}
_addon.language = 'english'

running = false
mobs = S{"Prickly Pitriv","Bounding Belinda","Hugemaw Harold","Ironhorn Baldurno","Sleepy Mabel","Serpopard Ninlil","Abyssdiver","Immanibugard","Intuila",
	"Jester Malatrix","Orcfeltrap","Sybaritic Samantha","Valkurm Imperator","Cactrot Veloz","Emperor Arthro","Garbage Gel","Joyous Green","Keeper of Heiligtum",
	"Tiyanak","Voso","Warblade Beak","Woodland Mender","Arke","Ayapec","Azure-toothed Clawberry","Bakunawa","Beist","Centurio XX-I","Coca","Douma Weapon",
	"King Uropygid","Kubool Ja's Mhuufya","Largantua","Lumber Jill","Mephitas","Muut","Specter Worm","Strix","Vermillion Fishfly","Azrael","Borealis Shadow",
	"Camahueto","Carousing Celine","Grand Grenade","Vedrfolnir","Vidmapire","Volatile Cluster","Glazemane","Wyvernhunter Bambrox","Hidhaegg","Sovereign Behemoth",
	"Tolba","Thu'ban","Sarama","Shedu","Tumult Curator"}
	
checktimer = 5
capsparkstop = true

function check_incoming_text(original)
	local org = original:lower()
	
	-- [Icy] added the option to continue popping the unm even if sparks are capped.
	if org:find('sparks of eminence, and now possess a total of 99999') ~= nil and capsparkstop then
		running = false
		windower.add_to_chat(167, 'UNM turned off! Sparks are capped.')
	elseif org:find('one or more party/alliance members do not have the required') ~= nil then
		running = false
		windower.add_to_chat(167, 'UNM turned off! Requirements not met.')
	end
end

function check()
	if running == true then
		windower.chat.input("/targetnpc")
		coroutine.sleep(3) -- was 2
	
		if windower.ffxi.get_mob_by_target('t') == nil or windower.ffxi.get_mob_by_target('t').name == nil then
			windower.add_to_chat(167, 'No target found. Running check again.')
			coroutine.sleep(checktimer)
			check()
		elseif windower.ffxi.get_mob_by_target('t').name == "Ethereal Junction" then
			windower.add_to_chat(167, 'Junction found, spawning')
			poke()
			coroutine.sleep(checktimer)
			check()
		elseif mobs:contains(windower.ffxi.get_mob_by_target('t').name) then
			windower.add_to_chat(167, 'Target still alive, sleeping')
			coroutine.sleep(checktimer)
			check()
		else
			coroutine.sleep(checktimer) --was 10
			windower.add_to_chat(167, 'Invalid target. Escaping and rechecking.')
			escapebutton()
			check()	
		end
		
	end
end

function escapebutton()
	windower.send_command('setkey ESCAPE down')
	coroutine.sleep(0.5)
	windower.send_command('setkey ESCAPE up')
	coroutine.sleep(0.5)
end

function poke()
	windower.send_command('setkey enter down')
	coroutine.sleep(0.5)
	windower.send_command('setkey enter up')
	coroutine.sleep(1.5)
	
	windower.send_command('setkey up down')
	coroutine.sleep(0.5)
	windower.send_command('setkey up up')
	coroutine.sleep(0.5)
		
	
	
	windower.send_command('setkey enter down')
	coroutine.sleep(0.5)
	windower.send_command('setkey enter up')
	coroutine.sleep(0.5)
	
	windower.send_command('setkey up down')
	coroutine.sleep(0.5)
	windower.send_command('setkey up up')
	coroutine.sleep(0.5)
	
	windower.send_command('setkey enter down')
	coroutine.sleep(0.5)
	windower.send_command('setkey enter up')
	coroutine.sleep(0.5)
	
	
	windower.chat.input("/targetnpc")
	coroutine.sleep(0.5)
	
	if mobs:contains(windower.ffxi.get_mob_by_target('t').name) then -- Added by Icy 1/7/19
		windower.chat.input("/attack")
	elseif windower.ffxi.get_mob_by_target('t').name ~= nil then
		escapebutton()
	end
	
	if running == true then
		coroutine.sleep(checktimer)
		check()
	else
		windower.add_to_chat(167, 'Stopping UNM during poke()')

	end
end


function unm_command(...)
	if #arg > 3 then
		windower.add_to_chat(167, 'Invalid command. //unm help for valid options.')
	elseif #arg == 1 and arg[1]:lower() == 'start' then
		if running == false then
			running = true
			windower.add_to_chat(200, 'UNM - START')
			check()
		else
			windower.add_to_chat(200, 'UNM is already running.')
		end
	elseif #arg == 1 and arg[1]:lower() == 'stop' then
		if running == true then
			running = false
			windower.add_to_chat(200, 'UNM - STOP')
		else
			windower.add_to_chat(200, 'UNM is not running.')
		end
	elseif arg[1]:lower() == 'timer' then
		checktimer = arg[2]
		windower.add_to_chat(200, 'UNM - timer set to ' .. checktimer .. ' seconds.')
	elseif arg[1]:lower() == 'sparks' then
		if arg[2]:lower() == 'on' then
			windower.add_to_chat(200, 'UNM - Auto stopping when capped on sparks.')
			capsparkstop = true
		else
			windower.add_to_chat(200, 'UNM - Script will continue to pop even if sparks are capped.')
			capsparkstop = false
		end
	elseif #arg == 1 and arg[1]:lower() == 'help' then
		windower.add_to_chat(200, 'Available Options:')
		windower.add_to_chat(200, '  //unm start - turns on UNM and starts trying to spawn')
		windower.add_to_chat(200, '  //unm stop - turns off UNM')
		windower.add_to_chat(200, '  //unm timer # - set timer between checks')
		windower.add_to_chat(200, '  //unm sparks on/off - set to ON if you want to keep popping even if your sparks are capped.')
		windower.add_to_chat(200, '  //unm help - displays this text')
	end
end


windower.register_event('addon command', unm_command)
windower.register_event('incoming text', function(new, old)
	local info = windower.ffxi.get_info()
	if not info.logged_in then
		return
	else
		check_incoming_text(new)
	end
end)