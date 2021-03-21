_addon.version = '0.0.7'
_addon.name = 'attackwithme'
_addon.author = 'yyoshisaur, modded by icy'
_addon.commands = {'attackwithme','atkwm','awm'}

-- 0.0.7: if enabled, slaves will now stay within range of target.
-- 0.0.6: nil checks

require('logger')
require('chat')
config = require('config')
local packets = require('packets')

-- settings file added by icy
defaults = {
	master = 'PlayerName',
	slaves = S{''},
	slaves_close_in = true,
	slaves_close_in_distance = 2.6,
}
local settings = config.load(defaults)

local help_text = [[
Commands: attackwithme, atkwm, awm
  //awm master <- toggles master on/off
  //awm slave on <- turns on slave and begins assisting the master
  //awm slave off <- turns off slave and stops assisting the master
Settings - { } are optional
  //awm set master {name} <- sets current player or name to auto load as master
  //awm set slave {name} <- sets current player or name to auto load as slave
  //awm closein <- toggles slaves closing in on the target
  //awm closein <distance> <- sets the slaves fighting distance]]

local is_master = false
local is_slave = false

local player_status = {
    ['Idle'] = 0,
    ['Engaged'] = 1,
}

local max_retry = 5

local function attack_on(id)
    local target = windower.ffxi.get_mob_by_id(id)

    if not target then
        -- error
        return
    end

    local p = packets.new('outgoing', 0x01A, {
        ["Target"] = target.id,
        ["Target Index"] = target.index,
        ["Category"] = 0x02 -- Engage Monster
    })
    packets.inject(p)

    log('Slave: Attack '..target.name)
end

local function attack_off()
    local player = windower.ffxi.get_player()

    if not player then
        -- error
        return
    end

    local p = packets.new('outgoing', 0x01A, {
        ["Target"] = player.id,
        ["Target Index"] = player.index,
        ["Category"] = 0x04 -- Disengage
    })

    packets.inject(p)

    log('Slave: Attack Off')
end

local function change_target(id)
    local target = windower.ffxi.get_mob_by_id(id)
    local player = windower.ffxi.get_player()

    if not target or not player then
        -- error
        return
    end

    local p = packets.new('incoming', 0x058, {
        ['Player'] = player.id,
        ['Target'] = target.id,
        ['Player Index'] = player.index,
    })

    packets.inject(p)

    log('Slave: Change Target ---> '..target.name)
end

local function switch_target(id)
    local target = windower.ffxi.get_mob_by_id(id)

    if not target then
        -- error
        return
    end

    local p = packets.new('outgoing', 0x01A, {
        ["Target"] = target.id,
        ["Target Index"] = target.index,
        ["Category"] = 0x0F -- Switch target
    })

    packets.inject(p)

    log('Slave: Attack ---> '..target.name)
end

local function target_lock_on()
    local player = windower.ffxi.get_player()
    if player and not player.target_locked then
        windower.send_command('input /lockon')
    end
end

local function heading_to(x, y)
	local p = windower.ffxi.get_mob_by_target('me')
	local x = x - p.x
	local y = y - p.y
	local h = math.atan2(x, y)
	return h - 1.5708
end

local function face_target(target_type) -- 't', 'bt'
	if not target_type then target_type = 't' end
	
	local mob = windower.ffxi.get_mob_by_target(target_type)
	if not mob then
		-- error
		return 
	end
	
	windower.ffxi.turn(heading_to(mob.x, mob.y))
end

local function close_in(target_type) -- 't', 'bt'
	if not settings.slaves_close_in then return end
	if not target_type then target_type = 't' end
	
	local mob = windower.ffxi.get_mob_by_target(target_type)
	if not mob then
		-- error
		return
	end
	
	local engaged_distance = 3
	if tonumber(settings.slaves_close_in_distance) then 
		engaged_distance = tonumber(settings.slaves_close_in_distance)
	end
	
	local dist = math.sqrt(mob.distance)
	if dist > engaged_distance then 
		closing_in = true
		log('Slave: Closing in ---> '..mob.name)
	else
		face_target()
	end
	
	while (mob and dist > engaged_distance) do
		windower.ffxi.run(heading_to(mob.x, mob.y))
		coroutine.sleep(0.2)
		mob = windower.ffxi.get_mob_by_target('t')
		if mob then
			dist = math.sqrt(mob.distance)
		else
			mob = nil
		end
	end
	
	closing_in = false
	windower.ffxi.run(false)
end

local function stop_follow()
	windower.send_command('setkey numpad7 down;wait .5;setkey numpad7 up;')
end

local function set_bool_color(bool)
    local bool_str = tostring(bool)
    if bool then
        bool_str = bool_str:color(5)
    else
        bool_str = bool_str:color(39)
    end
    return bool_str
end

windower.register_event('ipc message', function(message)
    local msg = message:split(' ')

    if not is_slave then
        return
    end

    if msg[1] == 'attack' then
        if msg[2] == 'on' then
            local id = tonumber(msg[3])
            local target = windower.ffxi.get_mob_by_id(id)

            if not target then
                log('Slave: Target not found!')
                return
            end

            if math.sqrt(target.distance) > 29 then
                log('Slave: ['..target.name..']'..' found, but too far!')
                return
            end

            attack_on(id)
            target_lock_on:schedule(1)
        elseif msg[2] == 'off' then
            attack_off()
        end
    elseif msg[1] == 'change' then
        local id = tonumber(msg[2])
        local target = windower.ffxi.get_mob_by_id(id)
        local player = windower.ffxi.get_player()

        if not target then
            log('Slave: Target not found!')
            return
        end

        local retry_count = 0
        repeat
            switch_target(id)
            coroutine.sleep(2)
            player = windower.ffxi.get_player()
            retry_count = retry_count + 1
        until player.status == player_status['Engaged'] or retry_count > max_retry

        target_lock_on:schedule(1)
		
		if settings.slaves_close_in then
			coroutine.sleep(1)
			while player.status == player_status['Engaged'] do
				if not closing_in then
					close_in()
				end
				coroutine.sleep(.5)
				player = windower.ffxi.get_player()
			end
		end
		
    elseif msg[1] == 'follow' then
        local id = msg[2]
        local mob = windower.ffxi.get_mob_by_id(id)
        if mob then
            local index = mob.index
            windower.ffxi.follow(index)
        end
    end
end)

function send_ipc_message_delay(msg)
    windower.send_ipc_message(msg)
end

windower.register_event('outgoing chunk', function(id, original, modified, injected, blocked)
    if not is_master then
        return
    end

    if id == 0x01A then
        local p = packets.parse('outgoing', original)
        if p['Category'] == 0x02 then
            -- send_ipc_message_delay:schedule(1, 'attack on '..tostring(p['Target']))
            log('Master: Attack On')
        elseif p['Category'] == 0x04 then
            windower.send_ipc_message('attack off')
            log('Master: Attack Off')
        end
    end
end)

windower.register_event('incoming chunk', function(id, original, modified, injected, blocked)
    if not is_master then
        return
    end

    if id == 0x058 then
        local p = packets.parse('incoming', original)
        send_ipc_message_delay:schedule(1, 'change '..tostring(p['Target']))
        log('Master: Change Target')
    end
end)

windower.register_event('addon command', function(...)
    local args = {...}

    if not args[1] then
        log(help_text)
        return
    end
	if args[2] then args[2] = args[2]:lower() end
    local mode = args[1]
	
    if mode == 'master' then
        is_master = true
        is_slave = false
        log('Master: '..set_bool_color(is_master), 'Slave: '..set_bool_color(is_slave))
    elseif mode == 'slave' then
        if args[2] then
			if args[2] == 'on' then
				is_slave = true
				is_master = false
			elseif args[2] == 'off' then
				is_slave = false
				is_master = false
			else
				log(help_text)
				return
			end
		else
			is_slave = not is_slave
			is_master = false
        end
        log('Master: '..set_bool_color(is_master), 'Slave: '..set_bool_color(is_slave))
		if is_slave then windower.send_command('input /autotarget off')
		else windower.send_command('input /autotarget on') end
		
    elseif mode == 'follow' or mode == 'f' then
        if is_master then
            local id = windower.ffxi.get_player().id
            windower.send_ipc_message('follow '..id)
        end
		
	elseif mode == 'set' then
		if args[2] then
			if args[2] == 'master' or args[2] == 'slave' then
				local pname = windower.ffxi.get_player().name
				if args[3] then 
					pname = args[3]:ucfirst() 
				end
				
				if args[2]:lower() == 'master' then
					if settings.master == pname then
						settings.master = ''
						log(pname, 'will no longer load as master')
					else
						log(pname, 'will now auto load as master')
					end
					settings.master = pname
				elseif args[2]:lower() == 'slave' then 
					if settings.slaves:contains(pname) then
						settings.slaves:remove(pname)
						log(pname, 'will no longer load as slave')
					else
						settings.slaves:add(pname)
						log(pname, 'will now auto load as slave')
					end
				end
				settings:save('All')
			end
		end
		
	elseif mode == 'closein' then
		if args[2] and tonumber(args[2]) then
			settings.slaves_close_in_distance = args[2]
			log('Slaves close in distance:', settings.slaves_close_in_distance)
		else
			settings.slaves_close_in = not settings.slaves_close_in			
			log('Slaves close in:', settings.slaves_close_in)
		end
		settings:save('All')
    else
        -- error
        log(help_text)
    end
end)

windower.register_event('login','load', function()
	local player = windower.ffxi.get_player()
	if settings.master:lower() == player.name:lower() then
		is_master = true
		is_slave = false
		log('Master: '..set_bool_color(is_master), 'Slave: '..set_bool_color(is_slave))
	end
end)