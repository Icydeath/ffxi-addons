_addon.name = 'Multictrl'
_addon.author = 'Kate'
_addon.version = '1.2.0.5'
_addon.commands = {'multi','mc'}

require('functions')
require('logger')
config = require('config')
packets = require('packets')
require('coroutine')
res = require('resources')

settings = config.load(defaults)

isCasting = false
ipcflag = false
currentPC=windower.ffxi.get_player()
new = 0
old = 0

windower.register_event('status change', function(a, b)
	new = a
	old = b
end)

windower.register_event('incoming chunk', function(id, data)
    if id == 0x028 then
        local action_message = packets.parse('incoming', data)
		if action_message["Category"] == 4 then
			isCasting = false
		elseif action_message["Category"] == 8 then
			isCasting = true
		end
	end
end)

windower.register_event('addon command', function(input, ...)
    local cmd = string.lower(input)
	local args = {...}
	local cmd2 = args[1]
	
	
	if cmd == 'on' then
		on()
	elseif cmd == 'off' then
		off()
	elseif cmd == 'fon' then
		followon()
	elseif cmd == 'foff' then
		followoff()
	elseif cmd == 'warp' then
		warp()
	elseif cmd == 'omen' then
		omen()
	elseif cmd == 'mount' then
		mount()
	elseif cmd == 'dismount' then
		dismount()
	elseif cmd == 'refresh' then
		refresh()
	elseif cmd == 'reload' then
		reload(cmd2)
	elseif cmd == 'd2' then
		d2()
	elseif cmd == 'unload' then
		unload(cmd2)
    end
end)


function refresh()

	log('Reloading addons')
	windower.send_command('lua r healbot')
	windower.send_command('gs enable all')
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('refresh')
	end
	ipcflag = false
end

function unload(addonarg)

	log('Unloading Specific ADDON')
	windower.send_command('lua u ' ..addonarg)
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('unload ' ..addonarg)
	end
	ipcflag = false
end

function reload(addonarg)

	log('Reload Specific ADDON')
	windower.send_command('lua r ' ..addonarg)
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('reload ' ..addonarg)
	end
	ipcflag = false
end

function d2()

	player = windower.ffxi.get_player()
	get_spells = windower.ffxi.get_spells()
	spell = S{player.main_job_id,player.sub_job_id}[4] and (get_spells[261] 
		and {japanese='デジョン',english='"Warp"'} or get_spells[262] 
		and {japanese='デジョンII',english='"Warp II"'})
	
	if spell then
	-- Ok have right job/sub job and spells

		for k, v in pairs(windower.ffxi.get_party()) do
		
			if type(v) == 'table' then
				if v.name ~= currentPC.name then
				
					coroutine.sleep(1)
				
					ptymember = windower.ffxi.get_mob_by_name(v.name)
					-- check if party member in same zone.

					if v.mob == nil then
						-- Not in zone.
						log(v.name .. ' is not in zone, skipping')
						coroutine.sleep(0.5)
					else
						-- In zone, do distance check
						if math.sqrt(ptymember.distance) < 18 then
							-- Checking recast
							isWaiting = true
							RCast = windower.ffxi.get_spell_recasts()

							while isWaiting == true do
								coroutine.sleep(0.75)
								
								RCast = windower.ffxi.get_spell_recasts()
								
								if (RCast[262] == 0 ) then
									
									--Check MP
									playernow = windower.ffxi.get_player()
									checkmp = playernow.vitals.mp >= 150

									if checkmp then
										--check if resting
										if (new == 33 and old == 0) then
											windower.send_command('input /heal')
										end
										isWaiting = false
									else --Rest for MP
										
										--check if resting
										if (new == 33 and old == 0) then --Already resting
											
										elseif (new == 0 and old == 0) then
											log('Resting for MP')
											windower.send_command('input /heal')
											coroutine.sleep(3)
										else -- idle
											log('Resting for MP')
											windower.send_command('input /heal')
											coroutine.sleep(3)
										end
										isWaiting = true
									end
								end
								
							end
						
								isWaiting = true								
								coroutine.sleep(1.5)
								windower.send_command('input /ma "Warp II" ' .. v.name)
								coroutine.sleep(1)
								log('Warping ' .. v.name)
								
								--Check if still casting		
								while isCasting do
									coroutine.sleep(0.5)
								end

						else
							log(v.name .. ' is too far to warp, skipping')
							coroutine.sleep(0.5)
						end
					end

				end
				
			end
		end

		-- Warp self
	
		coroutine.sleep(1.5)
		isWaiting = true
		RCast = windower.ffxi.get_spell_recasts()
	
		while isWaiting == true do
			coroutine.sleep(0.75)
			RCast = windower.ffxi.get_spell_recasts()
			
			if (RCast[262] == 0 ) then
									
				--Check MP
				playernow = windower.ffxi.get_player()
				checkmp = playernow.vitals.mp >= 100

				if checkmp then
					--check if resting
					if (new == 33 and old == 0) then
						windower.send_command('input /heal')
					end
					isWaiting = false
				else --Rest for MP
					
					--check if resting
					if (new == 33 and old == 0) then --Already resting
						
					elseif (new == 0 and old == 0) then
						log('Resting for MP')
						windower.send_command('input /heal')
						coroutine.sleep(3)
					else -- idle
						log('Resting for MP')
						windower.send_command('input /heal')
						coroutine.sleep(3)
					end
					isWaiting = true
				end
			end
			
		end

		coroutine.sleep(1.5)
		log('Warping')
		windower.send_command('input /ma "Warp" ' .. currentPC.name)
		
	else
		log('Not BLM main or sub or no warp spells!')
	end
	
