local packets = require('packets')
require('strings')

_addon.name = 'SendAllTarget'
_addon.version = '1.1'
_addon.author = 'Selindrile, Thanks and apologies to Arcon for abusing his code.'
_addon.commands = {'sendalltarget','sendallt','sendat','sat'}

windower.register_event('addon command',function (cmd,cmd2,...)
	if cmd == nil then return
	elseif cmd == 'stop' or cmd == 'unfollow' then
		windower.ffxi.run(false)
		windower.ffxi.follow()
	elseif cmd == 'alltarget' then
		local target = windower.ffxi.get_mob_by_target('t')
		windower.send_command('send @all sendalltarget target ' .. tostring(target.id))
	elseif cmd == 'youtarget' then
		local target = windower.ffxi.get_mob_by_target('t')
		windower.send_command('send '..cmd2..' sendalltarget target ' .. tostring(target.id))
	elseif cmd == 'target' then
		local id = tonumber(cmd2)
		local target = windower.ffxi.get_mob_by_id(id)
		if not target then
			return
		end
		
		local player = windower.ffxi.get_player()
		packets.inject(packets.new('incoming', 0x058, {
			['Player'] = player.id,
			['Target'] = target.id,
			['Player Index'] = player.index,
		}))
	elseif cmd == 'allcommand' then
		local command = ...
		local mobid = windower.ffxi.get_mob_by_target('t')
		if mobid and mobid.id then
			if command == nil then
				windower.send_command('send @all '..cmd2..' '..mobid.id..'')
			elseif cmd2 then
				windower.send_command('send @all '..cmd2..' '..command..' '..mobid.id..'')
			end
		end
	elseif cmd == 'youcommand' then
		local command = ...
		local mobid = windower.ffxi.get_mob_by_target('t')
		if mobid and mobid.id then
			windower.send_command('send '..cmd2..' '..command..' '..mobid.id..'')
		end
    end
end)