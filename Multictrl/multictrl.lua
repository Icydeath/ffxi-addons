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
texts = require('texts')



default = {

	avatar='ramuh',
	indi='torpor',
	dia=false,
	active=false,
	assist='',
}



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
	local cmd3 = args[2]
	local cmd4 = args[3]
	
	local term = table.concat({...}, ' ')

    term = term:gsub('<(%a+)id>', function(target_string)
        local entity = windower.ffxi.get_mob_by_target(target_string)
        return entity and entity.id or '<' .. target_string .. 'id>'
    end)
	
	
	
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
	elseif cmd == 'reset' then
		reset()
	elseif cmd == 'reload' then
		reload(cmd2)
	elseif cmd == 'd2' then
		d2()
	elseif cmd == 'unload' then
		unload(cmd2)
	elseif cmd == 'assist' then
		assist(cmd2,cmd3)
	elseif cmd == 'trib' then
		trib()
	elseif cmd == 'rads' then
		rads()
	elseif cmd == 'vorseal' then
		vorseal()	
	elseif cmd == 'buyalltemps' then
		buyalltemps()
	elseif cmd == 'smnburn' then
		smnburn()
	elseif cmd == 'geoburn' then
		geoburn()
	elseif cmd == 'burn' then
		burnset(cmd2,cmd3,cmd4)
	elseif cmd == 'send' then
		send(term)

    end
	
end)

function send(commands)
	
	if ipcflag == false then
		log('Sending all chars \"' .. commands .. '\"')
		ipcflag = true
		windower.send_command(commands)
		windower.send_ipc_message('send ' .. commands)
	elseif ipcflag == true then
		windower.send_command(commands)
	end
	ipcflag = false
end


function burnset(cmd2,cmd3,cmd4)
	
	player = windower.ffxi.get_player()
	
	if cmd2 == 'avatar' then
		if cmd3 ~= nil then
			if cmd3:lower() == 'ramuh' then
				settings.avatar = 'ramuh'
				--settings.save()
			elseif cmd3:lower() == 'ifrit' then
				settings.avatar = 'ifrit'
				--settings.save()
				
			else
				log('Invalid Avatar choice')
			end
		else
			log('Missing argument for Avatar')
		end
		
	elseif cmd2 == 'on' then
		settings.active = true
		
	elseif cmd2 == 'off' then
		settings.active = false
		
	elseif cmd2 == 'dia' then
		if cmd3 ~= nil then
			if cmd3 == 'on' then
				settings.dia = true
			elseif cmd3 == 'off' then
				settings.dia = false
			else
				log('Invalid DIA choice')
			end
		else
			log('Missing argument for DIA')
		end
	elseif cmd2 == 'indi' then
		if cmd3 ~= nil then
			if cmd3 == 'torpor' then
				settings.indi = 'torpor'
			elseif cmd3 == 'malaise' then
				settings.indi = 'malaise'
			elseif cmd3 == 'refresh' then
				settings.indi = 'refresh'
			end
		else
			log('Missing argument for INDI')
		end
	elseif cmd2 == 'init' then
		
		if settings.assist == '' then
			log('Cannot initialize until you set assist name')
		else
			for k, v in pairs(windower.ffxi.get_party()) do
				if type(v) == 'table' then
					if string.lower(v.name) == string.lower(settings.assist) then
						if v.mob == nil then
							-- Not in zone.
							log(v.name .. ' is not in zone, HB will NOT assist if player is not in zone.  Try again later.')
						
						else
							log('Initialize HB and assist, and disabled cures')
							if string.lower(v.name) == string.lower(player.name) then
								windower.send_command('hb reload; wait 1.5; hb disable cure; hb disable na')
							else
								windower.send_command('hb reload; wait 1.5; hb disable cure; hb disable na; hb assist ' ..settings.assist .. ' wait 1.0; hb on')
							end
						end
					end
				end
			end
		end
		
	elseif cmd2 == 'assist' then
		if cmd3 ~= nil then
			for k, v in pairs(windower.ffxi.get_party()) do
		
				if type(v) == 'table' then
					if string.lower(v.name) == string.lower(cmd3) then
						if v.mob == nil then
							-- Not in zone.
							log(v.name .. ' is not in zone, HB will NOT assist if player is not in zone.  Try again later.')
						
						else
							log('You are now assisting ' ..cmd3)
							settings.assist = cmd3
						end
					end
				end
			end
			
		else
			log('Missing argument for ASSIST')
		end
	else
		log('Invalid command')
	end

	if ipcflag == false then
		ipcflag = true
		if cmd2 == nil then
		cmd2 = 'a'
		end
		if cmd3 == nil then
			cmd3 = 'b'
		end
		if cmd4 == nil then
			cmd4 = 'c'
		end
		windower.send_ipc_message('burnset ' ..cmd2.. ' ' ..cmd3.. ' ' ..cmd4)
	end

	ipcflag = false
	display_box()
	
	
end