end

function omen()

	log('Teleporting to Omen')
	windower.send_command('myomen')
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('omen')
	end
	ipcflag = false
end

function mount()

	log('Mounting Red Crab')
	windower.send_command('input /mount \'Red Crab\'')
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('mount')
	end
	ipcflag = false
end

function dismount()
	log('Dismounting.')
	windower.send_command('input /dismount')
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('dismount')
	end
	ipcflag = false
end

function warp()
	log('Warping!')
	windower.send_command('warp')
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('warp')
	end
	ipcflag = false
end

function on()
	log('Turning on addon stuff...')
	windower.send_command('hb on')
	windower.send_command('geo on')
	windower.send_command('roller on')
	windower.send_command('singer on')
	--windower.send_command('gs c toggle AutoTankMode')
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('on')
	end
	ipcflag = false
end

function off()
	log('Turning off addon stuff...')
	windower.send_command('hb off')
	windower.send_command('geo off')
	windower.send_command('roller off')
	windower.send_command('singer off')
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('off')
	end
	ipcflag = false
end

function followon(namearg)
	log('Follow ON')

	if ipcflag == false then
		--ipcflag = true
		windower.send_command('hb follow off')
		windower.send_ipc_message('followon ' .. currentPC.name)
	elseif ipcflag == true then
		windower.send_command('hb follow ' .. namearg)
	end
	ipcflag = false
	
end


function followoff()
	log('Follow OFF')
	windower.send_command('hb follow off')
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('followoff')
	end
	ipcflag = false
end



local function get_delay()
    local self = windower.ffxi.get_player().name
    local members = {}
    for k, v in pairs(windower.ffxi.get_party()) do
        if type(v) == 'table' then
            members[#members + 1] = v.name
        end
    end
    table.sort(members)
    for k, v in pairs(members) do
        if v == self then
            return (k - 1) * settings.send_all_delay
        end
    end
end


windower.register_event('ipc message', function(msg) 
	local args = msg:split(' ')
	local cmd = args[1]
	local cmd2 = args[2]
	args:remove(1)
	local delay = get_delay()
	
	if cmd == 'mount' then
		log('IPC Mount')
		coroutine.sleep(delay)
		ipcflag = true
		mount()
	elseif cmd == 'dismount' then
		log('IPC Dismount')
		coroutine.sleep(delay)
		ipcflag = true
		dismount()
	elseif cmd == 'warp' then
		log('IPC Warp')
		coroutine.sleep(delay)
		ipcflag = true
		warp()
	elseif cmd == 'on' then
		log('IPC Turn ON')
		coroutine.sleep(delay)
		ipcflag = true
		on()
	elseif cmd == 'off' then
		log('IPC Turn OFF')
		coroutine.sleep(delay)
		ipcflag = true
		off()
	elseif cmd == 'omen' then
		log('IPC Omen')
		coroutine.sleep(delay)
		ipcflag = true
		omen()
	elseif cmd == 'followoff' then
		log('IPC Follow OFF')
		coroutine.sleep(delay)
		ipcflag = true
		followoff()
	elseif cmd == 'followon' then
		log('IPC Follow ON')
		coroutine.sleep(delay)
		ipcflag = true
		followon(cmd2)
	elseif cmd == 'refresh' then
		log('IPC Refresh healbot')
		coroutine.sleep(delay)
		ipcflag = true
		refresh()
	elseif cmd == 'reload' then
		log('IPC Reload ADDON ' ..cmd2)
		coroutine.sleep(delay)
		ipcflag = true
		reload(cmd2)
	elseif cmd == 'unload' then
		log('IPC Unload ADDON ' ..cmd2)
		coroutine.sleep(delay)
		ipcflag = true
		unload(cmd2)
	end
	
	
end)