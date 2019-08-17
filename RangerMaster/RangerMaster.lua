_addon.author = 'Jyouya'
_addon.command = 'rm'
_addon.name = 'RangerMaster'
_addon.version = '1.0'

require('tables')
packets = require('packets')

target = nil
start_ra = false

prerender_event = nil
nexttime = os.clock()
timeout = nil
delay = 1

job_ws = {
	COR='Leaden Salute',
	RNG='Trueflight'
}

job_ja = {
	COR='Triple Shot',
	RNG='Double Shot'
}

windower.register_event('addon command', function(...)
	local args = T{...}
	local cmd = args[1]:lower()
	args:remove(1)
	if cmd == 'shoot' then
		local t = windower.ffxi.get_mob_by_target('t')
		windower.send_ipc_message('shoot %d':format(t.id))
	elseif cmd == 'ws' then
		local t = windower.ffxi.get_mob_by_target('t')
		windower.send_ipc_message('ws %d':format(t.id))
	elseif cmd == 'multishot' then
		windower.send_ipc_message('multishot')
	elseif cmd == 'assault' then
		local t = windower.ffxi.get_mob_by_target('t')
		windower.send_ipc_message('assault %d':format(t.id))
	end
end)

windower.register_event('ipc message', function(msg)
	local args = T(split(msg, ' '))
	local cmd = args[1]
	windower.add_to_chat(200,cmd)
	args:remove(1)
	if cmd:lower() == 'shoot' then
		if args[1] then
			target = args[1]
			-- if target is valid
			-- set flag to start doing ra
			local player = windower.ffxi.get_player()
			packets.inject(packets.new('incoming', 0x058, {
				['Player'] = player.id,
				['Target'] = target,
				['Player Index'] = player.index,
			}))
			windower.send_command('gs c face %d':format(target)) -- my gearswap has  auto-face-target, this makes keeps them from fighting.
			facetarget()
			delay = .2
			start_ra = true
			timeout = os.clock() + 5
		end
	elseif cmd:lower() == 'ws' then -- tell every cor/rng to ws
		if args[1] then
			start_ra = false
			target = args[1]
			local player = windower.ffxi.get_player()
			packets.inject(packets.new('incoming', 0x058, {
				['Player'] = player.id,
				['Target'] = target,
				['Player Index'] = player.index,
			}))
			facetarget()
			delay = .3
			windower.chat.input("/ws \"%s\" %d":format(job_ws[windower.ffxi.get_player().main_job],target))
		end
	elseif cmd:lower() == 'multishot' then
		windower.chat.input("/ja \%s\" <me>":format(job_ja[windower.ffxi.get_player().main_job]))
	elseif cmd:lower() == 'assault' then
		if args[1] then
			target = args[1]
			local player = windower.ffxi.get_player()
			packets.inject(packets.new('incoming', 0x058, {
				['Player'] = player.id,
				['Target'] = target,
				['Player Index'] = player.index,
			}))
			windower.chat.input("/pet assault %d":format(target))
		end
	end
end)

windower.register_event('incoming chunk', function(id, data, modified, injected, blocked)
    if (id == 0xe) and target then
        local p = packets.parse('incoming', data)
        if (p.NPC == target) and ((p.Mask % 8) > 3) then
            if not (p['HP %'] > 0) then
                target = nil
				start_ra = false
				timeout = nil
            end
        end
	elseif start_ra and id == 0x028 then -- detect when we start shooting
		local player = windower.ffxi.get_player()
		local parse = packets.parse('incoming', data)
		if parse.Actor == player.id then
			if parse.Category == 12 then -- we did an RA
				start_ra = false
				timeout = nil
			end
		end
    end
end)

function split(msg, match)
	if msg == nil then return '' end
	local length = msg:len()
	local splitarr = {}
	local u = 1
	while u <= length do
		local nextanch = msg:find(match,u)
		if nextanch ~= nil then
			splitarr[#splitarr+1] = msg:sub(u,nextanch-match:len())
			if nextanch~=length then
				u = nextanch+match:len()
			else
				u = length
			end
		else
			splitarr[#splitarr+1] = msg:sub(u,length)
			u = length+1
		end
	end
	return splitarr
end

function facetarget()
	if not autofacetarget then return end
	local t = windower.ffxi.get_mob_by_id(target)
	local destX = t.x
	local destY = t.y
	local direction = math.abs(PlayerH - math.deg(HeadingTo(destX,destY)))
	windower.ffxi.turn(HeadingTo(destX,destY))
end

function ft_target()
	local rh = rh_status()
	if rh.enabled and rh.target then
		return windower.ffxi.get_mob_by_id(rh.target)
	else
		return 
	end
end

function HeadingTo(X,Y)
	local X = X - windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id).x
	local Y = Y - windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id).y
	local H = math.atan2(X,Y)
	return H - 1.5708
end

function prerender()
	local curtime = os.clock()
	if nexttime + delay <= curtime then
		nexttime = curtime
		delay = 0.2
		if start_ra then
			windower.chat.input("/ra %d":format(target))
		end
		if timeout and timeout < os.clock() then
			target = nil
			start_ra = false
			timeout = nil
		end
	end
end

windower.register_event('prerender',prerender)