function init_box_pos()

	if burn_status then burn_status:destroy() end

	local settings = windower.get_windower_settings()
	local x,y
	
	--if settings["ui_x_res"] == 1920 and settings["ui_y_res"] == 1080 then
		--x,y = settings["ui_x_res"]-1917, settings["ui_y_res"]-18 -- -285, -18
	--else
	x,y = settings["ui_x_res"]-505, 45 -- -285, -18
	--end

	local font = displayfont or 'Arial'
	local size = displaysize or 11
	local bold = displaybold or true
	local bg = displaybg or 0
	local strokewidth = displaystroke or 2
	local stroketransparancy = displaytransparancy or 192
	
    burn_status = texts.new()
    burn_status:pos(x,y)
    burn_status:font(font)--Arial
    burn_status:size(size)
    burn_status:bold(bold)
    burn_status:bg_alpha(bg)--128
    burn_status:right_justified(false)
    burn_status:stroke_width(strokewidth)
    burn_status:stroke_transparency(stroketransparancy)
	

	burn_status:pos(x,y)
	
	display_box()
	--burn_status:show()
end

display_box = function()
    local str
	local clr = {
		r='\\cs(240,28,28)', -- Red for active
        h='\\cs(255,192,0)', -- Yellow for active booleans and non-default modals
		w='\\cs(255,255,255)', -- White for labels and default modals
        n='\\cs(192,192,192)', -- White for labels and default modals
        s='\\cs(96,96,96)' -- Gray for inactive booleans
    }
	burn_status:clear()
	burn_status:append(' ')

    if settings.active then
		burn_status:append(string.format("%s1HR Burn: %sON", clr.w, clr.r))

		if settings.avatar == 'ramuh' then
			burn_status:append(string.format("\n%s Avatar: %s" .. settings.avatar, clr.w, clr.h))
			
		elseif settings.avatar == 'ifrit' then
			burn_status:append(string.format("\n%s Avatar: %s" .. settings.avatar, clr.w, clr.h))
		end
		
		
		if settings.dia then
			burn_status:append(string.format("\n%s DIA: %sON", clr.w, clr.r))
		else
			burn_status:append(string.format("\n%s DIA: %sOFF", clr.w, clr.w))
		end
		
		if settings.indi == 'torpor' then
			burn_status:append(string.format("\n%s Indi Spell: %s" .. settings.indi, clr.w, clr.h))
		elseif settings.indi == 'malaise' then
			burn_status:append(string.format("\n%s Indi Spell: %s" .. settings.indi, clr.w, clr.h))
		elseif settings.indi == 'refresh' then
			burn_status:append(string.format("\n%s Indi Spell: %s" .. settings.indi, clr.w, clr.h))
		end
		
		if settings.assist ~= nil then
			burn_status:append(string.format("\n%s Assiting: %s" .. settings.assist, clr.w, clr.h))
		else
			burn_status:append(string.format("\n%s Assiting: %s", clr.w))
		end
		
		
    else
		burn_status:append(string.format("%s1HR Burn: %sOFF", clr.w, clr.w))
    end
	


	burn_status:show()
end

	
--burn_status = texts.new(display_box(),settings.text,settings)

function geoburn()
	
	player = windower.ffxi.get_player()
	
	if settings.active then
		log('GEO Burn Activated for Bolster!')
		if player.main_job == 'GEO' then
			log('GEO main job')
			if settings.dia then
				windower.send_command('hb debuff dia II')
			elseif not settings.dia then
				windower.send_command('hb debuff rm dia II')
			end
			windower.send_command('hb disable cure')
			windower.send_command('hb disable na')
			windower.send_command('hb on')
			if ipcflag == false then
				ipcflag = true
				windower.send_ipc_message('geoburn')
			end
			ipcflag = false
			
			coroutine.sleep(1.5)
			windower.send_command('input /ja "Bolster" <me>')
			coroutine.sleep(1.8)
			windower.send_command('input /ma "Geo-Frailty" <t>')
			coroutine.sleep(4.5)
			if settings.indi == 'torpor' then
				windower.send_command('input /ma "Indi-Torpor" <me>')
			elseif settings.indi == 'malaise' then
				windower.send_command('input /ma "Indi-Malaise" <me>')
			elseif settings.indti == 'refresh' then
				windower.send_command('input /ma "Indi-Refresh" <me>')
			end
			coroutine.sleep(4.5)
			windower.send_command('input /ja "Dematerialize" <me>')
			coroutine.sleep(0.75)
			windower.send_command('hb enable cure')
			windower.send_command('hb enable na')
			windower.send_command('hb mincure 3')
			windower.send_command('geo on')

		else
			log('Not GEO job, skipping')
			if ipcflag == false then
				ipcflag = true
				windower.send_ipc_message('geoburn')
			end
			ipcflag = false
		end
	else
		log('OneHour BURN not active!')
	end
	
end

function smnburn()

	player = windower.ffxi.get_player()
	if settings.active then
		log('SMN Burn active!')
		if player.main_job == 'SMN' then
			log('SMN main job')
			windower.send_command('hb on')
			if ipcflag == false then
				ipcflag = true
				windower.send_ipc_message('smnburn')
			end
			ipcflag = false
			-- check distance 21 or less
			coroutine.sleep(1.2)
			windower.send_command('input /ja "Astral Flow" <me>')
			coroutine.sleep(2.5)
			windower.send_command('input /ja "Assault" <t>')
			coroutine.sleep(4.2)
			windower.send_command('input /ja "Astral Conduit" <me>')
			coroutine.sleep(1.6)
			if settings.avatar == 'ramuh' then
				windower.send_command('exec VoltStrike.txt')
			elseif settings.avatar == 'ifrit' then
				windower.send_command('exec FlamingCrush.txt')
			end
		else
			log('Not SMN job, skipping')
			if ipcflag == false then
				ipcflag = true
				windower.send_ipc_message('smnburn')
			end
			ipcflag = false
		end
	else
		log('OneHour BURN not active!')
	end
	
end

function assist(cmd,namearg)
	
	if cmd == 'on' then
	
		if ipcflag == false then
			log('Assist Leader!')
			windower.send_command('hb assist off')
			windower.send_command('hb assist attack off')
			windower.send_ipc_message('assist on ' .. currentPC.name)
		elseif ipcflag == true then
			log('Assist & Attack -> ' ..namearg)
			windower.send_command('hb assist ' .. namearg)
			windower.send_command('wait 0.5; hb assist attack on')
			windower.send_command('wait 0.5; hb on')
		end
	elseif cmd == 'off' then
		if ipcflag == false then
			windower.send_command('hb assist off; hb assist attack off')
			windower.send_ipc_message('assist off')
		elseif ipcflag == true then
			windower.send_command('hb assist off; hb assist attack off')
		end
	end
	ipcflag = false
	
end

function reset()

	log('Reloading gearswap and healbot')
	windower.send_command('lua r healbot')
	windower.send_command('lua r gearswap')
	windower.send_command('gs enable all')
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('reset')
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
	currentPC=windower.ffxi.get_player()
	
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

function trib()
	log('Getting Tribulens')
	windower.send_command('escha trib')
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('trib')
	end
	ipcflag = false
end

function rads()
	log('Getting Radialens')
	windower.send_command('escha rads')
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('rads')
	end
	ipcflag = false
end

function vorseal()
	log('Getting Elvorseal')
	windower.send_command('escha vorseal')
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('vorseal')
	end
	ipcflag = false
end

function buyalltemps()
	log('Getting ALL TEMPS!')
	windower.send_command('escha buyall')
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('buyalltemps')
	end
	ipcflag = false
end


---------------------------------
--Helper functions--
---------------------------------

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

-- function(input, ...)
windower.register_event('ipc message', function(msg, ...) 
	local args = msg:split(' ')
	local cmd = args[1]
	local cmd2 = args[2]
	local cmd3 = args[3]
	local cmd4 = args[4]
	args:remove(1)
	local delay = get_delay()
	
		
	local term = msg:split(' ')
	term:remove(1)
	local send_cmd = table.concat(term, " ")
			
	
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
	elseif cmd == 'assist' then
		if cmd2 == 'on' then
			log('IPC Assist ON')
			coroutine.sleep(delay)
			ipcflag = true
			assist(cmd2,cmd3)
		elseif cmd2 == 'off' then
			log('IPC Assist OFF')
			coroutine.sleep(delay)
			ipcflag = true
			assist(cmd2)
		end
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
	elseif cmd == 'reset' then
		log('IPC reset gearswap and healbot')
		coroutine.sleep(delay)
		ipcflag = true
		reset()
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
	elseif cmd == 'trib' then
		log('IPC Getting Tribulens')
		coroutine.sleep(delay)
		ipcflag = true
		trib()
	elseif cmd == 'rads' then
		log('IPC Getting Radialens')
		coroutine.sleep(delay)
		ipcflag = true
		rads()
	elseif cmd == 'vorseal' then
		log('IPC Getting Elvorseal')
		coroutine.sleep(delay)
		ipcflag = true
		vorseal()
	elseif cmd == 'buyalltemps' then
		log('IPC TEMPS!')
		coroutine.sleep(delay)
		ipcflag = true
		buyalltemps()
	elseif cmd == 'smnburn' then
		log('IPC SMN Burn 1hr')
		ipcflag = true
		smnburn()
	elseif cmd == 'geoburn' then
		log('IPC GEO Burn 1hr')
		ipcflag = true
		geoburn()
	elseif cmd == 'burnset' then
		log('IPC Burn Settings')
		ipcflag = true
		burnset(cmd2, cmd3, cmd4)
	elseif cmd == 'send' then
		log('IPC Send: ' .. send_cmd)
		coroutine.sleep(delay)
		ipcflag = true
		send(send_cmd)
	end
	
	
end)

function loaded()


	settings = config.load(default)
	init_box_pos()
	

end

windower.register_event('load', loaded)